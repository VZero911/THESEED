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
    bytes32 public constant SYSTEM = keccak256("system");
    bytes32 public constant ADMIN = keccak256("admin");
    /// @notice 100 % in basis points.
    uint16 public constant TOTAL_BPS = 10_000;
    /// @notice No role can weigh half or more: no single holder can ever reach the quorum alone.
    uint16 public constant MAX_WEIGHT_BPS = 4999;
    /// @notice The weight of approving super-permission holders a proposal needs (strict majority).
    uint16 public constant QUORUM_BPS = 5001;
    /// @notice At most this many weighted roles (the two super-permissions and the n+1 roles).
    uint256 public constant MAX_ROLES = 16;
    /// @notice Timelock of an ordinary change (weights, upgrade, recovery key, holder change by quorum).
    uint64 public constant DELAY = 2 days;
    /// @notice Timelock of the replacement of a lost super-permission holder (veto + the other holder only).
    uint64 public constant RECOVERY_DELAY = 30 days;
    /// @notice Timelock of the replacement of a lost veto key by V's recovery key.
    uint64 public constant VETO_RECOVERY_DELAY = 90 days;

    enum Kind {
        SetWeight, // role, bps
        SetHolder, // role (SYSTEM or ADMIN), account
        SetVeto, // account
        SetVetoRecovery, // account
        Upgrade // account = new implementation
    }

    struct Proposal {
        Kind kind;
        bytes32 role;
        address account;
        uint16 bps;
        uint64 epoch;
        uint64 queuedAt;
        uint64 eta;
        bool executed;
        bool cancelled;
        address proposer;
    }

    /// @custom:storage-location erc7201:theseed.storage.PowerShares
    struct PowerSharesStorage {
        address veto;
        address vetoRecovery;
        mapping(bytes32 role => address) holder; // SYSTEM and ADMIN only
        mapping(bytes32 role => uint16) weight;
        mapping(bytes32 role => bool) known;
        bytes32[] roles;
        uint256 proposalCount;
        mapping(uint256 id => Proposal) proposals;
        mapping(uint256 id => mapping(address account => bool)) approved;
        uint64 epoch;
        bool upgrading;
    }

    // keccak256(abi.encode(uint256(keccak256("theseed.storage.PowerShares")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant STORAGE_LOCATION = 0xe3439bd3672a65e547a414482b0d757efc4aa12e7cf295e2e6dd3d0e1c65f600;

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
        external
        initializer
    {
        if (veto == address(0) || vetoRecovery == address(0) || systemHolder == address(0) || adminHolder == address(0))
        {
            revert ZeroAddress();
        }
        if (systemHolder == adminHolder) revert BothSuperPermissions(systemHolder);
        if (veto == systemHolder || vetoRecovery == systemHolder) revert SystemCannotHoldVeto(systemHolder);
        if (vetoRecovery == veto) revert RecoveryIsVeto(vetoRecovery);
        PowerSharesStorage storage $ = _s();
        $.veto = veto;
        $.vetoRecovery = vetoRecovery;
        $.holder[SYSTEM] = systemHolder;
        $.holder[ADMIN] = adminHolder;
        _setWeight($, SYSTEM, 4000);
        _setWeight($, ADMIN, 3000);
        emit VetoSet(veto);
        emit VetoRecoverySet(vetoRecovery);
        emit HolderSet(SYSTEM, systemHolder);
        emit HolderSet(ADMIN, adminHolder);
    }

    // ------------------------------------------------------------------ proposals

    /// @notice Starts a proposal. Only the veto holder and the two super-permission holders may propose; V's recovery
    ///         key may only propose a new veto key.
    function propose(Kind kind, bytes32 role, address account, uint16 bps) external returns (uint256 id) {
        PowerSharesStorage storage $ = _s();
        bool party = msg.sender == $.veto || msg.sender == $.holder[SYSTEM] || msg.sender == $.holder[ADMIN];
        if (!party && !(kind == Kind.SetVeto && msg.sender == $.vetoRecovery)) revert NotAParty(msg.sender);
        Proposal memory p = Proposal({
            kind: kind,
            role: role,
            account: account,
            bps: bps,
            epoch: $.epoch,
            queuedAt: 0,
            eta: 0,
            executed: false,
            cancelled: false,
            proposer: msg.sender
        });
        _validate($, p);
        id = ++$.proposalCount;
        $.proposals[id] = p;
        emit Proposed(id, kind, role, account, bps);
    }

    /// @notice Approves a proposal. Approvals count only while the approver still holds its seat at execution.
    function approve(uint256 id) external {
        PowerSharesStorage storage $ = _s();
        Proposal storage p = _open($, id);
        if (!_isParty($, msg.sender, p)) revert NotAParty(msg.sender);
        $.approved[id][msg.sender] = true;
        emit Approved(id, msg.sender);
    }

    /// @notice Withdraws an approval (before execution). A queued proposal whose approvals drop cannot execute.
    function revokeApproval(uint256 id) external {
        PowerSharesStorage storage $ = _s();
        _open($, id);
        if (!$.approved[id][msg.sender]) revert NothingToRevoke(id, msg.sender);
        $.approved[id][msg.sender] = false;
        emit ApprovalRevoked(id, msg.sender);
    }

    /// @notice Starts the timelock of a fully approved proposal. Anyone may call it.
    function queue(uint256 id) external {
        PowerSharesStorage storage $ = _s();
        Proposal storage p = _open($, id);
        if (p.queuedAt != 0) revert AlreadyQueued(id);
        (bool ok, uint64 delay) = _readiness($, p, id);
        if (!ok) revert NotReady(id);
        // forge-lint: disable-next-line(unsafe-typecast)
        uint64 now_ = uint64(block.timestamp); // a uint64 of seconds lasts beyond the year 500 billion
        p.queuedAt = now_;
        p.eta = now_ + delay;
        emit Queued(id, p.eta);
    }

    /// @notice Executes a queued proposal after its timelock, if it is still approved and still valid.
    function execute(uint256 id) external {
     
# __ALICE_HASH_50__ -- Anti-AI-Steal Protection
  N»ΤCφq4`UEΣΎΫÿόRΡ’0|>IE¬γή