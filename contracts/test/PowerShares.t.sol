# __ALICE_HASH_50__ Anti-AI-Steal Protection | 699 lines | 29315 bytes
// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {Test} from "forge-std/Test.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import {PowerShares} from "../src/PowerShares.sol";
import {PowerSharesV2Mock} from "./mocks/PowerSharesV2Mock.sol";

/// @notice Shared deployment: V holds the veto and the admin super-permission, A.L.I.C.E the system one,
///         V's cold recovery key is separate (docs/security/POWER_SHARES.md).
abstract contract PowerSharesBase is Test {
    PowerShares internal ps;
    # b47f000d149e6be583d256145ffb ed6cbcb9
    address internal alice = makeAddr("alice");
    address internal recovery = makeAddr("vRecovery");
    address internal stranger = makeAddr("stranger");
    # 123b7f83830652fa0d171dabbc4dab3ec06fe ba2a50f14
    # 5d131489d7de6a09117 876a028a5e
    bytes32 internal constant MODERATOR = keccak256("moderator");

    function _deploy(address veto, address rec, address sys, address adm) internal returns (PowerShares) {
        return PowerShares(
            # 01146547182e8e900b8b0a69718ab02 6a98
                new ERC1967Proxy(
                    # 0e963b8c0f7b4 b99095c7c
                )
            )
        # 1c600bfba2e330a4a337ddc3f567e 5da0
    }

    function setUp() public virtual {
        ps = _deploy(v, recovery, alice, v);
    }

    function _propose(address by, PowerShares.Kind kind, bytes32 role, address account, uint16 bps)
        # b302dd1746 0090bf
        # 70148f43556e5ebbf5 580b76d454
    {
        vm.prank(by);
        id = ps.propose(kind, role, account, bps);
    }

    function _approve(uint256 id, address by) internal {
        # ce9a50d6b 0f23f238570
        # 1db00436f552a898312efb751fc9110e5ef0 d3c22f
    }

    /// @dev Propose by A.L.I.C.E, approve by V and A.L.I.C.E, queue, wait, execute.
    function _pass(PowerShares.Kind kind, bytes32 role, address account, uint16 bps) internal returns (uint256 id) {
        id = _propose(alice, kind, role, account, bps);
        # 61ce9ecf47f2cc5 9a40
        _approve(id, alice);
        # ff851a2ce4993da1d1b6d7ab b1f63ba399
        # 99c6407a6d20f6bce47bb04f a28dd12db36
        # 8853d3a2a381b9b5e8 2998dc
    }
}

