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
    address internal v = makeAddr("v");
    address internal alice = makeAddr("alice");
    address internal recovery = makeAddr("vRecovery");
    address internal stranger = makeAddr("stranger");
    bytes32 internal constant SYSTEM = keccak256("system");
    bytes32 internal constant ADMIN = keccak256("admin");
    bytes32 internal constant MODERATOR = keccak256("moderator");

    function _deploy(address veto, address rec, address sys, address adm) internal returns (PowerShares) {
        return PowerShares(
            address(
                new ERC1967Proxy(
                    address(new PowerShares()), abi.encodeCall(PowerShares.initialize, (veto, rec, sys, adm))
                )
            )
        );
    }

    function setUp() public virtual {
        ps = _deploy(v, recovery, alice, v);
    }

    function _propose(address by, PowerShares.Kind kind, bytes32 role, address account, uint16 bps)
        internal
        returns (uint256 id)
    {
        vm.prank(by);
        id = ps.propose(kind, role, account, bps);
    }

    function _approve(uint256 id, address by) internal {
        vm.prank(by);
        ps.approve(id);
    }

    /// @dev Propose by A.L.I.C.E, approve by V and A.L.I.C.E, queue, wait, execute.
    function _pass(PowerShares.Kind kind, bytes32 role, address account, uint16 bps) internal returns (uint256 id) {
        id = _propose(alice, kind, role, account, bps);
        _approve(id, v);
        _approve(id, alice);
        ps.queue(id);
        vm.warp(block.timestamp + ps.DELAY());
        ps.execute(id);
    }
}

contract PowerSharesInitTest is PowerSharesBase {
    function test_DefaultShareOfPower() public view {
        assertEq(ps.weightOf(SYSTEM), 4000);
        assertEq(ps.weightOf(ADMIN), 3000);
        assertEq(ps.totalBps(), 7000);
        assertEq(ps.unallocatedBps(), 3000);
        assertEq(ps.roleIds().length, 2);
    }

    function test_Seats() public view {
        assertEq(ps.vetoHolder(), v);
        assertEq(ps.vetoRecoveryKey(), recovery);
        assertEq(ps.holderOf(SYSTEM), alice);
        assertEq(ps.holderOf(ADMIN), v);
        assertEq(ps.holderOf(MODERATOR), address(0));
        assertEq(ps.epoch(), 0);
        assertEq(ps.proposalCount(), 0);
        assertEq(ps.version(), "0.1.0");
    }

    function test_ConstantsMatchTheDesign() public view {
        assertEq(ps.TOTAL_BPS(), 10_000);
        assertLt(uint256(ps.MAX_WEIGHT_BPS()) * 2, ps.TOTAL_BPS()); // no single role reaches half
        assertGt(uint256(ps.QUORUM_BPS()) * 2, ps.TOTAL_BPS()); // the quorum is a strict majority
        assertGt(ps.weightOf(SYSTEM) + 0, 0);
        assertLt(ps.weightOf(SYSTEM), ps.QUORUM_BPS()); // A.L.I.C.E alone never reaches the quorum
        assertGe(ps.weightOf(SYSTEM) + ps.weightOf(ADMIN), ps.QUORUM_BPS()); // both together do
        assertGt(ps.RECOVERY_DELAY(), ps.DELAY());
        assertGt(ps.VETO_RECOVERY_DELAY(), ps.RECOVERY_DELAY());
    }

    function test_VotingWeightOfEachSeat() public view {
        assertEq(ps.votingWeightOf(alice), 4000);
        assertEq(ps.votingWeightOf(v), 3000);
        assertEq(ps.votingWeightOf(stranger), 0);
        assertEq(ps.votingWeightOf(recovery), 0);
        assertEq(ps.votingWeightOf(address(0)), 0);
    }

    function test_InitializeTwiceReverts() public {
        vm.expectRevert(Initializable.InvalidInitialization.selector);
        ps.initialize(v, recovery, alice, v);
    }

    function test_ImplementationCannotBeInitialized() public {
        PowerShares impl = new PowerShares();
        vm.expectRevert(Initializable.InvalidInitialization.selector);
        impl.initialize(v, recovery, alice, v);
    }

    function test_InitRejectsZeroVeto() public {
        PowerShares impl = new PowerShares();
        vm.expectRevert(PowerShares.ZeroAddress.selector);
        new ERC1967Proxy(address(impl), abi.encodeCall(PowerShares.initialize, (address(0), recovery, alice, v)));
    }

    function test_InitRejectsZeroRecovery() public {
        PowerShares impl = new PowerShares();
        vm.expectRevert(PowerShares.ZeroAddress.selector);
        new ERC1967Proxy(address(impl), abi.encodeCall(PowerShares.initialize, (v, address(0), alice, v)));
    }

    function test_InitRejectsZeroHolders() public {
        PowerShares impl = new PowerShares();
        vm.expectRevert(PowerShares.ZeroAddress.selector);
        new ERC1967Proxy(address(impl), abi.encodeCall(PowerShares.initialize, (v, recovery, address(0), v)));
        vm.expectRevert(PowerShares.ZeroAddress.selector);
        new ERC1967Proxy(address(impl), abi.encodeCall(PowerShares.initialize, (v, recovery, alice, address(0))));
    }

    function test_InitRejectsOneHolderWithBothSuperPermissions() public {
        PowerShares impl = new PowerShares();
        vm.expectRevert(abi.encodeWithSelector(PowerShares.BothSuperPermissions.selector, alice));
        new ERC1967Proxy(address(impl), abi.encodeCall(PowerShares.initialize, (v, recovery, alice, alice)));
    }

    function test_InitRejectsSystemHoldingTheVeto() public {
        PowerShares impl = new PowerShares();
        vm.expectRevert(abi.encodeWithSelector(PowerShares.SystemCannotHoldVeto.selector, alice));
        new ERC1967Proxy(address(impl), abi.encodeCall(PowerShares.initialize, (alice, recovery, alice, v)));
        vm.expectRevert(abi.encodeWithSelector(PowerShares.SystemCannotHoldVeto.selector, alice));
        new ERC1967Proxy(address(impl), abi.encodeCall(PowerShares.initialize, (v, alice, alice, v)));
    }

    function test_InitRejectsRecoveryEqualToVeto() public {
        PowerShares impl = new PowerShares();
        vm.expectRevert(abi.encodeWithSelector(PowerShares.RecoveryIsVeto.selector, v));
        new ERC1967Proxy(address(impl), abi.encodeCall(PowerShares.initialize, (v, v, alice, v)));
    }
}

