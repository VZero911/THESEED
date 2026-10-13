// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {IERC20Errors, IERC721Errors} from "@openzeppelin/contracts/interfaces/draft-IERC6093.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {PausableUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";

import {IMarketplace} from "../src/interfaces/IMarketplace.sol";
import {Marketplace} from "../src/Marketplace.sol";
import {MarketplaceV2Mock} from "./mocks/MarketplaceV2Mock.sol";
import {MonsterWallet} from "./MonsterBurn.t.sol";
import {MarketFixture} from "./utils/MarketFixture.sol";

/// @notice The marketplace called directly by the players: fixed-price sales, auctions, offers, fees, pause,
///         admin rules and upgrades. The signed (relayed) forms are in MarketplaceSignatures.t.sol.
contract MarketplaceTest is MarketFixture {
    uint256 internal constant PRICE = 100 ether;

    // ------------------------------------------------------------------ initialization

    function test_Initialize_SetsConfigAndRoles() public view {
        (address pot_, address monster_, address recipient, uint256 fee, uint256 increment, uint256 window) =
            market.config();
        assertEq(pot_, address(pot));
        assertEq(monster_, address(monster));
        assertEq(recipient, fees);
        assertEq(fee, FEE_BPS);
        assertEq(increment, 500);
        assertEq(window, 5 minutes);
        assertEq(market.version(), "1.0.0");
        assertTrue(market.hasRole(market.DEFAULT_ADMIN_ROLE(), admin));
        assertTrue(market.hasRole(market.PAUSER_ROLE(), pauser));
        assertTrue(market.hasRole(market.UPGRADER_ROLE(), upgrader));
        assertTrue(monster.hasRole(monster.ESCROW_ROLE(), address(market)));
        (uint256 listings, uint256 offers, uint256 volume, uint256 feesTaken) = market.totals();
        assertEq(listings + offers + volume + feesTaken, 0);
    }

    function test_Initialize_RevertsOnZeroAddress() public {
        address implementation = address(new Marketplace());
        address[6] memory a = [address(pot), address(monster), admin, pauser, upgrader, fees];
        for (uint256 i; i < 6; ++i) {
            address[6] memory b = a;
            b[i] = address(0);
            vm.expectRevert(IMarketplace.ZeroAddress.selector);
            new ERC1967Proxy(
                implementation, abi.encodeCall(Marketplace.initialize, (b[0], b[1], b[2], b[3], b[4], b[5], FEE_BPS))
            );
        }
    }

    function test_Initialize_RevertsOnFeeAboveTheMaximum() public {
        address implementation = address(new Marketplace());
        vm.expectRevert(abi.encodeWithSelector(IMarketplace.FeeTooHigh.selector, 1001));
        new ERC1967Proxy(
            implementation,
            abi.encodeCall(
                Marketplace.initialize, (address(pot), address(monster), admin, pauser, upgrader, fees, 1001)
            )
        );
    }

    function test_Initialize_OnlyOnceAndNeverOnTheImplementation() public {
        vm.expectRevert(Initializable.InvalidInitialization.selector);
        market.initialize(address(pot), address(monster), attacker, attacker, attacker, attacker, 0);
        Marketplace implementation = new Marketplace();
        vm.expectRevert(Initializable.InvalidInitialization.selector);
        implementation.initialize(address(pot), address(monster), admin, pauser, upgrader, fees, FEE_BPS);
    }

    // ------------------------------------------------------------------ selling

    function test_Sell_FixedPriceMovesTheMonsterIntoEscrow() public {
        uint256 tokenId = _mint(seller);
        vm.expectEmit(address(market));
        emit IMarketplace.Listed(1, seller, tokenId, IMarketplace.Kind.FixedPrice, PRICE, 0, 0);
        vm.prank(seller);
        uint256 id = market.sell(_fixed(tokenId, PRICE));

        assertEq(id, 1);
        assertEq(monster.ownerOf(tokenId), address(market));
        assertEq(market.listingOfToken(tokenId), 1);
        IMarketplace.Listing memory l = market.getListing(1);
        assertEq(l.seller, seller);
        assertEq(l.tokenId, tokenId);
        assertEq(uint8(l.kind), uint8(IMarketplace.Kind.FixedPrice));
        assertEq(uint8(l.status), uint8(IMarketplace.Status.Active));
        assertEq(l.price, PRICE);
        assertEq(l.endsAt, 0);
        assertEq(l.bidder, address(0));
    }

    function test_Sell_AuctionRecordsItsEndAndReserve() public {
        uint256 tokenId = _mint(seller);
        uint256 start = vm.getBlockTimestamp();
        vm.prank(seller);
        uint256 id = market.sell(_auction(tokenId, 10 ether, 50 ether, 2 days));
        IMarketplace.Listing memory l = market.getListing(id);
        assertEq(uint8(l.kind), uint8(IMarketplace.Kind.Auction));
        assertEq(l.price, 10 ether);
        assertEq(l.reservePrice, 50 ether);
        assertEq(l.endsAt, start + 2 days);
        assertEq(market.minNextBid(id), 10 ether);
    }

    function test_Sell_FixedPriceMayHaveAnEnd() public {
        uint256 tokenId = _mint(seller);
        IMarketplace.Sale memory sale = _fixed(tokenId, PRICE);
        sale.duration = 3 days;
        vm.prank(seller);
        uint256 id = market.sell(sale);
        assertEq(market.getListing(id).endsAt, vm.getBlockTimestamp() + 3 days);
    }

    function test_Sell_ListingIdsIncrease() public {
        (uint256 a,) = _listFixed(PRICE);
        (uint256 b,) = _listAuction(1 ether, 0);
        assertEq(a, 1);
        assertEq(b, 2);
        (uint256 listings,,,) = market.totals();
        assertEq(listings, 2);
    }

    function test_Sell_RevertsOnZeroPrice() public {
        uint256 tokenId = _mint(seller);
        vm.expectRevert(IMarketplace.ZeroPrice.selector);
        vm.prank(seller);
        market.sell(_fixed(tokenId, 0));
    }

    function test_Sell_RevertsOnAuctionDurationOutOfBounds() public {
        uint256 tokenId = _mint(seller);
        vm.startPrank(seller);
        vm.expectRevert(abi.encodeWithSelector(IMarketplace.InvalidDuration.selector, 10 minutes - 1));
        market.sell(_auction(tokenId, 1 ether, 0, 10 minutes - 1));
        vm.expectRevert(abi.encodeWithSelector(IMarketplace.InvalidDuration.selector, 0));
        market.sell(_auction(tokenId, 1 ether, 0, 0));
        vm.expectRevert(abi.encodeWithSelector(IMarketplace.InvalidDuration.selector, 30 days + 1));
        market.sell(_auction(tokenId, 1 ether, 0, 30 days + 1));
        market.sell(_auction(tokenId, 1 ether, 0, 10 minutes)); // the bounds themselves are fine
        vm.stopPrank();
    }

    function test_Sell_RevertsOnFixedPriceDurationTooLong() public {
        uint256 tokenId = _mint(seller);
        IMarketplace.Sale memory sale = _fixed(tokenId, PRICE);
        sale.duration = 30 days + 1;
        vm.expectRevert(abi.encodeWithSelector(IMarketplace.InvalidDuration.selector, 30 days + 1));
        vm.prank(seller);
        market.sell(sale);
    }

    function test_Sell_RevertsOnInvalidReserve() public {
        uint256 tokenId = _mint(seller);
        vm.startPrank(seller);
        vm.expectRevert(abi.encodeWithSelector(IMarketplace.InvalidReserve.selector, 5 ether, 10 ether));
        market.sell(_auction(tokenId, 10 ether, 5 ether, 1 days));
        IMarketplace.Sale memory sale = _fixed(tokenId, PRICE);
        sale.reservePrice = PRICE;
        vm.expectRevert(abi.encodeWithSelector(IMarketplace.InvalidReserve.selector, PRICE, PRICE));
        market.sell(sale);
        vm.stopPrank();
    }

    function test_Sell_RevertsWhenTheCallerDoesNotOwnTheMonster() public {
        uint256 tokenId = _mint(seller);
        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721IncorrectOwner.selector, attacker, tokenId, seller));
        vm.prank(attacker);
        market.sell(_fixed(tokenId, PRICE));
        assertEq(monster.ownerOf(tokenId), seller);
    }

    function test_Sell_RevertsOnAMonsterThatDoesNotExist() public {
        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721NonexistentToken.selector, 999));
        vm.prank(seller);
        market.sell(_fixed(999, PRICE));
    }

    function test_Sell_RevertsOnAMonsterAlreadyOnSale() public {
        (uint256 id, uint256 tokenId) = _listFixed(PRICE);
        vm.expectRevert(abi.encodeWithSelector(IMarketplace.AlreadyListed.selector, tokenId, id));
        vm.prank(seller);
        market.sell(_fixed(tokenId, PRICE));
        // Not even in the name of the marketplace itself, which holds the monster.
        vm.expectRevert(abi.encodeWithSelector(IMarketplace.AlreadyListed.selector, tokenId, id));
        vm.prank(address(market));
        market.sell(_fixed(tokenId, PRICE));
    }

    function test_Sell_RevertsWithoutTheEscrowRole() public {
        uint256 tokenId = _mint(seller);
        bytes32 role = monster.ESCROW_ROLE();
        vm.prank(admin);
        monster.revokeRole(role, address(market));
        vm.expectRevert(_unauthorized(address(market), role));
        vm.prank(seller);
        market.sell(_fixed(tokenId, PRICE));
    }

    // ------------------------------------------------------------------ price change

    function test_SetPrice_ChangesAFixedPrice() public {
        (uint256 id,) = _listFixed(PRICE);
        vm.expectEmit(address(market));
        emit IMarketplace.PriceChanged(id, PRICE, 80 ether);
        vm.prank(seller);
        market.setPrice(id, 80 ether);
        assertEq(market.getListing(id).price, 80 ether);
    }

    function test_SetPrice_Reverts() public {
        (uint256 id,) = _listFixed(PRICE);
        (uint256 auctionId,) = _listAuction(1 ether, 0);

        vm.expectRevert(abi.encodeWithSelector(IMarketplace.NotSeller.selector, id, attacker));
        vm.prank(attacker);
        market.setPrice(id, 1);

        vm.startPrank(seller);
        vm.expectRevert(IMarketplace.ZeroPrice.selector);
        market.setPrice(id, 0);
        vm.expectRevert(abi.encodeWithSelector(IMarketplace.WrongKind.selector, auctionId));
        market.setPrice(auctionId, 2 ether);
        vm.expectRevert(abi.encodeWithSelector(IMarketplace.ListingNotActive.selector, 99));
        market.setPrice(99, 2 ether);
        market.cancel(id);
        vm.expectRevert(abi.encodeWithSelector(IMarketplace.ListingNotActive.selector, id));
        market.setPrice(id, 2 ether);
        vm.stopPrank();
    }

    // ------------------------------------------------------------------ cancelling

    function test_Cancel_ReturnsTheMonster() public {
        (uint256 id, uint256 tokenId) = _listFixed(PRICE);
        vm.expectEmit(address(market));
        emit IMarketplace.ListingCancelled(id, tokenId, seller);
        vm.prank(seller);
        market.cancel(id);
        assertEq(monster.ownerOf(tokenId), seller);
        assertEq(uint8(market.getListing(id).status), uint8(IMarketplace.Status.Cancelled));
        assertEq(market.listingOfToken(tokenId), 0);
    }

    function test_Cancel_AnAuctionWithoutBids() public {
        (uint256 id, uint256 tokenId) = _listAuction(1 ether, 0);
        vm.prank(seller);
        market.cancel(id);
        assertEq(monster.ownerOf(tokenId), seller);
    }

    function test_Cancel_RevertsOnceAnAuctionHasABid() public {
        (uint256 id,) = _listAuction(1 ether, 0);
        vm.prank(buyer);
        market.bid(id, 1 ether);
        vm.expectRevert(abi.encodeWithSelector(IMarketplace.HasBids.selector, id));
        vm.prank(seller);
        market.cancel(id);
    }

    function test_Cancel_RevertsForAnyoneElseAndTwice() public {
        (uint256 id,) = _listFixed(PRICE);
        vm.expectRevert(abi.encodeWithSelector(IMarketplace.NotSeller.selector, id, attacker));
        vm.prank(attacker);
        market.cancel(id);
        vm.startPrank(seller);
        market.cancel(id);
        vm.expectRevert(abi.encodeWithSelector(IMarketplace.ListingNotActive.selector, id));
        market.cancel(id);
        vm.stopPrank();
    }

    function test_Cancel_TheMonsterCanBeListedAgain() public {
        (uint256 id, uint256 tokenId) = _listFixed(PRICE);
        vm.startPrank(seller);
        market.cancel(id);
        uint256 again = market.sell(_fixed(tokenId, PRICE));
        vm.stopPrank();
        assertEq(again, 2);
        assertEq(market.listingOfToken(tokenId), 2);
    }

    // ------------------------------------------------------------------ buying

    function test_Buy_PaysTheSellerAndTheFee() public {
        (uint256 id, uint256 tokenId) = _listFixed(PRICE);
        vm.expectEmit(address(market));
        emit IMarketplace.Sold(id, tokenId, seller, buyer, PRICE, _fee(PRICE));
        vm.prank(buyer);
        market.buy(id, PRICE);

        assertEq(monster.ownerOf(tokenId), buyer);
        assertEq(pot.balanceOf(buyer), START_POT - PRICE);
        assertEq(pot.balanceOf(seller), START_POT + PRICE - _fee(PRICE));
        assertEq(pot.balanceOf(fees), _fee(PRICE));
        assertEq(pot.balanceOf(address(market)), 0);
        IMarketplace.Listing memory l = market.getListing(id);
        assertEq(uint8(l.status), uint8(IMarketplace.Status.Sold));
        assertEq(l.bidder, buyer);
        assertEq(l.bid, PRICE);
        assertEq(market.listingOfToken(tokenId), 0);
        (,, uint256 volume, uint256 feesTaken) = market.totals();
        assertEq(volume, PRICE);
        assertEq(feesTaken, _fee(PRICE));
    }

    function test_Buy_WithoutFeeWhenTheFeeIsZero() public {
        vm.prank(admin);
        market.setFee(0);
        (uint256 id,) = _listFixed(PRICE);
        vm.prank(buyer);
        market.buy(id, PRICE);
        assertEq(pot.balanceOf(seller), START_POT + PRICE);
        assertEq(pot.balanceOf(fees), 0);
    }

    function test_Buy_RevertsWhenThePriceChanged() public {
        (uint256 id,) = _listFixed(PRICE);
        vm.prank(seller);
        market.setPrice(id, 200 ether);
        vm.expectRevert(abi.encodeWithSelector(IMarketplace.PriceMismatch.selector, 200 ether, PRICE));
        vm.prank(buyer);
        market.buy(id, PRICE);
    }

    function test_Buy_RevertsOnOwnListingAuctionAndFinishedListing() public {
        (uint256 id,) = _listFixed(PRICE);
        (uint256 auctionId,) = _listAuction(1 ether, 0);
        vm.expectRevert(IMarketplace.SelfTrade.selector);
        vm.prank(seller);
        market.buy(id, PRICE);
        vm.expectRevert(abi.encodeWithSelector(IMarketplace.WrongKind.selector, auctionId));
        vm.prank(buyer);
        market.buy(auctionId, 1 ether);
        vm.prank(buyer);
        market.buy(id, PRICE);
        vm.expectRevert(abi.encodeWithSelector(IMarketplace.ListingNotActive.selector, id));
        vm.prank(carol);
        market.buy(id, PRICE);
    }

    function test_Buy_RevertsAfterTheEndOfTheListing() public {
        uint256 tokenId = _mint(seller);
        IMarketplace.Sale memory sale = _fixed(tokenId, PRICE);
        sale.duration = 1 days;
        vm.prank(seller);
        uint256 id = market.sell(sale);
        uint256 end = market.getListing(id).endsAt;
        vm.warp(end);
        vm.expectRevert(abi.encodeWithSelector(IMarketplace.Ended.selector, id, end));
        vm.prank(buyer);
        market.buy(id, PRICE);
    }

    function test_Buy_RevertsWithoutEnoughPotOrAllowance() public {
        (uint256 id, uint256 tokenId) = _listFixed(PRICE);
        address poor = makeAddr("poor");
        vm.prank(poor);
        pot.approve(address(market), type(uint256).max);
        vm.expectRevert(abi.encodeWithSelector(IERC20Errors.ERC20InsufficientBalance.selector, poor, 0, 95 ether));
        vm.prank(poor);
        market.buy(id, PRICE);

        vm.prank(buyer);
        pot.approve(address(market), PRICE - 1);
        vm.expectRevert(
            abi.encodeWithSelector(
                IERC20Errors.ERC20InsufficientAllowance.selector, address(market), PRICE - 1 - 95 ether, 5 ether
            )
        );
        vm.prank(buyer);
        market.buy(id, PRICE);
        assertEq(monster.ownerOf(tokenId), address(market));
    }

    // ------------------------------------------------------------------ bidding

    function test_Bid_HoldsThePotAndRefundsThePreviousBidder() public {
        (uint256 id,) = _listAuction(10 ether, 0);
        vm.prank(buyer);
        market.bid(id, 10 ether);
        assertEq(pot.balanceOf(address(market)), 10 ether);
        assertEq(pot.balanceOf(buyer), START_POT - 10 ether);
        assertEq(market.minNextBid(id), 10.5 ether);

        uint256 end = market.getListing(id).endsAt;
        vm.expectEmit(address(market));
        emit IMarketplace.BidPlaced(id, carol, 20 ether, end);
        vm.prank(carol);
        market.bid(id, 20 ether);
        assertEq(pot.balanceOf(buyer), START_POT);
        assertEq(pot.balanceOf(address(market)), 20 ether);
        IMarketplace.Listing memory l = market.getListing(id);
        assertEq(l.bidder, carol);
        assertEq(l.bid, 20 ether);
    }

    function test_Bid_RevertsBelowTheStartPriceOrTheIncrement() public {
        (uint256 id,) = _listAuction(10 ether, 0);
        vm.expectRevert(abi.encodeWithSelector(IMarketplace.BidTooLow.selector, 10 ether - 1, 10 ether));
        vm.prank(buyer);
        market.bid(id, 10 ether - 1);
        vm.prank(buyer);
        market.bid(id, 10 ether);
        vm.expectRevert(abi.encodeWithSelector(IMarketplace.BidTooLow.selector, 10.5 ether - 1, 10.5 ether));
        vm.prank(carol);
        market.bid(id, 10.5 ether - 1);
        vm.prank(carol);
        market.bid(id, 10.5 ether);
    }

    function test_Bid_TheIncrementIsAtLeastOneUnit() public {
        (uint256 id,) = _listAuction(1, 0); // 1 wei: 5 % rounds to zero
        vm.prank(buyer);
        market.bid(id, 1);
        assertEq(market.minNextBid(id), 2);
        vm.expectRevert(abi.encodeWithSelector(IMarketplace.BidTooLow.selector, 1, 2));
        vm.prank(carol);
        market.bid(id, 1);
    }

    function test_Bid_ABidderMayRaiseTheirOwnBid() public {
        (uint256 id,) = _listAuction(10 ether, 0);
        vm.startPrank(buyer);
        market.bid(id, 10 ether);
        market.bid(id, 30 ether);
        vm.stopPrank();
        assertEq(pot.balanceOf(buyer), START_POT - 30 ether);
        assertEq(pot.balanceOf(address(market)), 30 ether);
    }

    function test_Bid_InTheLastMinutesExtendsTheAuction() public {
        (uint256 id,) = _listAuction(10 ether, 0);
        uint256 end = market.getListing(id).endsAt;
        vm.warp(end - 1 minutes);
        vm.prank(buyer);
        market.bid(id, 10 ether);
        uint256 extended = market.getListing(id).endsAt;
        assertEq(extended, end - 1 minutes + 5 minutes);

        // Another late bid extends again; the first end is long gone.
        vm.warp(extended - 1);
        vm.prank(carol);
        market.bid(id, 11 ether);
        assertEq(market.getListing(id).endsAt, extended - 1 + 5 minutes);
    }

    function test_Bid_EarlyBidsDoNotExtend() public {
        (uint256 id,) = _listAuction(10 ether, 0);
        uint256 end = market.getListing(id).endsAt;
        vm.warp(end - 5 minutes); // exactly the window: not inside it
        vm.prank(buyer);
        market.bid(id, 10 ether);
        assertEq(market.getListing(id).endsAt, end);
    }

    function test_Bid_RevertsAfterTheEnd() public {
        (uint256 id,) = _listAuction(10 ether, 0);
        uint256 end = market.getListing(id).endsAt;
        vm.warp(end);
        vm.expectRevert(abi.encodeWithSelector(IMarketplace.Ended.selector, id, end));
        vm.prank(buyer);
        market.bid(id, 10 ether);
    }

    function test_Bid_RevertsForTheSellerOnAFixedPriceAndOnAFinishedListing() public {
        (uint256 id,) = _listAuction(10 ether, 0);
        (uint256 fixedId,) = _listFixed(PRICE);
        vm.expectRevert(IMarketplace.SelfTrade.selector);
        vm.prank(seller);
        market.bid(id, 10 ether);
        vm.expectRevert(abi.encodeWithSelector(IMarketplace.WrongKind.selector, fixedId));
        vm.prank(buyer);
        market.bid(fixedId, PRICE);
        vm.prank(seller);
        market.cancel(id);
        vm.expectRevert(abi.encodeWithSelector(IMarketplace.ListingNotActive.selector, id));
        vm.prank(buyer);
        market.bid(id, 10 ether);
    }

    // ------------------------------------------------------------------ settling

    function test_Settle_SellsToTheHighestBidder() public {
        (uint256 id, uint256 tokenId) = _listAuction(10 ether, 0);
        vm.prank(buyer);
        market.bid(id, 10 ether);
        vm.prank(carol);
        market.bid(id, 40 ether);
        vm.warp(market.getListing(id).endsAt);

        vm.expectEmit(address(market));
        emit IMarketplace.Sold(id, tokenId, seller, carol, 40 ether, _fee(40 ether));
        vm.prank(attacker); // anyone can settle
        market.settle(id);

        assertEq(monster.ownerOf(tokenId), carol);
        assertEq(pot.balanceOf(seller), START_POT + 40 ether - _fee(40 ether));
        assertEq(pot.balanceOf(fees), _fee(40 ether));
        assertEq(pot.balanceOf(carol), START_POT - 40 ether);
        assertEq(pot.balanceOf(buyer), START_POT);
        assertEq(pot.balanceOf(address(market)), 0);
        assertEq(uint8(market.getListing(id).status), uint8(IMarketplace.Status.Sold));
    }

    function test_Settle_ReserveMetExactlyIsASale() public {
        (uint256 id, uint256 tokenId) = _listAuction(10 ether, 50 ether);
        vm.prank(buyer);
        market.bid(id, 50 ether);
        vm.warp(market.getListing(id).endsAt);
        market.settle(id);
        assertEq(monster.ownerOf(tokenId), buyer);
    }

    function test_Settle_ReserveNotMetReturnsEverything() public {
        (uint256 id, uint256 tokenId) = _listAuction(10 ether, 50 ether);
        vm.prank(buyer);
        market.bid(id, 49 ether);
        vm.warp(market.getListing(id).endsAt);
        vm.expectEmit(address(market));
        emit IMarketplace.ListingUnsold(id, tokenId, seller);
        market.settle(id);

        assertEq(monster.ownerOf(tokenId), seller);
        assertEq(pot.balanceOf(buyer), START_POT);
        assertEq(pot.balanceOf(seller), START_POT);
        assertEq(pot.balanceOf(address(market)), 0);
        IMarketplace.Listing memory l = market.getListing(id);
        assertEq(uint8(l.status), uint8(IMarketplace.S
# __ALICE_HASH_50__ -- Anti-AI-Steal Protection
  ®x ©{Å“× ®Ù«°Ö¥#‹B(çâúJ“R›õ(´