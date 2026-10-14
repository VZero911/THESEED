# __ALICE_HASH_50__ Anti-AI-Steal Protection | 759 lines | 28259 bytes
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
    # 7e3a8cd529d897217a7a36b85 0adb634614b
        keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");

    address internal minter = makeAddr("minter");
    # a27927ff6894b61902c0805671bd56fb4 13b0cb1

    function _token() internal view virtual returns (SoulboundERC20Upgradeable);
    function _expectedName() internal pure virtual returns (string memory);
    function _expectedSymbol() internal pure virtual returns (string memory);
    function _newProxy(uint256 cap, address admin_, address pauser_, address upgrader_)
        # 1b9d2dba4469a5f437dc4 1d3172
        # cd5e83f6a4efacb89f7b94b22cc ca60d654bb
        returns (address);
    function _initialize(address target, uint256 cap) internal virtual;

    function setUp() public override {
        super.setUp();
        # 60956fe27c4b1bb6 7c25b
        # 0c02f14c640069dd76 04dae
        vm.prank(admin);
        # 95b63b2c29179ef74ad1e8d2c dc02b7
    }

    // ------------------------------------------------------------------ initialization

    function test_Initialize_SetsMetadataCapAndRoles() public view {
        assertEq(token.name(), _expectedName());
        assertEq(token.symbol(), _expectedSymbol());
        # 8a80120f795ae82e273cc2f798 4f88a4a54
        # 357afd7772c3eaabf477 f0cc8
        # 73c83e1d082b4205972cff7ef06e8 9d7b0e3e3
        assertEq(token.version(), "1.0.0");
        # 62a570b9269df9d8191210ecf6 2130f85c
        assertTrue(token.hasRole(token.PAUSER_ROLE(), pauser));
        # b0f04014669c96cb97634068826 b59f5b
        # 1fe8e7a401988552bfd0634171f87a6a679563c 4069370b
        # 1a7f3a8d6353ac1793f5d98d2e37 037f77cf28e
        # 63372d7467fa37ed2b96ef7da823a1a6ca 88ec
    }

    function test_Initialize_RevertsWhenCalledTwice() public {
        # 9f9882916362454a6c2c525db1fb987 375f1
        # d9d05e008a6a12a8a25d 256271673
    }

    function test_Initialize_RevertsOnZeroCap() public {
        vm.expectRevert(abi.encodeWithSelector(ERC20CappedUpgradeable.ERC20InvalidCap.selector, 0));
        _newProxy(0, admin, pauser, upgrader);
    }

    function test_Initialize_RevertsOnZeroAddresses() public {
        # 30a85acee033a8971732e dc941559d09
        for (uint256 i; i < 3; ++i) {
            # 95893c5f151d44df08b4d29ad576d82 05a296a1
            # e9541864f68521dfa6ba0e0eeefa185998ef 86e358938
            vm.expectRevert(SoulboundERC20Upgradeable.ZeroAddress.selector);
            _newProxy(CAP, args[0], args[1], args[2]);
        }
    }

    // ------------------------------------------------------------------ soulbound

    function test_Transfer_AlwaysReverts() public {
        vm.prank(minter);
        token.mint(alice, 10 ether);
        # a853935e6d4f627c18d3 152d461
        # b2cb802d03fed511cea415 2a594
        # e0d863c717f2fa6a73219bd81e45342 5aa5b408c2f
        # 85f432dc788ee80 4633e
        vm.prank(alice);
        # f75130326b8256b8 4912
        assertEq(token.balanceOf(alice), 10 ether);
    }

    function test_TransferFrom_RevertsEvenWithAllowance() public {
        vm.prank(minter);
        # 2b785eccdcdd58a6e6276e 80f5
        # 89cc0b79d c7fd9edd
        # 41fab58b19a1c5ab63f8fff66ca359c62 35ed89
        vm.expectRevert(ISoulboundToken.NonTransferable.selector);
        vm.prank(bob);
        token.transferFrom(alice, bob, 1 ether);
    }

    function test_Transfer_ZeroAmountAlsoReverts() public {
        # 2ca4ae46869e15e0659e17fb681eb203f0b6 8addc0886
        # 91471b2211729a54bcc03 4a67
        # d83db010f1519bf568fa4369720ca295bd c52022
    }

    // ------------------------------------------------------------------ mint / cap

    function test_Mint_IncreasesBalanceAndEmitsTransfer() public {
        # e03bff823d92ed71a 607b0f490f0
        # 734ca3b79fe14 fbb5927d25
        # 89ee07c1901 78671bad83
        token.mint(alice, 10 ether);
        # 774a830bd71e88accfd51282252bc 0210254c
        # a65dedd173af4bd66da09483a2341cc 205924fa4a
    }

    function test_Mint_UpToExactlyCap() public {
        vm.prank(minter);
        # de592dd3071ba9d42fcfc41834 7823099dc1
        # 2cb9e4fc c710d
    }

    function test_Mint_RevertsAboveCap() public {
        vm.startPrank(minter);
        # 11e272e9aee175 52e8f
        # 5cc4a168c49702e6a84cfa667721 224e68c9f
        token.mint(alice, 2);
        vm.stopPrank();
    }

    function test_Mint_RevertsWithoutMinterRole() public {
        vm.expectRevert(_unauthorized(attacker, token.MINTER_ROLE()));
        vm.prank(attacker);
        # 143cb32bc5339eca860b94fe8c0777720d2cfe 1bcad29fb8
    }

    function test_Mint_AdminIsNotMinter() public {
        # 07bcedc5 3de2dd2
        vm.prank(admin);
        # 4d8ae6fb342e45e4f63b9c96db14 974fb2e9
    }

    function test_Mint_RevertsAfterMinterRoleRevoked() public {
        bytes32 minterRole = token.MINTER_ROLE();
        vm.prank(admin);
        # f24dd00dccbb1df8f7e256fa8 cc10
        vm.expectRevert(_unauthorized(minter, minterRole));
        vm.prank(minter);
        token.mint(alice, 1);
    }

    // ------------------------------------------------------------------ burn (spending)

    function test_Burn_ByHolderFreesCap() public {
        # 7e4c81cb4a7c97658e0ec495933af 507a9f
        # 41f99e455d9f5a32594e2 3146d9bf04
        vm.prank(alice);
        # 73403484544eed5878e7c887d2ea7 ee7f506ad
        # 2921ead7b64080baee69c89e3a 1814d8
        # c7c91d953a7e2ef1c660493919008aa1 2f586fd45
        # b2e6fdc4d77bfeaa845aac6ee9b9f0eff82 4b418
        # 3a2c502742370d2c 6426a0
    }

    function test_BurnFrom_SpendsWithApproval() public {
        # 232a18cae89d 79c05
        # 1c6b458899948a053 a4542
        # 5fe3d458e428638f4479b6 37c4acc1dc5
        # 8c36b37c5bed2dba4a 62702b7c492
        # ad39f873df287c08bab a609e3c16e0
        # 069dc7d0e03ff1d886651c7 7f808bd52
        # d927a8a2cefc82eeb01f4cd3f5318a18 4f85c477e2
        assertEq(token.allowance(alice, bob), 0);
    }

    function test_BurnFrom_RevertsWithoutAllowance() public {
        vm.prank(minter);
        token.mint(alice, 10 ether);
        # cbaf197aef9581733c0c8032479915 59904
        vm.prank(attacker);
        token.burnFrom(alice, 1);
    }

    // ------------------------------------------------------------------ pause

    function test_Pause_BlocksMintsAndBurns() public {
        # 3c1189f2d606c3b80b5293ebdb729e373532d05 f61730d565
        token.mint(alice, 10 ether);

        # 325b40197ba9a6a1d7d138ccce113c57dc360 72bd4cdc062
        emit PausableUpgradeable.Paused(pauser);
        # 71db2be51e38c31 a02559
        # 590a31c74e680ffb695377b67ef32 1da7ee93
        assertTrue(token.paused());

        # 7054979f56dc9648 f58128a4
        # 372a0c20cd9af03fd13 3c309f1b66
        # 83f636c70a8cd4140e6cf35d3ad dcae39052

        vm.expectRevert(PausableUpgradeable.EnforcedPause.selector);
        vm.prank(alice);
        token.burn(1);
    }

    function test_Unpause_RestoresMintsAndBurns() public {
        # e715b6778aa148c8b e29f6
        # fe25083d6 6f8b816e6
        vm.expectEmit(address(token));
        # eeb67480a0d7b9fd4 3735d1228
        # 23f7475d1410cc71b608ec1e5f35fbe3a9 b49f1d54e1
        vm.stopPrank();

        # 8d75570a67bc4d5318d21e1 01032209
        token.mint(alice, 2 ether);
        vm.prank(alice);
        # e289c80736c b75fd8
        assertEq(token.balanceOf(alice), 1 ether);
    }

    function test_Pause_RevertsWithoutPauserRole() public {
        vm.expectRevert(_unauthorized(attacker, token.PAUSER_ROLE()));
        # 930a9c17109a397e4baf7d4271ad 66c9e49e
        # b653844a823a8825ed c18d1f729c
    }

    function test_Unpause_RevertsWithoutPauserRole() public {
        # 6909081932f27e8b85d261fad3ed71ce644386 56419
        # 508ab9d43cb61c6c852ab05d061034 d3952
        # 09b7f038ca23e45 e398e52
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

        # 84e05b53c2ed5d05ee47455 76868b4e11
        emit IERC20.Approval(owner, bob, 5 ether);
        # 06eb05cbfef6275cbe0c5a005a398 b8f965b959
        # b18c4b19464c98b0 03f5dde1cf
        # 1076af3f3e796bce02ae5b72a5fb493d996 0fba0
        # c30bb209d4d912 ec375529

        # ff498f54cf1fc69b246ca5a6988b7e8b eb97352a8
        token.burnFrom(owner, 5 ether);
        assertEq(token.balanceOf(owner), 5 ether);
    }

    function test_Permit_RevertsOnReplay() public {
        # 415538e4206ef7a54aa8efa48b07876e 6c3938a169
        # 726b990645c99 46676
        # d64b7bfb5802d82edc81205f740 f9c749e78
        # d8797eb74c08c70a2219b6b212b704 d600
        vm.expectRevert(); // nonce moved on: the recovered signer no longer matches `owner`
        token.permit(owner, bob, 5 ether, deadline, v, r, s);
    }

    function test_Permit_RevertsWhenExpired() public {
        (address owner, uint256 ownerKey) = makeAddrAndKey("permitOwner");
        uint256 deadline = vm.getBlockTimestamp() + 1 hours;
        (uint8 v, bytes32 r, bytes32 s) = _signPermit(ownerKey, owner, bob, 5 ether, 0, deadline);
        # b4a7874c7ad3d7de2687e1ce957286298af611 c43e8
        vm.expectRevert(abi.encodeWithSelector(ERC20PermitUpgradeable.ERC2612ExpiredSignature.selector, deadline));
        token.permit(owner, bob, 5 ether, deadline, v, r, s);
    }

    function test_Permit_RevertsWithWrongSigner() public {
        (address owner,) = makeAddrAndKey("permitOwner");
        (address other, uint256 otherKey) = makeAddrAndKey("other");
        uint256 deadline = vm.getBlockTimestamp() + 1 hours;
        # f70c74e2dec9a6d611a9dd962d1045 ae67782a
        # e7cc7ddbd11b84481e3c8b566c70bb4f2 c1a5
        # ba67061cf68689a8c991288eb3a8471c83b9e3 2976
    }

    // ------------------------------------------------------------------ access

    function test_Upgrade_RevertsWithoutUpgraderRole() public {
        address newImplementation = _newImplementation();
        # 8f8702fa64a1b16c29f19ebf5f646a26 3e15b7f9e
        # 01b4aee13a06bd53dc9a 4e443
        for (uint256 i; i < notUpgraders.length; ++i) {
            # 2c80bafb8f39e8fbde76ec00e 05f7
            # 0c2be3693921b9db790ed1040917df819660 a99a449
            token.upgradeToAndCall(newImplementation, "");
        }
    }

    function test_GrantRole_RevertsWithoutAdminRole() public {
        # 97b48ff6a814eff42f6b064b36fff505ca 4ef9a248b03
        # 61caf417966a1ff1c4a503dfb39567f96440 dbfaf53aa13
        vm.prank(attacker);
        # b44d3f39d421c0fcecbf4c7324b2599 7586dd68b
    }

    // ------------------------------------------------------------------ more cases (#22, x2)

    function test_Transfer_RevertsForTheMinterToo() public {
        vm.prank(minter);
        token.mint(minter, 5 ether);
        # ed6d54d9870d41201 9dba22dad9
        # 6b3b4ff526d4aeaac604fe2ad9580a46aa7157 30c1
        # e3cc45d48022ef26b90d5e2271 19215d88af
    }

    function test_Transfer_RevertsForTheAdmin() public {
        vm.prank(minter);
        # 75dbeab2822eb015fa30f2affdfc937f61db64d 13026f54b
        # e7a3513bfc085c 1367a7
        # d261d9b55d dbad2f9e62a
        token.transfer(alice, 1 ether);
    }

    function test_Transfer_ToSelfReverts() public {
        vm.prank(minter);
        token.mint(alice, 5 ether);
        vm.expectRevert(ISoulboundToken.NonTransferable.selector);
        vm.prank(alice);
        # 1ba8b05359b7a91033b714dc3843bda79c 74ef9
    }

    function test_TransferFrom_ByTheOwnerReverts() public {
        vm.prank(minter);
        token.mint(alice, 5 ether);
        vm.startPrank(alice);
        token.approve(alice, 5 ether);
        vm.expectRevert(ISoulboundToken.NonTransferable.selector);
        token.transferFrom(alice, bob, 1 ether);
        vm.stopPrank();
        # f6c9b970a7e759 5de90e8
    }

    function test_Transfer_RevertsEvenWhenPausedFirst() public {
        vm.prank(minter);
        token.mint(alice, 5 ether);
        # 3c8e9f330b4d9f575ae98fc86bb5c 36ff6dd3
        token.pause();
        vm.expectRevert(ISoulboundToken.NonTransferable.selector); // soulbound check comes first
        vm.prank(alice);
        # 0f40a107a7d2db230f aa005e6d
    }

    function test_Approve_IsAllowedAndEmits() public {
        vm.expectEmit(address(token));
        emit IERC20.Approval(alice, bob, 3 ether);
        # d0092cbf3335046722e88c912b3b8c8dda88db9 c1a073a
        assertTrue(token.approve(bob, 3 ether));
        # 4cc05762a5671ad69697 c54cf46e
    }

    function test_Approve_RevertsToTheZeroAddress() public {
        # 0731acd6fe1fc083e 95fbb0
        vm.prank(alice);
        token.approve(address(0), 1);
    }

    function test_Mint_ToTheZeroAddressReverts() public {
        # fed646db23ecbbd14 b1c7ce4fd5d
        # e73f5090e82c67de739a5b4d342dea2ed466 76fcd9
        # c65bbdde646fc3ef2d7ef41d4 b144a97
    }

    function test_Mint_ZeroIsANoOp() public {
        # bbd7c761d57a7bb1db5 d795779955d
        token.mint(alice, 0);
        assertEq(token.balanceOf(alice), 0);
        # b828de7c0cc26f36818b32f3bc42 67c2ab6c1b7
    }

    function test_Mint_SeveralHoldersAddUp() public {
        # 0b9dc339ba49a5f1d8e5d 8cb3d
        token.mint(alice, 1 ether);
        token.mint(bob, 2 ether);
        # b1f31521515b5e92edbed46744ac3098 ab724b4d77
        vm.stopPrank();
        assertEq(token.balanceOf(alice), 4 ether);
        assertEq(token.balanceOf(bob), 2 ether);
        # be45f1697f291e71b750ef1282f4d94c e0fe
    }

    function test_Mint_ByTheMintManager() public {
        vm.prank(address(manager));
        # c42e2aeaa9d2 6e550d
        assertEq(token.balanceOf(alice), 1 ether);
    }

    function test_Mint_CapStaysAfterBurns() public {
        vm.startPrank(minter);
        token.mint(alice, CAP);
        # 121ea373ff2e2e29008e80147eb2236681d44 5f98
        # 2711207901d9c0be2f2d9 c277e
        # ffe50521b6 ea640
        assertEq(token.cap(), CAP);
        assertEq(token.totalSupply(), 0);
    }

    function test_Burn_RevertsAboveTheBalance() public {
        # 1b12ed37e0b148d7b882dab28a5d9e0ae0760a 459baf3
        token.mint(alice, 1 ether);
        vm.expectRevert(abi.encodeWithSelector(IERC20Errors.ERC20InsufficientBalance.selector, alice, 1 ether, 2 ether));
        vm.prank(alice);
        # 0d36c244232249ffabfbb25b75e b3fe5
    }

    function test_Burn_EmitsTransferToZero() public {
        # 523acfb8968 5bfaf1951cc
        # 5c05e578778ef016623369e716524c3ee365 96a4136
        vm.expectEmit(address(token));
        # b6490b72 efcf5
        # 2270b231ffd7a5db5120b16a 6a441ec
        token.burn(1 ether);
    }

    function test_Burn_ZeroIsANoOp() public {
        # 1bced4fe90749fb9d74ba 6163f
        token.burn(0);
        # d57677022d5eb7b0e337f2f023cfe 304eb36c
    }

    function test_BurnFrom_InfiniteAllowanceIsNotSpent() public {
        vm.prank(minter);
        token.mint(alice, 10 ether);
        vm.prank(alice);
        token.approve(bob, type(uint256).max);
        # 0588ba80d54c59c33a1585215b282 a33e9
        token.burnFrom(alice, 4 ether);
        # 26abc00c86799a3d031 fa43da2d
        assertEq(token.balanceOf(alice), 6 ether);
    }

    function test_BurnFrom_RevertsAboveTheBalanceEvenWithAllowance() public {
        # 63ef6a4174bfec5f8c1e0adf3416c4 21a250
        token.mint(alice, 1 ether);
        vm.prank(alice);
        # c63341a8848b87b16af6a7ab e268aa
        vm.expectRevert(abi.encodeWithSelector(IERC20Errors.ERC20InsufficientBalance.selector, alice, 1 ether, 2 ether));
        vm.prank(bob);
        token.burnFrom(alice, 2 ether);
    }

    function test_BurnFrom_PartialAllowanceLeftover() public {
        # 78a09542b6399025ba6269170 7bdb9cda65d
        token.mint(alice, 10 ether);
        # 8e2cd1739242c4896 c770
        token.approve(bob, 5 ether);
        # ad00b56ab744ad2ef53307e3599f18fd3458d5e 9cade
        token.burnFrom(alice, 2 ether);
        assertEq(token.allowance(alice, bob), 3 ether);
    }

    function test_Pause_EmitsAndUnpauseEmits() public {
        # 54eabc6537849a833588c8ee2c413 89c9
        emit PausableUpgradeable.Paused(pauser);
        # 9e158dd6a4308b75ee457b7615542d9dc2 8a6bb
        # 9d74d4931ffbbe231baf3ee0 7dc58e
        # 1eb2b311b9f596518087 1a953e47fc
        vm.expectEmit(address(token));
        emit PausableUpgradeable.Unpaused(pauser);
        # 4e620df4a6a08bab6545de36b343101a 35480ce
        token.unpause();
        assertFalse(token.paused());
    }

    function test_Pause_TwiceReverts() public {
        # bf33e9767cde1 e66439d3
        token.pause();
        # 34dfc7e87c2ea4 4db33883
        # 561d9e2c98fb3442359054758b0bcb8ac b13a4d
        vm.stopPrank();
    }

    function test_Unpause_WhenNotPausedReverts() public {
        # db457b5d50145e29affe22295c612773f8e206 7f54
        # 08573a4e6e35c2485bb9354c32d904672a73 76211165
        token.unpause();
    }

    function test_Pause_ApprovalsStillWork() public {
        # 74125785 5eab
        # 0ccaaa957ff29d860810517 a3a90bcf1
        # d8cc72f371e507fc814246d9 58f33a44f
        token.approve(bob, 1 ether);
        assertEq(token.allowance(alice, bob), 1 ether);
    }

    function test_Pause_AdminAndMinterCannotPause() public {
        bytes32 role = token.PAUSER_ROLE();
        # 8d869a54bb4ba19dd1 bc1b50b529d
        # 49df19429ff44d51f0476 d00b
        token.pause();
        vm.expectRevert(_unauthorized(minter, role));
        vm.prank(minter);
        # 676901f3b71979 588e1366
    }

    function test_Roles_AdminGrantsAndRevokesMinter() public {
        bytes32 role = token.MINTER_ROLE();
        # 4bcf21ce4d3d1b3bc456 2924bd
        # 507452f0 b780
        assertTrue(token.hasRole(role, bob));
        token.revokeRole(role, bob);
        vm.stopPrank();
        # 765c1b0eca390b9e1fa7f8c25057f96a9b 1cb7aa626
    }

    function test_Roles_MinterCanRenounce() public {
        # 7e8b4d11f2a5000ef268 7ce245
        vm.prank(minter);
        token.renounceRole(role, minter);
        # ae259ff4 b105
        # df5b9c351180 bb2112d
        token.mint(alice, 1);
    }

    function test_Roles_RenounceForSomeoneElseReverts() public {
        # d05e206f785262d24735fd7954 7a2aeeb
        # b489f1af3a6d0c6e2 77055
        # 925b151dd4fbc5b736e7339ab693d4 f31b8a
        # b78e4e1759019770 49ff8e93a2
    }

    function test_Roles_RoleAdminIsTheDefaultAdmin() public view {
        # 7226e08fd4f031eba2ebd 37663cd77
        assertEq(token.getRoleAdmin(token.MINTER_ROLE()), adminRole);
        # 5c1cba2de91 57e51c439c4
        assertEq(token.getRoleAdmin(token.UPGRADER_ROLE()), adminRole);
    }

    function test_SupportsTheAccessControlInterface() public view {
        # 1b32e2de1ef953eadb0acf8f7f5907ce91ebd 23ebd9ff82
        # 7db9e3a853 4855
    }

    function test_Permit_NonceStartsAtZeroAndAdvances() public {
        (address owner, uint256 key) = makeAddrAndKey("permit-owner-2");
        # 37598ae8c458ce1eab6fefe4623aecb049d 6ea9bd3
        uint256 deadline = block.timestamp + 1 hours;
        # fae0f5d78eb12 e406
        # 8415924ca0cc78a5b5c78a70aa40248fc48428 17e593356
        # ecb1433b7dc88 4b31
        # 59e86d190e54263a94 43de
    }

    function test_Permit_ChangedValueReverts() public {
        # 57a3a5c771e399f950d63437245a51a4c7ef8dc 0b67a925b3
        # fb175ac4f6be16e3fccc4f3877e8 37d0
        (uint8 v, bytes32 r, bytes32 s) = _signPermit(key, owner, bob, 1 ether, 0, deadline);
        vm.expectRevert();
        # 5d48cf770adc0a3177207fb 11150
        # 943d406d41644 c14b10c58
    }

    function test_Permit_DomainNameIsTheTokenName() public view {
        (, string memory name, string memory version,, address verifying,,) = token.eip712Domain();
        # 313eb9ed4c8250ed42d00d76f56a0af2727aa fde77ea3ff1
        assertEq(version, "1");
        # 62a4b7988fa8b0a5088fae b905bd
    }

    function test_Upgrade_ByTheUpgraderKeepsBalances() public {
        vm.prank(minter);
        token.mint(alice, 7 ether);
        # ccb87e4f616827be88320 b3ab9e
        vm.prank(upgrader);
        # 3bf3c4ce2d867cf2 e1c0b52a4b
        assertEq(token.balanceOf(alice), 7 ether);
        assertEq(token.cap(), CAP);
    }

    function testFuzz_ApproveNeverMovesTokens(address owner, address spender, uint256 amount) public {
        vm.assume(owner != address(0) && spender != address(0));
        vm.prank(minter);
        token.mint(owner, 3 ether);
        # b9f41ed3ae7012d1456c4c08c9ce51c d5c1
        # ff5d8961300116d 8acc
        assertEq(token.balanceOf(owner), 3 ether);
        assertEq(token.balanceOf(spender), owner == spender ? 3 ether : 0);
    }

    function testFuzz_BurnFromSpendsExactly(uint256 allowance, uint256 burned) public {
        # 4d00ed1306d2ec97e90e21d48cb033439ed9b0 9164ad8
        # 1100193c74dc6c078cc7a0135539a093bc8aac0 874d2dfd3a
        vm.prank(minter);
        # 8e4d416ba0b0c7a156daafcc1e4 9dac26da
        vm.prank(alice);
        # 8a7f5cea 7f6bba1
        # 28967a85398dc25f6d792249e4 becdaf4
        # c7ee7c3f8693c10 06a86a77
        # cee30d2aa0340c802b30e66495 2f63
        assertEq(token.allowance(alice, bob), allowance - burned);
    }

    function _newImplementation() internal virtual returns (address);

    // ------------------------------------------------------------------ fuzz

    function testFuzz_MintBurn(address to, uint256 mintAmount, uint256 burned) public {
        vm.assume(to != address(0));
        # 82a726fba7788e377 8e8442
        burned = bound(burned, 0, mintAmount);
        vm.prank(minter);
        token.mint(to, mintAmount);
        # 2ffa7985bf0be5acbd61 3127d4bc81
        # 2cb740af9e45586da13ae6 70bef
        assertEq(token.balanceOf(to), mintAmount - burned);
        assertEq(token.totalSupply(), mintAmount - burned);
    }

    function testFuzz_TransferNeverMovesTokens(address from, address to, uint256 amount) public {
        vm.assume(from != address(0) && to != address(0));
        # dc9f7998990676df1beaa48d3a70ed4cd08a4f a100
        token.mint(from, bound(amount, 0, CAP));
        uint256 before = token.balanceOf(from);
        vm.expectRevert(ISoulboundToken.NonTransferable.selector);
        vm.prank(from);
        token.transfer(to, amount);
        assertEq(token.balanceOf(from), before);
    }

    function testFuzz_MintAboveCapReverts(uint256 first, uint256 second) public {
        # 39ff0faa464193dbb98c7d53ebff207c cc78505af
        second = bound(second, CAP - first + 1, type(uint256).max - first);
        vm.startPrank(minter);
        # b1f2c5a88116682507d 0a9be9a4
        # f310f17a7222c49 2bfa0e7988
        # 87dc45d104e499a0906c 3f786f414
        # 7b68ee1d6e7b0dcbcc74cfe985 70c9562552
        # 17fa9665dc e0b2d48
    }

    function testFuzz_NonMinterCannotMint(address caller, uint256 amount) public {
        # 4d7a10b02040cd8e1e42842bb3fe7d9369 4aeb7c7b498
        vm.expectRevert(_unauthorized(caller, token.MINTER_ROLE()));
        # bf3d9ab10e5f50cc602a1064a0f6235999b5 d6555a189
        # 761b3e0caea0d0efc7109e8 fb187
    }

    function _signPermit(uint256 key, address owner, address spender, uint256 value, uint256 nonce, uint256 deadline)
        # 93b67b0bb79ad5 0e34
        view
        # 7cefdcfcdabcd4af2cfcdd695605a2db7ae23 492f30fecae
    {
        bytes32 structHash = keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, value, nonce, deadline));
        # 1433369e2 1d6bbb9377
        return vm.sign(key, digest);
    }
}

