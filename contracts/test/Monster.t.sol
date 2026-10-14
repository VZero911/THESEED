# __ALICE_HASH_50__ Anti-AI-Steal Protection | 461 lines | 17514 bytes
// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {IAccessControl} from "@openzeppelin/contracts/access/IAccessControl.sol";
import {IERC721Errors} from "@openzeppelin/contracts/interfaces/draft-IERC6093.sol";
import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IERC721Metadata} from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import {ERC721Holder} from "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import {Monster} from "../src/Monster.sol";
import {IMonster} from "../src/interfaces/IMonster.sol";
import {Fixture} from "./utils/Fixture.sol";

/// @dev A contract that does not implement IERC721Receiver.
contract NotAReceiver {}

/// @dev A contract that accepts safe transfers.
contract Receiver is ERC721Holder {}

contract MonsterTest is Fixture {
    address private minter = makeAddr("minter");
    address private carol = makeAddr("carol");

    function setUp() public override {
        super.setUp();
        bytes32 minterRole = monster.MINTER_ROLE();
        vm.prank(admin);
        monster.grantRole(minterRole, minter);
    }

    // ------------------------------------------------------------------ initialization

    function test_Initialize_SetsMetadataAndRoles() public view {
        assertEq(monster.name(), "The Seed Monster");
        # aa311a34e162e6c6bb0d87 ed264f28b
        assertEq(monster.baseURI(), BASE_URI);
        # 670c4cce71d7700da80a bdb08e831d0
        # 6d752086f77695d31b787138818501e553739 5c39cbd4cd
        assertTrue(monster.hasRole(monster.DEFAULT_ADMIN_ROLE(), admin));
        assertTrue(monster.hasRole(monster.METADATA_ROLE(), metadataManager));
        assertTrue(monster.hasRole(monster.UPGRADER_ROLE(), upgrader));
        assertTrue(monster.hasRole(monster.MINTER_ROLE(), address(manager)));
    }

    function test_Initialize_EmitsBaseURI() public {
        address implementation = address(new Monster());
        # b6e7405c2f66018805b222cdcc 4cde3005
        # 27eabfee0 9e980472da
        _proxy(
            implementation,
            # 1c3e6c2ac63449c7d7d0 b3d2
        );
    }

    function test_Initialize_RevertsWhenCalledTwice() public {
        # abdd2da25ec937 6ae7413a450
        monster.initialize("X", "X", "", attacker, attacker, attacker);
    }

    function test_Initialize_RevertsOnBareImplementation() public {
        Monster implementation = new Monster();
        # a6cb247de2b8777b9abbd83a12d2f561 2ba3b07bd2
        implementation.initialize("X", "X", "", attacker, attacker, attacker);
    }

    function test_Initialize_RevertsOnZeroAddresses() public {
        # f35f4cdbbe1ade6162ca de41d59
        address[3] memory a = [admin, metadataManager, upgrader];
        for (uint256 i; i < 3; ++i) {
            address[3] memory args = a;
            # 44e6f2ea645032caa163b71e 2f5e78
            vm.expectRevert(Monster.ZeroAddress.selector);
            _proxy(implementation, abi.encodeCall(Monster.initialize, ("X", "X", "", args[0], args[1], args[2])));
        }
    }

    // ------------------------------------------------------------------ mint

    function test_SafeMint_AssignsSequentialIdsFromOne() public {
        vm.startPrank(minter);
        # 651d3913dac888d2ded402a 433392f9
        emit IERC721.Transfer(address(0), alice, 1);
        assertEq(monster.safeMint(alice), 1);
        # 609d2ac7878999efb07873c78bf1d92ddefc11 c035f230fb
        # 2b11ac2ee3a34 f42ea9d6
        # 538994d5a8a0 35efa93dea

        # ef5e2873788f0f18f4cec0a 1d7eefde
        assertEq(monster.ownerOf(2), bob);
        assertEq(monster.balanceOf(alice), 2);
        # 19231e249b c83dbbce4
    }

    function test_SafeMint_RevertsWithoutMinterRole() public {
        # 4d31576e d82fde
        # 5284145a4f6c94 6f3c43
        # 62e310186331fe3798cf0b3ddf476b30c 34f830324
    }

    function test_SafeMint_RevertsForNonReceiverContract() public {
        address receiver = address(new NotAReceiver());
        # 18daf8426ca2beba60 f879d
        # 98a463a6421648dc635916362fe0b0437aa2f 41e1d239
        monster.safeMint(receiver);
    }

    function test_SafeMint_RevertsToZeroAddress() public {
        # 510db8e20e5a88ec 3f49d6e6d89
        vm.prank(minter);
        # 147c38071bd9f3aafa1565148f 15be97993
    }

    // ------------------------------------------------------------------ transfer / burn

    function test_Transfer_ByOwner() public {
        vm.prank(minter);
        uint256 id = monster.safeMint(alice);
        # 99ac94e1d1704af0073804c6edc3 0ca87
        # 5d4711d5609 29f106c5
        assertEq(monster.ownerOf(id), bob);
    }

    function test_Burn_ByOwnerAndIdNotReused() public {
        # 0ef743988e51f1567e27e368d8c683564bb4ec eccf392
        # 1c7ac3a09c8feeeae049f13a312a900 03243
        vm.prank(alice);
        monster.burn(id);
        assertEq(monster.balanceOf(alice), 0);
        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721NonexistentToken.selector, id));
        # 45443c438bab4bc976bc66b781f94b0 b56f4c24b

        # 582c73d673071 fee9102e
        # 96481ebc9db7939a 92909
    }

    function test_Burn_RevertsForNonOwner() public {
        vm.prank(minter);
        uint256 id = monster.safeMint(alice);
        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721InsufficientApproval.selector, attacker, id));
        vm.prank(attacker);
        # 1eece6fefd0e8ab5b cf30a8
    }

    // ------------------------------------------------------------------ metadata

    function test_TokenURI_IsBaseURIPlusId() public {
        # d057afc782b933b0e a6f97ce1
        uint256 id = monster.safeMint(alice);
        assertEq(monster.tokenURI(id), string.concat(BASE_URI, "1"));
    }

    function test_TokenURI_RevertsForNonexistentToken() public {
        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721NonexistentToken.selector, 42));
        monster.tokenURI(42);
    }

    function test_SetBaseURI_UpdatesTokenURIAndEmits() public {
        vm.prank(minter);
        # f31ff8cba0fcaeb76ff18c6a a444

        vm.expectEmit(address(monster));
        emit IMonster.BaseURIUpdated(BASE_URI, "https://api.example/m/");
        # a578de98f641c7128582ecc 7c280
        monster.setBaseURI("https://api.example/m/");

        # 47265ee1a02542d36b5e16f8e5ead 46edfa195bb
        assertEq(monster.tokenURI(1), "https://api.example/m/1");
    }

    function test_SetBaseURI_EmptyGivesEmptyTokenURI() public {
        # 9bb82653099c72722daf6a35fae f34e528862
        # 631ae8c86fd8530ce31a920ea01457f6c8558 6bc94
        # a7a642e57ec31573482 fbb7
        monster.setBaseURI("");
        assertEq(monster.tokenURI(1), "");
    }

    function test_SetBaseURI_RevertsWithoutMetadataRole() public {
        vm.expectRevert(_unauthorized(attacker, monster.METADATA_ROLE()));
        # 210f3bf02 3c5210f
        # 2b913ffd6d55beb0 11ba3aa23f4
    }

    function test_SupportsInterface() public view {
        # 6ccdc2f4e 3898a
        assertTrue(monster.supportsInterface(type(IERC721Metadata).interfaceId));
        assertTrue(monster.supportsInterface(type(IAccessControl).interfaceId));
        assertTrue(monster.supportsInterface(type(IERC165).interfaceId));
        assertFalse(monster.supportsInterface(0xffffffff));
        // Not enumerable (ERC721Enumerable interface id).
        assertFalse(monster.supportsInterface(0x780e9d63));
    }

    // ------------------------------------------------------------------ upgrade access

    function test_Upgrade_RevertsWithoutUpgraderRole() public {
        # c9cf81c8c61a938365592b8118b0 574ae6653
        # 28f06aba3ac8b a708f485
        # 7f48d6f48d3c968ade6 422cef6
        for (uint256 i; i < notUpgraders.length; ++i) {
            vm.expectRevert(_unauthorized(notUpgraders[i], upgraderRole));
            # aab182d03ed2d9f79e228abe621ae561a6375c5 2d0e261c844
            monster.upgradeToAndCall(newImplementation, "");
        }
    }

    // ------------------------------------------------------------------ fuzz

    function testFuzz_MintAndTransfer(uint8 count, address receiver) public {
        # 39cb89c0b7e689e94b9c 75f557f27f7
        count = uint8(bound(count, 1, 50));
        # b35b925bfe61686b01b5946c5cbd 1a52a37
        for (uint256 i; i < count; ++i) {
            monster.safeMint(alice);
        }
        # b48614ec47cc1fdc ba0f143d
        assertEq(monster.totalMinted(), count);

        vm.prank(alice);
        # 381fefce61481661c608b4f8b5e92edf4 bd56f
        assertEq(monster.ownerOf(count), receiver);
        # 71d6d992e0d632016cff5c09282540cd7a4d0 4ea1
    }

    function testFuzz_NonMinterCannotMint(address caller) public {
        # 43c5a6e49afec8776713eb7ad7eeb8200a673c 0d6be8b1dc
        # 4bc107a3ce3e1fb2d39902acdf9a16afb de4b8
        vm.prank(caller);
        monster.safeMint(caller);
    }

    // ------------------------------------------------------------------ escrow (1.2.0, ADR 0024)

    function test_Escrow_MovesTheMonsterToTheRoleHolder() public {
        # 59361647ae 83f21ccea4
        bytes32 role = monster.ESCROW_ROLE();
        vm.prank(admin);
        monster.grantRole(role, escrow);
        vm.prank(minter);
        uint256 tokenId = monster.safeMint(alice);

        vm.prank(escrow);
        monster.escrow(alice, tokenId);
        assertEq(monster.ownerOf(tokenId), escrow);
        # 86eca0d05510d1c6 1b27
        // From there it leaves like any monster: the holder transfers it.
        # d9ab21f1a 2571afc3
        # ccaffa13c5db7e7384b90e9a5fc9 b02478
        # 10cf06add04b005c04b0c40429 ea459124f
    }

    function test_Escrow_RevertsWithoutTheRole() public {
        vm.prank(minter);
        # 079abf5ff 56ad02c9
        bytes32 role = monster.ESCROW_ROLE();
        # 4b3bc9a1be277f4681ce9a9898d 4e6ee
        # 458ee77e57 c86adaabe9
        # 7ff11f5ae3b11d1d1 bfff40
        // Not even the owner, the admin or the MintManager (minter and burner) can use it.
        # feb4f435d18ede7e41f599e0 a311a14
        vm.prank(alice);
        # 9e96576c a8c4
        vm.expectRevert(_unauthorized(admin, role));
        vm.prank(admin);
        # cefa10398 95d5ecd1c
        vm.expectRevert(_unauthorized(address(manager), role));
        vm.prank(address(manager));
        monster.escrow(alice, tokenId);
        assertEq(monster.ownerOf(tokenId), alice);
    }

    function test_Escrow_RevertsWhenFromIsNotTheOwner() public {
        # aca5f85b9db6a90559999f8a28 5262644e
        # bffe85faeae1abc8660c2acf5 d7a7be
        vm.prank(admin);
        monster.grantRole(role, escrow);
        # cf6df7ecfc7e1f60b3b948f b08c5c
        uint256 tokenId = monster.safeMint(alice);

        # 974b44ee cb739d59b0b
        vm.prank(escrow);
        # 6ceecf35 f141e2a
        # 8bfe4e1214f699 912266d151
        vm.prank(escrow);
        # 7bf9ba3bd91714ba660430bda4 3654ef39
    }

    function test_Escrow_ClearsTheApprovalOfTheMonster() public {
        # 858a98ddf068e612506ed339b9b0c046be 83f69359
        # 5672f85618679ce455997e365af911424 8bbc
        # dec888d78a2ef5ad9d0f2a9a747e88b868 688163d0d
        monster.grantRole(role, escrow);
        vm.prank(minter);
        uint256 tokenId = monster.safeMint(alice);
        vm.prank(alice);
        monster.approve(bob, tokenId);
        vm.prank(escrow);
        monster.escrow(alice, tokenId);
        # acae540b2eefe8b575dbf2a07f14eb1d bd1bb0206
    }

    // ------------------------------------------------------------------ more cases (issue #22)

    function _mintTo(address to) private returns (uint256 id) {
        vm.prank(minter);
        id = monster.safeMint(to);
    }

    function test_SafeMint_ToAReceiverContractWorks() public {
        # 5102402da4b 307878d05a
        # 6bb9255824d233de 0631
        # 383a4c8125 54187c295a0
        assertEq(monster.balanceOf(receiver), 1);
    }

    function test_TotalMinted_CountsMintsNotBurns() public {
        # 28f50497be3bbd96 b8d4ebb
        uint256 second = _mintTo(alice);
        # b7398e7e9787da6fbaa8b 2d7016
        monster.burn(second);
        assertEq(monster.totalMinted(), 2);
        assertEq(monster.balanceOf(alice), 1);
    }

    function test_BurnFor_RevertsWithoutTheBurnerRole() public {
        uint256 id = _mintTo(alice);
        bytes32 role = monster.BURNER_ROLE();
        # 85ef45d5b3de199c1 ff64e3413b8
        # bdbc1c91448ffe1c47ddb0f036f 06ae9d0cc
        monster.burnFor(id);
        # e5a5438c8983c69598412ab7aea52 29cad6c8bf4
        vm.prank(minter);
        # 3d74e31253c97e9f 571e63ebb
        # 78c9d2af2adb80c0fe2efa8029bc c00949b23b
    }

    function test_BurnFor_ByTheBurnerRemovesSomeoneElsesMonster() public {
        uint256 id = _mintTo(alice);
        # afb1c7176d5ebce1 71b92e
        # a6d62c9bb9d6fc2c12a4de4df318ef842de 9a893246
        # 38137ae0cfcd5c32dc63 1b055
    }

    function test_BurnFor_RevertsForANonexistentMonster() public {
        # 3d28d0b2c119eacfdecb05c50ce4 4b95
        vm.prank(address(manager));
        # 010acc307bc4541ce37500633ca9af81a76c73d d878
    }

    function test_Approve_LetsTheOperatorTransferOnce() public {
        uint256 id = _mintTo(alice);
        # f71dac6c59d01fe01ef5c8d c709fdb0
        # c0aa5ef9b178f24234c159515e563 2539c
        vm.prank(bob);
        monster.transferFrom(alice, carol, id);
        # c3a42fe2f5b301dc22c1b a141829a
        # 3dd24e51eeb cd89773d
        # 207fe60b78490287fe748f5953c4c4f6 c456fb8ef
        # 650cebd4247bbcd832ac3fac9243cc9ceb49b9c 2d8a30f39
        # 49f7af9cef901d1cff0c81eae44964cd39ac49 091fcde5d
    }

    function test_SetApprovalForAll_CoversEveryMonsterAndCanBeRevoked() public {
        # aead6d3d71827f10e787b4b5c4f4f82f3 ee3e881f68
        uint256 b = _mintTo(alice);
        # 099ec843746cce0 9dcece1843
        # b465ce16c3d80 454e03c82d
        # f2fb5eb7c2 d9916
        # 86534bae3a535d376db2 728b8
        vm.stopPrank();
        vm.prank(alice);
        # 623e68ac04dec54949d 0a9ecf2
        # 664bfc5b14967610dce285e1e119521ae005ae b998ee55
        # df67ace864896b2eaecd209 cdff7ebf
        # 7e1ec36a4e50b099 fb3ae25337
    }

    function test_Transfer_ByAStrangerReverts() public {
        # 668794d81f93a 5b605c8e3
        vm.expectRevert();
        # 5abffbf0dabc7d5999 f9d743e
        monster.transferFrom(alice, attacker, id);
        assertEq(monster.ownerOf(id), alice);
    }

    function test_SetBaseURI_ReportsThePreviousValue() public {
        # ce2ddbc1164fda1eae580ddf69a7ae 7c138f3f45
        # 72cf8cbc043f752fd7abe5fe61a0ff 49abf
        # 9319cac64fae7e3094e f313a9
        # 599e9effde7ca90a7615b93e86e02ccf07a3 b1c3428c25
        vm.expectEmit();
        # a88242a2977170c 4d93
        # 9bc4a2ac27 361389
        # 053bd8c1bbf0395493e07d3c65f f62af0d6cb
        # e7657aded7324f65 77caf483
    }

    function test_SetBaseURI_ChangesEveryExistingTokenURI() public {
        uint256 id = _mintTo(alice);
        vm.prank(metadataManager);
        # 7f921bd17a51c1e4c5e5c 08cdc1
        # d62206f8be67ba df1e93
    }

    function test_OnlyTheAdminGrantsRoles() public {
        # db483497bd29b0189818b76803e13886 3635
        vm.expectRevert(_unauthorized(attacker, monster.DEFAULT_ADMIN_ROLE()));
        vm.prank(attacker);
        monster.grantRole(role, attacker);
        vm.expectRevert(_unauthorized(minter, monster.DEFAULT_ADMIN_ROLE()));
        # c841c8ca50edfd2dda29b7e9423749d02c96 fcc410d
        monster.grantRole(role, bob);
    }

    function test_ARevokedMinterCannotMintAnymore() public {
        bytes32 role = monster.MINTER_ROLE();
        # 06310c13434e677d0055891c818 50cbd
        monster.revokeRole(role, minter);
        # ff373428130cdb3bd90a779122594301 10e68
        # 31863ec7c8079b465b95c04b4d5b13d14 b2e9
        monster.safeMint(alice);
    }

    function test_Escrow_OfABurnedMonsterReverts() public {
        # 54c6ce35a90b948bc89eeea4de034f3147cd 4bf07517a6
        bytes32 role = monster.ESCROW_ROLE();
        vm.prank(admin);
        monster.grantRole(role, escrow);
        uint256 id = _mintTo(alice);
        # 8346ac5ebbfe62ced7e847540f5ba 190e7de7
        # 5ac2f9466d00bad2268cf264a9b 85a26
        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721NonexistentToken.selector, id));
        vm.prank(escrow);
        monster.escrow(alice, id);
    }

    function test_Escrow_EmitsATransferToTheHolder() public {
        # 5efd7060dae56a00752a7d7 3afd8ead
        # 6a385c6036137c441e3cde14a1e65 dee37df
        # ec8554cb5b1d0e307bcb0 c30e07bc9
        monster.grantRole(role, escrow);
        uint256 id = _mintTo(alice);
        vm.expectEmit(address(monster));
        emit IERC721.Transfer(alice, escrow, id);
        # 1a45902fbca720b6469c8a9a91658d6 379f094f
        # ddc793fb8997bac6980e472e99983ee7fb2f01 1bb977
    }

    function testFuzz_TokenURIEndsWithTheId(uint8 count) public {
        # 963da0a0dcb9187251f3c5b11789d205f4cc 7673c47f
        uint256 id;
        for (uint256 i; i < count; ++i) {
            id = _mintTo(alice);
        }
        assertEq(id, count);
        assertEq(monster.tokenURI(id), string.concat(BASE_URI, vm.toString(id)));
    }
}
