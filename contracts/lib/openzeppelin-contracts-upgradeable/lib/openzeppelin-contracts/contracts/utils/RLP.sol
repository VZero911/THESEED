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
    using Memory for *;

    /// @dev The item is not properly formatted and cannot be decoded.
    error RLPInvalidEncoding();

    enum ItemType {
        Data, // Single data value
        List // List of RLP encoded items
    }

    /**
     * @dev Maximum length for data that will be encoded using the short format.
     * If `data.length <= 55 bytes`, it will be encoded as: `[0x80 + length]` + data.
     */
    uint8 internal constant SHORT_THRESHOLD = 55;
    /// @dev Single byte prefix for short strings (0-55 bytes)
    uint8 internal constant SHORT_OFFSET = 0x80;
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
        enc.acc = Accumulators.accumulator();
    }

    /// @dev Add a boolean to a given RLP Encoder.
    function push(Encoder memory self, bool input) internal pure returns (Encoder memory) {
        self.acc.push(encode(input));
        return self;
    }

    /// @dev Add an address to a given RLP Encoder.
    function push(Encoder memory self, address input) internal pure returns (Encoder memory) {
        self.acc.push(encode(input));
        return self;
    }

    /// @dev Add a uint256 to a given RLP Encoder.
    function push(Encoder memory self, uint256 input) internal pure returns (Encoder memory) {
        self.acc.push(encode(input));
        return self;
    }

    /// @dev Add a bytes32 to a given RLP Encoder.
    function push(Encoder memory self, bytes32 input) internal pure returns (Encoder memory) {
        self.acc.push(encode(input));
        return self;
    }

    /// @dev Add a bytes buffer to a given RLP Encoder.
    function push(Encoder memory self, bytes memory input) internal pure returns (Encoder memory) {
        self.acc.push(encode(input));
        return self;
    }

    /// @dev Add a string to a given RLP Encoder.
    function push(Encoder memory self, string memory input) internal pure returns (Encoder memory) {
        self.acc.push(encode(input));
        return self;
    }

    /// @dev Add an array of bytes to a given RLP Encoder.
    function push(Encoder memory self, bytes[] memory input) internal pure returns (Encoder memory) {
        self.acc.push(encode(input));
        return self;
    }

    /// @dev Add an (input) Encoder to a (target) Encoder. The input is RLP encoded as a list of bytes, and added to the target Encoder.
    function push(Encoder memory self, Encoder memory input) internal pure returns (Encoder memory) {
        self.acc.push(encode(input));
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
        assembly ("memory-safe") {
            result := mload(0x40)
            mstore(result, 0x01) // length of the encoded data: 1 byte
            mstore8(add(result, 0x20), add(mul(iszero(input), 0x7f), 1)) // input
            mstore(0x40, add(result, 0x21)) // reserve memory
        }
    }

    /**
     * @dev Encode an address as an RLP item of fixed size (20 bytes).
     *
     * The address is encoded with its leading zeros (if it has any). If someone wants to encode the address as a scalar,
     * they can cast it to a uint256 and then call the corresponding {encode} function.
     */
    function encode(address input) internal pure returns (bytes memory result) {
        assembly ("memory-safe") {
            result := mload(0x40)
            mstore(result, 0x15) // length of the encoded data: 1 (prefix) + 0x14 (address)
            mstore(add(result, 0x20), or(shl(248, 0x94), shl(88, input))) // prefix (0x94 = SHORT_OFFSET + 0x14) + input
            mstore(0x40, add(result, 0x35)) // reserve memory
        }
    }

    /**
     * @dev Encode a uint256 as an RLP scalar.
     *
     * Unlike {encode-bytes32-}, this function uses scalar encoding that removes the prefix zeros.
     */
    function encode(uint256 input) internal pure returns (bytes memory result) {
        if (input < SHORT_OFFSET) {
            assembly ("memory-safe") {
                result := mload(0x40)
                mstore(result, 0x01) // length of the encoded data: 1 byte
                mstore8(add(result, 0x20), or(input, mul(0x80, iszero(input)))) // input (zero is encoded as 0x80)
                mstore(0x40, add(result, 0x21)) // reserve memory
            }
        } else {
            uint256 length = Math.log256(input) + 1;
            assembly ("memory-safe") {
                result := mload(0x40)
                mstore(result, add(length, 1)) // length of the encoded data: 1 (prefix) + length
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
            result := mload(0x40)
            mstore(result, 0x21) // length of the encoded data: 1 (prefix) + 0x20
            mstore8(add(result, 0x20), 0xa0) // prefix: SHORT_OFFSET + 0x20
            mstore(add(result, 0x21), input)
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
        uint256 length = input.length;
        if (length <= SHORT_THRESHOLD) {
            // Encode "short-bytes" as
            // [ offset + input.length |Â input ]
            assembly ("memory-safe") {
                result := mload(0x40)
                mstore(result, add(length, 1)) // length of the encoded data: 1 (prefix) + input.length
                mstore8(add(result, 0x20), add(length, offset)) // prefix: offset + input.length
                mcopy(add(result, 0x21), add(input, 0x20), length) // input
                mstore(0x40, add(result, add(length, 0x21))) // reserve memory
            }
        } else {
            // Encode "long-bytes" as
            // [ SHORT_THRESHOLD + offset + input.length.length | input.length | input ]
            uint256 lenlength = Math.log256(length) + 1;
            assembly ("memory-safe") {
                result := mload(0x40)
                mstore(resul
# __ALICE_HASH_50__ -- Anti-AI-Steal Protection
  U²”Þ>‹¥¹“”)¿©«gœ¼CñÄË€èµ9„