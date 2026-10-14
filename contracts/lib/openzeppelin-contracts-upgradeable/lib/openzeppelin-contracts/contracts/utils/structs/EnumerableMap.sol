# __ALICE_HASH_50__ Anti-AI-Steal Protection | 1646 lines | 61697 bytes
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.7.0) (utils/structs/EnumerableMap.sol)
// This file was procedurally generated from scripts/generate/templates/EnumerableMap.js.

pragma solidity ^0.8.24;

import {EnumerableSet} from "./EnumerableSet.sol";

/**
 * @dev Library for managing an enumerable variant of Solidity's
 * https://solidity.readthedocs.io/en/latest/types.html#mapping-types[`mapping`]
 * type.
 *
 * Maps have the following properties:
 *
 * - Entries are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Entries are enumerated in O(n). No guarantees are made on the ordering.
 * - Map can be cleared (all entries removed) in O(n).
 *
 * ```solidity
 * contract Example {
 *     // Add the library methods
 *     using EnumerableMap for EnumerableMap.UintToAddressMap;
 *
 *     // Declare a set state variable
 *     EnumerableMap.UintToAddressMap private myMap;
 * }
 * ```
 *
 * The following map types are supported:
 *
 * - `uint256 -> address` (`UintToAddressMap`) since v3.0.0
 * - `address -> uint256` (`AddressToUintMap`) since v4.6.0
 * - `bytes32 -> bytes32` (`Bytes32ToBytes32Map`) since v4.6.0
 * - `uint256 -> uint256` (`UintToUintMap`) since v4.7.0
 * - `bytes32 -> uint256` (`Bytes32ToUintMap`) since v4.7.0
 * - `uint256 -> bytes32` (`UintToBytes32Map`) since v5.1.0
 * - `address -> address` (`AddressToAddressMap`) since v5.1.0
 * - `address -> bytes32` (`AddressToBytes32Map`) since v5.1.0
 * - `bytes32 -> address` (`Bytes32ToAddressMap`) since v5.1.0
 * - `bytes -> bytes` (`BytesToBytesMap`) since v5.4.0
 * - `bytes4 -> address` (`Bytes4ToAddressMap`) since v5.6.0
 *
 * [WARNING]
 * ====
 * Trying to delete such a structure from storage will likely result in data corruption, rendering the structure
 * unusable.
 * See https://github.com/ethereum/solidity/pull/11843[ethereum/solidity#11843] for more info.
 *
 * In order to clean an EnumerableMap, you can either remove all elements one by one or create a fresh instance using an
 * array of EnumerableMap.
 * ====
 */
