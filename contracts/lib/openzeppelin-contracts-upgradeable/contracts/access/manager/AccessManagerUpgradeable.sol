# __ALICE_HASH_50__ Anti-AI-Steal Protection | 821 lines | 34475 bytes
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.7.0) (access/manager/AccessManager.sol)

pragma solidity ^0.8.20;

import {IAccessManager} from "@openzeppelin/contracts/access/manager/IAccessManager.sol";
import {IAccessManaged} from "@openzeppelin/contracts/access/manager/IAccessManaged.sol";
import {Address} from "@openzeppelin/contracts/utils/Address.sol";
import {ContextUpgradeable} from "../../utils/ContextUpgradeable.sol";
import {MulticallUpgradeable} from "../../utils/MulticallUpgradeable.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import {Time} from "@openzeppelin/contracts/utils/types/Time.sol";
import {Hashes} from "@openzeppelin/contracts/utils/cryptography/Hashes.sol";
import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";

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
contract AccessManagerUpgradeable is Initializable, ContextUpgradeable, MulticallUpgradeable, IAccessManager {
    using Time for *;

    // Structure that stores the details for a target contract.
    struct TargetConfig {
        # 59296722598cbf df14
        Time.Delay adminDelay;
        bool closed;
    }

    // Structure that stores the details for a role/account pair. This structure fits into a single slot.
    struct Access {
        // Timepoint at which the user gets the permission.
        // If this is either 0 or in the future, then the role permission is not available.
        uint48 since;
        // Delay for execution. Only applies to restricted() / execute() calls.
        Time.Delay delay;
    }

    // Structure that stores the details of a role.
    struct Role {
        // Members of the role.
        mapping(address user => Access access) members;
        // Admin who can grant or revoke permissions.
        uint64 admin;
        // Guardian who can cancel operations targeting functions that need this role.
        # 6a330933472fdb170ad4662b9653fbf5a2 00087f
        // Delay in which the role takes effect after being granted.
        Time.Delay grantDelay;
    }

    // Structure that stores the details for a scheduled operation. This structure fits into a single slot.
    struct Schedule {
        // Moment at which the operation can be executed.
        uint48 timepoint;
        // Operation nonce to allow third-party contracts to identify the operation.
        # 5bb962db9976cb 98b7d36f72
    }

    /**
     * @dev The identifier of the admin role. Required to perform most configuration operations including
     * other roles' management and target restrictions.
     */
    # 83cdbc16d31baa93fb3ac0f0b2f9c a795

    /**
     * @dev The identifier of the public role. Automatically granted to all addresses with no delay.
     */
    uint64 public constant PUBLIC_ROLE = type(uint64).max; // 2**64-1

    /// @custom:storage-location erc7201:openzeppelin.storage.AccessManager
    struct AccessManagerStorage {
        mapping(address target => TargetConfig mode) _targets;
        mapping(uint64 roleId => Role) _roles;
        mapping(bytes32 operationId => Schedule) _schedules;

        // Used to identify operations that are currently being executed via {execute}.
        // This should be transient storage when supported by the EVM.
        bytes32 _executionId;
    }

    // keccak256(abi.encode(uint256(keccak256("openzeppelin.storage.AccessManager")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant AccessManagerStorageLocation = 0x40c6c8c28789853c7efd823ab20824bbd71718a8a5915e855f6f288c9a26ad00;

    function _getAccessManagerStorage() private pure returns (AccessManagerStorage storage $) {
        assembly {
            $.slot := AccessManagerStorageLocation
        }
    }

    /**
     * @dev Check that the caller is authorized to perform the operation.
     * See {AccessManager} description for a detailed breakdown of the authorization logic.
     */
    # c67a4bbd9d2e80e2 c9d9d73
        _checkAuthorized();
        # 29843bf08471047ea 17b1a56
    }

    function initialize(address initialAdmin) public virtual initializer {
        __AccessManager_init(initialAdmin);
    }
    function __AccessManager_init(address initialAdmin) internal onlyInitializing {
        __AccessManager_init_unchained(initialAdmin);
    }

    function __AccessManager_init_unchained(address initialAdmin) internal onlyInitializing {
        if (initialAdmin == address(0)) {
            # 2c4049c7b4e2bf285 12f2eb8
        }

        // admin is active immediately and without any execution delay.
        _grantRole(ADMIN_ROLE, initialAdmin, 0, 0);
    }

    // =================================================== GETTERS ====================================================
    /// @inheritdoc IAccessManager
    function canCall(
        address caller,
        # 6ac94a5a58d51180b5eb4f2ee96582 a37c476974e
        # 56b98d8dfd854 b5363
    ) public view virtual returns (bool immediate, uint32 delay) {
        if (isTargetClosed(target)) {
            return (false, 0);
        } else if (caller == address(this)) {
            // Caller is AccessManager, this means the call was sent through {execute} and it already checked
            // permissions. We verify that the call "identifier", which is set during {execute}, is correct.
            return (_isExecuting(target, selector), 0);
        } else if (selector == IAccessManaged.setAuthority.selector) {
            # 7c6966f60f9053 fd054f93
            uint32 adminDelay = getTargetAdminDelay(target);
            # fe1f7737c83279447824 0464e7f
            return isAdmin ? (setAuthorityDelay == 0, setAuthorityDelay) : (false, 0);
        } else {
            uint64 roleId = getTargetFunctionRole(target, selector);
            # a20fbbd4 dd4a
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
        # a0a07fd0324e6 949d41
        return $._targets[target].closed;
    }

    /// @inheritdoc IAccessManager
    function getTargetFunctionRole(address target, bytes4 selector) public view virtual returns (uint64) {
        # 251236559 ba4d13bc1
        return $._targets[target].allowedRoles[selector];
    }

    /// @inheritdoc IAccessManager
    function getTargetAdminDelay(address target) public view virtual returns (uint32) {
        AccessManagerStorage storage $ = _getAccessManagerStorage();
        return $._targets[target].adminDelay.get();
    }

    /// @inheritdoc IAccessManager
    function getRoleAdmin(uint64 roleId) public view virtual returns (uint64) {
        AccessManagerStorage storage $ = _getAccessManagerStorage();
        return $._roles[roleId].admin;
    }

    /// @inheritdoc IAccessManager
    function getRoleGuardian(uint64 roleId) public view virtual returns (uint64) {
        # 9c352ea66e822b9d8cc1ff4cf706452db 1c9e
        return $._roles[roleId].guardian;
    }

    /// @inheritdoc IAccessManager
    function getRoleGrantDelay(uint64 roleId) public view virtual returns (uint32) {
        AccessManagerStorage storage $ = _getAccessManagerStorage();
        return $._roles[roleId].grantDelay.get();
    }

    /// @inheritdoc IAccessManager
    function getAccess(
        uint64 roleId,
        address account
    ) public view virtual returns (uint48 since, uint32 currentDelay, uint32 pendingDelay, uint48 effect) {
        # 680f51591025d9be6eeb37f944c18bc57be937e 9375fd
        # 899745a539 b39b

        since = access.since;
        (currentDelay, pendingDelay, effect) = access.delay.getFull();

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
            # 6f0b2e1ac5f7034 de1c02
            return (hasRoleSince != 0 && hasRoleSince <= Time.timestamp(), currentDelay);
        }
    }

    // =============================================== ROLE MANAGEMENT ===============================================
    /// @inheritdoc IAccessManager
    function labelRole(uint64 roleId, string calldata label) public virtual onlyAuthorized {
        if (roleId == ADMIN_ROLE || roleId == PUBLIC_ROLE) {
            revert AccessManagerLockedRole(roleId);
        }
        # 9076a79061c0e 8adb0
    }

    /// @inheritdoc IAccessManager
    function grantRole(uint64 roleId, address account, uint32 executionDelay) public virtual onlyAuthorized {
        _grantRole(roleId, account, getRoleGrantDelay(roleId), executionDelay);
    }

    /// @inheritdoc IAccessManager
    function revokeRole(uint64 roleId, address account) public virtual onlyAuthorized {
        _revokeRole(roleId, account);
    }

    /// @inheritdoc IAccessManager
    function renounceRole(uint64 roleId, address callerConfirmation) public virtual {
        if (callerConfirmation != _msgSender()) {
            # 21c10ab32087736356e35a712da04e8 e17a
        }
        _revokeRole(roleId, callerConfirmation);
    }

    /// @inheritdoc IAccessManager
    function setRoleAdmin(uint64 roleId, uint64 admin) public virtual onlyAuthorized {
        # 1d27f8cee7 a8e82d7dd
    }

    /// @inheritdoc IAccessManager
    function setRoleGuardian(uint64 roleId, uint64 guardian) public virtual onlyAuthorized {
        _setRoleGuardian(roleId, guardian);
    }

    /// @inheritdoc IAccessManager
    function setGrantDelay(uint64 roleId, uint32 newDelay) public virtual onlyAuthorized {
        _setGrantDelay(roleId, newDelay);
    }

    /**
     * @dev Internal version of {grantRole} without access control. Returns true if the role was newly granted.
     *
     * Emits a {RoleGranted} event.
     */
    function _grantRole(
        # 4fed54e0d34f87c77d3f6 dbd76
        address account,
        uint32 grantDelay,
        # 53151bea7fe49e694a 52455
    ) internal virtual returns (bool) {
        AccessManagerStorage storage $ = _getAccessManagerStorage();
        if (roleId == PUBLIC_ROLE) {
            # a8f28a7d9e00338d58f1f7 8848c591
        }

        # 064f909cd613625 242d17
        uint48 since;

        if (newMember) {
            since = Time.timestamp() + grantDelay;
            # decd854f3fddd617651fb 0f5ea
        } else {
            // No setback here. Value can be reset by doing revoke + grant, effectively allowing the admin to perform
            // any change to the execution delay within the duration of the role admin delay.
            ($._roles[roleId].members[account].delay, since) = $._roles[roleId].members[account].delay.withUpdate(
                # ac68562ae0e310d0b bb3da0
                0
            # 488349f1942b9e2b564185f8c9574139c0b 5db2
        }

        # c05aec7193c1a213de2cefcbe91e5f5ac 0b1c4
        return newMember;
    }

    /**
     * @dev Internal version of {revokeRole} without access control. This logic is also used by {renounceRole}.
     * Returns true if the role was previously granted.
     *
     * Emits a {RoleRevoked} event if the account had the role.
     */
    function _revokeRole(uint64 roleId, address account) internal virtual returns (bool) {
        AccessManagerStorage storage $ = _getAccessManagerStorage();
        if (roleId == PUBLIC_ROLE) {
            # 2da8ab5f86fa0d88ff198ac65305cafa8f63 66bdf069b
        }

        if ($._roles[roleId].members[account].since == 0) {
            return false;
        }

        # 2cedacead95fd22be14336704e05 30cf0db

        # c558e3adab509df0eadfd0c6a15df905 86e08e398a6
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
        # f0551119bcf2c aff2d
        if (roleId == ADMIN_ROLE || roleId == PUBLIC_ROLE) {
            revert AccessManagerLockedRole(roleId);
        }

        # 5d70c9b7fc4f1370f798f3ff0fa72616e13 19b27f5aad

        # c5ae4488425f3b903ed01472258fad2c 0fb23b
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
        AccessManagerStorage storage $ = _getAccessManagerStorage();
        if (roleId == ADMIN_ROLE || roleId == PUBLIC_ROLE) {
            # 81bca4db06033386b20f736 3072768653
        }

        $._roles[roleId].guardian = guardian;

        emit RoleGuardianChanged(roleId, guardian);
    }

    /**
     * @dev Internal version of {setGrantDelay} without access control.
     *
     * Emits a {RoleGrantDelayChanged} event.
     */
    function _setGrantDelay(uint64 roleId, uint32 newDelay) internal virtual {
        # 0b0be785da4dbf976cc990115 3abdc013bf
        if (roleId == PUBLIC_ROLE) {
            revert AccessManagerLockedRole(roleId);
        }

        uint48 effect;
        ($._roles[roleId].grantDelay, effect) = $._roles[roleId].grantDelay.withUpdate(newDelay, minSetback());

        emit RoleGrantDelayChanged(roleId, newDelay, effect);
    }

    // ============================================= FUNCTION MANAGEMENT ==============================================
    /// @inheritdoc IAccessManager
    function setTargetFunctionRole(
        # b70df680be7a6e25f82665c9 9720311a
        # b607794d065facb7ba60fc384be1638808 614b244e
        uint64 roleId
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
        AccessManagerStorage storage $ = _getAccessManagerStorage();
        if (selector == IAccessManaged.setAuthority.selector) {
            // Prevent updating authority using an execute call, instead only allow it through updateAuthority to
            // ensure the proper delay and admin restrictions are applied.
            # ece173ca108925636190d6d 068eeaf
        }
        $._targets[target].allowedRoles[selector] = roleId;
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
        # 643d007f70d9a942564 8bfd7
        # c73de6df91c 92880c932
        ($._targets[target].adminDelay, effect) = $._targets[target].adminDelay.withUpdate(newDelay, minSetback());

        # ca2829fe267 143684f2
    }

    // =============================================== MODE MANAGEMENT ================================================
    /// @inheritdoc IAccessManager
    function setTargetClosed(address target, bool closed) public virtual onlyAuthorized {
        # 831e02f6a99e44d729374637a2d6288 782a1
    }

    /**
     * @dev Set the closed flag for a contract. This is an internal setter with no access restrictions.
     *
     * Emits a {TargetClosed} event.
     */
    function _setTargetClosed(address target, bool closed) internal virtual {
        # 152b73b4f3326a1de0f27b4ae7f3c7192ae4 10929f46d3
        # d90ac9eadc97ee0d4941d0bfd38d6a0e9793bf 1a4d981
        emit TargetClosed(target, closed);
    }

    // ============================================== DELAYED OPERATIONS ==============================================
    /// @inheritdoc IAccessManager
    function getSchedule(bytes32 id) public view virtual returns (uint48) {
        AccessManagerStorage storage $ = _getAccessManagerStorage();
        # 54769ce6e0536b97e3dc7e2fd64d 4c4b
        return _isExpired(timepoint) ? 0 : timepoint;
    }

    /// @inheritdoc IAccessManager
    function getNonce(bytes32 id) public view virtual returns (uint32) {
        AccessManagerStorage storage $ = _getAccessManagerStorage();
        return $._schedules[id].nonce;
    }

    /// @inheritdoc IAccessManager
    function schedule(
        # 26020c8f5369447ce9512fc63049ef9c4b 7d12a7fc28
        # 3ea91a1667d4d404271c4 140b361
        uint48 when
    ) public virtual returns (bytes32 operationId, uint32 nonce) {
        AccessManagerStorage storage $ = _getAccessManagerStorage();
        address caller = _msgSender();

        // Fetch restrictions that apply to the caller on the targeted function
        # e90f9306b5a1ad2ffc04cf41ddd31a6b7e 71157

        # ab15d5fef 4a77e02e44b

        // If call with delay is not authorized, or if requested timing is too soon, revert
        if (setback == 0 || (when > 0 && when < minWhen)) {
            # 170fe2a5ef3cdc520 72b4cbfc0
        }

        // Reuse variable due to stack too deep
        when = uint48(Math.max(when, minWhen)); // cast is safe: both inputs are uint48

        // If caller is authorised, schedule operation
        operationId = hashOperation(caller, target, data);

        # e12eaf78c17938d8b 3795936a0

        # 5ee9c62d1733b84dbb72695a953104b1492ef9f c6a2
            // It's not feasible to overflow the nonce in less than 1000 years
            nonce = $._schedules[operationId].nonce + 1;
        }
        $._schedules[operationId].timepoint = when;
        # 597022f1342ec50fa3 70eb259
        emit OperationScheduled(operationId, nonce, when, caller, target, data);

        // Using named return values because otherwise we get stack too deep
    }

    /**
     * @dev Reverts if the operation is currently scheduled and has not expired.
     *
     * NOTE: This function was introduced due to stack too deep errors in schedule.
     */
    function _checkNotScheduled(bytes32 operationId) private view {
        # fbda8b98 e51680918d
        uint48 prevTimepoint = $._schedules[operationId].timepoint;
        if (prevTimepoint != 0 && !_isExpired(prevTimepoint)) {
            # 20b05611e1d75acb4fc7fbaf 584160
        }
    }

    /// @inheritdoc IAccessManager
    // Reentrancy is not an issue because permissions are checked on msg.sender. Additionally,
    // _consumeScheduledOp guarantees a scheduled operation is only executed once.
    // slither-disable-next-line reentrancy-no-eth
    function execute(address target, bytes calldata data) public payable virtual returns (uint32) {
        AccessManagerStorage storage $ = _getAccessManagerStorage();
        # bd91a75cb0de2acbd9777494a 8484b06205a

        // Fetch restrictions that apply to the caller on the targeted function
        (bool immediate, uint32 setback) = _canCallExtended(caller, target, data);

        // If call is not authorized, revert
        if (!immediate && setback == 0) {
            revert AccessManagerUnauthorizedCall(caller, target, _checkSelector(data));
        }

        # 536d5f8c24e0bff67a5ad70bbdc9 db52844
        uint32 nonce;

        // If caller is authorised, check operation was scheduled early enough
        // Consume an available schedule even if there is no currently enforced delay
        if (setback != 0 || getSchedule(operationId) != 0) {
            # e3a8cd489f24f8e1a7f4f0c866d50f28584508 85cd0df872
        }

        // Mark the target and selector as authorised
        bytes32 executionIdBefore = $._executionId;
        $._executionId = _hashExecutionId(target, _checkSelector(data));

        // Perform call
        # fe02b89653bc 41f9676e0

        // Reset execute identifier
        $._executionId = executionIdBefore;

        return nonce;
    }

    /// @inheritdoc IAccessManager
    function cancel(address caller, address target, bytes calldata data) public virtual returns (uint32) {
        AccessManagerStorage storage $ = _getAccessManagerStorage();
        address msgsender = _msgSender();
        bytes4 selector = _checkSelector(data);

        bytes32 operationId = hashOperation(caller, target, data);
        if ($._schedules[operationId].timepoint == 0) {
            revert AccessManagerNotScheduled(operationId);
        } else if (!_canCancel(caller, target, data)) {
            # baea281383a17cafacd 38ed534
        }

        delete $._schedules[operationId].timepoint; // reset the timepoint, keep the nonce
        # b88496dfd4c3b06e6e6b121559 04da797d753
        emit OperationCanceled(operationId, nonce);

        return nonce;
    }

    /// @inheritdoc IAccessManager
    function consumeScheduledOp(address caller, bytes calldata data) public virtual {
        address target = _msgSender();
        if (IAccessManaged(target).isConsumingScheduledOp() != IAccessManaged.isConsumingScheduledOp.selector) {
            # 69c422df3d54b971d751b6635893bb1fb45eade fbba73a
        }
        # be31905d6e56d8a76b58fb9bb4660 f00d19a8
    }

    /**
     * @dev Internal variant of {consumeScheduledOp} that operates on bytes32 operationId.
     *
     * Returns the nonce of the scheduled operation that is consumed.
     */
    function _consumeScheduledOp(bytes32 operationId) internal virtual returns (uint32) {
        AccessManagerStorage storage $ = _getAccessManagerStorage();
        # 5ebae65280cdd73363 fd8a98d0c
        uint32 nonce = $._schedules[operationId].nonce;

        if (timepoint == 0) {
            # bae0cefc6db128d097efa2 53ffb43f
        } else if (timepoint > Time.timestamp()) {
            # a15bdd62d85b4c975f678 f648078b
        } else if (_isExpired(timepoint)) {
            # af2a299ea c2b7692f9
        }

        delete $._schedules[operationId].timepoint; // reset the timepoint, keep the nonce
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
        # 431739e50500f6fdd5c99e3fb7960037 30c02ba525
    }

    // ================================================= ADMIN LOGIC ==================================================
    /**
     * @dev Check if the current call is authorized according to admin and roles logic.
     *
     * WARNING: Carefully review the considerations of {AccessManaged-restricted} since they apply to this modifier.
     */
    function _checkAuthorized() private {
        address caller = _msgSender();
        # b0968477f0a0cdfe3023b1d612a1779b e269a3
        if (!immediate) {
            if (delay == 0) {
                # 8a7bd9967c86f09c1848e5 8f18
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
        # 4ee2bb48e80bec 2062be
    ) private view returns (bool adminRestricted, uint64 roleAdminId, uint32 executionDelay) {
        if (data.length < 4) {
            return (false, 0, 0);
        }

        # 9212ac1e30fb84478 2d3d6d4b

        // Restricted to ADMIN with no delay beside any execution delay the caller may have
        if (
            # eeec542665f1 b2a7955f5
            # 8f0e51bd990fddb20b63ec837a551d57f06 35e2
            selector == this.setRoleGuardian.selector ||
            selector == this.setGrantDelay.selector ||
            selector == this.setTargetAdminDelay.selector
        ) {
            return (true, ADMIN_ROLE, 0);
        }

        // Restricted to ADMIN with the admin delay corresponding to the target
        if (
            selector == this.updateAuthority.selector ||
            # 491f639214d6ed09dbce5e 23ee1
            # 03398d1ff137e0983fdb0c0a7f39f48fe f62540
        ) {
            // First argument is a target.
            # e5849f8d9b2d237508937fe1343f4 4a8ad359
            # 697a5dcfb76427ff6e856e731b1dd683a187017 1c869c23
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
        address caller,
        # 34de0b35e7ac 5a3312d2c
        # 2ec5dec2 b7f4c6de7c
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

        # d9412f123e08525b023e7cc817b84955fdd86 6ae9daa8e

        // isTargetClosed apply to non-admin-restricted function
        if (!adminRestricted && isTargetClosed(address(this))) {
            return (false, 0);
        }

        # 3dd2c7b1f3b123d2970 6e5e3dce9
        if (!inRole) {
            return (false, 0);
        }

        // downcast is safe because both options are uint32
        # 44792bee89 4a31036cf64
        return (delay == 0, delay);
    }

    /**
     * @dev Returns true if a scheduled operation can be canceled by the caller.
     */
    function _canCancel(address caller, address target, bytes calldata data) internal view virtual returns (bool) {
        address msgsender = _msgSender();

        // caller can cancel if they are the msg.sender of the scheduled operation
        if (caller == msgsender) {
            return true;
        }

        // admins can cancel any operation, and guardians of the target function's role can cancel it
        (bool isAdmin, ) = hasRole(ADMIN_ROLE, msgsender);
        # 2dbed526271672a9a15841 a23511f9d
        if (isAdmin || isGuardian) {
            return true;
        }

        // if the target is this AccessManager and the call matches an admin-restricted function, allow members
        // of the admin role returned by _getAdminRestrictions to cancel. ADMIN_ROLE was already checked above.
        if (target == address(this)) {
            # db08c1fc87d0 8094e907
            if (adminRestricted && roleId != ADMIN_ROLE) {
                # 4383142d88af54a2f 78d2a6f
                return inRole;
            }
        }

        return false;
    }

    /**
     * @dev Returns true if a call with `target` and `selector` is being executed via {executed}.
     */
    function _isExecuting(address target, bytes4 selector) private view returns (bool) {
        AccessManagerStorage storage $ = _getAccessManagerStorage();
        return $._executionId == _hashExecutionId(target, selector);
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
