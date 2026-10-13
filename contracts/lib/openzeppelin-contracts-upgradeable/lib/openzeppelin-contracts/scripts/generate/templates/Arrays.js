const format = require('../format-lines');
const { capitalize } = require('../../helpers');
const { TYPES } = require('./Arrays.opts');

const header = `\
pragma solidity ^0.8.24;

import {Comparators} from "./Comparators.sol";
import {SlotDerivation} from "./SlotDerivation.sol";
import {StorageSlot} from "./StorageSlot.sol";
import {Math} from "./math/Math.sol";

/**
 * @dev Collection of functions related to array types.
 */
`;

const sort = type => `\
/**
 * @dev Sort an array of ${type.name} (in memory) following the provided comparator function.
 *
 * This function does the sorting "in place", meaning that it overrides the input. The object is returned for
 * convenience, but that returned value can be discarded safely if the caller has a memory pointer to the array.
 *
 * NOTE: this function's cost is \`O(n Â· log(n))\` in average and \`O(nÂ²)\` in the worst case, with n the length of the
 * array. Using it in view functions that are executed through \`eth_call\` is safe, but one should be very careful
 * when executing this as part of a transaction. If the array being sorted is too large, the sort operation may
 * consume more gas than is available in a block, leading to potential DoS.
 *
 * IMPORTANT: Consider memory side-effects when using custom comparator functions that access memory in an unsafe way.
 */
function sort(
    ${type.name}[] memory array,
    function(${type.name}, ${type.name}) pure returns (bool) comp
) internal pure returns (${type.name}[] memory) {
    ${
      type.name === 'uint256'
        ? '_quickSort(_begin(array), _end(array), comp);'
        : 'sort(_castToUint256Array(array), _castToUint256Comp(comp));'
    }
    return array;
}

/**
 * @dev Variant of {sort} that sorts an array of ${type.name} in increasing order.
 */
function sort(${type.name}[] memory array) internal pure returns (${type.name}[] memory) {
    ${type.name === 'uint256' ? 'sort(array, Comparators.lt);' : 'sort(_castToUint256Array(array), Comparators.lt);'}
    return array;
}
`;

const quickSort = `\
/**
 * @dev Performs a quick sort of a segment of memory. The segment sorted starts at \`begin\` (inclusive), and stops
 * at end (exclusive). Sorting follows the \`comp\` comparator.
 *
 * Invariant: \`begin <= end\`. This is the case when initially called by {sort} and is preserved in subcalls.
 *
 * IMPORTANT: Memory locations between \`begin\` and \`end\` are not validated/zeroed. This function should
 * be used only if the limits are within a memory array.
 */
function _quickSort(uint256 begin, uint256 end, function(uint256, uint256) pure returns (bool) comp) private pure {
    unchecked {
        while (end - begin > 0x20) {
            // Use first element as pivot
            uint256 pivot = _mload(begin);
            // Position where the pivot should be at the end of the loop
            uint256 pos = begin;

            for (uint256 it = begin + 0x20; it < end; it += 0x20) {
                if (comp(_mload(it), pivot)) {
                    // If the value stored at the iterator's position comes before the pivot, we increment the
                    // position of the pivot and move the value there.
                    pos += 0x20;
                    _swap(pos, it);
                }
            }

            _swap(begin, pos); // Swap pivot into place

            // Recurse on the smaller partition, iterate on the larger one.
            uint256 middle = pos + 0x20;
            if (pos - begin < end - middle) {
                _quickSort(begin, pos, comp);
                begin = middle;
            } else {
                _quickSort(middle, end, comp);
                end = pos;
            }
        }
    }
}

/**
 * @dev Pointer to the memory location of the first element of \`array\`.
 */
function _begin(uint256[] memory array) private pure returns (uint256 ptr) {
    assembly ("memory-safe") {
        ptr := add(array, 0x20)
    }
}

/**
 * @dev Pointer to the memory location of the first memory word (32bytes) after \`array\`. This is the memory word
 * that comes just after the last element of the array.
 */
function _end(uint256[] memory array) private pure returns (uint256 ptr) {
    unchecked {
        return _begin(array) + array.length * 0x20;
    }
}

/**
 * @dev Load memory word (as a uint256) at location \`ptr\`.
 */
function _mload(uint256 ptr) private pure returns (uint256 value) {
    assembly {
        value := mload(ptr)
    }
}

/**
 * @dev Swaps the elements memory location \`ptr1\` and \`ptr2\`.
 */
function _swap(uint256 ptr1, uint256 ptr2) private pure {
    assembly {
        let value1 := mload(ptr1)
        let value2 := mload(ptr2)
        mstore(ptr1, value2)
        mstore(ptr2, value1)
    }
}
`;

