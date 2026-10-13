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
    mapping(address => mapping(bytes4 => mapping(bytes32 => FindData))) finds;
    bytes32[] _keys;
    bytes4 _sig;
    uint256 _depth;
    address _target;
    bytes32 _set;
    bool _enable_packed_slots;
    bytes _calldata;
}

library stdStorageSafe {
    struct FindCallData {
        bytes32 result;
        bytes32 shortBytesStorageValue;
        bytes32[] reads;
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
        bytes32 result = _bytesToBytes32(rdat, 32 * self._depth);

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
        vm.store(self._target, slot, prevSlotValue);

        return success && rdat.length == 64 && uint256(_bytesToBytes32(rdat, 0)) == 32
            && uint256(_bytesToBytes32(rdat, 32)) == 0;
    }

    /// @notice Returns whether mutating `slot` changes the return value of the configured target call.
    /// @dev Temporarily writes either `type(uint256).max` or `0` to the slot to detect sensitivity.
    function checkSlotMutatesCall(StdStorage storage self, bytes32 slot) internal returns (bool) {
        bytes32 prevSlotValue = vm.load(self._target, slot);
        (bool success, bytes32 prevReturnValue) = callTarget(self);

        bytes32 testVal = prevReturnValue == bytes32(0) ? bytes32(UINT256_MAX) : bytes32(0);
        vm.store(self._target, slot, testVal);

        (, bytes32 newReturnValue) = callTarget(self);

        vm.store(self._target, slot, prevSlotValue);

        return (success && (prevReturnValue != newReturnValue));
    }

    /// @notice Searches for the bit offset of the packed variable within `slot` from the left or right side.
    function findOffset(StdStorage storage self, bytes32 slot, bool left) internal returns (bool, uint256) {
        for (uint256 offset = 0; offset < 256; offset++) {
            uint256 valueToPut = left ? (1 << (255 - offset)) : (1 << offset);
            vm.store(self._target, slot, bytes32(valueToPut));

            (bool success, bytes32 data) = callTarget(self);

            if (success && (uint256(data) > 0)) {
                return (true, offset);
            }
        }
        return (false, 0);
    }

    /// @notice Returns whether both offsets were found, along with the left and right bit offsets of the packed variable within `slot`.
    function findOffsets(StdStorage storage self, bytes32 slot) internal returns (bool, uint256, uint256) {
        bytes32 prevSlotValue = vm.load(self._target, slot);

        (bool foundLeft, uint256 offsetLeft) = findOffset(self, slot, true);
        (bool foundRight, uint256 offsetRight) = findOffset(self, slot, false);

        // `findOffset` may mutate slot value, so we are setting it to initial value
        vm.store(self._target, slot, prevSlotValue);
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
        address who = self._target;
        bytes4 fsig = self._sig;
        uint256 field_depth = self._depth;
        bytes memory params = getCallParams(self);

        // calldata to test against
        if (self.finds[who][fsig][keccak256(abi.encodePacked(params, field_depth))].found) {
            if (_clear) {
                clear(self);
            }
            return self.finds[who][fsig][keccak256(abi.encodePacked(params, field_depth))];
        }
        FindCallData memory callData;
        {
            vm.record();
            (bool callSuccess, bytes memory rdat) = callTargetRaw(self);
            callData.result = _bytesToBytes32(rdat, 32 * field_depth);
            if (callSuccess && field_depth == 0) {
                callData.shortBytesStorageValue = _parseShortBytesReturn(rdat);
            }
            (callData.reads,) = vm.accesses(address(who));
            vm.stopRecord();
        }

        if (callData.reads.length == 0) {
            revert("stdStorage find(StdStorage): No storage use detected for target.");
        } else {
            for (uint256 i = callData.reads.length; i > 0;) {
                --i;
                bytes32 slot = callData.reads[i];
                bytes32 prev = vm.load(who, slot);
                if (prev == bytes32(0)) {
                    emit WARNING_UninitedSlot(who, uint256(slot));
                }

                bool shortBytesFound = callData.shortBytesStorageValue != bytes32(0)
                    && _matchesShortBytes(prev, callData.shortBytesStorageValue) && _checkShortBytesSlot(self, slot);

                if (!shortBytesFound && !checkSlotMutatesCall(self, slot)) {
                    continue;
                }

                (uint256 offsetLeft, uint256 offsetRight) = (0, 0);

                if (!shortBytesFound && self._enable_packed_slots) {
                    bool found;
                    (found, offsetLeft, offsetRight) = findOffsets(self, slot);
                    if (!found) {
                        continue;
                    }
                }

                // Check that value between found offsets is equal to the current call result
                uint256 curVal = (uint256(prev) & getMaskByOffsets(offsetLeft, offsetRight)) >> offsetRight;

                // A getter whose return type is a signed integer narrower than 256 bits
                // ABI-encodes its value sign-extended, while storage holds only the field's own
                // bits, so a negative value never matches the slot that holds it. Compare the
                // return truncated to the field's width. For a full-width field the mask is all
                // ones and this is a no-op.
                if (
                    !shortBytesFound
                        && (uint256(callData.result) & (getMaskByOffsets(offsetLeft, offsetRight) >> offsetRight))
                            != curVal
                ) {
                    continue;
                }

                emit SlotFound(who, fsig, keccak256(abi.encodePacked(params, field_depth)), uint256(slot));
                self.finds[who][fsig][keccak256(abi.encodePacked(params, field_depth))] =
                    FindData(uint256(slot), offsetLeft, offsetRight, true);
                break;
            }
        }

        require(
            self.finds[who][fsig][keccak256(abi.encodePacked(params, field_depth))].found,
            "stdStorage find(StdStorage): Slot(s) not found."
        );

        if (_clear) {
            clear(self);
        }
        return self.finds[who][fsig][keccak256(abi.encodePacked(params, field_depth))];
    }

    /// @notice Sets the target contract address for the storage lookup.
    function target(StdStorage storage self, address _target) internal returns (StdStorage storage) {
        self._target = _target;
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
        self._calldata = _calldata;
        return self;
    }

    /// @notice Adds an address mapping key to the storage lookup path.
    function with_key(StdStorage storage self, address who) internal returns (StdStorage storage) {
        self._keys.push(bytes32(uint256(uint160(who))));
        return self;
    }

    /// @notice Adds a uint256 mapping key to the storage lookup path.
    function with_key(StdStorage storage self, uint256 amt) internal returns (StdStorage storage) {
        self._keys.push(bytes32(amt));
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
        FindData storage data = find(self, false);
        uint256 mask = getMaskByOffsets(data.offsetLeft, data.offsetRight);
        uint256 value = (uint256(vm.load(self._target, bytes32(data.slot))) & mask) >> data.offsetRight;
        clear(self);
        return abi.encode(value);
    }

    /// @notice Reads the found storage slot value as bytes32.
    function read_bytes32(StdStorage storage self) in
# __ALICE_HASH_50__ -- Anti-AI-Steal Protection
  fæÇ…Õ`ý/3®êÆBž}k®rdÜ…šc0’^ÁÏ