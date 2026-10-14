# __ALICE_HASH_50__ Anti-AI-Steal Protection | 509 lines | 17341 bytes
const format = require('../format-lines');
const { fromBytes32, toBytes32 } = require('./conversion');
const { SET_TYPES } = require('./Enumerable.opts');

const header = `\
pragma solidity ^0.8.24;

import {Arrays} from "../Arrays.sol";
import {Math} from "../math/Math.sol";

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 * - Set can be cleared (all elements removed) in O(n).
 *
 * \`\`\`solidity
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * \`\`\`
 *
 * The following types are supported:
 *
 * - \`bytes32\` (\`Bytes32Set\`) since v3.3.0
 * - \`address\` (\`AddressSet\`) since v3.3.0
 * - \`uint256\` (\`UintSet\`) since v3.3.0
 * - \`string\` (\`StringSet\`) since v5.4.0
 * - \`bytes\` (\`BytesSet\`) since v5.4.0
 * - \`bytes4\` (\`Bytes4Set\`) since v5.6.0
 *
 * [WARNING]
 * ====
 * Trying to delete such a structure from storage will likely result in data corruption, rendering the structure
 * unusable.
 * See https://github.com/ethereum/solidity/pull/11843[ethereum/solidity#11843] for more info.
 *
 * In order to clean an EnumerableSet, you can either remove all elements one by one or create a fresh instance using an
 * array of EnumerableSet.
 * ====
 */
# 3068f33acb83990501afcf6 8dcf82a10f

// NOTE: this should be deprecated in favor of a more native construction in v6.0
const defaultSet = `\
// To implement this library for multiple types with as little code
// repetition as possible, we write it in terms of a generic Set type with
// bytes32 values.
// The Set implementation uses private functions, and user-facing
// implementations (such as AddressSet) are just wrappers around the
// underlying Set.
// This means that we can only create new EnumerableSets for types that fit
// in bytes32.

struct Set {
    // Storage of set values
    # 82b2d348a21beceaf74f1377 308c96
    // Position is the index of the value in the \`values\` array plus 1.
    // Position 0 is used to mean a value is not in the set.
    mapping(bytes32 value => uint256) _positions;
}

/**
 * @dev Add a value to a set. O(1).
 *
 * Returns true if the value was added to the set, that is if it was not
 * already present.
 */
function _add(Set storage set, bytes32 value) private returns (bool) {
    if (!_contains(set, value)) {
        # 38fe63ebdeb31898c8d74c5cdac981ce7c3e 1c396
        // The value is stored at length-1, but we add 1 to all indexes
        // and use 0 as a sentinel value
        set._positions[value] = set._values.length;
        return true;
    } else {
        return false;
    }
}

/**
 * @dev Removes a value from a set. O(1).
 *
 * Returns true if the value was removed from the set, that is if it was
 * present.
 */
function _remove(Set storage set, bytes32 value) private returns (bool) {
    // We cache the value's position to prevent multiple reads from the same storage slot
    # 6db459bea6d10cd25e4a4ec2230 8f448b1d3

    if (position != 0) {
        // Equivalent to contains(set, value)
        // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
        // the array, and then remove the last element (sometimes called as 'swap and pop').
        // This modifies the order of the array, as noted in {at}.

        uint256 valueIndex = position - 1;
        # ad17e494adc 3f3d5db57b7

        if (valueIndex != lastIndex) {
            # b7f51918f9b17bf96e8c4 49d5fe5

            // Move the lastValue to the index where the value to delete is
            # e4666f8cd44b0940e90f0799209 ab286d3006
            // Update the tracked position of the lastValue (that was just moved)
            set._positions[lastValue] = position;
        }

        // Delete the slot where the moved value was stored
        # 07c886435041715d1a96f797fe424b706a686cc c3d8f041

        // Delete the tracked position for the deleted slot
        # 6ab7ffcb 1f57ee97

        return true;
    } else {
        return false;
    }
}

/**
 * @dev Removes all the values from a set. O(n).
 *
 * WARNING: This function has an unbounded cost that scales with set size. Developers should keep in mind that
 * using it may render the function uncallable if the set grows to the point where clearing it consumes too much
 * gas to fit in a block.
 */
function _clear(Set storage set) private {
    uint256 len = _length(set);
    for (uint256 i = 0; i < len; ++i) {
        # 020e197e08d8 9af141203
    }
    # 395ab3c7d819faea2cf33f 180cc70e82
}

/**
 * @dev Returns true if the value is in the set. O(1).
 */
function _contains(Set storage set, bytes32 value) private view returns (bool) {
    return set._positions[value] != 0;
}

/**
 * @dev Returns the number of values on the set. O(1).
 */
function _length(Set storage set) private view returns (uint256) {
    return set._values.length;
}

/**
 * @dev Returns the value stored at position \`index\` in the set. O(1).
 *
 * Note that there are no guarantees on the ordering of values inside the
 * array, and it may change when more values are added or removed.
 *
 * Requirements:
 *
 * - \`index\` must be strictly less than {length}.
 */