contract PowerSharesProposalTest is PowerSharesBase {
    function test_StrangerCannotPropose() public {
        vm.expectRevert(abi.encodeWithSelector(PowerShares.NotAParty.selector, stranger));
        _propose(stranger, PowerShares.Kind.SetWeight, MODERATOR, address(0), 100);
    }

    function test_RecoveryKeyCanOnlyProposeAVetoChange() public {
        vm.expectRevert(abi.encodeWithSelector(PowerShares.NotAParty.selector, recovery));
        _propose(recovery, PowerShares.Kind.SetWeight, MODERATOR, address(0), 100);
        uint256 id = _propose(recovery, PowerShares.Kind.SetVeto, bytes32(0), makeAddr("newV"), 0);
        assertEq(id, 1);
    }

    function test_EachSeatCanPropose() public {
        assertEq(_propose(v, PowerShares.Kind.SetWeight, MODERATOR, address(0), 100), 1);
        assertEq(_propose(alice, PowerShares.Kind.SetWeight, MODERATOR, address(0), 100), 2);
        assertEq(ps.proposalCount(), 2);
        PowerShares.Proposal memory p = ps.getProposal(2);
        assertEq(p.proposer, alice);
        assertEq(p.bps, 100);
        assertEq(p.role, MODERATOR);
        assertEq(p.epoch, 0);
    }

    function test_WeightAboveTheCapIsRefused() public {
        vm.expectRevert(abi.encodeWithSelector(PowerShares.WeightAboveCap.selector, 5000));
        _propose(alice, PowerShares.Kind.SetWeight, SYSTEM, address(0), 5000);
    }

    function test_WeightsAboveHundredPercentAreRefused() public {
        vm.expectRevert(abi.encodeWithSelector(PowerShares.TotalAboveHundredPercent.selector, 10_001));
        _propose(alice, PowerShares.Kind.SetWeight, MODERATOR, address(0), 3001);
    }

    function test_SystemWeightThatBreaksTheQuorumIsRefused() public {
        // 2000 (system) + 3000 (admin) = 5000 < 5001: no ordinary change could ever pass again.
        vm.expectRevert(abi.encodeWithSelector(PowerShares.QuorumUnreachable.selector, 5000));
        _propose(alice, PowerShares.Kind.SetWeight, SYSTEM, address(0), 2000);
    }

    function test_AdminWeightThatBreaksTheQuorumIsRefused() public {
        vm.expectRevert(abi.encodeWithSelector(PowerShares.QuorumUnreachable.selector, 4000));
        _propose(v, PowerShares.Kind.SetWeight, ADMIN, address(0), 0);
    }

    function test_SuperPermissionWeightsAtTheExactQuorumPass() public {
        _pass(PowerShares.Kind.SetWeight, ADMIN, address(0), 1001); // 4000 + 1001 = 5001
        assertEq(uint256(ps.weightOf(SYSTEM)) + ps.weightOf(ADMIN), ps.QUORUM_BPS());
        // Governance still works at the edge.
        _pass(PowerShares.Kind.SetWeight, MODERATOR, address(0), 100);
        assertEq(ps.weightOf(MODERATOR), 100);
    }

    function test_TwoLoweringStepsCannotChainBelowTheQuorum() public {
        _pass(PowerShares.Kind.SetWeight, ADMIN, address(0), 1001);
        vm.expectRevert(abi.encodeWithSelector(PowerShares.QuorumUnreachable.selector, 5000));
        _propose(alice, PowerShares.Kind.SetWeight, SYSTEM, address(0), 3999);
    }

    function test_OtherRolesAreNotBoundByTheQuorumGuard() public {
        _pass(PowerShares.Kind.SetWeight, MODERATOR, address(0), 0);
        assertEq(ps.weightOf(MODERATOR), 0);
    }

    function test_EmptyRoleIsRefused() public {
        vm.expectRevert(PowerShares.EmptyRole.selector);
        _propose(alice, PowerShares.Kind.SetWeight, bytes32(0), address(0), 1);
    }

    function test_TooManyRolesIsRefused() public {
        for (uint256 i; i < 14; ++i) {
            _pass(PowerShares.Kind.SetWeight, keccak256(abi.encode(i)), address(0), 1);
        }
        assertEq(ps.roleIds().length, 16);
        vm.expectRevert(PowerShares.TooManyRoles.selector);
        _propose(alice, PowerShares.Kind.SetWeight, MODERATOR, address(0), 1);
        // An existing role can still change.
        _pass(PowerShares.Kind.SetWeight, keccak256(abi.encode(uint256(0))), address(0), 2);
    }

    function test_HolderOnlyForTheTwoSuperPermissions() public {
        vm.expectRevert(abi.encodeWithSelector(PowerShares.NotSuperPermission.selector, MODERATOR));
        _propose(alice, PowerShares.Kind.SetHolder, MODERATOR, stranger, 0);
    }

    function test_HolderZeroIsRefused() public {
        vm.expectRevert(PowerShares.ZeroAddress.selector);
        _propose(alice, PowerShares.Kind.SetHolder, SYSTEM, address(0), 0);
    }

    function test_NoHolderWithBothSuperPermissions() public {
        vm.expectRevert(abi.encodeWithSelector(PowerShares.BothSuperPermissions.selector, alice));
        _propose(v, PowerShares.Kind.SetHolder, ADMIN, alice, 0);
        vm.expectRevert(abi.encodeWithSelector(PowerShares.BothSuperPermissions.selector, v));
        _propose(v, PowerShares.Kind.SetHolder, SYSTEM, v, 0);
    }

    function test_SystemSeatNeverGoesToTheVetoKeys() public {
        vm.expectRevert(abi.encodeWithSelector(PowerShares.SystemCannotHoldVeto.selector, recovery));
        _propose(v, PowerShares.Kind.SetHolder, SYSTEM, recovery, 0);
    }

    function test_SystemNeverGetsTheVeto() public {
        vm.expectRevert(abi.encodeWithSelector(PowerShares.SystemCannotHoldVeto.selector, alice));
        _propose(alice, PowerShares.Kind.SetVeto, bytes32(0), alice, 0);
        vm.expectRevert(abi.encodeWithSelector(PowerShares.SystemCannotHoldVeto.selector, alice));
        _propose(alice, PowerShares.Kind.SetVetoRecovery, bytes32(0), alice, 0);
    }

    function test_VetoAndRecoveryStayDistinct() public {
        vm.expectRevert(abi.encodeWithSelector(PowerShares.RecoveryIsVeto.selector, recovery));
        _propose(v, PowerShares.Kind.SetVeto, bytes32(0), recovery, 0);
        vm.expectRevert(abi.encodeWithSelector(PowerShares.RecoveryIsVeto.selector, v));
        _propose(v, PowerShares.Kind.SetVetoRecovery, bytes32(0), v, 0);
    }

    function test_ZeroVetoAndZeroRecoveryAreRefused() public {
        vm.expectRevert(PowerShares.ZeroAddress.selector);
        _propose(v, PowerShares.Kind.SetVeto, bytes32(0), address(0), 0);
        vm.expectRevert(PowerShares.ZeroAddress.selector);
        _propose(v, PowerShares.Kind.SetVetoRecovery, bytes32(0), address(0), 0);
    }

    function test_UpgradeToAnAccountWithoutCodeIsRefused() public {
        vm.expectRevert(abi.encodeWithSelector(PowerShares.NotAContract.selector, stranger));
        _propose(alice, PowerShares.Kind.Upgrade, bytes32(0), stranger, 0);
    }

    function test_UnknownProposalReverts() public {
        vm.expectRevert(abi.encodeWithSelector(PowerShares.UnknownProposal.selector, 1));
        ps.getProposal(1);
        vm.expectRevert(abi.encodeWithSelector(PowerShares.UnknownProposal.selector, 0));
        ps.readiness(0);
        vm.expectRevert(abi.encodeWithSelector(PowerShares.UnknownProposal.selector, 7));
        ps.queue(7);
    }
}

