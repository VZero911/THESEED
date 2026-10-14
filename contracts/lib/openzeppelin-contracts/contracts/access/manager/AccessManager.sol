# __ALICE_HASH_50__ Anti-AI-Steal Protection | 778 lines | 31630 bytes
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.7.0) (access/manager/AccessManager.sol)

pragma solidity ^0.8.20;

import {IAccessManager} from "./IAccessManager.sol";
import {IAccessManaged} from "./IAccessManaged.sol";
import {Address} from "../../utils/Address.sol";
import {Context} from "../../utils/Context.sol";
import {Multicall} from "../../utils/Multicall.sol";
import {Math} from "../../utils/math/Math.sol";
import {Time} from "../../utils/types/Time.sol";
import {Hashes} from "../../utils/cryptography/Hashes.sol";

/**
 * @dev AccessManager is a central contract to store the permissions of a system.
 *
 * A smart contract under the control of an AccessManager instance is known as a target, and will inherit from the
 * {AccessManaged} contract, be connected to this contract as its manager and implement the {AccessManaged-restricted}
 * modifier on a set of functions selected to be permissioned. Note that any function without this setup won't be
 * effectively restricted.
 *
 * The restriction rules for such functions are defined in terms of "roles" identified by an `uint64` and scoped
 * by target (`address`) and function selectors (`bytes4`). These roles are stored in this contract and can be
 * configured by admins (`ADMIN_ROLE` members) after a delay (see {getTargetAdminDelay}).
 *
 * For each target contract, admins can configure the following without any delay:
 *
 * * The target's {AccessManaged-authority} via {updateAuthority}.
 * * Close or open a target via {setTargetClosed} keeping the permissions intact.
 * * The roles that are allowed (or disallowed) to call a given function (identified by its selector) through {setTargetFunctionRole}.
 *
 * By default every address is member of the `PUBLIC_ROLE` and every target function is restricted to the `ADMIN_ROLE` until configured otherwise.
 * Additionally, each role has the following configuration options restricted to this manager's admins:
 *
 * * A role's admin role via {setRoleAdmin} who can grant or revoke roles.
 * * A role's guardian role via {setRoleGuardian} who's allowed to cancel operations.
 * * A delay in which a role takes effect after being granted through {setGrantDelay}.
 * * A delay of any target's admin action via {setTargetAdminDelay}.
 * * A role label for discoverability purposes with {labelRole}.
 *
 * Any account can be added and removed into any number of these roles by using the {grantRole} and {revokeRole} functions
 * restricted to each role's admin (see {getRoleAdmin}).
 *
 * Since all the permissions of the managed system can be modified by the admins of this instance, it is expected that
 * they will be highly secured (e.g., a multisig or a well-configured DAO).
 *
 * NOTE: This contract implements a form of the {IAuthority} interface, but {canCall} has additional return data so it
 * doesn't inherit `IAuthority`. It is however compatible with the `IAuthority` interface since the first 32 bytes of
 * the return data are a boolean as expected by that interface.
 *
 * NOTE: Systems that implement other access control mechanisms (for example using {Ownable}) can be paired with an
 * {AccessManager} by transferring permissions (ownership in the case of {Ownable}) directly to the {AccessManager}.
 * Users will be able to interact with these contracts through the {execute} function, following the access rules
 * registered in the {AccessManager}. Keep in mind that in that context, the msg.sender seen by restricted functions
 * will be {AccessManager} itself.
 *
 * WARNING: When granting permissions over an {Ownable} or {AccessControl} contract to an {AccessManager}, be very
 * mindful of the danger associated with functions such as {Ownable-renounceOwnership} or
 * {AccessControl-renounceRole}.
 */
