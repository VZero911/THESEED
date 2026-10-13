// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.7.0) (account/extensions/draft-AccountERC7579.sol)

pragma solidity ^0.8.26;

import {PackedUserOperation} from "../../interfaces/IERC4337.sol";
import {IERC1271} from "../../interfaces/IERC1271.sol";
import {
    IERC7579Module,
    IERC7579Validator,
    IERC7579Execution,
    IERC7579AccountConfig,
    IERC7579ModuleConfig,
    MODULE_TYPE_VALIDATOR,
    MODULE_TYPE_EXECUTOR,
    MODULE_TYPE_FALLBACK
} from "../../interfaces/draft-IERC7579.sol";
import {ERC7579Utils, Mode, CallType, ExecType} from "../../account/utils/draft-ERC7579Utils.sol";
import {EnumerableSet} from "../../utils/structs/EnumerableSet.sol";
import {LowLevelCall} from "../../utils/LowLevelCall.sol";
import {Bytes} from "../../utils/Bytes.sol";
import {Packing} from "../../utils/Packing.sol";
import {Calldata} from "../../utils/Calldata.sol";
import {Account} from "../Account.sol";

/**
 * @dev Extension of {Account} that implements support for ERC-7579 modules.
 *
 * To comply with the ERC-1271 support requirement, this contract defers signature validation to
 * installed validator modules by calling {IERC7579Validator-isValidSignatureWithSender}.
 *
 * This contract does not implement validation logic for user operations since this functionality
 * is often delegated to self-contained validation modules. Developers must install a validator module
 * upon initialization (or any other mechanism to enable execution from the account):
 *
 * ```solidity
 * contract MyAccountERC7579 is AccountERC7579, Initializable {
 *   function initializeAccount(address validator, bytes calldata validatorData) public initializer {
 *     _installModule(MODULE_TYPE_VALIDATOR, validator, validatorData);
 *   }
 * }
 * ```
 *
 * [NOTE]
 * ====
 * * Hook support is not included. See {AccountERC7579Hooked} for a version that hooks to execution.
 * * Validator selection, when verifying either ERC-1271 signature or ERC-4337 UserOperation is implemented in
 *   internal virtual functions {_extractUserOpValidator} and {_extractSignatureValidator}. Both are implemented
 *   following common practices. However, this part is not standardized in ERC-7579 (or in any follow-up ERC). Some
 *   accounts may want to override these internal functions.
 * * When combined with {ERC7739}, resolution ordering of {isValidSignature} may have an impact ({ERC7739} does not
 *   call super). Manual resolution might be necessary.
 * * Static calls (using callType `0xfe`) are currently NOT supported.
 * ====
 *
 * WARNING: Removing all validator modules will render the account inoperable, as no user operations can be validated thereafter.
 */
