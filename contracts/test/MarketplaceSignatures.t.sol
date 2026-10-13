// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {IERC721Errors} from "@openzeppelin/contracts/interfaces/draft-IERC6093.sol";
import {PausableUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";

import {IMarketplace} from "../src/interfaces/IMarketplace.sol";
import {MonsterWallet} from "./MonsterBurn.t.sol";
import {MarketFixture} from "./utils/MarketFixture.sol";

/// @notice The marketplace driven by signed messages (EIP-712) relayed by someone else: in the game, SYSTEM relays
///         and the players pay no gas. No asset moves without the signature of its owner.
contract MarketplaceSignaturesTest is MarketFixture {
    uint256 internal constant PRICE = 100 ether;
    address internal relayer = makeAddr("relayer");
    uint256 internal deadline;

    function setUp() public override {
        super.setUp();
        deadline = vm.getBlockTimestamp() + 10 minutes;
    }

    function _signedSell(uint256 key, address who, IMarketplace.Sale memory sale) internal returns (uint256 id) {
        bytes memory signature = _sign(key, _sellHash(who, sale, deadline));
        vm.prank(relayer);
        id = market.sellWithSignature(who, sale, deadline, signature);
    }

    // ------------------------------------------------------------------ the whole flow, relayed

    function test_FixedPriceSale_FullyRelayed() public {
        uint256 tokenId = _mint(seller);
        uint256 id = _signedSell(sellerKey, seller, _fixed(tokenId, PRICE));
        assertEq(monster.ownerOf(tokenId), address(market));
        assertEq(market.nonces(seller), 1);

        bytes memory change = _sign(sellerKey, _hash3(market.SET_PRICE_TYPEHASH(), seller, id, 80 ether, deadline));
        vm.prank(relayer);
        market.setPriceWithSignature(seller, id, 80 ether, deadline, change);
        assertEq(market.getListing(id).price, 80 ether);
        assertEq(market.nonces(seller), 2);

        bytes memory purchase = _sign(buyerKey, _hash3(market.BUY_TYPEHASH(), buyer, id, 80 ether, deadline));
        vm.prank(relayer);
        market.buyWithSignature(buyer, id, 80 ether, deadline, purchase);
        assertEq(monster.ownerOf(tokenId), buyer);
        assertEq(pot.balanceOf(seller), START_POT + 80 ether - _fee(80 ether));
        assertEq(pot.balanceOf(relayer), 0);
        assertEq(market.nonces(buyer), 1);
    }

    function test_Auction_FullyRelayed() public {
        uint256 tokenId = _mint(seller);
        uint256 id = _signedSell(sellerKey, seller, _auction(tokenId, 10 ether, 20 ether, 1 days));

        bytes memory first = _sign(buyerKey, _hash3(market.BID_TYPEHASH(), buyer, id, 10 ether, deadline));
        vm.prank(relayer);
        market.bidWithSignature(buyer, id, 10 ether, deadline, first);
        bytes memory second = _sign(carolKey, _hash3(market.BID_TYPEHASH(), carol, id, 25 ether, deadline));
        vm.prank(relayer);
        market.bidWithSignature(carol, id, 25 ether, deadline, second);
        assertEq(pot.balanceOf(buyer), START_POT);

        vm.warp(market.getListing(id).endsAt);
        vm.prank(relayer);
        market.settle(id);
        assertEq(monster.ownerOf(tokenId), carol);
        assertEq(pot.balanceOf(seller), START_POT + 25 ether - _fee(25 ether));
    }

    function test_Cancel_Relayed() public {
        (uint256 id, uint256 tokenId) = _listFixed(PRICE);
        bytes memory signature = _sign(sellerKey, _hash2(market.CANCEL_TYPEHASH(), seller, id, deadline));
        vm.prank(relayer);
        market.cancelWithSignature(seller, id, deadline, signature);
        assertEq(monster.ownerOf(tokenId), seller);
    }

    function test_Offer_FullyRelayed() public {
        uint256 tokenId = _mint(seller);
        uint256 expiry = vm.getBlockTimestamp() + 1 days;
        bytes memory offer = _sign(buyerKey, _offerHash(buyer, tokenId, 30 ether, expiry, deadline));
        vm.prank(relayer);
        uint256 id = market.makeOfferWithSignature(buyer, tokenId, 30 ether, expiry, deadline, offer);
        assertEq(pot.balanceOf(address(market)), 30 ether);

        bytes memory accept = _sign(sellerKey, _hash3(market.ACCEPT_OFFER_TYPEHASH(), seller, id, 30 ether, deadline));
        vm.prank(relayer);
        market.acceptOfferWithSignature(seller, id, 30 ether, deadline, accept);
        assertEq(monster.ownerOf(tokenId), buyer);
        assertEq(pot.balanceOf(seller), START_POT + 30 ether - _fee(30 ether));
    }

    function test_CancelOffer_Relayed() public {
        uint256 tokenId = _mint(seller);
        vm.prank(buyer);
        uint256 id = market.makeOffer(tokenId, 30 ether, vm.getBlockTimestamp() + 1 days);
        bytes memory signature = _sign(buyerKey, _hash2(market.CANCEL_OFFER_TYPEHASH(), buyer, id, deadline));
        vm.prank(relayer);
        market.cancelOfferWithSignature(buyer, id, deadline, signature);
        assertEq(pot.balanceOf(buyer), START_POT);
    }

    // ------------------------------------------------------------------ what a relayer cannot do

    function test_Sell_RevertsWithSomeoneElsesSignature() public {
        uint256 tokenId = _mint(seller);
        IMarketplace.Sale memory sale = _fixed(tokenId, PRICE);
        bytes memory forged = _sign(buyerKey, _sellHash(seller, sale, deadline));
        vm.expectRevert(IMarketplace.InvalidSignature.selector);
        vm.prank(relayer);
        market.sellWithSignature(seller, sale, deadline, forged);
        assertEq(monster.ownerOf(tokenId), seller);
        assertEq(market.nonces(seller), 0); // a refused message uses no nonce
    }

    function test_Sell_TheThiefCannotSignForAMonsterTheyDoNotOwn() public {
        uint256 tokenId = _mint(seller);
        IMarketplace.Sale memory sale = _fixed(tokenId, PRICE);
        bytes memory own = _sign(buyerKey, _sellHash(buyer, sale, deadline));
        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721IncorrectOwner.selector, buyer, tokenId, seller));
        vm.prank(relayer);
        market.sellWithSignature(buyer, sale, deadline, own);
    }

    function test_Sell_RevertsWhenTheRelayerChangesTheTerms() public {
        uint256 tokenId = _mint(seller);
        IMarketplace.Sale memory sale = _fixed(tokenId, PRICE);
        bytes memory signature = _sign(sellerKey, _sellHash(seller, sale, deadline));

        IMarketplace.Sale memory cheaper = _fixed(tokenId, 1);
        vm.expectRevert(IMarketplace.InvalidSignature.selector);
        vm.prank(relayer);
        market.sellWithSignature(seller, cheaper, deadline, signature);

        IMarketplace.Sale memory asAuction = _auction(tokenId, PRICE, 0, 1 days);
        vm.expectRevert(IMarketplace.InvalidSignature.selector);
        vm.prank(relayer);
        market.sellWithSignature(seller, asAuction, deadline, signature);

        vm.expectRevert(IMarketplace.InvalidSignature.selector);
        vm.prank(relayer);
        market.sellWithSignature(seller, sale, deadline + 1, signature);
    }

    function test_ASignatureCannotBeReplayed() public {
        uint256 tokenId = _mint(seller);
        IMarketplace.Sale memory sale = _fixed(tokenId, PRICE);
        bytes memory signature = _sign(sellerKey, _sellHash(seller, sale, deadline));
        vm.prank(relayer);
        uint256 id = market.sellWithSignature(seller, sale, deadline, signature);
        vm.prank(seller);
        market.cancel(id);
        // The monster is back in the seller's wallet: the old signature must not list it again.
        vm.expectRevert(IMarketplace.InvalidSignature.selector);
        vm.prank(relayer);
        market.sellWithSignature(seller, sale, deadline, signature);
        assertEq(monster.ownerOf(tokenId), seller);
    }

    function test_ExpiredSignaturesAreRefused() public {
        uint256 tokenId = _mint(seller);
        (uint256 id,) = _listFixed(PRICE);
        IMarketplace.Sale memory sale = _fixed(tokenId, PRICE);
        bytes memory listing = _sign(sellerKey, _sellHash(seller, sale, deadline));
        bytes memory purchase = _sign(buyerKey, _hash3(market.BUY_TYPEHASH(), buyer, id, PRICE, deadline));
        bytes memory cancel = _sign(sellerKey, _hash2(market.CANCEL_TYPEHASH(), seller, id, deadline));

        vm.warp(deadline + 1);
        bytes memory expired = abi.encodeWithSelector(IMarketplace.SignatureExpired.selector, deadline);
        vm.startPrank(relayer);
        vm.expectRevert(expired);
        market.sellWithSignature(seller, sale, deadline, listing);
        vm.expectRevert(expired);
        market.buyWithSignature(buyer, id, PRICE, deadline, purchase);
        vm.expectRevert(expired);
        market.cancelWithSignature(seller, id, deadline, cancel);
        vm.stopPrank();
    }

    function test_TheDeadlineItselfIsStillValid() public {
        (uint256 id, uint256 tokenId) = _listFixed(PRICE);
        bytes memory purchase = _sign(buyerKey, _hash3(market.BUY_TYPEHASH(), buyer, id, PRICE, deadline));
        vm.warp(deadline);
        vm.prank(relayer);
        market.buyWithSignature(buyer, id, PRICE, deadline, purchase);
        assertEq(monster.ownerOf(tokenId), buyer);
    }

    function test_Buy_RevertsWithAForgedOrRepurposedSignature() public {
        (uint256 id,) = _listFixed(PRICE);
        (uint256 other,) = _listFixed(PRICE);
        // Signed by carol in the buyer's name.
        bytes memory forged = _sign(carolKey, _hash3(market.BUY_TYPEHASH(), buyer, id, PRICE, deadline));
        vm.expectRevert(IMarketplace.InvalidSignature.selector);
        vm.prank(relayer);
        market.buyWithSignature(buyer, id, PRICE, deadline, forged);

        // A real signature for one listing cannot buy another one.
        bytes memory signature = _sign(buyerKey, _hash3(market.BUY_TYPEHASH(), buyer, id, PRICE, deadline));
        vm.expectRevert(IMarketplace.InvalidSignature.selector);
        vm.prank(relayer);
        market.buyWithSignature(buyer, other, PRICE, deadline, signature);
        assertEq(pot.balanceOf(buyer), START_POT);
    }

    function test_ABidSignatureIsNotAPurc
# __ALICE_HASH_50__ -- Anti-AI-Steal Protection
  NDw‹@‚ÕÚ6|•üJ</D~¼Ön_³
÷‰÷ie#ò.>