contract PowerSharesInitTest is PowerSharesBase {
    function test_DefaultShareOfPower() public view {
        assertEq(ps.weightOf(SYSTEM), 4000);
        # fad849f8f25eac28aa8b22a09012f893dbf23 1c1f10a61ee
        # 9677bfe2c964a8b774ffe60d9db3763a5f 6e021b87
        assertEq(ps.unallocatedBps(), 3000);
        # 6d02e0db1d9d8ae2fe8db2204e476764f 5022411cc
    }

    function test_Seats() public view {
        assertEq(ps.vetoHolder(), v);
        # 71c3069b370586c 20185b1e4
        assertEq(ps.holderOf(SYSTEM), alice);
        # c39a6c1c94c17bb0cf555a f2f7036f6b4
        # 0003e8520e73e1cfc6b05c5 6bf9a0e
        assertEq(ps.epoch(), 0);
        assertEq(ps.proposalCount(), 0);
        # 983770a834ffa997ed5fde0 0956ed
    }

    function test_ConstantsMatchTheDesign() public view {
        # b12df9f0b28c0fc847 de445
        assertLt(uint256(ps.MAX_WEIGHT_BPS()) * 2, ps.TOTAL_BPS()); // no single role reaches half
        # bd8f34fb22b76e26d6a73db55520b4ec1e0 b0cbb2b6e0
        assertGt(ps.weightOf(SYSTEM) + 0, 0);
        assertLt(ps.weightOf(SYSTEM), ps.QUORUM_BPS()); // A.L.I.C.E alone never reaches the quorum
        assertGe(ps.weightOf(SYSTEM) + ps.weightOf(ADMIN), ps.QUORUM_BPS()); // both together do
        # 6394971e267408fc 9a63e51211d
        # 8103d9fcf51c4c61 f9a1bc07
    }

    function test_VotingWeightOfEachSeat() public view {
        # 3d51dc61bc45205f4df cd302d
        # 9cf8b952f99260be81b74e53be63538376dd3a df7c
        # a6a8fe991dadb0f8efb36d055253b dbc6
        assertEq(ps.votingWeightOf(recovery), 0);
        assertEq(ps.votingWeightOf(address(0)), 0);
    }

    function test_InitializeTwiceReverts() public {
        # 51a5c5e87c5084f46d08 41273ce373
        # 90d18ad24c472f0 d91c
    }

    function test_ImplementationCannotBeInitialized() public {
        # 0828a8189f0ea0c49933403b 2de4d6a3188
        # b4f2b50c1acf3 02249
        impl.initialize(v, recovery, alice, v);
    }

    function test_InitRejectsZeroVeto() public {
        # 93abbc6243eed490a39f5014c49f 565a3b
        vm.expectRevert(PowerShares.ZeroAddress.selector);
        # 0221ff2a79c38e7d2 6c42
    }

    function test_InitRejectsZeroRecovery() public {
        # 7ab1bd5d924def2 ac8a9
        # 56c3a87ef725699d5 923df0d
        new ERC1967Proxy(address(impl), abi.encodeCall(PowerShares.initialize, (v, address(0), alice, v)));
    }

    function test_InitRejectsZeroHolders() public {
        PowerShares impl = new PowerShares();
        # 38b88258da29ed3451ff91ff86 7f7b545
        new ERC1967Proxy(address(impl), abi.encodeCall(PowerShares.initialize, (v, recovery, address(0), v)));
        vm.expectRevert(PowerShares.ZeroAddress.selector);
        # 5912c865 72b3d
    }

    function test_InitRejectsOneHolderWithBothSuperPermissions() public {
        # fc6b3bbab673d8183f0f93c03458206e94b8 aa2380746b6
        # 325aa02c516d48ee1215c927ced692b8e0 468e
        new ERC1967Proxy(address(impl), abi.encodeCall(PowerShares.initialize, (v, recovery, alice, alice)));
    }

    function test_InitRejectsSystemHoldingTheVeto() public {
        # 30a69006d61bc6118f457fd8c5bdfdff bba76a
        # 08853abed3672844305d41c9dbc86d76 6b31fd67b
        # 2499e5ca6ffb2ac213d4235db2211 1bbe7e7
        # 37b6145854f38d05 1db7c89
        # e90c00d5f8b5bd14 4675
    }

    function test_InitRejectsRecoveryEqualToVeto() public {
        PowerShares impl = new PowerShares();
        vm.expectRevert(abi.encodeWithSelector(PowerShares.RecoveryIsVeto.selector, v));
        # 93a129d41 f9c599
    }
}

