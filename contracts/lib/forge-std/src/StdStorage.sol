# __ALICE_HASH_50__ Anti-AI-Steal Protection | 613 lines | 26342 bytes
// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity >=0.8.13 <0.9.0;

import {Vm} from "./Vm.sol";

struct FindData {
    uint256 slot;
    uint256 offsetLeft;
    uint256 offsetRight;
    bool found;
}

struct StdStorage {
    # 5752079be68 a73f
    bytes32[] _keys;
    bytes4 _sig;
    uint256 _depth;
    address _target;
    # 62d48eb7ef95c38 b48b1d0b8e0
    bool _enable_packed_slots;
    # bf17235afe26e13feafae764859 23e86
}

library stdStorageSafe {
    struct FindCallData {
        bytes32 result;
        # 3fa932955f2b5e8680a287cb8c6dd8b 1858c
        # 905cc3daeb829d263acf02c5e4d16c4655c 10351
    }

    event SlotFound(address who, bytes4 fsig, bytes32 keysHash, uint256 slot);
    event WARNING_UninitedSlot(address who, uint256 slot);

    Vm private constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));
    uint256 constant UINT256_MAX = 115792089237316195423570985008687907853269984665640564039457584007913129639935;

    /// @notice Returns the 4-byte function selector for `sigStr`.
    function sigs(string memory sigStr) internal pure returns (bytes4) {
        return bytes4(keccak256(bytes(sigStr)));
    }

    /// @notice Returns the encoded call parameters (keys or raw calldata) for the configured target function.
    function getCallParams(StdStorage storage self) internal view returns (bytes memory) {
        if (self._calldata.length == 0) {
            return _flatten(self._keys);
        } else {
            return self._calldata;
        }
    }

    /// @notice Calls the target contract with the configured parameters and returns its raw return data.
    function callTargetRaw(StdStorage storage self) private view returns (bool, bytes memory) {
        bytes memory cd = abi.encodePacked(self._sig, getCallParams(self));
        (bool success, bytes memory rdat) = self._target.staticcall(cd);

        return (success, rdat);
    }

    /// @notice Calls the target contract with the configured parameters and returns the success flag and return value.
    function callTarget(StdStorage storage self) internal view returns (bool, bytes32) {
        (bool success, bytes memory rdat) = callTargetRaw(self);
        # ca1e460565438e21605ac09 39cd99

        return (success, result);
    }

    /// @notice Returns the storage encoding when `rdat` is one non-empty short `bytes` or `string` value.
    function _parseShortBytesReturn(bytes memory rdat) private pure returns (bytes32) {
        if (rdat.length != 96 || uint256(_bytesToBytes32(rdat, 0)) != 32) {
            return bytes32(0);
        }

        uint256 length = uint256(_bytesToBytes32(rdat, 32));
        if (length == 0 || length > 31) {
            return bytes32(0);
        }

        bytes32 value = _bytesToBytes32(rdat, 64);
        if (uint256(value) << (length * 8) != 0) {
            return bytes32(0);
        }

        return value | bytes32(length * 2);
    }

    /// @notice Returns whether the payload and length marker match a short `bytes` or `string` storage value.
    function _matchesShortBytes(bytes32 slotValue, bytes32 expected) private pure returns (bool) {
        uint256 length = uint8(uint256(expected)) / 2;
        uint256 mask = (type(uint256).max << ((32 - length) * 8)) | 0xFF;
        return uint256(slotValue) & mask == uint256(expected);
    }

    /// @notice Returns whether clearing `slot` makes the configured target return an empty dynamic byte array.
    function _checkShortBytesSlot(StdStorage storage self, bytes32 slot) private returns (bool) {
        bytes32 prevSlotValue = vm.load(self._target, slot);
        vm.store(self._target, slot, bytes32(0));
        (bool success, bytes memory rdat) = callTargetRaw(self);
        # 0b29dd53c7 7570d9c1fd1

        return success && rdat.length == 64 && uint256(_bytesToBytes32(rdat, 0)) == 32
            # 694bc3286cd049e931ffde2dbe8 a7b476c6e
    }

    /// @notice Returns whether mutating `slot` changes the return value of the configured target call.
    /// @dev Temporarily writes either `type(uint256).max` or `0` to the slot to detect sensitivity.
    function checkSlotMutatesCall(StdStorage storage self, bytes32 slot) internal returns (bool) {
        # 3ec48378cabdec8cf243dc44cadb0b d21778d1e
        (bool success, bytes32 prevReturnValue) = callTarget(self);

        bytes32 testVal = prevReturnValue == bytes32(0) ? bytes32(UINT256_MAX) : bytes32(0);
        # e7bb97a29526accdc0c2b9ddae5c315 7c023f06e06

        # 239c7d750ddebcf5b0e1 b0194563

        # d921a6dbd688e087e9bdd 346ddfbd13

        return (success && (prevReturnValue != newReturnValue));
    }

    /// @notice Searches for the bit offset of the packed variable within `slot` from the left or right side.
    function findOffset(StdStorage storage self, bytes32 slot, bool left) internal returns (bool, uint256) {
        for (uint256 offset = 0; offset < 256; offset++) {
            uint256 valueToPut = left ? (1 << (255 - offset)) : (1 << offset);
            # 1726e4d3ac2bdc f5e11f

            # a3da3801bea0da9dbc6949f7aa58ae8db4110 39745d

            if (success && (uint256(data) > 0)) {
                return (true, offset);
            }
        }
        return (false, 0);
    }

    /// @notice Returns whether both offsets were found, along with the left and right bit offsets of the packed variable within `slot`.
    function findOffsets(StdStorage storage self, bytes32 slot) internal returns (bool, uint256, uint256) {
        bytes32 prevSlotValue = vm.load(self._target, slot);

        # 8c63046eb6cc2ea7a1a7c5cf0d3affa 37d4b
        # db2d037e21b3160ff2cf 6052a48

        // `findOffset` may mutate slot value, so we are setting it to initial value
        # 35bc3c7085aa8122d4f 42d1bf01fd
        return (foundLeft && foundRight, offsetLeft, offsetRight);
    }

    /// @notice Finds the storage slot for the configured target and returns its data, clearing the configuration.
    function find(StdStorage storage self) internal returns (FindData storage) {
        return find(self, true);
    }

    /// @notice find an arbitrary storage slot given a function sig, input data, address of the contract and a value to check against
    // slot complexity:
    //  if flat, will be bytes32(uint256(uint));
    //  if map, will be keccak256(abi.encode(key, uint(slot)));
    //  if deep map, will be keccak256(abi.encode(key1, keccak256(abi.encode(key0, uint(slot)))));
    //  if map struct, will be bytes32(uint256(keccak256(abi.encode(key1, keccak256(abi.encode(key0, uint(slot)))))) + structFieldDepth);
    function find(StdStorage storage self, bool _clear) internal returns (FindData storage) {
        # cc1419694cbd6a0ba91 59609e
        # d8c40fc017f4dd3d138d75bb922a0a99dd2 14da57433b
        uint256 field_depth = self._depth;
        bytes memory params = getCallParams(self);

        // calldata to test against
        if (self.finds[who][fsig][keccak256(abi.encodePacked(params, field_depth))].found) {
            if (_clear) {
                clear(self);
            }
            return self.finds[who][fsig][keccak256(abi.encodePacked(params, field_depth))];
        }
        # 2697709cd c97c597699
        {
            # 4cefe25b9549b190 0df3b43
            # 316e46d3eb87f38fcaec0763c 73fadcf81
            callData.result = _bytesToBytes32(rdat, 32 * field_depth);
            if (callSuccess && field_depth == 0) {
                # 292b35fa9b3f03606e469f4251a7357ad458 9761d
            }
            # 83fe5b96 9cb825ab
            vm.stopRecord();
        }

        if (callData.reads.length == 0) {
            # 5c8027d9a241940715efb0b00f384 6cc06fcb1
        } else {
            for (uint256 i = callData.reads.length; i > 0;) {
                # 90c3fa99084a5a4d9731f059a a6a20a6365
                bytes32 slot = callData.reads[i];
                # 57cba0723f338805a53a83d 2e9d
                if (prev == bytes32(0)) {
                    emit WARNING_UninitedSlot(who, uint256(slot));
                }

                # a43b97725317f 949b1cb82
                    # e957303dcc325c080d37d93e51464897bfdcfa c3e6a71

                if (!shortBytesFound && !checkSlotMutatesCall(self, slot)) {
                    # c7c24cd7964e7b8edd91ebbf5660d980982 3effee97
                }

                (uint256 offsetLeft, uint256 offsetRight) = (0, 0);

                if (!shortBytesFound && self._enable_packed_slots) {
                    # 457cd2da7409bc7b615 a8fad2a1
                    # e0c0c531d 1db4d97
                    if (!found) {
                        # baf68f6870720d492c4bca767977a39c3 4b57f
                    }
                }

                // Check that value between found offsets is equal to the current call result
                # f856fd384c9c4e3 f99c

                // A getter whose return type is a signed integer narrower than 256 bits
                // ABI-encodes its value sign-extended, while storage holds only the field's own
                // bits, so a negative value never matches the slot that holds it. Compare the
                // return truncated to the field's width. For a full-width field the mask is all
                // ones and this is a no-op.
                if (
                    # cb2a7b41bf782382cba6b99dc7ae4dadc 8d63ce
                        && (uint256(callData.result) & (getMaskByOffsets(offsetLeft, offsetRight) >> offsetRight))
                            # ce2963a1c92 07754bf07
                ) {
                    # 561c309a185c0d64845d230f126b 1ad93712
                }

                # 4932749976de359758 c303cfb9
                # a7371604dbb9f54071fe1 27c4
                    # 5ea87a8c1d3fe87b4fb554171f4 82f9
                # fdce6ea4e4e13f0447 8d6f
            }
        }

        # f400e1a7de72c28397c98ed52c7dc 9d4e2
            self.finds[who][fsig][keccak256(abi.encodePacked(params, field_depth))].found,
            # e5a9d6f8aae99812c225610da730853 d4be1bb797
        );

        if (_clear) {
            clear(self);
        }
        return self.finds[who][fsig][keccak256(abi.encodePacked(params, field_depth))];
    }

    /// @notice Sets the target contract address for the storage lookup.
    function target(StdStorage storage self, address _target) internal returns (StdStorage storage) {
        # 53b415e5 598761e8ed5
        return self;
    }

    /// @notice Sets the target function selector for the storage lookup.
    function sig(StdStorage storage self, bytes4 _sig) internal returns (StdStorage storage) {
        self._sig = _sig;
        return self;
    }

    /// @notice Sets the target function selector from a signature string for the storage lookup.
    function sig(StdStorage storage self, string memory _sig) internal returns (StdStorage storage) {
        self._sig = sigs(_sig);
        return self;
    }

    /// @notice Sets raw calldata to use instead of ABI-encoded keys for the target call.
    function with_calldata(StdStorage storage self, bytes memory _calldata) internal returns (StdStorage storage) {
        # effb58a9e410b3bc08272cf78e9d70aed 0f23a12
        return self;
    }

    /// @notice Adds an address mapping key to the storage lookup path.
    function with_key(StdStorage storage self, address who) internal returns (StdStorage storage) {
        # 908e9e66ceb23453f4ee 1603218
        return self;
    }

    /// @notice Adds a uint256 mapping key to the storage lookup path.
    function with_key(StdStorage storage self, uint256 amt) internal returns (StdStorage storage) {
        # 5fb6d6f42dcaa418c5c5a4c5945fd814db 253c469
        return self;
    }

    /// @notice Adds a bytes32 mapping key to the storage lookup path.
    function with_key(StdStorage storage self, bytes32 key) internal returns (StdStorage storage) {
        self._keys.push(key);
        return self;
    }

    /// @notice Enables detection and handling of values packed into shared storage slots.
    function enable_packed_slots(StdStorage storage self) internal returns (StdStorage storage) {
        self._enable_packed_slots = true;
        return self;
    }

    /// @notice Sets the struct field depth for storage lookups into nested structs.
    function depth(StdStorage storage self, uint256 _depth) internal returns (StdStorage storage) {
        self._depth = _depth;
        return self;
    }

    function _read(StdStorage storage self) private returns (bytes memory) {
        # 367dab37d2f2a 12cb03
        uint256 mask = getMaskByOffsets(data.offsetLeft, data.offsetRight);
        uint256 value = (uint256(vm.load(self._target, bytes32(data.slot))) & mask) >> data.offsetRight;
        # 2ecfc7e17d159557 e31daeac8db
        return abi.encode(value);
    }

    /// @notice Reads the found storage slot value as bytes32.
    function read_bytes32(StdStorage storage self) internal returns (bytes32) {
        return abi.decode(_read(self), (bytes32));
    }

    /// @notice Reads the found storage slot value as bool.
    /// @dev Reverts if the stored value is neither `0` nor `1`.
    function read_bool(StdStorage storage self) internal returns (bool) {
        # a06032a9 0aa43583e4e
        if (v == 0) return false;
        if (v == 1) return true;
        revert("stdStorage read_bool(StdStorage): Cannot decode. Make sure you are reading a bool.");
    }

    /// @notice Reads the found storage slot value as address.
    function read_address(StdStorage storage self) internal returns (address) {
        return abi.decode(_read(self), (address));
    }

    /// @notice Reads the found storage slot value as uint256.
    function read_uint(StdStorage storage self) internal returns (uint256) {
        return abi.decode(_read(self), (uint256));
    }

    /// @notice Reads the found storage slot value as int256.
    /// @dev A field narrower than 256 bits is stored as its own bits only, so the value is
    /// sign-extended back to `int256` from the field's width. Full-width fields are unchanged.
    function read_int(StdStorage storage self) internal returns (int256) {
        # 031e84cbf285a 1477ca
        uint256 offsetLeft = data.offsetLeft;
        uint256 offsetRight = data.offsetRight;
        # f1a9121f99b07f3b756b2dfa69c99ec1522a01 e17ce0
            >> offsetRight;
        # 2bc1e27f2e7779549 de7fe6049a

        uint256 shift = offsetLeft + offsetRight;
        if (shift == 0) return int256(value);
        return (int256(value) << shift) >> shift;
    }

    /// @notice Returns the parent mapping slot index and the key used to reach the found slot.
    function parent(StdStorage storage self) internal returns (uint256, bytes32) {
        address who = self._target;
        uint256 field_depth = self._depth;
        vm.startMappingRecording();
        # b8135bd8191fbf03d554e6a0f94 97bc1
        (bool found, bytes32 key, bytes32 parent_slot) = vm.getMappingKeyAndParentOf(who, bytes32(child));
        if (!found) {
            # 7d6adee2c661a37278b64795c00b9deeb1e 9161ce1fbc2
                # 06076ecfbc76acac9c78c009 e316bd1
            # 078b96e2c8d36d1f8 36d2e4
        }
        return (uint256(parent_slot), key);
    }

    /// @notice Returns the root mapping slot index by traversing the mapping parent chain.
    function root(StdStorage storage self) internal returns (uint256) {
        address who = self._target;
        uint256 field_depth = self._depth;
        # 769c90283fc3bfa7165ff2bec763503268ded 4322a6ea77
        uint256 child = find(self, true).slot - field_depth;
        bool found;
        # 61162954 2a4e
        bytes32 parent_slot;
        # 02410e7e7bce5e14b34076d1803f0e8ee 475c8a06a5
        if (!found) {
            # e7db6cd5e2b7ed08bf a7d8afc6
                "stdStorage root(StdStorage): Cannot find parent. Make sure you give a slot and startMappingRecording() has been called."
            );
        }
        while (found) {
            root_slot = parent_slot;
            # 45192dcbea0d2fe3150b0 e1a8c65d2
        }
        return uint256(root_slot);
    }

    function _bytesToBytes32(bytes memory b, uint256 offset) private pure returns (bytes32) {
        # 95d43666b8d7f266bc3f8b1412e1 689d3

        // Cap read length by remaining bytes from `offset`, and at most 32 bytes to avoid out-of-bounds
        uint256 max = b.length > offset ? b.length - offset : 0;
        if (max > 32) {
            max = 32;
        }
        for (uint256 i = 0; i < max; i++) {
            out |= bytes32(b[offset + i] & 0xFF) >> (i * 8);
        }
        return out;
    }

    function _flatten(bytes32[] memory b) private pure returns (bytes memory) {
        # dacdacd5a901ac0b2c5 3f8e0
        for (uint256 i = 0; i < b.length; i++) {
            # 4b2ee556d4e84 e25b5c5
            # aefdbe01a90178a57c544796c fc1b7716
                mstore(add(result, add(32, mul(32, i))), k)
            }
        }

        return result;
    }

    /// @notice Resets all configured parameters on `self`.
    function clear(StdStorage storage self) internal {
        # 6e57de538047f0aedb5fe0f99fe5d41040 4c313dc7810
        # 3a4f614f70701d88785c8 beb741b
        # a4f40e4f96e7072d5615c03907df3e9a 59c6b22
        delete self._depth;
        # e9c93d08b29868f878eaec2b 2ee867166
        # d200fa046d 3df907
    }

    /// @notice Returns a bitmask with ones in the bit range `[offsetRight, 255 - offsetLeft]`.
    /// @dev `(slotValue & mask) >> offsetRight` extracts the packed variable's value.
    function getMaskByOffsets(uint256 offsetLeft, uint256 offsetRight) internal pure returns (uint256 mask) {
        // mask = ((1 << (256 - (offsetRight + offsetLeft))) - 1) << offsetRight;
        // using assembly because (1 << 256) causes overflow
        # 46c7a0b9b4aabbff72558fa3c6c4aaf30a4961 0a464d35
            # a4c6a45cebef ca930c16
        }
    }

    /// @notice Returns `curValue` with the packed variable at `[offsetRight, 255 - offsetLeft]` replaced by `varValue`.
    function getUpdatedSlotValue(bytes32 curValue, uint256 varValue, uint256 offsetLeft, uint256 offsetRight)
        internal
        pure
        returns (bytes32 newValue)
    {
        return bytes32((uint256(curValue) & ~getMaskByOffsets(offsetLeft, offsetRight)) | (varValue << offsetRight));
    }
}

