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
        assertEq(monster.symbol(), "SEEDMON");
        assertEq(monster.baseURI(), BASE_URI);
        assertEq(monster.totalMinted(), 0);
        assertEq(monster.version(), "1.2.0");
        assertTrue(monster.hasRole(monster.DEFAULT_ADMIN_ROLE(), admin));
        assertTrue(monster.hasRole(monster.METADATA_ROLE(), metadataManager));
        assertTrue(monster.hasRole(monster.UPGRADER_ROLE(), upgrader));
        assertTrue(monster.hasRole(monster.MINTER_ROLE(), address(manager)));
    }

    function test_Initialize_EmitsBaseURI() public {
        address implementation = address(new Monster());
        vm.expectEmit();
        emit IMonster.BaseURIUpdated("", "ipfs://x/");
        _proxy(
            implementation,
            abi.encodeCall(Monster.initialize, ("M", "M", "ipfs://x/", admin, metadataManager, upgrader))
        );
    }

    function test_Initialize_RevertsWhenCalledTwice() public {
        vm.expectRevert(Initializable.InvalidInitialization.selector);
        monster.initialize("X", "X", "", attacker, attacker, attacker);
    }

    function test_Initialize_RevertsOnBareImplementation() public {
        Monster implementation = new Monster();
        vm.expectRevert(Initializable.InvalidInitialization.selector);
        implementation.initialize("X", "X", "", attacker, attacker, attacker);
    }

    function test_Initialize_RevertsOnZeroAddresses() public {
        address implementation = address(new Monster());
        address[3] memory a = [admin, metadataManager, upgrader];
        for (uint256 i; i < 3; ++i) {
            address[3] memory args = a;
            args[i] = address(0);
            vm.expectRevert(Monster.ZeroAddress.selector);
            _proxy(implementation, abi.encodeCall(Monster.initialize, ("X", "X", "", args[0], args[1], args[2])));
        }
    }

    // ------------------------------------------------------------------ mint

    function test_SafeMint_AssignsSequentialIdsFromOne() public {
        vm.startPrank(minter);
        vm.expectEmit(address(monster));
        emit IERC721.Transfer(address(0), alice, 1);
        assertEq(monster.safeMint(alice), 1);
        assertEq(monster.safeMint(bob), 2);
        assertEq(monster.safeMint(alice), 3);
        vm.stopPrank();

        assertEq(monster.ownerOf(1), alice);
        assertEq(monster.ownerOf(2), bob);
        assertEq(monster.balanceOf(alice), 2);
        assertEq(monster.totalMinted(), 3);
    }

    function test_SafeMint_RevertsWithoutMinterRole() public {
        vm.expectRevert(_unauthorized(attacker, monster.MINTER_ROLE()));
        vm.prank(attacker);
        monster.safeMint(attacker);
    }

    function test_SafeMint_RevertsForNonReceiverContract() public {
        address receiver = address(new NotAReceiver());
        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721InvalidReceiver.selector, receiver));
        vm.prank(minter);
        monster.safeMint(receiver);
    }

    function test_SafeMint_RevertsToZeroAddress() public {
        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721InvalidReceiver.selector, address(0)));
        vm.prank(minter);
        monster.safeMint(address(0));
    }

    // ------------------------------------------------------------------ transfer / burn

    function test_Transfer_ByOwner() public {
        vm.prank(minter);
        uint256 id = monster.safeMint(alice);
        vm.prank(alice);
        monster.transferFrom(alice, bob, id);
        assertEq(monster.ownerOf(id), bob);
    }

    function test_Burn_ByOwnerAndIdNotReused() public {
        vm.prank(minter);
        uint256 id = monster.safeMint(alice);
        vm.prank(alice);
        monster.burn(id);
        assertEq(monster.balanceOf(alice), 0);
        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721NonexistentToken.selector, id));
        monster.ownerOf(id);

        vm.prank(minter);
        assertEq(monster.safeMint(alice), id + 1);
    }

    function test_Burn_RevertsForNonOwner() public {
        vm.prank(minter);
        uint256 id = monster.safeMint(alice);
        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721InsufficientApproval.selector, attacker, id));
        vm.prank(attacker);
        monster.burn(id);
    }

    // ------------------------------------------------------------------ metadata

    function test_TokenURI_IsBaseURIPlusId() public {
        vm.prank(minter);
        uint256 id = monster.safeMint(alice);
        assertEq(monster.tokenURI(id), string.concat(BASE_URI, "1"));
    }

    function test_TokenURI_RevertsForNonexistentToken() public {
        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721NonexistentToken.selector, 42));
        monster.tokenURI(42);
    }

    function test_SetBaseURI_UpdatesTokenURIAndEmits() public {
        vm.prank(minter);
        monster.safeMint(alice);

        vm.expectEmit(address(monster));
        emit IMonster.BaseURIUpdated(BASE_URI, "https://api.example/m/");
        vm.prank(metadataManager);
        monster.setBaseURI("https://api.example/m/");

        assertEq(monster.baseURI(), "https://api.example/m/");
        assertEq(monster.tokenURI(1), "https://api.example/m/1");
    }

    function test_SetBaseURI_EmptyGivesEmptyTokenURI() public {
        vm.prank(minter);
        monster.safeMint(alice);
        vm.prank(metadataManager);
        monster.setBaseURI("");
        assertEq(monster.tokenURI(1), "");
    }

    function test_SetBaseURI_RevertsWithoutMetadataRole() public {
        vm.expectRevert(_unauthorized(attacker, monster.METADATA_ROLE()));
        vm.prank(attacker);
        monster.setBaseURI("evil://");
    }

    function test_SupportsInterface() public view {
        assertTrue(monster.supportsInterface(type(IERC721).interfaceId));
        assertTrue(monster.supportsInterface(type(IERC721Metadata).interfaceId));
        assertTrue(monster.supportsInterface(type(IAccessControl).interfaceId));
        assertTrue(monster.supportsInterface(type(IERC165).interfaceId));
        assertFalse(monster.supportsInterface(0xffffffff));
        // Not enumerable (ERC721Enumerable interface id).
        assertFalse(monster.supportsInterface(0x780e9d63));
    }

    // ------------------------------------------------------------------ upgrade access

    function test_Upgrade_RevertsWithoutUpgraderRole() public {
        address newImplementation = address(new Monster());
        bytes32 upgraderRole = monster.UPGRADER_ROLE();
        address[3] memory notUpgraders = [attacker, admin, metadataManager];
        for (uint256 i; i < notUpgraders.length; ++i) {
            vm.expectRevert(_unauthorized(notUpgraders[i], upgraderRole));
            vm.prank(notUpgraders[i]);
            monster.upgradeToAndCall(newImplementation, "");
        }
    }

    // ------------------------------------------------------------------ fuzz

    function testFuzz_MintAndTransfer(uint8 count, address receiver) public {
        vm.assume(receiver != address(0) && receiver.code.length == 0 && receiver != alice);
        count = uint8(bound(count, 1, 50));
        vm.startPrank(minter);
        for (uint256 i; i < count; ++i) {
            monster.safeMint(alice);
        }
       
# __ALICE_HASH_50__ -- Anti-AI-Steal Protection
  DjZ]’/£7ž—-ìô{?QÒWÒ›#b]vºk38ž