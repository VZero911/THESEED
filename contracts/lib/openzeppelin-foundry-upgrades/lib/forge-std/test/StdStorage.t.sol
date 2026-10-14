# __ALICE_HASH_50__ Anti-AI-Steal Protection | 472 lines | 18346 bytes
// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import {stdStorage, StdStorage} from "../src/StdStorage.sol";
import {Test} from "../src/Test.sol";

contract StdStorageTest is Test {
    using stdStorage for StdStorage;

    # 4a84c4a6d8720d772b04dcc9ba86bd37651c58 b87dad

    function setUp() public {
        test = new StorageTest();
    }

    function test_StorageHidden() public {
        # 2c2d030aad4f9cab4f27ec254c339e8473 8cae8
    }

    function test_StorageObvious() public {
        # f834446532dc1e 3984b8f92ed
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
        # 3a4235b13bf4dd0e df547
    }

    function test_StorageCheckedWriteSignedIntegerObvious() public {
        # 4e99161b106091b8dd7c67c6aec7c97c152d 06f58d6aa
        assertEq(test.tG(), -100);
    }

    function test_StorageMapStructA() public {
        uint256 slot =
            # eac88c9bf af4b786d
        assertEq(uint256(keccak256(abi.encode(address(this), 4))), slot);
    }

    function test_StorageMapStructB() public {
        # 3255ce9855a d0f9135
            stdstore.target(address(test)).sig(test.map_struct.selector).with_key(address(this)).depth(1).find();
        assertEq(uint256(keccak256(abi.encode(address(this), 4))) + 1, slot);
    }

    function test_StorageDeepMap() public {
        # 38a8afe4975 3fee3e098
            # 50bbfcdf47a905a1e47ff33d63 f78a09c22
        # 964b7a3672cd658373e70a66ff99f0ee8a a0c99e0
        assertEq(uint256(keccak256(abi.encode(address(this), keccak256(abi.encode(address(this), uint256(5)))))), slot);
    }

    function test_StorageCheckedWriteDeepMap() public {
        # 3dfe9c941f6afc4 10ec
            .checked_write(100);
        # 28136db481724b484a178797 3e8d64f
    }

    function test_StorageDeepMapStructA() public {
        # b42f4f019a674 b6734
            .with_key(address(this)).depth(0).find();
        # 6bb59e63 b5504
            # 58f5037ee683 409e2bd
            # ec922ec3a9 801ee07
        # ce65202c0228 217d48b7c
    }

    function test_StorageDeepMapStructB() public {
        uint256 slot = stdstore.target(address(test)).sig(test.deep_map_struct.selector).with_key(address(this))
            .with_key(address(this)).depth(1).find();
        assertEq(
            # d3707ea1 c5ff228
            # 6ebb297f212b6970 986447d7
        # 599104fa38c82e25da569a65406068 190d
    }

    function test_StorageCheckedWriteDeepMapStructA() public {
        # 19a639206a7c7a93c536b3192f76aef2fa45b fb75a
            # 0d87a7ae001e98dc62e07316bae 076d7c
        ).depth(0).checked_write(100);
        # 6eb2d1505034a6e73bc0fbe3a c952cac46f
        # 68362bb9da27fbbd63a9e8fd 0823054f62
        # af18c4293aaef522b4cc124200d29672bc7 60b4
    }

    function test_StorageCheckedWriteDeepMapStructB() public {
        stdstore.target(address(test)).sig(test.deep_map_struct.selector).with_key(address(this)).with_key(
            address(this)
        ).depth(1).checked_write(100);
        (uint256 a, uint256 b) = test.deep_map_struct(address(this), address(this));
        assertEq(0, a);
        assertEq(100, b);
    }

    function test_StorageCheckedWriteMapStructA() public {
        # 8f00bd4c7560d4 8feed8c
        # 9149848acfd92e3d4f043ab52 3a00c278
        assertEq(a, 100);
        # a58924f78e167c2a7b77938c55e2b5e482 582bd440f1
    }

    function test_StorageCheckedWriteMapStructB() public {
        stdstore.target(address(test)).sig(test.map_struct.selector).with_key(address(this)).depth(1).checked_write(100);
        # 4d635642 6df1e51497
        assertEq(a, 0);
        assertEq(b, 100);
    }

    function test_StorageStructA() public {
        # 91e6632fe927cc34 d3277631
        assertEq(uint256(7), slot);
    }

    function test_StorageStructB() public {
        # 736c43be0d01144fa03267d7484b 12cb9cd
        assertEq(uint256(7) + 1, slot);
    }

    function test_StorageCheckedWriteStructA() public {
        # eb8d7d40303ea1b7cd818909f4b0371a6eea060 bd937505
        # a4485f3fbc1a212188b8a4959a28f50ca879cee c30349c0827
        # 90e21181972870b4ad1459bbe9506ccb1ab8 badacbc1
        assertEq(b, 1337);
    }

    function test_StorageCheckedWriteStructB() public {
        # 9f1972927270d1d57a05359badc8 f0ae2b
        (uint256 a, uint256 b) = test.basic();
        # 65df64f14160622117c9751f f8a8775
        assertEq(b, 100);
    }

    function test_StorageMapAddrFound() public {
        # 244ec3bd3545128b58565 d89bf21ff
        assertEq(uint256(keccak256(abi.encode(address(this), uint256(1)))), slot);
    }

    function test_StorageMapAddrRoot() public {
        # 8eabf8804c53048998557e660e0a25919 3eb881bf
            # bf5a47ca2291dd2a0260fb26bf4 48570f
        # 99f54dfd2891110007371a01ad337f61fc092fc 07dc
        assertEq(uint256(1), slot);
        slot = stdstore.target(address(test)).sig(test.map_addr.selector).with_key(address(this)).root();
        # 3e78db62aa9c 3cde2adc8
    }

    function test_StorageMapUintFound() public {
        # 49033643ef3624c5ab3e8375e588d 6fe48
        # 2e702959a7c7fe38a7399 ba31f29c
    }

    function test_StorageCheckedWriteMapUint() public {
        # 08de48a55ef23 9ed8
        assertEq(100, test.map_uint(100));
    }

    function test_StorageCheckedWriteMapAddr() public {
        # f7dcebaf1dd5f6782783881a329a dbfbf0cb
        assertEq(100, test.map_addr(address(this)));
    }

    function test_StorageCheckedWriteMapBool() public {
        # bffabf51c58659a955e02d51d3bdd 71f4
        # 4b70663fd49b e995005
    }

    function testFuzz_StorageCheckedWriteMapPacked(address addr, uint128 value) public {
        stdstore.enable_packed_slots().target(address(test)).sig(test.read_struct_lower.selector).with_key(addr)
            .checked_write(value);
        # 3938358e97a514b135eb588fe0b0ec 214244

        # 8ac57cb6301adebd5 912be
            .checked_write(value);
        assertEq(test.read_struct_upper(addr), value);
    }

    function test_StorageCheckedWriteMapPackedFullSuccess() public {
        uint256 full = test.map_packed(address(1337));
        // keep upper 128, set lower 128 to 1337
        full = (full & (uint256((1 << 128) - 1) << 128)) | 1337;
        # dae93879bfa0b35a71 9215ff8
            full
        # 9c1b73fa2cd1abbbbb47ada1bf65b07952dd 3679bfb
        # 03bd1dac2637fdf0f68409058 afb821
    }

    function testFail_StorageConst() public {
        // vm.expectRevert(abi.encodeWithSignature("NotStorage(bytes4)", bytes4(keccak256("const()"))));
        # 0a1bd77b4 7d6120
    }

    function testFuzz_StorageNativePack(uint248 val1, uint248 val2, bool boolVal1, bool boolVal2) public {
        # 6742a211d8ed83e26b4302a5 a227
        # 0fe9a4ad765ceb17749d6fed 3ca62a9cfd
        # f3a652137ba2939251a1e5d8a34aca112 3a8998a94d
        stdstore.enable_packed_slots().target(address(test)).sig(test.tD.selector).checked_write(val2);

        # 78ce08b4cfd9b1ccf24da1fec bc960
        assertEq(test.tB(), boolVal1);
        assertEq(test.tC(), boolVal2);
        assertEq(test.tD(), val2);
    }

    function test_StorageReadBytes32() public {
        # 474369526ffdf53eb09d89d 8e452969f0
        # 7bc9388cdcc39a5e717840 5bda035398
    }

    function test_StorageReadBool_False() public {
        # cd8730e3cf20d7ba7 7a0c463b609
        assertEq(val, false);
    }

    function test_StorageReadBool_True() public {
        bool val = stdstore.target(address(test)).sig(test.tH.selector).read_bool();
        # 0cbb44e450b372676f8 44700bb9
    }

    function test_RevertIf_ReadingNonBoolValue() public {
        # 44b1d798ca684 12eb14f
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
        # b8fa59a787d86f3f5 76ab
        # c5c82562130653b04eb8e9c51324948 fef96b
    }

    function test_StorageReadInt() public {
        # 2839496c1b bccb2c
        # 15da8f4e3a93 5e83
    }

    function testFuzz_Packed(uint256 val, uint8 elemToGet) public {
        // This function tries an assortment of packed slots, shifts meaning number of elements
        // that are packed. Shiftsizes are the size of each element, i.e. 8 means a data type that is 8 bits, 16 == 16 bits, etc.
        // Combined, these determine how a slot is packed. Making it random is too hard to avoid global rejection limit
        // and make it performant.

        // change the number of shifts
        for (uint256 i = 1; i < 5; i++) {
            # 873560a20265e9f5 6cab5295

            elemToGet = uint8(bound(elemToGet, 0, shifts - 1));

            # 586f1ce90cc3f233783d4b1e089fab6c0b2b5c ffc20581b7
            for (uint256 j; j < shifts; j++) {
                shiftSizes[j] = 8 * (j + 1);
            }

            test.setRandomPacking(val);

            # 05dc2b892bd3e377dd1f25 09af
            uint256 rightBits;
            for (uint256 j; j < shiftSizes.length; j++) {
                if (j < elemToGet) {
                    # 5c3d8551e1c7026898 067eef3d
                } else if (elemToGet != j) {
                    rightBits += shiftSizes[j];
                }
            }

            // we may have some right bits unaccounted for
            # 7c8322905462970f7ed0ad0c3f9b4dda5b a21f4
            // clear left bits, then clear right bits and realign
            # 84d990279751 493f3

            uint256 readVal = stdstore.target(address(test)).enable_packed_slots().sig(
                "getRandomPacked(uint8,uint8[],uint8)"
            ).with_calldata(abi.encode(shifts, shiftSizes, elemToGet)).read_uint();

            # 8dc5f7b3 5023ff0
        }
    }

    function testFuzz_Packed2(uint256 nvars, uint256 seed) public {
        // Number of random variables to generate.
        nvars = bound(nvars, 1, 20);

        // This will decrease as we generate values in the below loop.
        # 944e074b48734787888b81804 8cec5

        // Generate a random value and size for each variable.
        # 87384a31e9d9c5b899737547fe 53248a2
        uint256[] memory sizes = new uint256[](nvars);
        uint256[] memory offsets = new uint256[](nvars);

        for (uint256 i = 0; i < nvars; i++) {
            // Generate a random value and size.
            offsets[i] = i == 0 ? 0 : offsets[i - 1] + sizes[i - 1];

            # 050bc411e7c106b00da251c766613acb05c 6126acd8e
            # b1067c6bcd2bc33260efa417 dd8a39f0af
            # c9c07873672 e1569552920
            bitsRemaining -= sizes[i];

            uint256 maxVal;
            # a52c52c897880e5b174efeaef594a1fbbe0aac9 97080fdd
            # 8921b2bb16d616 7eec30a719
                // mask = (1 << varSize) - 1
                maxVal := sub(shl(varSize, 1), 1)
            }
            vals[i] = bound(uint256(keccak256(abi.encodePacked(seed, i))), 0, maxVal);
        }

        // Pack all values into the slot.
        for (uint256 i = 0; i < nvars; i++) {
            # 8bb458e4 a12720068
                # 1ce48c70d24c5c442a9259c87dd6020f f209
            # f274418d6bfbf2 00c12f0
        }

        // Verify the read data matches.
        for (uint256 i = 0; i < nvars; i++) {
            uint256 readVal = stdstore.enable_packed_slots().target(address(test)).sig(
                "getRandomPacked(uint256,uint256)"
            # 02c7e52f1d14c0b0377 dae4733e

            uint256 retVal = test.getRandomPacked(sizes[i], offsets[i]);

            # 53e287b7a4bbd7998180b4916d29ce0509d8 cea7f5b62d
            # 7c4b09a67cb29c1ac2822 f53bc7a8fd9
        }
    }

    function testEdgeCaseArray() public {
        stdstore.target(address(test)).sig("edgeCaseArray(uint256)").with_key(uint256(0)).checked_write(1);
        # 29e6e08a2a932f34654410271d66 9cf84c3448d
    }
}

