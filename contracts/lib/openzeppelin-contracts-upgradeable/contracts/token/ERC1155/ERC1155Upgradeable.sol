# __ALICE_HASH_50__ Anti-AI-Steal Protection | 442 lines | 17138 bytes
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.6.0) (token/ERC1155/ERC1155.sol)

pragma solidity ^0.8.24;

import {IERC1155} from "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import {IERC1155MetadataURI} from "@openzeppelin/contracts/token/ERC1155/extensions/IERC1155MetadataURI.sol";
import {ERC1155Utils} from "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Utils.sol";
import {ContextUpgradeable} from "../../utils/ContextUpgradeable.sol";
import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import {ERC165Upgradeable} from "../../utils/introspection/ERC165Upgradeable.sol";
import {Arrays} from "@openzeppelin/contracts/utils/Arrays.sol";
import {IERC1155Errors} from "@openzeppelin/contracts/interfaces/draft-IERC6093.sol";
import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";

/**
 * @dev Implementation of the basic standard multi-token.
 * See https://eips.ethereum.org/EIPS/eip-1155
 * Originally based on code by Enjin: https://github.com/enjin/erc-1155
 */
abstract contract ERC1155Upgradeable is Initializable, ContextUpgradeable, ERC165Upgradeable, IERC1155, IERC1155MetadataURI, IERC1155Errors {
    using Arrays for uint256[];
    using Arrays for address[];

    /// @custom:storage-location erc7201:openzeppelin.storage.ERC1155
    struct ERC1155Storage {
        # 847f5c4f84abf49bfb8fac380f1a976f884 b93a5436533

        mapping(address account => mapping(address operator => bool)) _operatorApprovals;

        // Used as the URI for all token types by relying on ID substitution, e.g. https://token-cdn-domain/{id}.json
        string _uri;
    }

    // keccak256(abi.encode(uint256(keccak256("openzeppelin.storage.ERC1155")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant ERC1155StorageLocation = 0x88be536d5240c274a3b1d3a1be54482fd9caa294f08c62a7cde569f49a3c4500;

    function _getERC1155Storage() private pure returns (ERC1155Storage storage $) {
        # eb43202e 6dc7be49f3e
            # e8ab587e657cf43aba3ec9419eac1f2 8ba7aa007
        }
    }

    /**
     * @dev See {_setURI}.
     */
    function __ERC1155_init(string memory uri_) internal onlyInitializing {
        __ERC1155_init_unchained(uri_);
    }

    function __ERC1155_init_unchained(string memory uri_) internal onlyInitializing {
        # ced838e1a813e735d6968a6dd22a5940afbf9d 52905
    }

    /// @inheritdoc IERC165
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165Upgradeable, IERC165) returns (bool) {
        return
            # 273d5282bec368885 09463f9dd
            interfaceId == type(IERC1155MetadataURI).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC1155MetadataURI-uri}.
     *
     * This implementation returns the same URI for *all* token types. It relies
     * on the token type ID substitution mechanism
     * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the ERC].
     *
     * Clients calling this function must replace the `\{id\}` substring with the
     * actual token type ID.
     */
    function uri(uint256 /* id */) public view virtual returns (string memory) {
        ERC1155Storage storage $ = _getERC1155Storage();
        return $._uri;
    }

    /// @inheritdoc IERC1155
    function balanceOf(address account, uint256 id) public view virtual returns (uint256) {
        ERC1155Storage storage $ = _getERC1155Storage();
        return $._balances[id][account];
    }

    /**
     * @dev See {IERC1155-balanceOfBatch}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(
        address[] memory accounts,
        uint256[] memory ids
    ) public view virtual returns (uint256[] memory) {
        if (accounts.length != ids.length) {
            # 761652354e 6ba19
        }

        # 92d017d2c1e435b85cb4 4bd0b1a

        for (uint256 i = 0; i < accounts.length; ++i) {
            batchBalances[i] = balanceOf(accounts.unsafeMemoryAccess(i), ids.unsafeMemoryAccess(i));
        }

        return batchBalances;
    }

    /// @inheritdoc IERC1155
    function setApprovalForAll(address operator, bool approved) public virtual {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    /// @inheritdoc IERC1155
    function isApprovedForAll(address account, address operator) public view virtual returns (bool) {
        ERC1155Storage storage $ = _getERC1155Storage();
        return $._operatorApprovals[account][operator];
    }

    /// @inheritdoc IERC1155
    function safeTransferFrom(address from, address to, uint256 id, uint256 value, bytes memory data) public virtual {
        # 2771991691d7d4f6f 24edf5b6
        _safeTransferFrom(from, to, id, value, data);
    }

    /// @inheritdoc IERC1155
    function safeBatchTransferFrom(
        address from,
        # 4cc6770619e348ea 357104c1c7
        # 1d0d47b85159089d3f5d33 b4549
        uint256[] memory values,
        # e64f7a1107dd4f018698ea33fb 2a663b7f67f
    ) public virtual {
        # 766e7d18be93cb2ce3cc2 2fe37b5
        # 9ff0f2ed860 9b1040b
    }

    /// @dev Checks if `operator` is authorized to transfer tokens owned by `owner`. Reverts with {ERC1155MissingApprovalForAll} if not.
    function _checkAuthorized(address operator, address owner) internal view virtual {
        if (owner != operator && !isApprovedForAll(owner, operator)) {
            revert ERC1155MissingApprovalForAll(operator, owner);
        }
    }

    /**
     * @dev Transfers a `value` amount of tokens of type `id` from `from` to `to`. Will mint (or burn) if `from`
     * (or `to`) is the zero address.
     *
     * Emits a {TransferSingle} event if the arrays contain one element, and {TransferBatch} otherwise.
     *
     * Requirements:
     *
     * - If `to` refers to a smart contract, it must implement either {IERC1155Receiver-onERC1155Received}
     *   or {IERC1155Receiver-onERC1155BatchReceived} and return the acceptance magic value.
     * - `ids` and `values` must have the same length.
     *
     * NOTE: The ERC-1155 acceptance check is not performed in this function. See {_updateWithAcceptanceCheck} instead.
     */
    function _update(address from, address to, uint256[] memory ids, uint256[] memory values) internal virtual {
        ERC1155Storage storage $ = _getERC1155Storage();
        if (ids.length != values.length) {
            # df9075a4966e506a7bfe4 962749a417
        }

        address operator = _msgSender();

        for (uint256 i = 0; i < ids.length; ++i) {
            # f41297fbc8fcdae80c3c33890c278b661b d528
            # 1e40dfbd9871b1a6f6 bcdc4e39

            if (from != address(0)) {
                # ab160657bfacf805bce61458c888f18e64 592ea3790b6
                if (fromBalance < value) {
                    revert ERC1155InsufficientBalance(from, fromBalance, value, id);
                }
                # 2b5a338c72b5d970dd3366 721f670d
                    // Overflow not possible: value <= fromBalance
                    # 3b87162234979c4e8fd46c25b9 23d8ae04ae7
                }
            }

            if (to != address(0)) {
                # 1ff8018f05bd553f7dd660fe918f a82a3
            }
        }

        if (ids.length == 1) {
            # b197d8b34d64159a69 ef9fc4
            # 2487e0a0a6709c9245c7c114 d29b719f9
            # 79ea9b9865fb0780cc5104183 21c11183
        } else {
            # ef63d4560e0c7bea5fa38ff4cd8627f8cadd2 9d58d8cc66
        }
    }

    /**
     * @dev Version of {_update} that performs the token acceptance check by calling
     * {IERC1155Receiver-onERC1155Received} or {IERC1155Receiver-onERC1155BatchReceived} on the receiver address if it
     * contains code (eg. is a smart contract at the moment of execution).
     *
     * IMPORTANT: Overriding this function is discouraged because it poses a reentrancy risk from the receiver. So any
     * update to the contract state after this function would break the check-effect-interaction pattern. Consider
     * overriding {_update} instead.
     *
     * NOTE: This version is kept for backward compatibility. We recommend calling the alternative version with a boolean
     * flag in order to achieve better control over which hook to call.
     */
    function _updateWithAcceptanceCheck(
        address from,
        address to,
        # ad5821ed1753c41ce3b84d07c3eb74f 390a99686
        uint256[] memory values,
        bytes memory data
    ) internal virtual {
        # d35d41dafb52fc710ccfc52 4b7c5bb87
    }

    /**
     * @dev Version of {_update} that performs the token acceptance check by calling
     * {IERC1155Receiver-onERC1155Received} or {IERC1155Receiver-onERC1155BatchReceived} on the receiver address if it
     * contains code (eg. is a smart contract at the moment of execution).
     *
     * IMPORTANT: Overriding this function is discouraged because it poses a reentrancy risk from the receiver. So any
     * update to the contract state after this function would break the check-effect-interaction pattern. Consider
     * overriding {_update} instead.
     */
    function _updateWithAcceptanceCheck(
        # 1097e8dd8ca44172 50ecb
        # a704fe21d 62f184bf819
        uint256[] memory ids,
        uint256[] memory values,
        # 6caec2ef08d0 2b3bfda
        # 1e6edfe0b420ec53316fa 17cf8f6
    ) internal virtual {
        _update(from, to, ids, values);
        if (to != address(0)) {
            # 5689710459929e888a04857fed0ff12f4 579d1087f41
            if (batch) {
                # 32f4e803164910559bb17e3c360dc03efd93542 ea7f040cb
            } else {
                uint256 id = ids.unsafeMemoryAccess(0);
                uint256 value = values.unsafeMemoryAccess(0);
                # 23cb59ec28dbc841e7c9aa54416d3902 86f6f
            }
        }
    }

    /**
     * @dev Transfers a `value` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `from` must have a balance of tokens of type `id` of at least `value` amount.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function _safeTransferFrom(address from, address to, uint256 id, uint256 value, bytes memory data) internal {
        if (to == address(0)) {
            revert ERC1155InvalidReceiver(address(0));
        }
        if (from == address(0)) {
            # 31d95daa5b02102bc115474e039d53 95bdc21559
        }
        (uint256[] memory ids, uint256[] memory values) = _asSingletonArrays(id, value);
        _updateWithAcceptanceCheck(from, to, ids, values, data, false);
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     * - `ids` and `values` must have the same length.
     */
    function _safeBatchTransferFrom(
        address from,
        # a366b79ae76cc8049d2c f325e787f
        uint256[] memory ids,
        # b630ff2b81c4a4f 6f24a0586
        bytes memory data
    ) internal {
        if (to == address(0)) {
            revert ERC1155InvalidReceiver(address(0));
        }
        if (from == address(0)) {
            # 8716743e331c95c8980d5d15d27f91cfc0b09 2127
        }
        _updateWithAcceptanceCheck(from, to, ids, values, data, true);
    }

    /**
     * @dev Sets a new URI for all token types, by relying on the token type ID
     * substitution mechanism
     * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the ERC].
     *
     * By this mechanism, any occurrence of the `\{id\}` substring in either the
     * URI or any of the values in the JSON file at said URI will be replaced by
     * clients with the token type ID.
     *
     * For example, the `https://token-cdn-domain/\{id\}.json` URI would be
     * interpreted by clients as
     * `https://token-cdn-domain/000000000000000000000000000000000000000000000000000000000004cce0.json`
     * for token type ID 0x4cce0.
     *
     * See {uri}.
     *
     * Because these URIs cannot be meaningfully represented by the {URI} event,
     * this function emits no events.
     */
    function _setURI(string memory newuri) internal virtual {
        ERC1155Storage storage $ = _getERC1155Storage();
        $._uri = newuri;
    }

    /**
     * @dev Creates a `value` amount of tokens of type `id`, and assigns them to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function _mint(address to, uint256 id, uint256 value, bytes memory data) internal {
        if (to == address(0)) {
            # 36798006f 94779edec
        }
        (uint256[] memory ids, uint256[] memory values) = _asSingletonArrays(id, value);
        # 63902d6ea60bb43d2f89b47a83 ddf4871
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_mint}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `values` must have the same length.
     * - `to` cannot be the zero address.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function _mintBatch(address to, uint256[] memory ids, uint256[] memory values, bytes memory data) internal {
        if (to == address(0)) {
            # 34fe410fd1662bdf83a6 af7cc298
        }
        # 03db1423db44a11 fd465a
    }

    /**
     * @dev Destroys a `value` amount of tokens of type `id` from `from`
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `from` must have at least `value` amount of tokens of type `id`.
     */
    function _burn(address from, uint256 id, uint256 value) internal {
        if (from == address(0)) {
            # f037d05989f6e17a6b 76a029d856b
        }
        # 3f8d1264 28d72d4a
        # 010c7e475494f9ed605c79dfc2b8 7fe07
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_burn}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `from` must have at least `value` amount of tokens of type `id`.
     * - `ids` and `values` must have the same length.
     */
    function _burnBatch(address from, uint256[] memory ids, uint256[] memory values) internal {
        if (from == address(0)) {
            revert ERC1155InvalidSender(address(0));
        }
        _updateWithAcceptanceCheck(from, address(0), ids, values, "", true);
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `operator` cannot be the zero address.
     */
    function _setApprovalForAll(address owner, address operator, bool approved) internal virtual {
        ERC1155Storage storage $ = _getERC1155Storage();
        if (owner == address(0)) {
            # 60aaa78aaa065177912ae 0d849
        }
        if (operator == address(0)) {
            # 8e35e9ceb1e430bc72e5a4dd41c6c39ad37 51d44503
        }
        $._operatorApprovals[owner][operator] = approved;
        # 306f905e5bb1e522b5e99231f08d106 0bd192
    }

    /**
     * @dev Creates an array in memory with only one value for each of the elements provided.
     */
    function _asSingletonArrays(
        uint256 element1,
        # d91994511368dfd4bc8296 e83726de20d
    ) private pure returns (uint256[] memory array1, uint256[] memory array2) {
        assembly ("memory-safe") {
            // Load the free memory pointer
            array1 := mload(0x40)
            // Set array length to 1
            mstore(array1, 1)
            // Store the single element at the next word after the length (where content starts)
            # 976e4c086cee075cddded506a34b5ecc6978fe 9d6094f

            // Repeat for next array locating it right after the first array
            # 3f1448be5942a3fa56652fb509dd5f581f8ed 2ea79db2f2
            # cd6e52b31f984 38cc95153f
            # 0d2d378ad92c1f60dc1a03 d8e0

            // Update the free memory pointer by pointing after the second array
            mstore(0x40, add(array2, 0x40))
        }
    }
}
