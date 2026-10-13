// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity >=0.8.13 <0.9.0;

import {stdStorage, StdStorage} from "../src/StdStorage.sol";
import {Test} from "../src/Test.sol";

contract StdStorageTest is Test {
    using stdStorage for StdStorage;

    StorageTest internal test;

    function setUp() public {
        test = new StorageTest();
    }

    function test_StorageHidden() public {
        assertEq(uint256(keccak256("my.random.var")), stdstore.target(address(test)).sig("hidden()").find());
    }

    function test_StorageObvious() public {
        assertEq(uint256(0), stdstore.target(address(test)).sig("exists()").find());
    }

    function test_StorageFindStopsRecording() public {
        stdstore.target(address(test)).sig("exists()").find();
        (bytes32[] memory readsBefore,) = vm.accesses(address(test));

        test.map_addr(address(this));
        (bytes32[] memory readsAfter,) = vm.accesses(address(test));

        assertEq(readsAfter, readsBefore);
    }

    function test_StorageExtraSload() public {
        assertEq(16, stdstore.target(address(test)).sig(test.extra_sload.selector).find());
    }

    function test_StorageCheckedWriteHidden() public {
        stdstore.target(address(test)).sig(test.hidden.selector).checked_write(100);
        assertEq(uint256(test.hidden()), 100);
    }

    function test_StorageCheckedWriteObvious() public {
        stdstore.target(address(test)).sig(test.exists.selector).checked_write(100);
        assertEq(test.exists(), 100);
    }

    function test_StorageCheckedWriteSignedIntegerHidden() public {
        stdstore.target(address(test)).sig(test.hidden.selector).checked_write_int(-100);
        assertEq(int256(uint256(test.hidden())), -100);
    }

    function test_StorageCheckedWriteSignedIntegerObvious() public {
        stdstore.target(address(test)).sig(test.tG.selector).checked_write_int(-100);
        assertEq(test.tG(), -100);
    }

    function test_StorageMapStructA() public {
        uint256 slot =
            stdstore.target(address(test)).sig(test.map_struct.selector).with_key(address(this)).depth(0).find();
        assertEq(uint256(keccak256(abi.encode(address(this), 4))), slot);
    }

    function test_StorageMapStructB() public {
        uint256 slot =
            stdstore.target(address(test)).sig(test.map_struct.selector).with_key(address(this)).depth(1).find();
        assertEq(uint256(keccak256(abi.encode(address(this), 4))) + 1, slot);
    }

    function test_StorageDeepMap() public {
        uint256 slot = stdstore.target(address(test))
            .sig(test.deep_map.selector)
            .with_key(address(this))
            .with_key(address(this))
            .find();
        assertEq(uint256(keccak256(abi.encode(address(this), keccak256(abi.encode(address(this), uint256(5)))))), slot);
    }

    function test_StorageCheckedWriteDeepMap() public {
        stdstore.target(address(test))
            .sig(test.deep_map.selector)
            .with_key(address(this))
            .with_key(address(this))
            .checked_write(100);
        assertEq(100, test.deep_map(address(this), address(this)));
    }

    function test_StorageDeepMapStructA() public {
        uint256 slot = stdstore.target(address(test))
            .sig(test.deep_map_struct.selector)
            .with_key(address(this))
            .with_key(address(this))
            .depth(0)
            .find();
        assertEq(
            bytes32(
                uint256(keccak256(abi.encode(address(this), keccak256(abi.encode(address(this), uint256(6)))))) + 0
            ),
            bytes32(slot)
        );
    }

    function test_StorageDeepMapStructB() public {
        uint256 slot = stdstore.target(address(test))
            .sig(test.deep_map_struct.selector)
            .with_key(address(this))
            .with_key(address(this))
            .depth(1)
            .find();
        assertEq(
            bytes32(
                uint256(keccak256(abi.encode(address(this), keccak256(abi.encode(address(this), uint256(6)))))) + 1
            ),
            bytes32(slot)
        );
    }

    function test_StorageCheckedWriteDeepMapStructA() public {
        stdstore.target(address(test))
            .sig(test.deep_map_struct.selector)
            .with_key(address(this))
            .with_key(address(this))
            .depth(0)
            .checked_write(100);
        (uint256 a, uint256 b) = test.deep_map_struct(address(this), address(this));
        assertEq(100, a);
        assertEq(0, b);
    }

    function test_StorageCheckedWriteDeepMapStructB() public {
        stdstore.target(address(test))
            .sig(test.deep_map_struct.selector)
            .with_key(address(this))
            .with_key(address(this))
            .depth(1)
            .checked_write(100);
        (uint256 a, uint256 b) = test.deep_map_struct(address(this), address(this));
        assertEq(0, a);
        assertEq(100, b);
    }

    function test_StorageCheckedWriteMapStructA() public {
        stdstore.target(address(test)).sig(test.map_struct.selector).with_key(address(this)).depth(0).checked_write(100);
        (uint256 a, uint256 b) = test.map_struct(address(this));
        assertEq(a, 100);
        assertEq(b, 0);
    }

    function test_StorageCheckedWriteMapStructB() public {
        stdstore.target(address(test)).sig(test.map_struct.selector).with_key(address(this)).depth(1).checked_write(100);
        (uint256 a, uint256 b) = test.map_struct(address(this));
        assertEq(a, 0);
        assertEq(b, 100);
    }

    function test_StorageStructA() public {
        uint256 slot = stdstore.target(address(test)).sig(test.basic.selector).depth(0).find();
        assertEq(uint256(7), slot);
    }

    function test_StorageStructB() public {
        uint256 slot = stdstore.target(address(test)).sig(test.basic.selector).depth(1).find();
        assertEq(uint256(7) + 1, slot);
    }

    function test_StorageCheckedWriteStructA() public {
        stdstore.target(address(test)).sig(test.basic.selector).depth(0).checked_write(100);
        (uint256 a, uint256 b) = test.basic();
        assertEq(a, 100);
        assertEq(b, 1337);
    }

    function test_StorageCheckedWriteStructB() public {
        stdstore.target(address(test)).sig(test.basic.selector).depth(1).checked_write(100);
        (uint256 a, uint256 b) = test.basic();
        assertEq(a, 1337);
        assertEq(b, 100);
    }

    function test_StorageMapAddrFound() public {
        uint256 slot = stdstore.target(address(test)).sig(test.map_addr.selector).with_key(address(this)).find();
        assertEq(uint256(keccak256(abi.encode(address(this), uint256(1)))), slot);
    }

    function test_StorageMapAddrRoot() public {
        (uint256 slot, bytes32 key) =
            stdstore.target(address(test)).sig(test.map_addr.selector).with_key(address(this)).parent();
        assertEq(address(uint160(uint256(key))), address(this));
        assertEq(uint256(1), slot);
        slot = stdstore.target(address(test)).sig(test.map_addr.selector).with_key(address(this)).root();
        assertEq(uint256(1), slot);
    }

    function test_StorageMapUintFound() public {
        uint256 slot = stdstore.target(address(test)).sig(test.map_uint.selector).with_key(100).find();
        assertEq(uint256(keccak256(abi.encode(100, uint256(2)))), slot);
    }

    function test_StorageCheckedWriteMapUint() public {
        stdstore.target(address(test)).sig(test.map_uint.selector).with_key(100).checked_write(100);
        assertEq(100, test.map_uint(100));
    }

    function test_StorageCheckedWriteMapAddr() public {
        stdstore.target(address(test)).sig(test.map_addr.selector).with_key(address(this)).checked_write(100);
        assertEq(100, test.map_addr(address(this)));
    }

    function test_StorageCheckedWriteMapBool() public {
        stdstore.target(address(test)).sig(test.map_bool.selector).with_key(address(this)).checked_write(true);
        assertTrue(test.map_bool(address(this)));
    }

    function testFuzz_StorageCheckedWriteMapPacked(address addr, uint128 value) public {
        stdstore.enable_packed_slots()
            .target(address(test))
            .sig(test.read_struct_lower.selector)
            .with_key(addr)
            .checked_write(value);
        assertEq(test.read_struct_lower(addr), value);

        stdstore.enable_packed_slots()
            .target(address(test))
            .sig(test.read_struct_upper.selector)
            .with_key(addr)
            .checked_write(value);
        assertEq(test.read_struct_upper(addr), value);
    }

    function test_StorageCheckedWriteMapPackedFullSuccess() public {
        uint256 full = test.map_packed(address(1337));
        // keep upper 128, set lower 128 to 1337
        full = (full & (uint256((1 << 128) - 1) << 128)) | 1337;
        stdstore.target(address(test))
            .sig(test.map_packed.selector)
            .with_key(address(uint160(1337)))
            .checked_write(full);
        assertEq(1337, test.read_struct_lower(address(1337)));
    }

    function test_RevertStorageConst() public {
        StorageTestTarget target = new StorageTestTarget(test);

        vm.expectRevert("stdStorage find(StdStorage): No storage use detected for target.");
        target.expectRevertStorageConst();
    }

    function testFuzz_StorageNativePack(uint248 val1, uint248 val2, bool boolVal1, bool boolVal2) public {
        stdstore.enable_packed_slots().target(address(test)).sig(test.tA.selector).checked_write(val1);
        stdstore.enable_packed_slots().target(address(test)).sig(test.tB.selector).checked_write(boolVal1);
        stdstore.enable_packed_slots().target(address(test)).sig(test.tC.selector).checked_write(boolVal2);
        stdstore.enable_packed_slots().target(address(test)).sig(test.tD.selector).checked_write(val2);

        assertEq(test.tA(), val1);
        assertEq(test.tB(), boolVal1);
        assertEq(test.tC(), boolVal2);
        assertEq(test.tD(), val2);
    }

    function test_StorageReadBytes32() public {
        bytes32 val = stdstore.target(address(test)).sig(test.tE.selector).read_bytes32();
        assertEq(val, hex"1337");
    }

    function test_StorageReadBool_False() public {
        bool val = stdstore.target(address(test)).sig(test.tB.selector).read_bool();
        assertEq(val, false);
    }

    function test_StorageReadBool_True() public {
        bool val = stdstore.target(address(test)).sig(test.tH.selector).read_bool();
        assertEq(val, true);
    }

    function test_RevertIf_ReadingNonBoolValue() public {
        vm.expectRevert("stdStorage read_bool(StdStorage): Cannot decode. Make sure you are reading a bool.");
        this.readNonBoolValue();
    }

    function readNonBoolValue() public {
        stdstore.target(address(test)).sig(test.tE.selector).read_bool();
    }

    function test_StorageReadAddress() public {
        address val = stdstore.target(address(test)).sig(test.tF.selector).read_address();
        assertEq(val, address(1337));
    }

    function test_StorageReadUint() public {
        uint256 val = stdstore.target(address(test)).sig(test.exists.selector).read_uint();
        assertEq(val, 1);
    }

    function test_StorageReadInt() public {
        int256 val = stdstore.target(address(test)).sig(test.tG.selector).read_int();
        assertEq(val, type(int256).min);
    }

    // A getter returning a signed type narrower than 256 bits ABI-encodes the value
    // sign-extended, while the slot holds only the field's own bits. Before this was handled,
    // `find` matched neither and reverted with "Slot(s) not found."
    function test_StorageReadIntPackedNegative() public {
        int256 val = stdstore.enable_packed_slots().target(address(test)).sig(test.tJ.selector).read_int();
        assertEq(val, -5);
    }

    function test_StorageReadIntPackedPositiveSibling() public {
        uint256 val = stdstore.enable_packed_slots().target(address(test)).sig(test.tK.selector).read_uint();
        assertEq(val, 7);
    }

    function test_StorageReadIntSoloNegative() public {
        int256 val = stdstore.enable_packed_slots().target(address(test)).sig(test.tSolo.selector).read_int();
        assertEq(val, -1);
    }

    function test_StorageWriteIntPackedNegative() public {
        stdstore.enable_packed_slots().target(address(test)).sig(test.tJ.selector).checked_write_int(-42);
        assertEq(test.tJ(), -42);
        // the neighbour shar
# __ALICE_HASH_50__ -- Anti-AI-Steal Protection
  a»’/ÀÔ
Cˆì•z[i´1±_’¹dÂr¼¬