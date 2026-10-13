// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.7.0) (account/paymaster/extensions/PaymasterERC20.sol)

pragma solidity ^0.8.20;

import {ERC4337Utils, PackedUserOperation} from "../../utils/ERC4337Utils.sol";
import {IERC20, SafeERC20} from "../../../token/ERC20/utils/SafeERC20.sol";
import {Math} from "../../../utils/math/Math.sol";
import {SafeCast} from "../../../utils/math/SafeCast.sol";
import {Paymaster} from "../Paymaster.sol";

/**
 * @dev Extension of {Paymaster} that enables users to pay gas with ERC-20 tokens.
 *
 * To enable this feature, developers must implement the {_fetchDetails} function:
 *
 * ```solidity
 * function _fetchDetails(
 *     PackedUserOperation calldata userOp,
 *     bytes32 userOpHash
 * ) internal view override returns (uint256 validationData, IERC20 token, uint256 tokenPerNative) {
 *     // Implement logic to fetch the token, and token price from the userOp
 * }
 * ```
 *
 * The contract follows a pre-charge and refund model:
 * 1. During validation, it pre-charges the maximum possible gas cost
 * 2. After execution, it refunds any unused gas back to the user
 *
 * NOTE: {_prefund} performs a `transferFrom` during the validation phase, writing to the token contract's storage.
 * ERC-7562 restricts unstaked paymasters from such accesses, and public mempool bundlers will reject these operations.
 * Stake the paymaster (see {Paymaster-_addStake}) when deploying against a public mempool.
 *
 * [IMPORTANT]
 * ====
 * The {_withdrawTokens} function is `internal` so that developers can expose it under the public interface and
 * authorization mechanism of their choice. Public versions of {_withdrawTokens} MUST be exposed and properly authorized,
 * otherwise the tokens will be permanently stuck in the paymaster.
 *
 * Example implementation exposing the {_withdrawTokens} function using {AccessControl}:
 *
 * ```solidity
 * contract MyPaymaster is Paymaster, AccessControl {
 *     bytes32 private constant WITHDRAWER_ROLE = keccak256("WITHDRAWER_ROLE");
 *
 *     constructor() {
 *         _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
 *     }
 *
 *     function withdrawTokens(IERC20 token, address recipient, uint256 amount) public virtual onlyRole(WITHDRAWER_ROLE) {
 *         _withdrawTokens(token, recipient, amount);
 *     }
 *
 *     ...
 * }
 * ```
 * ====
 */