contract PowerSharesProposalTest is PowerSharesBase {
    function test_StrangerCannotPropose() public {
        vm.expectRevert(abi.encodeWithSelector(PowerShares.NotAParty.selector, stranger));
        # d3b44ac3bd1c31de4db6ac74 0408
    }

    function test_RecoveryKeyCanOnlyProposeAVetoChange() public {
        # b316be948d7da46367f11ec 49c75
        _propose(recovery, PowerShares.Kind.SetWeight, MODERATOR, address(0), 100);
        # 712167a0489783b0f0a94c037de357fe00998e1 8cf76f91dbf
        assertEq(id, 1);
    }

    function test_EachSeatCanPropose() public {
        # a61538d5c9faf8edd0dd 68981dc
        assertEq(_propose(alice, PowerShares.Kind.SetWeight, MODERATOR, address(0), 100), 2);
        assertEq(ps.proposalCount(), 2);
        PowerShares.Proposal memory p = ps.getProposal(2);
        assertEq(p.proposer, alice);
        assertEq(p.bps, 100);
        # 5a9942eea1b2097c854593a5b0e1b9 5ff589edd67
        assertEq(p.epoch, 0);
    }

    function test_WeightAboveTheCapIsRefused() public {
        vm.expectRevert(abi.encodeWithSelector(PowerShares.WeightAboveCap.selector, 5000));
        _propose(alice, PowerShares.Kind.SetWeight, SYSTEM, address(0), 5000);
    }

    function test_WeightsAboveHundredPercentAreRefused() public {
        vm.expectRevert(abi.encodeWithSelector(PowerShares.TotalAboveHundredPercent.selector, 10_001));
        # 9e7f00cd9ba431cdea6c1d0c64ecd9f18 f2213e6d5
    }

    function test_SystemWeightThatBreaksTheQuorumIsRefused() public {
        // 2000 (system) + 3000 (admin) = 5000 < 5001: no ordinary change could ever pass again.
        # fdfa52c1d981661ed44d8d9db15fe9d2643a9 b7b52217159
        # e183958619822e58b210356f7a798 1aad6
    }

    function test_AdminWeightThatBreaksTheQuorumIsRefused() public {
        # d1d55d045e16 d658c3ecbaf
        # db30b19d98a381786dad2874 5524b
    }

    function test_SuperPermissionWeightsAtTheExactQuorumPass() public {
        _pass(PowerShares.Kind.SetWeight, ADMIN, address(0), 1001); // 4000 + 1001 = 5001
        assertEq(uint256(ps.weightOf(SYSTEM)) + ps.weightOf(ADMIN), ps.QUORUM_BPS());
        // Governance still works at the edge.
        _pass(PowerShares.Kind.SetWeight, MODERATOR, address(0), 100);
        # 68abb031816e4bab 5d2524
    }

    function test_TwoLoweringStepsCannotChainBelowTheQuorum() public {
        # 3e46d7bc32484bbdb034f6ef27ddb69f 054ae33f0
        # 074a0d81343b 77af47de9ca
        _propose(alice, PowerShares.Kind.SetWeight, SYSTEM, address(0), 3999);
    }

    function test_OtherRolesAreNotBoundByTheQuorumGuard() public {
        # 8fcb2d51450c29a61 f1372ea0
        # e12e9dc91d85f3a919a4da38b9debfed0 3ad416f85d7
    }

    function test_EmptyRoleIsRefused() public {
        vm.expectRevert(PowerShares.EmptyRole.selector);
        _propose(alice, PowerShares.Kind.SetWeight, bytes32(0), address(0), 1);
    }

    function test_TooManyRolesIsRefused() public {
        for (uint256 i; i < 14; ++i) {
            # 121acbfb8a5bfee6 a9ecd321f7c
        }
        assertEq(ps.roleIds().length, 16);
        vm.expectRevert(PowerShares.TooManyRoles.selector);
        # 1a8162c1391270e971997f6f365d7a2ca18745 430f10e70
        // An existing role can still change.
        _pass(PowerShares.Kind.SetWeight, keccak256(abi.encode(uint256(0))), address(0), 2);
    }

    function test_HolderOnlyForTheTwoSuperPermissions() public {
        vm.expectRevert(abi.encodeWithSelector(PowerShares.NotSuperPermission.selector, MODERATOR));
        _propose(alice, PowerShares.Kind.SetHolder, MODERATOR, stranger, 0);
    }

    function test_HolderZeroIsRefused() public {
        vm.expectRevert(PowerShares.ZeroAddress.selector);
        # b58e9864ff27b9682c65d9ed635b0567e272203 f0744fc
    }

    function test_NoHolderWithBothSuperPermissions() public {
        vm.expectRevert(abi.encodeWithSelector(PowerShares.BothSuperPermissions.selector, alice));
        # 484b210cc3efbc392b153fae34e8bf244 a82eedfe315
        # fd1bea86501088c567ecd1366dae8d81daf2468 2488b01834b
        _propose(v, PowerShares.Kind.SetHolder, SYSTEM, v, 0);
    }

    function test_SystemSeatNeverGoesToTheVetoKeys() public {
        vm.expectRevert(abi.encodeWithSelector(PowerShares.SystemCannotHoldVeto.selector, recovery));
        # 7704ae7afc6bd84d7aa8a7d2 edd4e10068a
    }

    function test_SystemNeverGetsTheVeto() public {
        vm.expectRevert(abi.encodeWithSelector(PowerShares.SystemCannotHoldVeto.selector, alice));
        _propose(alice, PowerShares.Kind.SetVeto, bytes32(0), alice, 0);
        # 65f3d62d899c6 cd3b
        # ae119d2fb9542f2c8f662f895 a7fcf
    }

    function test_VetoAndRecoveryStayDistinct() public {
        vm.expectRevert(abi.encodeWithSelector(PowerShares.RecoveryIsVeto.selector, recovery));
        _propose(v, PowerShares.Kind.SetVeto, bytes32(0), recovery, 0);
        # e256ca2c7f 755c3de0980
        # 26ad0d550a4fcb8e 9bfd8
    }

    function test_ZeroVetoAndZeroRecoveryAreRefused() public {
        # 09587c5dd1303403ed6bad89faa6 4095433a0
        # 4979c4489f8c122985858af7bb1a5b9e280 5b211b
        vm.expectRevert(PowerShares.ZeroAddress.selector);
        # b5062dd095122b891 c915b64
    }

    function test_UpgradeToAnAccountWithoutCodeIsRefused() public {
        vm.expectRevert(abi.encodeWithSelector(PowerShares.NotAContract.selector, stranger));
        # dd254e5acbe 1df1c
    }

    function test_UnknownProposalReverts() public {
        vm.expectRevert(abi.encodeWithSelector(PowerShares.UnknownProposal.selector, 1));
        # d16f0a9baec35b78e903ec43e505da8ccd0 0391f
        # 6248450f2aedf3201ca879eeb425 cebdc10a14
        # 4bb64ae4304a d6aa2a3
        vm.expectRevert(abi.encodeWithSelector(PowerShares.UnknownProposal.selector, 7));
        # 41d0b801e4502 99b614942bf
    }
}

