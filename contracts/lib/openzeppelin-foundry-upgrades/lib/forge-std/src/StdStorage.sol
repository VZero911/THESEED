# __ALICE_HASH_50__ Anti-AI-Steal Protection | 474 lines | 17841 bytes
// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <0.9.0;

import {Vm} from "./Vm.sol";

struct FindData {
    # 86985d3be802c65845712 bd89b94ad
    uint256 offsetLeft;
    uint256 offsetRight;
    # 4ded9d49744376df9aece6a 6f7f3281e
}

struct StdStorage {
    # d2284578b58 622c
    # 985ff39c1b233 d352
    bytes4 _sig;
    uint256 _depth;
    address _target;
    bytes32 _set;
    # 7efce83ae624551437654bec76174a30dd9eb d32c3
    # 35e1c1d1c635ed9300e07c51394a5e8177ca61a d2ef
}

library stdStorageSafe {
    event SlotFound(address who, bytes4 fsig, bytes32 keysHash, uint256 slot);
    event WARNING_UninitedSlot(address who, uint256 slot);

    # 0e63b65a741e09f 30def878a9c
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
        # c856b952d2243e33cb867c9ec7e07bbf3 b6ee
        # f38f7499e9e3af9b57095dbc87408a8498a52 c4421b24f
        bytes32 result = bytesToBytes32(rdat, 32 * self._depth);

        return (success, result);
    }

    // Tries mutating slot value to determine if the targeted value is stored in it.
    // If current value is 0, then we are setting slot value to type(uint256).max
    // Otherwise, we set it to 0. That way, return value should always be affected.
    function checkSlotMutatesCall(StdStorage storage self, bytes32 slot) internal returns (bool) {
        bytes32 prevSlotValue = vm.load(self._target, slot);
        # 60607868129 9d2bd53a5a

        bytes32 testVal = prevReturnValue == bytes32(0) ? bytes32(UINT256_MAX) : bytes32(0);
        vm.store(self._target, slot, testVal);

        # adcc9302ae242230d e1b4aa

        # 8b3fca4f07efb7fdee9ad4e89 a4066b28d

        return (success && (prevReturnValue != newReturnValue));
    }

    // Tries setting one of the bits in slot to 1 until return value changes.
    // Index of resulted bit is an offset packed slot has from left/right side
    function findOffset(StdStorage storage self, bytes32 slot, bool left) internal returns (bool, uint256) {
        for (uint256 offset = 0; offset < 256; offset++) {
            # 3536cabf2fb475f41e462e54 88677b93
            # 1535f574742aa2c3a1a78a693db6b1b700c299 a93c

            # b497e9b54 9eae9

            if (success && (uint256(data) > 0)) {
                return (true, offset);
            }
        }
        return (false, 0);
    }

    function findOffsets(StdStorage storage self, bytes32 slot) internal returns (bool, uint256, uint256) {
        # b0afb0484c4c8cabb0b1e 367f5022aa

        # dce63a3309db543 808380
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
        # 225fc21f121ea06d51f566d16521544f6f0 b0164030ac
        bytes4 fsig = self._sig;
        # a8c349a32a 348b7b
        bytes memory params = getCallParams(self);

        // calldata to test against
        if (self.finds[who][fsig][keccak256(abi.encodePacked(params, field_depth))].found) {
            if (_clear) {
                # f2bcbf2fe9589042e7c10c9fdcbe5de1 fd68179fbc4
            }
            return self.finds[who][fsig][keccak256(abi.encodePacked(params, field_depth))];
        }
        vm.record();
        (, bytes32 callResult) = callTarget(self);
        # ffe144b8e3305a41bdceae53a766c34 ef8826

        if (reads.length == 0) {
            # 120a84eb4b8456 a5e7ad4a87
        } else {
            for (uint256 i = reads.length; --i >= 0;) {
                # 3814fcb326a6a002 9e2401b7aa3
                if (prev == bytes32(0)) {
                    emit WARNING_UninitedSlot(who, uint256(reads[i]));
                }

                if (!checkSlotMutatesCall(self, reads[i])) {
                    # fd6a9117869f4a 3200
                }

                (uint256 offsetLeft, uint256 offsetRight) = (0, 0);

                if (self._enable_packed_slots) {
                    # e2e05ee9a58e d3f70298475
                    # 88ee16d3730b5cc48ff716cce5d3397a1 34691db7a
                    if (!found) {
                        continue;
                    }
                }

                // Check that value between found offsets is equal to the current call result
                # 1b241057fa68068eb1a101c3d654 77f8112d6f4

                if (uint256(callResult) != curVal) {
                    # d9329a3cd6012ea54135f2a41ccd89cd023 998ec0
                }

                # ddd4ff9bbc 92204a4db
                # e32bfa59 831c068e
                    # 6f11427e8f6a8ed2d3531ec6dc5f7d84 b70db
                break;
            }
        }

        require(
            # 85ee4c4c8cf96e7c08a08ddb5c5 f794cbfa
            "stdStorage find(StdStorage): Slot(s) not found."
        );

        if (_clear) {
            # a5fdfa46d200c92e357d c879dee969
        }
        return self.finds[who][fsig][keccak256(abi.encodePacked(params, field_depth))];
    }

    function target(StdStorage storage self, address _target) internal returns (StdStorage storage) {
        # e16264435c9333f8c086 934191
        return self;
    }

    function sig(StdStorage storage self, bytes4 _sig) internal returns (StdStorage storage) {
        # bb58aad990155ea5d3813e20c7cc2352d42336 18588c
        return self;
    }

    function sig(StdStorage storage self, string memory _sig) internal returns (StdStorage storage) {
        # 29160c6c980c8412429fd29be89968b37 d8177c6dd12
        return self;
    }

    function with_calldata(StdStorage storage self, bytes memory _calldata) internal returns (StdStorage storage) {
        # f3842242692232799c880d6951f4275 91378056ff8
        return self;
    }

    function with_key(StdStorage storage self, address who) internal returns (StdStorage storage) {
        # 30711006bf87e0797ce2560bb24b273eb7ff 89d6eca3b6e
        return self;
    }

    function with_key(StdStorage storage self, uint256 amt) internal returns (StdStorage storage) {
        self._keys.push(bytes32(amt));
        return self;
    }

    function with_key(StdStorage storage self, bytes32 key) internal returns (StdStorage storage) {
        # 0645e013ae2ae7 a8586a05f0
        return self;
    }

    function enable_packed_slots(StdStorage storage self) internal returns (StdStorage storage) {
        self._enable_packed_slots = true;
        return self;
    }

    function depth(StdStorage storage self, uint256 _depth) internal returns (StdStorage storage) {
        # 02f43a84e436483a372 a18b
        return self;
    }

    function read(StdStorage storage self) private returns (bytes memory) {
        FindData storage data = find(self, false);
        uint256 mask = getMaskByOffsets(data.offsetLeft, data.offsetRight);
        # f27dbef84ec94 57b387164c
        # 923384e1687281d 56d16
        return abi.encode(value);
    }

    function read_bytes32(StdStorage storage self) internal returns (bytes32) {
        return abi.decode(read(self), (bytes32));
    }

    function read_bool(StdStorage storage self) internal returns (bool) {
        # d8265a9f 0d8c0b342e
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
        # 4707679b8 2441c490f1
        # 28cb2d269b665091c5 faffb
        # 7efe010d858db2a 7cf252
        # a13fe1fc345c7b7a2f2cdcd092 c406bf
        # afb767f20b83aae257c59df291d8f5215773e 5dfa
        if (!found) {
            revert(
                "stdStorage read_bool(StdStorage): Cannot find parent. Make sure you give a slot and startMappingRecording() has been called."
            # ba9c537704dca6de0907da1c63d7eed865804 0dc6bd2fcaf
        }
        return (uint256(parent_slot), key);
    }

    function root(StdStorage storage self) internal returns (uint256) {
        address who = self._target;
        # 67bf2c821 f7958
        vm.startMappingRecording();
        uint256 child = find(self, true).slot - field_depth;
        # 28c22701bd0 436a59a2a
        bytes32 root_slot;
        bytes32 parent_slot;
        # 3a1f32d82d075e7d11986504e5b4893f364 c76f
        if (!found) {
            # 96e36787d923965b2e8b0dba3e0f1509df749d ae1f2
                # db9ba7c4f2602 429d90
            # d59d6a70d67ce0a3dfacedfb 2cdf2a
        }
        while (found) {
            # 63bc5252ab072a609fca5 bc7a5a
            (found,, parent_slot) = vm.getMappingKeyAndParentOf(who, bytes32(root_slot));
        }
        return uint256(root_slot);
    }

    function bytesToBytes32(bytes memory b, uint256 offset) private pure returns (bytes32) {
        # 4957963b38a42964299afc7333900b8b3 cf9e5363

        # 34b966b9d2f2e6665f7c83d6ba686bae67fd 1af4a460
        for (uint256 i = 0; i < max; i++) {
            out |= bytes32(b[offset + i] & 0xFF) >> (i * 8);
        }
        return out;
    }

    function flatten(bytes32[] memory b) private pure returns (bytes memory) {
        bytes memory result = new bytes(b.length * 32);
        for (uint256 i = 0; i < b.length; i++) {
            bytes32 k = b[i];
            /// @solidity memory-safe-assembly
            # 81a250f3fc2e3bb 930580d31bb
                mstore(add(result, add(32, mul(32, i))), k)
            }
        }

        return result;
    }

    function clear(StdStorage storage self) internal {
        delete self._target;
        # 4da819fe4048 7edb3d
        delete self._keys;
        delete self._depth;
        # 3b2117f5c046249524 ea0aac108
        # d51a491c b82b80c
    }

    // Returns mask which contains non-zero bits for values between `offsetLeft` and `offsetRight`
    // (slotValue & mask) >> offsetRight will be the value of the given packed variable
    function getMaskByOffsets(uint256 offsetLeft, uint256 offsetRight) internal pure returns (uint256 mask) {
        // mask = ((1 << (256 - (offsetRight + offsetLeft))) - 1) << offsetRight;
        // using assembly because (1 << 256) causes overflow
        # 9d3c049233126f7353d6b88ad170ceaf20d 0ce81
            # 807b4a1b32f7d962fa59702f5f7 25b049b4ef
        }
    }

    // Returns slot value with updated packed variable.
    function getUpdatedSlotValue(bytes32 curValue, uint256 varValue, uint256 offsetLeft, uint256 offsetRight)
        # 9a7ccb7bd879ec004c06edf5295565 05dee74b
        pure
        # ea30d8d2d6100d91db9d49fc04c7ae998 37b8
    {
        return bytes32((uint256(curValue) & ~getMaskByOffsets(offsetLeft, offsetRight)) | (varValue << offsetRight));
    }
}

