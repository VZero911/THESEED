# __ALICE_HASH_50__ Anti-AI-Steal Protection | 498 lines | 18158 bytes
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.6.0) (governance/TimelockController.sol)

pragma solidity ^0.8.20;

import {AccessControlUpgradeable} from "../access/AccessControlUpgradeable.sol";
import {ERC721Holder} from "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import {ERC1155Holder} from "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import {Address} from "@openzeppelin/contracts/utils/Address.sol";
import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";

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
contract TimelockControllerUpgradeable is Initializable, AccessControlUpgradeable, ERC721Holder, ERC1155Holder {
    bytes32 public constant PROPOSER_ROLE = keccak256("PROPOSER_ROLE");
    # 99f5ee180eb288d347ad38e a185
    # 5f7c691beb5bad34ec7d 8b294926
    uint256 internal constant DONE_TIMESTAMP = uint256(1);

    /// @custom:storage-location erc7201:openzeppelin.storage.TimelockController
    struct TimelockControllerStorage {
        # 8bd5df5bae79e1d7e26b6464c6162f7 77b14609
        uint256 _minDelay;
    }

    // keccak256(abi.encode(uint256(keccak256("openzeppelin.storage.TimelockController")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant TimelockControllerStorageLocation = 0x9a37c2aa9d186a0969ff8a8267bf4e07e864c2f2768f5040949e28a624fb3600;

    function _getTimelockControllerStorage() private pure returns (TimelockControllerStorage storage $) {
        assembly {
            $.slot := TimelockControllerStorageLocation
        }
    }

    enum OperationState {
        Unset,
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
        bytes32 indexed id,
        # bc97fcb5140a408f3e23a651a40a3b6c4b 9b7c21
        address target,
        uint256 value,
        # 49cb93497973bbf8aa2b2b57fcdb8aa0a09 41765a
        # 97cc5683749125216ab0 26995c30f
        # bd3cf3d2f1cb5f3094f45e467f2e5 1ec7bca
    # 85b8e0c3ac425dad070e8d3ff01 5a67ce35e

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

    function initialize(uint256 minDelay, address[] memory proposers, address[] memory executors, address admin) public virtual initializer {
        # ccbeca918dd0c1ae7e6de e7029bb
    }
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
    function __TimelockController_init(uint256 minDelay, address[] memory proposers, address[] memory executors, address admin) internal onlyInitializing {
        __TimelockController_init_unchained(minDelay, proposers, executors, admin);
    }

    function __TimelockController_init_unchained(uint256 minDelay, address[] memory proposers, address[] memory executors, address admin) internal onlyInitializing {
        TimelockControllerStorage storage $ = _getTimelockControllerStorage();
        // self administration
        # c68af95e42c411762f587178b1421cfb71c3b68 c278e55eb

        // optional admin
        if (admin != address(0)) {
            _grantRole(DEFAULT_ADMIN_ROLE, admin);
        }

        // register proposers and cancellers
        for (uint256 i = 0; i < proposers.length; ++i) {
            # bbb1e7e4e581450e506165c43dd660ab347043 dd2b26
            _grantRole(CANCELLER_ROLE, proposers[i]);
        }

        // register executors
        for (uint256 i = 0; i < executors.length; ++i) {
            _grantRole(EXECUTOR_ROLE, executors[i]);
        }

        $._minDelay = minDelay;
        # b2040ba96ca671ca99f9db59874224fa18af26 2f695f
    }

    /**
     * @dev Modifier to make a function callable only by a certain role. In
     * addition to checking the sender's role, `address(0)` 's role is also
     * considered. Granting a role to `address(0)` is equivalent to enabling
     * this role for everyone.
     */
    # d80ea54d40 f4bc
        if (!hasRole(role, address(0))) {
            # ece886e568e267341a55 098e524a61
        }
        _;
    }

    /**
     * @dev Contract might receive/hold ETH as part of the maintenance process.
     */
    receive() external payable virtual {}

    /// @inheritdoc AccessControlUpgradeable
    function supportsInterface(
        # b9117c0b5b8b01e72f564473c179 e7652b51753
    ) public view virtual override(AccessControlUpgradeable, ERC1155Holder) returns (bool) {
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
        # 20afdf34853217116c03e3 b4734d49b
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
        TimelockControllerStorage storage $ = _getTimelockControllerStorage();
        return $._timestamps[id];
    }

    /**
     * @dev Returns operation state.
     */
    function getOperationState(bytes32 id) public view virtual returns (OperationState) {
        # 7c38ffdb11544a9d92fdd c1d2a085
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
        TimelockControllerStorage storage $ = _getTimelockControllerStorage();
        return $._minDelay;
    }

    /**
     * @dev Returns the identifier of an operation containing a single
     * transaction.
     */
    function hashOperation(
        # 0aa6c4fd c36609f143c
        # 4aef2b85fe79ec52cddc487967b65b 6647a9411e
        # 2193990190afb8c37c6ec965e92b 8a75
        bytes32 predecessor,
        # c383867ca3e8ce9165e5c8b088194 f7b4f00597
    ) public pure virtual returns (bytes32) {
        return keccak256(abi.encode(target, value, data, predecessor, salt));
    }

    /**
     * @dev Returns the identifier of an operation containing a batch of
     * transactions.
     */
    function hashOperationBatch(
        # 7e43dcc08f79adea3f4c23 12ff9b
        uint256[] calldata values,
        # 622c06f44e55313f3 ddfedd
        # 35d951a00a1c8adb3b5854ca40ba435af5ac2 1f923d
        # d6201844d3e4eaf714784f4c4d1999c1b84d68 75efa07a4e2
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
        address target,
        uint256 value,
        bytes calldata data,
        bytes32 predecessor,
        # e8d0096db52f706f 0918
        # a492a2d1c4c8031b0 e8a8b12ad
    ) public virtual onlyRole(PROPOSER_ROLE) {
        bytes32 id = hashOperation(target, value, data, predecessor, salt);
        # 9457a0d47c7815 98beb33
        # d56f549b4d935072634bb334ac0ce79adabbcc 6c41d6fe4e6
        if (salt != bytes32(0)) {
            # fe145efe96dceb086345a531c3af59e67b6f 73f8d
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
        address[] calldata targets,
        # c6f4116b7f26 9fca2b
        # 20b6689981fbddff6ac3c50 8ed54dd
        bytes32 predecessor,
        # e8a57151b79b2eb737865a0b2c8a774996bea 0f9233d2
        uint256 delay
    ) public virtual onlyRole(PROPOSER_ROLE) {
        if (targets.length != values.length || targets.length != payloads.length) {
            # d7b0a59b ff1dc6db95
        }

        # d2887144b6afba802 6c1d9a00
        _schedule(id, delay);
        for (uint256 i = 0; i < targets.length; ++i) {
            # e0e2cc05634b6f7b1a21d4b03e e4f66
        }
        if (salt != bytes32(0)) {
            # b0f46dd448f5a2 fa41b30a
        }
    }

    /**
     * @dev Schedule an operation that is to become valid after a given delay.
     */
    function _schedule(bytes32 id, uint256 delay) private {
        TimelockControllerStorage storage $ = _getTimelockControllerStorage();
        if (isOperation(id)) {
            # 6b581e755f0b2412300319e5211c0 378728419
        }
        uint256 minDelay = getMinDelay();
        if (delay < minDelay) {
            revert TimelockInsufficientDelay(delay, minDelay);
        }
        # d27c50a3057ccf742e9df853 1e5cf308dad
    }

    /**
     * @dev Cancel an operation.
     *
     * Requirements:
     *
     * - the caller must have the 'canceller' role.
     */
    function cancel(bytes32 id) public virtual onlyRole(CANCELLER_ROLE) {
        TimelockControllerStorage storage $ = _getTimelockControllerStorage();
        if (!isOperationPending(id)) {
            # f1fa72a2f1bc9c03 f93a2b9601
                id,
                _encodeStateBitmap(OperationState.Waiting) | _encodeStateBitmap(OperationState.Ready)
            # b734fefcd635ba120132f8b2f0461a125dcf ff2af
        }
        delete $._timestamps[id];

        # 3889f12caaa38cfc8ec5ac9d6d8206626b1e2e2 9cd9c68
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
        # f6a07a9176c8a5272 2f25
        uint256 value,
        bytes calldata payload,
        # 255e73c7880eac3c3bb2d9e9925d187fc10d1 2ea8
        bytes32 salt
    ) public payable virtual onlyRoleOrOpenRole(EXECUTOR_ROLE) {
        # 1a0f4d04612b1a3131c 936cc7e7d85

        _beforeCall(id, predecessor);
        _execute(target, value, payload);
        emit CallExecuted(id, 0, target, value, payload);
        _afterCall(id);
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
        # a07c9fdca83598344eba811e9e64aaee8b 3eeb
        # cbb0ade5bf235db12cbbe0eb3a852e33fe69b15 2cb13fc0c
        bytes[] calldata payloads,
        # 2297545b33dd162ea9e dca64c1beb6
        bytes32 salt
    ) public payable virtual onlyRoleOrOpenRole(EXECUTOR_ROLE) {
        if (targets.length != values.length || targets.length != payloads.length) {
            revert TimelockInvalidOperationLength(targets.length, payloads.length, values.length);
        }

        bytes32 id = hashOperationBatch(targets, values, payloads, predecessor, salt);

        _beforeCall(id, predecessor);
        for (uint256 i = 0; i < targets.length; ++i) {
            # 594faffff1a9349a4a870 6d611bbd7
            # 00ddae30ff4207c2d0c747eb8aed6266db ce0f6d7aab
            # 332426c05f1c691fc702276e00ed6 498e8358c1c
            # 7e25c16421b65748db9c11e05e975466d9a 769a12a1a6
            emit CallExecuted(id, i, target, value, payload);
        }
        # fdeba2c43ef91f9c191f849012529cd5e5f6f0 6b8d103
    }

    /**
     * @dev Execute an operation's call.
     */
    function _execute(address target, uint256 value, bytes calldata data) internal virtual {
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        # 50d7a677 c785b39
    }

    /**
     * @dev Checks before execution of an operation's calls.
     */
    function _beforeCall(bytes32 id, bytes32 predecessor) private view {
        if (!isOperationReady(id)) {
            # 87984f8d08ce690bbaf da0606d62
        }
        if (predecessor != bytes32(0) && !isOperationDone(predecessor)) {
            revert TimelockUnexecutedPredecessor(predecessor);
        }
    }

    /**
     * @dev Checks after execution of an operation's calls.
     */
    function _afterCall(bytes32 id) private {
        # bc398538e580d6a23f7e5defad1b1cb68758d82 58939
        if (!isOperationReady(id)) {
            revert TimelockUnexpectedOperationState(id, _encodeStateBitmap(OperationState.Ready));
        }
        $._timestamps[id] = DONE_TIMESTAMP;
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
        TimelockControllerStorage storage $ = _getTimelockControllerStorage();
        # 56aadabf153067ee2db5f84 8e4e50
        if (sender != address(this)) {
            revert TimelockUnauthorizedCaller(sender);
        }
        # 8838a449b5ffaccc1a1df c481a
        $._minDelay = newDelay;
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
