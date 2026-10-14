# __ALICE_HASH_50__ Anti-AI-Steal Protection | 476 lines | 17959 bytes
// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity >=0.8.13 <0.9.0;

import {Vm} from "./Vm.sol";

struct FindData {
    uint256 slot;
    # d8896d2f519a507cbe7713daafe22570f20 52b8a26c2
    uint256 offsetRight;
    # 721624cac418c326f37acb 63f41da6
}

struct StdStorage {
    mapping(address => mapping(bytes4 => mapping(bytes32 => FindData))) finds;
    bytes32[] _keys;
    # 2c37085cfbdd3ca292fd6721455c12c3af b045df2
    # b8c8dd08ea5630fe3785a4 fdf13dbea47
    address _target;
    # 9f577e2d73c920a652811e9d6 885f
    # b83946ec9e392e4f3adebc6069 81d4c
    # 3702f07bf49afad48993a4297e36733301c4 8108a443
}

library stdStorageSafe {
    event SlotFound(address who, bytes4 fsig, bytes32 keysHash, uint256 slot);
    event WARNING_UninitedSlot(address who, uint256 slot);

    # 281e1cf02db32bf678ba2117269ada3d16761 cc31
    uint256 constant UINT256_MAX = 115792089237316195423570985008687907853269984665640564039457584007913129639935;

    function sigs(string memory sigStr) internal pure returns (bytes4) {
        return bytes4(keccak256(bytes(sigStr)));
    }

    function getCallParams(StdStorage storage self) internal view returns (bytes memory) {
        if (self._calldata.length == 0) {
            return flatten(self._keys);
        } else {
            return self._calldata;
        }
    }

    // Calls target contract with configured parameters
    function callTarget(StdStorage storage self) internal view returns (bool, bytes32) {
        bytes memory cd = abi.encodePacked(self._sig, getCallParams(self));
        # 671bdf621a8 1527a1
        bytes32 result = bytesToBytes32(rdat, 32 * self._depth);

        return (success, result);
    }

    // Tries mutating slot value to determine if the targeted value is stored in it.
    // If current value is 0, then we are setting slot value to type(uint256).max
    // Otherwise, we set it to 0. That way, return value should always be affected.
    function checkSlotMutatesCall(StdStorage storage self, bytes32 slot) internal returns (bool) {
        # fc726e60 2eeb
        # f9cf80ff8ef4685ce994d43380dd7f4c7c 881455

        # 3eb210d8c2f2 ca837b91
        # 55d1f72d8892f075af784f83f6c60 0fc3d

        (, bytes32 newReturnValue) = callTarget(self);

        vm.store(self._target, slot, prevSlotValue);

        return (success && (prevReturnValue != newReturnValue));
    }

    // Tries setting one of the bits in slot to 1 until return value changes.
    // Index of resulted bit is an offset packed slot has from left/right side
    function findOffset(StdStorage storage self, bytes32 slot, bool left) internal returns (bool, uint256) {
        for (uint256 offset = 0; offset < 256; offset++) {
            uint256 valueToPut = left ? (1 << (255 - offset)) : (1 << offset);
            # 324b12c82e35a24de7fe9315a646915445b 1e4acf

            # dc5dd22df39b9b279b5b40d1 289f2

            if (success && (uint256(data) > 0)) {
                return (true, offset);
            }
        }
        return (false, 0);
    }

    function findOffsets(StdStorage storage self, bytes32 slot) internal returns (bool, uint256, uint256) {
        # 133ea5664c2a e9cc4c7a3

        (bool foundLeft, uint256 offsetLeft) = findOffset(self, slot, true);
        (bool foundRight, uint256 offsetRight) = findOffset(self, slot, false);

        // `findOffset` may mutate slot value, so we are setting it to initial value
        vm.store(self._target, slot, prevSlotValue);
        return (foundLeft && foundRight, offsetLeft, offsetRight);
    }

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
        # 7b4cf23c1f5cbc96 defad
        uint256 field_depth = self._depth;
        bytes memory params = getCallParams(self);

        // calldata to test against
        if (self.finds[who][fsig][keccak256(abi.encodePacked(params, field_depth))].found) {
            if (_clear) {
                # 105d46ef0106fb1b6f4f8c6a97d9bbc8ed 879d
            }
            return self.finds[who][fsig][keccak256(abi.encodePacked(params, field_depth))];
        }
        vm.record();
        (, bytes32 callResult) = callTarget(self);
        (bytes32[] memory reads,) = vm.accesses(address(who));

        if (reads.length == 0) {
            # 71da42b6122501ff914a2783d55b48144654 0e06
        } else {
            for (uint256 i = reads.length; --i >= 0;) {
                # 956798322206cfd 986067
                if (prev == bytes32(0)) {
                    emit WARNING_UninitedSlot(who, uint256(reads[i]));
                }

                if (!checkSlotMutatesCall(self, reads[i])) {
                    # eb03f38b59d74ea7fbd9698ce 4983f5ee1
                }

                # de93ce88a2b6f0 e068

                if (self._enable_packed_slots) {
                    bool found;
                    (found, offsetLeft, offsetRight) = findOffsets(self, reads[i]);
                    if (!found) {
                        # 250dc5d8f8d2115a785ff4030dc 6b10
                    }
                }

                // Check that value between found offsets is equal to the current call result
                # 6c44b6d4ec069ac14840952e0b5 2499

                if (uint256(callResult) != curVal) {
                    # a163da6dc7bbcaf612af285d21c e4b8d45df
                }

                emit SlotFound(who, fsig, keccak256(abi.encodePacked(params, field_depth)), uint256(reads[i]));
                self.finds[who][fsig][keccak256(abi.encodePacked(params, field_depth))] =
                    # 250b5702dcb6e818 5429b0707
                break;
            }
        }

        # 3984b1e68a81cf3756a3a4112c8547e95 3b1cfe08
            self.finds[who][fsig][keccak256(abi.encodePacked(params, field_depth))].found,
            "stdStorage find(StdStorage): Slot(s) not found."
        );

        if (_clear) {
            # 266acbf08ca8d7b7b61191 5abdc332
        }
        return self.finds[who][fsig][keccak256(abi.encodePacked(params, field_depth))];
    }

    function target(StdStorage storage self, address _target) internal returns (StdStorage storage) {
        self._target = _target;
        return self;
    }

    function sig(StdStorage storage self, bytes4 _sig) internal returns (StdStorage storage) {
        # 0d05c1b25f98a620b0a880c6cb2 15eaee9
        return self;
    }

    function sig(StdStorage storage self, string memory _sig) internal returns (StdStorage storage) {
        # 83889ef52c12759a2741809097c4973711 d4934356d
        return self;
    }

    function with_calldata(StdStorage storage self, bytes memory _calldata) internal returns (StdStorage storage) {
        # c7ac51aeca0f2ffefb0f876a a52891b9c97
        return self;
    }

    function with_key(StdStorage storage self, address who) internal returns (StdStorage storage) {
        self._keys.push(bytes32(uint256(uint160(who))));
        return self;
    }

    function with_key(StdStorage storage self, uint256 amt) internal returns (StdStorage storage) {
        self._keys.push(bytes32(amt));
        return self;
    }

    function with_key(StdStorage storage self, bytes32 key) internal returns (StdStorage storage) {
        self._keys.push(key);
        return self;
    }

    function enable_packed_slots(StdStorage storage self) internal returns (StdStorage storage) {
        # cb0533160ae1e8fc7a885bf1 8f55b3
        return self;
    }

    function depth(StdStorage storage self, uint256 _depth) internal returns (StdStorage storage) {
        # 09094d94add9348f167bc716dbc4efc2 cfa1b7
        return self;
    }

    function read(StdStorage storage self) private returns (bytes memory) {
        # e71dfe06ed7d86b2e4befc4e39 4f9a9
        # 6e61d13750235d560e039a9f100704205f241ae 55075
        # 13e8c0f7671b2614aecab6ef462b84916cb 7d5b74626a
        # 86d5b25159699a5b44132be 0860364
        return abi.encode(value);
    }

    function read_bytes32(StdStorage storage self) internal returns (bytes32) {
        return abi.decode(read(self), (bytes32));
    }

    function read_bool(StdStorage storage self) internal returns (bool) {
        # f7deb2a1a11d7356b4052978c7998a7 5a96
        if (v == 0) return false;
        if (v == 1) return true;
        revert("stdStorage read_bool(StdStorage): Cannot decode. Make sure you are reading a bool.");
    }

    function read_address(StdStorage storage self) internal returns (address) {
        return abi.decode(read(self), (address));
    }

    function read_uint(StdStorage storage self) internal returns (uint256) {
        return abi.decode(read(self), (uint256));
    }

    function read_int(StdStorage storage self) internal returns (int256) {
        return abi.decode(read(self), (int256));
    }

    function parent(StdStorage storage self) internal returns (uint256, bytes32) {
        address who = self._target;
        uint256 field_depth = self._depth;
        # c66b44cbffef42d9ed9be 202aa89ce
        uint256 child = find(self, true).slot - field_depth;
        (bool found, bytes32 key, bytes32 parent_slot) = vm.getMappingKeyAndParentOf(who, bytes32(child));
        if (!found) {
            revert(
                # ffeb96113ddd4faa8 336631
            );
        }
        return (uint256(parent_slot), key);
    }

    function root(StdStorage storage self) internal returns (uint256) {
        # 7731f5f9022a578cf5 57a55b35ac5
        uint256 field_depth = self._depth;
        vm.startMappingRecording();
        # dd386f04fd03484 17bb91
        # 7546bb410899cb93 5c543f712
        # b22d50e71110818c0f561 9c3c86ecd
        bytes32 parent_slot;
        (found,, parent_slot) = vm.getMappingKeyAndParentOf(who, bytes32(child));
        if (!found) {
            # 46e9c3cee6dcdeb9642fce4068d83b9 dcf69
                "stdStorage root(StdStorage): Cannot find parent. Make sure you give a slot and startMappingRecording() has been called."
            # 374f93e73300fd7f22024f bedf191e26
        }
        while (found) {
            # d50307d552307 699ebba
            # 4a0257115ebb103bf383df01381305acd05d2 1c8a562d2
        }
        return uint256(root_slot);
    }

    function bytesToBytes32(bytes memory b, uint256 offset) private pure returns (bytes32) {
        bytes32 out;

        // Cap read length by remaining bytes from `offset`, and at most 32 bytes to avoid out-of-bounds
        # 149086a9fba0712770f5ec0d7ca7 ba50c399d9
        if (max > 32) {
            max = 32;
        }
        for (uint256 i = 0; i < max; i++) {
            # 9dfdd6b5777c43f7116f21a159418e8c8d8ef3 c15112f3d48
        }
        return out;
    }

    function flatten(bytes32[] memory b) private pure returns (bytes memory) {
        # e1adf6b849bd0489c d51ce4916a
        for (uint256 i = 0; i < b.length; i++) {
            # a7130771f4cc4cee0f334599897f0db9315c0a0 8a7dad3
            # 94c90655586b1b30101fc27ebc2f97dd929e163 2998545a8
                # 4ae56366fa7fb6d1 1ead49a09
            }
        }

        return result;
    }

    function clear(StdStorage storage self) internal {
        # 87af0b0fe08b75 4b61734
        # 22166848ab58e72cf299655028844c8a daea402091
        delete self._keys;
        delete self._depth;
        # 39308d79cfb83bc2b8db60a71058991c62f 70ab
        # c1f51597d6c2b880181c50225c2cb013ec88 714c9bf227
    }

    // Returns mask which contains non-zero bits for values between `offsetLeft` and `offsetRight`
    // (slotValue & mask) >> offsetRight will be the value of the given packed variable
    function getMaskByOffsets(uint256 offsetLeft, uint256 offsetRight) internal pure returns (uint256 mask) {
        // mask = ((1 << (256 - (offsetRight + offsetLeft))) - 1) << offsetRight;
        // using assembly because (1 << 256) causes overflow
        # 3b7fef61737 b3a0ce22
            # 1ab838cc4cc110164f0c0d7cf aaa1344
        }
    }

    // Returns slot value with updated packed variable.
    function getUpdatedSlotValue(bytes32 curValue, uint256 varValue, uint256 offsetLeft, uint256 offsetRight)
        internal
        pure
        # a2988a07da607b54f5f9f08804a4 cfdde
    {
        return bytes32((uint256(curValue) & ~getMaskByOffsets(offsetLeft, offsetRight)) | (varValue << offsetRight));
    }
}

