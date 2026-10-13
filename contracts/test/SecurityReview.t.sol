// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {IAccessControl} from "@openzeppelin/contracts/access/IAccessControl.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";

import {IMarketplace} from "../src/interfaces/IMarketplace.sol";
import {Achievements} from "../src/Achievements.sol";
import {MintManager} from "../src/MintManager.sol";
import {IMintManager} from "../src/interfaces/IMintManager.sol";
import {Names} from "../src/Names.sol";
import {Polls} from "../src/Polls.sol";
import {Roles} from "../src/Roles.sol";
import {Skins} from "../src/Skins.sol";
import {ISkins} from "../src/interfaces/ISkins.sol";
import {ISoulboundToken} from "../src/interfaces/ISoulboundToken.sol";
import {MarketFixture} from "./utils/MarketFixture.sol";

/// @notice Expert review of every entry point (dev-toolkit-chain). Each test pins a behaviour found in the review:
///         the guards that hold (access, replay, bounds) and the known weaknesses (named `Finding_`), so a later fix
///         changes a test on purpose. The findings are tracked in agents/backlog.json (`sec-chain-*`).
contract SecurityReviewTest is MarketFixture {
    uint256 internal constant FAR = 4_102_444_800; // year 2100
    Names internal names;
    Roles internal roles;
    Polls internal polls;
    Skins internal skins;
    Achievements internal achievements;

    uint256 internal aliceKey;
    address internal player;

    function setUp() public override {
        super.setUp();
        names = Names(_proxy(address(new Names()), abi.encodeCall(Names.initialize, (admin, upgrader))));
        roles = Roles(_proxy(address(new Roles()), abi.encodeCall(Roles.initialize, (admin, upgrader))));
        polls = Polls(_proxy(address(new Polls()), abi.encodeCall(Polls.initialize, (admin, upgrader))));
        skins = Skins(
            _proxy(
                address(new Skins()), abi.encodeCall(Skins.initialize, ("http://x/", admin, metadataManager, upgrader))
            )
        );
        achievements = Achievements(
            _proxy(address(new Achievements()), abi.encodeCall(Achievements.initialize, (admin, upgrader)))
        );
        (player, aliceKey) = makeAddrAndKey("player");
        vm.startPrank(admin);
        names.grantRole(names.OPERATOR_ROLE(), operator);
        roles.grantRole(roles.OPERATOR_ROLE(), operator);
        roles.grantRole(roles.CATALOG_ROLE(), admin);
        polls.grantRole(polls.OPERATOR_ROLE(), operator);
        skins.grantRole(skins.MINTER_ROLE(), operator);
        achievements.grantRole(achievements.OPERATOR_ROLE(), operator);
        vm.stopPrank();
    }

    // ---------------------------------------------------------------- MintManager: access and emission

    function test_Mint_EveryEntryPointIsOperatorOnly() public {
        vm.startPrank(attacker);
        bytes memory denied = _unauthorized(attacker, manager.OPERATOR_ROLE());
        vm.expectRevert(denied);
        manager.mintPoc(attacker, 1);
        vm.expectRevert(denied);
        manager.mintMana(attacker, 1);
        vm.expectRevert(denied);
        manager.mintCrystal(attacker, 1);
        vm.expectRevert(denied);
        manager.mintPot(attacker, 1);
        vm.expectRevert(denied);
        manager.mintMonster(attacker);
        uint256[] memory ids = new uint256[](1);
        vm.expectRevert(denied);
        manager.burnMonsters(attacker, ids, block.timestamp + 1, "");
        vm.stopPrank();
    }

    function test_Mint_AdminFunctionsAreAdminOnly() public {
        bytes memory denied = _unauthorized(attacker, manager.DEFAULT_ADMIN_ROLE());
        vm.startPrank(attacker);
        vm.expectRevert(denied);
        manager.setEpochBudget(address(pot), 1);
        vm.expectRevert(denied);
        manager.setEpochDuration(1);
        vm.stopPrank();
    }

    function test_Mint_OperatorCannotGoOverTheEpochBudget() public {
        vm.startPrank(operator);
        manager.mintPoc(alice, POC_BUDGET);
        vm.expectRevert();
        manager.mintPoc(alice, 1);
        vm.stopPrank();
    }

    function test_Mint_BudgetResetsAtTheEpochBoundary() public {
        vm.prank(operator);
        manager.mintPoc(alice, POC_BUDGET);
        vm.warp(block.timestamp + EPOCH_DURATION);
        vm.prank(operator);
        manager.mintPoc(alice, POC_BUDGET);
        assertEq(poc.balanceOf(alice), 2 * POC_BUDGET);
    }

    function test_Mint_AdminCanFreezeATokenWithABudgetOfZero() public {
        vm.prank(admin);
        manager.setEpochBudget(address(poc), 0);
        vm.prank(operator);
        vm.expectRevert();
        manager.mintPoc(alice, 1);
    }

    function test_Mint_UnknownTokenBudgetIsRefused() public {
        vm.prank(admin);
        vm.expectRevert();
        manager.setEpochBudget(attacker, 5);
        vm.prank(admin);
        vm.expectRevert();
        manager.setEpochBudget(address(0), 5);
    }

    function test_Mint_ZeroAmountIsRefused() public {
        vm.prank(operator);
        vm.expectRevert();
        manager.mintPot(alice, 0);
    }

    function test_Finding_MonsterMintHasNoEpochBudget() public {
        // sec-chain-monster-mint-cap: a leaked operator key mints without limit; only POC/MANA/CRYSTAL/POT are budgeted.
        vm.startPrank(operator);
        for (uint256 i; i < 300; ++i) {
            manager.mintMonster(alice);
        }
        vm.stopPrank();
        assertEq(monster.balanceOf(alice), 300);
    }

    function test_Finding_AFrozenBudgetDoesNotStopMonsterMinting() public {
        vm.startPrank(admin);
        manager.setEpochBudget(address(poc), 0);
        manager.setEpochBudget(address(pot), 0);
        vm.stopPrank();
        vm.prank(operator);
        manager.mintMonster(alice); // there is no kill switch for monsters on the manager
        assertEq(monster.balanceOf(alice), 1);
    }

    function test_Finding_AHugeEpochDurationIsRefused() public {
        // sec-chain-catalog-bounds: setEpochDuration is capped at one year (a typo used to freeze emission for good).
        vm.startPrank(admin);
        vm.expectRevert(abi.encodeWithSelector(IMintManager.EpochDurationTooLong.selector, uint256(365 days) + 1));
        manager.setEpochDuration(365 days + 1);
        vm.expectRevert(abi.encodeWithSelector(IMintManager.EpochDurationTooLong.selector, type(uint128).max));
        manager.setEpochDuration(type(uint128).max);
        manager.setEpochDuration(365 days); // the cap itself is fine
        vm.stopPrank();
        assertEq(manager.epochDuration(), 365 days);
    }

    function test_Mint_ZeroEpochDurationIsRefused() public {
        vm.prank(admin);
        vm.expectRevert(IMintManager.InvalidEpochDuration.selector);
        manager.setEpochDuration(0);
    }

    // ---------------------------------------------------------------- MintManager: signed burns

    function _burnSig(address who, uint256 key, uint256[] memory ids, uint256 deadline)
        internal
        view
        returns (bytes memory)
    {
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(key, manager.burnDigest(who, ids, deadline));
        return abi.encodePacked(r, s, v);
    }

    function _one(uint256 id) internal pure returns (uint256[] memory a) {
        a = new uint256[](1);
        a[0] = id;
    }

    function test_Burn_NeedsTheOwnersSignature() public {
        uint256 id = _mint(player);
        (, uint256 wrongKey) = makeAddrAndKey("wrong");
        uint256[] memory ids = _one(id);
        bytes memory sig = _burnSig(player, wrongKey, ids, block.timestamp + 1 hours);
        vm.prank(operator);
        vm.expectRevert(MintManager.InvalidBurnSignature.selector);
        manager.burnMonsters(player, ids, block.timestamp + 1 hours, sig);
        assertEq(monster.ownerOf(id), player);
    }

    function test_Burn_SignatureCoversTheTokenList() public {
        uint256 a = _mint(player);
        uint256 b = _mint(player);
        bytes memory sig = _burnSig(player, aliceKey, _one(a), block.timestamp + 1 hours);
        vm.prank(operator);
        vm.expectRevert(MintManager.InvalidBurnSignature.selector);
        manager.burnMonsters(player, _one(b), block.timestamp + 1 hours, sig);
    }

    function test_Burn_SignatureCoversTheDeadline() public {
        uint256 a = _mint(player);
        bytes memory sig = _burnSig(player, aliceKey, _one(a), block.timestamp + 1 hours);
        vm.prank(operator);
        vm.expectRevert(MintManager.InvalidBurnSignature.selector);
        manager.burnMonsters(player, _one(a), block.timestamp + 2 hours, sig);
    }

    function test_Burn_WorksOnceAndCannotBeReplayed() public {
        uint256 a = _mint(player);
        uint256 deadline = block.timestamp + 1 hours;
        bytes memory sig = _burnSig(player, aliceKey, _one(a), deadline);
        vm.prank(operator);
        manager.burnMonsters(player, _one(a), deadline, sig);
        assertEq(manager.burnNonce(player), 1);
        vm.prank(operator);
        vm.expectRevert(MintManager.InvalidBurnSignature.selector);
        manager.burnMonsters(player, _one(a), deadline, sig);
    }

    function test_Burn_ExpiredSignatureIsRefused() public {
        uint256 a = _mint(player);
        uint256 deadline = block.timestamp + 1 hours;
        bytes memory sig = _burnSig(player, aliceKey, _one(a), deadline);
        vm.warp(deadline + 1);
        vm.prank(operator);
        vm.expectRevert(abi.encodeWithSelector(MintManager.BurnExpired.selector, deadline));
        manager.burnMonsters(player, _one(a), deadline, sig);
    }

    function test_Burn_EmptyAndOversizedBatchesAreRefused() public {
        vm.startPrank(operator);
        vm.expectRevert(MintManager.EmptyBurn.selector);
        manager.burnMonsters(player, new uint256[](0), block.timestamp + 1, "");
        vm.expectRevert(abi.encodeWithSelector(MintManager.BurnBatchTooLarge.selector, 101));
        manager.burnMonsters(player, new uint256[](101), block.timestamp + 1, "");
        vm.stopPrank();
    }

    function test_Burn_AMonsterOfSomeoneElseIsRefusedEvenWithAValidSignature() public {
        uint256 mine = _mint(player);
        uint256 theirs = _mint(bob);
        uint256[] memory ids = new uint256[](2);
        ids[0] = mine;
        ids[1] = theirs;
        uint256 deadline = block.timestamp + 1 hours;
        bytes memory sig = _burnSig(player, aliceKey, ids, deadline);
        vm.prank(operator);
        vm.expectRevert(abi.encodeWithSelector(MintManager.NotMonsterOwner.selector, theirs, player));
        manager.burnMonsters(player, ids, deadline, sig);
        assertEq(monster.ownerOf(mine), player); // the whole call reverted
    }

    function test_Burn_SignatureDoesNotWorkOnAnotherChain() public {
        uint256 a = _mint(player);
        uint256 deadline = block.timestamp + 1 hours;
        bytes memory sig = _burnSig(player, aliceKey, _one(a), deadline);
        vm.chainId(block.chainid + 1);
        vm.prank(operator);
        vm.expectRevert(MintManager.InvalidBurnSignature.selector);
        manager.burnMonsters(player, _one(a), deadline, sig);
    }

    function test_Burn_AMonsterOnSaleCannotBeBurned() public {
        (, uint256 id) = _listFixed(100 ether); // owned by the marketplace while listed
        uint256 deadline = block.timestamp + 1 hours;
        bytes memory sig = _burnSig(seller, sellerKey, _one(id), deadline);
        vm.prank(operator);
        vm.expectRevert(abi.encodeWithSelector(MintManager.NotMonsterOwner.selector, id, seller));
        manager.burnMonsters(seller, _one(id), deadline, sig);
    }

    function test_Finding_ABurnSignatureCannotBeRevoked() public {
        // sec-chain-nonce-revoke: the owner has no function to cancel a signed burn before its deadline.
        uint256 a = _mint(player);
        uint256 deadline = block.timestamp + 7 days;
        bytes memory sig = _burnSig(player, aliceKey, _one(a), deadline);
        vm.prank(player);
        monster.transferFrom(player, bob, a);
        vm.prank(bob);
        monster.transferFrom(bob, player, a); // the monster comes back to the signer
        vm.prank(operator);
        manager.burnMonsters(player, _one(a), deadline, sig); // the old signature still burns it
        vm.expectRevert();
        monster.ownerOf(a);
    }

    // ---------------------------------------------------------------- Monster, soulbound tokens, items

    function test_Monster_EscrowAndBurnRolesAreNotOpen() public {
        uint256 id = _mint(player);
        vm.startPrank(attacker);
        vm.expectRevert(_unauthorized(attacker, monster.ESCROW_ROLE()));
        monster.escrow(player, id);
        vm.expectRevert(_unauthorized(attacker, monster.BURNER_ROLE()));
        monster.burnFor(id);
        vm.expectRevert(_unauthorized(attacker, monster.MINTER_ROLE()));
        monster.safeMint(attacker);
        vm.stopPrank();
        assertEq(monster.ownerOf(id), player);
    }

    function test_Monster_ImplementationCannotBeInitialized() public {
        // the proxy is initialized; the bare implementation is locked
        address impl = _implementationOf(address(monster));
        vm.expectRevert();
        Monsterish(impl).initialize("a", "b", "c", attacker, attacker, attacker);
    }

    function test_Monster_UpgradeIsUpgraderOnly() public {
        vm.expectRevert(_unauthorized(attacker, monster.UPGRADER_ROLE()));
        vm.prank(attacker);
        monster.upgradeToAndCall(address(1), "");
    }

    function test_Soulbound_NoTransferNoApprovalPath() public {
        vm.prank(operator);
        manager.mintPoc(alice, 10 ether);
        vm.prank(alice);
        vm.expectRevert(ISoulboundToken.NonTransferable.selector);
        poc.transfer(bob, 1);
        vm.prank(alice);
        poc.approve(bob, 5 ether);
        vm.prank(bob);
        vm.expectRevert(ISoulboundToken.NonTransferable.selector);
        poc.transferFrom(alice, bob, 1);
    }

    function test_Soulbound_OwnerMayBurnItsOwnBalance() public {
        vm.prank(operator);
        manager.mintMana(alice, 10 ether);
        vm.prank(alice);
        mana.burn(4 ether);
        assertEq(mana.balanceOf(alice), 6 ether);
    }

    function test_Soulbound_MintOnlyByTheManager() public {
        vm.expectRevert(_unauthorized(attacker, poc.MINTER_ROLE()));
        vm.prank(attacker);
        poc.mint(attacker, 1);
        vm.expectRevert(_unauthorized(attacker, crystal.MINTER_ROLE()));
        vm.prank(attacker);
        crystal.mint(attacker, 1);
    }

    function test_Soulbound_PausedTokenStopsMints() public {
        vm.prank(pauser);
        poc.pause();
        vm.prank(operator);
        vm.expectRevert();
        manager.mintPoc(alice, 1);
    }

    function test_Soulbound_OnlyThePauserPauses() public {
        vm.expectRevert(_unauthorized(attacker, poc.PAUSER_ROLE()));
        vm.prank(attacker);
        poc.pause();
    }

    function test_Items_OnlyMinterMints() public {
        vm.expectRevert(_unauthorized(attacker, items.MINTER_ROLE()));
        vm.prank(attacker);
        items.mint(attacker, 1, 1, "");
        uint256[] memory ids = new uint256[](1);
        uint256[] memory amounts = new uint256[](1);
        vm.expectRevert(_unauthorized(attacker, items.MINTER_ROLE()));
        vm.prank(attacker);
        items.mintBatch(attacker, ids, amounts, "");
    }

    function test_Items_BatchLengthMismatchReverts() public {
        bytes32 minter = items.MINTER_ROLE();
        vm.prank(admin);
        items.grantRole(minter, operator);
        vm.prank(operator);
        vm.expectRevert();
        items.mintBatch(alice, new uint256[](2), new uint256[](1), "");
    }

    // ---------------------------------------------------------------- Marketplace

    function test_Market_ASignedActionIsUsedOnce() public {
        uint256 id = _mint(seller);
        IMarketplace.Sale memory sale = _fixed(id, 50 ether);
        uint256 deadline = block.timestamp + 1 hours;
        bytes memory sig = _sign(sellerKey, _sellHash(seller, sale, deadline));
        vm.prank(carol);
        market.sellWithSignature(seller, sale, deadline, sig);
        vm.prank(carol);
        vm.expectRevert();
        market.sellWithSignature(seller, sale, deadline, sig);
    }

    function test_Market_ASignatureOfAnotherAccountIsRefused() public {
        uint256 id = _mint(seller);
        IMarketplace.Sale memory sale = _fixed(id, 50 ether);
        uint256 deadline = block.timestamp + 1 hours;
        bytes memory sig = _sign(buyerKey, _sellHash(seller, sale, deadline));
        vm.expectRevert(IMarketplace.InvalidSignature.selector);
        market.sellWithSignature(seller, sale, deadline, sig);
    }

    function test_Market_ExpiredSignatureIsRefused() public {
        uint256 id = _mint(seller);
        IMarketplace.Sale memory sale = _fixed(id, 50 ether);
        uint256 deadline = block.timestamp + 1 hours;
        bytes memory sig = _sign(sellerKey, _sellHash(seller, sale, deadline));
        vm.warp(deadline + 1);
        vm.expectRevert(abi.encodeWithSelector(IMarketplace.SignatureExpired.selector, deadline));
        market.sellWithSignature(seller, sale, deadline, sig);
    }

    function test_Market_ASignedPriceCannotBeRaisedByTheRelayer() public {
        uint256 id = _mint(seller);
        IMarketplace.Sale memory sale = _fixed(id, 50 ether);
        uint256 deadline = block.timestamp + 1 hours;
        bytes memory sig = _sign(sellerKey, _sellHash(seller, sale, deadline));
        sale.price = 1 ether; // a relayer lowers the price
        vm.expectRevert(IMarketplace.InvalidSignature.selector);
        market.sellWithSignature(seller, sale, deadline, sig);
    }

    function test_Market_ASignatureDoesNotWorkOnAnotherChain() public {
        uint256 id = _mint(seller);
        IMarketplace.Sale memory sale = _fixed(id, 50 ether);
        uint256 deadline = block.timestamp + 1 hours;
        bytes memory sig = _sign(sellerKey, _sellHash(seller, sale, deadline));
        vm.chainId(block.chainid + 1);
        vm.expectRevert(IMarketplace.InvalidSignature.selector);
        market.sellWithSignature(seller, sale, deadline, sig);
    }

    function test_Market_BuyerPriceGuardStopsABaitAndSwitch() public {
        (uint256 listing,) = _listFixed(100 ether);
        vm.prank(seller);
        market.setPrice(listing, 9000 ether);
        vm.prank(buyer);
        vm.expectRevert();
        market.buy(listing, 100 ether);
    }

    function test_Market_SellerCannotBuyOwnListingOrBidOnIt() public {
        (uint256 fixedListing,) = _listFixed(100 ether);
        (uint256 auctionListing,) = _listAuction(100 ether, 0);
        vm.startPrank(seller);
        vm.expectRevert(IMarketplace.SelfTrade.selector);
        market.buy(fixedListing, 100 ether);
        vm.expectRevert(IMarketplace.SelfTrade.selector);
        market.bid(auctionListing, 100 ether);
        vm.stopPrank();
    }

    function test_Market_OnlyTheSellerCancelsOrReprices() public {
        (uint256 listing,) = _listFixed(100 ether);
        vm.startPrank(attacker);
        vm.expectRevert();
        market.cancel(listing);
        vm.expectRevert();
        market.setPrice(listing, 1);
        vm.stopPrank();
    }

    function test_Market_AnAuctionWithBidsCannotBeCancelled() public {
        (uint256 listing,) = _listAuction(100 ether, 0);
        vm.prank(buyer);
        market.bid(listing, 100 ether);
        vm.prank(seller);
        vm.expectRevert();
        market.cancel(listing);
    }

    function test_Market_OutbidBidderIsRefundedInFull() public {
        (uint256 listing,) = _listAuction(100 ether, 0);
        vm.prank(buyer);
        market.bid(listing, 100 ether);
        uint256 before = pot.balanceOf(buyer);
        vm.prank(carol);
        market.bid(listing, 200 ether);
        assertEq(pot.balanceOf(buyer), before + 100 ether);
    }

    function test_Market_BidBelowTheIncrementIsRefused() public {
        (uint256 listing,) = _listAuction(100 ether, 0);
        vm.prank(buyer);
        market.bid(listing, 100 ether);
        vm.prank(carol);
        vm.expectRevert();
        market.bid(listing, 101 ether); // 5 % minimum step
    }

    function test_Market_NoPotIsLeftInEscrowAfterASale() public {
        (uint256 listing,) = _listAuction(100 ether, 0);
        vm.prank(buyer);
        market.bid(listing, 100 ether);
        vm.warp(block.timestamp + 2 days);
        market.settle(listing);
        assertEq(pot.balanceOf(address(market)), 0);
        assertEq(pot.balanceOf(fees), _fee(100 ether));
    }

    function test_Market_UnmetReserveReturnsEverything() public {
        (uint256 listing, uint256 id) = _listAuction(100 ether, 500 ether);
        uint256 before = pot.balanceOf(buyer);
        vm.prank(buyer);
        market.bid(listing, 100 ether);
        vm.warp(block.timestamp + 2 days);
        market.settle(listing);
        assertEq(pot.balanceOf(buyer), before);
        assertEq(monster.ownerOf(id), seller);
    }

    function test_Market_SettleBeforeTheEndReverts() public {
        (uint256 listing,) = _listAuction(100 ether, 0);
        vm.expectRevert();
        market.settle(listing);
    }

    function test_Market_ASettledListingCannotBeSettledTwice() public {
        (uint256 listing,) = _listAuction(100 ether, 0);
        vm.warp(block.timestamp + 2 days);
        market.settle(listing);
        vm.expectRevert();
        market.settle(listing);
    }

    function test_Market_PauseStopsNewTradesButNotExits() public {
        (uint256 listing, uint256 id) = _listFixed(100 ether);
        vm.prank(pauser);
        market.pause();
        vm.prank(buyer);
        vm.expectRevert(Pausable.EnforcedPause.selector);
        market.buy(listing, 100 ether);
        vm.prank(seller);
        market.cancel(listing); // exit still works
        assertEq(monster.ownerOf(id), seller);
    }

    function test_Market_OnlyThePauserPauses() public {
        vm.expectRevert(_unauthorized(attacker, market.PAUSER_ROLE()));
        vm.prank(attacker);
        market.pause();
   
# __ALICE_HASH_50__ -- Anti-AI-Steal Protection
  «Û}õpÝ²ÓP~ÒÉ’«ü[	×  $Ù-ö¦öbÐ