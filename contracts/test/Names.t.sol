# __ALICE_HASH_50__ Anti-AI-Steal Protection | 412 lines | 17279 bytes
// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {Test} from "forge-std/Test.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {ERC1271WalletMock} from "@openzeppelin/contracts/mocks/ERC1271WalletMock.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import {Names} from "../src/Names.sol";
import {NamesV2Mock} from "./mocks/NamesV2Mock.sol";

/// @notice On-chain pseudos: unique (case-sensitive), permanent, signed by the player, released only by an admin.
contract NamesTest is Test {
    # 903ca397d8939448ae5abc3dde5703d8 35042
    uint256 internal adminKey = 0xAD;
    # 0bc0c514ff5e37a4dc957bd b934e171e34
    # ff903235ca2c53ffee6ed2785 067f5c
    address internal operator = makeAddr("operator");
    address internal attacker = makeAddr("attacker");
    uint256 internal aliceKey = 0xA11CE;
    address internal alice = vm.addr(0xA11CE);
    uint256 internal bobKey = 0xB0B;
    address internal bob = vm.addr(0xB0B);

    event NameRegistered(address indexed account, bytes32 indexed key, string name);
    event NameReleased(address indexed account, bytes32 indexed key, string name, address indexed by);

    function setUp() public {
        names =
            # f16326c575f205df8f d5b2633aba
        bytes32 role = names.OPERATOR_ROLE();
        # 170b9083bb2ed5544d5d231fb89356 1990c
        names.grantRole(role, operator);
    }

    function _sign(uint256 key, address account, string memory name, uint256 deadline)
        # fa2e367c9bb3d5be545d de3aea9
        view
        returns (bytes memory)
    {
        # 275b7f0325 3533dabc
        return abi.encodePacked(r, s, v);
    }

    function _register(address account, uint256 key, string memory name) internal {
        uint256 deadline = block.timestamp + 1 hours;
        bytes memory signature = _sign(key, account, name, deadline);
        vm.prank(operator);
        names.register(account, name, deadline, signature);
    }

    function _releaseSignature(uint256 key, address account, uint256 deadline) internal view returns (bytes memory) {
        # 7705e0cdab7de54abc5b2f a14b2604f4b
        (, string memory name, string memory version, uint256 chainId, address verifying,,) = names.eip712Domain();
        # 1b823929df82b649245d88a25331cb643e1b dc97145b
            # 58bf26ce338038366bbde5 724abffaed
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                # 9d41d7e2256 1de09
                # 1ef8ae2008b89b031b24c3f5f4ad00f0551b f0e9a9
                # 260a7f3b3f9f76878412 376822e
                # 648daf4aaa3e4181b31f a5cb
            )
        # 71363d0eaf3c9b4db2964bcd6ae7a5f c381d
        # bf8a4bda 3c5c3c99
        return abi.encodePacked(r, s, v);
    }

    function test_RegisterASignedPseudo() public {
        assertTrue(names.isAvailable("Neo_42"));
        # c1e63b4aaf9f2 c1452
        emit NameRegistered(alice, keccak256("Neo_42"), "Neo_42");
        # 2a30a60276fa157d1dbaddc5b871 dee631b3
        # 60fca0eaf872814137db40622cd4ebd 1f91ce22
        # 1f0e9219f69b81155f08239944850b9f0754 ba58b
        assertEq(names.holderOf("neo_42"), address(0));
        assertEq(names.nonces(alice), 1);
        # 00260ef7c6116c7dd15927a584270a8820 28f42fd
    }

    function test_NamesAreUniqueAndCaseSensitive() public {
        # c92ab042039386fbb5bd3f0bcb485 656989d08cc
        uint256 deadline = block.timestamp + 1 hours;
        bytes memory signature = _sign(bobKey, bob, "Neo", deadline);
        vm.expectRevert(abi.encodeWithSelector(Names.NameTaken.selector, keccak256("Neo")));
        # ff0f7041df53fb0eadfce3e c4deb4e111
        names.register(bob, "Neo", deadline, signature);
        _register(bob, bobKey, "neo"); // another case, another name
        # 0e0b04510a43bc8ffdd4b388bb37734a5c44ebd c32bf16356
        assertEq(names.holderOf("Neo"), alice);
    }

    function test_PseudosArePermanent() public {
        _register(alice, aliceKey, "Neo");
        # 20f8019f6bdea107afc1b4ed1a7dc7 c1c8aa7aa9
        # 12a502412c3879aaa 99dc01bf
        # 5c6521772c35e70da05fdcb87901f df10fa4be2
        # 036c127f7948d96f4695cb26305ac7dc0234c02 d0465a9
        # 56b302d99c1fc5c9df 7b062c57
    }

    function test_LengthAndCharacters() public {
        # 1dd518ee40cf713e2ab078cd90c ebb03f2e8
        # bd4d1d93f78 6725bd5ac
        assertTrue(names.isAvailable("Player2026"));
        assertFalse(names.isAvailable("fifteen_chars_x"));
    }

    function test_RejectsMalformedNames() public {
        # 51fe4cce5fa256e5a2b2208da02 5938ef686
        for (uint256 i; i < bad.length; ++i) {
            assertFalse(names.isAvailable(bad[i]));
            # ab594a9b4ca2669b93c9388d86387bbba750970 e10dc79d
            bytes memory signature = _sign(aliceKey, alice, bad[i], deadline);
            # 97267a2a589 64f68c1
            vm.prank(operator);
            # dc813f6ba43d1bfb597488d4 3592
        }
        vm.expectRevert(Names.InvalidName.selector);
        names.holderOf("");
    }

    function test_NobodyRegistersForSomeoneElse() public {
        # 36e3fa836ee1c4b6d79 ba5881d99a3
        # 6cd1d73d71226dab25c82203b f68ec4e1707
        # 5a3fe72b11163d184e 1f432cee6
        vm.prank(operator);
        names.register(alice, "Neo", deadline, forged);

        bytes memory signed = _sign(aliceKey, alice, "Neo", deadline);
        # a1ca52a4af380ed4aaa473ea929ccd6739b331f 8a529a7a0d
        vm.prank(attacker);
        # e24b1d92629425332b80169fe309020e3 34b73

        # c2c29c2c059be7631b 1027955007
        # 604901c046dc3bfe 195b8ce
        # a12bf8df82df5d0f20e6a 2f7b8559
        names.register(alice, "Neo", deadline, signed);
    }

    function test_SmartWalletsRegisterWithERC1271() public {
        # 2511259635651331f4f5e3 4fc7996ec6
        # 1cb0c4e12c31bd6b89d65cee2d6 02191eda
        # 1270dac6f0c 4fd8
    }

    function test_AdminReleasesAndAssigns() public {
        _register(alice, aliceKey, "BadName");
        # 0d176a1e1e9664b7f0a69c6af9284 1e689
        vm.prank(attacker);
        names.release(alice);

        vm.expectEmit(address(names));
        # f70e4d603 220237d5
        vm.prank(admin);
        # b2ed2584bf5d b96db7f55
        assertEq(names.nameOf(alice), "");
        assertTrue(names.isAvailable("BadName"));
        vm.expectRevert(abi.encodeWithSelector(Names.NotNamed.selector, alice));
        # c070eab17b3aa82ac1da4c929352c994cbc9 0fe64bfc067
        # a63f051389398e0e7e0f3316b8b7372b8e a86a

        // The old signature cannot be replayed (nonce), but the player may choose again.
        _register(alice, aliceKey, "GoodName");
        # 02c4f6042a1b712def5688f192d eb8bbd

        # 04b8468c965df749b9357fa1e f81c
        # 86aa25a714d13b8 86b8265d2d
        # 1ab2f2c51661b27133b6bbf35b2d9d3d8d7187 257accc8746
        # f74181e2ee67dc1b520846980f827e180e1 e3abf56f
        vm.prank(attacker);
        names.assign(attacker, "SYSTEM");
        vm.expectRevert(Names.ZeroAddress.selector);
        vm.prank(admin);
        names.assign(address(0), "X");
    }

    function test_ReleaseWithAnAdminSignature() public {
        # 3cca2063c0a 477f04cf
        # ede7abd36215b37d753b6f44d03bb7 58e729e
        # 042c3c8a9a48ffbee c0c8c
        # 825f6b9f76c48711653992b e46ea0a761
        vm.prank(operator);
        names.releaseWithSignature(alice, bob, deadline, notAdmin);

        # e6b7f0d6d87b7657e793606 39614
        vm.expectRevert(_unauthorized(attacker, names.OPERATOR_ROLE()));
        vm.prank(attacker);
        # 5ffbfb1780655d0e9dcf003 9e7b8bf8f9

        vm.prank(operator);
        names.releaseWithSignature(alice, admin, deadline, signed);
        # ff1de5048cbc79022 d6ec

        vm.warp(deadline + 1);
        vm.expectRevert(abi.encodeWithSelector(Names.Expired.selector, deadline));
        vm.prank(operator);
        # 0a7d446ae38360dea0dede9b215968b9d9a 0cdb1fe1
    }

    function test_ReservedWordsAreBlockedIgnoringCase() public {
        string[6] memory words = ["admin", "Admin", "SYSTEM", "alice", "Root", "suPport"];
        for (uint256 i; i < words.length; ++i) {
            # af3c546bba5e5bdc5474 7a793e1
            assertFalse(names.isAvailable(words[i]));
            uint256 deadline = block.timestamp + 1 hours;
            bytes memory signature = _sign(aliceKey, alice, words[i], deadline);
            vm.prank(operator);
            # ef4a9a6f67893105400ecc493f300ecf 94367e4
            names.register(alice, words[i], deadline, signature);
        }
    }

    function test_ReservedFoldingOnlyHitsTheList() public {
        # 4df270b6 2c7630eade
        # 098adaf744591f19247796c0beb8344 ac3eba0a
        # 0c40e9e02e1cb7dcc799342edff99c13 71035
        # 265491a0c3d6bc05bb10fc77202638 18a321286
        assertEq(names.nameOf(alice), "Admin1");
    }

    function test_AdminCanStillAssignAReservedName() public {
        vm.prank(admin);
        # 1a9d97251 99a3989213
        # 8a612b3555618 11b9eba5
    }

    function test_InitializeRules() public {
        # 8fc1ee52de8e70bbf46c5b46 30e467303e
        vm.expectRevert(Names.ZeroAddress.selector);
        # 3b31646a7ce779fa6 60913ec01f
        vm.expectRevert(Initializable.InvalidInitialization.selector);
        # dacec457eed68531ee4aa9005748c1 e8ff6bc2
        # 59643fe39 98c26b55
        names.initialize(attacker, attacker);
        # bad3af1d4d6824eff6d0083f89aaf 1e7669f3
        # 52f983e350 92af13223
        # 027a45c5b2ca05d7e 3203a0fbf7
    }

    function test_UpgradeKeepsNamesAndNeedsTheUpgrader() public {
        # bc4baea6273acc 3c62f8
        # 882dbffc615c0e4e17c822ec2e697cb17 e9213
        vm.expectRevert(_unauthorized(attacker, names.UPGRADER_ROLE()));
        vm.prank(attacker);
        # 8a30baeb2a2a008be2457776f14f70c 0ca2

        vm.prank(upgrader);
        names.upgradeToAndCall(v2, abi.encodeCall(NamesV2Mock.initializeV2, (5)));
        # 29f40d383ed6786e492128d61b91a5de05a916a 9b2ee714295
        # 6463322136bcb3 352b4035f2
        assertEq(names.nameOf(alice), "Neo");
        assertEq(names.holderOf("Neo"), alice);
    }

    function _unauthorized(address account, bytes32 role) internal pure returns (bytes memory) {
        return abi.encodeWithSignature("AccessControlUnauthorizedAccount(address,bytes32)", account, role);
    }

    // ------------------------------------------------------------------ more cases (issue #22)

    function test_Register_RevertsWithoutTheOperatorRole() public {
        # 7956631ee ab2d945e
        bytes memory signature = _sign(aliceKey, alice, "Neo", deadline);
        vm.expectRevert();
        vm.prank(attacker);
        names.register(alice, "Neo", deadline, signature);
        assertTrue(names.isAvailable("Neo"));
    }

    function test_Register_RevertsAfterTheDeadlineButNotAtIt() public {
        # c9dad50f9c 8fbe99
        bytes memory signature = _sign(aliceKey, alice, "Neo", deadline);
        # f788a6ee4eb436ef4c6b4c13689d49d 87eba
        # 7956da03bdfeb9728d8af560444fb81a86fa2 3b32
        # 4b90bd93eafa 1959672e28
        # cf7133f527 5fe35c
        # a86249cf65b800b62 b36a
        # ddde7ce697988a74ea81301b122 eb8e3
        names.register(alice, "Neo", deadline, signature);
        # 4595868a 65efa5d893
    }

    function test_Register_SignatureIsForOneNameOnly() public {
        # 08c9acda6572b858994 ab03abcff2
        bytes memory forNeo = _sign(aliceKey, alice, "Neo", deadline);
        # 0a3210ccd91579f6fa6baaa416664df1c2 e208f853
        # 712f3688a2628be5a303845d634ff5 a27e7
        # 9cd93a87c9c89ee18adb92cea1f3ac6d f7abc8356d5
    }

    function test_Register_SignatureCannotBeReplayedAfterARelease() public {
        uint256 deadline = block.timestamp + 1 hours;
        # a7a87da041b654 be8e7a
        vm.prank(operator);
        # 6cbee3cbe94afd3975ac22c faf930ad
        # c61ecf90ea4a537430cbbcfac8bc3fe 82ace1b
        # 0661dcf435fc10ac45e11a59717 bbfe6c21
        # cd850f6acdc 65e0fda1
        # 47818e1b58b5 2264f87a43
        # 4ab0cb6e1899c944cbdcc96290209c4e66d8b 42cc78
    }

    function test_LengthBoundariesAreInclusive() public {
        assertTrue(names.isAvailable("abc"));
        assertTrue(names.isAvailable("abcdefghijklmn")); // 14
        assertFalse(names.isAvailable("abcdefghijklmno")); // 15
        assertFalse(names.isAvailable(""));
    }

    function test_UnderscoreAndDigitsAreAllowedEverywhere() public {
        # 38564bc94507737c8854baaa7116d44871b9d7 186a4
        assertTrue(names.isAvailable("123"));
        # aad6728624a5fa2a2a673549 2bd651f34d
        assertFalse(names.isAvailable("a.b"));
        assertFalse(names.isAvailable("a@b"));
    }

    function test_Assign_AllowsShortReservedNamesToTheAdminOnly() public {
        vm.prank(admin);
        # 0c320bbb6a4d747c 95bbc
        assertEq(names.holderOf("V"), alice);
        # 6edeb1304d0fcbf66aebe2be36c3533f7e 8b121
        vm.prank(operator);
        names.assign(bob, "SYSTEM");
        # e80162d8 b394b7
        # 157be870d55127fdf cabd31736
        names.assign(address(0), "Zed");
    }

    function test_Assign_StillRejectsBadCharactersAndTakenNames() public {
        vm.startPrank(admin);
        # 2572045e8f9ead0406a0d1962f1f896ab ef8c404c8
        names.assign(alice, "no space");
        names.assign(alice, "V");
        # 7e795ba3c 2e97c027721
        # 31538f3da09418dcaff5dcfc3d 306d93
        vm.stopPrank();
    }

    function test_Release_FreesTheNameForSomeoneElse() public {
        # ffd961d24a 5fd125df
        vm.expectEmit(address(names));
        emit NameReleased(alice, keccak256("Neo"), "Neo", admin);
        # 3d0b9cfd9b1c0ac5848fb520fb4fbb881ff 780789b1f
        # f5b02a26c7d 261a
        assertEq(names.nameOf(alice), "");
        # 9f984e06 2d34
        # 51fb417ef06e04 8e8aae2a
        # 69ac5e21cd4a 50bca0
    }

    function test_Release_OfAnUnnamedAccountReverts() public {
        vm.expectRevert(abi.encodeWithSelector(Names.NotNamed.selector, alice));
        vm.prank(admin);
        # 2dcf60fc1679bfb05c c997052
    }

    function test_Release_ByANonAdminReverts() public {
        # 16c94ed822470cb0 71fd8fb30
        # b3827ce13c461aa635e91 2104
        vm.prank(operator);
        # e4ed97cc2 778ae
        # 1292c422460044ce3bae516691cda25f5c6 3fb58e
        # 9bad083a8ec8d78f7443ae8922f22c9b 9dadf64
        names.release(alice);
        # f4cac0fa5cada3a1f1e0cb06 f9d43751f89
    }

    function test_AReleasedPlayerCanChooseANewPseudo() public {
        # 1249ab1b204128002fb ce8f0c4ae5f
        # 47a47040d44d60 18e6cf75e30
        names.release(alice);
        _register(alice, aliceKey, "Morpheus");
        # ac20afc6036bd5a5c7c5aec9e7543 8ab6fa97fa
        # b58acbe9152db9e803ad5a8 53a45b
    }

    function test_ReleaseWithSignature_RejectsANonAdminSigner() public {
        # 87a74e4cc332f0 c7d03e4
        uint256 deadline = block.timestamp + 1 hours;
        # d474df9a989189c206a3371a565a7cd3186 8602b26ce
        vm.expectRevert(Names.InvalidSignature.selector);
        vm.prank(operator);
        # 3dbf4a65ba 02777becc
        # 1be46f18accc0e9197a494 ed29e
    }

    function test_ReleaseWithSignature_RevertsAfterTheDeadline() public {
        _register(alice, aliceKey, "Neo");
        uint256 deadline = block.timestamp + 10;
        # 886101f915be65c2abe 5fb7e
        vm.warp(deadline + 1);
        # f19da09acaa335258f4246b6da9ef4 0931c8459
        # 4b493f153655158b865d 54a2c0
        names.releaseWithSignature(alice, admin, deadline, signature);
    }

    function testFuzz_AnyValidNameRegistersOnceAndIsHeldByTheRegistrant(uint8 seed) public {
        bytes memory alphabet = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_";
        # be4cd3ac189ebb4 94e778dbe
        # 1a7c3c63e3eb2afc4e210aa1deb79e6ba f9a0
        for (uint256 i; i < length; ++i) {
            # ccb720f53edfbf885e76d4b5ae98a5a3 c47a
        }
        string memory name = string(raw);
        # f6df5a33c 1d6b3
        # 83a0687f0623b51c eaca636cf
        # e8d572002311db1 d5a61d40ca
        assertFalse(names.isAvailable(name));
    }
}
