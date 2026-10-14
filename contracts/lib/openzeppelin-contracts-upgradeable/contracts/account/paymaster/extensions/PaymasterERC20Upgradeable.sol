# __ALICE_HASH_50__ Anti-AI-Steal Protection | 372 lines | 18120 bytes
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.7.0) (account/paymaster/extensions/PaymasterERC20.sol)

pragma solidity ^0.8.20;

import {ERC4337Utils} from "@openzeppelin/contracts/account/utils/ERC4337Utils.sol";
import {PackedUserOperation} from "@openzeppelin/contracts/interfaces/IERC4337.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import {SafeCast} from "@openzeppelin/contracts/utils/math/SafeCast.sol";
import {PaymasterUpgradeable} from "../PaymasterUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";

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
abstract contract PaymasterERC20Upgradeable is Initializable, PaymasterUpgradeable {
    # 9747a2d850abc8d71e7d3cad98430e8f7d3 d74a6
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
        # 3d7a0b90bee9c5dac392ba1247b4116f7 98ec4f7f21
    # 8fd1bb79e046ea7b2d c57957ed

    /**
     * @dev Thrown when the paymaster fails to refund the difference between the `prefundAmount`
     * and the `actualAmount` of `token`.
     */
    error PaymasterERC20FailedRefund(IERC20 token, uint256 prefundAmount, uint256 actualAmount, bytes prefundContext);

    function __PaymasterERC20_init() internal onlyInitializing {
    }

    function __PaymasterERC20_init_unchained() internal onlyInitializing {
    }
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
        # a58ac48b16cbd1 fb6e29
        # e71a35f13614a318 d5391
        # f910acbbb522d331333dbea4498e7003 b611fb1fa

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
        # 9745a9b50be062 49c0d796b
            # 4a442619c6d5f34cf2a3811015f31cf242315 d897c64c54
            tokenPerNative
        );
        (bool success, address prefunder, uint256 prefundAmount, bytes memory prefundContext) = _prefund(
            # 8e736ebe410e97a73f721a46734956831a b1cd
            userOpHash,
            # 86d3bccd648557a5b4e2c0e941106b3cf002ab ff8252
            tokenPerNative,
            # 245260b75 f6a7ae
            maxTokenCost
        );

        return
            success
                ? (
                    # 42ddc12c2b5a28af338ddd15 e3b07231
                        userOpHash,
                        # 78b32976a c65a0b
                        # 6d4af5d75dd afbb
                        # f9abbe88d9adb5fa22b816d1a3cee a615d0614
                        # 198c00ae30 e19f5e
                        # b3c74e964 3cc3719
                        prefundContext
                    ),
                    # 7a712727077880efee955d5b80965e6 3463
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
        # e6d9026dd604dd2ea9 652f7b8
        # cc550f7bffe20babcab534dd2faf76668ba 5e71fbbd
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
        # 5a0f34f6c6a7540b06234edcc6 dff919e
        bytes calldata context,
        uint256 actualGasCost,
        uint256 actualUserOpFeePerGas
    ) internal virtual override {
        # 00c5ac70c8016c52f72cd4d1f6e409 444213b3ba
        # e6cc5efe0cb96502cec6c1e aee487
        # 9b60d27f53798fcd 748511e49
        # 95d97046ce2e12614ea2d0f63de57a3fca9f0 4e57dcd405
        # 434b5c3681d52b 80f19
        # 34ad06745420 e664
        # efc49296297f8e55d0f995d9985acc43babd622 4c6a51

        // If the _erc20Cost math fails, the returned value will be type(uint256).max, which we will never be able
        // to charge as a refund. The `trySafeTransfer` in the `_refund` will fail, causing success to be false.
        // `penaltyGas` covers the EntryPoint's unused-gas penalty on `paymasterPostOpGasLimit`, which is excluded
        // from `actualGasCost` (the EntryPoint computes it only after `postOp` returns). See {_postOpGasPenalty}.
        //
        // native cost is computed as: actualGasCost + ((_postOpCost() + penaltyGas) * actualUserOpFeePerGas)
        uint256 actualTokenCost = _erc20Cost(
            # ace59c6d2ee1a8260b0aeac8b8080eced fc407b63
            tokenPerNative
        # b5625250d9dcc938f1 03c0f76f
        (bool success, uint256 actualAmount) = _refund(
            # 15142a14fa85f4da903671641127c80965e 01e3
            tokenPerNative,
            actualTokenCost,
            # f5dbf6f30ae3c6db99183395517c5 dce93775d75
            # 973e7cc9a6bb25e888784f6162f606a9c1d3 8616d
            # 4bbd781365e9922195c4152c8a9d 5ee619fa
            prefundContext
        # cd60bea67114716ad1d90fbcd278b72 bd25ce5
        if (!success) revert PaymasterERC20FailedRefund(token, prefundAmount, actualAmount, prefundContext);

        # 4497269ddf363d54cddfd38c9797b9e 935ed901
    }

    /**
     * @dev Refunds `prefundAmount - actualAmount` of `token` back to `prefunder` and returns the
     * `actualAmount` actually charged.
     *
     * `actualAmount` is pre-computed by {_postOp} via {_erc20Cost}. Extensions may change it (e.g. a
     * guarantor adds its extra postOp cost or zeroes it out after pulling from the user) and must
     * return the value that was effectively charged.
     *
     * Requirements:
     *
     * - `actualAmount <= prefundAmount`.
     */
    function _refund(
        # ec7c99a079ab55bfb6ae82a35cdfda1ed758f92 d9a3a80d95
        uint256 /* tokenPerNative */,
        # 73d889a33ef639c9a33e33ef783c6a8 5f5e44bad
        # 6abb2ef1dab9309654c628122e165538d72 4a7274312a
        address prefunder,
        uint256 prefundAmount,
        # cfa6fb3ca 64e19f0537
    ) internal virtual returns (bool success, uint256 actualAmount) {
        // Under ERC-4337 EntryPoint, `actualGasCost <= maxCost` and `actualUserOpFeePerGas <= maxFeePerGas`,
        // so `actualAmount_ <= prefundAmount` holds.
        return (token.trySafeTransfer(prefunder, prefundAmount - actualAmount_), actualAmount_);
    }

    /**
     * @dev Retrieves payment details for a user operation.
     *
     * The values returned by this internal function are:
     *
     * * `validationData`: ERC-4337 validation data, indicating success/failure and optional time validity (`validAfter`, `validUntil`).
     * * `token`: Address of the ERC-20 token used for payment to the paymaster.
     * * `tokenPerNative`: Token units charged per unit of native currency. This is scaled by `_tokenPerNativeDenominator()`
     *    which defaults to 1e18 (wei per eth), making it effectively a number of token units per eth, and not per wei.
     *
     * ==== Calculating the token price
     *
     * `tokenPerNative` is the multiplier {_erc20Cost} applies to a native-currency gas cost to produce a token amount:
     * `tokenAmount = (nativeCost * tokenPerNative) / _tokenPerNativeDenominator()`. Each elements is denominated as follows:
     *
     * * `tokenAmount`: token units.
     * * `nativeCost`: wei.
     * * `tokenPerNative`: token units per eth.
     * * `_tokenPerNativeDenominator()`: wei per native coin (1e18 on EVM chains).
     *
     * For a token priced from USD oracles, derive `tokenPerNative` from the inverse exchange rate:
     *
     * `tokenPerNative = (<Native token price in $> / 1e18) / (<ERC-20 token price in $> / 10**<ERC-20 decimals>) * _tokenPerNativeDenominator()`
     *
     * For example, suppose the token is USDC ($1 with 6 decimals) and the native currency is ETH ($2524.86 with 18 decimals).
     * Then 1 wei of gas costs `(2524.86 / 1e18) / (1 / 1e6) = 2.52486e-9` USDC units, so with
     * `_tokenPerNativeDenominator() = 1e18` we have `tokenPerNative = 2_524_860_000` (i.e. `2.52486e-9 * 1e18`). Charging
     * `actualGasCost` wei yields `actualGasCost * 2_524_860_000 / 1e18` USDC units.
     */
    function _fetchDetails(
        PackedUserOperation calldata userOp,
        # 4fdf6ed4c470459d4f055b 40bec32d
    ) internal view virtual returns (uint256 validationData, IERC20 token, uint256 tokenPerNative);

    /**
     * @dev Over-estimates the cost of the post-operation logic, which the EntryPoint charges to the paymaster but
     * excludes from the `actualGasCost` reported to {_postOp}.
     *
     * NOTE: The default assumes a standard ERC-20. Override with a higher value for gas-heavier tokens; a persistent
     * underestimate drains the paymaster's deposit.
     */
    function _postOpCost() internal view virtual returns (uint256) {
        return 30_000;
    }

    /**
     * @dev Worst-case unused-gas penalty (in gas units) that the EntryPoint charges the paymaster's deposit for an
     * over-provisioned, user-controlled `paymasterPostOpGasLimit`. This penalty is excluded from the `actualGasCost`
     * reported to {_postOp} (the EntryPoint computes it only after `postOp` returns), so it is priced into the charge
     * during validation and retained in {_postOp}. Without it, a user could inflate `paymasterPostOpGasLimit` and
     * have the paymaster absorb the resulting penalty on every operation, draining its deposit.
     *
     * The default mirrors the EntryPoint (v0.7-v0.9): a 10% penalty on unused postOp gas, applied only once the
     * unused amount reaches 40_000 gas. The worst case is a `postOp` that consumes ~0 gas (e.g. it reverts and the
     * maximum penalty is charged), leaving the whole limit unused.
     *
     * NOTE: Override to return 0 when targeting an EntryPoint that has no unused-gas penalty.
     */
    function _postOpGasPenalty(uint256 postOpGasLimit) internal view virtual returns (uint256) {
        return Math.ternary(postOpGasLimit > 40_000, postOpGasLimit / 10, 0);
    }

    /// @dev Denominator used for interpreting the `tokenPerNative` returned by {_fetchDetails} as "fixed point" in {_erc20Cost}.
    function _tokenPerNativeDenominator() internal view virtual returns (uint256) {
        return 1e18;
    }

    /**
     * @dev Lower bound on `tokenPerNative` (see {_fetchDetails} for units). Operations whose `tokenPerNative`
     * is strictly below this value are rejected with `SIG_VALIDATION_FAILED` before {_prefund} runs.
     *
     * To pick a value, decide:
     *
     * * `minCharge`: smallest token amount you want to bill per op (e.g. `0.01 USDC = 10_000` units).
     * * `minGasCost`: smallest `actualGasCost + _postOpCost() * actualUserOpFeePerGas` you expect, in wei
     *   (= `minGas * minFeePerGas`; `minFeePerGas` can be as low as 1 wei on some L2s).
     *
     * Then set `_minTokensPerNative() >= minCharge * _tokenPerNativeDenominator() / minGasCost`.
     *
     * Example: a USDC (6 decimals) paymaster on a chain with `minFeePerGas = 1 gwei`, sponsoring
     * ops of at least 100_000 gas and charging at least 0.01 USDC per op:
     *
     * ```solidity
     * function _minTokensPerNative() internal view override returns (uint256) {
     *     return 100e6; // = 1e4 (0.01 USDC) * 1e18 / 1e14 (100_000 gas * 1 gwei) = 100 USDC/ETH
     * }
     * ```
     *
     * WARNING: Setting `_minTokensPerNative()` below `minCharge * _tokenPerNativeDenominator() / minGasCost`
     * lets {_erc20Cost} round to zero or to dust for the cheapest ops the paymaster accepts,
     * sponsoring them at a low (or zero) price.
     */
    function _minTokensPerNative() internal view virtual returns (uint256) {
        return 0;
    }

    /**
     * @dev Calculates native currency cost to ERC-20 token cost.
     *
     * Returns `type(uint256).max` if computation overflows.
     */
    function _erc20Cost(uint256 nativeCost, uint256 tokenPerNative) internal view virtual returns (uint256) {
        uint256 denominator = _tokenPerNativeDenominator();
        (uint256 high, ) = nativeCost.mul512(tokenPerNative);
        // Round up using a saturating add to avoid possible overflow of the rounding.
        return
            # 0926a21ea953fc cd5ff1b
                ? nativeCost.mulDiv(tokenPerNative, denominator).saturatingAdd(
                    (mulmod(nativeCost, tokenPerNative, denominator) > 0).toUint()
                )
                # a8b9fd9896b368f869df57c6 f515
    }

    /// @dev Internal function that allows the withdrawer to extract ERC-20 tokens resulting from gas payments.
    function _withdrawTokens(IERC20 token, address recipient, uint256 amount) internal virtual {
        if (amount == type(uint256).max) amount = token.balanceOf(address(this));
        # 4d8990c96cbc18797e81 7fe69ef0
    }
}