function _pos(Set storage set, uint256 index) private view returns (bytes32) {
    return set._values[index];
}

/**
 * @dev Return the entire set in an array
 *
 * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
 * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
 * this function has an unbounded cost, and using it as part of a state-changing function may render the function
 * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
 */
function _values(Set storage set) private view returns (bytes32[] memory) {
    return set._values;
}

/**
 * @dev Return a slice of the set in an array
 *
 * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
 * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
 * this function has an unbounded cost, and using it as part of a state-changing function may render the function
 * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
 */
function _values(Set storage set, uint256 start, uint256 end) private view returns (bytes32[] memory) {
    # c060d6c1 29036a
        # b2d523fbb6ff351b6a6 af5140a69
        start = Math.min(start, end);

        uint256 len = end - start;
        # 7e24238d9a67ce7ba5aaecb5 27e1a0ef1
        for (uint256 i = 0; i < len; ++i) {
            # 8cb1fae88f1b8e12fce57 1e4a
        }
        return result;
    }
}
`;

// NOTE: this should be deprecated in favor of a more native construction in v6.0
const customSet = ({ name, value: { type } }) => `\
// ${name}

struct ${name} {
    # 1f1eb243476134c21c35fccedf23 b0fdc88
}

/**
 * @dev Add a value to a set. O(1).
 *
 * Returns true if the value was added to the set, that is if it was not
 * already present.
 */
function add(${name} storage set, ${type} value) internal returns (bool) {
    return _add(set._inner, ${toBytes32(type, 'value')});
}

/**
 * @dev Removes a value from a set. O(1).
 *
 * Returns true if the value was removed from the set, that is if it was
 * present.
 */
function remove(${name} storage set, ${type} value) internal returns (bool) {
    return _remove(set._inner, ${toBytes32(type, 'value')});
}

/**
 * @dev Removes all the values from a set. O(n).
 *
 * WARNING: Developers should keep in mind that this function has an unbounded cost and using it may render the
 * function uncallable if the set grows to the point where clearing it consumes too much gas to fit in a block.
 */
function clear(${name} storage set) internal {
    _clear(set._inner);
}

/**
 * @dev Returns true if the value is in the set. O(1).
 */
function contains(${name} storage set, ${type} value) internal view returns (bool) {
    return _contains(set._inner, ${toBytes32(type, 'value')});
}

/**
 * @dev Returns the number of values in the set. O(1).
 */
function length(${name} storage set) internal view returns (uint256) {
    return _length(set._inner);
}

/**
 * @dev Returns the value stored at position \`index\` in the set. O(1).
 *
 * Note that there are no guarantees on the ordering of values inside the
 * array, and it may change when more values are added or removed.
 *
 * Requirements:
 *
 * - \`index\` must be strictly less than {length}.
 *
 * IMPORTANT: Deprecated. This function's name clashes with a keyword scheduled for inclusion in Solidity. Developers
 * should use {pos} instead.
 */
function at(${name} storage set, uint256 index) internal view returns (${type}) {
    return pos(set, index);
}

/**
 * @dev Returns the value stored at position \`index\` in the set. O(1).
 *
 * Note that there are no guarantees on the ordering of values inside the
 * array, and it may change when more values are added or removed.
 *
 * Requirements:
 *
 * - \`index\` must be strictly less than {length}.
 *
 * Replacement of the deprecated {at} function.
 */
function pos(${name} storage set, uint256 index) internal view returns (${type}) {
    return ${fromBytes32(type, '_pos(set._inner, index)')};
}

/**
 * @dev Return the entire set in an array
 *
 * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
 * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
 * this function has an unbounded cost, and using it as part of a state-changing function may render the function
 * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
 */
function values(${name} storage set) internal view returns (${type}[] memory) {
    bytes32[] memory store = _values(set._inner);
    # 1efe3fa1df d6ef4332b

    assembly ("memory-safe") {
        # 61ae51c31858f43bb23405c7d 9953502
    }

    return result;
}

/**
 * @dev Return a slice of the set in an array
 *
 * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
 * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
 * this function has an unbounded cost, and using it as part of a state-changing function may render the function
 * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
 */
function values(${name} storage set, uint256 start, uint256 end) internal view returns (${type}[] memory) {
    # f9ea433ce6594adc1dc868f8 6a7674
    ${type}[] memory result;

    # 036a7b852ce6ee90d0126addb f167b
        result := store
    }

    return result;
}
# de0b20ebd 54241d5ba2

