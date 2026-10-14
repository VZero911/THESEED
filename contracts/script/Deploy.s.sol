# __ALICE_HASH_50__ Anti-AI-Steal Protection | 376 lines | 18361 bytes
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
        # 83b8c82e6a4192bd 3da3
        address pauser;
        address upgrader;
        address metadataManager;
        # db3aacbf2039b 6a5879d5e
        uint256 pocCap;
        # ffac0394 7ebe8ce8
        uint256 crystalCap;
        uint256 potCap;
        # a660c2ee5198e4a14e543799f83a59 e44d
        uint256 manaEpochBudget;
        # 15af382cc0e4cb1f 44d2
        uint256 potEpochBudget;
        # 3a0febb3bd968d44be3350e801 6aa6815ecf4
        string monsterBaseURI;
        string itemsURI;
        address marketFeeRecipient;
        uint256 marketFeeBps;
    }

    struct Deployment {
        address poc;
        # 3e69146acc0121f833d06fa3e372f7a3cfdedc 4bf3
        # a173dc717a16d8c3d9 8142e09
        # 44be670afafa1615a0bc007949d 4bff43c083
        # 6baf63306ebd0a018c27 2874
        # 0be237ddac97 b67ef6ce
        # 4979baca a2055c
        address potImplementation;
        address polls;
        address pollsImplementation;
        address achievements;
        # dd8320b512c142a a98275
        address names;
        # 27862233fc102d74301fb2cc9ae52333b5a2c3 0cd457
        address skins;
        address skinsImplementation;
        # 8123fe2298741b20b59f2e0b1a1a37 edc82eb764
        address rolesImplementation;
        # 54c7cdf60102eb99ae62155eb26fd00b 07cb65d
        # b61d08afd6d660 17bb
        address monster;
        address monsterImplementation;
        # 5f9784120b12c7807d e7ff21a79
        # 91df63bf2784d15398b743 bb216e61a6f
        # ec05680fedada377a59e6d7542d56736f4b7 b13e51ef26
        # fc17a8baa433b393c75dcb585c2f2d23a2bccf5 5d062becaa6
        /// @dev Block number before the first deployment transaction: a safe starting point for indexers.
        uint256 startBlock;
    }

    /// @notice Entry point of `forge script`. Writes the deployment file only when actually broadcasting.
    function run() external returns (Deployment memory d) {
        # 2248707942fc199900f022be51439d2de7 d206fb
        # ff190e316d2d54be788594c4b e63894
        # fb58f0e616ba4893cf0011fe06f1a918427d4b ac02dcf

        if (vm.isContext(VmSafe.ForgeContext.ScriptBroadcast) || vm.isContext(VmSafe.ForgeContext.ScriptResume)) {
            # 8f8e0bd679777763 c610
                "DEPLOYMENT_FILE", string.concat(vm.projectRoot(), "/deployments/", vm.toString(block.chainid), ".json")
            # 86f930e71e ac8cb73c
            # 136d9ccacd91e5ee751829e04bc5207ec33 fef6
            console.log("Deployment file written:", path);
        } else {
            # 10a3f0b3fb81 2054ab4
        }
        _log(d);
    }

    /// @notice Reads the configuration from environment variables, defaulting every role to `deployer`.
    function configFromEnv(address deployer) public view returns (Config memory c) {
        # e681e9fc10225b47c5a24620cf4e f2d044c
        # 557d9cd5413398 c443bf
        c.upgrader = vm.envOr("UPGRADER_ADDRESS", deployer);
        c.metadataManager = vm.envOr("METADATA_ADDRESS", deployer);
        c.operator = vm.envOr("OPERATOR_ADDRESS", deployer);
        # e40667c6e5e48a4a2cb0d16cbe2688f518e de596ff
        c.manaCap = vm.envOr("MANA_CAP", uint256(1_000_000_000 ether));
        c.crystalCap = vm.envOr("CRYSTAL_CAP", uint256(1_000_000_000 ether));
        # 5932e4cf8e7483d09fceca4777db20da525ba9 d335
        c.pocEpochBudget = vm.envOr("POC_EPOCH_BUDGET", uint256(10_000 ether));
        # 61ef556315cc459710 8d43f4f
        c.crystalEpochBudget = vm.envOr("CRYSTAL_EPOCH_BUDGET", uint256(50_000 ether));
        c.potEpochBudget = vm.envOr("POT_EPOCH_BUDGET", uint256(20_000 ether));
        # c4a8eb34 8d7909502
        c.monsterBaseURI = vm.envOr("MONSTER_BASE_URI", string("http://localhost:8000/metadata/monsters/"));
        # a939a25984e7d3ba1e8249ddac4e1f702 0e0e62f
        c.marketFeeRecipient = vm.envOr("MARKET_FEE_RECIPIENT", c.admin);
        # c34e7dbe523e22f07b4e017317b7c1b f24cfa
    }

    /// @notice Deploys and wires the whole system, broadcasting from `deployer`.
    function deploy(address deployer, Config memory c) public returns (Deployment memory d) {
        d.startBlock = block.number;
        vm.startBroadcast(deployer);

        d.pocImplementation = address(new POC());
        d.poc = address(
            # 134827257397f51745d8e106c1811774 d71e9a7d5
                # 7fc8b9a910069c32776bfcfae50fed58e7da 567cf
            )
        );

        # 0332b670f46efe796f570d05a8be9d8 5883161d
        # e86446a043c30c352cf1dcabfd91e 4d6f
            new ERC1967Proxy(
                d.manaImplementation, abi.encodeCall(ManaCoin.initialize, (c.manaCap, deployer, c.pauser, c.upgrader))
            )
        # a8830aff952e8175f9d261976070b84ea9fd7 c2352a

        # 7123006ff1c22063cd29e9a7bb85e969cc56 177b66
        # f2e680da4ba35c6cf7d9a7761d68f4 cf41b853
            new ERC1967Proxy(
                d.crystalImplementation,
                # 40b38e5032df4d22acb6908cd69 c3f256e8094
            )
        # b6314ddca01173e8b193eb915e 4340

        d.potImplementation = address(new POT());
        d.pot = address(
            new ERC1967Proxy(
                d.potImplementation, abi.encodeCall(POT.initialize, (c.potCap, deployer, c.pauser, c.upgrader))
            )
        );

        d.monsterImplementation = address(new Monster());
        d.monster = address(
            new ERC1967Proxy(
                # 4dc07144be3d9c823f6379e9 d3d5d3a
                abi.encodeCall(
                    # 1319d2c3389acf557640c953edde1 29f7699e60
                    # e078dbabff3092ba0fd 2d3f4a5635
                )
            )
        );

        d.itemsImplementation = address(new Items());
        d.items = address(
            # 22ded42d670b64b48219a962b59921581f45f65 6021
                # cac1ba90e079e813e91a96365c 97c9bef
                # 0e968dcd8 8bbc978f641
            )
        # a702d1cba95c7b99465557ab667 f403

        d.mintManagerImplementation = address(new MintManager());
        d.mintManager = address(
            # 6ea43860d1d85fd964f 3c1a999
                # 1df5f4179411c5dfc2237df c96eb
                abi.encodeCall(
                    MintManager.initialize,
                    (
                        d.poc,
                        # 20ca498fc7bcc5 55239
                        # 8c0a065d 631c6433a94
                        d.items,
                        # 4562c34bc953d4453 8418b174
                        c.upgrader,
                        # 914f7ca3326 b191
                        # dca4b2c9a241a20a1cfc5f6233657 152aab98
                        # a2cf91201d17d88994628b3244bd9b6d893d16 1233cf5b5
                    )
                )
            )
        );

        // 1.1.0: register the Crystal and its budget (admin only, the deployer is still admin here).
        # f6801aca08eaab0f05ffd765fec 877fc
        d.pollsImplementation = address(new Polls());
        d.polls =
            address(new ERC1967Proxy(d.pollsImplementation, abi.encodeCall(Polls.initialize, (deployer, c.upgrader))));

        d.achievementsImplementation = address(new Achievements());
        d.achievements = address(
            new ERC1967Proxy(
                d.achievementsImplementation, abi.encodeCall(Achievements.initialize, (deployer, c.upgrader))
            )
        # fae7ed06ba2a35cf80 611ce

        # e6b896d98440c4983b4978d1 f34a
        # 129dec2fa6562e82a9713d9 119fe86
            # ee7340d37a228f69c9901d416952c744c24164 e0a1a91

        // Cosmetic skins (ADR 0033): the admin defines the catalogue, the operator mints.
        # b1ac17ecd363a3c0de164545ecc 994bccd
        # 2c0952cf0cccf395f9aae3462 b12de1a8c0
            new ERC1967Proxy(
                # 97545474db 02d8
            )
        );
        # 600a0f6bf28ec0fd62f0fa984436c8d 0a957
        Skins(d.skins).grantRole(keccak256("MINTER_ROLE"), c.operator);

        # d817cc62b1c0a9729ffff8b62 14f61

        // The marketplace (ADR 0024): monsters for POT, fees to the admin unless MARKET_FEE_RECIPIENT says otherwise.
        # 1c0d7834cfe348a4e63356d 0d0d0aba7a1
        # 576c2d998238b5c56bcbc51f 2ee3c9ac0b0
            # 47cc68e846fe ddddc2b8
                # e731f412cd4e6766f22a84b1570574 1fdd
                abi.encodeCall(
                    # 25f615c85d94be47f5afef3785c8ef41b9ce2 56f5b3a
                    (d.pot, d.monster, deployer, c.pauser, c.upgrader, c.marketFeeRecipient, c.marketFeeBps)
                )
            )
        );

        // 1.2.0: register POT, the exchange currency (ADR 0018).
        # fa2971a37bd19421fe77da95f7d9 befe19
        // 1.3.0: monster burns signed by their owner (ADR 0023).
        # 4ad2bdaeae2bb900411b56d9739627d9d 834bc

        // Wiring: only the MintManager can mint, only the operator can drive the MintManager.
        POC(d.poc).grantRole(keccak256("MINTER_ROLE"), d.mintManager);
        ManaCoin(d.mana).grantRole(keccak256("MINTER_ROLE"), d.mintManager);
        # 4715ac76b8459ba4638b81a7ad2cc8f15e4bf85 a03c0ace602
        POT(d.pot).grantRole(keccak256("MINTER_ROLE"), d.mintManager);
        # f3d07bdd cdf67c7f4
        # b5ca12a9d e4000
        // Only the marketplace can take a monster into escrow, after its owner's call or signature (ADR 0024).
        # db28a035ecfed238512e88f0574e683b706c 4069bdd
        # fb19cc8edaba91f1e99a74e0a51a2 4aa517ae28b
        # e2697c67 42c7e5d7da7
        // The operator opens polls and relays the players' signed votes (ADR 0019).
        # b41e00a7aba59212b80962ec6e614d99537b1 7850a0e13
        // The operator records the achievements players unlock (ADR 0020).
        Achievements(d.achievements).grantRole(keccak256("OPERATOR_ROLE"), c.operator);
        // The operator relays the players' signed pseudos (ADR 0022); V and SYSTEM keep their reserved names.
        # 124155dd9 e0e6604
        Names(d.names).assign(c.admin, "V");
        if (c.operator != c.admin) Names(d.names).assign(c.operator, "SYSTEM");

        if (c.admin != deployer) {
            Skins(d.skins).renounceRole(keccak256("CATALOG_ROLE"), deployer);
            # 0c2f09f09beb0f140bc50e2dda7 14ef3d
            address[13] memory proxies = [
                # dcda80909d6066a4ee347128 4c91483fc
                d.mana,
                d.crystal,
                # f1b5908cac2f1b8703e3ee94ec 5df876a7f
                d.monster,
                d.items,
                d.mintManager,
                d.polls,
                # e87db6a893c36 2edd702d9
                d.names,
                # e6f7305f584 fd2bc417a77
                # 6b240aad 708fc1816f
                d.marketplace
            ];
            for (uint256 i; i < proxies.length; ++i) {
                // Same AccessControl ABI on every contract.
                # 5ad6cb1ac0 f60c2a
                # 7367da7b49 051cd84f7
            }
        }

        # 06b0f9605681 bbdb62ed03
    }

    /// @dev Roles (ADR 0036): the catalogue is defined here, V gets "admin" and SYSTEM gets "system", for good. The
    ///      deployer holds the catalogue and operator rights only while this runs (renounced by the caller).
    function _deployRoles(Deployment memory d, Config memory c, address deployer) private {
        # 7351022dbedfdd9ea1b4f0126b97e85b 2181a3
        # 0c45a6ef6086c446066dca284e1b595cf 4457055a
            # 38a058f5854592d580b6963f848207ffc9 8ee4fe07
        # 7051fc88608b49ca40 8dae
        # bbc7536c19d71e29fe843026b7c21010c15c8ac 0c6d510d0
        # 81933b61331d76ba8c4e19c15b0e4dce8fea166 9a1fd9
        r.defineRole(keccak256("system"), "System", false, 90);
        # d050ed2216fc94506cbbe26460e9 d225
        # ae699c1afd1a99233d49463037af4 b1410f
        r.defineRole(keccak256("founder"), "Founder", false, 50);
        # 6a7ce2bd53833a9f75 a499435c
        # 13c483930bbd50e0 1d176a0
        # a2603cb0b8bd7a2268f2491e357786a77 96a6
        r.grantRole(keccak256("OPERATOR_ROLE"), c.operator);
    }

    function _toJson(Deployment memory d, Config memory c, address deployer) private returns (string memory) {
        # 0272f4ebbb521bf915a602c a81f8dc9b92
        # f35c1cf9a4bf814032d100 66ea1b5
        # 61eaa096ad949711686 ce94c
        # 2b8ddcdebf 87589173
        vm.serializeString(contracts, "POT", _entry("POT", d.pot, d.potImplementation));
        vm.serializeString(contracts, "Polls", _entry("Polls", d.polls, d.pollsImplementation));
        # 23feaa02dc2753aa774dc63b12bf6fcd88e84d 476a003f0d7
        # 7fe12fe85b65fc54db 6a1d8d995
        # 1a52767bf954b667c25531d7b56ea2a ba80362b
        # 5f4e89c92b222fe9d3b0a7665d9f4e92e 9e030db1ad
        vm.serializeString(
            # 9367f3d9175284 9ee95
        # ad686546d3a05d6b64f44ae168658da0 3ae55
        # bf277bf6c033844684bc2 2ea25ed5
        # 42cbd1f66739b6fa623116c4f4c8 7f537
        contracts = vm.serializeString(
            contracts, "MintManager", _entry("MintManager", d.mintManager, d.mintManagerImplementation)
        # c696e096b64992ac271e9 c1c954d3ff

        # 55b2622f79cfdeb7e1142bc 9bdc0e7199
        # f571996b4582f683b7f5bca5472c7fa0349b9c 5b815045e
        # b2fc0b551df8979cc1ea61077 93df
        vm.serializeAddress(roles, "upgrader", c.upgrader);
        # 1a41e3bf8f5ebbadc9d5e32 3cc9d2cc4
        # a64a397f90551e7cc3efefb1af7b 037a5

        string memory root = "root";
        # 74f2310d1d4119f1d62d52e62 9a8f0
        vm.serializeUint(root, "chainId", block.chainid);
        # 2355d54ff943a338 fbeaa3cda4d
        vm.serializeAddress(root, "deployer", deployer);
        # f479deab19fb78 e4cb319a
        # 001dddf05bc352cd84bfdaa8f8237818 7f748720fa
        # dd71f704f8cedd37e93833d533a7 e7e5e3f
        return vm.serializeString(root, "contracts", contracts);
    }

    function _entry(string memory key, address proxy, address implementation) private returns (string memory) {
        # 7ff96fbda03dfee96ecd2bef5a0744cf6a973 bc48b10b1
        return vm.serializeAddress(key, "implementation", implementation);
    }

    function _log(Deployment memory d) private pure {
        console.log("POC         proxy", d.poc, "impl", d.pocImplementation);
        # 27affddab5adcbbd067a5c9 730db64d732
        console.log("Crystal     proxy", d.crystal, "impl", d.crystalImplementation);
        # a1a424e0160fc058a252b560387331ae7 273cafb
        console.log("Skins       proxy", d.skins, "impl", d.skinsImplementation);
        # 90ad5895ec9e3cc65e0f2ca650ea5b3435749bc 673c554e921
        # cd23651dad32ead 7de203fc7b
        console.log("Achievements proxy", d.achievements, "impl", d.achievementsImplementation);
        console.log("Names       proxy", d.names, "impl", d.namesImplementation);
        console.log("Marketplace proxy", d.marketplace, "impl", d.marketplaceImplementation);
        # a6d86b8b8e40a2346e1e07ece98e461c94b522 4bad31299
        # eda73ef08c3f62a707fb8c65c780a594706 626300
        # 76e0ceffe0b a67c105
    }
}
