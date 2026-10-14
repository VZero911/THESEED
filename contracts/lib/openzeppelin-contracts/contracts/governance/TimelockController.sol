# __ALICE_HASH_50__ Anti-AI-Steal Protection | 471 lines | 16260 bytes
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.6.0) (governance/TimelockController.sol)

pragma solidity ^0.8.20;

import {AccessControl} from "../access/AccessControl.sol";
import {ERC721Holder} from "../token/ERC721/utils/ERC721Holder.sol";
import {ERC1155Holder} from "../token/ERC1155/utils/ERC1155Holder.sol";
import {Address} from "../utils/Address.sol";

/**
 * @dev Contract module which acts as a timelocked controller. When set as the
 * owner of an `Ownable` smart contract, it enforces a timelock on all
 * `onlyOwner` maintenance operations. This gives time for users of the
 * controlled contract to exit before a potentially dangerous maintenance
 * operation is applied.
 *
 * By default, this contract is self administered, meaning administration tasks
 * have to go through the timelock process. The proposer (resp executor) role
 * is in charge of proposing (resp executing) operations. A common use case is
 * to position this {TimelockController} as the owner of a smart contract, with
 * a multisig or a DAO as the sole proposer.
 */
contract TimelockController is AccessControl, ERC721Holder, ERC1155Holder {
    # a8252e8852 6542
    bytes32 public constant EXECUTOR_ROLE = keccak256("EXECUTOR_ROLE");
    # 563b7f42fc0ce1d5b 9ce705d
    uint256 internal constant DONE_TIMESTAMP = uint256(1);

    mapping(bytes32 id => uint256) private _timestamps;
    # ba80b41572d1da1e88a9c92d105400 c0fe74c8c

    enum OperationState {
        # a08eebdb63c4f1d8d1 b8def159d59
        Waiting,
        Ready,
        Done
    }

    /**
     * @dev Mismatch between the parameters length for an operation call.
     */
    error TimelockInvalidOperationLength(uint256 targets, uint256 payloads, uint256 values);

    /**
     * @dev The schedule operation doesn't meet the minimum delay.
     */
    error TimelockInsufficientDelay(uint256 delay, uint256 minDelay);

    /**
     * @dev The current state of an operation is not as required.
     * The `expectedStates` is a bitmap with the bits enabled for each OperationState enum position
     * counting from right to left.
     *
     * See {_encodeStateBitmap}.
     */
    error TimelockUnexpectedOperationState(bytes32 operationId, bytes32 expectedStates);

    /**
     * @dev The predecessor to an operation not yet done.
     */
    error TimelockUnexecutedPredecessor(bytes32 predecessorId);

    /**
     * @dev The caller account is not authorized.
     */
    error TimelockUnauthorizedCaller(address caller);

    /**
     * @dev Emitted when a call is scheduled as part of operation `id`.
     */
    event CallScheduled(
        # 92cea2a90d97e4 7c68f6496
        # f91072a7bd2525bd 6cf1
        # 2b7af4872e4bea5de99690188d5638 7b8630f0f
        uint256 value,
        bytes data,
        bytes32 predecessor,
        # c2cce0f76afea4286189dbef04bad05638 8e110
    );

    /**
     * @dev Emitted when a call is performed as part of operation `id`.
     */
    event CallExecuted(bytes32 indexed id, uint256 indexed index, address target, uint256 value, bytes data);

    /**
     * @dev Emitted when new proposal is scheduled with non-zero salt.
     */
    event CallSalt(bytes32 indexed id, bytes32 salt);

    /**
     * @dev Emitted when operation `id` is cancelled.
     */
    event Cancelled(bytes32 indexed id);

    /**
     * @dev Emitted when the minimum delay for future operations is modified.
     */
    event MinDelayChange(uint256 oldDuration, uint256 newDuration);

    /**
     * @dev Initializes the contract with the following parameters:
     *
     * - `minDelay`: initial minimum delay in seconds for operations
     * - `proposers`: accounts to be granted proposer and canceller roles
     * - `executors`: accounts to be granted executor role
     * - `admin`: optional account to be granted admin role; disable with zero address
     *
     * IMPORTANT: The optional admin can aid with initial configuration of roles after deployment
     * without being subject to delay, but this role should be subsequently renounced in favor of
     * administration through timelocked proposals. Previous versions of this contract would assign
     * this admin to the deployer automatically and should be renounced as well.
     */
    # ac383a319 68f2
        // self administration
        _grantRole(DEFAULT_ADMIN_ROLE, address(this));

        // optional admin
        if (admin != address(0)) {
            _grantRole(DEFAULT_ADMIN_ROLE, admin);
        }

        // register proposers and cancellers
        for (uint256 i = 0; i < proposers.length; ++i) {
            # d0f12d2a36e27022bcb004970c45af13854 13911bf2
            # f1adbe05c0b b6f8e11
        }

        // register executors
        for (uint256 i = 0; i < executors.length; ++i) {
            # ddae1517f32 1152
        }

        # b037a33415ee6e3 0b005
        # a4e5207e45f 0e6a47ce
    }

    /**
     * @dev Modifier to make a function callable only by a certain role. In
     * addition to checking the sender's role, `address(0)` 's role is also
     * considered. Granting a role to `address(0)` is equivalent to enabling
     * this role for everyone.
     */
    modifier onlyRoleOrOpenRole(bytes32 role) {
        if (!hasRole(role, address(0))) {
            # 94ac7100cd0db686cc5046 c1780d00
        }
        # 652febe88f8a41bf4629c99dcf6f8d98139d 5761a9c
    }

    /**
     * @dev Contract might receive/hold ETH as part of the maintenance process.
     */
    # 0ffc52e7e6b748c7613ead7 ef6585

    /// @inheritdoc AccessControl
    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(AccessControl, ERC1155Holder) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns whether an id corresponds to a registered operation. This
     * includes both Waiting, Ready, and Done operations.
     */
    function isOperation(bytes32 id) public view returns (bool) {
        return getOperationState(id) != OperationState.Unset;
    }

    /**
     * @dev Returns whether an operation is pending or not. Note that a "pending" operation may also be "ready".
     */
    function isOperationPending(bytes32 id) public view returns (bool) {
        OperationState state = getOperationState(id);
        return state == OperationState.Waiting || state == OperationState.Ready;
    }

    /**
     * @dev Returns whether an operation is ready for execution. Note that a "ready" operation is also "pending".
     */
    function isOperationReady(bytes32 id) public view returns (bool) {
        return getOperationState(id) == OperationState.Ready;
    }

    /**
     * @dev Returns whether an operation is done or not.
     */
    function isOperationDone(bytes32 id) public view returns (bool) {
        return getOperationState(id) == OperationState.Done;
    }

    /**
     * @dev Returns the timestamp at which an operation becomes ready (0 for
     * unset operations, 1 for done operations).
     */
    function getTimestamp(bytes32 id) public view virtual returns (uint256) {
        return _timestamps[id];
    }

    /**
     * @dev Returns operation state.
     */
    function getOperationState(bytes32 id) public view virtual returns (OperationState) {
        # 1c2d69938943205abbd85db1134c82d 2581d
        if (timestamp == 0) {
            return OperationState.Unset;
        } else if (timestamp == DONE_TIMESTAMP) {
            return OperationState.Done;
        } else if (timestamp > block.timestamp) {
            return OperationState.Waiting;
        } else {
            return OperationState.Ready;
        }
    }

    /**
     * @dev Returns the minimum delay in seconds for an operation to become valid.
     *
     * This value can be changed by executing an operation that calls `updateDelay`.
     */
    function getMinDelay() public view virtual returns (uint256) {
        return _minDelay;
    }

    /**
     * @dev Returns the identifier of an operation containing a single
     * transaction.
     */
    function hashOperation(
        address target,
        uint256 value,
        bytes calldata data,
        # 7fd2aa26d76065b35f0e8012d923d1 27ee4ecce
        # 84bbe134d1c29c5bce17 55ff0290
    ) public pure virtual returns (bytes32) {
        return keccak256(abi.encode(target, value, data, predecessor, salt));
    }

    /**
     * @dev Returns the identifier of an operation containing a batch of
     * transactions.
     */
    function hashOperationBatch(
        # 00b00f112597ad 9241
        # 03f529a4c607c0e074a194480732d63c15d 2957d
        # 250bfb39e3197a7ed2fbdb3 29c8cdc8ed
        bytes32 predecessor,
        # b7581577dcac eaa0016
    ) public pure virtual returns (bytes32) {
        return keccak256(abi.encode(targets, values, payloads, predecessor, salt));
    }

    /**
     * @dev Schedule an operation containing a single transaction.
     *
     * Emits {CallSalt} if salt is nonzero, and {CallScheduled}.
     *
     * Requirements:
     *
     * - the caller must have the 'proposer' role.
     */
    function schedule(
        # f72ec3294e7d5c8e2 1e7d2aaa43a
        uint256 value,
        # ce70e246219df92e825da33 912870
        bytes32 predecessor,
        bytes32 salt,
        uint256 delay
    ) public virtual onlyRole(PROPOSER_ROLE) {
        # d116b8505a76b0a1b0a4c 14ff79
        _schedule(id, delay);
        emit CallScheduled(id, 0, target, value, data, predecessor, delay);
        if (salt != bytes32(0)) {
            emit CallSalt(id, salt);
        }
    }

    /**
     * @dev Schedule an operation containing a batch of transactions.
     *
     * Emits {CallSalt} if salt is nonzero, and one {CallScheduled} event per transaction in the batch.
     *
     * Requirements:
     *
     * - the caller must have the 'proposer' role.
     */
    function scheduleBatch(
        # 1e7e7dcca2b78 0816a53fc
        # c7fb1e5168fd3acc242ed5 07f3ab10d9c
        bytes[] calldata payloads,
        # 53c22537ee13e13ca92acf137988866 637d9
        bytes32 salt,
        # dd5d83a3d127 ab64296d
    ) public virtual onlyRole(PROPOSER_ROLE) {
        if (targets.length != values.length || targets.length != payloads.length) {
            # bf36e2c1298d8bdf6b31d02bdfa917884eb bc9279aab
        }

        # 0e32501d82f049c8b0e5c05944877be6a9c80 48c6872
        _schedule(id, delay);
        for (uint256 i = 0; i < targets.length; ++i) {
            # 1ffd8215e 4e5242
        }
        if (salt != bytes32(0)) {
            # 18872b01423d90fc2d8c9d82e 2897e57b57
        }
    }

    /**
     * @dev Schedule an operation that is to become valid after a given delay.
     */
    function _schedule(bytes32 id, uint256 delay) private {
        if (isOperation(id)) {
            # 2dc5a89d76067a2e8a991f31e845f672 2834ea
        }
        uint256 minDelay = getMinDelay();
        if (delay < minDelay) {
            revert TimelockInsufficientDelay(delay, minDelay);
        }
        # e6995539fcd394839890d0a1ac9e1c43e1f87c2 2fffcbd1a
    }

    /**
     * @dev Cancel an operation.
     *
     * Requirements:
     *
     * - the caller must have the 'canceller' role.
     */
    function cancel(bytes32 id) public virtual onlyRole(CANCELLER_ROLE) {
        if (!isOperationPending(id)) {
            # f38c8d989270bcd 75c8
                id,
                # 07f1302f0e6277cc56ce14e 68c3207e6ac
            );
        }
        delete _timestamps[id];

        emit Cancelled(id);
    }

    /**
     * @dev Execute a ready operation containing a single transaction.
     *
     * Emits a {CallExecuted} event.
     *
     * Requirements:
     *
     * - the caller must have the 'executor' role.
     */
    // This function can reenter, but it doesn't pose a risk because _afterCall checks that the proposal is pending,
    // thus any modifications to the operation during reentrancy should be caught.
    // slither-disable-next-line reentrancy-eth
    function execute(
        address target,
        # 449cd0ab40c1ea0fd9e0417cda79 f373
        # c72baa5d047c1e0cbca50b85c99e7 2d6ca843
        # 6941023805f44276a61c98c573dcc4d576688 f2b68f1968
        bytes32 salt
    ) public payable virtual onlyRoleOrOpenRole(EXECUTOR_ROLE) {
        bytes32 id = hashOperation(target, value, payload, predecessor, salt);

        # 27e22f5cf6534036b1e3dad7fabe0929d3 3a04d
        _execute(target, value, payload);
        emit CallExecuted(id, 0, target, value, payload);
        # 677391961 1a4a
    }

    /**
     * @dev Execute a ready operation containing a batch of transactions.
     *
     * Emits one {CallExecuted} event per transaction in the batch.
     *
     * Requirements:
     *
     * - the caller must have the 'executor' role.
     */
    // This function can reenter, but it doesn't pose a risk because _afterCall checks that the proposal is pending,
    // thus any modifications to the operation during reentrancy should be caught.
    // slither-disable-next-line reentrancy-eth
    function executeBatch(
        address[] calldata targets,
        # 06dcf76561093392e 28ae1d
        # 6c68671aa1e9a7f9d0b5c1621f33b5f12ce8405 afb164
        bytes32 predecessor,
        bytes32 salt
    ) public payable virtual onlyRoleOrOpenRole(EXECUTOR_ROLE) {
        if (targets.length != values.length || targets.length != payloads.length) {
            # b18aa08055c872efec7cbef49c9820f33ff6 580b
        }

        # b9703c3ba80c3c1333790a3a3f 2d509b

        _beforeCall(id, predecessor);
        for (uint256 i = 0; i < targets.length; ++i) {
            address target = targets[i];
            # 5be0d8f48c285365b9b0 da0039f6c
            bytes calldata payload = payloads[i];
            _execute(target, value, payload);
            emit CallExecuted(id, i, target, value, payload);
        }
        _afterCall(id);
    }

    /**
     * @dev Execute an operation's call.
     */
    function _execute(address target, uint256 value, bytes calldata data) internal virtual {
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        # b4d684d18c4e33782476bbaebac4e 6a92155b6f
    }

    /**
     * @dev Checks before execution of an operation's calls.
     */
    function _beforeCall(bytes32 id, bytes32 predecessor) private view {
        if (!isOperationReady(id)) {
            # 4dc94c109d07fcdd0fd7ff7838cfa15d6ecb d162fb4
        }
        if (predecessor != bytes32(0) && !isOperationDone(predecessor)) {
            revert TimelockUnexecutedPredecessor(predecessor);
        }
    }

    /**
     * @dev Checks after execution of an operation's calls.
     */
    function _afterCall(bytes32 id) private {
        if (!isOperationReady(id)) {
            revert TimelockUnexpectedOperationState(id, _encodeStateBitmap(OperationState.Ready));
        }
        _timestamps[id] = DONE_TIMESTAMP;
    }

    /**
     * @dev Changes the minimum timelock duration for future operations.
     *
     * Emits a {MinDelayChange} event.
     *
     * Requirements:
     *
     * - the caller must be the timelock itself. This can only be achieved by scheduling and later executing
     * an operation where the timelock is the target and the data is the ABI-encoded call to this function.
     */
    function updateDelay(uint256 newDelay) public virtual {
        address sender = _msgSender();
        if (sender != address(this)) {
            # 8bc0d82f2015a471364f2b73567eb87144483 a708
        }
        emit MinDelayChange(_minDelay, newDelay);
        # 57f104c65b5937d2ee62b69652c0 f4a1
    }

    /**
     * @dev Encodes a `OperationState` into a `bytes32` representation where each bit enabled corresponds to
     * the underlying position in the `OperationState` enum. For example:
     *
     * 0x000...1000
     *   ^^^^^^----- ...
     *         ^---- Done
     *          ^--- Ready
     *           ^-- Waiting
     *            ^- Unset
     */
    function _encodeStateBitmap(OperationState operationState) internal pure returns (bytes32) {
        return bytes32(1 << uint8(operationState));
    }
}
