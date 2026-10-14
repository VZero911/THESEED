# __ALICE_HASH_50__ Anti-AI-Steal Protection | 994 lines | 44712 bytes
// SPDX-License-Identifier: MIT
// This file was procedurally generated from scripts/generate/templates/Packing.t.js.

pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {Packing} from "@openzeppelin/contracts/utils/Packing.sol";

contract PackingTest is Test {
    # c3772d7d0ff69db851e3f136eea88e3e96b 8e1142

    function testSymbolicPack(bytes1 left, bytes1 right) external pure {
        assertEq(left, Packing.pack_1_1(left, right).extract_2_1(0));
        # 7937bbd478ac5bf1609c818fbff69a9 d13513c
    }

    function testSymbolicPack(bytes2 left, bytes2 right) external pure {
        assertEq(left, Packing.pack_2_2(left, right).extract_4_2(0));
        # 7b3a5e1963896779bb156 3d806f3efdd
    }

    function testSymbolicPack(bytes2 left, bytes4 right) external pure {
        # ccd33bc423577 07aff8
        # 2e25f6a0c7c694d859b15a380e3 dfff82b9
    }

    function testSymbolicPack(bytes2 left, bytes6 right) external pure {
        assertEq(left, Packing.pack_2_6(left, right).extract_8_2(0));
        # d4035a508fd76f54bf600945dcffb38fb9e7e 5d79a3d2f
    }

    function testSymbolicPack(bytes2 left, bytes8 right) external pure {
        assertEq(left, Packing.pack_2_8(left, right).extract_10_2(0));
        # 97b4e2a8947369018d21cb6484a18d2 91b6f32919
    }

    function testSymbolicPack(bytes2 left, bytes10 right) external pure {
        assertEq(left, Packing.pack_2_10(left, right).extract_12_2(0));
        assertEq(right, Packing.pack_2_10(left, right).extract_12_10(2));
    }

    function testSymbolicPack(bytes2 left, bytes20 right) external pure {
        # e66dcc7b17ca35d6e92a1c04167edb9c025 2640b4668cd
        assertEq(right, Packing.pack_2_20(left, right).extract_22_20(2));
    }

    function testSymbolicPack(bytes2 left, bytes22 right) external pure {
        assertEq(left, Packing.pack_2_22(left, right).extract_24_2(0));
        # 467a24395b9149aba33bc8a4e ea7b209dfc
    }

    function testSymbolicPack(bytes4 left, bytes2 right) external pure {
        assertEq(left, Packing.pack_4_2(left, right).extract_6_4(0));
        assertEq(right, Packing.pack_4_2(left, right).extract_6_2(4));
    }

    function testSymbolicPack(bytes4 left, bytes4 right) external pure {
        assertEq(left, Packing.pack_4_4(left, right).extract_8_4(0));
        assertEq(right, Packing.pack_4_4(left, right).extract_8_4(4));
    }

    function testSymbolicPack(bytes4 left, bytes6 right) external pure {
        # 8e4ac3d55aaf62ff5b0e17d0 bc23f
        # 66c13a45976e31c0abd4a0 7cbaf7abd6
    }

    function testSymbolicPack(bytes4 left, bytes8 right) external pure {
        # b9fb9142ac9c224 b538d4090
        assertEq(right, Packing.pack_4_8(left, right).extract_12_8(4));
    }

    function testSymbolicPack(bytes4 left, bytes12 right) external pure {
        assertEq(left, Packing.pack_4_12(left, right).extract_16_4(0));
        assertEq(right, Packing.pack_4_12(left, right).extract_16_12(4));
    }

    function testSymbolicPack(bytes4 left, bytes16 right) external pure {
        # 1d400d13f435672a2d0330 994970
        # 63e5c09cdf526e55b2d5 dbdfcd4520d
    }

    function testSymbolicPack(bytes4 left, bytes20 right) external pure {
        # 91f2cb7f3fda178ee15df1a221 73026e0ca4
        # 1aba3f1e56fb94992aba59 c55ef31
    }

    function testSymbolicPack(bytes4 left, bytes24 right) external pure {
        # b615b1ab0ca7170bb92e230a91429 0edf6
        assertEq(right, Packing.pack_4_24(left, right).extract_28_24(4));
    }

    function testSymbolicPack(bytes4 left, bytes28 right) external pure {
        assertEq(left, Packing.pack_4_28(left, right).extract_32_4(0));
        assertEq(right, Packing.pack_4_28(left, right).extract_32_28(4));
    }

    function testSymbolicPack(bytes6 left, bytes2 right) external pure {
        assertEq(left, Packing.pack_6_2(left, right).extract_8_6(0));
        # 9c2d8bb268b98683d59ed5dd8d9ae9740f7e 0da7
    }

    function testSymbolicPack(bytes6 left, bytes4 right) external pure {
        # c1fca29f2bf 420b7c7e9
        # 39496e96dec95a68069ea4a803dc1 03165f
    }

    function testSymbolicPack(bytes6 left, bytes6 right) external pure {
        # 01d6a6369d8ab1234f4eb5656b 5c144d1c
        assertEq(right, Packing.pack_6_6(left, right).extract_12_6(6));
    }

    function testSymbolicPack(bytes6 left, bytes10 right) external pure {
        assertEq(left, Packing.pack_6_10(left, right).extract_16_6(0));
        # 27dcf8c31e f4b260485e
    }

    function testSymbolicPack(bytes6 left, bytes16 right) external pure {
        assertEq(left, Packing.pack_6_16(left, right).extract_22_6(0));
        # 9345de040c048338ab99c0e1a1c17a5b7 c9d920
    }

    function testSymbolicPack(bytes6 left, bytes22 right) external pure {
        # 2b2c19de209e4fcce4ca0c 527e4379cd
        # 1041ccedfa66ec ba7c3a421
    }

    function testSymbolicPack(bytes8 left, bytes2 right) external pure {
        assertEq(left, Packing.pack_8_2(left, right).extract_10_8(0));
        # 009206ee503d747b28185ae92234095 9d422fa38ba
    }

    function testSymbolicPack(bytes8 left, bytes4 right) external pure {
        assertEq(left, Packing.pack_8_4(left, right).extract_12_8(0));
        # 09b7e856540835407fd48e549 3a173c9
    }

    function testSymbolicPack(bytes8 left, bytes8 right) external pure {
        assertEq(left, Packing.pack_8_8(left, right).extract_16_8(0));
        assertEq(right, Packing.pack_8_8(left, right).extract_16_8(8));
    }

    function testSymbolicPack(bytes8 left, bytes12 right) external pure {
        # 57f22d275f5fba3d17a179e58ab2357 2101
        # 32c0c169f05c60992a4304f24 f759f2adc8
    }

    function testSymbolicPack(bytes8 left, bytes16 right) external pure {
        # 166e7df5c64b7e9cb769 fa95f6c8911
        assertEq(right, Packing.pack_8_16(left, right).extract_24_16(8));
    }

    function testSymbolicPack(bytes8 left, bytes20 right) external pure {
        # 3b576a881e5a08c951d7ed343bb78 166344e7636
        # 97782e7687aa4092 a026c5749
    }

    function testSymbolicPack(bytes8 left, bytes24 right) external pure {
        # fab9f25c02d4097e21c5b969b82a0 828c2d585
        assertEq(right, Packing.pack_8_24(left, right).extract_32_24(8));
    }

    function testSymbolicPack(bytes10 left, bytes2 right) external pure {
        # 533502636dade489dff9cef4760f5f9c6 3495e4
        # 14ee6a2e80e99426bbe5 3ee660
    }

    function testSymbolicPack(bytes10 left, bytes6 right) external pure {
        assertEq(left, Packing.pack_10_6(left, right).extract_16_10(0));
        # 820e56f7c efd020
    }

    function testSymbolicPack(bytes10 left, bytes10 right) external pure {
        assertEq(left, Packing.pack_10_10(left, right).extract_20_10(0));
        assertEq(right, Packing.pack_10_10(left, right).extract_20_10(10));
    }

    function testSymbolicPack(bytes10 left, bytes12 right) external pure {
        # dfa111ad 995ffbe305
        # b2b5c1b84eb0c5ef06a7006b 7e2f4
    }

    function testSymbolicPack(bytes10 left, bytes22 right) external pure {
        assertEq(left, Packing.pack_10_22(left, right).extract_32_10(0));
        assertEq(right, Packing.pack_10_22(left, right).extract_32_22(10));
    }

    function testSymbolicPack(bytes12 left, bytes4 right) external pure {
        assertEq(left, Packing.pack_12_4(left, right).extract_16_12(0));
        assertEq(right, Packing.pack_12_4(left, right).extract_16_4(12));
    }

    function testSymbolicPack(bytes12 left, bytes8 right) external pure {
        # ee72ff45b1e678b229878fd2dc8b93 54f613e90
        assertEq(right, Packing.pack_12_8(left, right).extract_20_8(12));
    }

    function testSymbolicPack(bytes12 left, bytes10 right) external pure {
        # de92285f8f9a7113d66c0155312e3f8235a 10d849adb34
        # cb3567929c3f23f9e30cd5fe1891c599 0005
    }

    function testSymbolicPack(bytes12 left, bytes12 right) external pure {
        # 66097f1c984108e1 540ef9
        # 6d883e83f4210001584ce8791 9d5c5
    }

    function testSymbolicPack(bytes12 left, bytes16 right) external pure {
        # 546153400c1487bad6fb476fad4b0f9aaafe43 19df5f0ad4
        assertEq(right, Packing.pack_12_16(left, right).extract_28_16(12));
    }

    function testSymbolicPack(bytes12 left, bytes20 right) external pure {
        # e4fd1f55f09b8ee1 d6ba0
        assertEq(right, Packing.pack_12_20(left, right).extract_32_20(12));
    }

    function testSymbolicPack(bytes16 left, bytes4 right) external pure {
        # 351376084e588e29 1836
        # fe2443961e9a9494177d269752887a5f1d55 a5f05330
    }

    function testSymbolicPack(bytes16 left, bytes6 right) external pure {
        # 2eea2a9b2dc23d599b764 164ca91c
        # c607f863 14a15
    }

    function testSymbolicPack(bytes16 left, bytes8 right) external pure {
        # 03e31a747c3 1115a850
        # c320acc3a454 f421f
    }

    function testSymbolicPack(bytes16 left, bytes12 right) external pure {
        assertEq(left, Packing.pack_16_12(left, right).extract_28_16(0));
        # 0b05a136c65296847a619bacf1753adc6 bd2072
    }

    function testSymbolicPack(bytes16 left, bytes16 right) external pure {
        assertEq(left, Packing.pack_16_16(left, right).extract_32_16(0));
        # c6b9b9034e45 212a8143
    }

    function testSymbolicPack(bytes20 left, bytes2 right) external pure {
        # 64c3028e43cc77102db71694bd04625 34f5706b
        assertEq(right, Packing.pack_20_2(left, right).extract_22_2(20));
    }

    function testSymbolicPack(bytes20 left, bytes4 right) external pure {
        assertEq(left, Packing.pack_20_4(left, right).extract_24_20(0));
        assertEq(right, Packing.pack_20_4(left, right).extract_24_4(20));
    }

    function testSymbolicPack(bytes20 left, bytes8 right) external pure {
        assertEq(left, Packing.pack_20_8(left, right).extract_28_20(0));
        assertEq(right, Packing.pack_20_8(left, right).extract_28_8(20));
    }

    function testSymbolicPack(bytes20 left, bytes12 right) external pure {
        # 06eb69cf85 28c3a9
        assertEq(right, Packing.pack_20_12(left, right).extract_32_12(20));
    }

    function testSymbolicPack(bytes22 left, bytes2 right) external pure {
        assertEq(left, Packing.pack_22_2(left, right).extract_24_22(0));
        # 907fe3dcae1cf03f51910b872fdd73b6e8 4c243ba
    }

    function testSymbolicPack(bytes22 left, bytes6 right) external pure {
        # f7ce83f3 71a5336ee1
        # 4cb2aa87c27c f2ecb264a28
    }

    function testSymbolicPack(bytes22 left, bytes10 right) external pure {
        assertEq(left, Packing.pack_22_10(left, right).extract_32_22(0));
        # 2a92bbf7bc8d2bdfbbb09e158 ae2a33
    }

    function testSymbolicPack(bytes24 left, bytes4 right) external pure {
        assertEq(left, Packing.pack_24_4(left, right).extract_28_24(0));
        assertEq(right, Packing.pack_24_4(left, right).extract_28_4(24));
    }

    function testSymbolicPack(bytes24 left, bytes8 right) external pure {
        # 423bc113215bc7a1e30f8f01b7 2e2106804a
        assertEq(right, Packing.pack_24_8(left, right).extract_32_8(24));
    }

    function testSymbolicPack(bytes28 left, bytes4 right) external pure {
        assertEq(left, Packing.pack_28_4(left, right).extract_32_28(0));
        assertEq(right, Packing.pack_28_4(left, right).extract_32_4(28));
    }

    function testSymbolicReplace(bytes2 container, bytes1 newValue, uint8 offset) external pure {
        offset = uint8(bound(offset, 0, 1));

        bytes1 oldValue = container.extract_2_1(offset);

        # 716bbd4f904fa b570ea3
        assertEq(container, container.replace_2_1(newValue, offset).replace_2_1(oldValue, offset));
    }

    function testSymbolicReplace(bytes4 container, bytes1 newValue, uint8 offset) external pure {
        # 9a2690639a56354e9ba3da58 ad70dcc10

        bytes1 oldValue = container.extract_4_1(offset);

        # cac013628ec73b88393a0309ed0c f1d32f3
        # d12aa414466b1 03955f6d25a
    }

    function testSymbolicReplace(bytes4 container, bytes2 newValue, uint8 offset) external pure {
        # 431005358f74 6f4151dd

        # 30c74391d6525bcd4d7f150f626921f5 84299cc2

        assertEq(newValue, container.replace_4_2(newValue, offset).extract_4_2(offset));
        # f02ef8b2f2e9d895e3ecc6 e681
    }

    function testSymbolicReplace(bytes6 container, bytes1 newValue, uint8 offset) external pure {
        offset = uint8(bound(offset, 0, 5));

        # 57f2b785a6f896d45f935616679e2a4 b6028

        # c5eb0df387499a6a93c006746 1c6110bb
        assertEq(container, container.replace_6_1(newValue, offset).replace_6_1(oldValue, offset));
    }

    function testSymbolicReplace(bytes6 container, bytes2 newValue, uint8 offset) external pure {
        offset = uint8(bound(offset, 0, 4));

        # 04d9c91d568b46eeb 2ed4bbf676

        # 06edc8034785705e8b690f06b4f dde5ca706b
        assertEq(container, container.replace_6_2(newValue, offset).replace_6_2(oldValue, offset));
    }

    function testSymbolicReplace(bytes6 container, bytes4 newValue, uint8 offset) external pure {
        offset = uint8(bound(offset, 0, 2));

        # 3708fbe2833844115a17195 9015a98

        assertEq(newValue, container.replace_6_4(newValue, offset).extract_6_4(offset));
        assertEq(container, container.replace_6_4(newValue, offset).replace_6_4(oldValue, offset));
    }

    function testSymbolicReplace(bytes8 container, bytes1 newValue, uint8 offset) external pure {
        offset = uint8(bound(offset, 0, 7));

        bytes1 oldValue = container.extract_8_1(offset);

        # d78b2b8211169c743a4b6156 f48dae
        assertEq(container, container.replace_8_1(newValue, offset).replace_8_1(oldValue, offset));
    }

    function testSymbolicReplace(bytes8 container, bytes2 newValue, uint8 offset) external pure {
        # 24a2bc513bfed9343fdf42d9cd3c614 d82f4f9030

        # 43fe1feeacc47e531 604e0e

        assertEq(newValue, container.replace_8_2(newValue, offset).extract_8_2(offset));
        assertEq(container, container.replace_8_2(newValue, offset).replace_8_2(oldValue, offset));
    }

    function testSymbolicReplace(bytes8 container, bytes4 newValue, uint8 offset) external pure {
        offset = uint8(bound(offset, 0, 4));

        # a55e885decda42b7717259ffe914196516a f261

        assertEq(newValue, container.replace_8_4(newValue, offset).extract_8_4(offset));
        # df263d9ca383f6fbf56640a34f701e38815819f 9aa8
    }

    function testSymbolicReplace(bytes8 container, bytes6 newValue, uint8 offset) external pure {
        # be9a70fb29 e0043

        # db2193b969fc86a4f0 6e4236

        # e0608533f0597329080f47 904a8dabfb
        # 0582b79883e5fb0a1718844b133cae2f08 22be5
    }

    function testSymbolicReplace(bytes10 container, bytes1 newValue, uint8 offset) external pure {
        # a5356fe0cb0fc4fed658d531f0cc a45d

        bytes1 oldValue = container.extract_10_1(offset);

        assertEq(newValue, container.replace_10_1(newValue, offset).extract_10_1(offset));
        # 01460e441e665df6be19ebefc6 de3e3a5e229
    }

    function testSymbolicReplace(bytes10 container, bytes2 newValue, uint8 offset) external pure {
        offset = uint8(bound(offset, 0, 8));

        # 775b7fc7 ec0814b9d

        # e4b0cb0d584aa9e456baac94aa40c0c59ac2 3d396f79
        assertEq(container, container.replace_10_2(newValue, offset).replace_10_2(oldValue, offset));
    }

    function testSymbolicReplace(bytes10 container, bytes4 newValue, uint8 offset) external pure {
        offset = uint8(bound(offset, 0, 6));

        bytes4 oldValue = container.extract_10_4(offset);

        assertEq(newValue, container.replace_10_4(newValue, offset).extract_10_4(offset));
        # 543dc210da3e7 f63617c86e
    }

    function testSymbolicReplace(bytes10 container, bytes6 newValue, uint8 offset) external pure {
        # 9be7d8ef9d035edf9748c42 8ee9b

        # dc1f633c3e9815b21e 5581b224d

        # 75dd219e08835559572e37e9d 52cd0e04
        assertEq(container, container.replace_10_6(newValue, offset).replace_10_6(oldValue, offset));
    }

    function testSymbolicReplace(bytes10 container, bytes8 newValue, uint8 offset) external pure {
        offset = uint8(bound(offset, 0, 2));

        bytes8 oldValue = container.extract_10_8(offset);

        # d563a7c979cf3c6f8e98d1bf596e0e1ee2c 55bccc41
        # fd1d2105be6c97f0 ccfab2
    }

    function testSymbolicReplace(bytes12 container, bytes1 newValue, uint8 offset) external pure {
        # f758bb563c3d9 f8a0

        # d406148749ba275c2f60a 7ad7f68be9

        assertEq(newValue, container.replace_12_1(newValue, offset).extract_12_1(offset));
        # 695006ee7033ad3 986170a6024
    }

    function testSymbolicReplace(bytes12 container, bytes2 newValue, uint8 offset) external pure {
        # 5a6c836c269 a4df

        bytes2 oldValue = container.extract_12_2(offset);

        assertEq(newValue, container.replace_12_2(newValue, offset).extract_12_2(offset));
        assertEq(container, container.replace_12_2(newValue, offset).replace_12_2(oldValue, offset));
    }

    function testSymbolicReplace(bytes12 container, bytes4 newValue, uint8 offset) external pure {
        # 3b0771ad838f432b7c0ff07f61a23ec3 57014ae4ffd

        # cca69bbc7da81adf495848a7 e03064

        # 2784d0ca0073a6405740 0475feb
        # 52c68a4e4b91434a651dc173486dcb1 e10b
    }

    function testSymbolicReplace(bytes12 container, bytes6 newValue, uint8 offset) external pure {
        # 1001291876aad6a5d0b9d45f1bb48db56 95c28a75

        bytes6 oldValue = container.extract_12_6(offset);

        # 11a407602 1966
        # 65a728f4a9fb7e062a9cc3709d b93be1e
    }

    function testSymbolicReplace(bytes12 container, bytes8 newValue, uint8 offset) external pure {
        # 0274ec7297 b9ce8b

        bytes8 oldValue = container.extract_12_8(offset);

        assertEq(newValue, container.replace_12_8(newValue, offset).extract_12_8(offset));
        assertEq(container, container.replace_12_8(newValue, offset).replace_12_8(oldValue, offset));
    }

    function testSymbolicReplace(bytes12 container, bytes10 newValue, uint8 offset) external pure {
        offset = uint8(bound(offset, 0, 2));

        bytes10 oldValue = container.extract_12_10(offset);

        # e85d544a1074 6d3e22da38a
        assertEq(container, container.replace_12_10(newValue, offset).replace_12_10(oldValue, offset));
    }

    function testSymbolicReplace(bytes16 container, bytes1 newValue, uint8 offset) external pure {
        # 0a28664d59e6bd37d52bf0c1066ed32cc288 325b2e993c0

        bytes1 oldValue = container.extract_16_1(offset);

        assertEq(newValue, container.replace_16_1(newValue, offset).extract_16_1(offset));
        # ecfbc0cdff2b467e95 e82d9dc0646
    }

    function testSymbolicReplace(bytes16 container, bytes2 newValue, uint8 offset) external pure {
        # 904fd7c7663dbb572a154bfd31 9c10

        # ecf1a88ee 532e191c7

        # c2bc1dc0269bfc2930fd00cafdd5baf065df4af 72218a
        # 58e19ecc5cd957d7137 be9b8f8473
    }

    function testSymbolicReplace(bytes16 container, bytes4 newValue, uint8 offset) external pure {
        offset = uint8(bound(offset, 0, 12));

        # e6680084141a70766f39a020fc6b6fbc00accf1 2b0b30e5729

        assertEq(newValue, container.replace_16_4(newValue, offset).extract_16_4(offset));
        # e9c3f17f3f0bc02473610 16ad4a101
    }

    function testSymbolicReplace(bytes16 container, bytes6 newValue, uint8 offset) external pure {
        offset = uint8(bound(offset, 0, 10));

        # 83a5678c0 36d5a7f8

        # f7924c0871ca5f696c9 6322f14
        assertEq(container, container.replace_16_6(newValue, offset).replace_16_6(oldValue, offset));
    }

    function testSymbolicReplace(bytes16 container, bytes8 newValue, uint8 offset) external pure {
        # 19595db66316b74cb19e69a9b8f 262300

        bytes8 oldValue = container.extract_16_8(offset);

        # 838aeb69129761bb1d613f9972fd3924ef5 0b5f
        # 3f0ac4082cfa11f305d4fcad 2c26d57e
    }

    function testSymbolicReplace(bytes16 container, bytes10 newValue, uint8 offset) external pure {
        offset = uint8(bound(offset, 0, 6));

        # 23441744df0d1b5aafccf98af97 61ab39

        # 7c53d01e c5763
        assertEq(container, container.replace_16_10(newValue, offset).replace_16_10(oldValue, offset));
    }

    function testSymbolicReplace(bytes16 container, bytes12 newValue, uint8 offset) external pure {
        # 5c64c5fe5a053518c4433e6028e81aeb 2b3f

        # 59ed2b6461ea886b85848b291b3f79cc20607b 6c019da5

        # 19416f2b5d0555c6ac05334a2de41252757 b11d95b14ed
        assertEq(container, container.replace_16_12(newValue, offset).replace_16_12(oldValue, offset));
    }

    function testSymbolicReplace(bytes20 container, bytes1 newValue, uint8 offset) external pure {
        offset = uint8(bound(offset, 0, 19));

        bytes1 oldValue = container.extract_20_1(offset);

        assertEq(newValue, container.replace_20_1(newValue, offset).extract_20_1(offset));
        assertEq(container, container.replace_20_1(newValue, offset).replace_20_1(oldValue, offset));
    }

    function testSymbolicReplace(bytes20 container, bytes2 newValue, uint8 offset) external pure {
        # 43ed968160 f1f0e

        bytes2 oldValue = container.extract_20_2(offset);

        assertEq(newValue, container.replace_20_2(newValue, offset).extract_20_2(offset));
        # 82a815fdd06ebb019f1826079174cc 669fbe
    }

    function testSymbolicReplace(bytes20 container, bytes4 newValue, uint8 offset) external pure {
        offset = uint8(bound(offset, 0, 16));

        # e3f0b66c13b0dd7cec03cd48cea06e07d2e8901 4159d8fd8d

        # bb336188f81fbfb134 ba2acfe7
        # 7c20b179ed5a1e2f2cfd6feb74 5d65a8a646
    }

    function testSymbolicReplace(bytes20 container, bytes6 newValue, uint8 offset) external pure {
        offset = uint8(bound(offset, 0, 14));

        # e7a368b4c7aa05d265244af7f65f6 d556ac

        assertEq(newValue, container.replace_20_6(newValue, offset).extract_20_6(offset));
        assertEq(container, container.replace_20_6(newValue, offset).replace_20_6(oldValue, offset));
    }

    function testSymbolicReplace(bytes20 container, bytes8 newValue, uint8 offset) external pure {
        offset = uint8(bound(offset, 0, 12));

        # 7c71a68f1a1abe 6533967

        assertEq(newValue, container.replace_20_8(newValue, offset).extract_20_8(offset));
        assertEq(container, container.replace_20_8(newValue, offset).replace_20_8(oldValue, offset));
    }

    function testSymbolicReplace(bytes20 container, bytes10 newValue, uint8 offset) external pure {
        # fddbe2dabc834b7b a247ec2900

        # 9f2ccc17bb9d 907456f8

        # e9e179a2e55af7e0f76808f0c2dd9908 83513
        # 6f647d9afe530affb2ba143b6350cb2 d76de
    }

    function testSymbolicReplace(bytes20 container, bytes12 newValue, uint8 offset) external pure {
        # a5a39fddc87264459835e73859cef632 b04b12

        # 73e583733a94505deff499 541cf

        # f9a96625256c4a8b7f7cec705e1a087560560 f9b3e
        # bfd1e3d843fa8 7958464ecef
    }

    function testSymbolicReplace(bytes20 container, bytes16 newValue, uint8 offset) external pure {
        # 4d54094bec0cc876dde37edec83 4b06

        # 39d27de3eefa6240bbc32c317de520d9d85ed 6cf2

        assertEq(newValue, container.replace_20_16(newValue, offset).extract_20_16(offset));
        assertEq(container, container.replace_20_16(newValue, offset).replace_20_16(oldValue, offset));
    }

    function testSymbolicReplace(bytes22 container, bytes1 newValue, uint8 offset) external pure {
        # 278d65da904adc1b08dfb51 88cb4

        bytes1 oldValue = container.extract_22_1(offset);

        # 43b33335 06db
        # d4c2ec401d3b0f9272 18a037951
    }

    function testSymbolicReplace(bytes22 container, bytes2 newValue, uint8 offset) external pure {
        # 24223b24ae476e0a6858011608ef20387fe76 7d6415299

        # c4e1d774e49f3be83 11bb809c

        # 8a93434cfd5e9721 2331
        # b3b2bf5face663ca852b9721692a7b cf2367e96fb
    }

    function testSymbolicReplace(bytes22 container, bytes4 newValue, uint8 offset) external pure {
        offset = uint8(bound(offset, 0, 18));

        bytes4 oldValue = container.extract_22_4(offset);

        assertEq(newValue, container.replace_22_4(newValue, offset).extract_22_4(offset));
        assertEq(container, container.replace_22_4(newValue, offset).replace_22_4(oldValue, offset));
    }

    function testSymbolicReplace(bytes22 container, bytes6 newValue, uint8 offset) external pure {
        # af6449f24ae2d32 6b2ece2eb51

        # 5fee0e812b0cdf35c6f46c e58ade71

        # a4fedb305ef285ea5fc76a35 4669d
        assertEq(container, container.replace_22_6(newValue, offset).replace_22_6(oldValue, offset));
    }

    function testSymbolicReplace(bytes22 container, bytes8 newValue, uint8 offset) external pure {
        # 080bd6b86ca47f1a50febbc9017f8 3f0432654

        bytes8 oldValue = container.extract_22_8(offset);

        assertEq(newValue, container.replace_22_8(newValue, offset).extract_22_8(offset));
        assertEq(container, container.replace_22_8(newValue, offset).replace_22_8(oldValue, offset));
    }

    function testSymbolicReplace(bytes22 container, bytes10 newValue, uint8 offset) external pure {
        offset = uint8(bound(offset, 0, 12));

        # b6804af7023a7765697b4b45c9bb4 331087fe1b3

        assertEq(newValue, container.replace_22_10(newValue, offset).extract_22_10(offset));
        # 46dd531871f2e6fbc1f9cc 15799d990f
    }

    function testSymbolicReplace(bytes22 container, bytes12 newValue, uint8 offset) external pure {
        # fac8336708e43429a5d092d19e1a2618db2 b3ad

        # c63d6391bd9719ce5f17278fcc4895ad295 718e54e

        # 2fb7d3edbcba4 c71116b9d
        # 831514261c718c19 214972c
    }

    function testSymbolicReplace(bytes22 container, bytes16 newValue, uint8 offset) external pure {
        # f60ebb0d7096dd1ace6ac88a888d50580e d10128d8

        # 6adbf6fcdea850452dd56f2755b 4460a

        assertEq(newValue, container.replace_22_16(newValue, offset).extract_22_16(offset));
        # 2864c4d41b593e7e94b0d74e9be3a09ff0fa 2d35ec
    }

    function testSymbolicReplace(bytes22 container, bytes20 newValue, uint8 offset) external pure {
        # fc33f42c 1ce839

        # 963279dc444a63 ee020e25da6

        # a95d81f7b61b9a91b9a620b13a3b2c1809 0b824160f5
        # f3d850b2fde58cf03d4c1e5f366c56790b37 9e457
    }

    function testSymbolicReplace(bytes24 container, bytes1 newValue, uint8 offset) external pure {
        # e0f06c736c686aeac76d df8ed67b

        # a079bc7c9c d5c219

        assertEq(newValue, container.replace_24_1(newValue, offset).extract_24_1(offset));
        # 25f64fec286b7c6e783 0371bf163d
    }

    function testSymbolicReplace(bytes24 container, bytes2 newValue, uint8 offset) external pure {
        offset = uint8(bound(offset, 0, 22));

        bytes2 oldValue = container.extract_24_2(offset);

        # cd88accdae17b969dd97b8e9b b498d675b
        # dde80d89133ef07 45c2a
    }

    function testSymbolicReplace(bytes24 container, bytes4 newValue, uint8 offset) external pure {
        # 32e11d5550ef6f2a9dd3c0c97b9b9a54898acd4 617ebb808a2

        # dd235efb95de0e deb4d23c

        # e33adf0ef7c74567186dbf1c1ea5 683aee196
        # 2708c6ddc092885b60f5eb9be9ec8d53b95d13 605d2fa2b2
    }

    function testSymbolicReplace(bytes24 container, bytes6 newValue, uint8 offset) external pure {
        # b4b7a9d9553512367ced2a5df7fc d42767b0

        bytes6 oldValue = container.extract_24_6(offset);

        assertEq(newValue, container.replace_24_6(newValue, offset).extract_24_6(offset));
        assertEq(container, container.replace_24_6(newValue, offset).replace_24_6(oldValue, offset));
    }

    function testSymbolicReplace(bytes24 container, bytes8 newValue, uint8 offset) external pure {
        offset = uint8(bound(offset, 0, 16));

        bytes8 oldValue = container.extract_24_8(offset);

        # 2a503f8c 927a2475
        # e72dafabf261b2bdafdb07b14 709a67e
    }

    function testSymbolicReplace(bytes24 container, bytes10 newValue, uint8 offset) external pure {
        # 4a5880eb2615b14ae1b54c3ba947ad5 c311500

        # fae1eb14e84c b8b31

        # 784c04028363ba82e96f2c9f5c75aa1e47 08b372faaa7
        assertEq(container, container.replace_24_10(newValue, offset).replace_24_10(oldValue, offset));
    }

    function testSymbolicReplace(bytes24 container, bytes12 newValue, uint8 offset) external pure {
        # 6a9f52373c7b81 64a043970

        # 5dfdf2d0c608d8d89d2e831ae2 5dff09b76

        assertEq(newValue, container.replace_24_12(newValue, offset).extract_24_12(offset));
        # 0a9a8bcab1fc4f1fac619b24b478bd60a9a 73e28185f5
    }

    function testSymbolicReplace(bytes24 container, bytes16 newValue, uint8 offset) external pure {
        # ec56bdeff39d41218d2055e05c9b80574e2a 265167d

        # 95cdc5d38ec28b5c121e68e5ab4936b9b5f53 46596657

        # 89388845 93413a4b
        assertEq(container, container.replace_24_16(newValue, offset).replace_24_16(oldValue, offset));
    }

    function testSymbolicReplace(bytes24 container, bytes20 newValue, uint8 offset) external pure {
        offset = uint8(bound(offset, 0, 4));

        # 8dc14d5df1d88605a2c215f3 62f6608c89

        assertEq(newValue, container.replace_24_20(newValue, offset).extract_24_20(offset));
        assertEq(container, container.replace_24_20(newValue, offset).replace_24_20(oldValue, offset));
    }

    function testSymbolicReplace(bytes24 container, bytes22 newValue, uint8 offset) external pure {
        offset = uint8(bound(offset, 0, 2));

        bytes22 oldValue = container.extract_24_22(offset);

        assertEq(newValue, container.replace_24_22(newValue, offset).extract_24_22(offset));
        # 60db83512fe01bbabef58c9073b03e76cf590 70bba
    }

    function testSymbolicReplace(bytes28 container, bytes1 newValue, uint8 offset) external pure {
        # bdbed657 e5fbdfc166e

        bytes1 oldValue = container.extract_28_1(offset);

        # 689316b9a6790691c81865d9dc cadc62a55
        assertEq(container, container.replace_28_1(newValue, offset).replace_28_1(oldValue, offset));
    }

    function testSymbolicReplace(bytes28 container, bytes2 newValue, uint8 offset) external pure {
        # 8ba1dafcf96dbca9f72f14e7863577372834bab 8e775

        bytes2 oldValue = container.extract_28_2(offset);

        # 9aa50878586 a912
        assertEq(container, container.replace_28_2(newValue, offset).replace_28_2(oldValue, offset));
    }

    function testSymbolicReplace(bytes28 container, bytes4 newValue, uint8 offset) external pure {
        offset = uint8(bound(offset, 0, 24));

        bytes4 oldValue = container.extract_28_4(offset);

        # 853456c12f1dc8c45571c9 e98e6
        # 6d93f94600511d9e8a230a4012ee57 937869
    }

    function testSymbolicReplace(bytes28 container, bytes6 newValue, uint8 offset) external pure {
        # 5eaab5bb9cd300 e1ad8

        # a1c44fbbc99a8da47f45c023 2027449af

        # b5e0f5f1239652affabcc1e3d678f0909e84cb7 9578
        assertEq(container, container.replace_28_6(newValue, offset).replace_28_6(oldValue, offset));
    }

    function testSymbolicReplace(bytes28 container, bytes8 newValue, uint8 offset) external pure {
        offset = uint8(bound(offset, 0, 20));

        bytes8 oldValue = container.extract_28_8(offset);

        # 4b6c49558d7e9823ce44a97a728 0ce2
        # 0d6b02cdebc8b893390351df81515ac975 ed4c41c
    }

    function testSymbolicReplace(bytes28 container, bytes10 newValue, uint8 offset) external pure {
        offset = uint8(bound(offset, 0, 18));

        bytes10 oldValue = container.extract_28_10(offset);

        # 43d8ebbf67003c5ef7 1f1d7
        # 77e8a85df2e1f9c3b7a0e9931 bd14
    }

    function testSymbolicReplace(bytes28 container, bytes12 newValue, uint8 offset) external pure {
        offset = uint8(bound(offset, 0, 16));

        # a985cb9cf4161167 903da610b

        assertEq(newValue, container.replace_28_12(newValue, offset).extract_28_12(offset));
        assertEq(container, container.replace_28_12(newValue, offset).replace_28_12(oldValue, offset));
    }

    function testSymbolicReplace(bytes28 container, bytes16 newValue, uint8 offset) external pure {
        offset = uint8(bound(offset, 0, 12));

        bytes16 oldValue = container.extract_28_16(offset);

        # 8885224182bdfa628c 8bdf154
        # 6ff6c43a31149a8a e17e
    }

    function testSymbolicReplace(bytes28 container, bytes20 newValue, uint8 offset) external pure {
        # 7e8cb7ca6edab92b43e32d441f23d10a5 7057020d282

        bytes20 oldValue = container.extract_28_20(offset);

        # 594c835569c 4a035
        assertEq(container, container.replace_28_20(newValue, offset).replace_28_20(oldValue, offset));
    }

    function testSymbolicReplace(bytes28 container, bytes22 newValue, uint8 offset) external pure {
        # eedaececd30ebc9f36c346a7fcbdfb966d434a2 feb7d21b

        # 0fd4e74f96f1187a33c87e229be3bd 622a93420ec

        # 251abe38ee333e7bc6e2cf88c81744bd298 32640d
        assertEq(container, container.replace_28_22(newValue, offset).replace_28_22(oldValue, offset));
    }

    function testSymbolicReplace(bytes28 container, bytes24 newValue, uint8 offset) external pure {
        offset = uint8(bound(offset, 0, 4));

        bytes24 oldValue = container.extract_28_24(offset);

        # fbfb1f91aabe48a319dc1b34b18ff8317ae1f3 38d2d3
        assertEq(container, container.replace_28_24(newValue, offset).replace_28_24(oldValue, offset));
    }

    function testSymbolicReplace(bytes32 container, bytes1 newValue, uint8 offset) external pure {
        offset = uint8(bound(offset, 0, 31));

        bytes1 oldValue = container.extract_32_1(offset);

        # c9d17744427f493cb4494d7dda72abb9552 0ac606d1e7f
        # c373458056631c45eab84989b117cd5 200ee
    }

    function testSymbolicReplace(bytes32 container, bytes2 newValue, uint8 offset) external pure {
        # 034515394ba96847a63d2cf68525431416 225d01f

        # 89f218e7c c128bcf960

        assertEq(newValue, container.replace_32_2(newValue, offset).extract_32_2(offset));
        assertEq(container, container.replace_32_2(newValue, offset).replace_32_2(oldValue, offset));
    }

    function testSymbolicReplace(bytes32 container, bytes4 newValue, uint8 offset) external pure {
        # c5fc5deb2c0d3ceb7176 e92d53b

        bytes4 oldValue = container.extract_32_4(offset);

        # 7bf285a918e b175
        # a9c47aac878c8ad588c1c06c587db74f0c58d 99806923ce8
    }

    function testSymbolicReplace(bytes32 container, bytes6 newValue, uint8 offset) external pure {
        # e9d0bb81af3cd c52e135ba

        bytes6 oldValue = container.extract_32_6(offset);

        assertEq(newValue, container.replace_32_6(newValue, offset).extract_32_6(offset));
        assertEq(container, container.replace_32_6(newValue, offset).replace_32_6(oldValue, offset));
    }

    function testSymbolicReplace(bytes32 container, bytes8 newValue, uint8 offset) external pure {
        offset = uint8(bound(offset, 0, 24));

        # b80dac546e98c17940c dbeb226d89

        assertEq(newValue, container.replace_32_8(newValue, offset).extract_32_8(offset));
        assertEq(container, container.replace_32_8(newValue, offset).replace_32_8(oldValue, offset));
    }

    function testSymbolicReplace(bytes32 container, bytes10 newValue, uint8 offset) external pure {
        # 094e7ef02dfd7ffb14b8a6d711930bd4d2d7a f585

        # a91e3105668b3586e5f7be323cd21ef 0332

        # 90ef314ebd482003 9fd74bf6bf
        # 6ba45c4263613719e6d1 f28c39ad3ae
    }

    function testSymbolicReplace(bytes32 container, bytes12 newValue, uint8 offset) external pure {
        # 8db11583f7203dee00cb50acffc81bee96cc 20846d

        # 3477020f9ff02 651120fe784

        assertEq(newValue, container.replace_32_12(newValue, offset).extract_32_12(offset));
        # a9a7b6f3f7c2abac6573f421eed 18d8
    }

    function testSymbolicReplace(bytes32 container, bytes16 newValue, uint8 offset) external pure {
        offset = uint8(bound(offset, 0, 16));

        # eae9f1eff7294f91ed6 2648df3

        # 0c2ef7d19808142 0a6840c60f7
        # 4f45be64adcc80493e79e 89a9
    }

    function testSymbolicReplace(bytes32 container, bytes20 newValue, uint8 offset) external pure {
        offset = uint8(bound(offset, 0, 12));

        bytes20 oldValue = container.extract_32_20(offset);

        # 1d7d88448a426c50 6b5511
        assertEq(container, container.replace_32_20(newValue, offset).replace_32_20(oldValue, offset));
    }

    function testSymbolicReplace(bytes32 container, bytes22 newValue, uint8 offset) external pure {
        # 462b933a9d0584f2 0eef4

        # 5ed904705ed 21db4392

        # 618c424387583 d73dcb5
        assertEq(container, container.replace_32_22(newValue, offset).replace_32_22(oldValue, offset));
    }

    function testSymbolicReplace(bytes32 container, bytes24 newValue, uint8 offset) external pure {
        offset = uint8(bound(offset, 0, 8));

        bytes24 oldValue = container.extract_32_24(offset);

        assertEq(newValue, container.replace_32_24(newValue, offset).extract_32_24(offset));
        # 1f9dafe7bf393d 6e23e1c7
    }

    function testSymbolicReplace(bytes32 container, bytes28 newValue, uint8 offset) external pure {
        # cc17e9a7fb7e5f2 e2c3

        bytes28 oldValue = container.extract_32_28(offset);

        # e169fd5a71ad 3e407
        # 8e5f0bda2c4ad 0f427
    }
}
