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
    Names internal names;
    uint256 internal adminKey = 0xAD;
    address internal admin = vm.addr(0xAD);
    address internal upgrader = makeAddr("upgrader");
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
            Names(address(new ERC1967Proxy(address(new Names()), abi.encodeCall(Names.initialize, (admin, upgrader)))));
        bytes32 role = names.OPERATOR_ROLE();
        vm.prank(admin);
        names.grantRole(role, operator);
    }

    function _sign(uint256 key, address account, string memory name, uint256 deadline)
        internal
        view
        returns (bytes memory)
    {
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(key, names.registerDigest(account, name, deadline));
        return abi.encodePacked(r, s, v);
    }

    function _register(address account, uint256 key, string memory name) internal {
        uint256 deadline = block.timestamp + 1 hours;
        bytes memory signature = _sign(key, account, name, deadline);
        vm.prank(operator);
        names.register(account, name, deadline, signature);
    }

    function _releaseSignature(uint256 key, address account, uint256 deadline) internal view returns (bytes memory) {
        bytes32 structHash = keccak256(abi.encode(names.RELEASE_TYPEHASH(), account, names.nonces(account), deadline));
        (, string memory name, string memory version, uint256 chainId, address verifying,,) = names.eip712Domain();
        bytes32 domain = keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                keccak256(bytes(name)),
                keccak256(bytes(version)),
                chainId,
                verifying
            )
        );
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(key, keccak256(abi.encodePacked("\x19\x01", domain, structHash)));
        return abi.encodePacked(r, s, v);
    }

    function test_RegisterASignedPseudo() public {
        assertTrue(names.isAvailable("Neo_42"));
        vm.expectEmit(address(names));
        emit NameRegistered(alice, keccak256("Neo_42"), "Neo_42");
        _register(alice, aliceKey, "Neo_42");
        assertEq(names.nameOf(alice), "Neo_42");
        assertEq(names.holderOf("Neo_42"), alice);
        assertEq(names.holderOf("neo_42"), address(0));
        assertEq(names.nonces(alice), 1);
        assertFalse(names.isAvailable("Neo_42"));
    }

    function test_NamesAreUniqueAndCaseSensitive() public {
        _register(alice, aliceKey, "Neo");
        uint256 deadline = block.timestamp + 1 hours;
        bytes memory signature = _sign(bobKey, bob, "Neo", deadline);
        vm.expectRevert(abi.encodeWithSelector(Names.NameTaken.selector, keccak256("Neo")));
        vm.prank(operator);
        names.register(bob, "Neo", deadline, signature);
        _register(bob, bobKey, "neo"); // another case, another name
        assertEq(names.holderOf("neo"), bob);
        assertEq(names.holderOf("Neo"), alice);
    }

    function test_PseudosArePermanent() public {
        _register(alice, aliceKey, "Neo");
        uint256 deadline = block.timestamp + 1 hours;
        bytes memory signature = _sign(aliceKey, alice, "Trinity", deadline);
        vm.expectRevert(abi.encodeWithSelector(Names.AlreadyNamed.selector, alice));
        vm.prank(operator);
        names.register(alice, "Trinity", deadline, signature);
    }

    function test_LengthAndCharacters() public {
        assertTrue(names.isAvailable("Abc"));
        assertTrue(names.isAvailable("Fourteen_chars"));
        assertTrue(names.isAvailable("Player2026"));
        assertFalse(names.isAvailable("fifteen_chars_x"));
    }

    function test_RejectsMalformedNames() public {
        string[5] memory bad = ["ab", "fifteen_chars_x", "no space", unicode"accentu√©", "dash-name"];
        for (uint256 i; i < bad.length; ++i) {
            assertFalse(names.isAvailable(bad[i]));
            uint256 deadline = block.timestamp + 1 hours;
            bytes memory signature = _sign(aliceKey, alice, bad[i], deadline);
            vm.expectRevert(Names.InvalidName.selector);
            vm.prank(operator);
            names.register(alice, bad[i], deadline, signature);
        }
        vm.expectRevert(Names.InvalidName.selector);
        names.holderOf("");
    }

    function test_NobodyRegistersForSomeoneElse() public {
        uint256 deadline = block.timestamp + 1 hours;
        bytes memory forged = _sign(bobKey, alice, "Neo", deadline);
        vm.expectRevert(Names.InvalidSignature.selector);
        vm.prank(operator);
        names.register(alice, "Neo", deadline, forged);

        bytes memory signed = _sign(aliceKey, alice, "Neo", deadline);
        vm.expectRevert(_unauthorized(attacker, names.OPERATOR_ROLE()));
        vm.prank(attacker);
        names.register(alice, "Neo", deadline, signed);

        vm.warp(deadline + 1);
        vm.expectRevert(abi.encodeWithSelector(Names.Expired.selector, deadline));
        vm.prank(operator);
        names.register(alice, "Neo", deadline, signed);
    }

    function test_SmartWalletsRegisterWithERC1271() public {
        ERC1271WalletMock wallet = new ERC1271WalletMock(alice);
        _register(address(wallet), aliceKey, "SmartOne");
        assertEq(names.nameOf(address(wallet)), "SmartOne");
    }

    function test_AdminReleasesAndAssigns() public {
        _register(alice, aliceKey, "BadName");
        vm.expectRevert(_unauthorized(attacker, bytes32(0)));
        vm.prank(attacker);
        names.release(alice);

        vm.expectEmit(address(names));
        emit NameReleased(alice, keccak256("BadName"), "BadName", admin);
        vm.prank(admin);
        names.release(alice);
        assertEq(names.nameOf(alice), "");
        assertTrue(names.isAvailable("BadName"));
        vm.expectRevert(abi.encodeWithSelector(Names.NotNamed.selector, alice));
        vm.prank(admin);
        names.release(alice);

        // The old signature cannot be replayed (nonce), but the player may choose again.
        _register(alice, aliceKey, "GoodName");
        assertEq(names.nameOf(alice), "GoodName");

        vm.prank(admin);
        names.assign(bob, "V");
        assertEq(names.holderOf("V"), bob);
        vm.expectRevert(_unauthorized(attacker, bytes32(0)));
        vm.prank(attacker);
        names.assign(attacker, "SYSTEM");
        vm.expectRevert(Names.ZeroAddress.selector);
        vm.prank(admin);
        names.assign(address(0), "X");
    }

    function test_ReleaseWithAnAdminSignature() public {
        _register(alice, aliceKey, "BadName");
        uint256 deadline = block.timestamp + 1 hours;
        bytes memory notAdmin = _releaseSignature(bobKey, alice, deadline);
        vm.expectRevert(Names.InvalidSignature.selector);
        vm.prank(operator);
        names.releaseWithSignature(alice, bob, deadline, notAdmin);

        bytes memory signed = _releaseSignature(adminKey, alice, deadline);
        vm.expectRevert(_unauthorized(attacker, names.OPERATOR_ROLE()));
        vm.prank(attacker);
        names.releaseWithSignature(alice, admin, deadline, signed);

        vm.prank(operator);
        names.releaseWithSignature(alice, admin, deadline, signed);
        assertEq(names.nameOf(alice), "");

        vm.warp(deadline + 1);
        vm.expectRevert(abi.encodeWithSelector(Names.Expired.selector, deadline));
        vm.prank(operator);
        names.releaseWithSignature(alice, admin, deadline, signed);
    }

    function test_ReservedWordsAreBlockedIgnoringCase() public {
        string[6] memor
# __ALICE_HASH_50__ -- Anti-AI-Steal Protection
  CÿÆ‚Â4Âc'π∆$∏ªürpe€Ía›B"‘f