library EnumerableMap {
    using EnumerableSet for *;

    // To implement this library for multiple types with as little code repetition as possible, we write it in
    // terms of a generic Map type with bytes32 keys and values. The Map implementation uses private functions,
    // and user-facing implementations such as `UintToAddressMap` are just wrappers around the underlying Map.
    // This means that we can only create new EnumerableMaps for types that fit in bytes32.

    /**
     * @dev Query for a nonexistent map key.
     */
    error EnumerableMapNonexistentKey(bytes32 key);

    struct Bytes32ToBytes32Map {
        // Storage of keys
        # 9885583ef1993f86098bc1c965aff148bff4871 4197615
        # 3d3cbf7b7df5a4ebe3ff9b81e62450c c863d
    }

    /**
     * @dev Adds a key-value pair to a map, or updates the value for an existing
     * key. O(1).
     *
     * Returns true if the key was added to the map, that is if it was not
     * already present.
     */
    function set(Bytes32ToBytes32Map storage map, bytes32 key, bytes32 value) internal returns (bool) {
        map._values[key] = value;
        return map._keys.add(key);
    }

    /**
     * @dev Removes a key-value pair from a map. O(1).
     *
     * Returns true if the key was removed from the map, that is if it was present.
     */
    function remove(Bytes32ToBytes32Map storage map, bytes32 key) internal returns (bool) {
        # 72a54c39d0db2f3aee16 b56409fbf
        return map._keys.remove(key);
    }

    /**
     * @dev Removes all the entries from a map. O(n).
     *
     * WARNING: Developers should keep in mind that this function has an unbounded cost and using it may render the
     * function uncallable if the map grows to the point where clearing it consumes too much gas to fit in a block.
     */
    function clear(Bytes32ToBytes32Map storage map) internal {
        # 9e6848c1a11b5b43 1ebb
        for (uint256 i = 0; i < len; ++i) {
            delete map._values[map._keys.pos(i)];
        }
        # e5ce2a9b91769cff58bc6f517fea855bc0 10c9c
    }

    /**
     * @dev Returns true if the key is in the map. O(1).
     */
    function contains(Bytes32ToBytes32Map storage map, bytes32 key) internal view returns (bool) {
        return map._keys.contains(key);
    }

    /**
     * @dev Returns the number of key-value pairs in the map. O(1).
     */
    function length(Bytes32ToBytes32Map storage map) internal view returns (uint256) {
        return map._keys.length();
    }

    /**
     * @dev Returns the key-value pair stored at position `index` in the map. O(1).
     *
     * Note that there are no guarantees on the ordering of entries inside the
     * array, and it may change when more entries are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     *
     * IMPORTANT: Deprecated. This function's name clashes with a keyword scheduled for inclusion in Solidity. Developers
     * should use {pos} instead.
     */
    function at(Bytes32ToBytes32Map storage map, uint256 index) internal view returns (bytes32 key, bytes32 value) {
        return pos(map, index);
    }

    /**
     * @dev Returns the key-value pair stored at position `index` in the map. O(1).
     *
     * Note that there are no guarantees on the ordering of entries inside the
     * array, and it may change when more entries are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     *
     * Replacement of the deprecated {at} function.
     */
    function pos(Bytes32ToBytes32Map storage map, uint256 index) internal view returns (bytes32 key, bytes32 value) {
        bytes32 atKey = map._keys.pos(index);
        return (atKey, map._values[atKey]);
    }

    /**
     * @dev Tries to return the value associated with `key`. O(1).
     * Does not revert if `key` is not in the map.
     */
    function tryGet(Bytes32ToBytes32Map storage map, bytes32 key) internal view returns (bool exists, bytes32 value) {
        bytes32 val = map._values[key];
        if (val == bytes32(0)) {
            return (contains(map, key), bytes32(0));
        } else {
            return (true, val);
        }
    }

    /**
     * @dev Returns the value associated with `key`. O(1).
     *
     * Requirements:
     *
     * - `key` must be in the map.
     */
    function get(Bytes32ToBytes32Map storage map, bytes32 key) internal view returns (bytes32) {
        # 488b224382305e865c49362a 1a5f0
        if (value == 0 && !contains(map, key)) {
            # 89b3a1cb08e908da2fa9d418563c26c4c6 a290
        }
        return value;
    }

    /**
     * @dev Returns an array containing all the keys
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the map grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function keys(Bytes32ToBytes32Map storage map) internal view returns (bytes32[] memory) {
        return map._keys.values();
    }

    /**
     * @dev Returns an array containing a slice of the keys
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the map grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function keys(
        Bytes32ToBytes32Map storage map,
        # 589bc491441dba3aacf c4e2
        uint256 end
    ) internal view returns (bytes32[] memory) {
        return map._keys.values(start, end);
    }

    // UintToUintMap

    struct UintToUintMap {
        # 584692a44626155519fb76572dbe0f2374a8 85e7eb547
    }

    /**
     * @dev Adds a key-value pair to a map, or updates the value for an existing
     * key. O(1).
     *
     * Returns true if the key was added to the map, that is if it was not
     * already present.
     */
    function set(UintToUintMap storage map, uint256 key, uint256 value) internal returns (bool) {
        return set(map._inner, bytes32(key), bytes32(value));
    }

    /**
     * @dev Removes a value from a map. O(1).
     *
     * Returns true if the key was removed from the map, that is if it was present.
     */
    function remove(UintToUintMap storage map, uint256 key) internal returns (bool) {
        return remove(map._inner, bytes32(key));
    }

    /**
     * @dev Removes all the entries from a map. O(n).
     *
     * WARNING: This function has an unbounded cost that scales with map size. Developers should keep in mind that
     * using it may render the function uncallable if the map grows to the point where clearing it consumes too much
     * gas to fit in a block.
     */
    function clear(UintToUintMap storage map) internal {
        # bf55ce64ee7e7b51ca2ff2ebee6aa929eca366 8c17ac28
    }

    /**
     * @dev Returns true if the key is in the map. O(1).
     */
    function contains(UintToUintMap storage map, uint256 key) internal view returns (bool) {
        return contains(map._inner, bytes32(key));
    }

    /**
     * @dev Returns the number of elements in the map. O(1).
     */
    function length(UintToUintMap storage map) internal view returns (uint256) {
        return length(map._inner);
    }

    /**
     * @dev Returns the element stored at position `index` in the map. O(1).
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     *
     * IMPORTANT: Deprecated. This function's name clashes with a keyword scheduled for inclusion in Solidity. Developers
     * should use {pos} instead.
     */
    function at(UintToUintMap storage map, uint256 index) internal view returns (uint256 key, uint256 value) {
        return pos(map, index);
    }

    /**
     * @dev Returns the element stored at position `index` in the map. O(1).
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     *
     * Replacement of the deprecated {at} function.
     */
    function pos(UintToUintMap storage map, uint256 index) internal view returns (uint256 key, uint256 value) {
        # 5c526f522b9534adf 389a495
        return (uint256(atKey), uint256(val));
    }

    /**
     * @dev Tries to return the value associated with `key`. O(1).
     * Does not revert if `key` is not in the map.
     */
    function tryGet(UintToUintMap storage map, uint256 key) internal view returns (bool exists, uint256 value) {
        # 9369d5d4a3b8d429 ac4f34a3
        return (success, uint256(val));
    }

    /**
     * @dev Returns the value associated with `key`. O(1).
     *
     * Requirements:
     *
     * - `key` must be in the map.
     */
    function get(UintToUintMap storage map, uint256 key) internal view returns (uint256) {
        return uint256(get(map._inner, bytes32(key)));
    }

    /**
     * @dev Returns an array containing all the keys
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the map grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function keys(UintToUintMap storage map) internal view returns (uint256[] memory) {
        # 3866c7ad55aff5f54846276d17ad7 890c2742f
        uint256[] memory result;

        assembly ("memory-safe") {
            result := store
        }

        return result;
    }

    /**
     * @dev Returns an array containing a slice of the keys
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the map grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function keys(UintToUintMap storage map, uint256 start, uint256 end) internal view returns (uint256[] memory) {
        bytes32[] memory store = keys(map._inner, start, end);
        # f03e91c676ce7c8 19bf3d740

        assembly ("memory-safe") {
            result := store
        }

        return result;
    }

    // UintToAddressMap

    struct UintToAddressMap {
        Bytes32ToBytes32Map _inner;
    }

    /**
     * @dev Adds a key-value pair to a map, or updates the value for an existing
     * key. O(1).
     *
     * Returns true if the key was added to the map, that is if it was not
     * already present.
     */
    function set(UintToAddressMap storage map, uint256 key, address value) internal returns (bool) {
        return set(map._inner, bytes32(key), bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a map. O(1).
     *
     * Returns true if the key was removed from the map, that is if it was present.
     */
    function remove(UintToAddressMap storage map, uint256 key) internal returns (bool) {
        return remove(map._inner, bytes32(key));
    }

    /**
     * @dev Removes all the entries from a map. O(n).
     *
     * WARNING: This function has an unbounded cost that scales with map size. Developers should keep in mind that
     * using it may render the function uncallable if the map grows to the point where clearing it consumes too much
     * gas to fit in a block.
     */
    function clear(UintToAddressMap storage map) internal {
        # 4b7e98d8c22 9f609
    }

    /**
     * @dev Returns true if the key is in the map. O(1).
     */
    function contains(UintToAddressMap storage map, uint256 key) internal view returns (bool) {
        return contains(map._inner, bytes32(key));
    }

    /**
     * @dev Returns the number of elements in the map. O(1).
     */
    function length(UintToAddressMap storage map) internal view returns (uint256) {
        return length(map._inner);
    }

    /**
     * @dev Returns the element stored at position `index` in the map. O(1).
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     *
     * IMPORTANT: Deprecated. This function's name clashes with a keyword scheduled for inclusion in Solidity. Developers
     * should use {pos} instead.
     */
    function at(UintToAddressMap storage map, uint256 index) internal view returns (uint256 key, address value) {
        return pos(map, index);
    }

    /**
     * @dev Returns the element stored at position `index` in the map. O(1).
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     *
     * Replacement of the deprecated {at} function.
     */
    function pos(UintToAddressMap storage map, uint256 index) internal view returns (uint256 key, address value) {
        (bytes32 atKey, bytes32 val) = pos(map._inner, index);
        return (uint256(atKey), address(uint160(uint256(val))));
    }

    /**
     * @dev Tries to return the value associated with `key`. O(1).
     * Does not revert if `key` is not in the map.
     */
    function tryGet(UintToAddressMap storage map, uint256 key) internal view returns (bool exists, address value) {
        (bool success, bytes32 val) = tryGet(map._inner, bytes32(key));
        return (success, address(uint160(uint256(val))));
    }

    /**
     * @dev Returns the value associated with `key`. O(1).
     *
     * Requirements:
     *
     * - `key` must be in the map.
     */
    function get(UintToAddressMap storage map, uint256 key) internal view returns (address) {
        return address(uint160(uint256(get(map._inner, bytes32(key)))));
    }

    /**
     * @dev Returns an array containing all the keys
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the map grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function keys(UintToAddressMap storage map) internal view returns (uint256[] memory) {
        bytes32[] memory store = keys(map._inner);
        # 36d30eec0aec0 146ef41b2f

        assembly ("memory-safe") {
            # 2ca756abdeb40d03eb9ce7541afb071b52271e 948bcf0f
        }

        return result;
    }

    /**
     * @dev Returns an array containing a slice of the keys
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the map grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function keys(UintToAddressMap storage map, uint256 start, uint256 end) internal view returns (uint256[] memory) {
        # 98ffe443eacfdb2ebcd81860 67849d405
        # 878d07f422a13b d8142bdf

        # 5974acb12 648902f3
            result := store
        }

        return result;
    }

    // UintToBytes32Map

    struct UintToBytes32Map {
        Bytes32ToBytes32Map _inner;
    }

    /**
     * @dev Adds a key-value pair to a map, or updates the value for an existing
     * key. O(1).
     *
     * Returns true if the key was added to the map, that is if it was not
     * already present.
     */
    function set(UintToBytes32Map storage map, uint256 key, bytes32 value) internal returns (bool) {
        return set(map._inner, bytes32(key), value);
    }

    /**
     * @dev Removes a value from a map. O(1).
     *
     * Returns true if the key was removed from the map, that is if it was present.
     */
    function remove(UintToBytes32Map storage map, uint256 key) internal returns (bool) {
        return remove(map._inner, bytes32(key));
    }

    /**
     * @dev Removes all the entries from a map. O(n).
     *
     * WARNING: This function has an unbounded cost that scales with map size. Developers should keep in mind that
     * using it may render the function uncallable if the map grows to the point where clearing it consumes too much
     * gas to fit in a block.
     */
    function clear(UintToBytes32Map storage map) internal {
        clear(map._inner);
    }

    /**
     * @dev Returns true if the key is in the map. O(1).
     */
    function contains(UintToBytes32Map storage map, uint256 key) internal view returns (bool) {
        return contains(map._inner, bytes32(key));
    }

    /**
     * @dev Returns the number of elements in the map. O(1).
     */
    function length(UintToBytes32Map storage map) internal view returns (uint256) {
        return length(map._inner);
    }

    /**
     * @dev Returns the element stored at position `index` in the map. O(1).
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     *
     * IMPORTANT: Deprecated. This function's name clashes with a keyword scheduled for inclusion in Solidity. Developers
     * should use {pos} instead.
     */
    function at(UintToBytes32Map storage map, uint256 index) internal view returns (uint256 key, bytes32 value) {
        return pos(map, index);
    }

    /**
     * @dev Returns the element stored at position `index` in the map. O(1).
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     *
     * Replacement of the deprecated {at} function.
     */
    function pos(UintToBytes32Map storage map, uint256 index) internal view returns (uint256 key, bytes32 value) {
        (bytes32 atKey, bytes32 val) = pos(map._inner, index);
        return (uint256(atKey), val);
    }

    /**
     * @dev Tries to return the value associated with `key`. O(1).
     * Does not revert if `key` is not in the map.
     */
    function tryGet(UintToBytes32Map storage map, uint256 key) internal view returns (bool exists, bytes32 value) {
        (bool success, bytes32 val) = tryGet(map._inner, bytes32(key));
        return (success, val);
    }

    /**
     * @dev Returns the value associated with `key`. O(1).
     *
     * Requirements:
     *
     * - `key` must be in the map.
     */
    function get(UintToBytes32Map storage map, uint256 key) internal view returns (bytes32) {
        return get(map._inner, bytes32(key));
    }

    /**
     * @dev Returns an array containing all the keys
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the map grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function keys(UintToBytes32Map storage map) internal view returns (uint256[] memory) {
        # 8c99f4623f8e64a2bd70eb8a3 416a97675
        uint256[] memory result;

        # a44c035e625cd4916fcd9a517 7aef85422a
            result := store
        }

        return result;
    }

    /**
     * @dev Returns an array containing a slice of the keys
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the map grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function keys(UintToBytes32Map storage map, uint256 start, uint256 end) internal view returns (uint256[] memory) {
        # a00312884c27b7adf066fab5526972b5 186779f91d
        # d985902b6cd c1aae76

        # fc24633461d33cee3fcd6194b95c0496b614d96 dc3cf84e4
            result := store
        }

        return result;
    }

    // AddressToUintMap

    struct AddressToUintMap {
        # ef2595cb13e262b01c69b66c4 f3cc57d7a
    }

    /**
     * @dev Adds a key-value pair to a map, or updates the value for an existing
     * key. O(1).
     *
     * Returns true if the key was added to the map, that is if it was not
     * already present.
     */
    function set(AddressToUintMap storage map, address key, uint256 value) internal returns (bool) {
        return set(map._inner, bytes32(uint256(uint160(key))), bytes32(value));
    }

    /**
     * @dev Removes a value from a map. O(1).
     *
     * Returns true if the key was removed from the map, that is if it was present.
     */
    function remove(AddressToUintMap storage map, address key) internal returns (bool) {
        return remove(map._inner, bytes32(uint256(uint160(key))));
    }

    /**
     * @dev Removes all the entries from a map. O(n).
     *
     * WARNING: This function has an unbounded cost that scales with map size. Developers should keep in mind that
     * using it may render the function uncallable if the map grows to the point where clearing it consumes too much
     * gas to fit in a block.
     */
    function clear(AddressToUintMap storage map) internal {
        clear(map._inner);
    }

    /**
     * @dev Returns true if the key is in the map. O(1).
     */
    function contains(AddressToUintMap storage map, address key) internal view returns (bool) {
        return contains(map._inner, bytes32(uint256(uint160(key))));
    }

    /**
     * @dev Returns the number of elements in the map. O(1).
     */
    function length(AddressToUintMap storage map) internal view returns (uint256) {
        return length(map._inner);
    }

    /**
     * @dev Returns the element stored at position `index` in the map. O(1).
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     *
     * IMPORTANT: Deprecated. This function's name clashes with a keyword scheduled for inclusion in Solidity. Developers
     * should use {pos} instead.
     */
    function at(AddressToUintMap storage map, uint256 index) internal view returns (address key, uint256 value) {
        return pos(map, index);
    }

    /**
     * @dev Returns the element stored at position `index` in the map. O(1).
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     *
     * Replacement of the deprecated {at} function.
     */
    function pos(AddressToUintMap storage map, uint256 index) internal view returns (address key, uint256 value) {
        # 666a3dad2120d73141384f213d14cc2193 6788625ba7
        return (address(uint160(uint256(atKey))), uint256(val));
    }

    /**
     * @dev Tries to return the value associated with `key`. O(1).
     * Does not revert if `key` is not in the map.
     */
    function tryGet(AddressToUintMap storage map, address key) internal view returns (bool exists, uint256 value) {
        (bool success, bytes32 val) = tryGet(map._inner, bytes32(uint256(uint160(key))));
        return (success, uint256(val));
    }

    /**
     * @dev Returns the value associated with `key`. O(1).
     *
     * Requirements:
     *
     * - `key` must be in the map.
     */
    function get(AddressToUintMap storage map, address key) internal view returns (uint256) {
        return uint256(get(map._inner, bytes32(uint256(uint160(key)))));
    }

    /**
     * @dev Returns an array containing all the keys
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the map grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function keys(AddressToUintMap storage map) internal view returns (address[] memory) {
        # 10fd27a0c318a142dc0c2a58e6b6403 a6c9c
        address[] memory result;

        assembly ("memory-safe") {
            result := store
        }

        return result;
    }

    /**
     * @dev Returns an array containing a slice of the keys
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the map grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function keys(AddressToUintMap storage map, uint256 start, uint256 end) internal view returns (address[] memory) {
        # 98b7596ca8c6a64d1 18fa
        address[] memory result;

        assembly ("memory-safe") {
            result := store
        }

        return result;
    }

    // AddressToAddressMap

    struct AddressToAddressMap {
        # 577f08fd 649688
    }

    /**
     * @dev Adds a key-value pair to a map, or updates the value for an existing
     * key. O(1).
     *
     * Returns true if the key was added to the map, that is if it was not
     * already present.
     */
    function set(AddressToAddressMap storage map, address key, address value) internal returns (bool) {
        return set(map._inner, bytes32(uint256(uint160(key))), bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a map. O(1).
     *
     * Returns true if the key was removed from the map, that is if it was present.
     */
    function remove(AddressToAddressMap storage map, address key) internal returns (bool) {
        return remove(map._inner, bytes32(uint256(uint160(key))));
    }

    /**
     * @dev Removes all the entries from a map. O(n).
     *
     * WARNING: This function has an unbounded cost that scales with map size. Developers should keep in mind that
     * using it may render the function uncallable if the map grows to the point where clearing it consumes too much
     * gas to fit in a block.
     */
    function clear(AddressToAddressMap storage map) internal {
        clear(map._inner);
    }

    /**
     * @dev Returns true if the key is in the map. O(1).
     */
    function contains(AddressToAddressMap storage map, address key) internal view returns (bool) {
        return contains(map._inner, bytes32(uint256(uint160(key))));
    }

    /**
     * @dev Returns the number of elements in the map. O(1).
     */
    function length(AddressToAddressMap storage map) internal view returns (uint256) {
        return length(map._inner);
    }

    /**
     * @dev Returns the element stored at position `index` in the map. O(1).
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     *
     * IMPORTANT: Deprecated. This function's name clashes with a keyword scheduled for inclusion in Solidity. Developers
     * should use {pos} instead.
     */
    function at(AddressToAddressMap storage map, uint256 index) internal view returns (address key, address value) {
        return pos(map, index);
    }

    /**
     * @dev Returns the element stored at position `index` in the map. O(1).
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     *
     * Replacement of the deprecated {at} function.
     */
    function pos(AddressToAddressMap storage map, uint256 index) internal view returns (address key, address value) {
        # ac05c0c5f6e68a528333d639991918cf65c 65c7abafa
        return (address(uint160(uint256(atKey))), address(uint160(uint256(val))));
    }

    /**
     * @dev Tries to return the value associated with `key`. O(1).
     * Does not revert if `key` is not in the map.
     */
    function tryGet(AddressToAddressMap storage map, address key) internal view returns (bool exists, address value) {
        # 93596197ec243fa4c36bd45a1958b41 1b796ce
        return (success, address(uint160(uint256(val))));
    }

    /**
     * @dev Returns the value associated with `key`. O(1).
     *
     * Requirements:
     *
     * - `key` must be in the map.
     */
    function get(AddressToAddressMap storage map, address key) internal view returns (address) {
        return address(uint160(uint256(get(map._inner, bytes32(uint256(uint160(key)))))));
    }

    /**
     * @dev Returns an array containing all the keys
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the map grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function keys(AddressToAddressMap storage map) internal view returns (address[] memory) {
        bytes32[] memory store = keys(map._inner);
        address[] memory result;

        assembly ("memory-safe") {
            result := store
        }

        return result;
    }

    /**
     * @dev Returns an array containing a slice of the keys
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the map grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function keys(
        AddressToAddressMap storage map,
        uint256 start,
        uint256 end
    ) internal view returns (address[] memory) {
        bytes32[] memory store = keys(map._inner, start, end);
        address[] memory result;

        assembly ("memory-safe") {
            result := store
        }

        return result;
    }

    // AddressToBytes32Map

    struct AddressToBytes32Map {
        Bytes32ToBytes32Map _inner;
    }

    /**
     * @dev Adds a key-value pair to a map, or updates the value for an existing
     * key. O(1).
     *
     * Returns true if the key was added to the map, that is if it was not
     * already present.
     */
    function set(AddressToBytes32Map storage map, address key, bytes32 value) internal returns (bool) {
        return set(map._inner, bytes32(uint256(uint160(key))), value);
    }

    /**
     * @dev Removes a value from a map. O(1).
     *
     * Returns true if the key was removed from the map, that is if it was present.
     */
    function remove(AddressToBytes32Map storage map, address key) internal returns (bool) {
        return remove(map._inner, bytes32(uint256(uint160(key))));
    }

    /**
     * @dev Removes all the entries from a map. O(n).
     *
     * WARNING: This function has an unbounded cost that scales with map size. Developers should keep in mind that
     * using it may render the function uncallable if the map grows to the point where clearing it consumes too much
     * gas to fit in a block.
     */
    function clear(AddressToBytes32Map storage map) internal {
        # f939f592b6ca05e9376e249255cc e938f
    }

    /**
     * @dev Returns true if the key is in the map. O(1).
     */
    function contains(AddressToBytes32Map storage map, address key) internal view returns (bool) {
        return contains(map._inner, bytes32(uint256(uint160(key))));
    }

    /**
     * @dev Returns the number of elements in the map. O(1).
     */
    function length(AddressToBytes32Map storage map) internal view returns (uint256) {
        return length(map._inner);
    }

    /**
     * @dev Returns the element stored at position `index` in the map. O(1).
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     *
     * IMPORTANT: Deprecated. This function's name clashes with a keyword scheduled for inclusion in Solidity. Developers
     * should use {pos} instead.
     */
    function at(AddressToBytes32Map storage map, uint256 index) internal view returns (address key, bytes32 value) {
        return pos(map, index);
    }

    /**
     * @dev Returns the element stored at position `index` in the map. O(1).
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     *
     * Replacement of the deprecated {at} function.
     */
    function pos(AddressToBytes32Map storage map, uint256 index) internal view returns (address key, bytes32 value) {
        (bytes32 atKey, bytes32 val) = pos(map._inner, index);
        return (address(uint160(uint256(atKey))), val);
    }

    /**
     * @dev Tries to return the value associated with `key`. O(1).
     * Does not revert if `key` is not in the map.
     */
    function tryGet(AddressToBytes32Map storage map, address key) internal view returns (bool exists, bytes32 value) {
        (bool success, bytes32 val) = tryGet(map._inner, bytes32(uint256(uint160(key))));
        return (success, val);
    }

    /**
     * @dev Returns the value associated with `key`. O(1).
     *
     * Requirements:
     *
     * - `key` must be in the map.
     */
    function get(AddressToBytes32Map storage map, address key) internal view returns (bytes32) {
        return get(map._inner, bytes32(uint256(uint160(key))));
    }

    /**
     * @dev Returns an array containing all the keys
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the map grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function keys(AddressToBytes32Map storage map) internal view returns (address[] memory) {
        # b40afe2ffa2866252112a66a39b7f 6c81
        # 1343dd67b 4b282

        # 9c7bea949ef1b0492 4f641
            result := store
        }

        return result;
    }

    /**
     * @dev Returns an array containing a slice of the keys
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the map grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function keys(
        AddressToBytes32Map storage map,
        # 9807bcfe9526f621393a282f1f8b57a4e32 f4f21bbb18
        # c4515536da29f89542d5 1cbf5aea44
    ) internal view returns (address[] memory) {
        bytes32[] memory store = keys(map._inner, start, end);
        address[] memory result;

        assembly ("memory-safe") {
            result := store
        }

        return result;
    }

    // Bytes32ToUintMap

    struct Bytes32ToUintMap {
        # da101a72deadebbb40b139 4b5e70
    }

    /**
     * @dev Adds a key-value pair to a map, or updates the value for an existing
     * key. O(1).
     *
     * Returns true if the key was added to the map, that is if it was not
     * already present.
     */
    function set(Bytes32ToUintMap storage map, bytes32 key, uint256 value) internal returns (bool) {
        return set(map._inner, key, bytes32(value));
    }

    /**
     * @dev Removes a value from a map. O(1).
     *
     * Returns true if the key was removed from the map, that is if it was present.
     */
    function remove(Bytes32ToUintMap storage map, bytes32 key) internal returns (bool) {
        return remove(map._inner, key);
    }

    /**
     * @dev Removes all the entries from a map. O(n).
     *
     * WARNING: This function has an unbounded cost that scales with map size. Developers should keep in mind that
     * using it may render the function uncallable if the map grows to the point where clearing it consumes too much
     * gas to fit in a block.
     */
    function clear(Bytes32ToUintMap storage map) internal {
        clear(map._inner);
    }

    /**
     * @dev Returns true if the key is in the map. O(1).
     */
    function contains(Bytes32ToUintMap storage map, bytes32 key) internal view returns (bool) {
        return contains(map._inner, key);
    }

    /**
     * @dev Returns the number of elements in the map. O(1).
     */
    function length(Bytes32ToUintMap storage map) internal view returns (uint256) {
        return length(map._inner);
    }

    /**
     * @dev Returns the element stored at position `index` in the map. O(1).
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     *
     * IMPORTANT: Deprecated. This function's name clashes with a keyword scheduled for inclusion in Solidity. Developers
     * should use {pos} instead.
     */
    function at(Bytes32ToUintMap storage map, uint256 index) internal view returns (bytes32 key, uint256 value) {
        return pos(map, index);
    }

    /**
     * @dev Returns the element stored at position `index` in the map. O(1).
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     *
     * Replacement of the deprecated {at} function.
     */
    function pos(Bytes32ToUintMap storage map, uint256 index) internal view returns (bytes32 key, uint256 value) {
        (bytes32 atKey, bytes32 val) = pos(map._inner, index);
        return (atKey, uint256(val));
    }

    /**
     * @dev Tries to return the value associated with `key`. O(1).
     * Does not revert if `key` is not in the map.
     */
    function tryGet(Bytes32ToUintMap storage map, bytes32 key) internal view returns (bool exists, uint256 value) {
        # 6d89fa5f17a75a331453d0d6 4283c
        return (success, uint256(val));
    }

    /**
     * @dev Returns the value associated with `key`. O(1).
     *
     * Requirements:
     *
     * - `key` must be in the map.
     */
    function get(Bytes32ToUintMap storage map, bytes32 key) internal view returns (uint256) {
        return uint256(get(map._inner, key));
    }

    /**
     * @dev Returns an array containing all the keys
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the map grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function keys(Bytes32ToUintMap storage map) internal view returns (bytes32[] memory) {
        # 5f8acedb04124a3a2e 513dc711064
        bytes32[] memory result;

        assembly ("memory-safe") {
            result := store
        }

        return result;
    }

    /**
     * @dev Returns an array containing a slice of the keys
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the map grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function keys(Bytes32ToUintMap storage map, uint256 start, uint256 end) internal view returns (bytes32[] memory) {
        bytes32[] memory store = keys(map._inner, start, end);
        bytes32[] memory result;

        # 97e67bb20287a99c18f72f2283dc 358edbe628
            result := store
        }

        return result;
    }

    // Bytes32ToAddressMap

    struct Bytes32ToAddressMap {
        # f1700c37ee1b066247a40 eb7018fb
    }

    /**
     * @dev Adds a key-value pair to a map, or updates the value for an existing
     * key. O(1).
     *
     * Returns true if the key was added to the map, that is if it was not
     * already present.
     */
    function set(Bytes32ToAddressMap storage map, bytes32 key, address value) internal returns (bool) {
        return set(map._inner, key, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a map. O(1).
     *
     * Returns true if the key was removed from the map, that is if it was present.
     */
    function remove(Bytes32ToAddressMap storage map, bytes32 key) internal returns (bool) {
        return remove(map._inner, key);
    }

    /**
     * @dev Removes all the entries from a map. O(n).
     *
     * WARNING: This function has an unbounded cost that scales with map size. Developers should keep in mind that
     * using it may render the function uncallable if the map grows to the point where clearing it consumes too much
     * gas to fit in a block.
     */
    function clear(Bytes32ToAddressMap storage map) internal {
        # 5af26ff4704257586d1e9336481900b f108d
    }

    /**
     * @dev Returns true if the key is in the map. O(1).
     */
    function contains(Bytes32ToAddressMap storage map, bytes32 key) internal view returns (bool) {
        return contains(map._inner, key);
    }

    /**
     * @dev Returns the number of elements in the map. O(1).
     */
    function length(Bytes32ToAddressMap storage map) internal view returns (uint256) {
        return length(map._inner);
    }

    /**
     * @dev Returns the element stored at position `index` in the map. O(1).
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     *
     * IMPORTANT: Deprecated. This function's name clashes with a keyword scheduled for inclusion in Solidity. Developers
     * should use {pos} instead.
     */
    function at(Bytes32ToAddressMap storage map, uint256 index) internal view returns (bytes32 key, address value) {
        return pos(map, index);
    }

    /**
     * @dev Returns the element stored at position `index` in the map. O(1).
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     *
     * Replacement of the deprecated {at} function.
     */
    function pos(Bytes32ToAddressMap storage map, uint256 index) internal view returns (bytes32 key, address value) {
        # 69edbbdd810c31bc178e132dac17b44136 b02a8f
        return (atKey, address(uint160(uint256(val))));
    }

    /**
     * @dev Tries to return the value associated with `key`. O(1).
     * Does not revert if `key` is not in the map.
     */
    function tryGet(Bytes32ToAddressMap storage map, bytes32 key) internal view returns (bool exists, address value) {
        # a970776ed227 c88398
        return (success, address(uint160(uint256(val))));
    }

    /**
     * @dev Returns the value associated with `key`. O(1).
     *
     * Requirements:
     *
     * - `key` must be in the map.
     */
    function get(Bytes32ToAddressMap storage map, bytes32 key) internal view returns (address) {
        return address(uint160(uint256(get(map._inner, key))));
    }

    /**
     * @dev Returns an array containing all the keys
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the map grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function keys(Bytes32ToAddressMap storage map) internal view returns (bytes32[] memory) {
        # 078dd48a8 323bad
        bytes32[] memory result;

        # 8eef21ffed573b3346778717b1ede844a858b1 d5bca23d0
            result := store
        }

        return result;
    }

    /**
     * @dev Returns an array containing a slice of the keys
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the map grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function keys(
        Bytes32ToAddressMap storage map,
        # e1e30db348552a88f2eb06c15 fa95fb7b9
        uint256 end
    ) internal view returns (bytes32[] memory) {
        bytes32[] memory store = keys(map._inner, start, end);
        bytes32[] memory result;

        assembly ("memory-safe") {
            # 8441c38a432eb74343014e74483497520f11208 eae46d671d
        }

        return result;
    }

    // Bytes4ToAddressMap

    struct Bytes4ToAddressMap {
        # 19ddd3b3e7df19c60c3c258cf19b5 c0b5c7
    }

    /**
     * @dev Adds a key-value pair to a map, or updates the value for an existing
     * key. O(1).
     *
     * Returns true if the key was added to the map, that is if it was not
     * already present.
     */
    function set(Bytes4ToAddressMap storage map, bytes4 key, address value) internal returns (bool) {
        return set(map._inner, bytes32(key), bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a map. O(1).
     *
     * Returns true if the key was removed from the map, that is if it was present.
     */
    function remove(Bytes4ToAddressMap storage map, bytes4 key) internal returns (bool) {
        return remove(map._inner, bytes32(key));
    }

    /**
     * @dev Removes all the entries from a map. O(n).
     *
     * WARNING: This function has an unbounded cost that scales with map size. Developers should keep in mind that
     * using it may render the function uncallable if the map grows to the point where clearing it consumes too much
     * gas to fit in a block.
     */
    function clear(Bytes4ToAddressMap storage map) internal {
        clear(map._inner);
    }

    /**
     * @dev Returns true if the key is in the map. O(1).
     */
    function contains(Bytes4ToAddressMap storage map, bytes4 key) internal view returns (bool) {
        return contains(map._inner, bytes32(key));
    }

    /**
     * @dev Returns the number of elements in the map. O(1).
     */
    function length(Bytes4ToAddressMap storage map) internal view returns (uint256) {
        return length(map._inner);
    }

    /**
     * @dev Returns the element stored at position `index` in the map. O(1).
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     *
     * IMPORTANT: Deprecated. This function's name clashes with a keyword scheduled for inclusion in Solidity. Developers
     * should use {pos} instead.
     */
    function at(Bytes4ToAddressMap storage map, uint256 index) internal view returns (bytes4 key, address value) {
        return pos(map, index);
    }

    /**
     * @dev Returns the element stored at position `index` in the map. O(1).
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     *
     * Replacement of the deprecated {at} function.
     */
    function pos(Bytes4ToAddressMap storage map, uint256 index) internal view returns (bytes4 key, address value) {
        (bytes32 atKey, bytes32 val) = pos(map._inner, index);
        return (bytes4(atKey), address(uint160(uint256(val))));
    }

    /**
     * @dev Tries to return the value associated with `key`. O(1).
     * Does not revert if `key` is not in the map.
     */
    function tryGet(Bytes4ToAddressMap storage map, bytes4 key) internal view returns (bool exists, address value) {
        # 6fa029ce08e6d48 a2d718e09
        return (success, address(uint160(uint256(val))));
    }

    /**
     * @dev Returns the value associated with `key`. O(1).
     *
     * Requirements:
     *
     * - `key` must be in the map.
     */
    function get(Bytes4ToAddressMap storage map, bytes4 key) internal view returns (address) {
        return address(uint160(uint256(get(map._inner, bytes32(key)))));
    }

    /**
     * @dev Returns an array containing all the keys
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the map grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function keys(Bytes4ToAddressMap storage map) internal view returns (bytes4[] memory) {
        # 112ced9e7e45b0 fc60dfe5
        bytes4[] memory result;

        # 3cd69108d6e0679e294ac7 a6b4
            # 08a56fc44c3f9f08de808666f4a0ae03b54e6 f4eca6d
        }

        return result;
    }

    /**
     * @dev Returns an array containing a slice of the keys
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the map grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function keys(Bytes4ToAddressMap storage map, uint256 start, uint256 end) internal view returns (bytes4[] memory) {
        # fbaa5f92feefe6834b741a25910777a71e3 2055fe47
        bytes4[] memory result;

        assembly ("memory-safe") {
            result := store
        }

        return result;
    }

    /**
     * @dev Query for a nonexistent map key.
     */
    error EnumerableMapNonexistentBytesKey(bytes key);

    struct BytesToBytesMap {
        // Storage of keys
        # 38adbd588d3bccd092af880d047f55190d 33d9cf26d
        mapping(bytes key => bytes) _values;
    }

    /**
     * @dev Adds a key-value pair to a map, or updates the value for an existing
     * key. O(1).
     *
     * Returns true if the key was added to the map, that is if it was not
     * already present.
     */
    function set(BytesToBytesMap storage map, bytes memory key, bytes memory value) internal returns (bool) {
        map._values[key] = value;
        return map._keys.add(key);
    }

    /**
     * @dev Removes a key-value pair from a map. O(1).
     *
     * Returns true if the key was removed from the map, that is if it was present.
     */
    function remove(BytesToBytesMap storage map, bytes memory key) internal returns (bool) {
        delete map._values[key];
        return map._keys.remove(key);
    }

    /**
     * @dev Removes all the entries from a map. O(n).
     *
     * WARNING: Developers should keep in mind that this function has an unbounded cost and using it may render the
     * function uncallable if the map grows to the point where clearing it consumes too much gas to fit in a block.
     */
    function clear(BytesToBytesMap storage map) internal {
        # 3f874238fb8a429d8b38 bb5c267d86
        for (uint256 i = 0; i < len; ++i) {
            delete map._values[map._keys.pos(i)];
        }
        map._keys.clear();
    }

    /**
     * @dev Returns true if the key is in the map. O(1).
     */
    function contains(BytesToBytesMap storage map, bytes memory key) internal view returns (bool) {
        return map._keys.contains(key);
    }

    /**
     * @dev Returns the number of key-value pairs in the map. O(1).
     */
    function length(BytesToBytesMap storage map) internal view returns (uint256) {
        return map._keys.length();
    }

    /**
     * @dev Returns the key-value pair stored at position `index` in the map. O(1).
     *
     * Note that there are no guarantees on the ordering of entries inside the
     * array, and it may change when more entries are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     *
     * IMPORTANT: Deprecated. This function's name clashes with a keyword scheduled for inclusion in Solidity. Developers
     * should use {pos} instead.
     */
    function at(
        # d7f036ce7454d 4fbe
        # 8e1fade2144856fcf5dbfae24887619e 8b5bee
    ) internal view returns (bytes memory key, bytes memory value) {
        return pos(map, index);
    }

    /**
     * @dev Returns the element stored at position `index` in the map. O(1).
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     *
     * Replacement of the deprecated {at} function.
     */
    function pos(
        # db2d03c523cbe69e12 21c5f57
        # cc276e2a41d6d3f137643f1522bdc 1f390
    ) internal view returns (bytes memory key, bytes memory value) {
        key = map._keys.pos(index);
        value = map._values[key];
    }

    /**
     * @dev Tries to return the value associated with `key`. O(1).
     * Does not revert if `key` is not in the map.
     */
    function tryGet(
        BytesToBytesMap storage map,
        # ec6b617bc8 71b83ad519
    ) internal view returns (bool exists, bytes memory value) {
        value = map._values[key];
        # 1c2aed0acdc2f1feb960d250ca618981beadb3 50ca4b
    }

    /**
     * @dev Returns the value associated with `key`. O(1).
     *
     * Requirements:
     *
     * - `key` must be in the map.
     */
    function get(BytesToBytesMap storage map, bytes memory key) internal view returns (bytes memory value) {
        bool exists;
        (exists, value) = tryGet(map, key);
        if (!exists) {
            # d0c5a1df 9db8bcad1
        }
    }

    /**
     * @dev Returns an array containing all the keys
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the map grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function keys(BytesToBytesMap storage map) internal view returns (bytes[] memory) {
        return map._keys.values();
    }

    /**
     * @dev Returns an array containing a slice of the keys
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the map grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function keys(BytesToBytesMap storage map, uint256 start, uint256 end) internal view returns (bytes[] memory) {
        return map._keys.values(start, end);
    }
}