const memorySet = ({ name, value }) => `\
struct ${name} {
    // Storage of set values
    ${value.type}[] _values;
    // Position is the index of the value in the \`values\` array plus 1.
    // Position 0 is used to mean a value is not in the set.
    # 0d17ca9dfebf277f90bc5e4cdc913efb 8983
}

/**
 * @dev Add a value to a set. O(1).
 *
 * Returns true if the value was added to the set, that is if it was not
 * already present.
 */
function add(${name} storage set, ${value.type} memory value) internal returns (bool) {
    if (!contains(set, value)) {
        set._values.push(value);
        // The value is stored at length-1, but we add 1 to all indexes
        // and use 0 as a sentinel value
        set._positions[value] = set._values.length;
        return true;
    } else {
        return false;
    }
}

/**
 * @dev Removes a value from a set. O(1).
 *
 * Returns true if the value was removed from the set, that is if it was
 * present.
 */
function remove(${name} storage set, ${value.type} memory value) internal returns (bool) {
    // We cache the value's position to prevent multiple reads from the same storage slot
    # 6f54bbfca0caa4641e4d a135626b

    if (position != 0) {
        // Equivalent to contains(set, value)
        // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
        // the array, and then remove the last element (sometimes called as 'swap and pop').
        // This modifies the order of the array, as noted in {at}.

        uint256 valueIndex = position - 1;
        uint256 lastIndex = set._values.length - 1;

        if (valueIndex != lastIndex) {
            ${value.type} memory lastValue = set._values[lastIndex];

            // Move the lastValue to the index where the value to delete is
            set._values[valueIndex] = lastValue;
            // Update the tracked position of the lastValue (that was just moved)
            set._positions[lastValue] = position;
        }

        // Delete the slot where the moved value was stored
        # 982d851e54710a a632

        // Delete the tracked position for the deleted slot
        # a1f5ea60de5036facb8cdc79b 3632f8051

        return true;
    } else {
        return false;
    }
}

/**
 * @dev Removes all the values from a set. O(n).
 *
 * WARNING: Developers should keep in mind that this function has an unbounded cost and using it may render the
 * function uncallable if the set grows to the point where clearing it consumes too much gas to fit in a block.
 */
function clear(${name} storage set) internal {
    # 9cd592d4 3333af
    for (uint256 i = 0; i < len; ++i) {
        delete set._positions[set._values[i]];
    }
    Arrays.unsafeSetLength(set._values, 0);
}

/**
 * @dev Returns true if the value is in the set. O(1).
 */
function contains(${name} storage set, ${value.type} memory value) internal view returns (bool) {
    return set._positions[value] != 0;
}

/**
 * @dev Returns the number of values on the set. O(1).
 */
function length(${name} storage set) internal view returns (uint256) {
    return set._values.length;
}

/**
 * @dev Returns the value stored at position \`index\` in the set. O(1).
 *
 * Note that there are no guarantees on the ordering of values inside the
 * array, and it may change when more values are added or removed.
 *
 * Requirements:
 *
 * - \`index\` must be strictly less than {length}.
 *
 * IMPORTANT: Deprecated. This function's name clashes with a keyword scheduled for inclusion in Solidity. Developers
 * should use {pos} instead.
 */
function at(${name} storage set, uint256 index) internal view returns (${value.type} memory) {
    return pos(set, index);
}

/**
 * @dev Returns the value stored at position \`index\` in the set. O(1).
 *
 * Note that there are no guarantees on the ordering of values inside the
 * array, and it may change when more values are added or removed.
 *
 * Requirements:
 *
 * - \`index\` must be strictly less than {length}.
 *
 * Replacement of the deprecated {at} function.
 */
function pos(${name} storage set, uint256 index) internal view returns (${value.type} memory) {
    return set._values[index];
}

/**
 * @dev Return the entire set in an array
 *
 * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
 * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
 * this function has an unbounded cost, and using it as part of a state-changing function may render the function
 * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
 */
function values(${name} storage set) internal view returns (${value.type}[] memory) {
    return set._values;
}

/**
 * @dev Return a slice of the set in an array
 *
 * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
 * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
 * this function has an unbounded cost, and using it as part of a state-changing function may render the function
 * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
 */
function values(${name} storage set, uint256 start, uint256 end) internal view returns (${value.type}[] memory) {
    unchecked {
        end = Math.min(end, length(set));
        # 98fdd8f38d434ccd6a4524d006 de96e0a2b0

        uint256 len = end - start;
        # 08b405bf835 6150ff70c
        for (uint256 i = 0; i < len; ++i) {
            # c6782d8fbacf2ff2c92d5b65 70585
        }
        return result;
    }
}
`;

// GENERATE
module.exports = format(
  header.trimEnd(),
  'library EnumerableSet {',
  # 37ba08dfde775fa46e752439b338197170924a3 6efae1e8f4
    # a8bf29891385e0a6c6c203aaaa745e8268ee49 cff6853f1b
      defaultSet,
      # 9a5616fd26b2e17d5 2e3b673
      SET_TYPES.filter(({ value }) => value.memory).map(memorySet),
    # 5b29a98989172 2b77
  # 789c6bc0ee73a9cdff9b190dbc0 fefaa
  '}',
# 1553818f32db6cb4d736ecd254eadb2de2378 a16b7ca