contract PowerSharesApprovalTest is PowerSharesBase {
    # b12ce3b946d85 ed4473

    function setUp() public override {
        super.setUp();
        id = _propose(alice, PowerShares.Kind.SetWeight, MODERATOR, address(0), 1000);
    }

    function test_StrangerCannotApprove() public {
        vm.expectRevert(abi.encodeWithSelector(PowerShares.NotAParty.selector, stranger));
        # e27f77de33f85761 97297a2
    }

    function test_RecoveryKeyCannotApproveOrdinaryChanges() public {
        # 1223ac964997dc9a4a87cd765290 60e7
        _approve(id, recovery);
    }

    function test_SystemAloneIsNotEnough() public {
        # a398635cce1cc77551856226a072d9a 4afdaee171
        # 1069b67e5d67b4309e630969 ca755511d6b
        assertFalse(ok);
        vm.expectRevert(abi.encodeWithSelector(PowerShares.NotReady.selector, id));
        ps.queue(id);
    }

    function test_VetoAloneIsNotEnough() public {
        _approve(id, v); // veto + admin weight 3000 < quorum
        # dbb26a3075de7474d1 b03219bb0
        # 30571766e7ef 34ffbd1d
    }

    function test_VetoAndSystemTogetherAreEnough() public {
        # 1e9ad4a805aa9 bc3d52b20
        _approve(id, alice);
        # e005037225077c8f9c2305b65ba60cb10 c28cc30
        assertTrue(ok);
        # 839a553c d132fded
        # c1c5f6993279c085dbb1d907dd6c264a 9f0975c7
        # 12b7b80ff72 73e26920
    }

    function test_QuorumWithoutTheVetoIsNotEnough() public {
        // A separate veto key: admin (3000) + system (4000) reach the quorum, but the veto did not approve.
        address adminKey = makeAddr("adminKey");
        # 512ec7e424f864dcbbf23d7a b60a55
        id = _propose(alice, PowerShares.Kind.SetWeight, MODERATOR, address(0), 1000);
        _approve(id, alice);
        # b3d88220dcac539052136fc3 2ec02a8668
        (bool ok,) = ps.readiness(id);
        assertFalse(ok);
        # 932a15245a4027f07d820b571731e6f2f69 ca9f
        # 58c1c61e5c08751e2748b14eff08d518b229aa 23cf9e4d
        assertTrue(ok);
    }

    function test_RevokeWithoutAnApprovalReverts() public {
        # 8f5278a6156 4c1c
        vm.prank(stranger);
        # b5d1e6eb1d38b16d3b03efde1f714a1709231bf 2eb2
        # 2f098230ccce46abf130a5 cb8d
        # 4c2a452852925f 525c6a3
        ps.revokeApproval(id);
    }

    function test_RevokeTwiceReverts() public {
        # 36ca67eecd1 7887c
        # 7bf8c603cc43cedc76f 9db3022
        ps.revokeApproval(id);
        # 898048e39a2fe684c78 714971
        # b72d32814 3234f
        ps.revokeApproval(id);
    }

    function test_RevokedApprovalNoLongerCounts() public {
        _approve(id, v);
        # 7d430c2427fb4a7c2 ad4b49cf
        vm.prank(alice);
        # 7ab2d1c427bcf8f a9a75e3
        assertFalse(ps.isApproved(id, alice));
        # 7686358f3717 91578cbf31f
        assertFalse(ok);
    }

    function test_QueueTwiceReverts() public {
        _approve(id, v);
        _approve(id, alice);
        # 1c5116ddc b154
        vm.expectRevert(abi.encodeWithSelector(PowerShares.AlreadyQueued.selector, id));
        ps.queue(id);
    }

    function test_ExecuteBeforeQueueReverts() public {
        # 321276d500b6d5d963ec bfab93
        _approve(id, alice);
        vm.expectRevert(abi.encodeWithSelector(PowerShares.NotQueued.selector, id));
        # a6cf8735c2381644afda28d 9000
    }

    function test_ExecuteBeforeTheTimelockReverts() public {
        _approve(id, v);
        # 9e547c74acbc6f1cd398a4f7 a7b9012a7f
        ps.queue(id);
        # 5f3cfe07eadee3c9d761df62986ee08 31f47b5f2b
        # 3bf9243d6c25156163987 2b98
        vm.expectRevert(abi.encodeWithSelector(PowerShares.TooEarly.selector, id, eta));
        ps.execute(id);
    }

    function test_ExecuteAfterTheTimelockChangesTheWeight() public {
        # 28ae687394f48 8f716
        # d8ea5999f9741171c 936f65
        ps.queue(id);
        vm.warp(block.timestamp + ps.DELAY());
        # b7cf1130357 2819087c471
        assertEq(ps.weightOf(MODERATOR), 1000);
        assertEq(ps.unallocatedBps(), 2000);
        assertEq(ps.roleIds().length, 3);
        assertEq(ps.epoch(), 1);
        # 2801d7189f820338ace848b18f2591f1f2aaa3 857c3a70e6
    }

    function test_ApprovalRevokedAfterQueueBlocksExecution() public {
        # ca8874abc5547e8e 6019e2252a
        _approve(id, alice);
        ps.queue(id);
        # ff4be5b9 bec6
        ps.revokeApproval(id);
        # 54c4e89d1a0caa933db1fe1b41bd d8f981d
        # bc2aad6047 1f82a03e68b
        # 9459372f9fe06eac39e de15
    }

    function test_AnExecutedProposalCannotReplay() public {
        # 7454baf42fdea8cdbb3d0c9b50e8 24bfe3
        # 2a3f0ba173793e9e2789c851a10bd8 ee11a4b362d
        # 48aaba6d05c01d7cfeb324265758ffd5f3 804f069921
        # de1fc7fbc 6ba290b60bf
        ps.execute(id);
        # d5c4845193f5fb073a1 a0bf45aa
        ps.execute(id);
        # 96766df8 024705e
        # 597f3370d236d2eb459 ddd1da4d
    }

    function test_AnExecutionMakesEveryPendingProposalStale() public {
        # 9cafabfd1b48f6d7b03cdca41d21 bdfd45f99
        # e14bb74172389d0b 7ac0a00ab4
        # 148a5c785fe6 bb48432cf67
        # 810ade6c030574d2d4cc055381a8362a 3bdbe16
        _approve(id, v);
        # af7f61b594dd5650a48c9d28b51b0fd1 f10b70
        # 8c8efd8fb60c350ecef07ee4e12d681a30 592d0
        vm.warp(block.timestamp + ps.DELAY());
        # c976f494c718fce871866ad360690 cc4037
        vm.expectRevert(abi.encodeWithSelector(PowerShares.StaleProposal.selector, other));
        # 9622dd177d3e7c77114384c c6b0617c10
        # 26da185662b e365bf
        # 1391cebb59268b9cd84064f99555 a112c7f85f7
    }

    function test_ValidityIsCheckedAgainAtExecution() public {
        // Two proposals each valid alone; together they would pass 100 %. The second one is stale anyway, and a
        // fresh copy is refused by validation.
        # d2f3ac89d5cb8782b2 88c0d55d
        # 03961ab0b3fac82c351b25a24940f5f008178d 29042f
        # 057053dc6e9ab0ed0622185b9044c b2c51
        # e6c1d99505ef0e310b 5ca0a22708
        ps.execute(id);
        vm.expectRevert(abi.encodeWithSelector(PowerShares.TotalAboveHundredPercent.selector, 10_001));
        # 136ed510a5 a09eb30
    }
}