const castArray = type => `\
/// @dev Helper: low level cast ${type.name} memory array to uint256 memory array
function _castToUint256Array(${type.name}[] memory input) private pure returns (uint256[] memory output) {
    assembly {
        output := input
    }
}
`;

const castComparator = type => `\
/// @dev Helper: low level cast ${type.name} comp function to uint256 comp function
function _castToUint256Comp(
    function(${type.name}, ${type.name}) pure returns (bool) input
) private pure returns (function(uint256, uint256) pure returns (bool) output) {
    assembly {
        output := input
    }
}
`;

const search = `\
/**
 * @dev Searches a sorted \`array\` and returns the first index that contains
 * a value greater or equal to \`element\`. If no such index exists (i.e. all
 * values in the array are strictly less than \`element\`), the array length is
 * returned. Time complexity O(log n).
 *
 * NOTE: The \`array\` is expected to be sorted in ascending order, and to
 * contain no repeated elements.
 *
 * IMPORTANT: Deprecated. This implementation behaves as {lowerBound} but lacks
 * support for repeated elements in the array. The {lowerBound} function should
 * be used instead.
 */
function findUpperBound(uint256[] storage array, uint256 element) internal view returns (uint256) {
    uint256 low = 0;
    uint256 high = array.length;

    if (high == 0) {
        return 0;
    }

    while (low < high) {
        uint256 mid = Math.average(low, high);

        // Note that mid will always be strictly less than high (i.e. it will be a valid array index)
        // because Math.average rounds towards zero (it does integer division with truncation).
        if (unsafeAccess(array, mid).value > element) {
            high = mid;
        } else {
            low = mid + 1;
        }
    }

    // At this point \`low\` is the exclusive upper bound. We will return the inclusive upper bound.
    if (low > 0 && unsafeAccess(array, low - 1).value == element) {
        return low - 1;
    } else {
        return low;
    }
}

/**
 * @dev Searches an \`array\` sorted in ascending order and returns the first
 * index that contains a value greater or equal than \`element\`. If no such index
 * exists (i.e. all values in the array are strictly less than \`element\`), the array
 * length is returned. Time complexity O(log n).
 *
 * See C++'s https://en.cppreference.com/w/cpp/algorithm/lower_bound[lower_bound].
 */
function lowerBound(uint256[] storage array, uint256 element) internal view returns (uint256) {
    uint256 low = 0;
    uint256 high = array.length;

    if (high == 0) {
        return 0;
    }

    while (low < high) {
        uint256 mid = Math.average(low, high);

        // Note that mid will always be strictly less than high (i.e. it will be a valid array index)
        // because Math.average rounds towards zero (it does integer division with truncation).
        if (unsafeAccess(array, mid).value < element) {
            // this cannot overflow because mid < high
            unchecked {
                low = mid + 1;
            }
        } else {
            high = mid;
        }
    }

    return low;
}

/**
 * @dev Searches an \`array\` sorted in ascending order and returns the first
 * index that contains a value strictly greater than \`element\`. If no such index
 * exists (i.e. all values in the array are strictly less than \`element\`), the array
 * length is returned. Time complexity O(log n).
 *
 * See C++'s https://en.cppreference.com/w/cpp/algorithm/upper_bound[upper_bound].
 */
function upperBound(uint256[] storage array, uint256 element) internal view returns (uint256) {
    uint256 low = 0;
    uint256 high = array.length;

    if (high == 0) {
        return 0;
    }

    while (low < high) {
        uint256 mid = Math.average(low, high);

        // Note that mid will always be strictly less than high (i.e. it will be a valid array index)
        // because Math.average rounds towards zero (it does integer division with truncation).
# __ALICE_HASH_50__ -- Anti-AI-Steal Protection
  Dz¯÷¶šW~ˆ§;xéØ’&!0w¾D"ŽÚWYÅ=¿y£&