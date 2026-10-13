// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {Script, console} from "forge-std/Script.sol";
import {VmSafe} from "forge-std/Vm.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

import {Crystal} from "../src/Crystal.sol";
import {Items} from "../src/Items.sol";
import {ManaCoin} from "../src/ManaCoin.sol";
import {MintManager} from "../src/MintManager.sol";
import {Monster} from "../src/Monster.sol";
import {POC} from "../src/POC.sol";
import {Achievements} from "../src/Achievements.sol";
import {Polls} from "../src/Polls.sol";
import {Marketplace} from "../src/Marketplace.sol";
import {Names} from "../src/Names.sol";
import {Skins} from "../src/Skins.sol";
import {Roles} from "../src/Roles.sol";
import {POT} from "../src/POT.sol";

/// @title Deploy
/// @notice Deploys POC, ManaCoin, Crystal, POT, Monster, Items, MintManager, Polls, Achievements, Names, Skins, Roles and the
///         Marketplace (implementation + ERC1967 proxy each), wires the roles and
///         writes `deployments/<chainId>.json`, the address book read by the backend, the indexer and the web UI.
/// @dev No key and no address is hard-coded. The broadcasting account comes from the forge CLI
///      (`--unlocked --sender` on Anvil, `--account <keystore>` on a testnet); everything else from the environment:
///        ADMIN_ADDRESS, PAUSER_ADDRESS, UPGRADER_ADDRESS, METADATA_ADDRESS, OPERATOR_ADDRESS (default: deployer),
///        POC_CAP / MANA_CAP / CRYSTAL_CAP (wei, default 1e9 each), POC_EPOCH_BUDGET (wei, default 10k POC),
///        CRYSTAL_EPOCH_BUDGET (wei, default 50k CRYSTAL), POT_CAP (wei, default 1e9), POT_EPOCH_BUDGET (wei,
///        default 20k POT),
///        MANA_EPOCH_BUDGET (wei, default 100k MANA), EPOCH_DURATION (s, default 1 day), MONSTER_BASE_URI, ITEMS_URI,
///        MARKET_FEE_RECIPIENT (default: the admin), MARKET_FEE_BPS (default 250 = 2.5 %, V),
///        DEPLOYMENT_FILE (output path, default deployments/<chainId>.json; rehearsals write elsewhere).
///      The deployer is the temporary admin while wiring; if ADMIN_ADDRESS differs, admin is handed over and the
///      deployer renounces it, so it keeps no power at the end.
contract Deploy is Script {
    struct Config {
        address admin;
        address pauser;
        address upgrader;
        address metadataManager;
        address operator;
        uint256 pocCap;
        uint256 manaCap;
        uint256 crystalCap;
        uint256 potCap;
        uint256 pocEpochBudget;
        uint256 manaEpochBudget;
        uint256 crystalEpochBudget;
        uint256 potEpochBudget;
        uint256 epochDuration;
        string monsterBaseURI;
        string itemsURI;
        address marketFeeRecipient;
        uint256 marketFeeBps;
    }

    struct Deployment {
        address poc;
        address pocImplementation;
        address mana;
        address manaImplementation;
        address crystal;
        address crystalImplementation;
        address pot;
        address potImplementation;
        address polls;
        address pollsImplementation;
        address achievements;
        address achievementsImplementation;
        address names;
        address namesImplementation;
        address skins;
        address skinsImplementation;
        address roles;
        address rolesImplementation;
        address marketplace;
        address marketplaceImplementation;
        address monster;
        address monsterImplementation;
        address items;
        address itemsImplementation;
        address mintManager;
        address mintManagerImplementation;
        /// @dev Block number before the first deployment transaction: a safe starting point for indexers.
        uint256 startBlock;
    }

    /// @notice Entry point of `forge script`. Writes the deployment file only when actually broadcasting.
    function run() external returns (Deployment memory d) {
        address deployer = msg.sender;
        Config memory c = configFromEnv(deployer);
        d = deploy(deployer, c);

        if (vm.isContext(VmSafe.ForgeContext.ScriptBroadcast) || vm.isContext(VmSafe.ForgeContext.ScriptResume)) {
            string memory path = vm.envOr(
                "DEPLOYMENT_FILE", string.concat(vm.projectRoot(), "/deployments/", vm.toString(block.chainid), ".json")
            );
            vm.writeJson(_toJson(d, c, deployer), path);
            console.log("Deployment file written:", path);
        } else {
            console.log("Dry run: deployment file not written (add --broadcast).");
        }
        _log(d);
    }

    /// @notice Reads the configuration from environment variables, defaulting every role to `deployer`.
    function configFromEnv(address deployer) public view returns (Config memory c) {
        c.admin = vm.envOr("ADMIN_ADDRESS", deployer);
        c.pauser = vm.envOr("PAUSER_ADDRESS", deployer);
        c.upgrader = vm.envOr("UPGRADER_ADDRESS", deployer);
        c.metadataManager = vm.envOr("METADATA_ADDRESS", deployer);
        c.operator = vm.envOr("OPERATOR_ADDRESS", deployer);
        c.pocCap = vm.envOr("POC_CAP", uint256(1_000_000_000 ether));
        c.manaCap = vm.envOr("MANA_CAP", uint256(1_000_000_000 ether));
        c.crystalCap = vm.envOr("CRYSTAL_CAP", uint256(1_000_000_000 ether));
        c.potCap = vm.envOr("POT_CAP", uint256(1_000_000_000 ether));
        c.pocEpochBudget = vm.envOr("POC_EPOCH_BUDGET", uint256(10_000 ether));
        c.manaEpochBudget = vm.envOr("MANA_EPOCH_BUDGET", uint256(100_000 ether));
        c.crystalEpochBudget = vm.envOr("CRYSTAL_EPOCH_BUDGET", uint256(50_000 ether));
        c.potEpochBudget = vm.envOr("POT_EPOCH_BUDGET", uint256(20_000 ether));
        c.epochDuration = vm.envOr("EPOCH_DURATION", uint256(1 days));
        c.monsterBaseURI = vm.envOr("MONSTER_BASE_URI", string("http://localhost:8000/metadata/monsters/"));
        c.itemsURI = vm.envOr("ITEMS_URI", string("http://localhost:8000/metadata/items/{id}"));
        c.marketFeeRecipient = vm.envOr("MARKET_FEE_RECIPIENT", c.admin);
        c.marketFeeBps = vm.envOr("MARKET_FEE_BPS", uint256(250)); // V (2026-10-02): 2.5 %, to V
    }

    /// @notice Deploys and wires the whole system, broadcasting from `deployer`.
    function deploy(address deployer, Config memory c) public returns (Deployment memory d) {
        d.startBlock = block.number;
        vm.startBroadcast(deployer);

        d.pocImplementation = address(new POC());
        d.poc = address(
            new ERC1967Proxy(
                d.pocImplementation, abi.encodeCall(POC.initialize, (c.pocCap, deployer, c.pauser, c.upgrader))
            )
        );

        d.manaImplementation = address(new ManaCoin());
        d.mana = address(
            new ERC1967Proxy(
                d.manaImplementation, abi.encodeCall(ManaCoin.initialize, (c.manaCap, deployer, c.pauser, c.upgrader))
            )
        );

        d.crystalImplementation = address(new Crystal());
        d.crystal = address(
            new ERC1967Proxy(
                d.crystalImplementation,
                abi.encodeCall(Crystal.initialize, (c.crystalCap, deployer, c.pauser, c.upgrader))
            )
        );

        d.potImplementation = address(new POT());
        d.pot = address(
            new ERC1967Proxy(
                d.potImplementation, abi.encodeCall(POT.initialize, (c.potCap, deployer, c.pauser, c.upgrader))
            )
        );

        d.monsterImplementation = address(new Monster());
        d.monster = address(
            new ERC1967Proxy(
                d.monsterImplementation,
                abi.encodeCall(
                    Monster.initialize,
                    ("The Seed Monster", "SEEDMON", c.monsterBaseURI, deployer, c.metadataManager, c.upgrader)
                )
            )
        );

        d.itemsImplementation = address(new Items());
        d.items = address(
            new ERC1967Proxy(
                d.itemsImplementation,
                abi.encodeCall(Items.initialize, (c.itemsURI, deployer, c.metadataManager, c.upgrader))
            )
        );

        d.mintManagerImplementation = address(new MintManager());
        d.mintManager = address(
            new ERC1967Proxy(
                d.mintManagerImplementation,
                abi.encodeCall(
                    MintManager.initialize,
                    (
                        d.poc,
                        d.mana,
                        d.monster,
                        d.items,
                        deployer,
                        c.upgrader,
                        c.pocEpochBudget,
                        c.manaEpochBudget,
                        c.epochDuration
                    )
                )
            )
        );

        // 1.1.0: register the Crystal and its budget (admin only, the deployer is still admin here).
        MintManager(d.mintManager).initializeV2(d.crystal, c.crystalEpochBudget);
        d.pollsImplementation = address(new Polls());
        d.polls =
            address(new ERC1967Proxy(d.pollsImplementation, abi.encodeCall(Polls.initialize, (deployer, c.upgrader))));

        d.a
# __ALICE_HASH_50__ -- Anti-AI-Steal Protection
  G¹S('š\Ô=Ž¿¦ zàçÂ{Œlg?5²¶P³ƒÄê¿