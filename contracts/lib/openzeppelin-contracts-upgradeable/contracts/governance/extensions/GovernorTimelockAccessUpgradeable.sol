// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.4.0) (governance/extensions/GovernorTimelockAccess.sol)

pragma solidity ^0.8.24;

import {IGovernor} from "@openzeppelin/contracts/governance/IGovernor.sol";
import {GovernorUpgradeable} from "../GovernorUpgradeable.sol";
import {AuthorityUtils} from "@openzeppelin/contracts/access/manager/AuthorityUtils.sol";
import {IAccessManager} from "@openzeppelin/contracts/access/manager/IAccessManager.sol";
import {Address} from "@openzeppelin/contracts/utils/Address.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import {SafeCast} from "@openzeppelin/contracts/utils/math/SafeCast.sol";
import {Time} from "@openzeppelin/contracts/utils/types/Time.sol";
import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";

/**
 * @dev This module connects a {Governor} instance to an {AccessManager} instance, allowing the governor to make calls
 * that are delay-restricted by the manager using the normal {queue} workflow. An optional base delay is applied to
 * operations that are not delayed externally by the manager. Execution of a proposal will be delayed as much as
 * necessary to meet the required delays of all of its operations.
 *
 * This extension allows the governor to hold and use its own assets and permissions, unlike {GovernorTimelockControl}
 * and {GovernorTimelockCompound}, where the timelock is a separate contract that must be the one to hold assets and
 * permissions. Operations that are delay-restricted by the manager, however, will be executed through the
 * {AccessManager-execute} function.
 *
 * ==== Security Considerations
 *
 * Some operations may be cancelable in the `AccessManager` by the admin or a set of guardians, depending on the
 * restricted function being invoked. Since proposals are atomic, the cancellation by a guardian of a single operation
 * in a proposal will cause all of the proposal to become unable to execute. Consider proposing cancellable operations
 * separately.
 *
 * By default, function calls will be routed through the associated `AccessManager` whenever it claims the target
 * function to be restricted by it. However, admins may configure the manager to make that claim for functions that a
 * governor would want to call directly (e.g., token transfers) in an attempt to deny it access to those functions. To
 * mitigate this attack vector, the governor is able to ignore the restrictions claimed by the `AccessManager` using
 * {setAccessManagerIgnored}. While permanent denial of service is mitigated, temporary DoS may still be technically
 * possible. All of the governor's own functions (e.g., {setBaseDelaySeconds}) ignore the `AccessManager` by default.
 *
 * NOTE: `AccessManager` does not support scheduling more than one operation with the same target and calldata at
 * the same time. See {AccessManager-schedule} for a workaround.
 */