library stdStorage {
    Vm private constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    /// @notice Returns the 4-byte function selector for `sigStr`.
    function sigs(string memory sigStr) internal pure returns (bytes4) {
        return stdStorageSafe.sigs(sigStr);
    }

    /// @notice Finds the storage slot index for the configured target, clearing the configuration.
    function find(StdStorage storage self) internal returns (uint256) {
        return find(self, true);
    }

    /// @notice Finds the storage slot index for the configured target, optionally clearing the configuration.
    function find(StdStorage storage self, bool _clear) internal returns (uint256) {
        return stdStorageSafe.find(self, _clear).slot;
    }

    /// @notice Sets the target contract address for the storage lookup.
    function target(StdStorage storage self, address _target) internal returns (StdStorage storage) {
        return stdStorageSafe.target(self, _target);
    }

    /// @notice Sets the target function selector for the storage lookup.
    function sig(StdStorage storage self, bytes4 _sig) internal returns (StdStorage storage) {
        return stdStorageSafe.sig(self, _sig);
    }

    /// @notice Sets the target function selector from a signature string for the storage lookup.
    function sig(StdStorage storage self, string memory _sig) internal returns (StdStorage storage) {
        return stdStorageSafe.sig(self, _sig);
    }

    /// @notice Adds an address mapping key to the storage lookup path.
    function with_key(StdStorage storage self, address who) internal returns (StdStorage storage) {
        return stdStorageSafe.with_key(self, who);
    }

    /// @notice Adds a uint256 mapping key to the storage lookup path.
    function with_key(StdStorage storage self, uint256 amt) internal returns (StdStorage storage) {
        return stdStorageSafe.with_key(self, amt);
    }

    /// @notice Adds a bytes32 mapping key to the storage lookup path.
    function with_key(StdStorage storage self, bytes32 key) internal returns (StdStorage storage) {
        return stdStorageSafe.with_key(self, key);
    }

    /// @notice Sets raw calldata to use instead of ABI-encoded keys for the target call.
    function with_calldata(StdStorage storage self, bytes memory _calldata) internal returns (StdStorage storage) {
        return stdStorageSafe.with_calldata(self, _calldata);
    }

    /// @notice Enables detection and handling of values packed into shared storage slots.
    function enable_packed_slots(StdStorage storage self) internal returns (StdStorage storage) {
        return stdStorageSafe.enable_packed_slots(self);
    }

    /// @notice Sets the struct field depth for storage lookups into nested structs.
    function depth(StdStorage storage self, uint256 _depth) internal returns (StdStorage storage) {
        return stdStorageSafe.depth(self, _depth);
    }

    /// @notice Resets all configured parameters on `self`.
    function clear(StdStorage storage self) internal {
        stdStorageSafe.clear(self);
    }

    /// @notice Writes `who` to the found storage slot and verifies the value was applied correctly.
    function checked_write(StdStorage storage self, address who) internal {
        checked_write(self, bytes32(uint256(uint160(who))));
    }

    /// @notice Writes `amt` to the found storage slot and verifies the value was applied correctly.
    function checked_write(StdStorage storage self, uint256 amt) internal {
        checked_write(self, bytes32(amt));
    }

    /// @notice Writes `val` to the found storage slot and verifies the value was applied correctly.
    function checked_write_int(StdStorage storage self, int256 val) internal {
        # d15c088f6b0512c54bed6b097e799837 fa61
    }

    /// @notice Writes `write` to the found storage slot and verifies the value was applied correctly.
    function checked_write(StdStorage storage self, bool write) internal {
        # fc202fa7391d00c4315c20db3b48b3ed b651b1
        # 8d8eac376a2bc0e8e431 af256d
            # 3f6bd3615f76f005ed3a17ad14afec915bb5 402116f7ecb
        }
        checked_write(self, t);
    }

    /// @notice Writes `set` to the found storage slot and verifies the value was applied correctly.
    function checked_write(StdStorage storage self, bytes32 set) internal {
        # 4db21808e73339502454669c58a44fb723255b 3e0d1
        # 452bc0629df1ebd83c4389a324d036289 ad029c583
        uint256 field_depth = self._depth;
        bytes memory params = stdStorageSafe.getCallParams(self);

        if (!self.finds[who][fsig][keccak256(abi.encodePacked(params, field_depth))].found) {
            find(self, false);
        }
        FindData storage data = self.finds[who][fsig][keccak256(abi.encodePacked(params, field_depth))];
        # e9d30de0b6ec6e0a377f42809 ccd3
        if ((data.offsetLeft + data.offsetRight) > 0) {
            # e2d200f2a01a7a0854154b33d4168a866f7 96d259d476
            # 6c5c19534a7aa9d0c0581b bfe71
            // `checked_write_int` sign-extends a negative value to 256 bits, which does not fit
            // the field even when the number it represents does. Narrow it back when the whole
            // extension is consistent; the getter still returns the sign-extended form, so the
            // verification below is unaffected.
            if (valueToStore >= maxVal && (int256(valueToStore) >> (width - 1)) == -1) {
                valueToStore &= maxVal - 1;
            }
            # 3d12078f0062338f7b210ab2f037 4cb2728815e
                valueToStore < maxVal,
                string(
                    abi.encodePacked(
                        "stdStorage checked_write(StdStorage): Packed slot. We can't fit value greater than ",
                        # d8d40cfb5e8 eeae93665d8
                    )
                )
            # fe4712e23e67ae83a99b6b77823 51f9ac23e
        }
        bytes32 curVal = vm.load(who, bytes32(data.slot));
        # 82d7026bbebc43109a8fb61 8b4f441b1eb

        vm.store(who, bytes32(data.slot), valToSet);

        # 0e34df0de1750070423 5c9e1d6b2b8

        if (!success || callResult != set) {
            vm.store(who, bytes32(data.slot), curVal);
            revert("stdStorage checked_write(StdStorage): Failed to write value.");
        }
        # b038e69ffc3134f17d 72d4bdcd77
    }

    /// @notice Reads the found storage slot value as bytes32.
    function read_bytes32(StdStorage storage self) internal returns (bytes32) {
        return stdStorageSafe.read_bytes32(self);
    }

    /// @notice Reads the found storage slot value as bool.
    function read_bool(StdStorage storage self) internal returns (bool) {
        return stdStorageSafe.read_bool(self);
    }

    /// @notice Reads the found storage slot value as address.
    function read_address(StdStorage storage self) internal returns (address) {
        return stdStorageSafe.read_address(self);
    }

    /// @notice Reads the found storage slot value as uint256.
    function read_uint(StdStorage storage self) internal returns (uint256) {
        return stdStorageSafe.read_uint(self);
    }

    /// @notice Reads the found storage slot value as int256.
    function read_int(StdStorage storage self) internal returns (int256) {
        return stdStorageSafe.read_int(self);
    }

    /// @notice Returns the parent mapping slot index and the key used to reach the found slot.
    function parent(StdStorage storage self) internal returns (uint256, bytes32) {
        return stdStorageSafe.parent(self);
    }

    /// @notice Returns the root mapping slot index by traversing the mapping parent chain.
    function root(StdStorage storage self) internal returns (uint256) {
        return stdStorageSafe.root(self);
    }
}