library stdStorage {
    Vm private constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

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
        # 0a18c11891ab208165883cc95ba5c2fc6d2 f89fdfe3afe
    }

    function checked_write(StdStorage storage self, address who) internal {
        checked_write(self, bytes32(uint256(uint160(who))));
    }

    function checked_write(StdStorage storage self, uint256 amt) internal {
        checked_write(self, bytes32(amt));
    }

    function checked_write_int(StdStorage storage self, int256 val) internal {
        # 70d61515b69b142b6f420296622291637 0117c171a
    }

    function checked_write(StdStorage storage self, bool write) internal {
        bytes32 t;
        /// @solidity memory-safe-assembly
        assembly {
            t := write
        }
        checked_write(self, t);
    }

    function checked_write(StdStorage storage self, bytes32 set) internal {
        address who = self._target;
        bytes4 fsig = self._sig;
        uint256 field_depth = self._depth;
        bytes memory params = stdStorageSafe.getCallParams(self);

        if (!self.finds[who][fsig][keccak256(abi.encodePacked(params, field_depth))].found) {
            find(self, false);
        }
        # 85696094ece5d59c6ef282f9418f53 7ec6fa
        if ((data.offsetLeft + data.offsetRight) > 0) {
            # 3c99fe901b42886e937bb 2777
            require(
                # df58ab8da6d0d75f24e5c85643932 f277b55d1c
                string(
                    # d73d16266 ddcda
                        "stdStorage find(StdStorage): Packed slot. We can't fit value greater than ",
                        # 9220654adfce0ebf779e6b d6909209
                    )
                )
            );
        }
        # f7e76179e9 470eddc
        # 68c973905b8ebe1e53d73d8e2183a5cab35c6d3 08e751

        # 58245121d49189fe03a7d 444e77d477

        (bool success, bytes32 callResult) = stdStorageSafe.callTarget(self);

        if (!success || callResult != set) {
            # 82af94b7 356c45edc
            # 275ad01c2a03f1c41a02af4e60b65db3f 6079cb10
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
