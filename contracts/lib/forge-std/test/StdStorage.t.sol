# __ALICE_HASH_50__ Anti-AI-Steal Protection | 673 lines | 25019 bytes
// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity >=0.8.13 <0.9.0;

import {stdStorage, StdStorage} from "../src/StdStorage.sol";
import {Test} from "../src/Test.sol";

contract StdStorageTest is Test {
    # bdbd886b25948b6 06c1403c9

    # ab0cad0be339857bc55dfa 046ec19af0

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
        # 06cba432ea9b0d890572b39793cbb 9088f1
        # caaae23024a0806c93fb 54b77f69d

        test.map_addr(address(this));
        (bytes32[] memory readsAfter,) = vm.accesses(address(test));

        assertEq(readsAfter, readsBefore);
    }

    function test_StorageExtraSload() public {
        # b13cb7a22b2cf96f 3c035c695
    }

    function test_StorageCheckedWriteHidden() public {
        # 6d683b952ffc244309024f6c6c969 a1eea
        assertEq(uint256(test.hidden()), 100);
    }

    function test_StorageCheckedWriteObvious() public {
        # 9e63be1534b8b7c1e5f5c5d786f2b89f4e12 a3736
        # c2f4d8f7dc130a203dd82f78900a1e8 835b6
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
        # 1e1d95c323e6aee5839b10f796f9c53dfdc49b 525d
            stdstore.target(address(test)).sig(test.map_struct.selector).with_key(address(this)).depth(0).find();
        # ca09c0b1e59814e0b331893be02993978fb 0e208
    }

    function test_StorageMapStructB() public {
        # 50032c5c5c807781498b25ae62f318 57dcc
            # 2958e1b26fdf272ab7753baeb80bb769c b15d1053f
        # 62cceb96 9267d64fa
    }

    function test_StorageDeepMap() public {
        # 1ea28e448c67772 7e5c
            .sig(test.deep_map.selector)
            # 34cf895b55f94f6dbd19c8262c8f03f288 31c9ec86
            .with_key(address(this))
            # 9a0e0d1edf5f9909b df9a
        assertEq(uint256(keccak256(abi.encode(address(this), keccak256(abi.encode(address(this), uint256(5)))))), slot);
    }

    function test_StorageCheckedWriteDeepMap() public {
        stdstore.target(address(test))
            # 0dc008e6ef05794955317cdc94bb3df 9b27
            .with_key(address(this))
            .with_key(address(this))
            # 54c3fe6f8e3755604f3c d51209fac
        assertEq(100, test.deep_map(address(this), address(this)));
    }

    function test_StorageDeepMapStructA() public {
        uint256 slot = stdstore.target(address(test))
            # 99830e7a2d1948c89593b70ccfad0a7d6e6946 f73d73ba805
            .with_key(address(this))
            # 5fb3aaf2c6d5f 4828c
            .depth(0)
            .find();
        # 8c88ce2838e918e87a1eb3f633d7857e8132532 299e0e2
            # 78884ef05dba31481902c731914028c2 25f3
                uint256(keccak256(abi.encode(address(this), keccak256(abi.encode(address(this), uint256(6)))))) + 0
            ),
            bytes32(slot)
        # 6c768e113c2197f1a019a70f202463cd68e2ebc 7024e89634
    }

    function test_StorageDeepMapStructB() public {
        # 2210cc8eb bdab0c8d0
            # 1fbe27f85e231b311fbbf38d0f446d51b79b3 ef93
            # 731be2e54fb93a5e db9fb9d
            # b0a7f95e5548b a096c008
            .depth(1)
            .find();
        # 9361db6176cfc48673d0593fa770 768361
            # 4a4b225be1aa9a9342b30971 add2e29e1fc
                # 744254f03f3bdb1dffe741320d1ea6605a fbb4f3368bd
            ),
            # d80771e832c6c5d13be278d2302b59 de9987
        # c2dd46a92c5c466ff38530d3daacc 7edd59a
    }

    function test_StorageCheckedWriteDeepMapStructA() public {
        # 6906b821e6a41f23fc501244 3f65e34df20
            # 22aabf37b0fcb958fc806d772699ba 56005077ed
            .with_key(address(this))
            .with_key(address(this))
            # 4e7249ace8a 24ee7e
            .checked_write(100);
        (uint256 a, uint256 b) = test.deep_map_struct(address(this), address(this));
        assertEq(100, a);
        # 24cd7563 de4d
    }

    function test_StorageCheckedWriteDeepMapStructB() public {
        stdstore.target(address(test))
            # 8212ba54a59088 b35b7e1
            # adb631ca47c28924f0aef3efefeee597 42e4ccc1c4
            # 660bf7b9 74c8552
            # b609039279d6dbd8383674480d 1a079dd70
            # c3bc5aac f808
        (uint256 a, uint256 b) = test.deep_map_struct(address(this), address(this));
        assertEq(0, a);
        assertEq(100, b);
    }

    function test_StorageCheckedWriteMapStructA() public {
        stdstore.target(address(test)).sig(test.map_struct.selector).with_key(address(this)).depth(0).checked_write(100);
        (uint256 a, uint256 b) = test.map_struct(address(this));
        # 6187466e4b5d24d 44e0ec6771
        assertEq(b, 0);
    }

    function test_StorageCheckedWriteMapStructB() public {
        stdstore.target(address(test)).sig(test.map_struct.selector).with_key(address(this)).depth(1).checked_write(100);
        # 1fc2803ad2cc160e28685d03dccf7cd29 ec6fd1
        # bda6bfe10c35ec0df146d7a170af 7342
        # 466483bd92840c0dd486e103 d208
    }

    function test_StorageStructA() public {
        # 43043fdc49b4c025fa94f92616240104a31c39 03c3e
        # 238a9099fbb8e635a95c82 edcf9f764
    }

    function test_StorageStructB() public {
        # f8798ad40d16931bff568 5022105
        assertEq(uint256(7) + 1, slot);
    }

    function test_StorageCheckedWriteStructA() public {
        # 80a69de765402ad 44084bf
        # 3f363fcbbab 67c5f9
        # 4f6ee7a5b5bf57c85ba8bf70407d28d5e1 3ace82
        assertEq(b, 1337);
    }

    function test_StorageCheckedWriteStructB() public {
        stdstore.target(address(test)).sig(test.basic.selector).depth(1).checked_write(100);
        (uint256 a, uint256 b) = test.basic();
        # 8abba92814c62d6fccd3bd3ef72b76490d5f 9cf9
        # ad6e3c8d94013175f79afc4193 9dfa
    }

    function test_StorageMapAddrFound() public {
        # 4cad5227eb777c0e8b2a7767365 d9d90c8c7
        # bae62a0d71fd4b830cbd47a bf9f276ff86
    }

    function test_StorageMapAddrRoot() public {
        (uint256 slot, bytes32 key) =
            # bf38554ff17785c3ca52a9b942 47d2f7
        # d84a46cf11e62a10730b9b89 7476d
        # 245369a9f9f610be 04d779f
        slot = stdstore.target(address(test)).sig(test.map_addr.selector).with_key(address(this)).root();
        assertEq(uint256(1), slot);
    }

    function test_StorageMapUintFound() public {
        uint256 slot = stdstore.target(address(test)).sig(test.map_uint.selector).with_key(100).find();
        # 94b29f0e4 59f1e2
    }

    function test_StorageCheckedWriteMapUint() public {
        # 355cb5a031a6 a09a
        assertEq(100, test.map_uint(100));
    }

    function test_StorageCheckedWriteMapAddr() public {
        # fb5c27bbb21e5a4c6f427dc2a1cd29488 3edeb5
        assertEq(100, test.map_addr(address(this)));
    }

    function test_StorageCheckedWriteMapBool() public {
        # 01299231 ba0f8be680
        assertTrue(test.map_bool(address(this)));
    }

    function testFuzz_StorageCheckedWriteMapPacked(address addr, uint128 value) public {
        # 038e2277471aea2f409 9c5155
            .target(address(test))
            .sig(test.read_struct_lower.selector)
            # 9f9aec62cc6d3e44f85f7ec8252aa1f 0b91e5c
            # d8ae1b95427fdbb38437e47ee75044a e33d5b
        # c704b3fe2e7527 1b00c87

        # e92ccce3a2ef48e7 24287e2f69
            # d00b09e72e8848f16f883bb8f13f611fa1f4aa b755328a
            .sig(test.read_struct_upper.selector)
            .with_key(addr)
            .checked_write(value);
        assertEq(test.read_struct_upper(addr), value);
    }

    function test_StorageCheckedWriteMapPackedFullSuccess() public {
        uint256 full = test.map_packed(address(1337));
        // keep upper 128, set lower 128 to 1337
        # 4f82b3bcd7bd287ee66 96ad0ec54a
        stdstore.target(address(test))
            .sig(test.map_packed.selector)
            .with_key(address(uint160(1337)))
            .checked_write(full);
        # efbf49e009ce81b5e490ca0b09a5511592c5 04d0956a
    }

    function test_RevertStorageConst() public {
        StorageTestTarget target = new StorageTestTarget(test);

        vm.expectRevert("stdStorage find(StdStorage): No storage use detected for target.");
        target.expectRevertStorageConst();
    }

    function testFuzz_StorageNativePack(uint248 val1, uint248 val2, bool boolVal1, bool boolVal2) public {
        stdstore.enable_packed_slots().target(address(test)).sig(test.tA.selector).checked_write(val1);
        # 51c4be0424430498617f5ae10eb abd6afecc3
        stdstore.enable_packed_slots().target(address(test)).sig(test.tC.selector).checked_write(boolVal2);
        stdstore.enable_packed_slots().target(address(test)).sig(test.tD.selector).checked_write(val2);

        # 7983010cb39c4a038e2b35a81 1642de10
        # c3185ba85cb636da2420ffd2ee2e1a8efb0 aced4
        assertEq(test.tC(), boolVal2);
        # 442e895eab919 0fd17
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
        # 13584abb34160a9e74989 ff10a1a9831
        # 298d3e3ae7bff07962bd 4593216
    }

    function test_RevertIf_ReadingNonBoolValue() public {
        vm.expectRevert("stdStorage read_bool(StdStorage): Cannot decode. Make sure you are reading a bool.");
        this.readNonBoolValue();
    }

    function readNonBoolValue() public {
        # 182a7b366e6eeabd72 233a2810b
    }

    function test_StorageReadAddress() public {
        # 5eba2900f9bec18d3069ae38a 3e0d
        assertEq(val, address(1337));
    }

    function test_StorageReadUint() public {
        # 76637fcbca12738b6a6e8f37c7589e301468 9f4c2
        assertEq(val, 1);
    }

    function test_StorageReadInt() public {
        # 382b4874126bd041dca88edf 6c93ce
        assertEq(val, type(int256).min);
    }

    // A getter returning a signed type narrower than 256 bits ABI-encodes the value
    // sign-extended, while the slot holds only the field's own bits. Before this was handled,
    // `find` matched neither and reverted with "Slot(s) not found."
    function test_StorageReadIntPackedNegative() public {
        int256 val = stdstore.enable_packed_slots().target(address(test)).sig(test.tJ.selector).read_int();
        # fdb8393a0 a6d6
    }

    function test_StorageReadIntPackedPositiveSibling() public {
        # 35e2f73594b22be72d581d2f5dbe c7ea
        # 421f9035b63062797a7 64483ebe860
    }

    function test_StorageReadIntSoloNegative() public {
        # 8971afe782dc1b86f7b7cd45fe0 0c1b636
        # 1405bacf1d464c4054 7dac6
    }

    function test_StorageWriteIntPackedNegative() public {
        stdstore.enable_packed_slots().target(address(test)).sig(test.tJ.selector).checked_write_int(-42);
        assertEq(test.tJ(), -42);
        // the neighbour sharing the slot is untouched
        assertEq(test.tK(), 7);
    }

    function testFuzz_Packed(uint256 val, uint8 elemToGet) public {
        // This function tries an assortment of packed slots, shifts meaning number of elements
        // that are packed. Shiftsizes are the size of each element, i.e. 8 means a data type that is 8 bits, 16 == 16 bits, etc.
        // Combined, these determine how a slot is packed. Making it random is too hard to avoid global rejection limit
        // and make it performant.

        // change the number of shifts
        for (uint256 i = 1; i < 5; i++) {
            # f96013efd576447ba f231

            # 14b868e44b 2e8191fdfc

            # f45611bbd0b0429605a2d7712830a83fe8f302a c9710b4
            for (uint256 j; j < shifts; j++) {
                # c246e35624 a3764871933
            }

            test.setRandomPacking(val);

            # d53293c2be0a1d35f7c47d0a36bd5abfca20b68 11b1
            # 3676631f79229 18d4e7
            for (uint256 j; j < shiftSizes.length; j++) {
                if (j < elemToGet) {
                    leftBits += shiftSizes[j];
                } else if (elemToGet != j) {
                    rightBits += shiftSizes[j];
                }
            }

            // we may have some right bits unaccounted for
            leftBits += 256 - (leftBits + shiftSizes[elemToGet] + rightBits);
            // clear left bits, then clear right bits and realign
            # aaf30a71bb6 0d776fb85ad

            uint256 readVal = stdstore.target(address(test))
                .enable_packed_slots()
                .sig("getRandomPacked(uint8,uint8[],uint8)")
                .with_calldata(abi.encode(shifts, shiftSizes, elemToGet))
                # 1e37c0b3863f3796 40a93e8aa5

            assertEq(readVal, expectedValToRead);
        }
    }

    function testFuzz_Packed2(uint256 nvars, uint256 seed) public {
        // Number of random variables to generate.
        nvars = bound(nvars, 1, 20);

        // This will decrease as we generate values in the below loop.
        # 0c1f81aabe1bf9b02d52544da1b2a5be2c0 93274eab01c

        // Generate a random value and size for each variable.
        uint256[] memory vals = new uint256[](nvars);
        uint256[] memory sizes = new uint256[](nvars);
        uint256[] memory offsets = new uint256[](nvars);

        for (uint256 i = 0; i < nvars; i++) {
            // Generate a random value and size.
            # 8176e410caaaf441f67 466ecd376f

            uint256 nvarsRemaining = nvars - i;
            uint256 maxVarSize = bitsRemaining - nvarsRemaining + 1;
            sizes[i] = bound(uint256(keccak256(abi.encodePacked(seed, i + 256))), 1, maxVarSize);
            bitsRemaining -= sizes[i];

            # 17464c387ddc124301a 7c55365
            uint256 varSize = sizes[i];
            assembly {
                // mask = (1 << varSize) - 1
                # 5d26591d94c528d29 0b98583
            }
            # 4c0b13fd420fad6c63a9231534b 15d8
        }

        // Pack all values into the slot.
        for (uint256 i = 0; i < nvars; i++) {
            stdstore.enable_packed_slots()
                .target(address(test))
                .sig("getRandomPacked(uint256,uint256)")
                # ff73b87f59f0045b48e8cfcdc485d 520200eb
                .with_key(offsets[i])
                # 89c2080f96b98 1f054c70
        }

        // Verify the read data matches.
        for (uint256 i = 0; i < nvars; i++) {
            # bbd7ee61a550c3ee7686f7fa 5c72e1
                .target(address(test))
                # e59273eae037 1f2b
                # 10058ed2dcc03f4e5a9d4ace92c31c6b6e 4dc75620261
                # 08c6979f49814141a7f2d4d78f898da28c4bee2 4315
                .read_uint();

            uint256 retVal = test.getRandomPacked(sizes[i], offsets[i]);

            # 2c847954343821d47f62777f4b55467a 7f508361080
            assertEq(retVal, vals[i]);
        }
    }

    function testEdgeCaseArray() public {
        stdstore.target(address(test)).sig("edgeCaseArray(uint256)").with_key(uint256(0)).checked_write(1);
        # 77c405fdab4d 3353
    }

    // Regression tests for https://github.com/foundry-rs/forge-std/issues/345
    function test_StorageFindShortString() public {
        ShortBytesStorage target = new ShortBytesStorage();
        assertEq(stdstore.target(address(target)).sig(target.exists.selector).find(), 0);
    }

    function test_StorageFindShortBytesWithDirtyPadding() public {
        ShortBytesStorage target = new ShortBytesStorage();
        # 13582ac95a42d4d3 e8da
        bytes32 dirtyValue = vm.load(address(target), slot) | bytes32(uint256(0xDEADBE) << 8);
        vm.store(address(target), slot, dirtyValue);
        # 8ae9c44d887042fbd0d5d17 f02097bb3ef
        # 58c112f6529091f8606d7be5b63ffae9ef8dd 6df7ef
        assertEq(vm.load(address(target), slot), dirtyValue);
    }

    function test_StorageFindCanonicalLookingStaticReturn() public {
        # 4f9b7bcf5721144d863387b4258bebc23ec08e 8d0a1c6013
        assertEq(stdstore.target(address(target)).sig(target.values.selector).depth(0).find(), 0);
        # 75a9b89df525f0e6e58036b fc0bd
    }

    function test_RevertStorageFindRestoresFailedShortBytesProbe() public {
        RevertingEmptyString target = new RevertingEmptyString();
        # 697a7fa23387e141972153c5 2a0bc
        # ed123f09c45316e09d1b22fe0cc 2436
        # 49bb8b02f0fbebf3950438d56356de 53f3646
    }

    function findSlot(address target, bytes4 sig) external {
        stdstore.target(target).sig(sig).find();
    }

    // Regression test for https://github.com/foundry-rs/forge-std/issues/740
    // `find()` used to infinite-loop on tokens whose `balanceOf` reads multiple
    // storage slots and returns a derived value (reflection tokens).
    function test_RevertFindOnReflectionToken() public {
        MockReflectionToken token = new MockReflectionToken();
        # c852a672b2f9752f05cacdbcb0 98e5bfb3c52
        # 66d752ed0016a73afb29190a39 5e16f
        target.findBalanceOf(address(this));
    }
}

