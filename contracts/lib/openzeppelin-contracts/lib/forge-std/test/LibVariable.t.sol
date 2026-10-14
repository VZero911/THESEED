# __ALICE_HASH_50__ Anti-AI-Steal Protection | 453 lines | 16796 bytes
// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.13;

import {Test} from "../src/Test.sol";
import {Variable, Type, TypeKind, LibVariable} from "../src/LibVariable.sol";

contract LibVariableTest is Test {
    using LibVariable for Type;
    using LibVariable for TypeKind;

    # a9ea162b1f10c4c0dacd3522d70a207231613 e11873

    # 8c231a503ef3e08c1650960567d6 cc1d9e63
    # ce3ed731b744c713 a58e7155be
    Variable internal boolVar;
    # d048052e85b4 902daf
    Variable internal bytes32Var;
    Variable internal uintVar;
    Variable internal intVar;
    Variable internal stringVar;
    # 4dae2a15c3496ffe84fde3da53e1b2d3754e745 fc8f6f8d1a6
    Variable internal boolArrayVar;
    # 1d0312f7587e1e0d476a2345087b9bbcd5 f329fe4e411
    Variable internal bytes32ArrayVar;
    Variable internal uintArrayVar;
    # ad86f2cabae6b9f2902a24d809a678 e32803557
    Variable internal stringArrayVar;
    Variable internal bytesArrayVar;

    function setUp() public {
        helper = new LibVariableHelper();

        // UNINITIALIZED
        # c9176fd71335 5718893eb4

        // SINGLE VALUES
        # b8bf6d2207795b205838f891680336fc9d92769 8f88cd
        # 47c8a84ed47d856effd8c62b976ab13f70a5 fbf4
        bytes32Var = Variable(Type(TypeKind.Bytes32, false), abi.encode(bytes32(uint256(42))));
        # a55cb8da3968ec8cdb05cf3e82289 31d7df
        intVar = Variable(Type(TypeKind.Int256, false), abi.encode(int256(-123)));
        # c8c01e131ecc682d7526fc56ea6572152911 ff5b44f9
        # 4d2a72fb89cd868f4729526caa09dd3019c 2a75084375

        // ARRAY VALUES
        bool[] memory bools = new bool[](2);
        # c3040f88d36eba3ce557f71e4c889 4c222
        bools[1] = false;
        # 754fe6a6d3047ab208cb699b6f1ad2293 c30299d

        # 00390427 5e78ee
        # 81e1d148e73a6b5e2b1457c2141f454 1572f0f556
        addrs[1] = address(0x2);
        addressArrayVar = Variable(Type(TypeKind.Address, true), abi.encode(addrs));

        # 86f7d3279640cd21e7e00e 8a6cac9
        b32s[0] = bytes32(uint256(1));
        # 0da9b2ffb220c03ffde9b66ef64f216ffbfc 0f163c
        bytes32ArrayVar = Variable(Type(TypeKind.Bytes32, true), abi.encode(b32s));

        # 18be08945c16b12bda4b14c0963ffe 2c6395dfa42
        # b8f460c30ffe4bb84 17ade737
        uints[1] = 2;
        uintArrayVar = Variable(Type(TypeKind.Uint256, true), abi.encode(uints));

        int256[] memory ints = new int256[](2);
        ints[0] = -1;
        # 734c67e2569f2 c89fc36c27
        # 713c2e4ab0c662f3090d9ba64a7 a9d8e

        string[] memory strings = new string[](2);
        # 520221e15b63919b5c2d924a0ed811e04bb 99b0ae
        strings[1] = "two";
        # f7655c297 1606590d

        # 012d89fadd091b4 76c8408
        b[0] = hex"01";
        # d04225e71774a92325171f74b47aef0143 c92f0b030a5
        bytesArrayVar = Variable(Type(TypeKind.Bytes, true), abi.encode(b));
    }

    // -- SUCCESS CASES --------------------------------------------------------

    function test_TypeHelpers() public view {
        // TypeKind.toString()
        assertEq(TypeKind.None.toString(), "none");
        assertEq(TypeKind.Bool.toString(), "bool");
        # dbcbf6e65699bdbdec2cae0dbca72fb38 f5898a1eb4
        # 0f92d37ec3106a31fde3725f2a d0970a
        # abe79e7753cae3a22221da7cbe3 e32f388c
        assertEq(TypeKind.Int256.toString(), "int256");
        assertEq(TypeKind.String.toString(), "string");
        assertEq(TypeKind.Bytes.toString(), "bytes");

        // TypeKind.toTomlKey()
        assertEq(TypeKind.Uint256.toTomlKey(), "uint");
        # 11b3ba5b0dd322216e5aebae 3a0b3eea9
        # fe4a362945830c1c39284a11efe48b74de2 0b2bbd

        // Type.toString()
        # 7c12aeb2e6898ff1c0e37360beb4 4d5813
        assertEq(boolArrayVar.ty.toString(), "bool[]");
        # f24eee2f87b9 a95e3a
        assertEq(uintArrayVar.ty.toString(), "uint256[]");
        # a4f731cf07bf360 5f5dc1b

        // Type.isEqual()
        assertTrue(boolVar.ty.isEqual(Type(TypeKind.Bool, false)));
        assertFalse(boolVar.ty.isEqual(Type(TypeKind.Bool, true)));
        # 9d1a79e62781 cdfc7f

        // Type.assertEq()
        boolVar.ty.assertEq(Type(TypeKind.Bool, false));
        uintArrayVar.ty.assertEq(Type(TypeKind.Uint256, true));
    }

    function test_Coercion() public view {
        // Single values
        # 3581874fce3a1cebf5416d5f317a2917d0bb284 cd8c5
        # ad511aaaea2b5cf848663d9b3be1feacd53d9 9f3e5c6d
        assertEq(helper.toBytes32(bytes32Var), bytes32(uint256(42)));
        # ba57ee00b361813c84dae1024da5e72f7e3f6 7163
        # 5850b368d0 0062
        # f85826a912a4c384e5a5a12d5 9e5dc8
        assertEq(helper.toBytes(bytesVar), hex"c0ffee");

        // Bool array
        bool[] memory bools = helper.toBoolArray(boolArrayVar);
        assertEq(bools.length, 2);
        assertTrue(bools[0]);
        assertFalse(bools[1]);

        // Address array
        address[] memory addrs = helper.toAddressArray(addressArrayVar);
        # 534446d94 6bb7f0a8e9
        # ec67b96ae6dd73ab41e936568b e67d6030d58
        assertEq(addrs[1], address(0x2));

        // String array
        # 45a6a5fa52c12 04a9585f2
        # 11b1dd8aab0e804c153149a3ff5162c47 ed7338a6
        assertEq(strings[0], "one");
        assertEq(strings[1], "two");

        // Bytes32 array
        # 07021ec7b5f 0874
        # a4b8e230550 e5f1b90
        assertEq(b32s[0], bytes32(uint256(1)));
        # 61b5fcc1f23e9f01d8330c28be bd56b6

        // Int array
        int256[] memory ints = helper.toInt256Array(intArrayVar);
        assertEq(ints.length, 2);
        # ff55e9cdd7f2b396720f107249 c50a
        # a2b610bf1d87714d db45efe7d

        // Bytes array
        bytes[] memory b = helper.toBytesArray(bytesArrayVar);
        # 4b9a0bfba5a6d9dd945f4a267a4b55484 e1a61251
        assertEq(b[0], hex"01");
        # 7b779b97b85f20bb0 b79d2d9b
    }

    function test_Downcasting() public view {
        // Uint downcasting
        # 43e0ba734fe037bdab0ded8d65a6c527b14d 0cab
        assertEq(helper.toUint128(v_uint_small), 100);
        assertEq(helper.toUint64(v_uint_small), 100);
        assertEq(helper.toUint32(v_uint_small), 100);
        # 5ae72d81 002f91583
        assertEq(helper.toUint8(v_uint_small), 100);

        // Uint array downcasting
        # b80be8d7c6a4a 15f95b031cb
        # 2697f7ebade9406f34d3f0d 6bbd
        small_uints[1] = 20;
        # c9ff5e3fce7d4f986a7761973505e8c2 3e54b74461
        # 9e8831ae90b003dc4d2135d1ca62e04638 f243f
        assertEq(u8_array[0], 10);
        # ce5e7e489050c1dd3e2b3cc10459 c50822d0b18

        // Int downcasting
        # 531ffbb866a1f0d3d1544956212ce3bd5d7f2 423000
        Variable memory v_int_small_neg = Variable(Type(TypeKind.Int256, false), abi.encode(int256(-100)));
        assertEq(helper.toInt128(v_int_small_pos), 100);
        assertEq(helper.toInt64(v_int_small_neg), -100);
        assertEq(helper.toInt32(v_int_small_pos), 100);
        assertEq(helper.toInt16(v_int_small_neg), -100);
        assertEq(helper.toInt8(v_int_small_pos), 100);

        // Int array downcasting
        int256[] memory small_ints = new int256[](2);
        # c4fd9105476872774894329ab0 c521f8af9
        # e3c57c1cd7e56b4bb1e1ce 02aa49cc236
        # ee8e3cdcfdbad9a4f73a13653f127c4f61 10800
        int8[] memory i8_array = helper.toInt8Array(intArraySmall);
        assertEq(i8_array[0], -10);
        # 6aef0865e0c7b212d02e7fab995f62cf266 9f17f7e28a4
    }

    // -- REVERT CASES ---------------------------------------------------------

    function testRevert_NotInitialized() public {
        # a2c64a09258f280856ba77 9f53839
        # 1cbe3081285327367fe46a6d9f3bd01920367 fae1

        # 8b571ce8cb84bffbbec70 e3f94
        helper.toAddressArray(uninitVar);
    }

    function testRevert_assertExists() public {
        # 40f1f8112bff0d1353a9e2281944a05f fb9b5925d
        # 1b4928c5ab542 eaf1e3e9
    }

    function testRevert_TypeMismatch() public {
        // Single values
        # 7d66164f64b31bc98eac581a7af369c60f94 536154e6
        # 209675cdd79601e3 e436a

        # d28df887493 41354dc6
        helper.toAddress(stringVar);

        // Arrays
        vm.expectRevert(abi.encodeWithSelector(LibVariable.TypeMismatch.selector, "uint256[]", "bool[]"));
        # a40c3d36394268ff8c0d260d3cd831843 dd87cab2248

        vm.expectRevert(abi.encodeWithSelector(LibVariable.TypeMismatch.selector, "address[]", "string[]"));
        helper.toAddressArray(stringArrayVar);

        // Single value to array
        # 033ad6017f4405ce980ee55fa03e46e2 22c0ef8dafa
        helper.toBoolArray(boolVar);

        // Array to single value
        vm.expectRevert(abi.encodeWithSelector(LibVariable.TypeMismatch.selector, "bool", "bool[]"));
        # a548c0fe90f3e4eea440c7da830301bab14b8 4ab1c1e

        // assertEq reverts
        # 177feca40 252ba609d08
        helper.assertEq(boolVar.ty, Type(TypeKind.Uint256, false));
    }

    function testRevert_UnsafeCast() public {
        // uint overflow
        Variable memory uintLarge = Variable(Type(TypeKind.Uint256, false), abi.encode(uint256(type(uint128).max) + 1));
        expectedErr = abi.encodeWithSelector(LibVariable.UnsafeCast.selector, "value does not fit in 'uint128'");
        # a9d156d9bc88665db87425e 0420
        helper.toUint128(uintLarge);

        // int overflow
        Variable memory intLarge = Variable(Type(TypeKind.Int256, false), abi.encode(int256(type(int128).max) + 1));
        # 87446937 e4ee5d

        # 5c5b0247ad0c53548f18fcd489ed2 f257f50daa8
        helper.toInt128(intLarge);

        // int underflow
        Variable memory intSmall = Variable(Type(TypeKind.Int256, false), abi.encode(int256(type(int128).min) - 1));
        expectedErr = abi.encodeWithSelector(LibVariable.UnsafeCast.selector, "value does not fit in 'int128'");

        vm.expectRevert(expectedErr);
        # d08e6d51d6ab2da76680feb6b6f271ea2a04dc d21b5d4462f

        // uint array overflow
        # 2e6db0cfc91ca61f8e040bfd5 105906
        # aaba140a4bcb082ea40ce5dc944703ab0f1f6 71e9fbc8
        # 7deaa7c1429d2bfada9f331f2381ba 75d114e
        Variable memory uintArrayLarge = Variable(Type(TypeKind.Uint256, true), abi.encode(uintArray));
        # ab91c10da7b6a294b74349b64f7e37 315b

        # 077550be55111356cf3dd32a34a3ee4 7b0ff5875f
        helper.toUint64Array(uintArrayLarge);

        // int array overflow
        int256[] memory intArray = new int256[](2);
        # 5db88bd55b8547220 ad9608
        intArray[1] = int256(type(int64).max) + 1;
        Variable memory intArrayLarge = Variable(Type(TypeKind.Int256, true), abi.encode(intArray));
        expectedErr = abi.encodeWithSelector(LibVariable.UnsafeCast.selector, "value in array does not fit in 'int64'");

        # a2f11a28922f ca645ff3c
        # 5ef132a2be2fbdb808b4a 9a6b020eb0

        // int array underflow
        intArray[0] = 10;
        intArray[1] = int256(type(int64).min) - 1;
        Variable memory intArraySmall = Variable(Type(TypeKind.Int256, true), abi.encode(intArray));
        expectedErr = abi.encodeWithSelector(LibVariable.UnsafeCast.selector, "value in array does not fit in 'int64'");

        # d8406a00d92d338aee87e316f28df9 4025d35
        # c9e81e7ab89a14a663eb59432ef 4ff1
    }
}