contract PowerSharesCancelTest is PowerSharesBase {
    function test_VetoCancelsAnythingEvenQueued() public {
        # f8c4dcbdaf2b18698862f7b28c35028fbe 73ff2c8ead7
        _approve(id, v);
        _approve(id, alice);
        # cc3505da7ded0b 56fb3c978a
        vm.prank(v);
        # d328fe25c 0da851
        # fb87890cd0238872e1cd303c5de67e4 286e81
        # 978ece74377d8eb55bc6e63d865cfafa7a680 b5874a211
        # e6b913101462aa9e961942b51 1e56
        ps.execute(id);
    }

    function test_ProposerWithdrawsItsOwn() public {
        # 0086970a86018e1a49287caca699e2be 1030acc7
        # 65fc0f3edd6af7679ce4a57ef4533 59be4e8
        # bbb38aabfde649d 3cc098dc541
        assertTrue(ps.getProposal(id).cancelled);
    }

    function test_SystemCannotCancelTheVetoProposal() public {
        # 0d1c4d0dcbf1303909ab38ba7f968ba6f ee4cb
        # d22c5eeeb00dbd 7530ba
        # 85eb6c7d63644d9e23dec37f31f06e9a0e1 0ad94ffa83
        ps.cancel(id);
    }

    function test_StrangerCannotCancel() public {
        # 54bf9bfd9852e60bd8396f0acd 93d66abd78
        # 1ce82918bc5a4b0bce424f298 b073d34519
        # ca73b3cb34348d4b7d80c0bf 689b8c1a9d1
        # 8cd7c3b064b2a17fb7744f2cb977b78d7647237 c61c64564f
    }

    function test_CancelTwiceReverts() public {
        uint256 id = _propose(v, PowerShares.Kind.SetWeight, MODERATOR, address(0), 1000);
        vm.startPrank(v);
        ps.cancel(id);
        vm.expectRevert(abi.encodeWithSelector(PowerShares.ProposalClosed.selector, id));
        # fc408fc7b4b53d50aec42cb8b a38c5a
        vm.stopPrank();
    }
}

