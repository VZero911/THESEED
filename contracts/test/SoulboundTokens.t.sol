// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {IERC20Errors} from "@openzeppelin/contracts/interfaces/draft-IERC6093.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {
    ERC20CappedUpgradeable
} from "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20CappedUpgradeable.sol";
import {
    ERC20PermitUpgradeable
} from "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PermitUpgradeable.sol";
import {PausableUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";

import {Crystal} from "../src/Crystal.sol";
import {ManaCoin} from "../src/ManaCoin.sol";
import {POC} from "../src/POC.sol";
import {SoulboundERC20Upgradeable} from "../src/base/SoulboundERC20Upgradeable.sol";
import {ISoulboundToken} from "../src/interfaces/ISoulboundToken.sol";
import {Fixture} from "./utils/Fixture.sol";

/// @notice Behaviour shared by POC and Mana Coin; run once per token by the concrete contracts below.
abstract contract SoulboundTokenTest is Fixture {
    bytes32 private constant PERMIT_TYPEHASH =
        keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");

    address internal minter = makeAddr("minter");
    SoulboundERC20Upgradeable internal token;

    function _token() internal view virtual returns (SoulboundERC20Upgradeable);
    function _expectedName() internal pure virtual returns (string memory);
    function _expectedSymbol() internal pure virtual returns (string memory);
    function _newProxy(uint256 cap, address admin_, address pauser_, address upgrader_)
        internal
        virtual
        returns (address);
    function _initialize(address target, uint256 cap) internal virtual;

    function setUp() public override {
        super.setUp();
        token = _token();
        bytes32 minterRole = token.MINTER_ROLE();
        vm.prank(admin);
        token.grantRole(minterRole, minter);
    }

    // ------------------------------------------------------------------ initialization

    function test_Initialize_SetsMetadataCapAndRoles() public view {
        assertEq(token.name(), _expectedName());
        assertEq(token.symbol(), _expectedSymbol());
        assertEq(token.decimals(), 18);
        assertEq(token.cap(), CAP);
        assertEq(token.totalSupply(), 0);
        assertEq(token.version(), "1.0.0");
        assertTrue(token.hasRole(token.DEFAULT_ADMIN_ROLE(), admin));
        assertTrue(token.hasRole(token.PAUSER_ROLE(), pauser));
        assertTrue(token.hasRole(token.UPGRADER_ROLE(), upgrader));
        assertTrue(token.hasRole(token.MINTER_ROLE(), address(manager)));
        assertFalse(token.hasRole(token.UPGRADER_ROLE(), admin));
        assertFalse(token.hasRole(token.MINTER_ROLE(), admin));
    }

    function test_Initialize_RevertsWhenCalledTwice() public {
        vm.expectRevert(Initializable.InvalidInitialization.selector);
        _initialize(address(token), 1);
    }

    function test_Initialize_RevertsOnZeroCap() public {
        vm.expectRevert(abi.encodeWithSelector(ERC20CappedUpgradeable.ERC20InvalidCap.selector, 0));
        _newProxy(0, admin, pauser, upgrader);
    }

    function test_Initialize_RevertsOnZeroAddresses() public {
        address[3] memory a = [admin, pauser, upgrader];
        for (uint256 i; i < 3; ++i) {
            address[3] memory args = a;
            args[i] = address(0);
            vm.expectRevert(SoulboundERC20Upgradeable.ZeroAddress.selector);
            _newProxy(CAP, args[0], args[1], args[2]);
        }
    }

    // ------------------------------------------------------------------ soulbound

    function test_Transfer_AlwaysReverts() public {
        vm.prank(minter);
        token.mint(alice, 10 ether);
        vm.expectRevert(ISoulboundToken.NonTransferable.selector);
        vm.prank(alice);
        token.transfer(bob, 1 ether);
        vm.expectRevert(ISoulboundToken.NonTransferable.selector);
        vm.prank(alice);
        token.transfer(alice, 1 ether);
        assertEq(token.balanceOf(alice), 10 ether);
    }

    function test_TransferFrom_RevertsEvenWithAllowance() public {
        vm.prank(minter);
        token.mint(alice, 10 ether);
        vm.prank(alice);
        token.approve(bob, 10 ether);
        vm.expectRevert(ISoulboundToken.NonTransferable.selector);
        vm.prank(bob);
        token.transferFrom(alice, bob, 1 ether);
    }

    function test_Transfer_ZeroAmountAlsoReverts() public {
        vm.expectRevert(ISoulboundToken.NonTransferable.selector);
        vm.prank(alice);
        token.transfer(bob, 0);
    }

    // ------------------------------------------------------------------ mint / cap

    function test_Mint_IncreasesBalanceAndEmitsTransfer() public {
        vm.expectEmit(address(token));
        emit IERC20.Transfer(address(0), alice, 10 ether);
        vm.prank(minter);
        token.mint(alice, 10 ether);
        assertEq(token.balanceOf(alice), 10 ether);
        assertEq(token.totalSupply(), 10 ether);
    }

    function test_Mint_UpToExactlyCap() public {
        vm.prank(minter);
        token.mint(alice, CAP);
        assertEq(token.totalSupply(), CAP);
    }

    function test_Mint_RevertsAboveCap() public {
        vm.startPrank(minter);
        token.mint(alice, CAP - 1);
        vm.expectRevert(abi.encodeWithSelector(ERC20CappedUpgradeable.ERC20ExceededCap.selector, CAP + 1, CAP));
        token.mint(alice, 2);
        vm.stopPrank();
    }

    function test_Mint_RevertsWithoutMinterRole() public {
        vm.expectRevert(_unauthorized(attacker, token.MINTER_ROLE()));
        vm.prank(attacker);
        token.mint(attacker, 1);
    }

    function test_Mint_AdminIsNotMinter() public {
        vm.expectRevert(_unauthorized(admin, token.MINTER_ROLE()));
        vm.prank(admin);
        token.mint(admin, 1);
    }

    function test_Mint_RevertsAfterMinterRoleRevoked() public {
        bytes32 minterRole = token.MINTER_ROLE();
        vm.prank(admin);
        token.revokeRole(minterRole, minter);
        vm.expectRevert(_unauthorized(minter, minterRole));
        vm.prank(minter);
        token.mint(alice, 1);
    }

    // ------------------------------------------------------------------ burn (spending)

    function test_Burn_ByHolderFreesCap() public {
        vm.prank(minter);
        token.mint(alice, CAP);
        vm.prank(alice);
        token.burn(40 ether);
        assertEq(token.totalSupply(), CAP - 40 ether);
        vm.prank(minter);
        token.mint(bob, 40 ether);
        assertEq(token.totalSupply(), CAP);
    }

    function test_BurnFrom_SpendsWithApproval() public {
        vm.prank(minter);
        token.mint(alice, 10 ether);
        vm.prank(alice);
        token.approve(bob, 4 ether);
        vm.prank(bob);
        token.burnFrom(alice, 4 ether);
        assertEq(token.balanceOf(alice), 6 ether);
        assertEq(token.allowance(alice, bob), 0);
    }

    function test_BurnFrom_RevertsWithoutAllowance() public {
        vm.prank(minter);
        token.mint(alice, 10 ether);
        vm.expectRevert(abi.encodeWithSelector(IERC20Errors.ERC20InsufficientAllowance.selector, attacker, 0, 1));
        vm.prank(attacker);
        token.burnFrom(alice, 1);
    }

    // ------------------------------------------------------------------ pause

    function test_Pause_BlocksMintsAndBurns() public {
        vm.prank(minter);
        token.mint(alice, 10 ether);

        vm.expectEmit(address(token));
        emit PausableUpgradeable.Paused(pauser);
        vm.prank(pauser);
        token.pause();
        assertTrue(token.paused());

        vm.expectRevert(PausableUpgradeable.EnforcedPause.selector);
        vm.prank(minter);
        token.mint(alice, 1);

        vm.expectRevert(PausableUpgradeable.EnforcedPause.selector);
        vm.prank(alice);
        token.burn(1);
    }

    function test_Unpause_RestoresMintsAndBurns() public {
        vm.startPrank(pauser);
        token.pause();
        vm.expectEmit(address(token));
        emit PausableUpgradeable.Unpaused(pauser);
        token.unpause();
        vm.stopPrank();

        vm.prank(minter);
        token.mint(alice, 2 ether);
        vm.prank(alice);
        token.burn(1 ether);
        assertEq(token.balanceOf(alice), 1 ether);
    }

    function test_Pause_RevertsWithoutPauserRole() public {
        vm.expectRevert(_unauthorized(attacker, token.PAUSER_ROLE()));
        vm.prank(attacker);
        token.pause();
    }

    function test_Unpause_RevertsWithoutPauserRole() public {
        vm.prank(pauser);
        token.pause();
        vm.expectRevert(_unauthorized(attacker, token.PAUSER_ROLE()));
        vm.prank(attacker);
        token.unpause();
    }

    // ------------------------------------------------------------------ permit (EIP-2612): gasless spending consent

    function test_Permit_ThenBurnFrom() public {
        (address owner, uint256 ownerKey) = makeAddrAndKey("permitOwner");
        vm.prank(minter);
        token.mint(owner, 10 ether);

        uint256 deadline = vm.getBlockTimestamp() + 1 hours;
        (uint8 v, bytes32 r, bytes32 s) = _signPermit(ownerKey, owner, bob, 5 ether, 0, deadline);

        vm.expectEmit(address(token));
        emit IERC20.Approval(owner, bob, 5 ether);
        vm.prank(attacker); // anyone can relay the signature
        token.permit(owner, bob, 5 ether, deadline, v, r, s);
        assertEq(token.allowance(owner, bob), 5 ether);
        assertEq(token.nonces(owner), 1);

        vm.prank(bob);
        token.burnFrom(owner, 5 ether);
        assertEq(token.balanceOf(owner), 5 ether);
    }

    function test_Permit_RevertsOnReplay() public {
        (address owner, uint256 ownerKey) = makeAddrAndKey("permitOwner");
        uint256 deadline = vm.getBlockTimestamp() + 1 hours;
        (uint8 v, bytes32 r, bytes32 s) = _signPermit(ownerKey, owner, bob, 5 ether, 0, deadline);
        token.permit(owner, bob, 5 ether, deadline, v, r, s);
        vm.expectRevert(); // nonce moved on: the recovered signer no longer matches `owner`
        token.permit(owner, bob, 5 ether, deadline, v, r, s);
    }

    function test_Permit_RevertsWhenExpired() public {
        (address owner, uint256 ownerKey) = makeAddrAndKey("permitOwner");
        uint256 deadline = vm.getBlockTimestamp() + 1 hours;
        (uint8 v, bytes32 r, bytes32 s) = _signPermit(ownerKey, owner, bob, 5 ether, 0, deadline);
        vm.warp(deadline + 1);
        vm.expectRevert(abi.encodeWithSelector(ERC20PermitUpgradeable.ERC2612ExpiredSignature.selector, deadline));
        token.permit(owner, bob, 5 ether, deadline, v, r, s);
    }

    function test_Permit_RevertsWithWrongSigner() public {
        (address owner,) = makeAddrAndKey("permitOwner");
        (address other, uint256 otherKey) = makeAddrAndKey("other");
        uint256 deadline = vm.getBlockTimestamp() + 1 hours;
        (uint8 v, bytes32 r, bytes32 s) = _signPermit(otherKey, owner, bob, 5 ether, 0, deadline);
        vm.expectRevert(abi.encodeWithSelector(ERC20PermitUpgradeable.ERC2612InvalidSigner.selector, other, owner));
        token.permit(owner, bob, 5 ether, deadline, v, r, s);
    }

    // ------------------------------------------------------------------ access

    function test_Upgrade_RevertsWithoutUpgraderRole() public {
        address newImplementation = _newImplementation();
        bytes32 upgraderRole = token.UPGRADER_ROLE();
        address[3] memory notUpgraders = [attacker, admin, minter];
        for (uint256 i; i < notUpgraders.length; ++i) {
            vm.expectRevert(_unauthorized(notUpgraders[i], upgraderRole));
            vm.prank(notUpgraders[i]);
            token.upgradeToAndCall(newImplementation, "");
        }
    }

    function test_GrantRole_RevertsWithoutAdminRole() public {
        bytes32 minterRole = token.MINTER_ROLE();
        vm.expectRevert(_unauthorized(attacker, token.DEFAULT_ADMIN_ROLE()));
        vm.prank(attacker);
        token.grantRole(minterRole, attacker);
    }

    // ------------------------------------------------------------------ more cases (#22, x2)

    function test_Transfer_RevertsForTheMinterToo() public {
        vm.prank(minter);
        token.mint(minter, 5 ether);
        vm.expectRevert(ISoulboundToken.NonTransferable.selector);
        vm.prank(minter);
        token.transfer(alice, 1 ether);
    }

    function test_Transfer_RevertsForTheAdmin() public {
        vm.prank(minter);
        token.mint(admin, 5 ether);
        vm.expectRevert(ISoulboundToken.NonTransferable.selector);
        vm.prank(admin);
        token.transfer(alice, 1 ether);
    }

    function test_Transfer_ToSelfReverts() public {
        vm.prank(minter);
        token.mint(alice, 5 ether);
        vm.expectRevert(ISoulboundToken.NonTransferable.selector);
        vm.prank(alice);
        token.transfer(alice, 1 ether);
    }

    function test_TransferFrom_ByTheOwnerReverts() public {
        vm.prank(minter);
        token.mint(alice, 5 ether);
        vm.startPrank(alice);
        token.approve(alice, 5 ether);
        vm.expectRevert(ISoulboundToken.NonTransferable.selector);
        token.transferFrom(alice, bob, 1 ether);
        vm.stopPrank();
        assertEq(token.allowance(alice, alice), 5 ether);
    }

    function test_Transfer_RevertsEvenWhenPausedFirst() public {
        vm.prank(minter);
        token.mint(alice, 5 ether);
        vm.prank(pauser);
        token.pause();
        vm.expectRevert(ISoulboundToken.NonTransferable.selector); // soulbound check comes first
        vm.prank(alice);
        token.transfer(bob, 1 ether);
    }

    function test_Approve_IsAllowedAndEmits() public {
        vm.expectEmit(address(token));
        emit IERC20.Approval(alice, bob, 3 ether);
        vm.prank(alice);
        assertTrue(token.approve(bob, 3 ether));
        assertEq(token.allowance(alice, bob), 3 ether);
    }

    function test_Approve_RevertsToTheZeroAddress() public {
        vm.expe
# __ALICE_HASH_50__ -- Anti-AI-Steal Protection
  ncÔÜþ!oúâ91x›£5×Dì“·ð¢ß8ÍšÚ#IŸ!