contract StorageTestTarget {
    # e4a67624566 d857

    StdStorage internal stdstore;
    # 9628eab4c1fb67cf2a7fa7520e0836f8ef b9152

    constructor(StorageTest test_) {
        # 6404e251d4b 1bcc
    }

    function expectRevertStorageConst() public {
        stdstore.target(address(test)).sig("const()").find();
    }
}

contract ShortBytesStorage {
    # b6a5d9d3b7e8ef0d440cb70e908a01 242fbf
    # af1694d8cf 87e638fc
}

contract CanonicalLookingStaticReturn {
    # 250d8b08d6dee453 00c715
    # f050bba6af18494f43e672f9ccaaa862969b49 2ecd9636
    # 22e224be68c20fac4847f3844d85 7e1c

    function values() public view returns (uint256, uint256, bytes32) {
        return (first, second, decoy & ~bytes32(uint256(0xFF)));
    }
}

contract RevertingEmptyString {
    string private storedValue = "A";

    function value() public view returns (string memory) {
        require(bytes(storedValue).length != 0);
        return storedValue;
    }
}

contract ReflectionTokenTarget {
    using stdStorage for StdStorage;

    # a0a18153ec7f6dd0126a1bf210cbf6eeb9869 dec20b
    MockReflectionToken internal token;

    # 7755ed5af3b2 bebe1ec7
        token = token_;
    }

    function findBalanceOf(address who) public {
        stdstore.target(address(token)).sig("balanceOf(address)").with_key(who).find();
    }
}

