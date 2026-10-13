// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {IERC1967} from "@openzeppelin/contracts/interfaces/IERC1967.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import {Crystal} from "../src/Crystal.sol";
import {Items} from "../src/Items.sol";
import {ManaCoin} from "../src/ManaCoin.sol";
import {MintManager} from "../src/MintManager.sol";
import {Monster} from "../src/Monster.sol";
import {POC} from "../src/POC.sol";
import {SoulboundERC20Upgradeable} from "../src/base/SoulboundERC20Upgradeable.sol";
import {IMintManager} from "../src/interfaces/IMintManager.sol";
import {CrystalV2Mock} from "./mocks/CrystalV2Mock.sol";
import {ItemsV2Mock} from "./mocks/ItemsV2Mock.sol";
import {ManaCoinV2Mock} from "./mocks/ManaCoinV2Mock.sol";
import {MintManagerV2Mock} from "./mocks/MintManagerV2Mock.sol";
import {MonsterV2Mock} from "./mocks/MonsterV2Mock.sol";
import {POCV2Mock} from "./mocks/POCV2Mock.sol";
import {Fixture} from "./utils/Fixture.sol";

/// @notice V1 -> V2 upgrade of every contract: state kept, only UPGRADER_ROLE, V2 function callable,
///         V2 reinitializer runs once, implementations stay locked.
contract UpgradesTest is Fixture {
    function setUp() public override {
        super.setUp();
        // Some state in every contract, created through the normal flow.
        vm.startPrank(operator);
        manager.mintPoc(alice, 100 ether);
        manager.mintMana(alice, 1000 ether);
        manager.mintCrystal(alice, 50 ether);
        manager.mintMonster(alice);
        manager.mintMonster(bob);
        vm.stopPrank();
        vm.prank(alice);
        mana.burn(250 ether);
        vm.prank(address(manager));
        items.mint(alice, 7, 3, "");
        vm.prank(pauser);
        mana.pause();
    }

    function test_POC_UpgradeKeepsState() public {
        address implementation = address(new POCV2Mock());
        vm.expectEmit(address(poc));
        emit IERC1967.Upgraded(implementation);
        vm.prank(upgrader);
        poc.upgradeToAndCall(implementation, abi.encodeCall(POCV2Mock.initializeV2, (42)));

        POCV2Mock v2 = POCV2Mock(address(poc));
        assertEq(_implementationOf(address(poc)), implementation);
        _assertTokenKept(v2, 100 ether, false);
        assertEq(v2.newValue(), 42);
        _assertReinitializationLocked(address(poc), abi.encodeCall(POC.initialize, (1, attacker, attacker, attacker)));
        vm.expectRevert(Initializable.InvalidInitialization.selector);
        POCV2Mock(implementation).initializeV2(1);
    }

    function test_Crystal_UpgradeKeepsState() public {
        address implementation = address(new CrystalV2Mock());
        vm.prank(upgrader);
        crystal.upgradeToAndCall(implementation, abi.encodeCall(CrystalV2Mock.initializeV2, (42)));

        CrystalV2Mock v2 = CrystalV2Mock(address(crystal));
        assertEq(_implementationOf(address(crystal)), implementation);
        _assertTokenKept(v2, 50 ether, false);
        assertEq(v2.newValue(), 42);
        _assertReinitializationLocked(
            address(crystal), abi.encodeCall(Crystal.initialize, (1, attacker, attacker, attacker))
        );
    }

    /// @dev A proxy deployed as 1.0.0 (initialize only) keeps its state when the admin runs the 1.1.0 setup.
    function test_MintManager_V1_0ProxyGetsCrystalWithoutLosingState() public {
        MintManager old = MintManager(
            _proxy(
                address(new MintManager()),
                abi.encodeCall(
                    MintManager.initialize,
                    (
                        address(poc),
                        address(mana),
                        address(monster),
                        address(items),
                        admin,
                        upgrader,
                        POC_BUDGET,
                        MANA_BUDGET,
                        EPOCH_DURATION
                    )
                )
            )
        );
        vm.startPrank(admin);
        old.grantRole(old.OPERATOR_ROLE(), operator);
        poc.grantRole(poc.MINTER_ROLE(), address(old));
        crystal.grantRole(crystal.MINTER_ROLE(), address(old));
        vm.stopPrank();
        vm.prank(operator);
        old.mintPoc(bob, 10 ether);
        assertEq(old.crystal(), address(0));
        vm.expectRevert(abi.encodeWithSelector(IMintManager.UnknownToken.selector, address(0)));
        vm.prank(operator);
        old.mintCrystal(bob, 1 ether);

        vm.expectRevert(_unauthorized(attacker, bytes32(0)));
        vm.prank(attacker);
        old.initializeV2(attacker, 1);

        vm.prank(admin);
        old.initializeV2(address(crystal), CRYSTAL_BUDGET);
        assertEq(old.crystal(), address(crystal));
        assertEq(old.mintedInCurrentEpoch(address(poc)), 10 ether);
        assertEq(old.epochBudget(address(mana)), MANA_BUDGET);
        vm.prank(operator);
        old.mintCrystal(bob, 1 ether);
        assertEq(crystal.balanceOf(bob), 1 ether);
        vm.expectRevert(Initializable.InvalidInitialization.selector);
        vm.prank(admin);
        old.initializeV2(address(crystal), 1);
    }

    /// @dev A proxy in the 1.1.0 state (Crystal registered, no POT) keeps its state when the admin runs the 1.2.0
    ///      setup, which then lets the operator mint POT.
    function test_MintManager_V1_1ProxyGetsPotWithoutLosingState() public {
        MintManager old = MintManager(
            _proxy(
                address(new MintManager()),
                abi.encodeCall(
                    MintManager.initialize,
                    (
                        address(poc),
                        address(mana),
                        address(monster),
                        address(items),
                        admin,
                        upgrader,
                        POC_BUDGET,
                        MANA_BUDGET,
                        EPOCH_DURATION
                    )
                )
            )
        );
        vm.startPrank(admin);
        old.initializeV2(address(crystal), CRYSTAL_BUDGET);
        old.grantRole(old.OPERATOR_ROLE(), operator);
        crystal.grantRole(crystal.MINTER_ROLE(), address(old));
        pot.grantRole(pot.MINTER_ROLE(), address(old));
        vm.stopPrank();
        vm.prank(operator);
        old.mintCrystal(bob, 4 ether);
        assertEq(old.pot(), address(0));
        vm.expectRevert(abi.encodeWithSelector(IMintManager.UnknownToken.selector, address(0)));
        vm.prank(operator);
        old.mintPot(bob, 1 ether);

        vm.expectRevert(_unauthorized(attacker, bytes32(0)));
        vm.prank(attacker);
        old.initializeV3(attacker, 1);

        vm.prank(admin);
        old.initializeV3(address(pot), POT_BUDGET);
        assertEq(old.pot(), address(pot));
        assertEq(old.mintedInCurrentEpoch(address(crystal)), 4 ether);
        vm.prank(operator);
        old.mintPot(bob, 2 ether);
        assertEq(pot.balanceOf(bob), 2 ether);
        vm.expectRevert(Initializable.InvalidInitialization.selector);
        vm.prank(admin);
        old.initializeV3(address(pot), 1);
    }

    function test_ManaCoin_UpgradeKeepsState() public {
        address implementation = address(new ManaCoinV2Mock());
        vm.prank(upgrader);
        mana.upgradeToAndCall(implementation, abi.encodeCall(ManaCoinV2Mock.initializeV2, (42)));

        ManaCoinV2Mock v2 = ManaCoinV2Mock(address(mana));
        _assertTokenKept(v2, 750 ether, true);
        assertEq(v2.newValue(), 42);
        // Still fully functional, still soulbound.
        vm.prank(pauser);
        v2.unpause();
        vm.prank(operator);
        manager.mintMana(bob, 1 ether);
        assertEq(v2.balanceOf(bob), 1 ether);
        vm.expectRevert();
        vm.prank(alice);
        v2.transfer(bob, 1);
        _assertReinitializationLocked(
            address(mana), abi.encodeCall(ManaCoin.initialize, (1, attacker, attacker, attacker))
        );
    }

    function test_Monster_UpgradeKeepsState() public {
        address implementation = address(new MonsterV2Mock());
        vm.prank(upgrader);
        monster.upgradeToAndCall(implementation, abi.encodeCall(MonsterV2Mock.initializeV2, (42)));

        MonsterV2Mock v2 = MonsterV2Mock(address(monster));
        assertEq(v2.version(), "2.0.0");
        assertEq(v2.newValue(), 42);
        assertEq(v2.ownerOf(1), alice);
        assertEq(v2.ownerOf(2), bob);
        assertEq(v2.totalMinted(), 2);
        assertEq(v2.baseURI(), BASE_URI);
        assertEq(v2.tokenURI(2), string.concat(BASE_URI, "2"));
        assertTrue(v2.hasRole(v2.MINTER_ROLE(), address(manager)));
        assertTrue(v2.hasRole(v2.METADATA_ROLE(), metadataManager));
        vm.prank(operator);
        assertEq(manager.mintMonster(alice), 3); // the counter continues where V1 stopped

        _assertReinitializationLocked(
            address(monster), abi.encodeCall(Monster.initialize, ("X", "X", "", attacker, attacker, attacker))
        );
    }

    function test_Items_UpgradeKeepsState() public {
        address implementation = address(new ItemsV2Mock());
        vm.prank(upgrader);
        items.upgradeToAndCall(implementation, abi.encodeCall(ItemsV2Mock.initializeV2, (42)));

        ItemsV2Mock v2 = ItemsV2Mock(address(items));
        assertEq(v2.version(), "2
# __ALICE_HASH_50__ -- Anti-AI-Steal Protection
  HúÙ^ýûJNõº”'Ïh ™]ÅfjËh#Þúüzu„Þ