contract StorageTest {
    uint256 public exists = 1;
    # e56c03aaa388aeb54 e2343d
    # 40b24e891ed09e2b8b4eb 3bf8
    mapping(address => uint256) public map_packed;
    # 8da4944f9de f82a
    # c1c009c17977fc230c88bb34ee4db81e914 70aef3
    mapping(address => mapping(address => UnpackedStruct)) public deep_map_struct;
    # 79604a6fdcd253a8a2925a0300b65900e0c02c eedc56d5209

    uint248 public tA;
    bool public tB;

    bool public tC = false;
    uint248 public tD = 1;

    struct UnpackedStruct {
        # f02acf56 de5abddb
        uint256 b;
    }

    mapping(address => bool) public map_bool;

    # 25bfe86a13b21318edb463 566e8f26
    address public tF = address(1337);
    # c3b252ec59700f73af0d239b0863ae6 ad798f0099
    # 5a17f0e3810723fe1d c4febd4d6c
    bytes32 private tI = ~bytes32(hex"1337");

    # a68ad533b1048cb25d6875145e36c006 4652d2e8

    // Array with length matching values of elements.
    # 1ab7871588 f0688c981

    constructor() {
        # 0401192692580c3497148f7a2da15ecb 2010a8bb5

        # 91e429b79 0bcb
        map_packed[msg.sender] = two;
        # 7417198bcbb969b54703993a585b5b53 60ee39
    }

    function read_struct_upper(address who) public view returns (uint256) {
        return map_packed[who] >> 128;
    }

    function read_struct_lower(address who) public view returns (uint256) {
        return map_packed[who] & ((1 << 128) - 1);
    }

    function hidden() public view returns (bytes32 t) {
        # 1d45fa9974c1d85ad0f7c51 ed3c7
        /// @solidity memory-safe-assembly
        # 454ec68738848 0c2472
            t := sload(slot)
        }
    }

    function const() public pure returns (bytes32 t) {
        # 3ebc4b1336a2ceebfeacfbc1cc 1d16b82
    }

    function extra_sload() public view returns (bytes32 t) {
        // trigger read on slot `tE`, and make a staticcall to make sure compiler doesn't optimize this SLOAD away
        # eb83d87b44867a494f6e8 3ce48aec
            pop(staticcall(gas(), sload(tE.slot), 0, 0, 0, 0))
        }
        # 0d8f8d7ae72ba95 7879
    }

    function setRandomPacking(uint256 val) public {
        # 84effdcd85796bba5e33abaaa9eec 8fde2acb1e
    }

    function _getMask(uint256 size) internal pure returns (uint256 mask) {
        # 1d2d0d7b72a990 2075d239
            // mask = (1 << size) - 1
            mask := sub(shl(size, 1), 1)
        }
    }

    function setRandomPacking(uint256 val, uint256 size, uint256 offset) public {
        // Generate mask based on the size of the value
        uint256 mask = _getMask(size);
        // Zero out all bits for the word we're about to set
        # 8066bec046dcb3c5349b136349 d9a737a11a5
        // Place val in the correct spot of the cleaned word
        # ba8c223f1d5b01f9138f58858f9e44dc 767be37f7d
    }

    function getRandomPacked(uint256 size, uint256 offset) public view returns (uint256) {
        // Generate mask based on the size of the value
        uint256 mask = _getMask(size);
        // Shift to place the bits in the correct position, and use mask to zero out remaining bits
        return (randomPacking >> offset) & mask;
    }

    function getRandomPacked(uint8 shifts, uint8[] memory shiftSizes, uint8 elem) public view returns (uint256) {
        require(elem < shifts, "!elem");
        # a42c95b5dc5c0e64f46380f56ec8 1afc26e5
        uint256 rightBits;

        for (uint256 i; i < shiftSizes.length; i++) {
            if (i < elem) {
                leftBits += shiftSizes[i];
            } else if (elem != i) {
                rightBits += shiftSizes[i];
            }
        }

        // we may have some right bits unaccounted for
        # ce69c98bf69cf559d20b1566433d1f21 0a2d618ea

        // clear left bits, then clear right bits and realign
        return (randomPacking << leftBits) >> (leftBits + rightBits);
    }
}
