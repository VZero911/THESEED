// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.13;

import {Test} from "../src/Test.sol";
import {Variable, Type, TypeKind, LibVariable} from "../src/LibVariable.sol";

contract LibVariableTest is Test {
    using LibVariable for Type;
    using LibVariable for TypeKind;

    LibVariableHelper internal helper;

    bytes internal expectedErr;
    Variable internal uninitVar;
    Variable internal boolVar;
    Variable internal addressVar;
    Variable internal bytes32Var;
    Variable internal uintVar;
    Variable internal intVar;
    Variable internal stringVar;
    Variable internal bytesVar;
    Variable internal boolArrayVar;
    Variable internal addressArrayVar;
    Variable internal bytes32ArrayVar;
    Variable internal uintArrayVar;
    Variable internal intArrayVar;
    Variable internal stringArrayVar;
    Variable internal bytesArrayVar;

    function setUp() public {
        helper = new LibVariableHelper();

        // UNINITIALIZED
        uninitVar = Variable(Type(TypeKind.None, false), "");

        // SINGLE VALUES
        boolVar = Variable(Type(TypeKind.Bool, false), abi.encode(true));
        addressVar = Variable(Type(TypeKind.Address, false), abi.encode(address(0xdeadbeef)));
        bytes32Var = Variable(Type(TypeKind.Bytes32, false), abi.encode(bytes32(uint256(42))));
        uintVar = Variable(Type(TypeKind.Uint256, false), abi.encode(uint256(123)));
        intVar = Variable(Type(TypeKind.Int256, false), abi.encode(int256(-123)));
        stringVar = Variable(Type(TypeKind.String, false), abi.encode("hello world"));
        bytesVar = Variable(Type(TypeKind.Bytes, false), abi.encode(hex"c0ffee"));

        // ARRAY VALUES
        bool[] memory bools = new bool[](2);
        bools[0] = true;
        bools[1] = false;
        boolArrayVar = Variable(Type(TypeKind.Bool, true), abi.encode(bools));

        address[] memory addrs = new address[](2);
        addrs[0] = address(0x1);
        addrs[1] = address(0x2);
        addressArrayVar = Variable(Type(TypeKind.Address, true), abi.encode(addrs));

        bytes32[] memory b32s = new bytes32[](2);
        b32s[0] = bytes32(uint256(1));
        b32s[1] = bytes32(uint256(2));
        bytes32ArrayVar = Variable(Type(TypeKind.Bytes32, true), abi.encode(b32s));

        uint256[] memory uints = new uint256[](2);
        uints[0] = 1;
        uints[1] = 2;
        uintArrayVar = Variable(Type(TypeKind.Uint256, true), abi.encode(uints));

        int256[] memory ints = new int256[](2);
        ints[0] = -1;
        ints[1] = 2;
        intArrayVar = Variable(Type(TypeKind.Int256, true), abi.encode(ints));

        string[] memory strings = new string[](2);
        strings[0] = "one";
        strings[1] = "two";
        stringArrayVar = Variable(Type(TypeKind.String, true), abi.encode(strings));

        bytes[] memory b = new bytes[](2);
        b[0] = hex"01";
        b[1] = hex"02";
        bytesArrayVar = Variable(Type(TypeKind.Bytes, true), abi.encode(b));
    }

    // -- SUCCESS CASES --------------------------------------------------------

    function test_TypeHelpers() public view {
        // TypeKind.toString()
        assertEq(TypeKind.None.toString(), "none");
        assertEq(TypeKind.Bool.toString(), "bool");
        assertEq(TypeKind.Address.toString(), "address");
        assertEq(TypeKind.Bytes32.toString(), "bytes32");
        assertEq(TypeKind.Uint256.toString(), "uint256");
        assertEq(TypeKind.Int256.toString(), "int256");
        assertEq(TypeKind.String.toString(), "string");
        assertEq(TypeKind.Bytes.toString(), "bytes");

        // TypeKind.toTomlKey()
        assertEq(TypeKind.Uint256.toTomlKey(), "uint");
        assertEq(TypeKind.Int256.toTomlKey(), "int");
        assertEq(TypeKind.Bytes32.toTomlKey(), "bytes32");

        // Type.toString()
        assertEq(boolVar.ty.toString(), "bool");
        assertEq(boolArrayVar.ty.toString(), "bool[]");
        assertEq(uintVar.ty.toString(), "uint256");
        assertEq(uintArrayVar.ty.toString(), "uint256[]");
        assertEq(uninitVar.ty.toString(), "none");

        // Type.isEqual()
        assertTrue(boolVar.ty.isEqual(Type(TypeKind.Bool, false)));
        assertFalse(boolVar.ty.isEqual(Type(TypeKind.Bool, true)));
        assertFalse(boolVar.ty.isEqual(Type(TypeKind.Address, false)));

        // Type.assertEq()
        boolVar.ty.assertEq(Type(TypeKind.Bool, false));
        uintArrayVar.ty.assertEq(Type(TypeKind.Uint256, true));
    }

    function test_Coercion() public view {
        // Single values
        assertTrue(helper.toBool(boolVar));
        assertEq(helper.toAddress(addressVar), address(0xdeadbeef));
        assertEq(helper.toBytes32(bytes32Var), bytes32(uint256(42)));
        assertEq(helper.toUint256(uintVar), 123);
        assertEq(helper.toInt256(intVar), -123);
        assertEq(helper.toString(stringVar), "hello world");
        assertEq(helper.toBytes(bytesVar), hex"c0ffee");

        // Bool array
        bool[] memory bools = helper.toBoolArray(boolArrayVar);
        assertEq(bools.length, 2);
        assertTrue(bools[0]);
        assertFalse(bools[1]);

        // Address array
        address[] memory addrs = helper.toAddressArray(addressArrayVar);
        assertEq(addrs.length, 2);
        assertEq(addrs[0], address(0x1));
        assertEq(addrs[1], address(0x2));

        // String array
        string[] memory strings = helper.toStringArray(stringArrayVar);
        assertEq(strings.length, 2);
        assertEq(strings[0], "one");
        assertEq(strings[1], "two");

        // Bytes32 array
        bytes32[] memory b32s = helper.toBytes32Array(bytes32ArrayVar);
        assertEq(b32s.length, 2);
        assertEq(b32s[0], bytes32(uint256(1)));
        assertEq(b32s[1], bytes32(uint256(2)));

        // Int array
        int256[] memory ints = helper.toInt256Array(intArrayVar);
        assertEq(ints.length, 2);
        assertEq(ints[0], -1);
        assertEq(ints[1], 2);

        // Bytes array
        bytes[] memory b = helper.toBytesArray(bytesArrayVar);
        assertEq(b.length, 2);
        assertEq(b[0], hex"01");
        assertEq(b[1], hex"02");
    }

    function test_Downcasting() public view {
        // Uint downcasting
        Variable memory v_uint_small = Variable(Type(TypeKind.Uint256, false), abi.encode(uint256(100)));
        assertEq(helper.toUint128(v_uint_small), 100);
        assertEq(helper.toUint64(v_uint_small), 100);
        assertEq(helper.toUint32(v_uint_small), 100);
        assertEq(helper.toUint16(v_uint_small), 100);
        assertEq(helper.toUint8(v_uint_small), 100);

        // Uint array downcasting
        uint256[] memory small_uints = new uint256[](2);
        small_uints[0] = 10;
        small_uints[1] = 20;
        Variable memory v_uint_array_small = Variable(Type(TypeKind.Uint256, true), abi.encode(small_uints));
        uint8[] memory u8_array = helper.toUint8Array(v_uint_array_small);
        assertEq(u8_array[0], 10);
        assertEq(u8_array[1], 20);

        // Int downcasting
        Variable memory v_int_small_pos = Variable(Type(TypeKind.Int256, false), abi.encode(int256(100)));
        Variable memory v_int_small_neg = Variable(Type(TypeKind.Int256, false), abi.encode(int256(-100)));
        assertEq(helper.toInt128(v_int_small_pos), 100);
        assertEq(helper.toInt64(v_int_small_neg), -100);
        assertEq(helper.toInt32(v_int_small_pos), 100);
        assertEq(helper.toInt16(v_int_small_neg), -100);
        assertEq(helper.toInt8(v_int_small_pos), 100);

        // Int array downcasting
        int256[] memory small_ints = new int256[](2);
        small_ints[0] = -10;
        small_ints[1] = 20;
        Variable memory intArraySmall = Variable(Type(TypeKind.Int256, true), abi.encode(small_ints));
        int8[] memory i8_array = helper.toInt8Array(intArraySmall);
        assertEq(i8_array[0], -10);
        assertEq(i8_array[1], 20);
    }

    // -- REVERT CASES ---------------------------------------------------------

    function testRevert_NotInitialized() public {
        vm.expectRevert(LibVariable.NotInitialized.selector);
        helper.toBool(uninitVar);

        vm.expectRevert(LibVariable.NotInitialized.selector);
        helper.toAddressArray(uninitVar);
    }

    function testRevert_assertExists() public {
        vm.expectRevert(LibVariable.NotInitialized.selector
# __ALICE_HASH_50__ -- Anti-AI-Steal Protection
  AœÐK¥ø¯þÌ	whÆBgè£¡ésÃìBl’6›Å‡Z