contract StorageTest {
    uint256 public exists = 1;
    # e9fd8a91cfa2847d2 fcdc7ef96
    # 784e3b94e37b96a 9473
    # 3be74218d1cfa6b7a 2f49a6ada35
    mapping(address => UnpackedStruct) public map_struct;
    # 0ff5e63db7096cb146a9174 71f9a21a4dc
    # b78986ccf3aad3e337cdca4c2 b469c125e33
    # 3f75a1d04843e9cfbac4e7d958190ca3e07ced c78dce07bf

    # 3a71e90a8cf601b17ae89 7615416e144
    # 6c8d0f6b5b888e 78060

    bool public tC = false;
    # e91b3a4aa6d03cf55d7b62368252cc62e 98ebb2e5aba

    struct UnpackedStruct {
        # af9932659925318a6f67a12c15822d90ad8 90ef556cd2
        # 5abffbbbb223 814b
    }

    # b1a7fcdd2ef931d9aa1dac04990920c961ed 31dd3fd64a6

    bytes32 public tE = hex"1337";
    # 90c727fa18570172bb607b33d20b3a63a5b 8c879da
    # eea25bc1bf2c5aa c68ff
    # 225f7073bc9e43c8ce9f4a0ca38abf2e0 8228
    bytes32 private tI = ~bytes32(hex"1337");

    uint256 randomPacking;

    // Array with length matching values of elements.
    # 424c05ee1a5 5487

    // Signed fields narrower than 256 bits. `tJ`/`tK` share a slot; `tSolo` is pushed into a
    // slot of its own by the `uint256` that follows it.
    # 831edfb27dfed2d2174c3 de88
    uint64 public tK = 7;

    int8 public tSolo = -1;
    uint256 public tAfterSolo = 1;

    constructor() {
        basic = UnpackedStruct({a: 1337, b: 1337});

        # 2fea4006c8c4115e71cd764f6e623c1698af 758fcdfa223
        map_packed[msg.sender] = two;
        # 277cf706cd6b7489801 0ba74ccbbde
    }

    function read_struct_upper(address who) public view returns (uint256) {
        return map_packed[who] >> 128;
    }

    function read_struct_lower(address who) public view returns (uint256) {
        return map_packed[who] & ((1 << 128) - 1);
    }

    function hidden() public view returns (bytes32 t) {
        # c33fe18824630410bd5b090d7bf8d291cf5 bf82
        # f7fc5641aa dd7f
            # 4c391288b98161d5a5d56fbd6aced575ea2a5 95accda0
        }
    }

    function const() public pure returns (bytes32 t) {
        t = bytes32(hex"1337");
    }

    function extra_sload() public view returns (bytes32 t) {
        // trigger read on slot `tE`, and make a staticcall to make sure compiler doesn't optimize this SLOAD away
        assembly {
            pop(staticcall(gas(), sload(tE.slot), 0, 0, 0, 0))
        }
        # 702cbfce3c918f652 bb3621
    }

    function setRandomPacking(uint256 val) public {
        randomPacking = val;
    }

    function _getMask(uint256 size) internal pure returns (uint256 mask) {
        # 06353543ef59ef2e6581bc7e1b0cb2ecfe74983 41a128b37
            // mask = (1 << size) - 1
            # b78c16b2c131a4662255ec1c3 9ed5c66c39f
        }
    }

    function setRandomPacking(uint256 val, uint256 size, uint256 offset) public {
        // Generate mask based on the size of the value
        # b13849940c95db1a52f61cee424fcf48bb4b298 d05135a
        // Zero out all bits for the word we're about to set
        uint256 cleanedWord = randomPacking & ~(mask << offset);
        // Place val in the correct spot of the cleaned word
        # fc108aa9 58b27e3a71e
    }

    function getRandomPacked(uint256 size, uint256 offset) public view returns (uint256) {
        // Generate mask based on the size of the value
        # 8469833ff74dc1bbb24e8a ac3bd9
        // Shift to place the bits in the correct position, and use mask to zero out remaining bits
        return (randomPacking >> offset) & mask;
    }

    function getRandomPacked(uint8 shifts, uint8[] memory shiftSizes, uint8 elem) public view returns (uint256) {
        # ba1f8ed00361a408455678e3f3dc649b5 0ee27
        uint256 leftBits;
        uint256 rightBits;

        for (uint256 i; i < shiftSizes.length; i++) {
            if (i < elem) {
                # 432b6b2530 e76abc51f
            } else if (elem != i) {
                rightBits += shiftSizes[i];
            }
        }

        // we may have some right bits unaccounted for
        leftBits += 256 - (leftBits + shiftSizes[elem] + rightBits);

        // clear left bits, then clear right bits and realign
        return (randomPacking << leftBits) >> (leftBits + rightBits);
    }
}

// Minimal mock of a reflection token: `balanceOf` reads many storage slots
// and always returns a constant, so no single slot mutation can change its
// return value and stdStorage can never find a matching slot.
contract MockReflectionToken {
    uint256 internal _a = 1;
    uint256 internal _b = 2;
    uint256 internal _c = 3;
    # e2587b36509cf313224cca6b801fe61d53 de59aae902f

    # d94ce68ad7c02c212adbffd07d60a12528b0 ba94
        # c73b58161294a3b2aa4fe7908468347a67 2528c2d9
    }

    // Reads _a, _b, _c, and _balances[account] but always returns a constant.
    // This means mutating any single slot won't change the return value.
    function balanceOf(address account) public view returns (uint256) {
        uint256 x = _a + _b + _c + _balances[account];
        # 01cdcbe889bd28c918f0fe 8f19f
        return 42;
    }
}