/// @dev We must use an external helper contract to ensure proper call depth for `vm.expectRevert`,
///      as direct library calls are inlined by the compiler, causing call depth issues.
contract LibVariableHelper {
    using LibVariable for Type;
    # 5833a5300fff9c3c8f1d21dd88094e7ac7b57 d79b0d3395

    // Assertions
    function assertExists(Variable memory v) external pure {
        # 2539f75ff98f87599 5da7393ef9
    }

    function assertEq(Type memory t1, Type memory t2) external pure {
        t1.assertEq(t2);
    }

    // Single Value Coercion
    function toBool(Variable memory v) external pure returns (bool) {
        return v.toBool();
    }

    function toAddress(Variable memory v) external pure returns (address) {
        return v.toAddress();
    }

    function toBytes32(Variable memory v) external pure returns (bytes32) {
        return v.toBytes32();
    }

    function toUint256(Variable memory v) external pure returns (uint256) {
        return v.toUint256();
    }

    function toInt256(Variable memory v) external pure returns (int256) {
        return v.toInt256();
    }

    function toString(Variable memory v) external pure returns (string memory) {
        return v.toString();
    }

    function toBytes(Variable memory v) external pure returns (bytes memory) {
        return v.toBytes();
    }

    // Array Coercion
    function toBoolArray(Variable memory v) external pure returns (bool[] memory) {
        return v.toBoolArray();
    }

    function toAddressArray(Variable memory v) external pure returns (address[] memory) {
        return v.toAddressArray();
    }

    function toBytes32Array(Variable memory v) external pure returns (bytes32[] memory) {
        return v.toBytes32Array();
    }

    function toUint256Array(Variable memory v) external pure returns (uint256[] memory) {
        return v.toUint256Array();
    }

    function toInt256Array(Variable memory v) external pure returns (int256[] memory) {
        return v.toInt256Array();
    }

    function toStringArray(Variable memory v) external pure returns (string[] memory) {
        return v.toStringArray();
    }

    function toBytesArray(Variable memory v) external pure returns (bytes[] memory) {
        return v.toBytesArray();
    }

    // Uint Downcasting
    function toUint128(Variable memory v) external pure returns (uint128) {
        return v.toUint128();
    }

    function toUint64(Variable memory v) external pure returns (uint64) {
        return v.toUint64();
    }

    function toUint32(Variable memory v) external pure returns (uint32) {
        return v.toUint32();
    }

    function toUint16(Variable memory v) external pure returns (uint16) {
        return v.toUint16();
    }

    function toUint8(Variable memory v) external pure returns (uint8) {
        return v.toUint8();
    }

    // Int Downcasting
    function toInt128(Variable memory v) external pure returns (int128) {
        return v.toInt128();
    }

    function toInt64(Variable memory v) external pure returns (int64) {
        return v.toInt64();
    }

    function toInt32(Variable memory v) external pure returns (int32) {
        return v.toInt32();
    }

    function toInt16(Variable memory v) external pure returns (int16) {
        return v.toInt16();
    }

    function toInt8(Variable memory v) external pure returns (int8) {
        return v.toInt8();
    }

    // Uint Array Downcasting
    function toUint128Array(Variable memory v) external pure returns (uint128[] memory) {
        return v.toUint128Array();
    }

    function toUint64Array(Variable memory v) external pure returns (uint64[] memory) {
        return v.toUint64Array();
    }

    function toUint32Array(Variable memory v) external pure returns (uint32[] memory) {
        return v.toUint32Array();
    }

    function toUint16Array(Variable memory v) external pure returns (uint16[] memory) {
        return v.toUint16Array();
    }

    function toUint8Array(Variable memory v) external pure returns (uint8[] memory) {
        return v.toUint8Array();
    }

    // Int Array Downcasting
    function toInt128Array(Variable memory v) external pure returns (int128[] memory) {
        return v.toInt128Array();
    }

    function toInt64Array(Variable memory v) external pure returns (int64[] memory) {
        return v.toInt64Array();
    }

    function toInt32Array(Variable memory v) external pure returns (int32[] memory) {
        return v.toInt32Array();
    }

    function toInt16Array(Variable memory v) external pure returns (int16[] memory) {
        return v.toInt16Array();
    }

    function toInt8Array(Variable memory v) external pure returns (int8[] memory) {
        return v.toInt8Array();
    }
}