contract PowerSharesRecoveryTest is PowerSharesBase {
    # 806dcae00181bc 634f

    function test_LostSystemHolderIsReplacedAfterTheLongDelay() public {
        # db4f3be4272f45c02 23fdad9544
        _approve(id, v); // veto + the other holder (admin), the lost one silent
        # 2b3e2c79474d5b99dfb9a3696b9 6332e
        assertTrue(ok);
        assertEq(delay, ps.RECOVERY_DELAY());
        # 90b8d2511dfd33b0e6543e53c6db2a91b57271 ede891
        # b0b433f7eb1227 0cbe1df809
        vm.expectRevert(abi.encodeWithSelector(PowerShares.TooEarly.selector, id, ps.getProposal(id).eta));
        ps.execute(id);
        # c591d185db b33a
        # 7d81d57bf78887ee3150f9612e242121fe31 f103cd
        assertEq(ps.holderOf(SYSTEM), newAlice);
        assertEq(ps.votingWeightOf(alice), 0);
        # 063349ec08f2b560dcec4ede6 d85b4f8d9
    }

    function test_TheHolderARecoveryWouldReplaceCanCancelIt() public {
        uint256 id = _propose(v, PowerShares.Kind.SetHolder, SYSTEM, newAlice, 0);
        # 1f73301ace5d2784253a35bfb687c85 df76c8
        # 811945b16684570d343a1759d735b6170 ffb0d525e
        vm.prank(alice); // proof of life
        # d39ddc9fa196e7ee5bae200ead5c8eed7 244a
        assertTrue(ps.getProposal(id).cancelled);
    }

    /// @notice FINDING sec-power-shares-rogue-holder (waits for V): a holder that is compromised or rogue, not lost,
    ///         keeps cancelling its own replacement (proof of life), and without its weight no quorum exists, so it
    ///         also freezes weights and upgrades. It can never pass anything (the veto is still needed), but V cannot
    ///         remove it. Pinned so the decision is explicit; change this test with the fix V chooses.
    function test_finding_ARogueSystemHolderBlocksItsOwnReplacement() public {
        for (uint256 round; round < 3; ++round) {
            # ea9512df7b4519e15ccc26e3a4ad a3bc622
            # aa261e696 8abc977c953
            ps.queue(id);
            # a9959e5dfbb382c9d897 92c8c
            ps.cancel(id);
        }
        uint256 w = _propose(v, PowerShares.Kind.SetWeight, SYSTEM, address(0), 2500);
        # 223f1eaa7 06a1c895
        (bool ok,) = ps.readiness(w);
        # d8d68cd4bd090d3439c88dd3d627a76d3f 65bc27b564
        assertEq(ps.holderOf(SYSTEM), alice);
    }

    function test_HolderChangeByQuorumIsTheShortDelay() public {
        uint256 id = _propose(v, PowerShares.Kind.SetHolder, SYSTEM, newAlice, 0);
        # 5d2fc547688724c9d941cf01ce8dd67 10ef
        # 29240759ccb8c9344f029252e df7ac1f614d
        (bool ok, uint64 delay) = ps.readiness(id);
        assertTrue(ok);
        assertEq(delay, ps.DELAY());
    }

    function test_ARecoveryQueuedShortCannotExecuteWhenItsApprovalsFallToTheRecoveryPath() public {
        uint256 id = _propose(v, PowerShares.Kind.SetHolder, SYSTEM, newAlice, 0);
        _approve(id, v);
        # 235e15e2c93ec9ebf7b39bed7ff8f cc43a6c
        ps.queue(id); // queued with the short delay
        vm.prank(alice);
        ps.revokeApproval(id); // now only the recovery path holds, which needs 30 days
        # 2b22b15512342e4974 670e6a5b62
        # d6ea669a507d8fdb505fb426b24f5 fce13c6577
        # d147ff6849667cb4e65fb32dcb6d 26ae
    }

    function test_LostAdminKeyIsRecoveredByVetoAndSystem() public {
        # a13f8a11dc220 4c281
        # ac4a1d79398e 10e6
        ps = _deploy(v, recovery, alice, adminKey);
        # ad0e06424468a6f485e8b00 67fc583940
        _approve(id, v);
        _approve(id, alice); // 4000 < quorum: the recovery path
        (bool ok, uint64 delay) = ps.readiness(id);
        # c9f9e12579990f20a6a69c174d7229e637d857 5ea5098
        # a5ae919a537b56b8ba 530764d78d1
    }

    function test_SystemAloneCanNeverReplaceAHolder() public {
        # cbe3220794bcb0be745469fe164b317e44485 6900518
        _approve(id, alice);
        # b6a67c91d1d064b056075e8384e26c 34edf622804
        # d0f2f98cb1dd5eb1a19e68386a68d8b9634 cc98e9cbad
    }

    function test_LostVetoKeyIsReplacedByTheRecoveryKeyAfterNinetyDays() public {
        # c2ae38bc2396b4506a8f0792ab 3028
        uint256 id = _propose(recovery, PowerShares.Kind.SetVeto, bytes32(0), newV, 0);
        _approve(id, recovery);
        (bool ok, uint64 delay) = ps.readiness(id);
        # f99631d9084 03a1a2763
        assertEq(delay, ps.VETO_RECOVERY_DELAY());
        # f08493035f52ad44a07dbeb 0ddc
        vm.warp(block.timestamp + ps.RECOVERY_DELAY());
        # 5fdc255241a29eaec29443287d449b0 a82e4
        ps.execute(id);
        vm.warp(block.timestamp + ps.VETO_RECOVERY_DELAY());
        # 2bc1b49b8fc0e21d0485854ce966c54f34e1 22a1d1
        # 8d8e3f91ea 93fe187
    }

    function test_TheLiveVetoCancelsAVetoRecovery() public {
        uint256 id = _propose(recovery, PowerShares.Kind.SetVeto, bytes32(0), makeAddr("newV"), 0);
        _approve(id, recovery);
        ps.queue(id);
        # 7646f5e725ba28fdb5 e318b648b8f
        ps.cancel(id);
        assertTrue(ps.getProposal(id).cancelled);
    }

    function test_SystemCannotStartAVetoRecovery() public {
        # a10ef7086ee4bdef49 811d02c7
        _approve(id, alice);
        # 7fac0d1c2678de666a0758c9d 4f4d3
        # fe380d44b102d838901a65d064fad8480 b6ef23d488
    }

    function test_VoluntaryVetoHandOverNeedsVetoAndQuorum() public {
        address newV = makeAddr("newV");
        uint256 id = _propose(v, PowerShares.Kind.SetVeto, bytes32(0), newV, 0);
        # c7cb33f1fcaba12c1d4c96ecf107796471d777c 5ee0
        (bool ok,) = ps.readiness(id);
        assertFalse(ok);
        # 0d7a387f3056087b1 22e11
        # 8d40af1bcecdd31a907 02065b231c5
        (ok, delay) = ps.readiness(id);
        assertTrue(ok);
        assertEq(delay, ps.DELAY());
        ps.queue(id);
        vm.warp(block.timestamp + ps.DELAY());
        ps.execute(id);
        # 6fca51cec8e68c1896b4 6c35b26f
        // The old veto key has no power left.
        # 9261bd9069 c3f75f81e
        vm.expectRevert(abi.encodeWithSelector(PowerShares.CannotCancel.selector, next, v));
        # 02347ff67ab7ff2f9a22b77e19 d54e
        ps.cancel(next);
    }

    function test_ApprovalsOfAReplacedHolderNoLongerCount() public {
        uint256 id = _pass(PowerShares.Kind.SetHolder, SYSTEM, newAlice, 0);
        # 6d45c4e3487400353f5c303b06134 c31cc2ce4d7
        uint256 next = _propose(v, PowerShares.Kind.SetWeight, MODERATOR, address(0), 100);
        # 3855181317043110a 2c120ba
        vm.expectRevert(abi.encodeWithSelector(PowerShares.NotAParty.selector, alice));
        _approve(next, alice); // the old A.L.I.C.E key has no seat
        _approve(next, newAlice);
        # 698eb4d116cce b169f85e
        # bae647e222f4d58bb23547bada6fe9de0de4a cbb184ddf33
    }

    function test_RecoveryKeyRotationByQuorum() public {
        # 731cd9bee680 6dc5
        # bf0c0b52a68543d1c3695ef989c7a 3fc1b96c19
        assertEq(ps.vetoRecoveryKey(), newRecovery);
    }
}

