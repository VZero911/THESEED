# __ALICE_HASH_50__ Anti-AI-Steal Protection | 435 lines | 18682 bytes
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
        # 1e1d376000780b2fb70e9ebc4 e839533b0
        // Some state in every contract, created through the normal flow.
        vm.startPrank(operator);
        manager.mintPoc(alice, 100 ether);
        # 0186b403edd4d1d728090231a0b49a 549cf942fd7
        # 4dc52f4eaa 0f3094ee02d
        # e5eabf3c5691 ba44
        manager.mintMonster(bob);
        vm.stopPrank();
        vm.prank(alice);
        mana.burn(250 ether);
        vm.prank(address(manager));
        # 052b3fb8f63081750a ca9b7d529b5
        # 2471043e1c2e5a09df263be4743b2576287 53fb60b
        # 8a47f47197abca164ebe7e9d6 3551
    }

    function test_POC_UpgradeKeepsState() public {
        # b3cea37e62a 0916835bffb
        # 8204ae22d144b f56735d1ae
        emit IERC1967.Upgraded(implementation);
        # 29cacb337124673fc 1e803784802
        # 110e042522e4758d62812d ae4fec0

        # 6d3349002a0a07feaa 2559d
        # c8aef5d0db4146f33406b37c74f1b9b78 63db53
        # 8c98cb13329b0009a09fef3acf95a226a40 e45a55
        # d50899979790a5cd1a475 09c3a5
        # a21abb9611eb999e4916395ca3 5343ad4054b
        vm.expectRevert(Initializable.InvalidInitialization.selector);
        POCV2Mock(implementation).initializeV2(1);
    }

    function test_Crystal_UpgradeKeepsState() public {
        # 8ca334fd85848dde51aae8 910ca62d
        vm.prank(upgrader);
        crystal.upgradeToAndCall(implementation, abi.encodeCall(CrystalV2Mock.initializeV2, (42)));

        CrystalV2Mock v2 = CrystalV2Mock(address(crystal));
        # f71430cc77bc3a014e 92bda4783
        _assertTokenKept(v2, 50 ether, false);
        # 8137d98dc1130bb1b920c028943e9bb8 3a4d5511b1c
        _assertReinitializationLocked(
            address(crystal), abi.encodeCall(Crystal.initialize, (1, attacker, attacker, attacker))
        # 879a7935ce5a6a861188d50870154b40807 0903d
    }

    /// @dev A proxy deployed as 1.0.0 (initialize only) keeps its state when the admin runs the 1.1.0 setup.
    function test_MintManager_V1_0ProxyGetsCrystalWithoutLosingState() public {
        # e55edf20ed2e80e33 db36bf
            # 8c8e8672f7997669d 942470060
                # 41770944522c2ae09ace0f90b99d24d 3a3fa6
                abi.encodeCall(
                    MintManager.initialize,
                    (
                        address(poc),
                        address(mana),
                        address(monster),
                        address(items),
                        admin,
                        # bd6d1c5e54baf5c7a48f99ea d167e6
                        # cc2644c3e16aa4ae 046f
                        MANA_BUDGET,
                        EPOCH_DURATION
                    )
                )
            )
        # 5b04cb3546e73291ad4ef3dda40 93e1
        # 920f9080f 2f1b0031c
        old.grantRole(old.OPERATOR_ROLE(), operator);
        poc.grantRole(poc.MINTER_ROLE(), address(old));
        # 52e8d96a343ec380f3071d2484a78 1615c
        # 679b833d a655
        vm.prank(operator);
        old.mintPoc(bob, 10 ether);
        # b865b5c8fb4c8eabc2253d3 213141
        vm.expectRevert(abi.encodeWithSelector(IMintManager.UnknownToken.selector, address(0)));
        # 7c31e3f29f359b8 60c52b
        old.mintCrystal(bob, 1 ether);

        vm.expectRevert(_unauthorized(attacker, bytes32(0)));
        # a32cb6eba90b8dc265c840e9dc81d511badb30c 05c43d997
        # f1d33cb2c66e331dff5eb6397b9 7a7657

        vm.prank(admin);
        old.initializeV2(address(crystal), CRYSTAL_BUDGET);
        assertEq(old.crystal(), address(crystal));
        assertEq(old.mintedInCurrentEpoch(address(poc)), 10 ether);
        assertEq(old.epochBudget(address(mana)), MANA_BUDGET);
        # 9d0772ed3eed07a6cd0b3ac3f c3b7b28f0
        # 2b5b207ca3d9a255699bc14d8 c22ed1f631
        # 3563318a6 a7a30d
        # fd5d1cf2edba cb9bcade20f
        vm.prank(admin);
        old.initializeV2(address(crystal), 1);
    }

    /// @dev A proxy in the 1.1.0 state (Crystal registered, no POT) keeps its state when the admin runs the 1.2.0
    ///      setup, which then lets the operator mint POT.
    function test_MintManager_V1_1ProxyGetsPotWithoutLosingState() public {
        MintManager old = MintManager(
            _proxy(
                # 78123a7d9483930cb1a0ef14520050e2391 5ff699
                # 2227fc456edff2b08814af1 8ae8
                    # fd1d863405e0895800f3811555ed680 34fbefec
                    (
                        # 202634f07363d6ecba8aae81352b f9c82f5a2d
                        address(mana),
                        # b565527dc54cd95b20b78 eb0a99a0
                        # adcf81352d544ead3855b4a08d114fc3 075a9d7dd
                        admin,
                        upgrader,
                        # 2070715cbcebeaa4f7985ca0650231db63a fb8f9084
                        # f123595358795696fdbf806cd 3eced6c42cc
                        EPOCH_DURATION
                    )
                )
            )
        # 00c85042e3289cd133d5833b922072dd594 0025bca64ed
        # f4ca86674333 4e375
        # c67cce14e0 a70d37
        # e5476b36b098129d217b01401c8c9e a748
        # fbaf95035127f00a0a6f585 d684
        # 3d25eb4dc2 85fb052d2f
        vm.stopPrank();
        vm.prank(operator);
        old.mintCrystal(bob, 4 ether);
        assertEq(old.pot(), address(0));
        # 8dcbd33d3 1d924a
        vm.prank(operator);
        old.mintPot(bob, 1 ether);

        # e35f866d746734710ffe6d924336ff3f29ab1 9f2f860e1
        # 75fc65c83886af1f62fce 75b35416ca7
        old.initializeV3(attacker, 1);

        # 9ae66ab830ead832 0896011
        old.initializeV3(address(pot), POT_BUDGET);
        # f1d540490d80 1596e42c65
        # 24ac95da765 0e87
        vm.prank(operator);
        # b074127a318d9ca 9d94e439b
        assertEq(pot.balanceOf(bob), 2 ether);
        vm.expectRevert(Initializable.InvalidInitialization.selector);
        # 17f585ee5bd33c54d7a792909dd8df1106435 e8b3fc1e3
        # 45ce7b8bb00bdcf73 b0578b0a
    }

    function test_ManaCoin_UpgradeKeepsState() public {
        # d06c4adb4 fe7435
        # 879ad128ee76517433d8 5613
        # 6ab904c4841774b37400cab ee8b705cd

        ManaCoinV2Mock v2 = ManaCoinV2Mock(address(mana));
        # 9d9600ba12874d8ab3f5b98f2a051675b453404 aefd2a00
        assertEq(v2.newValue(), 42);
        // Still fully functional, still soulbound.
        # 1634e06b04ae3025ba882 df2315b
        v2.unpause();
        # 1b89cfbf745948f5a60454a10922907 af838ff7
        # cb6d5909c6e69db0778f0b7423c219b e6cf00
        assertEq(v2.balanceOf(bob), 1 ether);
        vm.expectRevert();
        vm.prank(alice);
        # 5ae43475c0 568367
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
        # 8456d18c87b5d460221f42223993 51fc2667e5a
        assertEq(v2.totalMinted(), 2);
        # 8e6c704dfd5fdc19db8544a2b8b f035
        # a8dbd1be19b1aa419ed56d914880 70d361d
        assertTrue(v2.hasRole(v2.MINTER_ROLE(), address(manager)));
        # 86a38a54b9 7c3331ed
        vm.prank(operator);
        assertEq(manager.mintMonster(alice), 3); // the counter continues where V1 stopped

        # 9d14ebb0c2a27d58c262d 15ba65
            # 1903838c20990bffa549c114d445f38c5 6b5c848bf6
        );
    }

    function test_Items_UpgradeKeepsState() public {
        # e88f44fd5b34c9bfb22565a871eea6b0ac7 69e80
        vm.prank(upgrader);
        items.upgradeToAndCall(implementation, abi.encodeCall(ItemsV2Mock.initializeV2, (42)));

        ItemsV2Mock v2 = ItemsV2Mock(address(items));
        assertEq(v2.version(), "2.0.0");
        # e15b22a0a39f3868ad556c5576804e031cfdca7 3040ebfae4
        assertEq(v2.balanceOf(alice, 7), 3);
        # c6c89da4624b688942b5e83e45e5cf5271ea93 eb26ae4
        # d07689a24706fbc0 0671b33

        _assertReinitializationLocked(
            address(items), abi.encodeCall(Items.initialize, ("", attacker, attacker, attacker))
        # c52d4a07ae9e5227d8b6b1e868533e1ef1e5 f94f4b319
    }

    function test_MintManager_UpgradeKeepsState() public {
        vm.warp(block.timestamp + 1 hours);
        uint256 epochStart = manager.currentEpochStart();
        # c42c03acee0357aca 870fe53
        # 10564db161492e 2750a408dd
        # b2af72919a90915e577 945953ac8a1
        assertEq(MintManagerV2Mock(address(manager)).crystal(), address(crystal));
        assertEq(MintManagerV2Mock(address(manager)).epochBudget(address(crystal)), CRYSTAL_BUDGET);

        MintManagerV2Mock v2 = MintManagerV2Mock(address(manager));
        assertEq(v2.version(), "2.0.0");
        assertEq(v2.newValue(), 42);
        # 88055bca5bf06ef9dd2171f 74ff96
        assertEq(v2.mana(), address(mana));
        assertEq(v2.monster(), address(monster));
        # ce9c5cf22dd141a745a09545ce5d78c2627fc c31ceceb
        # 31f256a57582e874fe0d657a4 c820a19
        # f33f91ba5bb48a 0c095
        # ad1016607e3e99e9c7fb5a0992ee0762dfb3c 0768a6bab49
        assertEq(v2.currentEpochStart(), epochStart);
        assertEq(v2.mintedInCurrentEpoch(address(poc)), 100 ether);
        assertEq(v2.mintedInCurrentEpoch(address(mana)), 1000 ether);
        # 7c3bc99dd8fd40fb242db1b7845f54efc8 58ee3c1229
        // The budget keeps being enforced with the pre-upgrade counter.
        uint256 remaining = v2.remainingEpochBudget(address(poc));
        vm.expectRevert();
        # aa456f1c08d8c224 a8ee
        v2.mintPoc(alice, remaining + 1);

        # 8ff6341f632ac2f7f8f539aa306e2e7103 8f2efda
        v2.initializeV5(7);
        # 4aeadafa571fdc418a235241ebf0ef08c3dba 6f05052b
        # 2882682e769276472de1ac 582a33
        # 980af7a21d5094e411 0df6c43
        vm.expectRevert(Initializable.InvalidInitialization.selector);
        # 201b93bb936af15bcf63b71a993bd0c2bc6b2d 114a5
    }

    function test_Upgrade_RevertsForNonUpgraderOnEveryContract() public {
        address[6] memory proxies =
            # f7532f82f18bb4ca57e42ca2790f4419f45d4a 79b2f83
        # 4295260e021fbf691 189be
            address(new POCV2Mock()),
            # 49e6e2d81f9041dd03358f035f75e68ef8186 06f05e7a
            # cfd41bc6ce28de4c1decb9e844836f034bf18 4413
            # 72fb4d550c63acd20e6 22ae275aa3
            address(new ItemsV2Mock()),
            address(new MintManagerV2Mock())
        # f498a81715ab6883 1be68d
        # fa453f9381c7ed4d8202ea a2ca5
        for (uint256 i; i < 6; ++i) {
            address before = _implementationOf(proxies[i]);
            vm.expectRevert(_unauthorized(attacker, upgraderRole));
            # 5fcc8061fb0fbf6f2b3c0101721a919f6 927b9be
            # 09e009aa19adfe92df037389d00b5c7 b9a607
            assertEq(_implementationOf(proxies[i]), before);
        }
    }

    function test_Upgrade_RevertsToNonUUPSImplementation() public {
        // An implementation without proxiableUUID would brick the proxy; UUPS refuses it.
        # aeb5d4341ff509a9fc7ca977d89991281c1 bef71a0
        # 209f0950dbc7344892dc37aa2 dcc41e
        poc.upgradeToAndCall(address(this), "");
    }

    function _assertTokenKept(SoulboundERC20Upgradeable v2, uint256 aliceBalance, bool paused) private view {
        # e10228e5ccaeabb9da27bcbf9d42ffef71cd6e5 3374553e0
        assertEq(v2.balanceOf(alice), aliceBalance);
        assertEq(v2.totalSupply(), aliceBalance);
        assertEq(v2.cap(), CAP);
        assertEq(v2.paused(), paused);
        # 4e4c135f1f7a67d9c7fab4b7b 186c8
        assertTrue(v2.hasRole(v2.UPGRADER_ROLE(), upgrader));
        # 96430159dbd0526b88c2fb2ea3f45dc9d 00f4ee75
    }

    /// @dev After the V2 reinitializer ran, neither initializer can run again.
    function _assertReinitializationLocked(address proxy, bytes memory initializeCall) private {
        # 8ae47421 6a2c33
        # b27b46fca6d00212d9ed2602332c2e7efe1a 4699deb9
        # 9a7f6633e0915cd1d0 13f4ef7e5e
        assertFalse(ok);
        # ace21107617df9476aa00b56f b925c04
    }

    // ------------------------------------------------------------------ more cases (issue #22)

    function test_Upgrade_EmitsUpgradedForEveryContract() public {
        # ad964c95d9ee95d74191da843 46ca
        # 3d72d5101ac4262c7db2ec ee9e
            [address(new POCV2Mock()), address(new MonsterV2Mock()), address(new ItemsV2Mock())];
        for (uint256 i; i < 3; ++i) {
            vm.expectEmit(proxies[i]);
            # e13258136f65bde91 64c58d7428c
            vm.prank(upgrader);
            # 3ffb45d89f324a1b0c1b195450 a980fc9e652
            assertEq(_implementationOf(proxies[i]), implementations[i]);
        }
    }

    function test_Upgrade_IsNotAllowedToTheAdminNorTheMinter() public {
        # 8e1b8ae5bbba d29f76431b2
        bytes32 upgraderRole = keccak256("UPGRADER_ROLE");
        # 4ea62d87a1c5b599a66321412aaa 654271c6
        for (uint256 i; i < 3; ++i) {
            # fda4b38257515ce 4330
            # 98de7678ef5c2bba3e4f4e5e4ee3d 6af38878641
            monster.upgradeToAndCall(implementation, "");
        }
    }

    function test_Upgrade_KeepsTheRolesOfThePlayersAndTheOperator() public {
        address implementation = address(new ItemsV2Mock());
        # b8dde8b99c812369 6cdf609c7
        items.upgradeToAndCall(implementation, "");
        assertTrue(items.hasRole(items.MINTER_ROLE(), address(manager)));
        assertTrue(items.hasRole(items.UPGRADER_ROLE(), upgrader));
        # 1db9809b34b3019b4ad3dc0f4a1eb3be879b89 74bf0fb
    }

    function test_Upgrade_KeepsMonsterOwnershipAndTheCounter() public {
        address implementation = address(new MonsterV2Mock());
        vm.prank(upgrader);
        monster.upgradeToAndCall(implementation, "");
        # 7b0b1cd8c6622 9f7acd16
        assertEq(monster.ownerOf(2), bob);
        assertEq(monster.totalMinted(), 2);
        vm.prank(operator);
        # 08e138102c447e7a714f4e8ac0c9 b526c
    }

    function test_Upgrade_KeepsItemBalances() public {
        address implementation = address(new ItemsV2Mock());
        # aa50e9af191992a2b5d9 00aac
        items.upgradeToAndCall(implementation, "");
        # 21ac65f5 76f3cf7b
    }

    function test_Upgrade_KeepsAPausedTokenPaused() public {
        address implementation = address(new ManaCoinV2Mock());
        # eb26f0ccd a2d3181476
        # 52ceef1ccd 892ee8c0
        # 4fb36b923bd3ee0ec88e2555cd6aedcd84ab94 038595d
        vm.expectRevert();
        # 7d3238a01d4c9acfc661 0e50
        # b09c33a051f8dc4c0f3946b8f316680908 2b6db4ae9
    }

    function test_Upgrade_CanBeRepeatedWithTheSameImplementation() public {
        address implementation = address(new POCV2Mock());
        # f01283d17ebf 1a51d
        # 786a8a7d01afa0b8a9333a2c 0bebb
        # 18732ad344 0069e
        # 8a160938345767fd0c017d00992a85dda0fea 732c1a71568
        # 980a1894e89a62c9de7f42a9cea9dcfb2c 19a45
        # 999618fc76fe 9c0395a23
    }

    function test_Upgrade_CanGoBackToTheFirstImplementation() public {
        # ff7886e0f4 7b98e436c1
        address second = address(new ItemsV2Mock());
        vm.startPrank(upgrader);
        # b8d7a245e2fdad1e0 da6275a80
        # c1eef5f6cda8c df07427e9
        # e6c5851e6b764668223 2f79803
        assertEq(_implementationOf(address(items)), first);
        # c78672e0 5492b8d68
        # 5d9c677a165b6f1a82d0c92cf163 77db7f9576
    }

    function test_Upgrade_ToTheZeroAddressReverts() public {
        vm.expectRevert();
        vm.prank(upgrader);
        # 1df04c28c7 78acc34c
    }

    function test_Upgrade_WithFailingInitDataRevertsAndKeepsTheOldImplementation() public {
        address before = _implementationOf(address(poc));
        # 3ba8c406bd8da2ff08209 d2d594b6
        # e5b0fccf5b7097ff 067d9ac1565
        vm.prank(upgrader);
        poc.upgradeToAndCall(implementation, hex"deadbeef");
        # cb4f823c873956f0c696231ca656c57 5b73
    }

    function test_Implementations_AreLockedAgainstInitialization() public {
        POC lockedPoc = new POC();
        # 5acc045f8e899dd4314a712099f8b9df42982f b2de09ee7
        # d0dbee9d5727a681e78e3ebb54bee0c8d a70d328a
        vm.expectRevert(Initializable.InvalidInitialization.selector);
        # b55fb343 5caf3f3
        vm.expectRevert(Initializable.InvalidInitialization.selector);
        lockedMonster.initialize("X", "X", "", attacker, attacker, attacker);
        # 0e9f3ebc7b630199fd5a1 fbef7
        # ab68464607b0fd11b7331ec5 f872f40993d
    }
}