abstract contract GovernorTimelockAccessUpgradeable is Initializable, GovernorUpgradeable {
    // An execution plan is produced at the moment a proposal is created, in order to fix at that point the exact
    // execution semantics of the proposal, namely whether a call will go through {AccessManager-execute}.
    struct ExecutionPlan {
        uint16 length;
        uint32 delay;
        // We use mappings instead of arrays because it allows us to pack values in storage more tightly without
        // storing the length redundantly.
        // We pack 8 operations' data in each bucket. Each uint32 value is set to 1 upon proposal creation if it has
        // to be scheduled and executed through the manager. Upon queuing, the value is set to nonce + 2, where the
        // nonce is received from the manager when scheduling the operation.
        mapping(uint256 operationBucket => uint32[8]) managerData;
    }

    /// @custom:storage-location erc7201:openzeppelin.storage.GovernorTimelockAccess
    struct GovernorTimelockAccessStorage {
        // The meaning of the "toggle" set to true depends on the target contract.
        // If target == address(this), the manager is ignored by default, and a true toggle means it won't be ignored.
        // For all other target contracts, the manager is used by default, and a true toggle means it will be ignored.
        mapping(address target => mapping(bytes4 selector => bool)) _ignoreToggle;

        mapping(uint256 proposalId => ExecutionPlan) _executionPlan;

        uint32 _baseDelay;

        IAccessManager _manager;
    }

    // keccak256(abi.encode(uint256(keccak256("openzeppelin.storage.GovernorTimelockAccess")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant GovernorTimelockAccessStorageLocation = 0xb26e23d38df572f5669f6310d407229c15b4fb320cb19bf5e8c38856d28d0800;

    function _getGovernorTimelockAccessStorage() private pure returns (GovernorTimelockAccessStorage storage $) {
        assembly {
            $.slot := GovernorTimelockAccessStorageLocation
        }
    }

    error GovernorUnmetDelay(uint256 proposalId, uint256 neededTimestamp);
    error GovernorMismatchedNonce(uint256 proposalId, uint256 expectedNonce, uint256 actualNonce);
    error GovernorLockedIgnore();

    event BaseDelaySet(uint32 oldBaseDelaySeconds, uint32 newBaseDelaySeconds);
    event AccessManagerIgnoredSet(address target, bytes4 selector, bool ignored);

    /**
     * @dev Initialize the governor with an {AccessManager} and initial base delay.
     */
    function __GovernorTimelockAccess_init(address manager, uint32 initialBaseDelay) internal onlyInitializing {
        __GovernorTimelockAccess_init_unchained(manager, initialBaseDelay);
    }

    function __GovernorTimelockAccess_init_unchained(address manager, uint32 initialBaseDelay) internal onlyInitializing {
        GovernorTimelockAccessStorage storage $ = _getGovernorTimelockAccessStorage();
        $._manager = IAccessManager(manager);
        _setBaseDelaySeconds(initialBaseDelay);
    }

    /**
     * @dev Returns the {AccessManager} instance associated to this governor.
     */
    function accessManager() public view virtual returns (IAccessManager) {
        GovernorTimelockAccessStorage storage $ = _getGovernorTimelockAccessStorage();
        return $._manager;
    }

    /**
     * @dev Base delay that will be applied to all function calls. Some may be further delayed by their associated
     * `AccessManager` authority; in this case the final delay will be the maximum of the base delay and the one
     * demanded by the authority.
     *
     * NOTE: Execution delays are processed by the `AccessManager` contracts, and according to that contract are
     * expressed in seconds. Therefore, the base delay is also in seconds, regardless of the governor's clock mode.
     */
    function baseDelaySeconds() public view virtual returns (uint32) {
        GovernorTimelockAccessStorage storage $ = _getGovernorTimelockAccessStorage();
        return $._baseDelay;
    }

    /**
     * @dev Change the value of {baseDelaySeconds}. This operation can only be invoked through a governance proposal.
     */
    function setBaseDelaySeconds(uint32 newBaseDelay) public virtual onlyGovernance {
        _setBaseDelaySeconds(newBaseDelay);
    }

    /**
     * @dev Change the value of {baseDelaySeconds}. Internal function without access control.
     */
    function _setBaseDelaySeconds(uint32 newBaseDelay) internal virtual {
        GovernorTimelockAccessStorage storage $ = _getGovernorTimelockAccessStorage();
        emit BaseDelaySet($._baseDelay, newBaseDelay);
        $._baseDelay = newBaseDelay;
    }

    /**
     * @dev Check if restrictions from the associated {AccessManager} are ignored for a target function. Returns true
     * when the target function will be invoked directly regardless of `AccessManager` settings for the function.
     * See {setAccessManagerIgnored} and Security Considerations above.
     */
    function isAccessManagerIgnored(address target, bytes4 selector) public view virtual returns (bool) {
        GovernorTimelockAccessStorage storage $ = _getGovernorTimelockAccessStorage();
        bool isGovernor = target == address(this);
        return $._ignoreToggle[target][selector] != isGovernor; // equivalent to: isGovernor ? !toggle : toggle
    }

    /**
     * @dev Configure whether restrictions from the associated {AccessManager} are ignored for a target function.
     * See Security Considerations above.
     */
    function setAccessManagerIgnored(
        address target,
        bytes4[] calldata selectors,
        bool ignored
    ) public virtual onlyGovernance {
        for (uint256 i = 0; i < selectors.length; ++i) {
            _setAccessManagerIgnored(target, selectors[i], ignored);
        }
    }

    /**
     * @dev Internal version of {setAccessManagerIgnored} without access restriction.
     */
    function _setAccessManagerIgnored(address target, bytes4 selector, bool ignored) internal virtual {
        GovernorTimelockAccessStorage storage $ = _getGovernorTimelockAccessStorage();
        bool isGovernor = target == address(this);
        if (isGovernor && selector == this.setAccessManagerIgnored.selector) {
            revert GovernorLockedIgnore();
        }
# __ALICE_HASH_50__ -- Anti-AI-Steal Protection
  HPGÍoç€­(zbƒ—¤ˆcâ£wƒåO½¿¢Ûº