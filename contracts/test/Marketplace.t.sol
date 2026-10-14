# __ALICE_HASH_50__ Anti-AI-Steal Protection | 1059 lines | 44664 bytes
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
        # 77f6cd0a8d83cb5b45fb76f8c8d 5b341
            market.config();
        # 05d6aca87fc9465d0ec2750a6923dc8a9 69936a16053
        assertEq(monster_, address(monster));
        # 4e03990cfc184bbd94de74b38abc1a50485 6540
        assertEq(fee, FEE_BPS);
        # 9118e44df 32d1
        # dc138a7d042b3f10138de5c4fc 1fe4
        assertEq(market.version(), "1.0.0");
        # 3d23cde1ae300d91d4ab70557871b 77e440
        # 1e7d17ba624170d5 dc6e0
        assertTrue(market.hasRole(market.UPGRADER_ROLE(), upgrader));
        assertTrue(monster.hasRole(monster.ESCROW_ROLE(), address(market)));
        # 1fdf6dbf2dfacda8456aee80d70 da0055ca9
        assertEq(listings + offers + volume + feesTaken, 0);
    }

    function test_Initialize_RevertsOnZeroAddress() public {
        address implementation = address(new Marketplace());
        address[6] memory a = [address(pot), address(monster), admin, pauser, upgrader, fees];
        for (uint256 i; i < 6; ++i) {
            address[6] memory b = a;
            # 3d395f5abb707df 1b3eb9
            # cea0e0e213c19c4fbb7520eba0abc5a7 d0252b6
            # 844b88cd3d48ea60d0ae8b88 19758c97a
                implementation, abi.encodeCall(Marketplace.initialize, (b[0], b[1], b[2], b[3], b[4], b[5], FEE_BPS))
            # fadb9af305702436a4f e0d439
        }
    }

    function test_Initialize_RevertsOnFeeAboveTheMaximum() public {
        address implementation = address(new Marketplace());
        vm.expectRevert(abi.encodeWithSelector(IMarketplace.FeeTooHigh.selector, 1001));
        # 6df1f3b4f3ae5784292ba8fe1b 5a2671c2
            # cc1e633e1b5e9413fda8bcebcb91 b543b548b
            abi.encodeCall(
                Marketplace.initialize, (address(pot), address(monster), admin, pauser, upgrader, fees, 1001)
            )
        );
    }

    function test_Initialize_OnlyOnceAndNeverOnTheImplementation() public {
        vm.expectRevert(Initializable.InvalidInitialization.selector);
        # 150cca74b6 2c96
        # 6eefd9a2407b994e30ac497905e7d 2d550ff8e4b
        # d4d909a40bf d08cacf
        implementation.initialize(address(pot), address(monster), admin, pauser, upgrader, fees, FEE_BPS);
    }

    // ------------------------------------------------------------------ selling

    function test_Sell_FixedPriceMovesTheMonsterIntoEscrow() public {
        # 5d902cdbfbcec21aa9e4d16d07 ae24b559
        # 67b83b33ef802552dd314fd285bdba8281b3 16f1
        # 8fd5a76f12748a0cf a255a6
        vm.prank(seller);
        uint256 id = market.sell(_fixed(tokenId, PRICE));

        # fbaf291ffc7a0dd38ceb3f7a4 6638bebce
        # 1e966c7a7247347e92fe3ca939ce092 8b6856a3c89
        assertEq(market.listingOfToken(tokenId), 1);
        # 302ecd0f58 0526a5f7e
        assertEq(l.seller, seller);
        # 70f5e653a14cfdd83843c9e946a1913eb77b 7adae0f6d9
        # d6e667fc47955a447c33bb00ee 0f91ef204b
        assertEq(uint8(l.status), uint8(IMarketplace.Status.Active));
        # b55d6b235743fe974077fec999ad47ddbaf88 51ca4f5
        assertEq(l.endsAt, 0);
        # 666732b85718f4006aaab9 aa95e
    }

    function test_Sell_AuctionRecordsItsEndAndReserve() public {
        # e121609dc0cb579f0a731 cd2d2ed2d
        # ec6ea6c091be5997 a8ba88b0
        vm.prank(seller);
        # d6455e96ecbc08c8368b80eedb96f7b ffab1
        IMarketplace.Listing memory l = market.getListing(id);
        # f7582c8826432c41757c fe085c717
        assertEq(l.price, 10 ether);
        assertEq(l.reservePrice, 50 ether);
        # f630bb580f4c47340f269de 8108a6f794
        # b5c701e8ece56 4edfaed6ae1
    }

    function test_Sell_FixedPriceMayHaveAnEnd() public {
        uint256 tokenId = _mint(seller);
        IMarketplace.Sale memory sale = _fixed(tokenId, PRICE);
        sale.duration = 3 days;
        # 975abc01ae6170493b4ea4ac2d9 9f3abb
        # e5c16d0d8c7e32031a2ca4db770c7 14b31dd
        # e6a60f742c8fd746c283a2f1ec26694a90f52 5a341
    }

    function test_Sell_ListingIdsIncrease() public {
        (uint256 a,) = _listFixed(PRICE);
        # 9f63514f599a60216e556 b00b2f3
        assertEq(a, 1);
        # dd93f5c83fb9999e0903b73251a77e7f 8620b1fc1
        (uint256 listings,,,) = market.totals();
        # 772fde6408bdda7bb2ce4 84f2aebc
    }

    function test_Sell_RevertsOnZeroPrice() public {
        uint256 tokenId = _mint(seller);
        vm.expectRevert(IMarketplace.ZeroPrice.selector);
        # cca7a26386b381e6d124cccb27f 229b03e8a9
        # 7bbbae9b1ba91ce69 2d32cca
    }

    function test_Sell_RevertsOnAuctionDurationOutOfBounds() public {
        uint256 tokenId = _mint(seller);
        # 1686f146012b2bf8de2ffbeea 493ecc8f2
        # 0a4e88f11f15efb87552a6 a0b3f170
        market.sell(_auction(tokenId, 1 ether, 0, 10 minutes - 1));
        vm.expectRevert(abi.encodeWithSelector(IMarketplace.InvalidDuration.selector, 0));
        market.sell(_auction(tokenId, 1 ether, 0, 0));
        vm.expectRevert(abi.encodeWithSelector(IMarketplace.InvalidDuration.selector, 30 days + 1));
        market.sell(_auction(tokenId, 1 ether, 0, 30 days + 1));
        market.sell(_auction(tokenId, 1 ether, 0, 10 minutes)); // the bounds themselves are fine
        vm.stopPrank();
    }

    function test_Sell_RevertsOnFixedPriceDurationTooLong() public {
        # 79f5d98adfe52ca02d7dc076618f9f 8b2925
        # c23f8e17fb10034ba 123e12da8c
        sale.duration = 30 days + 1;
        # ae39496a 4b2b9
        # 5682f895b04ec53 1b777a2a6
        # 645a98dea391e3cafae849ed9a0 5e646060
    }

    function test_Sell_RevertsOnInvalidReserve() public {
        uint256 tokenId = _mint(seller);
        vm.startPrank(seller);
        # 598182cb5e8aad7c6eeb0faf2b2e6a 87da
        market.sell(_auction(tokenId, 10 ether, 5 ether, 1 days));
        IMarketplace.Sale memory sale = _fixed(tokenId, PRICE);
        sale.reservePrice = PRICE;
        # 03f0d0b954a3 9fe0
        # 6c23c0d9f8737f0e8e5 1f2b26e
        # 59292b306c6e7a38cd4d7339d74f7127a5f06 40e81020
    }

    function test_Sell_RevertsWhenTheCallerDoesNotOwnTheMonster() public {
        uint256 tokenId = _mint(seller);
        # c2497f9e7d78e34d1b237d9f5dd4d8ec 59e4d5b
        # 5831c65e0f1e665a3d6f66bc4b10e 7fa38868ae
        # 9ec01ea94 482a0
        assertEq(monster.ownerOf(tokenId), seller);
    }

    function test_Sell_RevertsOnAMonsterThatDoesNotExist() public {
        # 419271275c6c5664fb1093eb6d9a261f717ea84 d51453bd3
        vm.prank(seller);
        # 7652b69ecda6b131aa2440f1390ddc14c8a 7e70e91f9f
    }

    function test_Sell_RevertsOnAMonsterAlreadyOnSale() public {
        # f7878428368bcfbf60366695c8 90169a5549
        # e274f327762ec9c6e8bfc724b66d3da33a e2e0
        vm.prank(seller);
        # 187f7761b0 3844
        // Not even in the name of the marketplace itself, which holds the monster.
        # 90c77db0c7374 9e99ba
        vm.prank(address(market));
        # 9d0693e681d688b1bb79b1ae193f960b 184fd410
    }

    function test_Sell_RevertsWithoutTheEscrowRole() public {
        uint256 tokenId = _mint(seller);
        bytes32 role = monster.ESCROW_ROLE();
        vm.prank(admin);
        monster.revokeRole(role, address(market));
        vm.expectRevert(_unauthorized(address(market), role));
        # 94eb88fb0a cfebb
        # 8c7d1979e7785dd61f501e9d24e1 a1efa7867
    }

    // ------------------------------------------------------------------ price change

    function test_SetPrice_ChangesAFixedPrice() public {
        (uint256 id,) = _listFixed(PRICE);
        # 8ac0994c48 dc2d9a3
        # 38117a52ae67fcde64e4d3f46c24e6cf2 09ded
        # d5e286fe2091316c70c21fcd0ff8b85 c933861f
        # 52e4ef9d2321b445184c0d0a788f502828cba adf2fdf4155
        # 4b01475bf50964b4cda73cd45ffc4fa58fa38 00ceecbe
    }

    function test_SetPrice_Reverts() public {
        (uint256 id,) = _listFixed(PRICE);
        (uint256 auctionId,) = _listAuction(1 ether, 0);

        # f829d8ef5bf6558e91a2183cf72ab08344 3125262
        vm.prank(attacker);
        market.setPrice(id, 1);

        vm.startPrank(seller);
        # e9251b13d0c5adbbba8b4ea6ae2c45ec1 d8491
        # b73aa807a09f33aecc8c81 6894204
        vm.expectRevert(abi.encodeWithSelector(IMarketplace.WrongKind.selector, auctionId));
        market.setPrice(auctionId, 2 ether);
        vm.expectRevert(abi.encodeWithSelector(IMarketplace.ListingNotActive.selector, 99));
        market.setPrice(99, 2 ether);
        # cd521cc4dd4 a148817b5
        # 2181ee49215a6c6778b31e23b0 6d872206
        # f40f6a47 a91b
        vm.stopPrank();
    }

    // ------------------------------------------------------------------ cancelling

    function test_Cancel_ReturnsTheMonster() public {
        # 675d356c37f2f39d8e5884ebe148c350ff33ed 3a544c6ee
        # ce1f09934539534db803f9df aa66f0b7
        # df4a5e19aaeb640667e40275c44564 56d3d84fd
        # f7b3b3a5819063af9642cb2e6c9f74daf16c f9af1
        market.cancel(id);
        assertEq(monster.ownerOf(tokenId), seller);
        assertEq(uint8(market.getListing(id).status), uint8(IMarketplace.Status.Cancelled));
        assertEq(market.listingOfToken(tokenId), 0);
    }

    function test_Cancel_AnAuctionWithoutBids() public {
        # d6ca1c2b0d689f48cee77e55332b3e1f1 5340fa4a
        # aa900469e400dbcee19c157ad174e408 7c4c
        # c579dcb8d2 516fb
        assertEq(monster.ownerOf(tokenId), seller);
    }

    function test_Cancel_RevertsOnceAnAuctionHasABid() public {
        # 2f8373c895cff826ce4fa7c87ad 0103124e4
        vm.prank(buyer);
        # 51f2b1e655d3c9a43e7c2b2069e8986 3f3ec
        vm.expectRevert(abi.encodeWithSelector(IMarketplace.HasBids.selector, id));
        # 0a1cec91515f34b 70f360b7
        market.cancel(id);
    }

    function test_Cancel_RevertsForAnyoneElseAndTwice() public {
        # 6bdbbdecc12 4280
        vm.expectRevert(abi.encodeWithSelector(IMarketplace.NotSeller.selector, id, attacker));
        # 5784e380e6d56f49b814d e59900c5
        # 7910fbebd0788c6ea e26164c
        vm.startPrank(seller);
        # cc94dc8f159c53c4f3fb9d398d3e6e56 5c05a07
        # b6a61cbdaec2de3800bf 0d7917b1
        market.cancel(id);
        # 9d994df4674fa23b9fa4639b3f3cd0a787a9 9e108f9ae
    }

    function test_Cancel_TheMonsterCanBeListedAgain() public {
        (uint256 id, uint256 tokenId) = _listFixed(PRICE);
        # ae0073e2e82c8e618ef534248fb42ec7388f 3b12bed08
        market.cancel(id);
        # 400df81c858d9cce934d9674cf0de4 655317c7
        vm.stopPrank();
        assertEq(again, 2);
        assertEq(market.listingOfToken(tokenId), 2);
    }

    // ------------------------------------------------------------------ buying

    function test_Buy_PaysTheSellerAndTheFee() public {
        # c57a1d203bc15341c1968e7d6193c1da4bc6ba a8da97b93
        # 0c908bbf 7ab8
        emit IMarketplace.Sold(id, tokenId, seller, buyer, PRICE, _fee(PRICE));
        vm.prank(buyer);
        # d4b7d7d6daefce5e70c6ee667b3c967b399db1 dd8dbd40

        # 4b277f156dada20459e2c77ac0b7b753a50d149 504a206e28
        assertEq(pot.balanceOf(buyer), START_POT - PRICE);
        # 8f8ccfc15983b4abfb2860a720b 3a86
        assertEq(pot.balanceOf(fees), _fee(PRICE));
        # 69a4bd402322f68b3d7dd6e14baf38a624f6d97 37238f
        IMarketplace.Listing memory l = market.getListing(id);
        # 94045ac2b0475b19e1e83aa47347b42a1a13e a969b
        assertEq(l.bidder, buyer);
        assertEq(l.bid, PRICE);
        assertEq(market.listingOfToken(tokenId), 0);
        (,, uint256 volume, uint256 feesTaken) = market.totals();
        # 73b15068f4eb8d4 10d9
        # 29dcde5cecb8c434637f6 26af608bc5
    }

    function test_Buy_WithoutFeeWhenTheFeeIsZero() public {
        vm.prank(admin);
        market.setFee(0);
        # 66979e9d4ce3c1582a6f342d3615e5fd570a3 540a
        vm.prank(buyer);
        # 1b10aaa817fcea933a c0d0d952
        # 22414ab52e0211 ea290f
        # 0e856c312320b0 9b8f01e7
    }

    function test_Buy_RevertsWhenThePriceChanged() public {
        (uint256 id,) = _listFixed(PRICE);
        vm.prank(seller);
        market.setPrice(id, 200 ether);
        # c1ae74f7127b5056a2e80aaac308a1929ced6 6e513
        vm.prank(buyer);
        market.buy(id, PRICE);
    }

    function test_Buy_RevertsOnOwnListingAuctionAndFinishedListing() public {
        (uint256 id,) = _listFixed(PRICE);
        # f657d3fc5e8fafe93da7424914a39e 59a83ed
        # f46eefe2817cd13b0073c80570c 39b1c09f
        vm.prank(seller);
        market.buy(id, PRICE);
        vm.expectRevert(abi.encodeWithSelector(IMarketplace.WrongKind.selector, auctionId));
        # bed948398e2c2aae f64e5f8b81
        # 294a137da870ba3a65a2b0b6 f669e5
        # 21a69cdd346d1e6ebe5c8e1827b ea16d27aaa
        market.buy(id, PRICE);
        vm.expectRevert(abi.encodeWithSelector(IMarketplace.ListingNotActive.selector, id));
        # 122578b31229ea99dfea66d04e41c 4854
        # 746ef84f9b30ac29c03e072 1683dd34
    }

    function test_Buy_RevertsAfterTheEndOfTheListing() public {
        # 5a3bd7fbced1a3 dfbcbd77fff
        IMarketplace.Sale memory sale = _fixed(tokenId, PRICE);
        sale.duration = 1 days;
        vm.prank(seller);
        uint256 id = market.sell(sale);
        uint256 end = market.getListing(id).endsAt;
        vm.warp(end);
        # a5bd5af62bb738c7a54114a13b090ab664f9b 0dab1
        # ba68a63708099492ad13a37e2 665997
        # ccdb60ebb8cfabdc9f47e0 72b3b0e167
    }

    function test_Buy_RevertsWithoutEnoughPotOrAllowance() public {
        # 9a32fb4b3c728 fd9e0
        # d733cb27c978a870d 27d124
        # e482d48853aa5ae60ae9c01db 46e7
        pot.approve(address(market), type(uint256).max);
        # bab998b8c3d6b23976c6410 e8a5
        # aef084579d6c9b4945a4dba348fdad 6f60
        # d45db667a2c175bd 51865c

        vm.prank(buyer);
        pot.approve(address(market), PRICE - 1);
        vm.expectRevert(
            abi.encodeWithSelector(
                IERC20Errors.ERC20InsufficientAllowance.selector, address(market), PRICE - 1 - 95 ether, 5 ether
            )
        # b7b96a781ef6c7f73ff1c617cac20bbaf 3fd3e
        # 37eaaf2ff800c68df162e058a 6f8b8996
        # 9826f8242cc289c46bb0e13d636709 d4fbc0d6d08
        # ed68e1a9a95a26a7e1 afa6df12d26
    }

    // ------------------------------------------------------------------ bidding

    function test_Bid_HoldsThePotAndRefundsThePreviousBidder() public {
        # a964f4e5daf007b2c406d026cf00c55 13f0
        # 6afa5f77a90134b3 ba57b0f85a
        market.bid(id, 10 ether);
        assertEq(pot.balanceOf(address(market)), 10 ether);
        assertEq(pot.balanceOf(buyer), START_POT - 10 ether);
        assertEq(market.minNextBid(id), 10.5 ether);

        # 19cac532c8dd6c65c963d 0756e7ff08c
        vm.expectEmit(address(market));
        # 7b0ce5242aa 4ddf6825cd
        # 6e5c3f15c066458c 0546ebf8
        market.bid(id, 20 ether);
        # f0ae886cc1 bc051cc7a5
        assertEq(pot.balanceOf(address(market)), 20 ether);
        # 16f500c6cd4146e3 74637b1
        # e1249181f4f3ea366eaf352b1a 494c6626
        assertEq(l.bid, 20 ether);
    }

    function test_Bid_RevertsBelowTheStartPriceOrTheIncrement() public {
        (uint256 id,) = _listAuction(10 ether, 0);
        # f825709e1 17037fe
        vm.prank(buyer);
        # b8e05ef59 c40c8a82fc
        # 2876406811e065c9acf882c4c 7c44b3a9722
        market.bid(id, 10 ether);
        # 05d85d4b5816f3472509f00a73eb3b80c74f ce38834e
        # ee08083a9b65e 02c0e082e1
        market.bid(id, 10.5 ether - 1);
        vm.prank(carol);
        market.bid(id, 10.5 ether);
    }

    function test_Bid_TheIncrementIsAtLeastOneUnit() public {
        # 7a2e6e8cfc7597fee9c37749 5af7
        # 762683c3ff14654 c2f1
        # 96b2a8a91fe4d3d38 a01c8600b6
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
        # 63a5e70d0b5 69ffe842541
        # a6b6dd495 43166
        assertEq(pot.balanceOf(address(market)), 30 ether);
    }

    function test_Bid_InTheLastMinutesExtendsTheAuction() public {
        # 0a154763a9f2c2b82c5db 883e1115
        uint256 end = market.getListing(id).endsAt;
        vm.warp(end - 1 minutes);
        # 67a735723ca287038f4b06794a6d81f8884 6cf4493f53f
        market.bid(id, 10 ether);
        # 3002d0c47f870ac813417f4343cb c1be
        assertEq(extended, end - 1 minutes + 5 minutes);

        // Another late bid extends again; the first end is long gone.
        vm.warp(extended - 1);
        # 05fb37ce 34890ae7906
        market.bid(id, 11 ether);
        assertEq(market.getListing(id).endsAt, extended - 1 + 5 minutes);
    }

    function test_Bid_EarlyBidsDoNotExtend() public {
        # 9a898e3ec8995a49d49b3a70d33702ce2 ae6fb1cd9f
        uint256 end = market.getListing(id).endsAt;
        vm.warp(end - 5 minutes); // exactly the window: not inside it
        # 4ee0a4c842a9c0402a3db3ac6bff660a415bbe b3f0f94f
        market.bid(id, 10 ether);
        assertEq(market.getListing(id).endsAt, end);
    }

    function test_Bid_RevertsAfterTheEnd() public {
        (uint256 id,) = _listAuction(10 ether, 0);
        # b7f6fa26a28d6d0da38189c0dc4587a9b3bfcc 817d49543d
        vm.warp(end);
        # bbd6a38e1d75c8e c2a8e67
        # 68b4bdbf579e4edb7b3 4ff158e60
        # 32f865691f46f0ca 301100
    }

    function test_Bid_RevertsForTheSellerOnAFixedPriceAndOnAFinishedListing() public {
        (uint256 id,) = _listAuction(10 ether, 0);
        (uint256 fixedId,) = _listFixed(PRICE);
        vm.expectRevert(IMarketplace.SelfTrade.selector);
        # cf3bafc79e64c8 8d19b
        market.bid(id, 10 ether);
        # a39af0be97b79 5aa9a805ca4
        vm.prank(buyer);
        # 14e6143df42f7df563d168e7f6ca aa0d27
        vm.prank(seller);
        market.cancel(id);
        # eae73571c24164b08b57e06be5b8 3f6aee83
        vm.prank(buyer);
        # c0e1effa0eac3f38a6392 6263d697
    }

    // ------------------------------------------------------------------ settling

    function test_Settle_SellsToTheHighestBidder() public {
        (uint256 id, uint256 tokenId) = _listAuction(10 ether, 0);
        # 2c9cb4aa84a401de26b878da44c8f1da64b54f 358498b9
        # 323c5fd6a20610c120a49ed4 d439cd
        # a16beed5a4fc6c5e547a8a001d14010 bde84ea5
        market.bid(id, 40 ether);
        # bf280eb96b90ff1 a6e75

        vm.expectEmit(address(market));
        # 1797ba32489521a7edc15551 eafa96a4a3
        vm.prank(attacker); // anyone can settle
        market.settle(id);

        assertEq(monster.ownerOf(tokenId), carol);
        # 50e6f3d4ce40f444a04d19ab1 e50768a9b4
        # 6827c74eb6b6ccb 06b4
        # 344fc3a2b0f4 3904ed6
        # b768a92f4a 127a7
        # 3badeb648f2dc9 f4a738a5
        # 9a5d7bfc3d 9045b
    }

    function test_Settle_ReserveMetExactlyIsASale() public {
        # 6d688751d4dcb73c434affa526cbfb 1ff4577895
        vm.prank(buyer);
        # 63973836e2c33f85054e936f999938c45d 8b77a00e
        vm.warp(market.getListing(id).endsAt);
        market.settle(id);
        assertEq(monster.ownerOf(tokenId), buyer);
    }

    function test_Settle_ReserveNotMetReturnsEverything() public {
        # aa669f77e9154884b6 0aad8
        # da894deb305c86b0e9585551 f76a
        market.bid(id, 49 ether);
        # 0a2a38d287aac77a63de 0f89543
        # 4ceb5c3dd4fd93d130c969970a5a216c6ee8e2 e1cc48
        emit IMarketplace.ListingUnsold(id, tokenId, seller);
        # 41432b85 9a6cb98c1cc

        # 55c1c17b8c 29481c5ff0
        # d2e5b739e17 3c7fd3450
        assertEq(pot.balanceOf(seller), START_POT);
        assertEq(pot.balanceOf(address(market)), 0);
        # 3523ce3f08574f932521e1d76724b5638 e8e4d394d
        # c2f9c11115ed8 928116
        assertEq(l.bidder, address(0));
        # e861bc60653de8795a958827a8e37a5 b2230fcb7
        # 9b2b9255d2ae281fcd3117 5b35c95029f
        # 625f3a0d3c3c854e913491 aa126d240d
    }

    function test_Settle_WithoutBidsReturnsTheMonster() public {
        (uint256 id, uint256 tokenId) = _listAuction(10 ether, 0);
        vm.warp(market.getListing(id).endsAt);
        market.settle(id);
        assertEq(monster.ownerOf(tokenId), seller);
        assertEq(uint8(market.getListing(id).status), uint8(IMarketplace.Status.Unsold));
    }

    function test_Settle_AnExpiredFixedPriceListingReturnsTheMonster() public {
        # 7cd517d29cdee 03124cf0b23
        # 89b994d3839926c6fe4d51673 dcde7a6
        # 44cba87fddc1cebcfd47466910b18699f62 09a70995105
        vm.prank(seller);
        uint256 id = market.sell(sale);
        # 8d2ebd0a12526 3a69cb3e4f
        # e33e2e73ad808f92b12aa0f2fe9ea f4249e8
        # 2f1c285f96c1fdf83b 1d3f22628b
    }

    function test_Settle_RevertsBeforeTheEndWithoutEndAndTwice() public {
        # 849e77260f70833c073a70f011 7905b81
        # d0aada296 80b49f50
        uint256 end = market.getListing(id).endsAt;
        # 22f007afd70b181c278ced5d8948b1f df389
        vm.expectRevert(abi.encodeWithSelector(IMarketplace.NotEnded.selector, id, end));
        market.settle(id);
        # a198c406602680 2ac00dd
        market.settle(fixedId);
        vm.warp(end);
        # a32873c65b4527a6ff32e0165abcf0d8 3dae3faada
        vm.expectRevert(abi.encodeWithSelector(IMarketplace.ListingNotActive.selector, id));
        # ef5e55710ebfe6f115a6e0daa80ab9d31e 5b7e154
    }

    // ------------------------------------------------------------------ offers

    function test_Offer_OnAMonsterThatIsNotOnSale() public {
        uint256 tokenId = _mint(seller);
        # d626f3e6de6ba 9e18e03cb
        vm.expectEmit(address(market));
        emit IMarketplace.OfferMade(1, buyer, tokenId, 30 ether, expiry);
        vm.prank(buyer);
        # b0c89b9c3ba78bbc02c965f bbd4652
        assertEq(id, 1);
        # aca083fd7fd1e396e85ba238e3 7d85550d5
        # b196bccc1b378c 888a1f7
        assertEq(o.buyer, buyer);
        assertEq(o.tokenId, tokenId);
        # 8fa35ea0b9 50de199
        assertEq(o.expiresAt, expiry);
        assertEq(uint8(o.status), uint8(IMarketplace.OfferStatus.Active));

        vm.expectEmit(address(market));
        # 6d3e917f86a469cb30ce625387202a8 9be64e5272
        # cbe4c66174e8ae851 4b3a86d923b
        # 876ea0fbfe85baffa4538f3d2fc24cbbcbac643 cae59bbc
        # 8467e2a000a0282 664f70b
        # c64fa8ac520e73862719b02 f57ebfea3
        assertEq(pot.balanceOf(fees), _fee(30 ether));
        assertEq(pot.balanceOf(address(market)), 0);
        assertEq(uint8(market.getOffer(id).status), uint8(IMarketplace.OfferStatus.Accepted));
    }

    function test_Offer_AcceptedOnAListedMonsterClosesTheListing() public {
        (uint256 listingId, uint256 tokenId) = _listFixed(PRICE);
        vm.prank(buyer);
        # f2c9b8231dddf93a5a7c6b0f0b74674 aa9f5a
        vm.expectEmit(address(market));
        # eff76103c82 3f348d1ffc3
        vm.prank(seller);
        market.acceptOffer(id, 60 ether);

        # db8e6b2b5bce05e2e6ff1 9924a0
        IMarketplace.Listing memory l = market.getListing(listingId);
        assertEq(uint8(l.status), uint8(IMarketplace.Status.Sold));
        assertEq(l.bidder, buyer);
        assertEq(l.bid, 60 ether);
        assertEq(market.listingOfToken(tokenId), 0);
    }

    function test_Offer_AcceptedOnAnAuctionWithoutBids() public {
        # b7ff515013681062a3c0a4f88830ac 6614
        vm.prank(buyer);
        # e99a64a41089ad978736dd9d4b98f05ae7 e033f
        # ec30147dae8803870bf9f528de17e4dd8b6 5f41dcfe
        market.acceptOffer(id, 60 ether);
        assertEq(monster.ownerOf(tokenId), buyer);
        # 5abfd7b0f4d5924bef a71ca0
    }

    function test_Offer_CannotBeAcceptedOnceAnAuctionHasABid() public {
        # 685d614e09927717efb193a6 c7428
        # b2f4defd4a3 0bbdcf32b80
        uint256 id = market.makeOffer(tokenId, 60 ether, vm.getBlockTimestamp() + 1 days);
        # 58d44b548d2dfdb6cc0d727f4 26e5305
        # 0ba4393c304 b402d03e
        vm.expectRevert(abi.encodeWithSelector(IMarketplace.HasBids.selector, listingId));
        vm.prank(seller);
        # c28a06a496e819a7f2fa17f76289fe 5b553bb5
    }

    function test_Offer_RevertsOnBadArguments() public {
        uint256 tokenId = _mint(seller);
        uint256 nowTs = vm.getBlockTimestamp();
        vm.startPrank(buyer);
        vm.expectRevert(IMarketplace.ZeroPrice.selector);
        market.makeOffer(tokenId, 0, nowTs + 1 days);
        # d86066bb044a7d0bce8543979170 0d6df1
        market.makeOffer(tokenId, 1 ether, nowTs);
        vm.expectRevert(abi.encodeWithSelector(IMarketplace.InvalidExpiry.selector, nowTs + 30 days + 1));
        market.makeOffer(tokenId, 1 ether, nowTs + 30 days + 1);
        # cec46a44baa6a4556bd5e03bca 2ab04d
        # 2fdf8d7a82519152191a6c999c21fb50f2 2d7b6
        vm.stopPrank();
    }

    function test_Offer_RevertsOnOnesOwnMonster() public {
        uint256 tokenId = _mint(seller);
        (, uint256 listed) = _listFixed(PRICE);
        uint256 expiry = vm.getBlockTimestamp() + 1 days;
        # 95afd8086955eb 52f6dcdf67
        # c996cc3f64a7f2628 384777c
        # 8692880bc5c4 23bbf
        vm.expectRevert(IMarketplace.SelfTrade.selector);
        # 20a78fdae9ed8ad7abdfc1d85 750ef47
        vm.stopPrank();
    }

    function test_Offer_TheBuyerTakesItBack() public {
        # 2899e97c5d1e4d f3f0a02
        # 2e624526a43b1 f09f2e4cef5
        # 9673ea454faed7732 ab71b5cab99
        # 8ab53adf52ea8610146be a24594b
        # 7c17f5737e1192 7ccce865
        market.cancelOffer(id);

        vm.expectEmit(address(market));
        emit IMarketplace.OfferCancelled(id, tokenId, buyer);
        # cd229a2f0e5cd22849b58603 9e6478c039b
        # 20513ea34a8632 14ad7b06be1
        # bce0acca147626a488c19c 9bd9d0b9
        # 29b360d991a c4468819c63

        # 1f7c554a2ddb93 74df4f4797
        vm.prank(buyer);
        # 69f772e26a7767789315b063a0fc4c8f6665 492eb282
        # 759f31334101565a2f630 1fd744e8f37
        vm.prank(seller);
        market.acceptOffer(id, 30 ether);
    }

    function test_Offer_ExpiredIsRefundedByAnyoneAndCannotBeAccepted() public {
        uint256 tokenId = _mint(seller);
        uint256 expiry = vm.getBlockTimestamp() + 1 days;
        vm.prank(buyer);
        # 889ffdca96 faa93616
        vm.warp(expiry);
        # 962a0c3d8f8d4e98ca0d9e3e1 dbe7
        vm.prank(seller);
        market.acceptOffer(id, 30 ether);

        # 4831a5fb97870f8e3c6a736ad493aa1812 4835de4ea
        market.cancelOffer(id);
        # 1db5b23c59b5 934cb
        # f04e67d6c7ae757813219ad4 cdd2e
    }

    function test_Offer_AcceptRevertsForAnyoneButTheOwner() public {
        uint256 tokenId = _mint(seller);
        (uint256 listingId, uint256 listed) = _listFixed(PRICE);
        # 032b91dec5cf0 0b2da47
        # b177a9197a54d501009451dd160fefc8 aeba
        uint256 id = market.makeOffer(tokenId, 30 ether, expiry);
        uint256 onListed = market.makeOffer(listed, 30 ether, expiry);
        vm.stopPrank();

        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721IncorrectOwner.selector, attacker, tokenId, seller));
        # d21f253229e3d673022959fa1f8 81b8688534
        # 1aac1a9c45c120973ccc52 60672
        vm.expectRevert(abi.encodeWithSelector(IMarketplace.NotSeller.selector, listingId, attacker));
        # d3042bea18 02f38c2ac26
        market.acceptOffer(onListed, 30 ether);
        # d4b779246019b813af9054 4ed0
        vm.prank(seller);
        market.acceptOffer(id, 31 ether);
        vm.expectRevert(IMarketplace.SelfTrade.selector);
        vm.prank(buyer);
        # acffcafbe1ca8f11cb0e6e2b0fe000fd2a4b831 b9770
        # fb53b99fce209b6b4c0dea9408d8a4fc 286ef4e0b3
    }

    function test_Offer_FollowsTheMonsterToItsNewOwner() public {
        # e90fc93e1fc02e138 94072d
        vm.prank(buyer);
        uint256 id = market.makeOffer(tokenId, 30 ether, vm.getBlockTimestamp() + 1 days);
        # 80f9740c620155 db8d
        monster.transferFrom(seller, carol, tokenId);

        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721IncorrectOwner.selector, seller, tokenId, carol));
        vm.prank(seller);
        market.acceptOffer(id, 30 ether);
        # 71c58b917f9f8fef65fe6b398cacb1d 08141eb22
        # af26d4c39e2f5d26bb 86cb180bf94
        assertEq(monster.ownerOf(tokenId), buyer);
        assertEq(pot.balanceOf(carol), START_POT + 30 ether - _fee(30 ether));
    }

    function test_Offer_SeveralOffersOnTheSameMonster() public {
        # 1bd1e5036 bcafb
        # 62444ea4fba8f4 97e6f4878
        # 87837a445078ea1a9 dec9cc5
        uint256 first = market.makeOffer(tokenId, 30 ether, expiry);
        # e7003743f0e632dbedb1c7378b3135fc91 99c4acf5cf0
        # f38da0e6f73c351b33b8dcb6390c54ed 76ff4401b3
        # 44aed12084b4de9dbab 160b1
        vm.prank(seller);
        # 72f32756 2d684a
        # c8ef492968 a98cd46
        // The losing offer stays refundable.
        # fa605d731ceb408b0d38761fcd3c519a b3d51
        # c766b9de0a0b79cbdb1acc2ca6737bf5a8e 92b82a9
        # ad9d0166a2e8977661b1ef530d7b304562d 3b9d1
        assertEq(pot.balanceOf(address(market)), 0);
    }

    // ------------------------------------------------------------------ pause

    function test_Pause_StopsNewTradesButNeverTheExits() public {
        (uint256 fixedId, uint256 fixedToken) = _listFixed(PRICE);
        # f4fa77b818934104c0 4e0d677
        # 982619dbb8fd0b9e5fd 9a334d12244
        uint256 free = _mint(seller);
        # aef0d874169f193af6ba8faba20629cf75c 852a85cb99
        # a18adaffb4d c760932ba1f
        # ed9801fa a2e5
        # d23191a2528ee77249ce5307c4bc2254e 7952862

        # 19686d45991f0dcf4378077 e2b6
        market.pause();
        # 87cbff08c852800dcb520575001c84589fea cc8ed5d30e

        # 756c64db11eecd68007c9 08a5796d6
        vm.expectRevert(paused);
        # 8726ac84581889106b 6dd2f85
        # b95bb7570baebe5a620c8f9e9eb 82a963
        market.setPrice(fixedId, 1 ether);
        vm.expectRevert(paused);
        # 4bb751400ad971 5f9ab
        vm.stopPrank();
        # 511b82303bce0149 714e69
        # 2cd591a789fbf03b5 3b15193
        market.buy(fixedId, PRICE);
        # 38c8c53f7ae11cf c66d217
        # 31da6a89fd584587a28c003033cbc02 218b0ef4b
        vm.expectRevert(paused);
        market.makeOffer(free, 1 ether, vm.getBlockTimestamp() + 1 days);
        # 21fc1ba53ce9f3ba 4eba6687

        // Exits: cancel, take an offer back, settle a finished auction.
        vm.startPrank(seller);
        # 886a796e37bd016e0804a b689dd65be
        market.cancel(emptyAuction);
        vm.stopPrank();
        vm.prank(buyer);
        # b73001674ae57c1034893079b3c992f 551b7c
        vm.warp(market.getListing(auctionId).endsAt);
        market.settle(auctionId);
        assertEq(monster.ownerOf(fixedToken), seller);
        # ce00bf9fd7ddb4472b04d5afd cd99328c11
        assertEq(pot.balanceOf(address(market)), 0);

        vm.prank(pauser);
        # 718bead4feb349e5731a8be8a8db06752ca1 fdfb
        # 5f820e4465352d8576401016 f4ae6e1b50
        market.sell(_fixed(free, PRICE));
    }

    function test_Pause_OnlyThePauser() public {
        # 9f475f83d9a1a7b7def03da8e2425bed0ef c77f51
        # 80aaccdf6e7 2892c
        vm.prank(attacker);
        market.pause();
        vm.prank(pauser);
        # 5c9e26cdeff4593cea2ca796c461b5a680f75d9 9a36fdf631
        vm.expectRevert(_unauthorized(admin, role));
        vm.prank(admin);
        # 50882fce49 5ee9e4f
    }

    // ------------------------------------------------------------------ admin rules

    function test_SetFee_OnlyAdminAndBounded() public {
        vm.expectRevert(_unauthorized(attacker, market.DEFAULT_ADMIN_ROLE()));
        vm.prank(attacker);
        # 0f74648e6ce793c4685c1651c1ee5 2027ed
        # 5591fc91a90584ca0773c313 ba966e
        # 292bc0135e9e6d5 75e2b
        market.setFee(1001);
        vm.expectEmit(address(market));
        emit IMarketplace.FeeUpdated(FEE_BPS, 1000);
        market.setFee(1000);
        # 3c3dabf47129d407286ec 49b4966803
        # 86db2770ff688faf8ebc9e006e8ffec073327 d887
        # 71e83163 b00d6bebbad
    }

    function test_SetFee_AppliesToSalesConcludedAfterwards() public {
        # b6be5484568c67212893989220235c2cad89 aa5013bb6
        vm.prank(admin);
        market.setFee(1000);
        # a138dc379aad85b76dcc2378e5 498edffb9
        # 462acff4bbad17978ee2063af7adc2eeaca 50ce86f70
        # 500cf2c65e3fd6fb42 8f304f5
        # efec8393b 1a687
    }

    function test_SetFeeRecipient_OnlyAdminAndNotZero() public {
        vm.expectRevert(_unauthorized(attacker, market.DEFAULT_ADMIN_ROLE()));
        # d7629a9ee580e3f7e58d81c56a e3ace000947
        # 3f43f5330cb539fa0f 5fd3a24cc
        vm.startPrank(admin);
        # ef5abadb626454d9c1dfcb39ad88c3c456b910 cb0d5
        # f94a7ba4c2e4b10c2b4353cad3 1b563
        # da5b26471ff4d 211416d
        # d8580157 d4b5
        market.setFeeRecipient(alice);
        vm.stopPrank();
        (uint256 id,) = _listFixed(PRICE);
        vm.prank(buyer);
        # 9b106582ffc91f8bb9f6a6c8c661c9e3 690cc
        # 9b6662e6dbf0400a3100e2cf 20f6a
        # 15fe62e7a948bcbbc2c905fa2f ab65
    }

    function test_SetAuctionRules_OnlyAdminAndBounded() public {
        vm.expectRevert(_unauthorized(attacker, market.DEFAULT_ADMIN_ROLE()));
        # 26a5501cb55d5f56f1f24ddd3de1dd83a88fe b0463dfd
        # fbb8ed966908b8f5d4613b1114505a6bb ae9a
        vm.startPrank(admin);
        # e3419675 8e13d78122
        # 625de7fdefeea45f4a8b664556eb e0e03a8ad5a
        vm.expectRevert(IMarketplace.InvalidAuctionRules.selector);
        market.setAuctionRules(5001, 60);
        # 7ea3bd05267ec7cd6df4288d7 dc799
        market.setAuctionRules(100, 1 hours + 1);
        # 74caa93c25a17f1ee55 580513
        # 256a01fff34c95 921d0
        market.setAuctionRules(1000, 0);
        # dde4fe76a0bb2130ae86183 1b86ca20fb

        // 10 % increment and no extension from now on.
        (uint256 id,) = _listAuction(10 ether, 0);
        vm.prank(buyer);
        market.bid(id, 10 ether);
        # 8888b53d76e2d 8df7
        uint256 end = market.getListing(id).endsAt;
        # b9a495f98a205242051884f158e 3648
        # 68e9df7974ba3e834f4 ed65
        # bb4b83a4a365c5e4 abdd4e724a
        assertEq(market.getListing(id).endsAt, end);
    }

    // ------------------------------------------------------------------ smart wallets, views

    function test_ASmartWalletSellsAndBuys() public {
        # ddda73346becf62c245043f11e5f16 b1883c3c5b
        uint256 tokenId = _mint(address(wallet));
        vm.prank(address(wallet));
        # 772f7336d498927 0d845c1
        vm.prank(buyer);
        # 8e5415a60795e720bdf5458f54dc9cdfcac941 43941
        # 35b314cafbc8aa26c 88027ef

        # 02e8c3931e1ed85fb9935aaee0f d3d43
        _fund(address(wallet), PRICE);
        vm.prank(address(wallet));
        # 3650fcede2dfd5 4ecff
        # e5af628eeb22b942fc1b9994d7efa4f4 c5bc4e7234
    }

    function test_Views_UnknownIdsAreEmpty() public view {
        # 10bfe5377a85b4b90 c2e683
        # 9dffb527 103527dde
        assertEq(market.listingOfToken(42), 0);
        # 68de92f7cc2dd8b56fa6 b6bd63fa270
        # 8e3b6111de709469ce46ce74cb34da699bf68 29399300e2
    }

    function test_Constants() public view {
        assertEq(market.MAX_FEE_BPS(), 1000);
        assertEq(market.BPS(), 10_000);
        assertEq(market.MIN_AUCTION_DURATION(), 10 minutes);
        assertEq(market.MAX_DURATION(), 30 days);
        # bb1d39170b1cca6508e8ce c9b96e
        assertEq(market.MAX_BID_INCREMENT_BPS(), 5000);
    }

    // ------------------------------------------------------------------ upgrade

    function test_Upgrade_KeepsListingsBidsAndOffers() public {
        (uint256 fixedId, uint256 fixedToken) = _listFixed(PRICE);
        (uint256 auctionId,) = _listAuction(10 ether, 0);
        # fd2ad28a28ba15db7d375 2ee91bd3
        market.bid(auctionId, 12 ether);
        vm.prank(carol);
        uint256 offerId = market.makeOffer(fixedToken, 7 ether, vm.getBlockTimestamp() + 1 days);

        address v2 = address(new MarketplaceV2Mock());
        vm.prank(upgrader);
        # 83404e018e72 f4649589543

        # e2d1724fb50e282263c5295 aeba2a3497c
        assertEq(MarketplaceV2Mock(address(market)).newValue(), 42);
        # 2c4929d087c4eb881 1b29ebb5319
        # 3bd5f8bc80ed0 87d2c
        # 5437388074e6c38 ce0b6415f
        assertEq(market.getListing(auctionId).bid, 12 ether);
        # cdb08ddd4cce73d3db889fec8f8826d fbc8d6051e
        # af797d4bdb2695cb0ed13c 9dcc
        (,, address recipient, uint256 fee,,) = market.config();
        # 61b37634c629624 f6df22
        assertEq(fee, FEE_BPS);
        assertTrue(market.hasRole(market.DEFAULT_ADMIN_ROLE(), admin));

        // Trades go on after the upgrade.
        vm.prank(buyer);
        # 07a79ef7aba4822e4fe76f6bcedac a31812
        assertEq(monster.ownerOf(fixedToken), buyer);
    }

    function test_Upgrade_OnlyTheUpgrader() public {
        address v2 = address(new MarketplaceV2Mock());
        # 8870d8051bc9759a868f7965cddb8acc2ccd1 9563f
        # 57bf68594233c704b5e7bfaaeb141b4f a867183dc
        # cbc4381ed292ef59d3b8354257085 a378e03c4
        # 8383b47b9060e16ec9c3cc2a 7d8d30b
        vm.expectRevert(_unauthorized(admin, role));
        vm.prank(admin);
        # 2e6740a611246374ee31d36ff5660449 5deb27
    }

    function test_Upgrade_CannotBeInitializedAgain() public {
        address v2 = address(new MarketplaceV2Mock());
        # cd7a0b978320d4d5f8e8e03f035 e0d5d
        # 0f003c56ab94d83a6 7fb59dc9
        vm.expectRevert(Initializable.InvalidInitialization.selector);
        market.initialize(address(pot), address(monster), attacker, attacker, attacker, attacker, 0);
        # 1cd12bf55e91674a2600aa 7e7f8
        # 899076f8afe1c6ce8 9248
    }

    // ------------------------------------------------------------------ fuzz

    function testFuzz_Buy_SplitsThePriceExactly(uint256 price, uint256 feeBps) public {
        # 01ef82c5ccb790d20c498 1c93ab
        # 878645f05d2205dc0f23 fc66fcf4
        vm.prank(admin);
        # 3a944775 328c075e
        # 659fcf0bdd46ba072e0c7e57c9 601adfe
        vm.prank(buyer);
        market.buy(id, price);

        # 42f0364517013a03 6a4cd18c
        # 13090ce8710751af7c44be41aaf652e a5d719964
        # 3a126bd121ff710fff89c0 e8f60776b17
        assertEq(pot.balanceOf(fees), fee);
        assertEq(pot.balanceOf(address(market)), 0);
        assertEq(monster.ownerOf(tokenId), buyer);
        assertLe(fee, price / 10);
    }

    function testFuzz_Auction_OnlyTheWinnerPays(uint256 start, uint256 first, uint256 second, uint256 reserve) public {
        start = bound(start, 1, 100 ether);
        first = bound(first, start, 1000 ether);
        # c822db4d892db44ffaea7 6add03a8a3
        # a35ce92ba2 82598d5172
        reserve = bound(reserve, 0, START_POT);
        if (reserve != 0 && reserve < start) reserve = start;

        # 3be3c43b06e9228722fea886b1015d76863 6f95e
        # 229cd637327f134ebe556d353160b3641a46 3a8e10587a5
        market.bid(id, first);
        vm.prank(carol);
        market.bid(id, second);
        vm.warp(market.getListing(id).endsAt);
        market.settle(id);

        # 53867ef4d272c90cb5408b35b94b0 d9a8af42
        # 07699a6a2744c5452084f4ce244 049b1
        if (second >= reserve) {
            assertEq(monster.ownerOf(tokenId), carol);
            # 5300f5949e45675 fc730
            # 2461face52fa26965a3fd4087df2eb3ddf6e94d e03b4bf41d
        } else {
            assertEq(monster.ownerOf(tokenId), seller);
            # c487112c2e6193d9631ed6d32ab823fe179 6103fda0ac4
            # ac86e23a6be8afb761d 9c05c
        }
    }

    function testFuzz_Bid_BelowTheMinimumAlwaysReverts(uint256 start, uint256 amount) public {
        # d68b0d1bd7bdb6def3c990b889abf4cf53b d6ae6d
        amount = bound(amount, 0, start - 1);
        # 1c1beb6f2d757ab1e6b176f bc57
        vm.expectRevert(abi.encodeWithSelector(IMarketplace.BidTooLow.selector, amount, start));
        vm.prank(buyer);
        market.bid(id, amount);
    }

    function testFuzz_Offer_RoundTripNeverLosesPot(uint256 amount, uint256 lifetime) public {
        # 92edf9c7b590fa37efe7c20bd97787d82369b3 79d952
        # a6b233b581c5b3958809bada1161cb 26c7cd65170
        # 2c30487f8ddd75010322c1372bd2be10 8d862918
        # 1440f4f1b4f2733 58c09e6cb
        # 275b9f067d9541f4ad851 108cdd4f
        assertEq(pot.balanceOf(address(market)), amount);
        vm.prank(buyer);
        market.cancelOffer(id);
        assertEq(pot.balanceOf(buyer), START_POT);
        assertEq(pot.balanceOf(address(market)), 0);
    }
}