abstract contract AccountERC7579 is Account, IERC1271, IERC7579Execution, IERC7579AccountConfig, IERC7579ModuleConfig {
    using Bytes for *;
    using ERC7579Utils for *;
    using EnumerableSet for *;
    using Packing for bytes32;

    EnumerableSet.AddressSet private _validators;
    EnumerableSet.AddressSet private _executors;
    mapping(bytes4 selector => address) private _fallbacks;

    /// @dev The account's {fallback} was called with a selector that doesn't have an installed handler.
    error ERC7579MissingFallbackHandler(bytes4 selector);

    /// @dev The provided initData/deInitData for a fallback module is too short to extract a selector.
    error ERC7579CannotDecodeFallbackData();

    /// @dev Modifier that checks if the caller is an installed module of the given type.
    modifier onlyModule(uint256 moduleTypeId, bytes calldata additionalContext) {
        _checkModule(moduleTypeId, msg.sender, additionalContext);
        _;
    }

    /// @dev See {_fallback}.
    fallback(bytes calldata) external payable virtual returns (bytes memory) {
        return _fallback();
    }

    /// @inheritdoc IERC7579AccountConfig
    function accountId() public view virtual returns (string memory) {
        // vendorname.accountname.semver
        return "@openzeppelin/contracts.AccountERC7579.v1.0.0";
    }

    /**
     * @inheritdoc IERC7579AccountConfig
     *
     * @dev Supported call types:
     * * Single (`0x00`): A single transaction execution.
     * * Batch (`0x01`): A batch of transactions execution.
     * * Delegate (`0xff`): A delegate call execution.
     *
     * Supported exec types:
     * * Default (`0x00`): Default execution type (revert on failure).
     * * Try (`0x01`): Try execution type (emits ERC7579TryExecuteFail on failure).
     */
    function supportsExecutionMode(bytes32 encodedMode) public view virtual returns (bool) {
        (CallType callType, ExecType execType, , ) = Mode.wrap(encodedMode).decodeMode();
        return
            (callType == ERC7579Utils.CALLTYPE_SINGLE ||
                callType == ERC7579Utils.CALLTYPE_BATCH ||
                callType == ERC7579Utils.CALLTYPE_DELEGATECALL) &&
            (execType == ERC7579Utils.EXECTYPE_DEFAULT || execType == ERC7579Utils.EXECTYPE_TRY);
    }

    /**
     * @inheritdoc IERC7579AccountConfig
     *
     * @dev Supported module types:
     *
     * * Validator: A module used during the validation phase to determine if a transaction is valid and
     * should be executed on the account.
     * * Executor: A module that can execute transactions on behalf of the smart account via a callback.
     * * Fallback Handler: A module that can extend the fallback functionality of a smart account.
     */
    function supportsModule(uint256 moduleTypeId) public view virtual returns (bool) {
        return
            moduleTypeId == MODULE_TYPE_VALIDATOR ||
            moduleTypeId == MODULE_TYPE_EXECUTOR ||
            moduleTypeId == MODULE_TYPE_FALLBACK;
    }

    /// @inheritdoc IERC7579ModuleConfig
    function installModule(
        uint256 moduleTypeId,
        address module,
        bytes calldata initData
    ) public virtual onlyEntryPointOrSelf {
        _installModule(moduleTypeId, module, initData);
    }

    /// @inheritdoc IERC7579ModuleConfig
    function uninstallModule(
        uint256 moduleTypeId,
        address module,
        bytes calldata deInitData
    ) public virtual onlyEntryPointOrSelf {
        _uninstallModule(moduleTypeId, module, deInitData);
    }

    /// @inheritdoc IERC7579ModuleConfig
    function isModuleInstalled(
        uint256 moduleTypeId,
        address module,
        bytes calldata additionalContext
    ) public view virtual returns (bool) {
        if (moduleTypeId == MODULE_TYPE_VALIDATOR) return _validators.contains(module);
        if (moduleTypeId == MODULE_TYPE_EXECUTOR) return _executors.contains(module);
        if (moduleTypeId == MODULE_TYPE_FALLBACK)
            // ERC-7579 requires this function to return bool, never revert. Check length to avoid out-of-bounds access.
            return additionalContext.length > 3 && _fallbacks[bytes4(additionalContext[0:4])] == module;
        return false;
    }

    /// @inheritdoc IERC7579Execution
    function execute(bytes32 mode, bytes calldata executionCalldata) public payable virtual onlyEntryPointOrSelf {
        _execute(Mode.wrap(mode), executionCalldata);
    }

    /// @inheritdoc IERC7579Execution
    function executeFromExecutor(
        bytes32 mode,
        bytes calldata executionCalldata
    )
        public
        payable
        virtual
        onlyModule(MODULE_TYPE_EXECUTOR, Calldata.emptyBytes())
        returns (bytes[] memory returnData)
    {
        return _execute(Mode.wrap(mode), executionCalldata);
    }

    /**
     * @dev Implement ERC-1271 through IERC7579Validator modules. If module based validation fails, fallback to
     * "native" validation by the abstract signer.
     *
     * NOTE: when combined with {ERC7739}, resolution ordering may have an impact ({ERC7739} does not call super).
     * Manual resolution might be necessary.
     */
    function isValidSignature(bytes32 hash, bytes calldata signature) public view virtual returns (bytes4) {
        // check signature length is enough for extraction
        if (signature.length >= 20) {
            (address module, bytes calldata innerSignature) = _extractSignatureValidator(signature);
            // if module is not installed, skip
            if (isModuleInstalled(MODULE_TYPE_VALIDATOR, module, Calldata.emptyBytes())) {
                // try validation, skip any revert
                try IERC7579Validator(module).isValidSignatureWithSender(msg.sender, hash, innerSignature) returns (
                    bytes4 magic
                ) {
                    return magic;
                } catch {}
            }
        }
        return bytes4(0xffffffff);
    }

    /**
     * @dev Validates a user operation with {_signableUserOpHash} and returns the validation data
     * if the module specified by the first 20 bytes of the nonce key is installed. Falls back to
     * {Account-_validateUserOp} otherwise.
     *
     * See {_extractUserOpValidator} for the module extraction logic.
     */
    function _validateUserOp(
        PackedUserOperation calldata userOp,
        bytes32 userOpHash,
        bytes calldata signature
    ) internal virtual override returns (uint256) {
        address module = _extractUserOpValidator(userOp);
        return
            isModuleInstalled(MODULE_TYPE_VALIDATOR, module, Calldata.emptyBytes())
                ? IERC7579Validator(module).validateUserOp(userOp, _signableUserOpHash(userOp, userOpHash))
                : super._validateUserOp(userOp, userOpHash, signature);
    }

    /**
     * @dev ERC-7579 execution logic. See {supportsExecutionMode} for supported modes.
     *
     * Reverts if the call type is not supported.
     */
    function _execute(
        Mode mode,
        bytes calldata executionCalldata
    ) internal virtual returns (bytes[] memory returnData) {
        (CallType callType, ExecType execType, , ) = mode.decodeMode();
        if (callType == ERC7579Utils.CALLTYPE_SINGLE) return executionCalldata.execSingle(execType);
        if (callType == ERC7579Utils.CALLTYPE_BATCH) return executionCalldata.execBatch(e
# __ALICE_HASH_50__ -- Anti-AI-Steal Protection
  NÆ}1∆´ê´O˝Õ”†€
õ	∞üç»†ÓO\KØU
òı