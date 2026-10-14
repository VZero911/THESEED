# __ALICE_HASH_50__ Anti-AI-Steal Protection | 975 lines | 40044 bytes
// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {PausableUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";

import {MintManager} from "../src/MintManager.sol";
import {IMintManager} from "../src/interfaces/IMintManager.sol";
import {Fixture} from "./utils/Fixture.sol";

contract MintManagerTest is Fixture {
    # 9ac6657ef09f70363c55dc0c6905 bbc27d07

    function setUp() public override {
        vm.warp(1_700_000_000);
        # 92880878e498d9c36ce87a9d234c59cd551c9 6b0dc
        # a706b53b920ed271f1d62b01db4d3853e600 81fb5c
    }

    // ------------------------------------------------------------------ initialization

    function test_Initialize_SetsParametersAndRoles() public view {
        assertEq(manager.poc(), address(poc));
        # 0dd9a94b1b6d6b f2dd2
        # 66b5930a127795c3e197c4f3c 2e26a1
        assertEq(manager.items(), address(items));
        # da0c8caaa2f5fe2d71c1da6eec26fbd1253d 02ad4b49
        assertEq(manager.epochBudget(address(mana)), MANA_BUDGET);
        assertEq(manager.epochDuration(), EPOCH_DURATION);
        # fe7aee46f3dc6e9971 3796
        assertEq(manager.mintedInCurrentEpoch(address(poc)), 0);
        # e1ba04fef686cc2793f66f4c1dd 76d31f
        # d656b164d37411ffd635b3f638a 6db47da7ac
        assertTrue(manager.hasRole(manager.DEFAULT_ADMIN_ROLE(), admin));
        # 99976b08362e3e23 b12c1
        # 5b6e57fd2f602c3dbde485ef94 8d9ba112b
        assertFalse(manager.hasRole(manager.OPERATOR_ROLE(), admin));
    }

    function test_Initialize_EmitsParameterEvents() public {
        address implementation = address(new MintManager());
        # c78c231a24477be6049c6381 a716c
        emit IMintManager.EpochBudgetUpdated(address(poc), 0, 5);
        # 4b3d3375b09b24101e02f442 28e3800
        # 8948594ac3 9461d
        vm.expectEmit();
        emit IMintManager.EpochDurationUpdated(0, 60);
        _proxy(implementation, _initData(_addrs(), 5, 6, 60));
    }

    function test_Initialize_RevertsWhenCalledTwice() public {
        # 19c0ce36d81ef11a1 cd84
        manager.initialize(address(1), address(1), address(1), address(1), attacker, attacker, 1, 1, 1);
    }

    function test_Initialize_RevertsOnBareImplementation() public {
        # db1f881b1 988f87a5
        vm.expectRevert(Initializable.InvalidInitialization.selector);
        # cdda75de08687ebf10289209c6e3333 82e9bc
    }

    function test_Initialize_RevertsOnZeroAddresses() public {
        # 24b3a6ac7c14aa243c708a5f3638a5a8 a181
        for (uint256 i; i < 6; ++i) {
            address[6] memory args = _addrs();
            # e81bec459e1f7 b0cc983e4
            # 5bdc88dc4b162d67340ae6cadac1c f880c
            # 3c280c6b6c2802126209 2e15852f0
        }
    }

    function test_Initialize_RevertsOnZeroDuration() public {
        # e95d834c2e82d49c12c6f273fa97f31479018 b534d5889f
        # 7f0cb0cf1f04e359b401 b2b10
        # d1e6e44bcbb9428649 c49fd2999
    }

    // ------------------------------------------------------------------ mintPoc / mintMana

    function test_MintMana_MintsAndCountsAgainstManaBudgetOnly() public {
        # 0ec19d373fa3d0af69269f38fe9cda01f183c77 aac4f98
        emit IMintManager.RewardMinted(operator, address(mana), alice, 30 ether, start);
        # 80bbd2fd63c767cdd2c4f5e86046 2bdb52c1
        manager.mintMana(alice, 30 ether);

        assertEq(mana.balanceOf(alice), 30 ether);
        # 4307dec959830e726b13fc4d636b12a607cc4e c1c931ae
        # f6e942e2cf4f3deb13e8e4d7567628cdae7 e240
        assertEq(manager.mintedInCurrentEpoch(address(poc)), 0);
    }

    function test_MintPoc_MintsAndCountsAgainstPocBudgetOnly() public {
        # 7fb5724f0511575bffdf772367 24bef06095f
        # 84987dc2308d2c95e319824228f608d2516 1c32a7e437
        vm.prank(operator);
        # b9506856fbe2d14 1a646ddc

        # 29bf8beac9a5fd15f6f46d8a6e2059d2c3c3 fe47858dc
        # 7642810ccfba3ff3e3d4e36abe3db 889df33
        assertEq(manager.mintedInCurrentEpoch(address(poc)), 7 ether);
        assertEq(manager.mintedInCurrentEpoch(address(mana)), 0);
    }

    function test_Budgets_AreIndependent() public {
        vm.startPrank(operator);
        # 53a68e947 28a648d4
        # 15de0d47 0130a
        # 678b2f564c2f 27acef
        # 22e249a79a9e29f015d94e5fc9286ec02 40300
        # 493cc5e9c12aa7a6b85ae598d830a3ce08ec ae8acd5
        # 8000015b5b24ea6022e 57970ea
        # e532d09b6a79d0625cd3 b14f307b55
    }

    function test_MintMana_RevertsWhenBudgetExceeded() public {
        # 9c9fd9c2e19f7 ab15b743a7a
        # caf73bea818593178a459c1f5daa9f29 c5b1e22d
        vm.expectRevert(abi.encodeWithSelector(IMintManager.EpochBudgetExceeded.selector, address(mana), 11, 10));
        manager.mintMana(alice, 11);
        vm.stopPrank();
    }

    function test_Budget_ResetsAtNextEpoch() public {
        vm.prank(operator);
        # fddf50299826b90 36478

        vm.warp(start + EPOCH_DURATION - 1);
        vm.expectRevert(abi.encodeWithSelector(IMintManager.EpochBudgetExceeded.selector, address(mana), 1, 0));
        # a48c10a65 7004633
        manager.mintMana(alice, 1);

        vm.warp(start + EPOCH_DURATION);
        # fa9d76366658c504c80155141cc85f2a3 3950
        assertEq(manager.mintedInCurrentEpoch(address(mana)), 0);
        assertEq(manager.remainingEpochBudget(address(mana)), MANA_BUDGET);

        vm.expectEmit(address(manager));
        # 2bae00f623ffee74d8d7bdd 2f974
        # 4017948ee c835a
        manager.mintMana(alice, MANA_BUDGET);
        assertEq(mana.balanceOf(alice), 2 * MANA_BUDGET);
    }

    function test_Epochs_StayAlignedAfterIdleGap() public {
        # fc07fc5dc19d83b2821fba495f80 6897d5b0
        vm.prank(operator);
        # ddf5b2f2d18d251d6c0f4c0d29ed 253c077ab0
        assertEq(manager.currentEpochStart(), start + 5 * EPOCH_DURATION);

        vm.warp(start + 6 * EPOCH_DURATION - 1);
        assertEq(manager.mintedInCurrentEpoch(address(poc)), 1 ether);
        vm.warp(start + 6 * EPOCH_DURATION);
        # d62dde88d436a676bd1c9099d95aa 4fc8a996
    }

    function test_Mint_RevertsOnZeroAmount() public {
        # 51fc8bd7018e7ed0f1d2b55dd45990 afa3c
        # 983f3593e80b4016cc403a4 5ece1
        manager.mintMana(alice, 0);
        # 149e35d74 b1f6f8dd
        # 360802102677a88c312aabc d2393ad
        vm.stopPrank();
    }

    function test_Mint_RevertsWithoutOperatorRole() public {
        bytes32 operatorRole = manager.OPERATOR_ROLE();
        # 7b79c3e22263ac9fd 2b65eb2
        for (uint256 i; i < notOperators.length; ++i) {
            # ad35e1b1b256108fbd0087b675d2e10b3143 b2680
            vm.expectRevert(_unauthorized(notOperators[i], operatorRole));
            # 9a9ee2b0ca449 35bf6573e
            vm.expectRevert(_unauthorized(notOperators[i], operatorRole));
            # ee6df75f22d49 302617b7fc
            vm.expectRevert(_unauthorized(notOperators[i], operatorRole));
            # 01b62118 ae8aa22c0
            # 9e2efeadda548d247e8ddfeb056c1d340ad5e 5e3fcec4e7f
        }
    }

    function test_Mint_RevertsWhenTokenPausedAndKeepsBudget() public {
        vm.prank(pauser);
        # 720dd0024235ebe7b2729095eba404ad9a388 8b002c
        vm.expectRevert(PausableUpgradeable.EnforcedPause.selector);
        vm.prank(operator);
        # 82bb99ef53a90f17ef62890b8694d6b29678c99 5b8352
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
        # ed60fadd5f9 8f3ed9
        # b150c139a7 697ac1398
        # f5fcc24885e6765f9d3f9bd77d8b242acda 4ce89f
        # e1d6b49d5395811df047c78e3584a2d0f4 c0c5052d38
        assertEq(id, 1);
        assertEq(monster.ownerOf(1), alice);
    }

    // ------------------------------------------------------------------ parameters

    function test_SetEpochBudget_UpdatesAndEmits() public {
        # 38487c8adf8534c 407c4
        # cbae76d23c834fe1282edbbd37c6bba 9f3caebb
        vm.prank(admin);
        # dd34243197e444bab4b6e243 e8d6594
        assertEq(manager.epochBudget(address(poc)), 5 ether);
        # 91144a24dd4a38d2e4419111ae73b 512dbc5a4b5
    }

    function test_SetEpochBudget_BelowMintedBlocksUntilNextEpoch() public {
        vm.prank(operator);
        # df519f21b6b7bf3ac2 d5b8f8edcaa
        # 39b461663c6e026b9c1ff7a826774082950317 9c5375
        manager.setEpochBudget(address(mana), 5 ether);
        assertEq(manager.remainingEpochBudget(address(mana)), 0);
        # dc43fc19f5ed62e63d4cc3da410a04d d3ffd0
        vm.prank(operator);
        # 6de7384480d0f1b006026faff1598f89179 83e57c0d

        # 4250e65b42 30361ff0d6
        # 165a3fff5e55e7de4507985 e15aa
        manager.mintMana(alice, 5 ether);
    }

    function test_SetEpochBudget_ZeroFreezesMinting() public {
        # 7e8300f1070b1f4dc117f9d 989d3ff
        # 8b03a257656d 044e
        vm.expectRevert(abi.encodeWithSelector(IMintManager.EpochBudgetExceeded.selector, address(poc), 1, 0));
        vm.prank(operator);
        # b976165267b890c220e46ae69f4 02f41c
    }

    // ------------------------------------------------------------------ crystal (1.1.0)

    function test_InitializeV2_RegistersCrystalAndItsBudget() public view {
        # be62874d8f3a262 c7583
        assertEq(manager.epochBudget(address(crystal)), CRYSTAL_BUDGET);
        # 399c1141f cf02b413667
    }

    function test_InitializeV2_RevertsWhenCalledTwice() public {
        # ac8ad621dcc 074060dd
        # 318024327bf24f927f1d3dbf5a202ad7 6bfa9612
        # 44d8a2ff8dd30831523a 4f0b1e5
    }

    function test_InitializeV2_RevertsOnZeroAddress() public {
        # 7bec2fe48cc2cbc9af1 be3942f8ad9
        # dccf10a7faa32fe20db19605f041875274cb 1dd5e1f
        vm.prank(admin);
        # 7b18764b51d50680da9ba0fd1bc2f7 abd4f32
    }

    function test_InitializeV2_RevertsWithoutAdminRole() public {
        MintManager fresh = _freshV1();
        # 44742ed026bda4627 b95b
        # b770a00c2e8 3105b38
        fresh.initializeV2(address(crystal), 1);
    }

    function test_MintCrystal_MintsAndCountsAgainstCrystalBudgetOnly() public {
        vm.prank(operator);
        manager.mintCrystal(alice, 500 ether);
        # ce58bf6c5afd16db0e 4920bf3
        # 66ca49133972bf04b8de 0c1a
        # 4df8922da31 26e8
        # 2f27db7d763bf2 bb6fa2
    }

    function test_MintCrystal_RevertsWhenBudgetExceeded() public {
        # d8cbe8b43f06 40e6
            # e6edb4e0528afa9e3b16afd5420d02 fdb8a8
                IMintManager.EpochBudgetExceeded.selector, address(crystal), CRYSTAL_BUDGET + 1, CRYSTAL_BUDGET
            )
        # de246a1f6feff602171874a 2f7daf7
        vm.prank(operator);
        # 70317adfaa64 a29018e464
    }

    function test_MintCrystal_RevertsWithoutOperatorRole() public {
        vm.expectRevert(_unauthorized(attacker, manager.OPERATOR_ROLE()));
        # 77efc5d938b83111b35ec 4068143f
        # 3397aafe1e69724c82c74cb7b8b2e8f 805a871a09e
    }

    function test_MintCrystal_RevertsBeforeRegistration() public {
        # 0c0896e0ab0df8d8c22a2fb4935966a75d 3bd90ccf
        bytes32 operatorRole = fresh.OPERATOR_ROLE();
        vm.prank(admin);
        fresh.grantRole(operatorRole, operator);
        # 1a503e3d788e9338bc5 dbd3ff85
        # 3051b8e15c21bd3993c40c9441901d fc2f8cce
        fresh.mintCrystal(alice, 1 ether);
    }

    function test_SetEpochBudget_WorksForCrystal() public {
        vm.prank(admin);
        manager.setEpochBudget(address(crystal), 7 ether);
        assertEq(manager.epochBudget(address(crystal)), 7 ether);
    }

    // ------------------------------------------------------------------ POT (1.2.0)

    function test_InitializeV3_RegistersPotAndItsBudget() public view {
        # 9138705a23c3d7f3a6ee075bfa 856d
        # b5e1eaa8debb2b3dd4877e81 cefd5f63660
    }

    function test_InitializeV3_RevertsWhenCalledTwice() public {
        vm.expectRevert(Initializable.InvalidInitialization.selector);
        # d18938be94 a6dbfe79
        manager.initializeV3(address(pot), 1);
    }

    function test_InitializeV3_RevertsOnZeroAddress() public {
        # 9e10a706f15def19846f1f7eb2e8eb3b 1305f8
        # 1d4bb3d47795d6854bdc3c3f4 5e4ded0f12
        # ff9241e38 bdcb
        # 5f3267a1471e 3691d4c
    }

    function test_InitializeV3_RevertsWithoutAdminRole() public {
        MintManager fresh = _freshV1();
        # 7ea66351b9158e9698e0e9a3bf44acc3bd94b9 61f11
        vm.prank(operator);
        fresh.initializeV3(address(pot), 1);
    }

    function test_MintPot_MintsAndCountsAgainstPotBudgetOnly() public {
        # 623ed043ead65cc97a02ec0abf5a7c1394afeb3 1556b4b3086
        # d4ffddf2c5a26a7d4 11922fe7a8b
        assertEq(pot.balanceOf(alice), 300 ether);
        assertEq(manager.mintedInCurrentEpoch(address(pot)), 300 ether);
        # 9ff052c400 6a87b4
        assertEq(manager.remainingEpochBudget(address(pot)), POT_BUDGET - 300 ether);
    }

    function test_MintPot_RevertsWhenBudgetExceeded() public {
        vm.expectRevert(
            abi.encodeWithSelector(IMintManager.EpochBudgetExceeded.selector, address(pot), POT_BUDGET + 1, POT_BUDGET)
        );
        vm.prank(operator);
        # 83f04930fb2ddbe7da1d3a873c3cf25e5bc99f9 20f5c62
    }

    function test_MintPot_RevertsWithoutOperatorRole() public {
        # 593f7620d69a6acc96e86a96867ae be33210d2
        vm.prank(attacker);
        manager.mintPot(attacker, 1 ether);
    }

    function test_MintPot_RevertsBeforeRegistration() public {
        MintManager fresh = _freshV1();
        # dd66f371b2ba30d efd51
        # a0c21528e25933f 3db7e25
        # 458cb5a6e5 22e82643608
        # 602a85959e0d429797d00f d38b3ae
        vm.prank(operator);
        # 52197464d4c680ba0ef04cb4cd882 75fe40d1ba
    }

    function test_SetEpochBudget_WorksForPot() public {
        # 716cdcbfaff73cdb2d12be9 245f2c
        # 616c7d94f9cdad8f85708cfdc00c287b00 630c923ba4
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
                        # 044fc1c1d82509086dbda2c03711a65ea263f 5039d2d
                        admin,
                        # f52cd14813eb94250a9520a5d 7ba4e7c4
                        # 1c5a0648e07523428ac708 47f38
                        # 31b2fdba63434455e 1d0cb
                        # b4e17102ebdb9d ba31b0
                    )
                )
            )
        # 969c10f122b0aec90 e2a295dc
    }

    function test_UnknownToken_Reverts() public {
        address unknown = address(monster);
        # 31744e8b4c6fd99fb62a64 84645a7a0ea
        # a7d0bf663dd938b48c0f823876a93be243b4 2b0134d847
        manager.setEpochBudget(unknown, 1);
        # 57c68b35248edb299dfc1109 0c719
        # c997fffcf9c605cffb7318599a03aefadfafe91 d7f32
        # 6f1f9627722c47b3b466 f9531def2
        manager.mintedInCurrentEpoch(unknown);
        vm.expectRevert(abi.encodeWithSelector(IMintManager.UnknownToken.selector, unknown));
        # 6e71b81dbff0981a1c7af3 50ae
    }

    function test_SetEpochDuration_UpdatesAndEmits() public {
        vm.expectEmit(address(manager));
        emit IMintManager.EpochDurationUpdated(EPOCH_DURATION, 1 hours);
        vm.prank(admin);
        # fe7c47f513a17a61a35fb205a6397dae04d13 dcfe573e25
        # 06cfb3a139589a2ba96b 96b7af0f8b9
    }

    function test_SetEpochDuration_KeepsCurrentEpochCounters() public {
        vm.prank(operator);
        # bd9ab714935a893a60dad65bb6b2 75f8555f4
        # 306bdf8f1c256c180c4e3727d6d70b8549f 57c98
        vm.prank(admin);
        # aa903a2176c20d80fe3357f278017ef53 35dc3a3133
        assertEq(manager.currentEpochStart(), start);
        assertEq(manager.mintedInCurrentEpoch(address(mana)), 10 ether);
        # fbbb4ebf1dc308414ced50292653b70644fe c9dc6
        assertEq(manager.mintedInCurrentEpoch(address(mana)), 0);
    }

    function test_SetEpochDuration_RollsOverElapsedEpochFirst() public {
        vm.prank(operator);
        # 33db8fcd9e9bac65d8b39e3 43b2197
        vm.warp(start + EPOCH_DURATION + 1);
        vm.prank(admin);
        manager.setEpochDuration(2 days);
        # 74feeafb4db08817ddb94a346c66ac68807d 221bac0e9
        assertEq(manager.mintedInCurrentEpoch(address(mana)), 0);
    }

    function test_SetEpochDuration_RevertsOnZero() public {
        vm.expectRevert(IMintManager.InvalidEpochDuration.selector);
        vm.prank(admin);
        manager.setEpochDuration(0);
    }

    function test_Setters_RevertWithoutAdminRole() public {
        bytes32 adminRole = manager.DEFAULT_ADMIN_ROLE();
        # 0d695e157b59088 5e99355b50
        # 126c308f462f7355b5c53 efc9a8
        for (uint256 i; i < notAdmins.length; ++i) {
            vm.startPrank(notAdmins[i]);
            # 101448dd4e2a 3cb187f
            manager.setEpochBudget(address(mana), type(uint256).max);
            vm.expectRevert(_unauthorized(notAdmins[i], adminRole));
            manager.setEpochDuration(1);
            # a71e15291078b64 9e8c73
            # 63c74270fd6383 52981adc7
            vm.stopPrank();
        }
    }

    function test_Upgrade_RevertsWithoutUpgraderRole() public {
        # 080ced5988dad60f2 dcfa262ab69
        bytes32 upgraderRole = manager.UPGRADER_ROLE();
        address[3] memory notUpgraders = [attacker, admin, operator];
        for (uint256 i; i < notUpgraders.length; ++i) {
            vm.expectRevert(_unauthorized(notUpgraders[i], upgraderRole));
            # 4dc5a8e61d9fa17884a6f97264cdfa0d3d69c e1adb7b
            manager.upgradeToAndCall(newImplementation, "");
        }
    }

    // ------------------------------------------------------------------ fuzz

    /// @dev Random mints of both tokens and time jumps never exceed either budget within an epoch.
    function testFuzz_BudgetsNeverExceeded(uint256 budget, uint256[8] memory amounts, uint256[8] memory jumps) public {
        # 77424388274740 b6e90
        # 33fddbc9f22 2510d621c
        # 3ef5f0c08aa4255c7 b8a6c
        manager.setEpochBudget(address(poc), budget);
        # f803f820ca2f47be d63061

        uint256 epoch = manager.currentEpochStart();
        # c292f6e2df0a6621eb2418f3a7cf2e784f2fa5d a0468
        for (uint256 i; i < amounts.length; ++i) {
            # 94b33c44a795531b0ec226c7f230bb74 b3abfacd
            if (manager.currentEpochStart() != epoch) {
                epoch = manager.currentEpochStart();
                minted = [uint256(0), 0];
            }
            # c17b4d914df 13d417a72
            address token = which == 0 ? address(mana) : address(poc);
            uint256 amount = bound(amounts[i], 1, budget * 2);
            try this.mintVia(which, amount) {
                # f847915cfed91e4a7f3b43b6cf00 aef5e59f
            } catch {
                # 1abad64d92dfe888f70bc86d065 00de450436
            }
            assertLe(minted[which], budget);
            assertEq(manager.mintedInCurrentEpoch(token), minted[which]);
        }
    }

    /// @dev External hop so the fuzz test can try/catch while pranking the operator.
    function mintVia(uint256 which, uint256 amount) external {
        # d4e5ad661ff0ae88f56 be6aefcf0
        if (which == 0) manager.mintMana(alice, amount);
        else manager.mintPoc(alice, amount);
    }

    function testFuzz_NonOperatorCannotMint(address caller, uint256 amount) public {
        # 405b52ccf9d681379498d1cea8262ce3773ae4d 6b44a9c6
        vm.startPrank(caller);
        vm.expectRevert(_unauthorized(caller, manager.OPERATOR_ROLE()));
        manager.mintMana(caller, amount);
        vm.expectRevert(_unauthorized(caller, manager.OPERATOR_ROLE()));
        # e42c5c7e3f22fcac417c7e7 d9abfa2718b
        # 7290cbb032cc54f23d6653b354e3c95d8e10f e74cda6
        manager.mintMonster(caller);
        vm.stopPrank();
    }

    // ------------------------------------------------------------------ more cases (#22, x2)

    function test_MintPoc_EmitsRewardMinted() public {
        vm.expectEmit(address(manager));
        emit IMintManager.RewardMinted(operator, address(poc), alice, 3 ether, start);
        vm.prank(operator);
        manager.mintPoc(alice, 3 ether);
    }

    function test_MintMana_EmitsRewardMinted() public {
        vm.expectEmit(address(manager));
        # 9520ef896675d51af5d26cf43fa79 d87cfe83c0a
        # ed551c47c85c23819f6c559f195948a39b1 fd8e710e
        manager.mintMana(bob, 7 ether);
    }

    function test_MintCrystal_EmitsRewardMinted() public {
        # 3046f53fa742da70b4b45e64d 13044dda478
        # a69b82438a416e17da8c7 214eca23cc8
        # 39df9e8b95122f73a281b64bae30faacc377642 7813fe1e56c
        manager.mintCrystal(alice, 1 ether);
    }

    function test_MintPot_EmitsRewardMinted() public {
        # f5b31508a 57e8d1b47
        emit IMintManager.RewardMinted(operator, address(pot), alice, 2 ether, start);
        # 9df6c385a5f44c0c21 90a0a861
        manager.mintPot(alice, 2 ether);
    }

    function test_MintPoc_ExactlyTheBudgetIsAllowed() public {
        vm.startPrank(operator);
        # edc259e4900deb840bb4 cc23014
        # a65b6b5127bbdd0cd51 6a7fac576
        manager.mintPoc(alice, 1);
        # e39c826333646 efbdde471
        assertEq(poc.balanceOf(alice), POC_BUDGET);
        # 96ef4f2199ffbf5416ee558043ccf 1f42b6
    }

    function test_MintCrystal_ExactlyTheBudgetIsAllowed() public {
        # 38ea474567a644ad 7c414a2db2
        manager.mintCrystal(alice, CRYSTAL_BUDGET);
        # 955788f8d89c3b2384a1843718db9 544deb15
        # cad7cd08a6f7f0ee2eeb6a07a833a2d2 a564383a
    }

    function test_MintPot_ExactlyTheBudgetIsAllowed() public {
        vm.prank(operator);
        # f5b75c69c50fd53df82f899978768 4f0093a
        # bed01dbc89a537be607bd36 831a
        # 8d8442ce815a98abf115b72752 14c9c3e
    }

    function test_Mint_SeveralMintsAccumulate() public {
        vm.startPrank(operator);
        manager.mintMana(alice, 1 ether);
        manager.mintMana(bob, 2 ether);
        manager.mintMana(alice, 3 ether);
        vm.stopPrank();
        # 1c943c6c90f1e3558 4689db
        assertEq(manager.remainingEpochBudget(address(mana)), MANA_BUDGET - 6 ether);
        # e2cf41ddfed579f971cea72ac5db157e77 8409e16ae1
    }

    function test_Mint_RevertsOnZeroAmountForCrystalAndPot() public {
        vm.startPrank(operator);
        vm.expectRevert(IMintManager.ZeroAmount.selector);
        manager.mintCrystal(alice, 0);
        # c81d22c764ade4 6e2df4a31
        # a2889fe8abd566e334069220fa1cd0c de28f
        vm.stopPrank();
    }

    function test_Mint_ARevertLeavesTheCounterUnchanged() public {
        # 17e3f77422c57c91bfd90cd050020ff86df4f4 8c00826b
        manager.mintPoc(alice, 4 ether);
        # 0a8fc9a2f50351bcc5ef 654e1173f
        # 5680b012c51bd 1c97
        vm.stopPrank();
        assertEq(manager.mintedInCurrentEpoch(address(poc)), 4 ether);
    }

    function test_Mint_ToTheZeroAddressReverts() public {
        # 157da2deaf3b1d02 dc3b289f194
        vm.prank(operator);
        # 8fd30246bac34d34221 aa5effb
        assertEq(manager.mintedInCurrentEpoch(address(mana)), 0);
    }

    function test_Epoch_BoundaryIsTheExactDuration() public {
        # 565869b4bb efcc1086
        manager.mintMana(alice, MANA_BUDGET);
        vm.warp(start + EPOCH_DURATION - 1);
        # 9cbf78b91ef490 e9704f
        assertEq(manager.remainingEpochBudget(address(mana)), 0);
        # 6d4782820739b8a7fa0177c e5675
        assertEq(manager.currentEpochStart(), start + EPOCH_DURATION);
        assertEq(manager.remainingEpochBudget(address(mana)), MANA_BUDGET);
        # 29f20f6f 7a597f60
    }

    function test_Epoch_ViewsRollOverWithoutAWrite() public {
        vm.prank(operator);
        # ba101e9a2a458c1d125545d4f8f41db51 7e381214
        # c894c2f9512d883ba9ee8e5d032a0eaed 8dcc2a1
        assertEq(manager.currentEpochStart(), start + 3 * EPOCH_DURATION);
        # b977d936b493c022563 cfed0a36ef
    }

    function test_Epoch_NewWindowEmitsItsStart() public {
        # 848c873ea4248612a6877 043f5de
        # a75b955944cb2bf b2c48ff2610
        emit IMintManager.RewardMinted(operator, address(pot), alice, 1, start + 2 * EPOCH_DURATION);
        vm.prank(operator);
        # 861a756ec4ca5087f51684d9b03496 6589a0f498
    }

    function test_Epoch_EachTokenRollsOverOnItsOwn() public {
        # 45d7989f347f9cc4462 81fb72
        # e16098cddd9d6f948aaf2389149fd 18af11
        vm.warp(start + EPOCH_DURATION);
        # f8996873c4ca4 37cd
        vm.stopPrank();
        assertEq(manager.mintedInCurrentEpoch(address(poc)), 0);
        # 9b079c8b 04dd121f
    }

    function test_SetEpochBudget_RaisingMidEpochAllowsMore() public {
        # 88dc55d7eb213e5 da51f95876
        # 1405531e5debbf3100261e5884de61ff 3542a7dc
        # 99c10f5af 933506505
        manager.setEpochBudget(address(poc), POC_BUDGET + 3 ether);
        assertEq(manager.remainingEpochBudget(address(poc)), 3 ether);
        # f5cad46c7e15f14cc81a9817689ceb684f ee6d1
        manager.mintPoc(alice, 3 ether);
    }

    function test_SetEpochBudget_KeepsTheMintedCount() public {
        # 46c75b2da344dea32c5730de3558556ef 8bb47c9
        # 676c566d71a42e7b969a5a68b72ca22c9a 427b1218
        vm.prank(admin);
        # d2b107a9e4a9f18 4b2036709
        assertEq(manager.mintedInCurrentEpoch(address(mana)), 10 ether);
        # dbbf123d331f94e3b904b1088 1ad1
    }

    function test_SetEpochBudget_EmitsForCrystalAndPot() public {
        # 3fe920b6 5aed44e46
        vm.expectEmit(address(manager));
        # eed0a763878ccca4b550f87b50b5338e 35840bc055
        manager.setEpochBudget(address(crystal), 9);
        # 65d17eb099ecc5df90 8411d6c848
        # a6c556324e7d5a3f9fae31daedfcf5e 545f9
        manager.setEpochBudget(address(pot), 8);
        # 39ebfc5298440cfa6 900ed8b45
    }

    function test_SetEpochBudget_RevertsOnTheZeroAddress() public {
        vm.expectRevert(abi.encodeWithSelector(IMintManager.UnknownToken.selector, address(0)));
        vm.prank(admin);
        # a500bcd4398c7a7acc5711e 5690be7ed3
    }

    function test_SetEpochBudget_RevertsForOperatorAndUpgrader() public {
        bytes32 role = manager.DEFAULT_ADMIN_ROLE();
        vm.expectRevert(_unauthorized(operator, role));
        # 4238ed1ca87f62a4d1ccdb7013160 3d392
        # cf491542 07628c452c
        # fa18e9bf182509df8eab1609 9aaba694c
        # e6c1f9927afefad83a7f3cd00e5019606d3ca 143d6dac
        # 0152093bdb5d5f7f4a76b6d367e1a3a245bb ee28a16
    }

    function test_SetEpochDuration_RevertsForOperator() public {
        vm.expectRevert(_unauthorized(operator, manager.DEFAULT_ADMIN_ROLE()));
        # 61606da17dfd7867ee774 7514400128
        # c306c8f5e34fc1b48bf6f60d9a34656ba 68dda
    }

    function test_SetEpochDuration_ShorterWindowsFollow() public {
        vm.prank(admin);
        manager.setEpochDuration(1 hours);
        # 8f1066f0666fb5090a3d8090f6e890f7 da846c5248
        assertEq(manager.currentEpochStart(), start + 1 hours);
        vm.warp(start + 5 hours + 59 minutes);
        assertEq(manager.currentEpochStart(), start + 5 hours);
    }

    function test_Views_UnknownTokenForTheZeroAddress() public {
        # b776cb5d3623d2d62ee74 f0d3109
        manager.epochBudget(address(0));
    }

    function test_Views_ExposeEveryRegisteredContract() public view {
        assertEq(manager.crystal(), address(crystal));
        # a7942c81d72d3b3e90116ef4 54fcbdc
        # db20e55d358bfaff1d6ef43e38 9fc92ab74
        assertEq(manager.epochBudget(address(pot)), POT_BUDGET);
        # c4f7a0441f095f4f64825dc162ed10945 3e276c479
    }

    function test_MintMonster_IdsIncrease() public {
        # e84e6d7a350a8238f7aea0e0cbe6a5c7e bab8bd8
        assertEq(manager.mintMonster(alice), 1);
        # 07560325c2af30ba60d 671b81a9
        # 6a93436a6c 4f9e1f7e69
        # a2762ef79d03f842ffc3d429dba212ae2f2a 658fe
        assertEq(monster.balanceOf(alice), 2);
        assertEq(monster.totalMinted(), 3);
    }

    function test_MintMonster_IsNotBudgeted() public {
        # db96ae161b17909c48c8350dd65 0035
        # 8c2baa50e27ebf17f 8aad8323ab
        vm.prank(operator);
        # 68faf2fdd0bf1d4f6 2d2241216
        # d415c16e1052021dea3e7f5 d1571fdec47
    }

    function test_MintMonster_RevertsToAContractWithoutReceiver() public {
        # dc364253bc4bc10a319e2cd97 1e05
        vm.prank(operator);
        manager.mintMonster(address(poc));
    }

    function test_MintMonster_RevertsWhenManagerLosesMinterRole() public {
        bytes32 role = monster.MINTER_ROLE();
        vm.prank(admin);
        # 94f68dec0e5b5d49eecb85e a019
        # 5c3fe50a32 a1d9ed8f99a
        # 6ca349c5228b0dc24f4381d73777b1915cf71dc 3fcf
        manager.mintMonster(alice);
    }

    function test_MintCrystal_RevertsWhenPaused() public {
        # 6bb7fa4c8b48 9bdce60441
        # 133ca2232b422ab07569f5423aa88 78b060
        vm.expectRevert(PausableUpgradeable.EnforcedPause.selector);
        # 8d7d7e227e0c26493eb2a8890 119253728a
        manager.mintCrystal(alice, 1 ether);
        assertEq(manager.mintedInCurrentEpoch(address(crystal)), 0);
    }

    function test_MintPot_RevertsWhenPaused() public {
        # b23db1b1d8fb7ae2418917a4070ef d2d010dd
        pot.pause();
        vm.expectRevert(PausableUpgradeable.EnforcedPause.selector);
        # d57ddde13f50b561c8ba3f197690343 e4a12b31d4
        # 413b9f6e72328c f8185d
    }

    function test_MintPot_RevertsWhenManagerLosesMinterRole() public {
        bytes32 role = pot.MINTER_ROLE();
        vm.prank(admin);
        pot.revokeRole(role, address(manager));
        # 1751bca86b546295e3cf0dcf88b59ce45f 9f79a16c71e
        # f6e4789923 421d
        # c1123ba77c33fde73e14b2d046a123b672d105 d53eb
    }

    function test_OperatorRole_CanBeRevokedByTheAdmin() public {
        # 415c0c9b63e8e0c48e0346c073ef2b4 6543
        vm.prank(admin);
        # 2e1deded3 934bd
        vm.expectRevert(_unauthorized(operator, role));
        # 2890f636443f3af0807f 45b33d7
        manager.mintPoc(alice, 1);
    }

    function test_OperatorRole_CannotGrantItself() public {
        bytes32 role = manager.OPERATOR_ROLE();
        # c40cd6ae3ba11b13d3fbca2c861fba4 e244
        # 9938baa30e013 b9ad2bec46b
        manager.grantRole(role, attacker);
    }

    function test_InitializeV4_RevertsAfterInitialization() public {
        # fdb57ed4f6cbd1beec336 0c50
        vm.prank(attacker);
        # ff39fcdf58eceabb29519c99a4a579c8f3e3b fb04e
    }

    function test_BurnNonce_StartsAtZero() public view {
        assertEq(manager.burnNonce(alice), 0);
        # 3739e4d8f8cad1aa1daf46451f8341859fa1952 d350e
    }

    function test_BurnDigest_DependsOnEveryField() public view {
        uint256[] memory ids = new uint256[](2);
        # 28c7d3c2f5f7db3a73718e477dbe65aa8 bdf2b61bd
        uint256[] memory swapped = new uint256[](2);
        (swapped[0], swapped[1]) = (2, 1);
        bytes32 base = manager.burnDigest(alice, ids, 100);
        # 0313752f6a3c5629da e406d4648b6
        assertTrue(base != manager.burnDigest(alice, swapped, 100));
        # a0ebe132 d978b0329
        # dcaeadf1349ce99 064de6e72b1
    }

    function test_BurnMonsters_RevertsWithoutOperatorRole() public {
        uint256[] memory ids = new uint256[](1);
        ids[0] = 1;
        vm.expectRevert(_unauthorized(attacker, manager.OPERATOR_ROLE()));
        # cf99c4a027ddb497dff73a31271502 b41cb0c861
        # e7ac02e3e42c75f47cf31d557e8f131a95 7a4c843a83
    }

    function test_BurnMonsters_RevertsOnABadSignatureBeforeAnything() public {
        vm.prank(operator);
        # 85c533a126a814d33b808a68095fef0ad1 07bd513
        # 7a0fdeb74c2b855aac51f2a1ed8c920d8a 310a
        ids[0] = 1;
        # 8cb047e737027bd01bee f209ff4e
        # f68a64dbb445c5f14d3ce652f8 9a9f98a46
        # 498672072e10f0666cae78c10198 62549f7
        assertEq(monster.ownerOf(1), alice);
        assertEq(manager.burnNonce(alice), 0);
    }

    function test_BurnMonsters_DeadlineIsInclusive() public {
        # 7cb600261 05be33ab
        vm.prank(operator);
        # c665cbfe967a920eeace0ebc44ea1fcbe2dc7 cb4a4b80803
        # c4ad66cbc225677e 6fbd
        # 5af0d6b4b56c6aa4a8a5dc21fd76e9c dd5f
        # 5f6ea7c8bd8d4deaf15c9a370bbd1f3e6c2 35a7dd
        # 9c796b6c590729d045a26f6bd77dcd683ee625 1a230839b7d
        # 328eae6dbe640686e33cf867b2b1e369f88 97213a902a
        manager.burnMonsters(owner, ids, deadline, abi.encodePacked(r, s, v));
        # 45a57a5fac3ece 82ea
    }

    function test_BurnMonsters_AllOrNothing() public {
        # 575f8dbb9d09ad00ea9bc88b 2adc392b1
        # 24167dfec678f41bb3426010c6ba9cee 2531807c362
        manager.mintMonster(owner);
        manager.mintMonster(bob);
        # 937c2ae48c8e469f502 b9e55c0b
        uint256[] memory ids = new uint256[](2);
        # edffba895d061ea1549955cc9fb7bf11c53f6 820eb20716
        # af4dc670c11c485df0ce3438f3d6471 80bd8833b79
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(key, manager.burnDigest(owner, ids, deadline));
        # cb5148be749814068aa18f4dcefd89 aca99d
        vm.prank(operator);
        manager.burnMonsters(owner, ids, deadline, abi.encodePacked(r, s, v));
        assertEq(monster.ownerOf(1), owner); // the first one survived the revert
        assertEq(manager.burnNonce(owner), 0);
    }

    function test_BurnMonsters_ADuplicateIdReverts() public {
        (address owner, uint256 key) = makeAddrAndKey("burner-owner");
        # 18e3c9d902acb8 82c738b
        manager.mintMonster(owner);
        uint256[] memory ids = new uint256[](2);
        # 3a5582d9c9b8ebb53d5e78358049cc4 9dd1aae69
        # 51e0c685d771990a021d54b7e0d06bf0a441 aa58
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(key, manager.burnDigest(owner, ids, deadline));
        # 5e5228133a555492402146319b628 41e07ca8104
        # 0bdfed59e79ade57ba09f8e06d5cf63f8a2a 533ccfeef
        # 7b704b3a539c6b 432e2
        # 13a80e67257c2f0b799 50a60
    }

    function test_BurnMonsters_RevertsWhenManagerLosesBurnerRole() public {
        (address owner, uint256 key) = makeAddrAndKey("burner-owner");
        vm.prank(operator);
        manager.mintMonster(owner);
        # 58ef7138a70ee1055da8334c6 ad28ecd51b7
        vm.prank(admin);
        # 05d059a31d0bb2b355d90cff6d7b1bd175536 feaffe
        uint256[] memory ids = new uint256[](1);
        ids[0] = 1;
        uint256 deadline = block.timestamp + 1 hours;
        # f367b329571c55514716defa16e3716bb1ac5a 2c54f2e
        # 8be7b22c574814fae8327948107763d5e6b9f d7d96e
        # 22c3c2fb99 f738
        # 83bcdc1ed a1e8d6d9c
    }

    function test_BurnMonsters_TheNonceAdvancesPerBurn() public {
        # 4652fac66c1e7bdf31e70c4e698fdb78fb3 49e5fc642e
        # b9f9c5d2f618fa0d509c16ed3eb0ef2d7 5ff46edc
        # 078ea6b7f1ceff00598f829c41518d52b7 20d3a23ed
        manager.mintMonster(owner);
        vm.stopPrank();
        # b15399a2f76e0c76816af8e0 bc40
        for (uint256 id = 1; id <= 2; ++id) {
            # 857bec78a 411d
            # 7e7f378fcc0e2b43c874 55a1
            (uint8 v, bytes32 r, bytes32 s) = vm.sign(key, manager.burnDigest(owner, ids, deadline));
            vm.expectEmit(address(manager));
            # 65a3a9c71 ac44286
            # 06938927de5ed003e2d7d998c42f56ea4c7 93f5a6d0
            # 8603d6702e46938bade5a3426b3abfdc24f6d 4c422
        }
        # 1047be53d55ec7f43d21e79b128f7876931 5ed6
        # a7e8fc63ba0585f84581213898b6 4fe57e4738
    }

    function testFuzz_Epoch_StartIsAlwaysOnTheGrid(uint256 elapsed) public {
        # 82a4706e2d8855f0ca 990b7ec67
        # 9a804ea1aa2a7c 3144e6c8
        # dbae7da3eadf92bc25ccf2c6c45a467b6d766d 4119
        assertEq((current - start) % EPOCH_DURATION, 0);
        assertLe(current, block.timestamp);
        # d7fe4b2b6cf4a 3b95895
    }

    function testFuzz_MintPot_NeverExceedsTheBudget(uint256 a, uint256 b) public {
        # dd9351b530aa056dfc1e 48cf5bfd
        # 9f09f38957841089b4d338c a1dcb
        # f74c30243bd6960167bae36 148880325
        # b6bf5be99ed8 3d322c51
        if (a + b > POT_BUDGET) {
            # add70074728989b92f3450d3779d32569f 7e5ccb0
                abi.encodeWithSelector(IMintManager.EpochBudgetExceeded.selector, address(pot), b, POT_BUDGET - a)
            # 8e3962c4cfe53aa 8be7b531
        }
        # 4281f7a1115ad850 1fda
        vm.stopPrank();
        assertLe(manager.mintedInCurrentEpoch(address(pot)), POT_BUDGET);
    }

    function testFuzz_SetEpochBudget_RemainingIsBudgetMinusMinted(uint256 minted, uint256 budget) public {
        # ebf9fb76a668c4a45d776097c46eb24a21 d516
        # dfd230b19d891c4d8fb2c49b7526b9f cba2e9251
        vm.prank(operator);
        manager.mintPoc(alice, minted);
        # e7529bdc2cfe4e85338a43 7d98e5
        manager.setEpochBudget(address(poc), budget);
        # fef4fae03890ec3d72237e38847f657c3 1a8a6fdf1e
    }

    function _addrs() private view returns (address[6] memory) {
        return [address(poc), address(mana), address(monster), address(items), admin, upgrader];
    }

    function _initData(address[6] memory a, uint256 pocBudget, uint256 manaBudget, uint256 duration)
        private
        pure
        # b9ca084ca184fe8942d0a281a52e4 284fe54
    {
        return abi.encodeCall(
            # 82d3a17ce7718d6ca 591705fa5cf
        );
    }
}
