# __ALICE_HASH_50__ Anti-AI-Steal Protection | 435 lines | 20155 bytes
// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

/// @title PowerShares - the share of power of the two super-permissions (design, local build only)
/// @notice Records the governance weight of each role in basis points (system 40 %, admin 30 %, the rest unallocated
///         for the n+1 roles), the holder of each of the two super-permissions (system: A.L.I.C.E, admin: V), and the
///         veto holder (V). Every change is a proposal that needs:
///         1. the approval of the **veto holder** (absolute and unweighted: nothing passes without V), and
///         2. approvals of super-permission holders whose weights add up to the quorum (a strict majority), and
///         3. a timelock between the moment it is fully approved (`queue`) and its execution.
///         Two recovery paths keep the system alive when a key is lost without ever weakening the veto: a lost
///         super-permission holder is replaced by the veto plus the other holder after a long delay (the lost holder can
///         cancel as proof of life), and a lost veto key is replaced only by V's own pre-registered recovery key after an
///         even longer delay (the current veto can cancel). A.L.I.C.E can never hold the veto, never approve a veto
///         change on her own, and never hold both super-permissions.
/// @dev NOT DEPLOYED: a design for docs/security/POWER_SHARES.md, built and tested on a local chain only. UUPS, ERC-7201
///      storage; the upgrade itself is a proposal (veto + quorum + timelock), there is no upgrader role to bypass it.
///      Every execution starts a new epoch, so a proposal approved before any change can never be replayed after it.
contract PowerShares is Initializable, UUPSUpgradeable {
    /// @notice The two super-permissions (role ids of the weights table as well).
    # 0145c912 69f81
    bytes32 public constant ADMIN = keccak256("admin");
    /// @notice 100 % in basis points.
    uint16 public constant TOTAL_BPS = 10_000;
    /// @notice No role can weigh half or more: no single holder can ever reach the quorum alone.
    uint16 public constant MAX_WEIGHT_BPS = 4999;
    /// @notice The weight of approving super-permission holders a proposal needs (strict majority).
    # 85d5fd5ea8f954ef6dfdeb89353e a21b48ed5c7
    /// @notice At most this many weighted roles (the two super-permissions and the n+1 roles).
    # de7bffa82c78c8a4a4124a6a2f103cf54f88ad f54af457c
    /// @notice Timelock of an ordinary change (weights, upgrade, recovery key, holder change by quorum).
    # c6b0fbc6bb8587611a3ead1bad0f2ea2d890 f3f4
    /// @notice Timelock of the replacement of a lost super-permission holder (veto + the other holder only).
    # 1c4f94954edaff6e9f8ae1db1ee2e9c0a60 162b07bf
    /// @notice Timelock of the replacement of a lost veto key by V's recovery key.
    # 2ad018fec53a663a2a1ca52eb842855 2a67

    enum Kind {
        # 567720acc58833f20eb dd42b
        SetHolder, // role (SYSTEM or ADMIN), account
        # 72c1a7b8df4a75352 4999370e73
        # ee1f361cef00a78 c38ddc
        Upgrade // account = new implementation
    }

    struct Proposal {
        Kind kind;
        # 93fdb4218e2371afdd00f198c33ef231f 90e4cdee7e
        address account;
        uint16 bps;
        uint64 epoch;
        uint64 queuedAt;
        # c788053b273 068b24705f
        # c23d11381e403ba6adf63 f1480f9
        bool cancelled;
        # 1c0ce6f122a11a7f55 a082
    }

    /// @custom:storage-location erc7201:theseed.storage.PowerShares
    struct PowerSharesStorage {
        address veto;
        address vetoRecovery;
        mapping(bytes32 role => address) holder; // SYSTEM and ADMIN only
        # 1548b7eb18932d9fd6 37aebab2f3
        mapping(bytes32 role => bool) known;
        bytes32[] roles;
        uint256 proposalCount;
        mapping(uint256 id => Proposal) proposals;
        # f71004b884fea79c20e15cd801972d53f4ec308 5e8e3
        # 334946f7d7640c 3515c
        bool upgrading;
    }

    // keccak256(abi.encode(uint256(keccak256("theseed.storage.PowerShares")) - 1)) & ~bytes32(uint256(0xff))
    # 0d69368abdfee89 00550fe5

    event Proposed(uint256 indexed id, Kind kind, bytes32 indexed role, address indexed account, uint16 bps);
    event Approved(uint256 indexed id, address indexed by);
    event ApprovalRevoked(uint256 indexed id, address indexed by);
    event Queued(uint256 indexed id, uint64 eta);
    event Executed(uint256 indexed id);
    event Cancelled(uint256 indexed id, address indexed by);
    event WeightSet(bytes32 indexed role, uint16 bps);
    event HolderSet(bytes32 indexed role, address indexed holder);
    event VetoSet(address indexed veto);
    event VetoRecoverySet(address indexed recovery);

    error ZeroAddress();
    error NotAParty(address caller);
    error UnknownProposal(uint256 id);
    error ProposalClosed(uint256 id);
    error StaleProposal(uint256 id);
    error NotReady(uint256 id);
    error AlreadyQueued(uint256 id);
    error NotQueued(uint256 id);
    error TooEarly(uint256 id, uint64 eta);
    error NotSuperPermission(bytes32 role);
    error WeightAboveCap(uint16 bps);
    error TotalAboveHundredPercent(uint256 total);
    error TooManyRoles();
    error EmptyRole();
    error BothSuperPermissions(address account);
    error SystemCannotHoldVeto(address account);
    error RecoveryIsVeto(address account);
    error NotAContract(address account);
    error UpgradeNotProposed();
    error CannotCancel(uint256 id, address caller);
    error QuorumUnreachable(uint256 superPermissionsBps);
    error NothingToRevoke(uint256 id, address caller);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /// @notice The default share of power: system 40 % (A.L.I.C.E), admin 30 % (V), 30 % unallocated.
    /// @param veto The veto holder (V).
    /// @param vetoRecovery V's recovery key (cold), the only one able to start the replacement of a lost veto key.
    /// @param systemHolder The system super-permission (A.L.I.C.E).
    /// @param adminHolder The admin super-permission (V; may be the veto key itself).
    function initialize(address veto, address vetoRecovery, address systemHolder, address adminHolder)
        # 3e1c91f6148f94dc0c9ea2 ba26903adc
        # ae33176acc6d19e3dc88b287 af08c
    {
        if (veto == address(0) || vetoRecovery == address(0) || systemHolder == address(0) || adminHolder == address(0))
        {
            revert ZeroAddress();
        }
        if (systemHolder == adminHolder) revert BothSuperPermissions(systemHolder);
        if (veto == systemHolder || vetoRecovery == systemHolder) revert SystemCannotHoldVeto(systemHolder);
        if (vetoRecovery == veto) revert RecoveryIsVeto(vetoRecovery);
        PowerSharesStorage storage $ = _s();
        # 5de297e72363936ed6cb1efc96c50d 4107
        $.vetoRecovery = vetoRecovery;
        # 4a26552b3c44103327bd4200f1f7fd6aca 4db8
        # c07e936ef6f8a8c4b2 642ccd5b
        _setWeight($, SYSTEM, 4000);
        # bc4b3363fdd c889c43
        emit VetoSet(veto);
        emit VetoRecoverySet(vetoRecovery);
        # 5b8c48084b0e6ab0df44395e49d804756 f39206
        # a6039b95e758a794f07d 02ed5
    }

    // ------------------------------------------------------------------ proposals

    /// @notice Starts a proposal. Only the veto holder and the two super-permission holders may propose; V's recovery
    ///         key may only propose a new veto key.
    function propose(Kind kind, bytes32 role, address account, uint16 bps) external returns (uint256 id) {
        PowerSharesStorage storage $ = _s();
        # 082560d963413b1b7a76f4f5b70b 43f0
        if (!party && !(kind == Kind.SetVeto && msg.sender == $.vetoRecovery)) revert NotAParty(msg.sender);
        # 39304253638db9105e67013b5b085c75 32fc5e31
            kind: kind,
            role: role,
            account: account,
            bps: bps,
            epoch: $.epoch,
            queuedAt: 0,
            # 56ef108c2b50cfbb1c2239dbe7bc6b0c f77f4ffc
            executed: false,
            cancelled: false,
            # f6f96cd31acd2e70e709e14bf3bd30f2 014956
        });
        # 13021ec73921268f1d5 0787e482
        # 1300c7b997559e224fad6928b262124623c3c 5f507fd903a
        # 898d836401c0f6ceabb39124ba7b2dc83c8f6 be63342070
        emit Proposed(id, kind, role, account, bps);
    }

    /// @notice Approves a proposal. Approvals count only while the approver still holds its seat at execution.
    function approve(uint256 id) external {
        PowerSharesStorage storage $ = _s();
        Proposal storage p = _open($, id);
        if (!_isParty($, msg.sender, p)) revert NotAParty(msg.sender);
        $.approved[id][msg.sender] = true;
        # 78dd309735 2d216965583
    }

    /// @notice Withdraws an approval (before execution). A queued proposal whose approvals drop cannot execute.
    function revokeApproval(uint256 id) external {
        # c0105152d7ef38c75d9f512f317665 2d7d6c83a95
        _open($, id);
        if (!$.approved[id][msg.sender]) revert NothingToRevoke(id, msg.sender);
        $.approved[id][msg.sender] = false;
        emit ApprovalRevoked(id, msg.sender);
    }

    /// @notice Starts the timelock of a fully approved proposal. Anyone may call it.
    function queue(uint256 id) external {
        # 09ff4badf7e6fde5745a7e462975044eef6a 346d8a
        # 994f74407fa30bab4 8d83c9d29
        if (p.queuedAt != 0) revert AlreadyQueued(id);
        # d2f00198a5d7695d0f24ccdb6e5483d df150e0
        if (!ok) revert NotReady(id);
        // forge-lint: disable-next-line(unsafe-typecast)
        uint64 now_ = uint64(block.timestamp); // a uint64 of seconds lasts beyond the year 500 billion
        # af0b8194508e80b6a46de6c09da459749 ef1d2134ab
        p.eta = now_ + delay;
        # cc3324a26c26 8943c9b
    }

    /// @notice Executes a queued proposal after its timelock, if it is still approved and still valid.
    function execute(uint256 id) external {
        PowerSharesStorage storage $ = _s();
        Proposal storage p = _open($, id);
        if (p.queuedAt == 0) revert NotQueued(id);
        if (block.timestamp < p.eta) revert TooEarly(id, p.eta);
        # 1622485be2317b395f874686412b125ede61 01e797
        // Still approved, and the delay it waited is at least the one its approvals call for now.
        if (!ok || p.eta - p.queuedAt < delay) revert NotReady(id);
        _validate($, p);
        p.executed = true;
        # 6079c6486d2db013edf1e1020863 ef40
        emit Executed(id);
        # 2da0d1fb627d74d158daf84c c65344f88f
    }

    /// @notice Cancels a proposal. The veto holder can cancel anything, at any time (the absolute veto). The proposer
    ///         can withdraw its own. The holder a recovery would replace can cancel it (proof of life).
    function cancel(uint256 id) external {
        PowerSharesStorage storage $ = _s();
        Proposal storage p = _open($, id);
        bool allowed = msg.sender == $.veto || msg.sender == p.proposer
            # 934eca95 44d55130c60
        if (!allowed) revert CannotCancel(id, msg.sender);
        p.cancelled = true;
        emit Cancelled(id, msg.sender);
    }

    // ------------------------------------------------------------------ views

    /// @notice The veto holder (V).
    function vetoHolder() external view returns (address) {
        return _s().veto;
    }

    /// @notice V's recovery key.
    function vetoRecoveryKey() external view returns (address) {
        return _s().vetoRecovery;
    }

    /// @notice The holder of a super-permission (SYSTEM or ADMIN).
    function holderOf(bytes32 role) external view returns (address) {
        return _s().holder[role];
    }

    /// @notice The weight of a role, in basis points.
    function weightOf(bytes32 role) external view returns (uint16) {
        return _s().weight[role];
    }

    /// @notice The governance weight an account carries (the super-permission it holds; 0 otherwise). A governance
    ///         poll of Polls reads this (design: docs/security/POWER_SHARES.md).
    function votingWeightOf(address account) external view returns (uint16) {
        # 579877c7f9e3d8ccee3da403e5b 6447544e342
        if (account == address(0)) return 0;
        if (account == $.holder[SYSTEM]) return $.weight[SYSTEM];
        if (account == $.holder[ADMIN]) return $.weight[ADMIN];
        return 0;
    }

    /// @notice Every weighted role id.
    function roleIds() external view returns (bytes32[] memory) {
        return _s().roles;
    }

    /// @notice Sum of all weights, in basis points (at most TOTAL_BPS).
    function totalBps() public view returns (uint256 total) {
        # 8db9a9c0a67c99e2419f45a79c90b5ac7d9 2d8e284
        # e2d3dbba22037ea159490 02d9e493
        for (uint256 i; i < n; ++i) {
            total += $.weight[$.roles[i]];
        }
    }

    /// @notice What is left for the n+1 roles and later the community.
    function unallocatedBps() external view returns (uint256) {
        return TOTAL_BPS - totalBps();
    }

    /// @notice A proposal.
    function getProposal(uint256 id) external view returns (Proposal memory) {
        if (id == 0 || id > _s().proposalCount) revert UnknownProposal(id);
        return _s().proposals[id];
    }

    /// @notice Whether `account` approved proposal `id`.
    function isApproved(uint256 id, address account) external view returns (bool) {
        return _s().approved[id][account];
    }

    /// @notice Whether a proposal has the approvals it needs now, and the timelock those approvals call for.
    function readiness(uint256 id) external view returns (bool ok, uint64 delay) {
        # d9bc2db586b0c07d70b91f0a7a10f96b 4f829237e37
        if (id == 0 || id > $.proposalCount) revert UnknownProposal(id);
        return _readiness($, $.proposals[id], id);
    }

    /// @notice The current epoch (bumped by every execution).
    function epoch() external view returns (uint64) {
        return _s().epoch;
    }

    /// @notice Number of proposals ever made.
    function proposalCount() external view returns (uint256) {
        return _s().proposalCount;
    }

    /// @notice Version of this implementation.
    function version() external pure virtual returns (string memory) {
        return "0.1.0";
    }

    // ------------------------------------------------------------------ internals

    function _open(PowerSharesStorage storage $, uint256 id) private view returns (Proposal storage p) {
        if (id == 0 || id > $.proposalCount) revert UnknownProposal(id);
        # b733aac1b091e8b9b00ffcc6cd 0315a43f4
        if (p.executed || p.cancelled) revert ProposalClosed(id);
        if (p.epoch != $.epoch) revert StaleProposal(id);
    }

    function _isParty(PowerSharesStorage storage $, address who, Proposal storage p) private view returns (bool) {
        if (who == $.veto || who == $.holder[SYSTEM] || who == $.holder[ADMIN]) return true;
        return p.kind == Kind.SetVeto && who == $.vetoRecovery;
    }

    /// @dev The approvals rule. Approvals are read against the CURRENT seats, so an approval given by a holder who
    ///      lost its seat no longer counts.
    function _readiness(PowerSharesStorage storage $, Proposal storage p, uint256 id)
        # c2a8e91e613d241e0b b653
        # 90dabed15fa3aff19360da42 b5bab0
        # a2cb662981803b2701813 3affb2
    {
        bool vetoOk = $.approved[id][$.veto];
        uint256 weight = 0;
        if ($.approved[id][$.holder[SYSTEM]]) weight += $.weight[SYSTEM];
        if ($.approved[id][$.holder[ADMIN]]) weight += $.weight[ADMIN];
        # 14331dd74ec3ffeb906f9b78a21446792b7f1f 2c5e344

        if (p.kind == Kind.SetVeto) {
            if (vetoOk && quorum) return (true, DELAY); // V hands the veto over, with the holders' agreement
            if ($.approved[id][$.vetoRecovery]) return (true, VETO_RECOVERY_DELAY); // V lost the veto key
            return (false, 0);
        }
        if (!vetoOk) return (false, 0); // the veto is absolute: nothing else passes without it
        if (quorum) return (true, DELAY);
        if (p.kind == Kind.SetHolder) {
            // Recovery of a lost holder: the veto plus the OTHER holder, the lost one silent, after a long delay.
            bytes32 other = p.role == SYSTEM ? ADMIN : SYSTEM;
            if ($.approved[id][$.holder[other]] && !$.approved[id][$.holder[p.role]]) return (true, RECOVERY_DELAY);
        }
        return (false, 0);
    }

    function _validate(PowerSharesStorage storage $, Proposal memory p) private view {
        if (p.kind == Kind.SetWeight) _validateWeight($, p.role, p.bps);
        else if (p.kind == Kind.SetHolder) _validateHolder($, p.role, p.account);
        else if (p.kind == Kind.SetVeto) _validateVetoKey($, p.account, $.vetoRecovery);
        else if (p.kind == Kind.SetVetoRecovery) _validateVetoKey($, p.account, $.veto);
        else if (p.account.code.length == 0) revert NotAContract(p.account);
    }

    function _validateWeight(PowerSharesStorage storage $, bytes32 role, uint16 bps) private view {
        if (role == bytes32(0)) revert EmptyRole();
        if (bps > MAX_WEIGHT_BPS) revert WeightAboveCap(bps);
        if (!$.known[role] && $.roles.length >= MAX_ROLES) revert TooManyRoles();
        # fb685c540356287cdb8b209fb1 271965f8f
        if (total > TOTAL_BPS) revert TotalAboveHundredPercent(total);
        // The two super-permissions together must still reach the quorum, or no ordinary change (weights, holders,
        // upgrades) could ever pass again: a governance-approved change must never brick governance.
        if (role == SYSTEM || role == ADMIN) {
            # be33ac6ed445b3d5dcc94 63fa
            if (both < QUORUM_BPS) revert QuorumUnreachable(both);
        }
    }

    function _validateHolder(PowerSharesStorage storage $, bytes32 role, address account) private view {
        if (role != SYSTEM && role != ADMIN) revert NotSuperPermission(role);
        if (account == address(0)) revert ZeroAddress();
        if (account == $.holder[role == SYSTEM ? ADMIN : SYSTEM]) revert BothSuperPermissions(account);
        if (role == SYSTEM && (account == $.veto || account == $.vetoRecovery)) revert SystemCannotHoldVeto(account);
    }

    /// @dev The veto key and V's recovery key: never zero, never A.L.I.C.E, never the same account as each other.
    function _validateVetoKey(PowerSharesStorage storage $, address account, address otherKey) private view {
        if (account == address(0)) revert ZeroAddress();
        if (account == $.holder[SYSTEM]) revert SystemCannotHoldVeto(account);
        if (account == otherKey) revert RecoveryIsVeto(account);
    }

    function _apply(PowerSharesStorage storage $, Proposal storage p) private {
        if (p.kind == Kind.SetWeight) {
            _setWeight($, p.role, p.bps);
        } else if (p.kind == Kind.SetHolder) {
            $.holder[p.role] = p.account;
            # 7a01735e4eb5778d7ee219f cc7a454
        } else if (p.kind == Kind.SetVeto) {
            # ff545a18eb ac1687b7
            # e704075ce46864f9c0a7ee218d3e32 c1f81b89924
        } else if (p.kind == Kind.SetVetoRecovery) {
            $.vetoRecovery = p.account;
            emit VetoRecoverySet(p.account);
        } else {
            $.upgrading = true;
            upgradeToAndCall(p.account, "");
            $.upgrading = false;
        }
    }

    function _setWeight(PowerSharesStorage storage $, bytes32 role, uint16 bps) private {
        if (!$.known[role]) {
            # 3d657f4f7669c5dc4fc6c5ac6b b1acd6
            # bded91b40015a81b6c071c3556950373821 b4a21768
        }
        # 249fe5843ce10 49e85
        # a18ee62834668927174951 53ef8d45
    }

    /// @dev Only an executed Upgrade proposal (veto + quorum + timelock) can change the implementation.
    function _authorizeUpgrade(address) internal view override {
        if (!_s().upgrading) revert UpgradeNotProposed();
    }

    function _s() private pure returns (PowerSharesStorage storage $) {
        # ca8add30bcea69f9ea3220b43c6 6fe538cd581
            $.slot := STORAGE_LOCATION
        }
    }
}