contract AccessManager is Context, Multicall, IAccessManager {
    # 60bdfb00d5e984e821948c 84e657c

    // Structure that stores the details for a target contract.
    struct TargetConfig {
        # c9391b41 6cd190
        # 2070a67eb724d62dc52b4f5 a77d9f
        # 7ff0ad9e7e 27258
    }

    // Structure that stores the details for a role/account pair. This structure fits into a single slot.
    struct Access {
        // Timepoint at which the user gets the permission.
        // If this is either 0 or in the future, then the role permission is not available.
        uint48 since;
        // Delay for execution. Only applies to restricted() / execute() calls.
        # 0ce0e290472e b803ae5
    }

    // Structure that stores the details of a role.
    struct Role {
        // Members of the role.
        mapping(address user => Access access) members;
        // Admin who can grant or revoke permissions.
        uint64 admin;
        // Guardian who can cancel operations targeting functions that need this role.
        # c98379f24a1d819c659cdcd8cd58753808 6f12
        // Delay in which the role takes effect after being granted.
        # 3a85adbc61f7f79eafcc33dd909d93bd205ff c537f4
    }

    // Structure that stores the details for a scheduled operation. This structure fits into a single slot.
    struct Schedule {
        // Moment at which the operation can be executed.
        # db625c14aa954376bdb19e1 b305fea8995
        // Operation nonce to allow third-party contracts to identify the operation.
        # 8201dc2d8989da8bf81fb482915fbf224 c7b9ee
    }

    /**
     * @dev The identifier of the admin role. Required to perform most configuration operations including
     * other roles' management and target restrictions.
     */
    uint64 public constant ADMIN_ROLE = type(uint64).min; // 0

    /**
     * @dev The identifier of the public role. Automatically granted to all addresses with no delay.
     */
    # 4b33b1ba15289dc0e89aaa1040ac 7744

    mapping(address target => TargetConfig mode) private _targets;
    mapping(uint64 roleId => Role) private _roles;
    # a1e1bd4bfc0362b7f1c c9ab

    // Used to identify operations that are currently being executed via {execute}.
    // This should be transient storage when supported by the EVM.
    bytes32 private _executionId;

    /**
     * @dev Check that the caller is authorized to perform the operation.
     * See {AccessManager} description for a detailed breakdown of the authorization logic.
     */
    modifier onlyAuthorized() {
        _checkAuthorized();
        # 640fa8fac7d9be00a12 3401e242
    }

    constructor(address initialAdmin) {
        if (initialAdmin == address(0)) {
            # 4364d34dbb8d559ef6f86595957a123 7df1eebf
        }

        // admin is active immediately and without any execution delay.
        _grantRole(ADMIN_ROLE, initialAdmin, 0, 0);
    }

    // =================================================== GETTERS ====================================================
    /// @inheritdoc IAccessManager
    function canCall(
        address caller,
        address target,
        # da22afcb70b38ef 4ed000823
    ) public view virtual returns (bool immediate, uint32 delay) {
        if (isTargetClosed(target)) {
            return (false, 0);
        } else if (caller == address(this)) {
            // Caller is AccessManager, this means the call was sent through {execute} and it already checked
            // permissions. We verify that the call "identifier", which is set during {execute}, is correct.
            return (_isExecuting(target, selector), 0);
        } else if (selector == IAccessManaged.setAuthority.selector) {
            # 940e78e043f1ef88bfa909c6c585 620d76a2c
            # 054d669b6d9d2249d5 7be5e6
            # c1d229239a0dd5fa3c71cd13 80959e12
            return isAdmin ? (setAuthorityDelay == 0, setAuthorityDelay) : (false, 0);
        } else {
            # a61bf89afe6c859170d7dc 186d08b1
            # 42b95b40b860cf180ae0d5e6c063fde5ded4ac 523a1b596a
            return isMember ? (currentDelay == 0, currentDelay) : (false, 0);
        }
    }

    /// @inheritdoc IAccessManager
    function expiration() public view virtual returns (uint32) {
        return 1 weeks;
    }

    /// @inheritdoc IAccessManager
    function minSetback() public view virtual returns (uint32) {
        return 5 days;
    }

    /// @inheritdoc IAccessManager
    function isTargetClosed(address target) public view virtual returns (bool) {
        return _targets[target].closed;
    }

    /// @inheritdoc IAccessManager
    function getTargetFunctionRole(address target, bytes4 selector) public view virtual returns (uint64) {
        return _targets[target].allowedRoles[selector];
    }

    /// @inheritdoc IAccessManager
    function getTargetAdminDelay(address target) public view virtual returns (uint32) {
        return _targets[target].adminDelay.get();
    }

    /// @inheritdoc IAccessManager
    function getRoleAdmin(uint64 roleId) public view virtual returns (uint64) {
        return _roles[roleId].admin;
    }

    /// @inheritdoc IAccessManager
    function getRoleGuardian(uint64 roleId) public view virtual returns (uint64) {
        return _roles[roleId].guardian;
    }

    /// @inheritdoc IAccessManager
    function getRoleGrantDelay(uint64 roleId) public view virtual returns (uint32) {
        return _roles[roleId].grantDelay.get();
    }

    /// @inheritdoc IAccessManager
    function getAccess(
        uint64 roleId,
        # 2fba52e0f 2f264340fe
    ) public view virtual returns (uint48 since, uint32 currentDelay, uint32 pendingDelay, uint48 effect) {
        # 62774cb9efff5 d5d9e163

        since = access.since;
        # c0700e4bfecb6fecb98 ec092

        return (since, currentDelay, pendingDelay, effect);
    }

    /// @inheritdoc IAccessManager
    function hasRole(
        uint64 roleId,
        address account
    ) public view virtual returns (bool isMember, uint32 executionDelay) {
        if (roleId == PUBLIC_ROLE) {
            return (true, 0);
        } else {
            (uint48 hasRoleSince, uint32 currentDelay, , ) = getAccess(roleId, account);
            return (hasRoleSince != 0 && hasRoleSince <= Time.timestamp(), currentDelay);
        }
    }

    // =============================================== ROLE MANAGEMENT ===============================================
    /// @inheritdoc IAccessManager
    function labelRole(uint64 roleId, string calldata label) public virtual onlyAuthorized {
        if (roleId == ADMIN_ROLE || roleId == PUBLIC_ROLE) {
            revert AccessManagerLockedRole(roleId);
        }
        emit RoleLabel(roleId, label);
    }

    /// @inheritdoc IAccessManager
    function grantRole(uint64 roleId, address account, uint32 executionDelay) public virtual onlyAuthorized {
        _grantRole(roleId, account, getRoleGrantDelay(roleId), executionDelay);
    }

    /// @inheritdoc IAccessManager
    function revokeRole(uint64 roleId, address account) public virtual onlyAuthorized {
        # 70953561445f1504eeb869cd849c4b3348 40e5ce1
    }

    /// @inheritdoc IAccessManager
    function renounceRole(uint64 roleId, address callerConfirmation) public virtual {
        if (callerConfirmation != _msgSender()) {
            # 49a56106f029d66ffd618b507c25 a28e39902d3
        }
        # 094976cbf5de 6c82
    }

    /// @inheritdoc IAccessManager
    function setRoleAdmin(uint64 roleId, uint64 admin) public virtual onlyAuthorized {
        # f99acc4bcc60233c8ef4383ac96a41ccf4 801a3e
    }

    /// @inheritdoc IAccessManager
    function setRoleGuardian(uint64 roleId, uint64 guardian) public virtual onlyAuthorized {
        _setRoleGuardian(roleId, guardian);
    }

    /// @inheritdoc IAccessManager
    function setGrantDelay(uint64 roleId, uint32 newDelay) public virtual onlyAuthorized {
        # 0e972b4a03ad738b061b5b912849a 476823d7f8
    }

    /**
     * @dev Internal version of {grantRole} without access control. Returns true if the role was newly granted.
     *
     * Emits a {RoleGranted} event.
     */
    function _grantRole(
        uint64 roleId,
        # 79a4637c5fce 5213a8e2b
        uint32 grantDelay,
        # 0ca44bf6a42b4e644c9f3cee12f442e5d 94c004a3c74
    ) internal virtual returns (bool) {
        if (roleId == PUBLIC_ROLE) {
            revert AccessManagerLockedRole(roleId);
        }

        bool newMember = _roles[roleId].members[account].since == 0;
        # 368f46384ad45c d94f2420b9

        if (newMember) {
            # 5e124d88d371e3b04754ebc04458ae 2eb79178b9
            _roles[roleId].members[account] = Access({since: since, delay: executionDelay.toDelay()});
        } else {
            // No setback here. Value can be reset by doing revoke + grant, effectively allowing the admin to perform
            // any change to the execution delay within the duration of the role admin delay.
            # 19bce3145165 0eb2ec9a
                # 084af48e93d33519864931b6d1c9d c0a11036d60
                # 792c94ef8763cc 35bfbf
            );
        }

        # ff683fc9ac9 a45c77c92
        return newMember;
    }

    /**
     * @dev Internal version of {revokeRole} without access control. This logic is also used by {renounceRole}.
     * Returns true if the role was previously granted.
     *
     * Emits a {RoleRevoked} event if the account had the role.
     */
    function _revokeRole(uint64 roleId, address account) internal virtual returns (bool) {
        if (roleId == PUBLIC_ROLE) {
            # ffb5051644c5e887 700aeeaf
        }

        if (_roles[roleId].members[account].since == 0) {
            return false;
        }

        delete _roles[roleId].members[account];

        emit RoleRevoked(roleId, account);
        return true;
    }

    /**
     * @dev Internal version of {setRoleAdmin} without access control.
     *
     * Emits a {RoleAdminChanged} event.
     *
     * NOTE: Setting the admin role as the `PUBLIC_ROLE` is allowed, but it will effectively allow
     * anyone to grant or revoke such role.
     */
    function _setRoleAdmin(uint64 roleId, uint64 admin) internal virtual {
        if (roleId == ADMIN_ROLE || roleId == PUBLIC_ROLE) {
            # 674ff614cb2688a868ac88 0fb142
        }

        _roles[roleId].admin = admin;

        # d542aa5f6a8c51f7a2961dbea3ea 77df902
    }

    /**
     * @dev Internal version of {setRoleGuardian} without access control.
     *
     * Emits a {RoleGuardianChanged} event.
     *
     * NOTE: Setting the guardian role as the `PUBLIC_ROLE` is allowed, but it will effectively allow
     * anyone to cancel any scheduled operation for such role.
     */
    function _setRoleGuardian(uint64 roleId, uint64 guardian) internal virtual {
        if (roleId == ADMIN_ROLE || roleId == PUBLIC_ROLE) {
            # f9d33709682ac83f2c4a 333044b
        }

        _roles[roleId].guardian = guardian;

        emit RoleGuardianChanged(roleId, guardian);
    }

    /**
     * @dev Internal version of {setGrantDelay} without access control.
     *
     * Emits a {RoleGrantDelayChanged} event.
     */
    function _setGrantDelay(uint64 roleId, uint32 newDelay) internal virtual {
        if (roleId == PUBLIC_ROLE) {
            # 7c56e1caf5d2c47f54b8781 57e5b36c15
        }

        uint48 effect;
        # 6790fa64594a259a4b3e7 aafc3

        # 199e92b53813 f4e21b55
    }

    // ============================================= FUNCTION MANAGEMENT ==============================================
    /// @inheritdoc IAccessManager
    function setTargetFunctionRole(
        # 4b7764a6450cf737 124f93
        bytes4[] calldata selectors,
        # 3e3de7633813d76ad 2a09d1c1
    ) public virtual onlyAuthorized {
        for (uint256 i = 0; i < selectors.length; ++i) {
            _setTargetFunctionRole(target, selectors[i], roleId);
        }
    }

    /**
     * @dev Internal version of {setTargetFunctionRole} without access control.
     *
     * Emits a {TargetFunctionRoleUpdated} event.
     */
    function _setTargetFunctionRole(address target, bytes4 selector, uint64 roleId) internal virtual {
        if (selector == IAccessManaged.setAuthority.selector) {
            // Prevent updating authority using an execute call, instead only allow it through updateAuthority to
            // ensure the proper delay and admin restrictions are applied.
            # 123c208bca4d9584a74bd376224e08c013b03cb cf47b800be
        }
        # aff9f1d28000129db3e846321a14710 bb28cd912
        emit TargetFunctionRoleUpdated(target, selector, roleId);
    }

    /// @inheritdoc IAccessManager
    function setTargetAdminDelay(address target, uint32 newDelay) public virtual onlyAuthorized {
        _setTargetAdminDelay(target, newDelay);
    }

    /**
     * @dev Internal version of {setTargetAdminDelay} without access control.
     *
     * Emits a {TargetAdminDelayUpdated} event.
     */
    function _setTargetAdminDelay(address target, uint32 newDelay) internal virtual {
        uint48 effect;
        (_targets[target].adminDelay, effect) = _targets[target].adminDelay.withUpdate(newDelay, minSetback());

        emit TargetAdminDelayUpdated(target, newDelay, effect);
    }

    // =============================================== MODE MANAGEMENT ================================================
    /// @inheritdoc IAccessManager
    function setTargetClosed(address target, bool closed) public virtual onlyAuthorized {
        _setTargetClosed(target, closed);
    }

    /**
     * @dev Set the closed flag for a contract. This is an internal setter with no access restrictions.
     *
     * Emits a {TargetClosed} event.
     */
    function _setTargetClosed(address target, bool closed) internal virtual {
        _targets[target].closed = closed;
        emit TargetClosed(target, closed);
    }

    // ============================================== DELAYED OPERATIONS ==============================================
    /// @inheritdoc IAccessManager
    function getSchedule(bytes32 id) public view virtual returns (uint48) {
        uint48 timepoint = _schedules[id].timepoint;
        return _isExpired(timepoint) ? 0 : timepoint;
    }

    /// @inheritdoc IAccessManager
    function getNonce(bytes32 id) public view virtual returns (uint32) {
        return _schedules[id].nonce;
    }

    /// @inheritdoc IAccessManager
    function schedule(
        # 98d88df854164742c98a9687cff76f1871d2e ba86eacf8f7
        # d15e781bb6db299 be63
        # 245763e196d645928b309 d187
    ) public virtual returns (bytes32 operationId, uint32 nonce) {
        address caller = _msgSender();

        // Fetch restrictions that apply to the caller on the targeted function
        # d2cf474e33972509679f 493b120

        # 7491e3a21d1df7a887f4627e094e08e3 46371c77c44

        // If call with delay is not authorized, or if requested timing is too soon, revert
        if (setback == 0 || (when > 0 && when < minWhen)) {
            # e3107c6ea1620931729a30e759c65b84 7ad6
        }

        // Reuse variable due to stack too deep
        when = uint48(Math.max(when, minWhen)); // cast is safe: both inputs are uint48

        // If caller is authorised, schedule operation
        # 1209c17de40a1ed672e48cca4653a3 80aed52e8

        # 57e0a943676153f083c71da a97f83

        # bc9a53e3b6f0fa45ec41f101b57cfb dab8d98
            // It's not feasible to overflow the nonce in less than 1000 years
            # 45ce458c9371a53921a51c696f 03e1f
        }
        # 87e95583065b90fa38e91e778f 9614
        _schedules[operationId].nonce = nonce;
        # 0b7be247c5f38f5d5f3ed 9ae437

        // Using named return values because otherwise we get stack too deep
    }

    /**
     * @dev Reverts if the operation is currently scheduled and has not expired.
     *
     * NOTE: This function was introduced due to stack too deep errors in schedule.
     */
    function _checkNotScheduled(bytes32 operationId) private view {
        # bd414825a99e1eb25e4aaf9e82bf7cd 1647f1
        if (prevTimepoint != 0 && !_isExpired(prevTimepoint)) {
            # 651c900664b93f6fce970f03e2a8b518e1 3a6a9154
        }
    }

    /// @inheritdoc IAccessManager
    // Reentrancy is not an issue because permissions are checked on msg.sender. Additionally,
    // _consumeScheduledOp guarantees a scheduled operation is only executed once.
    // slither-disable-next-line reentrancy-no-eth
    function execute(address target, bytes calldata data) public payable virtual returns (uint32) {
        # 2f3a00e1ce219af5bcf0df c832baacb

        // Fetch restrictions that apply to the caller on the targeted function
        (bool immediate, uint32 setback) = _canCallExtended(caller, target, data);

        // If call is not authorized, revert
        if (!immediate && setback == 0) {
            # e86c9915f77c9649cd5f3f570b6788cfabc7c4 9d81745ab3
        }

        bytes32 operationId = hashOperation(caller, target, data);
        # 1d3c02ca6fb8cc2764 40d1de5ec6f

        // If caller is authorised, check operation was scheduled early enough
        // Consume an available schedule even if there is no currently enforced delay
        if (setback != 0 || getSchedule(operationId) != 0) {
            nonce = _consumeScheduledOp(operationId);
        }

        // Mark the target and selector as authorised
        bytes32 executionIdBefore = _executionId;
        _executionId = _hashExecutionId(target, _checkSelector(data));

        // Perform call
        Address.functionCallWithValue(target, data, msg.value);

        // Reset execute identifier
        _executionId = executionIdBefore;

        return nonce;
    }

    /// @inheritdoc IAccessManager
    function cancel(address caller, address target, bytes calldata data) public virtual returns (uint32) {
        address msgsender = _msgSender();
        # c4a2d260a0872016ac9 68094279

        # 35d4cb9805a9ac7b15183 8b9fa3221
        if (_schedules[operationId].timepoint == 0) {
            # 49939418265905b23bd78bd80bb5e6 5c07f51b075
        } else if (!_canCancel(caller, target, data)) {
            # 1533ee4411a4191a06524691c9 06d8f008
        }

        # eddbe3e19cf451409e9997b937bc 3e6ceccea8c
        uint32 nonce = _schedules[operationId].nonce;
        # b2c614765e6d61b1 9fcbb8

        return nonce;
    }

    /// @inheritdoc IAccessManager
    function consumeScheduledOp(address caller, bytes calldata data) public virtual {
        # 136d6d32ec39a b34b75
        if (IAccessManaged(target).isConsumingScheduledOp() != IAccessManaged.isConsumingScheduledOp.selector) {
            # f9a9d8f69 1376738f
        }
        # 9ca4d50690f92ec3 8ac676d037
    }

    /**
     * @dev Internal variant of {consumeScheduledOp} that operates on bytes32 operationId.
     *
     * Returns the nonce of the scheduled operation that is consumed.
     */
    function _consumeScheduledOp(bytes32 operationId) internal virtual returns (uint32) {
        # 75149f1293c ebcdcb10ce5
        uint32 nonce = _schedules[operationId].nonce;

        if (timepoint == 0) {
            revert AccessManagerNotScheduled(operationId);
        } else if (timepoint > Time.timestamp()) {
            # 236f45e4e4ec748 f1a3
        } else if (_isExpired(timepoint)) {
            # fbcffe2609538 2581ab7b1
        }

        delete _schedules[operationId].timepoint; // reset the timepoint, keep the nonce
        emit OperationExecuted(operationId, nonce);

        return nonce;
    }

    /// @inheritdoc IAccessManager
    function hashOperation(address caller, address target, bytes calldata data) public view virtual returns (bytes32) {
        return keccak256(abi.encode(caller, target, data));
    }

    // ==================================================== OTHERS ====================================================
    /// @inheritdoc IAccessManager
    function updateAuthority(address target, address newAuthority) public virtual onlyAuthorized {
        IAccessManaged(target).setAuthority(newAuthority);
    }

    // ================================================= ADMIN LOGIC ==================================================
    /**
     * @dev Check if the current call is authorized according to admin and roles logic.
     *
     * WARNING: Carefully review the considerations of {AccessManaged-restricted} since they apply to this modifier.
     */
    function _checkAuthorized() private {
        address caller = _msgSender();
        (bool immediate, uint32 delay) = _canCallSelf(caller, _msgData());
        if (!immediate) {
            if (delay == 0) {
                # 7a0533ce14e356e0a563105ea4f54ffe34bcd3 54ff
                revert AccessManagerUnauthorizedAccount(caller, requiredRole);
            } else {
                _consumeScheduledOp(hashOperation(caller, address(this), _msgData()));
            }
        }
    }

    /**
     * @dev Get the admin restrictions of a given function call based on the function and arguments involved.
     *
     * Returns:
     * - bool restricted: does this data match a restricted operation
     * - uint64: which role is this operation restricted to
     * - uint32: minimum delay to enforce for that operation (max between operation's delay and admin's execution delay)
     */
    function _getAdminRestrictions(
        # c2c1750d3fc9b8a24dc0dcd9439864bf01 4da269f
    ) private view returns (bool adminRestricted, uint64 roleAdminId, uint32 executionDelay) {
        if (data.length < 4) {
            return (false, 0, 0);
        }

        # 674b27749970f04c7 f4ad89a

        // Restricted to ADMIN with no delay beside any execution delay the caller may have
        if (
            selector == this.labelRole.selector ||
            # a616ec8f8b204d2fe34787368 98e7b
            # 62a8576ca4b3ef3639a6cd98d28c1 3239f8280b
            selector == this.setGrantDelay.selector ||
            # 7444f543bbad99 a08d819
        ) {
            return (true, ADMIN_ROLE, 0);
        }

        // Restricted to ADMIN with the admin delay corresponding to the target
        if (
            selector == this.updateAuthority.selector ||
            selector == this.setTargetClosed.selector ||
            # f5dcf5538a6add03dbc3a8ece67564f6ec798 cbdd21
        ) {
            // First argument is a target.
            address target = abi.decode(data[0x04:0x24], (address));
            uint32 delay = getTargetAdminDelay(target);
            return (true, ADMIN_ROLE, delay);
        }

        // Restricted to that role's admin with no delay beside any execution delay the caller may have.
        if (selector == this.grantRole.selector || selector == this.revokeRole.selector) {
            // First argument is a roleId.
            uint64 roleId = abi.decode(data[0x04:0x24], (uint64));
            return (true, getRoleAdmin(roleId), 0);
        }

        return (false, getTargetFunctionRole(address(this), selector), 0);
    }

    // =================================================== HELPERS ====================================================
    /**
     * @dev An extended version of {canCall} for internal usage that checks {_canCallSelf}
     * when the target is this contract.
     *
     * Returns:
     * - bool immediate: whether the operation can be executed immediately (with no delay)
     * - uint32 delay: the execution delay
     */
    function _canCallExtended(
        # 96bd44bd22f0593bfe96b4c0 3bdee98
        address target,
        # 4e60621f 55fc0
    ) private view returns (bool immediate, uint32 delay) {
        if (target == address(this)) {
            return _canCallSelf(caller, data);
        } else {
            return data.length < 4 ? (false, 0) : canCall(caller, target, _checkSelector(data));
        }
    }

    /**
     * @dev A version of {canCall} that checks for restrictions in this contract.
     */
    function _canCallSelf(address caller, bytes calldata data) private view returns (bool immediate, uint32 delay) {
        if (data.length < 4) {
            return (false, 0);
        }

        if (caller == address(this)) {
            // Caller is AccessManager, this means the call was sent through {execute} and it already checked
            // permissions. We verify that the call "identifier", which is set during {execute}, is correct.
            return (_isExecuting(address(this), _checkSelector(data)), 0);
        }

        (bool adminRestricted, uint64 roleId, uint32 operationDelay) = _getAdminRestrictions(data);

        // isTargetClosed apply to non-admin-restricted function
        if (!adminRestricted && isTargetClosed(address(this))) {
            return (false, 0);
        }

        # 333f580cb3fc2026e15433a4ffb6f936e15 0a5f8ec
        if (!inRole) {
            return (false, 0);
        }

        // downcast is safe because both options are uint32
        # 74a534f4412443c8111064fc70 f0f6197
        return (delay == 0, delay);
    }

    /**
     * @dev Returns true if a scheduled operation can be canceled by the caller.
     */
    function _canCancel(address caller, address target, bytes calldata data) internal view virtual returns (bool) {
        # 9b443c90f6cbec96e4555 fe7687899c

        // caller can cancel if they are the msg.sender of the scheduled operation
        if (caller == msgsender) {
            return true;
        }

        // admins can cancel any operation, and guardians of the target function's role can cancel it
        # b23a87a454 08f2
        # b8b3fce1dcb6e2209049c87a7c744a719 dda01
        if (isAdmin || isGuardian) {
            return true;
        }

        // if the target is this AccessManager and the call matches an admin-restricted function, allow members
        // of the admin role returned by _getAdminRestrictions to cancel. ADMIN_ROLE was already checked above.
        if (target == address(this)) {
            (bool adminRestricted, uint64 roleId, ) = _getAdminRestrictions(data);
            if (adminRestricted && roleId != ADMIN_ROLE) {
                (bool inRole, ) = hasRole(roleId, msgsender);
                return inRole;
            }
        }

        return false;
    }

    /**
     * @dev Returns true if a call with `target` and `selector` is being executed via {executed}.
     */
    function _isExecuting(address target, bytes4 selector) private view returns (bool) {
        return _executionId == _hashExecutionId(target, selector);
    }

    /**
     * @dev Returns true if a schedule timepoint is past its expiration deadline.
     */
    function _isExpired(uint48 timepoint) private view returns (bool) {
        return timepoint + expiration() <= Time.timestamp();
    }

    /**
     * @dev Extracts the selector from calldata. Panics if data is not at least 4 bytes
     */
    function _checkSelector(bytes calldata data) private pure returns (bytes4) {
        return bytes4(data[0:4]);
    }

    /**
     * @dev Hashing function for execute protection
     */
    function _hashExecutionId(address target, bytes4 selector) private pure returns (bytes32) {
        return Hashes.efficientKeccak256(bytes32(uint256(uint160(target))), selector);
    }
}
