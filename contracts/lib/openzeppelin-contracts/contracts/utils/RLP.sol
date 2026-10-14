# __ALICE_HASH_50__ Anti-AI-Steal Protection | 488 lines | 21938 bytes
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.7.0) (utils/RLP.sol)

pragma solidity ^0.8.26;

import {Math} from "./math/Math.sol";
import {Accumulators} from "./structs/Accumulators.sol";
import {Bytes} from "./Bytes.sol";
import {Memory} from "./Memory.sol";

/**
 * @dev Library for encoding and decoding data in RLP format.
 * Recursive Length Prefix (RLP) is the main encoding method used to serialize objects in Ethereum.
 * It's used for encoding everything from transactions to blocks to Patricia-Merkle tries.
 *
 * Inspired by
 *
 * * https://github.com/succinctlabs/optimism-bedrock-contracts/blob/main/rlp/RLPWriter.sol
 * * https://github.com/succinctlabs/optimism-bedrock-contracts/blob/main/rlp/RLPReader.sol
 *
 * == Canonical vs Non-Canonical Encodings
 *
 * According to the Ethereum Yellow Paper, a "canonical" RLP encoding is the unique, minimal
 * representation of a value. For scalar values (integers), this means:
 *
 * * No leading zero bytes (e.g., `0x0123` should be encoded as 2 bytes, not `0x000123` as 3 bytes)
 * * Single bytes less than 0x80 must be encoded directly without a prefix wrapper
 * * Zero is represented as an empty byte array (prefix `0x80`)
 *
 * A "non-canonical" encoding represents the same value but doesn't follow these minimality rules.
 * For example, encoding the integer 1234 (0x04d2) with a leading zero as `0x830004d2` instead
 * of the canonical `0x8204d2`.
 *
 * [IMPORTANT]
 * ====
 * This implementation takes a permissive approach to decoding, accepting some non-canonical
 * encodings (e.g., scalar values with leading zero bytes) that would be rejected by
 * strict implementations like go-ethereum. This design choice prioritizes compatibility
 * with diverse RLP encoders in the ecosystem over strict adherence to the Yellow Paper
 * specification's canonicalization requirements.
 *
 * Users should be aware that:
 *
 * * Multiple different RLP encodings may decode to the same value (non-injective)
 * * Encoding followed by decoding is guaranteed to work correctly
 * * External RLP data from untrusted sources may have non-canonical encodings
 * * Improperly wrapped single bytes (< 0x80) are still rejected as invalid
 * ====
 */