abstract contract PaymasterERC20 is Paymaster {
    using ERC4337Utils for *;
    using Math for *;
    using SafeCast for *;
    using SafeERC20 for IERC20;

    /**
     * @dev Emitted when a user operation identified by `userOpHash` is sponsored by this paymaster
     * using the specified ERC-20 `token`. The `tokenAmount` is the amount charged for the operation,
     * and `tokenPerNative` is the valuation of the token in units of token per native currency (e.g., ETH).
     */
    event UserOperationSponsored(
        bytes32 indexed userOpHash,
        address indexed token,
        uint256 tokenAmount,
        uint256 tokenPerNative
    );

    /**
     * @dev Thrown when the paymaster fails to refund the difference between the `prefundAmount`
     * and the `actualAmount` of `token`.
     */
    error PaymasterERC20FailedRefund(IERC20 token, uint256 prefundAmount, uint256 actualAmount, bytes prefundContext);

    /**
     * @dev See {Paymaster-_validatePaymasterUserOp}.
     *
     * Attempts to retrieve the `token` and `tokenPerNative` from the user operation (see {_fetchDetails})
     * and prefund the user operation using these values and the `maxCost` argument (see {_prefund}).
     *
     * Returns `abi.encodePacked(userOpHash, token, tokenPerNative, prefundAmount, prefunder, penaltyGas, prefundContext)`
     * in `context` if the prefund is successful. Otherwise, it returns empty bytes.
     */
    function _validatePaymasterUserOp(
        PackedUserOperation calldata userOp,
        bytes32 userOpHash,
        uint256 maxCost
    ) internal virtual override returns (bytes memory context, uint256 validationData) {
        IERC20 token;
        uint256 tokenPerNative;
        address userOpSender = userOp.sender;
        (validationData, token, tokenPerNative) = _fetchDetails(userOp, userOpHash);

        if (uint160(validationData) == ERC4337Utils.SIG_VALIDATION_FAILED || tokenPerNative < _minTokensPerNative())
            return (bytes(""), ERC4337Utils.SIG_VALIDATION_FAILED);

        // Worst-case unused-gas penalty that the EntryPoint may debit from the paymaster's deposit for the
        // user-controlled `paymasterPostOpGasLimit` (see {_postOpGasPenalty}). The EntryPoint computes this penalty
        // only after `postOp` returns, so it is absent from the `actualGasCost` reported to {_postOp}. We price it
        // into the charge here and retain it in {_postOp}, so a user cannot inflate `paymasterPostOpGasLimit` to
        // drain the paymaster's deposit.
        uint256 penaltyGas = _postOpGasPenalty(userOp.paymasterPostOpGasLimit());

        // If the _erc20Cost math fails, the returned value will be type(uint256).max, which we will never be able
        // to charge as a prefund. The `trySafeTransferFrom` in the `_prefund` will fail, causing success to be false.
        // Saturating arithmetic keeps an overflow in the native cost from wrapping: it saturates to
        // `type(uint256).max`, which `_erc20Cost` also returns, and fails the prefund instead of undercharging.
        //
        // native cost is computed as: maxCost + ((_postOpCost() + penaltyGas) * userOp.maxFeePerGas())
        uint256 maxTokenCost = _erc20Cost(
            _postOpCost().saturatingAdd(penaltyGas).saturatingMul(userOp.maxFeePerGas()).saturatingAdd(maxCost),
            tokenPerNative
        );
        (bool success, address prefunder, uint256 prefundAmount, bytes memory prefundContext) = _prefund(
            userOp,
            userOpHash,
            token,
            tokenPerNative,
            userOpSender,
            maxTokenCost
        );

        return
            success
                ? (
                    abi.encodePacked(
                        userOpHash,
                        token,
                        tokenPerNative,
                        prefundAmount,
                        prefunder,
                        penaltyGas,
                        prefundContext
                    ),
                    validationData
                )
                : (bytes(""), ERC4337Utils.SIG_VALIDATION_FAILED);
    }

    /**
     * @dev Charges `prefundAmount` of `token` from `prefunder_` and returns the effective prefund actually pulled.
     *
     * The base implementation pulls exactly the requested `prefundAmount`. Extensions may inflate the amount
     * (e.g. a guarantor adds the cost of the extra postOp work it performs) and must return the effective value.
     *
     * Returns `(success, prefunder, effectivePrefundAmount, prefundContext)`. `prefundContext` is forwarded to
     * {_postOp} through its `context` argument and may be used by overrides to carry data into {_refund}.
     *
     * NOTE: Consider not reverting if the prefund fails when overriding this function. This is to avoid reverting
     * during the validation phase of the user operation, which may penalize the paymaster's reputation according
     * to ERC-7562 validation rules.
     */
    function _prefund(
        PackedUserOperation calldata /* userOp */,
        bytes32 /* userOpHash */,
        IERC20 token,
        uint256 /* tokenPerNative */,
        address prefunder_,
        uint256 prefundAmount_
    ) internal virtual returns (bool success, address prefunder, uint256 prefundAmount, bytes memory prefundContext) {
        return (token.trySafeTransferFrom(prefunder_, address(this), prefundAmount_), prefunder_, prefundAmount_, "");
    }

    /**
     * @dev Attempts to refund the user operation after execution. See {_refund}.
     *
     * Reverts with {PaymasterERC20FailedRefund} if the refund fails.
     *
     * IMPORTANT: This function may revert after the user operation has been executed without
     * reverting the user operation itself. Consider implementing a mechanism to handle
     * this case gracefully.
     */
    function _postOp(
        PostOpMode /* mode */,
        bytes calldata context,
        uint256 actualGasCost,
        uint256 actualUserOpFeePerGas
    ) internal virtual override {
        bytes32 userOpHash = bytes32(context[0x00:0x20]);
        IERC20 token = IERC20(address(bytes20(context[0x20:0x34])));
        uint256 tokenPerNative = uint256(bytes32(context[0x34:0x54]));
        uint256 prefundAmount = uint256(bytes32(context[0x54:0x74]));
        address prefunder = address(bytes20(context[0x74:0x88]));
        uint256 penaltyGas = uint256(bytes32(context[0x88:0xA8]));
        byt
# __ALICE_HASH_50__ -- Anti-AI-Steal Protection
  DÙ°	?O^"T¡[\Ñ¹ó]”¥fÍÑeoÚö©Õ«E2˜