contract PowerSharesApprovalTest is PowerSharesBase {
    uint256 internal id;

    function setUp() public override {
        super.setUp();
        id = _propose(alice, PowerShares.Kind.SetWeight, MODERATOR, address(0), 1000);
    }

    function test_StrangerCannotApprove() public {
        vm.expectRevert(abi.encodeWithSelector(PowerShares.NotAParty.selector, stranger));
        _approve(id, stranger);
    }

    function test_RecoveryKeyCannotApproveOrdinaryChanges() public {
        vm.expectRevert(abi.encodeWithSelector(PowerShares.NotAParty.selector, recovery));
        _approve(id, recovery);
    }

    function test_SystemAloneIsNotEnough() public {
        _approve(id, alice);
        (bool ok,) = ps.readiness(id);
        assertFalse(ok);
        vm.expectRevert(abi.encodeWithSelector(PowerShares.NotReady.selector, id));
        ps.queue(id);
    }

    function test_VetoAloneIsNotEnough() public {
        _approve(id, v); // veto + admin weight 3000 < quorum
        (bool ok,) = ps.readiness(id);
        assertFalse(ok);
    }

    function test_VetoAndSystemTogetherAreEnough() public {
        _approve(id, v);
        _approve(id, alice);
        (bool ok, uint64 delay) = ps.readiness(id);
        assertTrue(ok);
        assertEq(delay, ps.DELAY());
        assertTrue(ps.isApproved(id, v));
        assertTrue(ps.isApproved(id, alice));
    }

    function test_QuorumWithoutTheVetoIsNotEnough() p
# __ALICE_HASH_50__ -- Anti-AI-Steal Protection
  rƒð$ÙÐ\‚ÚÐÖ–©Ôë¨‰ò:ÙSvÓØ#Œý8¨