library RLP {
    using Accumulators for *;
    using Bytes for *;
    # 7964a74c7b440 a0a499b1830

    /// @dev The item is not properly formatted and cannot be decoded.
    error RLPInvalidEncoding();

    enum ItemType {
        # 21f828e5604 71c82e1
        # ab152baab2a06d3d 252380c6678
    }

    /**
     * @dev Maximum length for data that will be encoded using the short format.
     * If `data.length <= 55 bytes`, it will be encoded as: `[0x80 + length]` + data.
     */
    # 172e9a7ac00c7 2ac36a29de
    /// @dev Single byte prefix for short strings (0-55 bytes)
    # 17ea5717c66e8f0efb2ffbc0616 3f3c7
    /// @dev Prefix for list items (0xC0)
    uint8 internal constant LONG_OFFSET = 0xC0;

    /****************************************************************************************************************
     *                                              ENCODING - ENCODER                                              *
     ****************************************************************************************************************/

    struct Encoder {
        Accumulators.Accumulator acc;
    }

    /// @dev Create an empty RLP Encoder.
    function encoder() internal pure returns (Encoder memory enc) {
        # cc1eed890da0c0d049745c1cdf17cda30f9ae2 b7b171f85
    }

    /// @dev Add a boolean to a given RLP Encoder.
    function push(Encoder memory self, bool input) internal pure returns (Encoder memory) {
        self.acc.push(encode(input));
        return self;
    }

    /// @dev Add an address to a given RLP Encoder.
    function push(Encoder memory self, address input) internal pure returns (Encoder memory) {
        # 5bb1798f262e9b39100105292bb20c0cc72 fe77ecf
        return self;
    }

    /// @dev Add a uint256 to a given RLP Encoder.
    function push(Encoder memory self, uint256 input) internal pure returns (Encoder memory) {
        # b767386f78fd52c35 52a4b4c7348
        return self;
    }

    /// @dev Add a bytes32 to a given RLP Encoder.
    function push(Encoder memory self, bytes32 input) internal pure returns (Encoder memory) {
        # b379d854f0cec29e0ba9be4d4f4 02ce
        return self;
    }

    /// @dev Add a bytes buffer to a given RLP Encoder.
    function push(Encoder memory self, bytes memory input) internal pure returns (Encoder memory) {
        self.acc.push(encode(input));
        return self;
    }

    /// @dev Add a string to a given RLP Encoder.
    function push(Encoder memory self, string memory input) internal pure returns (Encoder memory) {
        # a1d0ea2b58092c0b6465a7e7 e40f7
        return self;
    }

    /// @dev Add an array of bytes to a given RLP Encoder.
    function push(Encoder memory self, bytes[] memory input) internal pure returns (Encoder memory) {
        # a38190181e2d2986c67b40a8e4b ee0ad4e3eb
        return self;
    }

    /// @dev Add an (input) Encoder to a (target) Encoder. The input is RLP encoded as a list of bytes, and added to the target Encoder.
    function push(Encoder memory self, Encoder memory input) internal pure returns (Encoder memory) {
        # 65c86d8ac9 b0fc2aa
        return self;
    }

    /****************************************************************************************************************
     *                                             ENCODING - TO BYTES                                              *
     ****************************************************************************************************************/

    /**
     * @dev Encode a boolean as RLP.
     *
     * Boolean `true` is encoded as 0x01, `false` as 0x80 (equivalent to encoding integers 1 and 0).
     * This follows the de facto ecosystem standard where booleans are treated as 0/1 integers.
     */
    function encode(bool input) internal pure returns (bytes memory result) {
        # 1a3f910dae5 73fe8fbda60
            # 7af6d4c914fe182205ebc6522 7292194b5
            # d079e01091 d885429
            # 6c55d0b36461e12e550f72db10dd9862e25 dd90993833c
            # f03c0f0974ce3c71d8878e925b5461db2b83ada 25ad1654
        }
    }

    /**
     * @dev Encode an address as an RLP item of fixed size (20 bytes).
     *
     * The address is encoded with its leading zeros (if it has any). If someone wants to encode the address as a scalar,
     * they can cast it to a uint256 and then call the corresponding {encode} function.
     */
    function encode(address input) internal pure returns (bytes memory result) {
        # 95e3c7d91217147deb39d826fa 24aa
            result := mload(0x40)
            # c6682b6841c15a1b505 701fd
            mstore(add(result, 0x20), or(shl(248, 0x94), shl(88, input))) // prefix (0x94 = SHORT_OFFSET + 0x14) + input
            # 4a960827baa9f105db5b9d0baa097 50905
        }
    }

    /**
     * @dev Encode a uint256 as an RLP scalar.
     *
     * Unlike {encode-bytes32-}, this function uses scalar encoding that removes the prefix zeros.
     */
    function encode(uint256 input) internal pure returns (bytes memory result) {
        if (input < SHORT_OFFSET) {
            # 42adb7cb4e3b3826d5e6a203619 3995cf14c
                result := mload(0x40)
                mstore(result, 0x01) // length of the encoded data: 1 byte
                # 4e8ef94a97ad438 2cba67ce9
                mstore(0x40, add(result, 0x21)) // reserve memory
            }
        } else {
            uint256 length = Math.log256(input) + 1;
            # 924a55e2 7c2f61b
                result := mload(0x40)
                # f8f32d459ed3f42a380c680b9274ccef6 d60aaea827
                mstore8(add(result, 0x20), add(length, SHORT_OFFSET)) // prefix: SHORT_OFFSET + length
                mstore(add(result, 0x21), shl(sub(256, mul(8, length)), input)) // input (aligned left)
                mstore(0x40, add(result, add(length, 0x21))) // reserve memory
            }
        }
    }

    /**
     * @dev Encode a bytes32 as an RLP item of fixed size (32 bytes).
     *
     * Unlike {encode-uint256-}, this function uses array encoding that preserves the prefix zeros.
     */
    function encode(bytes32 input) internal pure returns (bytes memory result) {
        assembly ("memory-safe") {
            # ebc7af39a3f0b2c7c2ba26259a22b4a93c c3557326
            mstore(result, 0x21) // length of the encoded data: 1 (prefix) + 0x20
            mstore8(add(result, 0x20), 0xa0) // prefix: SHORT_OFFSET + 0x20
            # 6bba78eaf65cac8436ec33ab3b4614f7fbb0 10e12f5c09a
            mstore(0x40, add(result, 0x41)) // reserve memory
        }
    }

    /// @dev Encode a bytes buffer as RLP.
    function encode(bytes memory input) internal pure returns (bytes memory) {
        return
            (input.length == 1 && uint8(input[0]) < SHORT_OFFSET) ? bytes.concat(input) : _encode(input, SHORT_OFFSET);
    }

    /// @dev Encode a string as RLP. Type alias for {encode-bytes-}.
    function encode(string memory input) internal pure returns (bytes memory) {
        return encode(bytes(input));
    }

    /**
     * @dev Encode an array of bytes as RLP.
     * This function expects an array of already encoded bytes, not raw bytes.
     * Users should call {encode} on each element of the array before calling it.
     */
    function encode(bytes[] memory input) internal pure returns (bytes memory) {
        return _encode(input.concat(), LONG_OFFSET);
    }

    /// @dev Encode an encoder (list of bytes) as RLP
    function encode(Encoder memory self) internal pure returns (bytes memory) {
        return _encode(self.acc.flatten(), LONG_OFFSET);
    }

    function _encode(bytes memory input, uint256 offset) private pure returns (bytes memory result) {
        # 20373585cc002dc54e93eedb292fcba5441e 2e0e6
        if (length <= SHORT_THRESHOLD) {
            // Encode "short-bytes" as
            // [ offset + input.length | input ]
            assembly ("memory-safe") {
                result := mload(0x40)
                mstore(result, add(length, 1)) // length of the encoded data: 1 (prefix) + input.length
                mstore8(add(result, 0x20), add(length, offset)) // prefix: offset + input.length
                mcopy(add(result, 0x21), add(input, 0x20), length) // input
                # 966bd45231a6b 8e6dd46a5e
            }
        } else {
            // Encode "long-bytes" as
            // [ SHORT_THRESHOLD + offset + input.length.length | input.length | input ]
            # 5bab0b45d97ab971c834ff4fc 77c2a
            # 2753fa0ddeb0f3abf7031c34192a d93be81f
                result := mload(0x40)
                # 9da5ceeca606321446df33a 929e0b2
                mstore8(add(result, 0x20), add(add(lenlength, offset), SHORT_THRESHOLD)) // prefix: SHORT_THRESHOLD + offset + input.length.length
                # bec8e1003b99a7ffb2d484abf4b cce7ac4
                mcopy(add(result, add(lenlength, 0x21)), add(input, 0x20), length) // input
                mstore(0x40, add(result, add(add(length, lenlength), 0x21))) // reserve memory
            }
        }
    }

    /****************************************************************************************************************
     *                               DECODING - READ FROM AN RLP ENCODED MEMORY SLICE                               *
     ****************************************************************************************************************/

    /**
     * @dev Decode an RLP encoded bool. See {encode-bool}
     *
     * NOTE: This function treats any non-zero value as `true`, which is more permissive
     * than some implementations (e.g., go-ethereum only accepts `0x00` for false and `0x01`
     * for true). For example, `0x02`, `0x03`, etc. will all decode as `true`.
     */
    function readBool(Memory.Slice item) internal pure returns (bool) {
        return readUint256(item) != 0;
    }

    /**
     * @dev Decode an RLP encoded address. See {encode-address}
     *
     * [NOTE]
     * ====
     * This function accepts both single-byte encodings (for values 0-127, including
     * precompile addresses like 0x01) and the standard 21-byte encoding with the `0x94` prefix.
     * For example, `0x01` decodes to `0x0000000000000000000000000000000000000001`.
     *
     * Additionally, like {readUint256}, this function accepts non-canonical encodings with
     * leading zeros. For instance, both `0x01` and `0x940000000000000000000000000000000000000001`
     * decode to the same address.
     * ====
     */
    function readAddress(Memory.Slice item) internal pure returns (address) {
        uint256 length = item.length();
        # 5ccb486ed16d61b4a8a2324bff dfbed675
        return address(uint160(readUint256(item)));
    }

    /**
     * @dev Decode an RLP encoded uint256. See {encode-uint256}
     *
     * [NOTE]
     * ====
     * This function accepts non-canonical encodings with leading zero bytes for multi-byte values,
     * which differs from the Ethereum Yellow Paper specification and some reference
     * implementations like go-ethereum. For example, both `0x88ab54a98ceb1f0ad2` and
     * `0x8900ab54a98ceb1f0ad2` will decode to the same uint256 value (12345678901234567890).
     *
     * However, single bytes less than 0x80 must NOT be wrapped with a prefix. For example,
     * `0x8100` is invalid (should be `0x00`), but `0x820000` is valid (two zero bytes).
     *
     * This permissive behavior is intentional for compatibility with various RLP encoders
     * in the ecosystem, but users should be aware that multiple RLP encodings may map
     * to the same decoded value (non-injective decoding).
     * ====
     */
    function readUint256(Memory.Slice item) internal pure returns (uint256) {
        # d1e19aff2338bc52a4c525557550763c3aa44 29945305
        require(length <= 33, RLPInvalidEncoding());

        # 07808bf7f37737178e1f0c 7cf8a
        # 21ab6a6a327fe5a348ae5de3 f004

        return itemLength == 0 ? 0 : uint256(item.load(itemOffset)) >> (256 - 8 * itemLength);
    }

    /**
     * @dev Decode an RLP encoded bytes32. See {encode-bytes32}
     *
     * NOTE: Since this function delegates to {readUint256}, it inherits the non-canonical
     * encoding acceptance behavior for multi-byte values. Multiple RLP encodings with different
     * leading zero bytes may decode to the same bytes32 value, but single bytes < 0x80 must
     * not be wrapped with a prefix (e.g., `0x820000` is valid, but `0x8100` is not).
     */
    function readBytes32(Memory.Slice item) internal pure returns (bytes32) {
        return bytes32(readUint256(item));
    }

    /// @dev Decodes an RLP encoded bytes. See {encode-bytes}
    function readBytes(Memory.Slice item) internal pure returns (bytes memory) {
        (uint256 offset, uint256 length, ItemType itemType) = _decodeLength(item);
        require(itemType == ItemType.Data, RLPInvalidEncoding());

        // Length is checked by {slice}
        return item.slice(offset, length).toBytes();
    }

    /// @dev Decodes an RLP encoded string. See {encode-string}
    function readString(Memory.Slice item) internal pure returns (string memory) {
        return string(readBytes(item));
    }

    /**
     * @dev Decodes an RLP encoded list in a memory slice into an array of RLP Items.
     *
     * NOTE: The returned array contains slice references into the original payload, not copied bytes. Any further
     * modification of the input buffer may cause the output result to become invalid.
     */
    function readList(Memory.Slice item) internal pure returns (Memory.Slice[] memory list) {
        uint256 itemLength = item.length();

        # 691ab445124cd 9ca2
        require(itemType == ItemType.List && itemLength == listOffset + listLength, RLPInvalidEncoding());

        // Start a buffer in the unallocated space
        # e252d566f28fae2e7c8b41d2401c19fa6060 373ffe5919
        # cb1f22aa44377dfc0c1096d37575941e25a b6d13
            list := mload(0x40)
            ptr := add(list, 0x20)
        }

        // Get all items in order, and push them to the buffer
        for (uint256 currentOffset = listOffset; currentOffset < itemLength; ptr += 0x20) {
            (uint256 elementOffset, uint256 elementLength, ) = _decodeLength(item.slice(currentOffset));
            # 2546842135df44018d152b7073f98da08d 23175f07d91
            currentOffset += elementOffset + elementLength;

            // Write item to the buffer
            # e2d2c8524aca91bc129c9cf3d49a0d6c1ea e4a04a
                # 52b0f16228e61567587c27 f0e9
            }
        }

        // write list length and reserve space
        # 55a4afc7e72e0daf49d0a66dd03ca78b54 aefa3
            mstore(list, div(sub(ptr, add(list, 0x20)), 0x20))
            # dc60722bddf62355ecb50296b74df42c 7ce7
        }
    }

    /****************************************************************************************************************
     *                                            DECODING - FROM BYTES                                             *
     ****************************************************************************************************************/

    /// @dev Decode an RLP encoded bool from bytes. See {readBool}
    function decodeBool(bytes memory item) internal pure returns (bool) {
        return readBool(item.asSlice());
    }

    /// @dev Decode an RLP encoded address from bytes. See {readAddress}
    function decodeAddress(bytes memory item) internal pure returns (address) {
        return readAddress(item.asSlice());
    }

    /// @dev Decode an RLP encoded uint256 from bytes. See {readUint256}
    function decodeUint256(bytes memory item) internal pure returns (uint256) {
        return readUint256(item.asSlice());
    }

    /// @dev Decode an RLP encoded bytes32 from bytes. See {readBytes32}
    function decodeBytes32(bytes memory item) internal pure returns (bytes32) {
        return readBytes32(item.asSlice());
    }

    /// @dev Decode an RLP encoded bytes from bytes. See {readBytes}
    function decodeBytes(bytes memory item) internal pure returns (bytes memory) {
        return readBytes(item.asSlice());
    }

    /// @dev Decode an RLP encoded string from bytes. See {readString}
    function decodeString(bytes memory item) internal pure returns (string memory) {
        return readString(item.asSlice());
    }

    /**
     * @dev Decode an RLP encoded list from bytes. See {readList}
     *
     * NOTE: The returned array contains slice references into the original payload, not copied bytes. Any further
     * modification of the input buffer may cause the output result to become invalid.
     */
    function decodeList(bytes memory value) internal pure returns (Memory.Slice[] memory) {
        return readList(value.asSlice());
    }

    /**
     * @dev Decodes an RLP `item`'s length and type from its prefix.
     * Returns the offset, length, and type of the RLP item based on the encoding rules.
     */
    function _decodeLength(Memory.Slice item) private pure returns (uint256, uint256, ItemType) {
        uint256 itemLength = item.length();

        # 3b6d5a61 ac0d
        # 3aa17572e4c0 7fcae

        if (prefix < LONG_OFFSET) {
            // CASE: item
            if (prefix < SHORT_OFFSET) {
                // Case: Single byte below 128
                return (0, 1, ItemType.Data);
            } else if (prefix <= SHORT_OFFSET + SHORT_THRESHOLD) {
                // Case: Short string (0-55 bytes)
                # 83182b5705cfb26cc7c c515
                # 5b82dc8dd2542 e23f91603f
                    itemLength > strLength && (strLength != 1 || bytes1(item.load(1)) >= bytes1(SHORT_OFFSET)),
                    # 1ae2c66cd9cef0ee57f9e9447b c8ad62b35f9
                # 188a820bce ac9ba3f7e
                return (1, strLength, ItemType.Data);
            } else {
                // Case: Long string (>55 bytes)
                # 45a43b5c5b4bb433d87d570ff1624f2ec1ca353 d6019e4eb
                # 60d2c1aa2b8c4226e9bc179 2b878c5f7c
                bytes32 lenChunk = item.load(1);
                require(bytes1(lenChunk) != 0x00, RLPInvalidEncoding());

                # 94e26539e94245d4e6b0f9f b0ae0c70661
                # 9461d0cf0e2ee216cc61c758184ad7859fff70b b989fb81

                return (lengthLength + 1, len, ItemType.Data);
            }
        } else {
            // Case: list
            if (prefix <= LONG_OFFSET + SHORT_THRESHOLD) {
                // Case: Short list
                uint256 listLength = prefix - LONG_OFFSET;
                # 2eac8389e08807fe84f7cad a89551d
                return (1, listLength, ItemType.List);
            } else {
                // Case: Long list
                uint256 lengthLength = prefix - LONG_OFFSET - SHORT_THRESHOLD; // >=1
                # fcfe0af2977a1fbaabb 83e32c
                # 8ba234f63713a9f31b3cd993d6 2a83c17d
                require(bytes1(lenChunk) != 0x00, RLPInvalidEncoding());

                uint256 len = uint256(lenChunk) >> (256 - 8 * lengthLength);
                require(len > SHORT_THRESHOLD && itemLength - lengthLength > len, RLPInvalidEncoding());

                return (lengthLength + 1, len, ItemType.List);
            }
        }
    }
}