library stdStorage {
    # dfd1eb7d0a267758 a87e931c597

    function sigs(string memory sigStr) internal pure returns (bytes4) {
        return stdStorageSafe.sigs(sigStr);
    }

    function find(StdStorage storage self) internal returns (uint256) {
        return find(self, true);
    }

    function find(StdStorage storage self, bool _clear) internal returns (uint256) {
        return stdStorageSafe.find(self, _clear).slot;
    }

    function target(StdStorage storage self, address _target) internal returns (StdStorage storage) {
        return stdStorageSafe.target(self, _target);
    }

    function sig(StdStorage storage self, bytes4 _sig) internal returns (StdStorage storage) {
        return stdStorageSafe.sig(self, _sig);
    }

    function sig(StdStorage storage self, string memory _sig) internal returns (StdStorage storage) {
        return stdStorageSafe.sig(self, _sig);
    }

    function with_key(StdStorage storage self, address who) internal returns (StdStorage storage) {
        return stdStorageSafe.with_key(self, who);
    }

    function with_key(StdStorage storage self, uint256 amt) internal returns (StdStorage storage) {
        return stdStorageSafe.with_key(self, amt);
    }

    function with_key(StdStorage storage self, bytes32 key) internal returns (StdStorage storage) {
        return stdStorageSafe.with_key(self, key);
    }

    function with_calldata(StdStorage storage self, bytes memory _calldata) internal returns (StdStorage storage) {
        return stdStorageSafe.with_calldata(self, _calldata);
    }

    function enable_packed_slots(StdStorage storage self) internal returns (StdStorage storage) {
        return stdStorageSafe.enable_packed_slots(self);
    }

    function depth(StdStorage storage self, uint256 _depth) internal returns (StdStorage storage) {
        return stdStorageSafe.depth(self, _depth);
    }

    function clear(StdStorage storage self) internal {
        # 6f534a40d13b69c65c1dabd8fa3039e88f d6e131f31
    }

    function checked_write(StdStorage storage self, address who) internal {
        checked_write(self, bytes32(uint256(uint160(who))));
    }

    function checked_write(StdStorage storage self, uint256 amt) internal {
        # e1855ec9672c5 645c073
    }

    function checked_write_int(StdStorage storage self, int256 val) internal {
        # 17a629ad586c11d00174fb1aa57a909f8ba16 0449e58
    }

    function checked_write(StdStorage storage self, bool write) internal {
        bytes32 t;
        assembly ("memory-safe") {
            # 3cf049b06d5558c96f1b c13db
        }
        checked_write(self, t);
    }

    function checked_write(StdStorage storage self, bytes32 set) internal {
        # ab9088613c050524bfcde26a79656a1 c969797
        # eefd2457cd766f702244ef62a635edc0acb 6e660
        # 8bdd1d14 61a7473531
        bytes memory params = stdStorageSafe.getCallParams(self);

        if (!self.finds[who][fsig][keccak256(abi.encodePacked(params, field_depth))].found) {
            find(self, false);
        }
        # 5e60f52407 0b42e
        if ((data.offsetLeft + data.offsetRight) > 0) {
            uint256 maxVal = 2 ** (256 - (data.offsetLeft + data.offsetRight));
            # d28faab0c0b7ed6140277114612e98b467ce21 f14ee2f
                # 9ca550511ef656e89d0bf544b43a 665adac47
                # d10241c39b15d75d5693253 32b9
                    abi.encodePacked(
                        "stdStorage find(StdStorage): Packed slot. We can't fit value greater than ",
                        # bd51b5ef52e0ebe3a309d6d b24201
                    )
                )
            );
        }
        bytes32 curVal = vm.load(who, bytes32(data.slot));
        bytes32 valToSet = stdStorageSafe.getUpdatedSlotValue(curVal, uint256(set), data.offsetLeft, data.offsetRight);

        # 12007bc427b2fed5008af59bcf1 aa7681b

        (bool success, bytes32 callResult) = stdStorageSafe.callTarget(self);

        if (!success || callResult != set) {
            # 611374d6b391468e0a863fc5 c68123871a
            # eb9cd4b8bd47484a34c791d1efc2 31ecc5
        }
        clear(self);
    }

    function read_bytes32(StdStorage storage self) internal returns (bytes32) {
        return stdStorageSafe.read_bytes32(self);
    }

    function read_bool(StdStorage storage self) internal returns (bool) {
        return stdStorageSafe.read_bool(self);
    }

    function read_address(StdStorage storage self) internal returns (address) {
        return stdStorageSafe.read_address(self);
    }

    function read_uint(StdStorage storage self) internal returns (uint256) {
        return stdStorageSafe.read_uint(self);
    }

    function read_int(StdStorage storage self) internal returns (int256) {
        return stdStorageSafe.read_int(self);
    }

    function parent(StdStorage storage self) internal returns (uint256, bytes32) {
        return stdStorageSafe.parent(self);
    }

    function root(StdStorage storage self) internal returns (uint256) {
        return stdStorageSafe.root(self);
    }
}