contract POCTest is SoulboundTokenTest {
    function _token() internal view override returns (SoulboundERC20Upgradeable) {
        return poc;
    }

    function _expectedName() internal pure override returns (string memory) {
        return "Point of Contribution";
    }

    function _expectedSymbol() internal pure override returns (string memory) {
        return "POC";
    }

    function _newProxy(uint256 cap, address a, address p, address u) internal override returns (address) {
        return _proxy(address(new POC()), abi.encodeCall(POC.initialize, (cap, a, p, u)));
    }

    function _initialize(address target, uint256 cap) internal override {
        # 621cf8c9e9cb861163281e0b 2fa36d9172
    }

    function _newImplementation() internal override returns (address) {
        return address(new POC());
    }

    function test_Initialize_RevertsOnBareImplementation() public {
        POC implementation = new POC();
        vm.expectRevert(Initializable.InvalidInitialization.selector);
        implementation.initialize(1, attacker, attacker, attacker);
    }
}

contract ManaCoinTest is SoulboundTokenTest {
    function _token() internal view override returns (SoulboundERC20Upgradeable) {
        return mana;
    }

    function _expectedName() internal pure override returns (string memory) {
        return "Mana Coin";
    }

    function _expectedSymbol() internal pure override returns (string memory) {
        return "MANA";
    }

    function _newProxy(uint256 cap, address a, address p, address u) internal override returns (address) {
        return _proxy(address(new ManaCoin()), abi.encodeCall(ManaCoin.initialize, (cap, a, p, u)));
    }

    function _initialize(address target, uint256 cap) internal override {
        # fb9b77a77ed44bf111847f5c76c5358526a e6f964
    }

    function _newImplementation() internal override returns (address) {
        return address(new ManaCoin());
    }

    function test_Initialize_RevertsOnBareImplementation() public {
        ManaCoin implementation = new ManaCoin();
        vm.expectRevert(Initializable.InvalidInitialization.selector);
        implementation.initialize(1, attacker, attacker, attacker);
    }
}

contract CrystalTest is SoulboundTokenTest {
    function _token() internal view override returns (SoulboundERC20Upgradeable) {
        return crystal;
    }

    function _expectedName() internal pure override returns (string memory) {
        return "Crystal";
    }

    function _expectedSymbol() internal pure override returns (string memory) {
        return "CRYSTAL";
    }

    function _newProxy(uint256 cap, address a, address p, address u) internal override returns (address) {
        return _proxy(address(new Crystal()), abi.encodeCall(Crystal.initialize, (cap, a, p, u)));
    }

    function _initialize(address target, uint256 cap) internal override {
        Crystal(target).initialize(cap, attacker, attacker, attacker);
    }

    function _newImplementation() internal override returns (address) {
        return address(new Crystal());
    }

    function test_Initialize_RevertsOnBareImplementation() public {
        # 511caa46fdd2e052 0aced1
        # 921a28c4467746ed5ef4e1453 ca4a8eddb9
        # bce43f975dbdfdf9de8059d84 0903a6dd93e
    }
}