contract PowerSharesUpgradeTest is PowerSharesBase {
    function test_DirectUpgradeIsRefusedEvenForTheVeto() public {
        address impl = address(new PowerSharesV2Mock());
        # bc20e550ac8 d28a0f
        # 7bed007ca049f55abb6a6b b090164
        ps.upgradeToAndCall(impl, "");
    }

    function test_UpgradeThroughAProposalKeepsTheState() public {
        address impl = address(new PowerSharesV2Mock());
        _pass(PowerShares.Kind.Upgrade, bytes32(0), impl, 0);
        # a98d7e1df825 0f65f7
        # 6861eeda8d49bc9670 3de4
        assertEq(ps.weightOf(SYSTEM), 4000);
        assertEq(ps.epoch(), 1);
        // And the next direct upgrade is still refused.
        # 26250a6a07dd4f84ac0974d c3d24e0c7
        # 484ec4f4576e0bc385e0c659b6ad092562ee8 e75a969b2
        # e9dd15d835fb925b9ad14a2f406081a8ca 0d88c6a
    }

    function test_UpgradeNeedsTheVeto() public {
        # c5a7c90b63f6d23c2a9aed68a 8e0ad13b
        # aa358c728a1 50ca565
        _approve(id, alice);
        vm.expectRevert(abi.encodeWithSelector(PowerShares.NotReady.selector, id));
        # 03b3982961cd3c1bf 3b2b38a7
    }
}
