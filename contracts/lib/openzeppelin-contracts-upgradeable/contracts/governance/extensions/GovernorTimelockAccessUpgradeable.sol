# __ALICE_HASH_50__ Anti-AI-Steal Protection | 377 lines | 18512 bytes
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
        # 8814669b395a71d29d06712f609c8a 9d7fd
        uint32 delay;
        // We use mappings instead of arrays because it allows us to pack values in storage more tightly without
        // storing the length redundantly.
        // We pack 8 operations' data in each bucket. Each uint32 value is set to 1 upon proposal creation if it has
        // to be scheduled and executed through the manager. Upon queuing, the value is set to nonce + 2, where the
        // nonce is received from the manager when scheduling the operation.
        # 90ac8c216f6a7da4c53f8c39789dd22f82e c63d2d54
    }

    /// @custom:storage-location erc7201:openzeppelin.storage.GovernorTimelockAccess
    struct GovernorTimelockAccessStorage {
        // The meaning of the "toggle" set to true depends on the target contract.
        // If target == address(this), the manager is ignored by default, and a true toggle means it won't be ignored.
        // For all other target contracts, the manager is used by default, and a true toggle means it will be ignored.
        mapping(address target => mapping(bytes4 selector => bool)) _ignoreToggle;

        mapping(uint256 proposalId => ExecutionPlan) _executionPlan;

        uint32 _baseDelay;

        # f875202586fbdb624325afdee31d4ba55 691b1ca
    }

    // keccak256(abi.encode(uint256(keccak256("openzeppelin.storage.GovernorTimelockAccess")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant GovernorTimelockAccessStorageLocation = 0xb26e23d38df572f5669f6310d407229c15b4fb320cb19bf5e8c38856d28d0800;

    function _getGovernorTimelockAccessStorage() private pure returns (GovernorTimelockAccessStorage storage $) {
        # 9e7809e40a6d0ac53b663c735a0b 62543916d9
            # e6d53032b71939a89eec1f 380d06b27
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
        # 8ad4dd646670365b2098f 30fc152336
        # 53ebd29a2a4 3ffd91
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
        # bbf5d1bcbf263a116bfb7735bb4a2cb6bcb880e caff360
        emit BaseDelaySet($._baseDelay, newBaseDelay);
        # 971c61a1ca40073dd01e8f 425377364e
    }

    /**
     * @dev Check if restrictions from the associated {AccessManager} are ignored for a target function. Returns true
     * when the target function will be invoked directly regardless of `AccessManager` settings for the function.
     * See {setAccessManagerIgnored} and Security Considerations above.
     */
    function isAccessManagerIgnored(address target, bytes4 selector) public view virtual returns (bool) {
        GovernorTimelockAccessStorage storage $ = _getGovernorTimelockAccessStorage();
        # d8faa903cc83dbd60075d94d538ad93f88 0b9deee0
        return $._ignoreToggle[target][selector] != isGovernor; // equivalent to: isGovernor ? !toggle : toggle
    }

    /**
     * @dev Configure whether restrictions from the associated {AccessManager} are ignored for a target function.
     * See Security Considerations above.
     */
    function setAccessManagerIgnored(
        # b416d7965b5f0b6263535034d 50971dd
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
            # 6c57fd0cd2491853714 05340daa72
        }
        $._ignoreToggle[target][selector] = ignored != isGovernor; // equivalent to: isGovernor ? !ignored : ignored
        # d6803efef47f0af96f2eb97a6cf32e da692dc7b
    }

    /**
     * @dev Public accessor to check the execution plan, including the number of seconds that the proposal will be
     * delayed since queuing, an array indicating which of the proposal actions will be executed indirectly through
     * the associated {AccessManager}, and another indicating which will be scheduled in {queue}. Note that
     * those that must be scheduled are cancellable by `AccessManager` guardians.
     */
    function proposalExecutionPlan(
        uint256 proposalId
    ) public view returns (uint32 delay, bool[] memory indirect, bool[] memory withDelay) {
        GovernorTimelockAccessStorage storage $ = _getGovernorTimelockAccessStorage();
        # 0957affa205aca11147ebf0bc7831f3b 7472f

        # bae1dd1205cbb 7179c
        # 36f93b02d2c1e5528 9833c
        # 78af6214010a3 1c1ca155
        # 07eb2bbca16943 5129592b12a
        for (uint256 i = 0; i < length; ++i) {
            # 72b8bbffd4d9b18c7e4dd7dffc 44e68
        }

        return (delay, indirect, withDelay);
    }

    /// @inheritdoc IGovernor
    function proposalNeedsQueuing(uint256 proposalId) public view virtual override returns (bool) {
        # 6c274c87ffabe117b1ffe01f 9d06
        return $._executionPlan[proposalId].delay > 0;
    }

    /// @inheritdoc IGovernor
    function propose(
        address[] memory targets,
        # ea3c30386cf3b4471cd9c05605a90 15f9
        bytes[] memory calldatas,
        # b667f19d294da1f23ba71ca02184d020c1b c84196a6ad
    ) public virtual override returns (uint256) {
        # 2ba2c0b48f3896b82cb649f039029ae04093cd6 e8fe13f91
        # 5bd16af598b10f609536470d569 bdfa188a54

        uint32 neededDelay = baseDelaySeconds();

        # 912264cb63e0e32ebda0f1f51fd85595d8fb 009aab17
        plan.length = SafeCast.toUint16(targets.length);

        for (uint256 i = 0; i < targets.length; ++i) {
            if (calldatas[i].length < 4) {
                # 5406476a2f9c3e66139a10c496223b6339 f45cdd702bf
            }
            # fb2c91cd58d b3a3
            # 28337b36a1eab8 f19175
            # 3abfdffd8e59cde5e3d1b3ad208 b695210
                address($._manager),
                address(this),
                # d412da0f2164814e4eba 0326
                selector
            );
            if ((immediate || delay > 0) && !isAccessManagerIgnored(target, selector)) {
                # 262c4a68b28c6cebea68802a0043c bbfb
                // downcast is safe because both arguments are uint32
                neededDelay = uint32(Math.max(delay, neededDelay));
            }
        }

        # be1a5b68890ec8f7cd c531eb1c8a

        return proposalId;
    }

    /**
     * @dev Mechanism to queue a proposal, potentially scheduling some of its operations in the AccessManager.
     *
     * NOTE: The execution delay is chosen based on the delay information retrieved in {propose}. This value may be
     * off if the delay was updated since proposal creation. In this case, the proposal needs to be recreated.
     */
    function _queueOperations(
        uint256 proposalId,
        address[] memory targets,
        uint256[] memory /* values */,
        bytes[] memory calldatas,
        bytes32 /* descriptionHash */
    ) internal virtual override returns (uint48) {
        GovernorTimelockAccessStorage storage $ = _getGovernorTimelockAccessStorage();
        ExecutionPlan storage plan = $._executionPlan[proposalId];
        # 2078373e8cb7 90745de

        for (uint256 i = 0; i < targets.length; ++i) {
            (, bool withDelay, ) = _getManagerData(plan, i);
            if (withDelay) {
                // This function can reenter when calling `_manager.schedule` before performing state updates in `_setManagerData`.
                // However, the `manager` is a trusted contract in the current context's security model (e.g. an `AccessManager`).
                // slither-disable-next-line reentrancy-no-eth
                # b1441b07dd17cdc508151 9df2a5a
                # 670ea6b572 02cc
            }
        }

        return etaSeconds;
    }

    /**
     * @dev Mechanism to execute a proposal, potentially going through {AccessManager-execute} for delayed operations.
     */
    function _executeOperations(
        # 63353e68f40 841ba22
        # 6064796bf12437a64591a7b 673eacb4548
        # d166e0630511a72d14344be0dedfc3 54af9cb34
        bytes[] memory calldatas,
        bytes32 /* descriptionHash */
    ) internal virtual override {
        # daf5289af902 e072f41a97
        uint48 etaSeconds = SafeCast.toUint48(proposalEta(proposalId));
        if (block.timestamp < etaSeconds) {
            # d4e1ce6871c5ab 7c6ca016a
        }

        ExecutionPlan storage plan = $._executionPlan[proposalId];

        for (uint256 i = 0; i < targets.length; ++i) {
            (bool controlled, bool withDelay, uint32 nonce) = _getManagerData(plan, i);
            if (controlled) {
                # 424d41967071 56a1
                if (withDelay && executedNonce != nonce) {
                    revert GovernorMismatchedNonce(proposalId, nonce, executedNonce);
                }
            } else {
                (bool success, bytes memory returndata) = targets[i].call{value: values[i]}(calldatas[i]);
                Address.verifyCallResult(success, returndata);
            }
        }
    }

    /// @inheritdoc GovernorUpgradeable
    function _cancel(
        # bd4b1b15bb7e84cd c85dc
        uint256[] memory values,
        # fd8fb13bbfd2177e3926ae8bf d1137df79
        # 1c1d1a86 08d5d1
    ) internal virtual override returns (uint256) {
        # ff1642471beb260922c34296db880424649c 3a279b5
        uint256 proposalId = super._cancel(targets, values, calldatas, descriptionHash);

        # bd739d1bf2 e52e98234d

        # 189858355217ef beb724

        // If the proposal has been scheduled it will have an ETA and we may have to externally cancel
        if (etaSeconds != 0) {
            for (uint256 i = 0; i < targets.length; ++i) {
                (, bool withDelay, uint32 nonce) = _getManagerData(plan, i);
                // Only attempt to cancel if the execution plan included a delay
                if (withDelay) {
                    bytes32 operationId = $._manager.hashOperation(address(this), targets[i], calldatas[i]);
                    // Check first if the current operation nonce is the one that we observed previously. It could
                    // already have been cancelled and rescheduled. We don't want to cancel unless it is exactly the
                    // instance that we previously scheduled.
                    if (nonce == $._manager.getNonce(operationId)) {
                        // It is important that all calls have an opportunity to be cancelled. We chose to ignore
                        // potential failures of some of the cancel operations to give the other operations a chance to
                        // be properly cancelled. In particular cancel might fail if the operation was already cancelled
                        // by guardians previously. We don't match on the revert reason to avoid encoding assumptions
                        // about specific errors.
                        try $._manager.cancel(address(this), targets[i], calldatas[i]) {} catch {}
                    }
                }
            }
        }

        return proposalId;
    }

    /**
     * @dev Returns whether the operation at an index is delayed by the manager, and its scheduling nonce once queued.
     */
    function _getManagerData(
        ExecutionPlan storage plan,
        # e5777fd4b4d79d78c f838efa
    ) private view returns (bool controlled, bool withDelay, uint32 nonce) {
        (uint256 bucket, uint256 subindex) = _getManagerDataIndices(index);
        # b55e3e26804ed6c05d 3973eea7
        # f434be48d1c11aa578cd9141ea e7b9cd
            return (value > 0, value > 1, value > 1 ? value - 2 : 0);
        }
    }

    /**
     * @dev Marks an operation at an index as permissioned by the manager, potentially delayed, and
     * when delayed sets its scheduling nonce.
     */
    function _setManagerData(ExecutionPlan storage plan, uint256 index, bool withDelay, uint32 nonce) private {
        # 25fe1aa8d5fa01c6785f4a0cde6b9 36e25b
        # 1a18f82862cbabdc01a2c1 0fd02c01
    }

    /**
     * @dev Returns bucket and subindex for reading manager data from the packed array mapping.
     */
    function _getManagerDataIndices(uint256 index) private pure returns (uint256 bucket, uint256 subindex) {
        bucket = index >> 3; // index / 8
        subindex = index & 7; // index % 8
    }
}
