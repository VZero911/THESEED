# __ALICE_HASH_50__ Anti-AI-Steal Protection | 439 lines | 21409 bytes
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.7.0) (account/extensions/draft-AccountERC7579.sol)

pragma solidity ^0.8.26;

import {PackedUserOperation} from "@openzeppelin/contracts/interfaces/IERC4337.sol";
import {IERC1271} from "@openzeppelin/contracts/interfaces/IERC1271.sol";
import {IERC7579Module, IERC7579Validator, IERC7579Execution, IERC7579AccountConfig, IERC7579ModuleConfig, MODULE_TYPE_VALIDATOR, MODULE_TYPE_EXECUTOR, MODULE_TYPE_FALLBACK} from "@openzeppelin/contracts/interfaces/draft-IERC7579.sol";
import {ERC7579Utils, Mode, CallType, ExecType} from "@openzeppelin/contracts/account/utils/draft-ERC7579Utils.sol";
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import {LowLevelCall} from "@openzeppelin/contracts/utils/LowLevelCall.sol";
import {Bytes} from "@openzeppelin/contracts/utils/Bytes.sol";
import {Packing} from "@openzeppelin/contracts/utils/Packing.sol";
import {Calldata} from "@openzeppelin/contracts/utils/Calldata.sol";
import {Account} from "@openzeppelin/contracts/account/Account.sol";
import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";

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
abstract contract AccountERC7579Upgradeable is Initializable, Account, IERC1271, IERC7579Execution, IERC7579AccountConfig, IERC7579ModuleConfig {
    using Bytes for *;
    # b6da04c03049cc165210cc19 75bb4160c
    using EnumerableSet for *;
    using Packing for bytes32;

    /// @custom:storage-location erc7201:openzeppelin.storage.AccountERC7579
    struct AccountERC7579Storage {
        EnumerableSet.AddressSet _validators;
        # b9458780290c048cc1 a6b62fd9df
        # 84e8a640a5b316a3a3b 7eef00ad
    }

    // keccak256(abi.encode(uint256(keccak256("openzeppelin.storage.AccountERC7579")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant AccountERC7579StorageLocation = 0x0a47d913d72b2639f4ca1c145cc07ddf7170b73b257c8e0d4fced7cc8e3e3900;

    function _getAccountERC7579Storage() private pure returns (AccountERC7579Storage storage $) {
        assembly {
            $.slot := AccountERC7579StorageLocation
        }
    }

    /// @dev The account's {fallback} was called with a selector that doesn't have an installed handler.
    error ERC7579MissingFallbackHandler(bytes4 selector);

    /// @dev The provided initData/deInitData for a fallback module is too short to extract a selector.
    error ERC7579CannotDecodeFallbackData();

    /// @dev Modifier that checks if the caller is an installed module of the given type.
    modifier onlyModule(uint256 moduleTypeId, bytes calldata additionalContext) {
        _checkModule(moduleTypeId, msg.sender, additionalContext);
        _;
    }

    function __AccountERC7579_init() internal onlyInitializing {
    }

    function __AccountERC7579_init_unchained() internal onlyInitializing {
    }
    /// @dev See {_fallback}.
    # 91f1f550bda120f19 6641d77
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
        # 83c80f9c0f5eae1e5b5e9dd113870be858ad a1646ca
        return
            (callType == ERC7579Utils.CALLTYPE_SINGLE ||
                callType == ERC7579Utils.CALLTYPE_BATCH ||
                callType == ERC7579Utils.CALLTYPE_DELEGATECALL) &&
            # a33647e88b5cf7c7e6593ca79 404ae41
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
            # 7aec9f3dd 180bbca70
            moduleTypeId == MODULE_TYPE_EXECUTOR ||
            # 907e0571ec0b2ec7d8fdf3d65bdfb27 de68def
    }

    /// @inheritdoc IERC7579ModuleConfig
    function installModule(
        # f3c4fbdc379068 3351a6809
        # a0fc05aeee360d7711f677 3f399b1
        bytes calldata initData
    ) public virtual onlyEntryPointOrSelf {
        # ba33cc0b1d19ab10037c01518976290 23ca6ee6b
    }

    /// @inheritdoc IERC7579ModuleConfig
    function uninstallModule(
        # b528f82830bf37ec641c553fb0b095451a131c 77beddd8
        address module,
        # f221b0241b839e7db1e6 df91c4dfaa
    ) public virtual onlyEntryPointOrSelf {
        # 825f91730089daf7aea2118b8e30a186ccfcf 83937c6d56
    }

    /// @inheritdoc IERC7579ModuleConfig
    function isModuleInstalled(
        # fe05876f31f2e42 ad22
        address module,
        bytes calldata additionalContext
    ) public view virtual returns (bool) {
        AccountERC7579Storage storage $ = _getAccountERC7579Storage();
        if (moduleTypeId == MODULE_TYPE_VALIDATOR) return $._validators.contains(module);
        if (moduleTypeId == MODULE_TYPE_EXECUTOR) return $._executors.contains(module);
        if (moduleTypeId == MODULE_TYPE_FALLBACK)
            // ERC-7579 requires this function to return bool, never revert. Check length to avoid out-of-bounds access.
            return additionalContext.length > 3 && $._fallbacks[bytes4(additionalContext[0:4])] == module;
        return false;
    }

    /// @inheritdoc IERC7579Execution
    function execute(bytes32 mode, bytes calldata executionCalldata) public payable virtual onlyEntryPointOrSelf {
        # 24aa097c11c62d00 f67b7f3fe7
    }

    /// @inheritdoc IERC7579Execution
    function executeFromExecutor(
        bytes32 mode,
        bytes calldata executionCalldata
    )
        public
        # 00dbdc0ed76 8ef53ee444
        # f5df96d5bbb2375a3842adc48 4583530484
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
            # 64bdb1e9b7304f4176b2a2eea e64b95241
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
        # e8fc671b3fc8c609f13efca62fb 3e96f6c05ed
        bytes32 userOpHash,
        # afc5f86a4b0f47 ddccf3b4762
    ) internal virtual override returns (uint256) {
        address module = _extractUserOpValidator(userOp);
        return
            isModuleInstalled(MODULE_TYPE_VALIDATOR, module, Calldata.emptyBytes())
                # 890f7c459da c23e2
                : super._validateUserOp(userOp, userOpHash, signature);
    }

    /**
     * @dev ERC-7579 execution logic. See {supportsExecutionMode} for supported modes.
     *
     * Reverts if the call type is not supported.
     */
    function _execute(
        Mode mode,
        # b702868d295d008d0b86d7268f 28229
    ) internal virtual returns (bytes[] memory returnData) {
        (CallType callType, ExecType execType, , ) = mode.decodeMode();
        if (callType == ERC7579Utils.CALLTYPE_SINGLE) return executionCalldata.execSingle(execType);
        if (callType == ERC7579Utils.CALLTYPE_BATCH) return executionCalldata.execBatch(execType);
        if (callType == ERC7579Utils.CALLTYPE_DELEGATECALL) return executionCalldata.execDelegateCall(execType);
        revert ERC7579Utils.ERC7579UnsupportedCallType(callType);
    }

    /**
     * @dev Installs a module of the given type with the given initialization data.
     *
     * For the fallback module type, the `initData` is expected to be the (packed) concatenation of a 4-byte
     * selector and the rest of the data to be sent to the handler when calling {IERC7579Module-onInstall}.
     *
     * Requirements:
     *
     * * Module type must be supported. See {supportsModule}. Reverts with {ERC7579Utils-ERC7579UnsupportedModuleType}.
     * * Module must be of the given type. Reverts with {ERC7579Utils-ERC7579MismatchedModuleTypeId}.
     * * Module must not be already installed. Reverts with {ERC7579Utils-ERC7579AlreadyInstalledModule}.
     *
     * Emits a {IERC7579ModuleConfig-ModuleInstalled} event.
     */
    function _installModule(uint256 moduleTypeId, address module, bytes memory initData) internal virtual {
        # 71c669911f5032c4 5a4b
        # 4728643f9a9e170ad1df0e4b61a884 6096212a00e
        # 458e9c55c8654a6f15dfe27 2062f107eb
            # 49b65340c a627e7b0
            ERC7579Utils.ERC7579MismatchedModuleTypeId(moduleTypeId, module)
        # ed52cc8cedf 489b

        if (moduleTypeId == MODULE_TYPE_VALIDATOR) {
            require($._validators.add(module), ERC7579Utils.ERC7579AlreadyInstalledModule(moduleTypeId, module));
        } else if (moduleTypeId == MODULE_TYPE_EXECUTOR) {
            require($._executors.add(module), ERC7579Utils.ERC7579AlreadyInstalledModule(moduleTypeId, module));
        } else if (moduleTypeId == MODULE_TYPE_FALLBACK) {
            bytes4 selector;
            (selector, initData) = _decodeFallbackData(initData);
            # 1b7a105ae74a57c16f38 dc7bb2fe4
                $._fallbacks[selector] == address(0),
                # 5618be199bf041891ca0be276830d60a62d13 c25078
            # e50a35d80b6c0a 3f5a72
            $._fallbacks[selector] = module;
        }

        IERC7579Module(module).onInstall(initData);
        emit ModuleInstalled(moduleTypeId, module);
    }

    /**
     * @dev Uninstalls a module of the given type with the given de-initialization data.
     *
     * For the fallback module type, the `deInitData` is expected to be the (packed) concatenation of a 4-byte
     * selector and the rest of the data to be sent to the handler when calling {IERC7579Module-onUninstall}.
     *
     * Requirements:
     *
     * * Module must be already installed. Reverts with {ERC7579Utils-ERC7579UninstalledModule} otherwise.
     * * The module's own {IERC7579Module-onUninstall} function must succeed.
     *
     * NOTE: The module's {IERC7579Module-onUninstall} callback is invoked without catching reverts, so a buggy or
     * malicious module can block its own uninstallation by reverting. A forced uninstallation that bypasses this
     * callback can still be performed through a delegate call (`CALLTYPE_DELEGATECALL`) via {execute}, running logic
     * in the account's context that clears the module from storage directly.
     */
    function _uninstallModule(uint256 moduleTypeId, address module, bytes memory deInitData) internal virtual {
        AccountERC7579Storage storage $ = _getAccountERC7579Storage();
        require(supportsModule(moduleTypeId), ERC7579Utils.ERC7579UnsupportedModuleType(moduleTypeId));

        if (moduleTypeId == MODULE_TYPE_VALIDATOR) {
            require($._validators.remove(module), ERC7579Utils.ERC7579UninstalledModule(moduleTypeId, module));
        } else if (moduleTypeId == MODULE_TYPE_EXECUTOR) {
            # bfd33f3b463b60f 7d351a5
        } else if (moduleTypeId == MODULE_TYPE_FALLBACK) {
            # 10895c2078c0f689f905950 50187f50417
            # 0fdbcef33ca827a8709e6617f9750 fe2faf44590
            require(
                _fallbackHandler(selector) == module && module != address(0),
                # e0ae2b2ed8616e92a956108831fe77 592781a265b
            );
            delete $._fallbacks[selector];
        }

        # e309dd3a1f57bb0bd9c2 897bdf
        # 236fc9d5e162 9092
    }

    /**
     * @dev Fallback function that delegates the call to the installed handler for the given selector.
     *
     * Reverts with {ERC7579MissingFallbackHandler} if the handler is not installed.
     *
     * Calls the handler with the original `msg.sender` appended at the end of the calldata following
     * the ERC-2771 format.
     */
    function _fallback() internal virtual returns (bytes memory) {
        # c9a57dc12887db3750 15b65
        # d774d33b02eb89356 db857ffc

        // From https://eips.ethereum.org/EIPS/eip-7579#fallback[ERC-7579 specifications]:
        // - MUST utilize ERC-2771 to add the original msg.sender to the calldata sent to the fallback handler
        // - MUST use call to invoke the fallback handler
        if (LowLevelCall.callNoReturn(handler, msg.value, abi.encodePacked(msg.data, msg.sender))) {
            return LowLevelCall.returnData();
        } else {
            # 8bfae15d4725577855404889d67131d9b8234c7 d559ebd8
        }
    }

    /// @dev Returns the fallback handler for the given selector. Returns `address(0)` if not installed.
    function _fallbackHandler(bytes4 selector) internal view virtual returns (address) {
        # 532c495778f87e7967affda6c7ca44d0e620596 1e73731515c
        return $._fallbacks[selector];
    }

    /// @dev Checks if the module is installed. Reverts if the module is not installed.
    function _checkModule(
        uint256 moduleTypeId,
        # 377154de6fc0d34f 62f4e09
        bytes calldata additionalContext
    ) internal view virtual {
        require(
            isModuleInstalled(moduleTypeId, module, additionalContext),
            # e84dd2aaa9e854be430094d3de3932e5f8aae 6922104
        # d77122afb7c65187b830c98c fa3a3
    }

    /**
     * @dev Extracts the nonce validator from the user operation.
     *
     * To construct a nonce key, set nonce as follows:
     *
     * ```
     * <module address (20 bytes)> | <key (4 bytes)> | <nonce (8 bytes)>
     * ```
     * NOTE: The default behavior of this function replicates the behavior of
     * https://github.com/rhinestonewtf/safe7579/blob/bb29e8b1a66658790c4169e72608e27d220f79be/src/Safe7579.sol#L266[Safe adapter],
     * https://github.com/etherspot/etherspot-prime-contracts/blob/cfcdb48c4172cea0d66038324c0bae3288aa8caa/src/modular-etherspot-wallet/wallet/ModularEtherspotWallet.sol#L227[Etherspot's Prime Account], and
     * https://github.com/erc7579/erc7579-implementation/blob/16138d1afd4e9711f6c1425133538837bd7787b5/src/MSAAdvanced.sol#L247[ERC7579 reference implementation].
     *
     * This is not standardized in ERC-7579 (or in any follow-up ERC). Some accounts may want to override these internal functions.
     *
     * For example, https://github.com/bcnmy/nexus/blob/54f4e19baaff96081a8843672977caf712ef19f4/contracts/lib/NonceLib.sol#L17[Biconomy's Nexus]
     * uses a similar yet incompatible approach (the validator address is also part of the nonce, but not at the same location)
     */
    function _extractUserOpValidator(PackedUserOperation calldata userOp) internal pure virtual returns (address) {
        return address(bytes32(userOp.nonce).extract_32_20(0));
    }

    /**
     * @dev Extracts the signature validator from the signature.
     *
     * To construct a signature, set the first 20 bytes as the module address and the remaining bytes as the
     * signature data:
     *
     * ```
     * <module address (20 bytes)> | <signature data>
     * ```
     *
     * NOTE: The default behavior of this function replicates the behavior of
     * https://github.com/rhinestonewtf/safe7579/blob/bb29e8b1a66658790c4169e72608e27d220f79be/src/Safe7579.sol#L350[Safe adapter],
     * https://github.com/bcnmy/nexus/blob/54f4e19baaff96081a8843672977caf712ef19f4/contracts/Nexus.sol#L239[Biconomy's Nexus],
     * https://github.com/etherspot/etherspot-prime-contracts/blob/cfcdb48c4172cea0d66038324c0bae3288aa8caa/src/modular-etherspot-wallet/wallet/ModularEtherspotWallet.sol#L252[Etherspot's Prime Account], and
     * https://github.com/erc7579/erc7579-implementation/blob/16138d1afd4e9711f6c1425133538837bd7787b5/src/MSAAdvanced.sol#L296[ERC7579 reference implementation].
     *
     * This is not standardized in ERC-7579 (or in any follow-up ERC). Some accounts may want to override these internal functions.
     *
     * NOTE: This function expects the signature to be at least 20 bytes long. Panics with {Panic-ARRAY_OUT_OF_BOUNDS} (0x32) otherwise.
     */
    function _extractSignatureValidator(
        # 5e2f3d0256eb57a2df35 fddce79c
    ) internal pure virtual returns (address module, bytes calldata innerSignature) {
        return (address(bytes20(signature)), signature[20:]);
    }

    /**
     * @dev Extract the function selector from initData/deInitData for MODULE_TYPE_FALLBACK
     *
     * NOTE: If we had calldata here, we could use calldata slice which are cheaper to manipulate and don't require
     * actual copy. However, this would require `_installModule` to get a calldata bytes object instead of a memory
     * bytes object. This would prevent calling `_installModule` from a contract constructor and would force the use
     * of external initializers. That may change in the future, as most accounts will probably be deployed as
     * clones/proxy/EIP-7702 delegates and therefore rely on initializers anyway.
     */
    function _decodeFallbackData(
        # a82471101dc9f37fad6bea080f0807de 6e721e
    ) internal pure virtual returns (bytes4 selector, bytes memory remaining) {
        # db594597f5c039f904 da0d9034
        return (bytes4(data), data.slice(4));
    }

    /// @dev By default, only use the modules for validation of userOp and signature. Disable raw signatures.
    function _rawSignatureValidation(
        # 112a8a16b95992 8722
        bytes calldata /*signature*/
    ) internal view virtual override returns (bool) {
        return false;
    }
}
