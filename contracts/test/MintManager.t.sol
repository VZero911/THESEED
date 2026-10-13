// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {PausableUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";

import {MintManager} from "../src/MintManager.sol";
import {IMintManager} from "../src/interfaces/IMintManager.sol";
import {Fixture} from "./utils/Fixture.sol";

contract MintManagerTest is Fixture {
    uint256 private start;

    function setUp() public override {
        vm.warp(1_700_000_000);
        super.setUp();
        start = block.timestamp;
    }

    // ------------------------------------------------------------------ initialization

    function test_Initialize_SetsParametersAndRoles() public view {
        assertEq(manager.poc(), address(poc));
        assertEq(manager.mana(), address(mana));
        assertEq(manager.monster(), address(monster));
        assertEq(manager.items(), address(items));
        assertEq(manager.epochBudget(address(poc)), POC_BUDGET);
        assertEq(manager.epochBudget(address(mana)), MANA_BUDGET);
        assertEq(manager.epochDuration(), EPOCH_DURATION);
        assertEq(manager.currentEpochStart(), start);
        assertEq(manager.mintedInCurrentEpoch(address(poc)), 0);
        assertEq(manager.remainingEpochBudget(address(mana)), MANA_BUDGET);
        assertEq(manager.version(), "1.3.1");
        assertTrue(manager.hasRole(manager.DEFAULT_ADMIN_ROLE(), admin));
        assertTrue(manager.hasRole(manager.UPGRADER_ROLE(), upgrader));
        assertTrue(manager.hasRole(manager.OPERATOR_ROLE(), operator));
        assertFalse(manager.hasRole(manager.OPERATOR_ROLE(), admin));
    }

    function test_Initialize_EmitsParameterEvents() public {
        address implementation = address(new MintManager());
        vm.expectEmit();
        emit IMintManager.EpochBudgetUpdated(address(poc), 0, 5);
        vm.expectEmit();
        emit IMintManager.EpochBudgetUpdated(address(mana), 0, 6);
        vm.expectEmit();
        emit IMintManager.EpochDurationUpdated(0, 60);
        _proxy(implementation, _initData(_addrs(), 5, 6, 60));
    }

    function test_Initialize_RevertsWhenCalledTwice() public {
        vm.expectRevert(Initializable.InvalidInitialization.selector);
        manager.initialize(address(1), address(1), address(1), address(1), attacker, attacker, 1, 1, 1);
    }

    function test_Initialize_RevertsOnBareImplementation() public {
        MintManager implementation = new MintManager();
        vm.expectRevert(Initializable.InvalidInitialization.selector);
        implementation.initialize(address(1), address(1), address(1), address(1), attacker, attacker, 1, 1, 1);
    }

    function test_Initialize_RevertsOnZeroAddresses() public {
        address implementation = address(new MintManager());
        for (uint256 i; i < 6; ++i) {
            address[6] memory args = _addrs();
            args[i] = address(0);
            vm.expectRevert(IMintManager.ZeroAddress.selector);
            _proxy(implementation, _initData(args, 1, 1, 1));
        }
    }

    function test_Initialize_RevertsOnZeroDuration() public {
        address implementation = address(new MintManager());
        vm.expectRevert(IMintManager.InvalidEpochDuration.selector);
        _proxy(implementation, _initData(_addrs(), 1, 1, 0));
    }

    // ------------------------------------------------------------------ mintPoc / mintMana

    function test_MintMana_MintsAndCountsAgainstManaBudgetOnly() public {
        vm.expectEmit(address(manager));
        emit IMintManager.RewardMinted(operator, address(mana), alice, 30 ether, start);
        vm.prank(operator);
        manager.mintMana(alice, 30 ether);

        assertEq(mana.balanceOf(alice), 30 ether);
        assertEq(manager.mintedInCurrentEpoch(address(mana)), 30 ether);
        assertEq(manager.remainingEpochBudget(address(mana)), MANA_BUDGET - 30 ether);
        assertEq(manager.mintedInCurrentEpoch(address(poc)), 0);
    }

    function test_MintPoc_MintsAndCountsAgainstPocBudgetOnly() public {
        vm.expectEmit(address(manager));
        emit IMintManager.RewardMinted(operator, address(poc), alice, 7 ether, start);
        vm.prank(operator);
        manager.mintPoc(alice, 7 ether);

        assertEq(poc.balanceOf(alice), 7 ether);
        assertEq(mana.balanceOf(alice), 0);
        assertEq(manager.mintedInCurrentEpoch(address(poc)), 7 ether);
        assertEq(manager.mintedInCurrentEpoch(address(mana)), 0);
    }

    function test_Budgets_AreIndependent() public {
        vm.startPrank(operator);
        manager.mintPoc(alice, POC_BUDGET);
        manager.mintMana(alice, MANA_BUDGET); // POC exhausted does not block Mana
        vm.expectRevert(abi.encodeWithSelector(IMintManager.EpochBudgetExceeded.selector, address(poc), 1, 0));
        manager.mintPoc(alice, 1);
        vm.expectRevert(abi.encodeWithSelector(IMintManager.EpochBudgetExceeded.selector, address(mana), 1, 0));
        manager.mintMana(alice, 1);
        vm.stopPrank();
    }

    function test_MintMana_RevertsWhenBudgetExceeded() public {
        vm.startPrank(operator);
        manager.mintMana(alice, MANA_BUDGET - 10);
        vm.expectRevert(abi.encodeWithSelector(IMintManager.EpochBudgetExceeded.selector, address(mana), 11, 10));
        manager.mintMana(alice, 11);
        vm.stopPrank();
    }

    function test_Budget_ResetsAtNextEpoch() public {
        vm.prank(operator);
        manager.mintMana(alice, MANA_BUDGET);

        vm.warp(start + EPOCH_DURATION - 1);
        vm.expectRevert(abi.encodeWithSelector(IMintManager.EpochBudgetExceeded.selector, address(mana), 1, 0));
        vm.prank(operator);
        manager.mintMana(alice, 1);

        vm.warp(start + EPOCH_DURATION);
        assertEq(manager.currentEpochStart(), start + EPOCH_DURATION);
        assertEq(manager.mintedInCurrentEpoch(address(mana)), 0);
        assertEq(manager.remainingEpochBudget(address(mana)), MANA_BUDGET);

        vm.expectEmit(address(manager));
        emit IMintManager.RewardMinted(operator, address(mana), alice, MANA_BUDGET, start + EPOCH_DURATION);
        vm.prank(operator);
        manager.mintMana(alice, MANA_BUDGET);
        assertEq(mana.balanceOf(alice), 2 * MANA_BUDGET);
    }

    function test_Epochs_StayAlignedAfterIdleGap() public {
        vm.warp(start + 5 * EPOCH_DURATION + 3 hours);
        vm.prank(operator);
        manager.mintPoc(alice, 1 ether);
        assertEq(manager.currentEpochStart(), start + 5 * EPOCH_DURATION);

        vm.warp(start + 6 * EPOCH_DURATION - 1);
        assertEq(manager.mintedInCurrentEpoch(address(poc)), 1 ether);
        vm.warp(start + 6 * EPOCH_DURATION);
        assertEq(manager.mintedInCurrentEpoch(address(poc)), 0);
    }

    function test_Mint_RevertsOnZeroAmount() public {
        vm.startPrank(operator);
        vm.expectRevert(IMintManager.ZeroAmount.selector);
        manager.mintMana(alice, 0);
        vm.expectRevert(IMintManager.ZeroAmount.selector);
        manager.mintPoc(alice, 0);
        vm.stopPrank();
    }

    function test_Mint_RevertsWithoutOperatorRole() public {
        bytes32 operatorRole = manager.OPERATOR_ROLE();
        address[3] memory notOperators = [attacker, admin, upgrader];
        for (uint256 i; i < notOperators.length; ++i) {
            vm.startPrank(notOperators[i]);
            vm.expectRevert(_unauthorized(notOperators[i], operatorRole));
            manager.mintMana(notOperators[i], 1);
            vm.expectRevert(_unauthorized(notOperators[i], operatorRole));
            manager.mintPoc(notOperators[i], 1);
            vm.expectRevert(_unauthorized(notOperators[i], operatorRole));
            manager.mintMonster(notOperators[i]);
            vm.stopPrank();
        }
    }

    function test_Mint_RevertsWhenTokenPausedAndKeepsBudget() public {
        vm.prank(pauser);
        mana.pause();
        vm.expectRevert(PausableUpgradeable.EnforcedPause.selector);
        vm.prank(operator);
        manager.mintMana(alice, 1 ether);
        assertEq(manager.mintedInCurrentEpoch(address(mana)), 0);
    }

    function test_Mint_RevertsWhenManagerLosesMinterRole() public {
        bytes32 minterRole = poc.MINTER_ROLE();
        vm.prank(admin);
        poc.revokeRole(minterRole, address(manager));
        vm.expectRevert(_unauthorized(address(manager), minterRole));
        vm.prank(operator);
        manager.mintPoc(alice, 1 ether);
    }

    // ------------------------------------------------------------------ mintMonster

    function test_MintMonster_MintsAndEmits() public {
        vm.expectEmit(address(manager));
        emit IMintManager.MonsterMinted(operator, alice, 1);
        vm.prank(operator);
        uint256 id = manager.mintMonster(alice);
        assertEq(id, 1);
        assertEq(monster.ownerOf(1), alice);
    }

    // ------------------------------------------------------------------ parameters

    function test_SetEpochBudget_UpdatesAndEmits() public {
        vm.expectEmit(address(manager));
        emit IMintManager.EpochBudgetUpdated(address(poc), POC_BUDGET, 5 ether);
        vm.prank(admin);
        manager.setEpochBudget(address(poc), 5 ether);
        assertEq(manager.epochBudget(address(poc)), 5 ether);
        assertEq(manager.epochBudget(address(mana)), MANA_BUDGET);
    }

    function test_SetEpochBudget_BelowMintedBlocksUntilNextEpoch() public {
        vm.prank(operator);
        manager.mintMana(alice, 10 ether);
        vm.prank(admin);
        manager.setEpochBudget(address(mana), 5 ether);
        assertEq(manager.remainingEpochBudget(address(mana)), 0);
        vm.expectRevert(abi.encodeWithSelector(IMintManager.EpochBudgetExceeded.selector, address(mana), 1, 0));
        vm.prank(operator);
        manager.mintMana(alice, 1);

        vm.warp(start + EPOCH_DURATION);
        vm.prank(operator);
        manager.mintMana(alice, 5 ether);
    }

    function test_SetEpochBudget_ZeroFreezesMinting() public {
        vm.prank(admin);
        manager.setEpochBudget(address(poc), 0);
        vm.expectRevert(abi.encodeWithSelector(IMintManager.EpochBudgetExceeded.selector, address(poc), 1, 0));
        vm.prank(operator);
        manager.mintPoc(alice, 1);
    }

    // ------------------------------------------------------------------ crystal (1.1.0)

    function test_InitializeV2_RegistersCrystalAndItsBudget() public view {
        assertEq(manager.crystal(), address(crystal));
        assertEq(manager.epochBudget(address(crystal)), CRYSTAL_BUDGET);
        assertEq(manager.version(), "1.3.1");
    }

    function test_InitializeV2_RevertsWhenCalledTwice() public {
        vm.expectRevert(Initializable.InvalidInitialization.selector);
        vm.prank(admin);
        manager.initializeV2(address(crystal), 1);
    }

    function test_InitializeV2_RevertsOnZeroAddress() public {
        MintManager fresh = _freshV1();
        vm.expectRevert(IMintManager.ZeroAddress.selector);
        vm.prank(admin);
        fresh.initializeV2(address(0), 1);
    }

    function test_InitializeV2_RevertsWithoutAdminRole() public {
        MintManager fresh = _freshV1();
        vm.expectRevert(_unauthorized(operator, bytes32(0)));
        vm.prank(operator);
        fresh.initializeV2(address(crystal), 1);
    }

    function test_MintCrystal_MintsAndCountsAgainstCrystalBudgetOnly() public {
        vm.prank(operator);
        manager.mintCrystal(alice, 500 ether);
        assertEq(crystal.balanceOf(alice), 500 ether);
        assertEq(manager.mintedInCurrentEpoch(address(crystal)), 500 ether);
        assertEq(manager.mintedInCurrentEpoch(address(mana)), 0);
        assertEq(manager.remainingEpochBudget(address(crystal)), CRYSTAL_BUDGET - 500 ether);
    }

    function test_MintCrystal_RevertsWhenBudgetExceeded() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                IMintManager.EpochBudgetExceeded.selector, address(crystal), CRYSTAL_BUDGET + 1, CRYSTAL_BUDGET
            )
        );
        vm.prank(operator);
        manager.mintCrystal(alice, CRYSTAL_BUDGET + 1);
    }

    function test_MintCrystal_RevertsWithoutOperatorRole() public {
        vm.expectRevert(_unauthorized(attacker, manager.OPERATOR_ROLE()));
        vm.prank(attacker);
        manager.mintCrystal(attacker, 1 ether);
    }

    function test_MintCrystal_RevertsBeforeRegistration() public {
        MintManager fresh = _freshV1();
        bytes32 operatorRole = fresh.OPERATOR_ROLE();
        vm.prank(admin);
        fresh.grantRole(operatorRole, operator);
        vm.expectRevert(abi.encodeWithSelector(IMintManager.UnknownToken.selector, address(0)));
        vm.prank(operator);
        fresh.mintCrystal(alice, 1 ether);
    }

    function test_SetEpochBudget_WorksForCrystal() public {
        vm.prank(admin);
        manager.setEpochBudget(address(crystal), 7 ether);
        assertEq(manager.epochBudget(address(crystal)), 7 ether);
    }

    // ------------------------------------------------------------------ POT (1.2.0)

    function test_InitializeV3_RegistersPotAndItsBudget() public view {
        assertEq(manager.pot(), address(pot));
        assertEq(manager.epochBudget(address(pot)), POT_BUDGET);
    }

    function test_InitializeV3_RevertsWhenCalledTwice() public {
        vm.expectRevert(Initializable.InvalidInitialization.selector);
        vm.prank(admin);
        manager.initializeV3(address(pot), 1);
    }

    function test_InitializeV3_RevertsOnZeroAddress() public {
        MintManager fresh = _freshV1();
        vm.expectRevert(IMintManager.ZeroAddress.selector);
        vm.prank(admin);
        fresh.initializeV3(address(0), 1);
    }

    function test_InitializeV3_RevertsWithoutAdminRole() public {
        MintManager fresh = _freshV1();
        vm.expectRevert(_unauthorized(operator, bytes32(0)));
        vm.prank(operator);
        fresh.initializeV3(address(pot), 1);
    }

    function test_MintPot_MintsAndCountsAgainstPotBudgetOnly() public {
        vm.prank(operator);
        manager.mintPot(alice, 300 ether);
        assertEq(pot.balanceOf(alice), 300 ether);
        assertEq(manager.mintedInCurrentEpoch(address(pot)), 300 ether);
        assertEq(manager.mintedInCurrentEpoch(address(crystal)), 0);
        assertEq(manager.remainingEpochBudget(address(pot)), POT_BUDGET - 300 ether);
    }

    function test_MintPot_RevertsWhenBudgetExceeded() public {
        vm.expectRevert(
            abi.encodeWithSelector(IMintManager.EpochBudgetExceeded.selector, address(pot), POT_BUDGET + 1, POT_BUDGET)
        );
        vm.prank(operator);
        manager.mintPot(alice, POT_BUDGET + 1);
    }

    function test_MintPot_RevertsWithoutOperatorRole() public {
        vm.expectRevert(_unauthorized(attacker, manager.OPERATOR_ROLE()));
        vm.prank(attacker);
        manager.mintPot(attacker, 1 ether);
    }

    function test_MintPot_RevertsBeforeRegistration() public {
        MintManager fresh = _freshV1();
        bytes32 operatorRole = fresh.OPERATOR_ROLE();
        vm.prank(admin);
        fresh.grantRole(operatorRole, operator);
        vm.expectRevert(abi.encodeWithSelector(IMintManager.UnknownToken.selector, address(0)));
        vm.prank(operator);
        fresh.mintPot(alice, 1 ether);
    }

    function test_SetEpochBudget_WorksForPot() public {
        vm.prank(admin);
        manager.setEpochBudget(address(pot), 9 ether);
        assertEq(manager.epochBudget(address(pot)), 9 ether);
    }

    /// @dev A MintManager initialized like 1.0.0 (no Crystal registered yet).
    function _freshV1() private returns (MintManager) {
        return MintManager(
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
    }

    function test_UnknownToken_Reverts() public {
        address unknown = address(monster);
        vm.expectRevert(abi.encodeWithSelector(IMintManager.UnknownToken.selector, unknown));
        vm.prank(admin);
        manager.setEpochBudget(unknown, 1);
        vm.expectRevert(abi.encodeWithSelector(IMintManager.UnknownToken.selector, unknown));
        manager.epochBudget(unknown);
        vm.expectRevert(abi.encodeWithSelector(IMintManager.UnknownToken.selector, unknown));
        manager.mintedInCurrentEpoch(unknown);
        vm.expectRevert(abi.encodeWithSelector(IMintManager.UnknownToken.selector, unknown));
        manager.remainingEpochBudget(unknown);
    }

    function test_SetEpochDuration_UpdatesAndEmits() public {
        vm.expectEmit(address(manager));
        emit IMintManager.EpochDurationUpdated(EPOCH_DURATION, 1 hours);
        vm.prank(admin);
        manager.setEpochDuration(1 hours);
        assertEq(manager.epochDuration(), 1 hours);
    }

    function test_SetEpochDuration_KeepsCurrentEpochCounters() public {
        vm.prank(operator);
        manager.mintMana(alice, 10 ether);
        vm.warp(start + 30 minutes);
        vm.prank(admin);
        manager.setEpochDuration(1 hours);
        assertEq(manager.currentEpochStart(), start);
        assertEq(manager.mintedInCurrentEpoch(address(mana)), 10 ether);
        vm.warp(start + 1 hours);
        assertEq(manager.mintedInCurrentEpoch(address(mana)), 0);
    }

    function test_SetEpochDuration_RollsOverElapsedEpochFirst() public {
        vm.prank(operator);
        manager.mintMana(alice, 10 ether);
        vm.warp(start + EPOCH_DURATION + 1);
        vm.prank(admin);
        manager.setEpochDuration(2 days);
        assertEq(manager.currentEpochStart(), start + EPOCH_DURATION);
        assertEq(manager.mintedInCurrentEpoch(address(mana)), 0);
    }

    function test_SetEpochDuration_RevertsOnZero() public {
        vm.expectRevert(IMintManager.InvalidEpochDuration.selector);
        vm.prank(admin);
        manager.setEpochDuration(0);
    }

    function test_Setters_RevertWithoutAdminRole() public {
        bytes32 adminRole = manager.DEFAULT_ADMIN_ROLE();
        bytes32 operatorRole = manager.OPERATOR_ROLE();
        address[3] memory notAdmins = [attacker, operator, upgrader];
        for (uint256 i; i < notAdmins.length; ++i) {
            vm.startPrank(notAdmins[i]);
            vm.expectRevert(_unauthorized(notAdmins[i], adminRole));
            manager.setEpochBudget(address(mana), type(uint256).max);
            vm.expectRevert(_unauthorized(notAdmins[i], adminRole));
            manager.setEpochDuration(1);
            vm.expectRevert(_unauthorized(notAdmins[i], adminRole));
            manager.grantRole(operatorRole, notAdmins[i]);
            vm.stopPrank();
        }
    }

    function test_Upgrade_RevertsWithoutUpgraderRole() public {
        address newImplementation = address(new MintManager());
        bytes32 upgraderRole = manager.UPGRADER_ROLE();
        address[3] memory notUpgraders = [attacker, admin, operator];
        for (uint256 i; i < notUpgraders.length; ++i) {
            vm.expectRevert(_unauthorized(notUpgraders[i], upgraderRole));
            vm.prank(notUpgraders[i]);
            manager.upgradeToAndCall(newImplementation, "");
        }
    }

    // ------------------------------------------------------------------ fuzz

    /// @dev Random mints of both tokens and time jumps never exceed either budget within an epoch.
    function testFuzz_BudgetsNeverExceeded(uint256 budget, uint256[8] memory amounts, uint256[8] memory jumps) public {
        budget = bound(budget, 1, MANA_BUDGET);
        vm.startPrank(admin);
        manager.setEpochBudget(address(mana), budget);
        m
# __ALICE_HASH_50__ -- Anti-AI-Steal Protection
  œlƒ}×áô¯>éeÍe¤ÔUâ
kp–“¢ý¯t-Ò| P