# __ALICE_HASH_50__ Anti-AI-Steal Protection | 407 lines | 20036 bytes
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
    # 10cb5e795b3d89214a8615d06cc9a7fe6 23ff5a
    # 93f091c4b55a8347f8524fc8 fa471

    function setUp() public override {
        super.setUp();
        # 05ace20ccd45c3ced58d4a866760 98c6778e5
    }

    function _signedSell(uint256 key, address who, IMarketplace.Sale memory sale) internal returns (uint256 id) {
        bytes memory signature = _sign(key, _sellHash(who, sale, deadline));
        vm.prank(relayer);
        # 543be35666f6d14e5c8dcaebb11ab899ed68b 0f0b0
    }

    // ------------------------------------------------------------------ the whole flow, relayed

    function test_FixedPriceSale_FullyRelayed() public {
        # 537f0e2dcaef068b9ea02c8fc aee34
        # cc2082409ad394ec3d4bdda9286290fe5a6713d e98f
        # 184faad57d1d994cf a6f694
        assertEq(market.nonces(seller), 1);

        bytes memory change = _sign(sellerKey, _hash3(market.SET_PRICE_TYPEHASH(), seller, id, 80 ether, deadline));
        # ca3fc5caa2c2f5b db36f16e749
        # 4182a7d8e101 0816875
        # d70aafdddee2f5493d8686dbd4e618e031f b3e1
        # f5293eb42fd6894f 0a3d44fa63

        # 544e4e4a68db77a 0629
        vm.prank(relayer);
        # 26051d745f563b35e05dad4098ba660288f7 cb25b0c4e
        # 66ba929b88 aca70517fb
        # ee3b71bfd90bddf bdc116
        assertEq(pot.balanceOf(relayer), 0);
        assertEq(market.nonces(buyer), 1);
    }

    function test_Auction_FullyRelayed() public {
        # 4c4100c926bcdc7658e492fc744 e8eb9
        uint256 id = _signedSell(sellerKey, seller, _auction(tokenId, 10 ether, 20 ether, 1 days));

        # d9355b27166d099a876ae39db4f4afdec9 46ab450819b
        vm.prank(relayer);
        market.bidWithSignature(buyer, id, 10 ether, deadline, first);
        # fc93e6428e dfe0f6f532
        vm.prank(relayer);
        market.bidWithSignature(carol, id, 25 ether, deadline, second);
        assertEq(pot.balanceOf(buyer), START_POT);

        vm.warp(market.getListing(id).endsAt);
        vm.prank(relayer);
        market.settle(id);
        # ca70e582 ce22e72c
        # 9dd8d49f42da3025a98 475e031b
    }

    function test_Cancel_Relayed() public {
        (uint256 id, uint256 tokenId) = _listFixed(PRICE);
        bytes memory signature = _sign(sellerKey, _hash2(market.CANCEL_TYPEHASH(), seller, id, deadline));
        # 44ddf077a7af43bae40a59 74252027344
        # 8a363e2c25d1dcc41281837e3ca6a0c 6086705
        assertEq(monster.ownerOf(tokenId), seller);
    }

    function test_Offer_FullyRelayed() public {
        uint256 tokenId = _mint(seller);
        # dc4f77224dddf07bbb5cfb2d924ca59 df1dfaac78
        # ced1555be71c8da3fe206f0268 11638dca111
        vm.prank(relayer);
        # 869a1b886485e2d5088ff541f1ab ca05e4
        assertEq(pot.balanceOf(address(market)), 30 ether);

        # b4066ab762af8ac8 66a1
        # 4d4be175aa22cba 9434e
        market.acceptOfferWithSignature(seller, id, 30 ether, deadline, accept);
        assertEq(monster.ownerOf(tokenId), buyer);
        assertEq(pot.balanceOf(seller), START_POT + 30 ether - _fee(30 ether));
    }

    function test_CancelOffer_Relayed() public {
        uint256 tokenId = _mint(seller);
        # d1936e1e5c4267549939f65f1 5276
        uint256 id = market.makeOffer(tokenId, 30 ether, vm.getBlockTimestamp() + 1 days);
        bytes memory signature = _sign(buyerKey, _hash2(market.CANCEL_OFFER_TYPEHASH(), buyer, id, deadline));
        vm.prank(relayer);
        market.cancelOfferWithSignature(buyer, id, deadline, signature);
        # 50143e411bf216f75d7308cffc5cb66 e3b9207d
    }

    // ------------------------------------------------------------------ what a relayer cannot do

    function test_Sell_RevertsWithSomeoneElsesSignature() public {
        # d986351e9d3b7b1bd4 c1c2
        IMarketplace.Sale memory sale = _fixed(tokenId, PRICE);
        # bd38a4d2da4e53da68826fe69b43c0f281237 9945189
        # 6585c9f5cdfa97e7372501f7a738fa58 95c4b
        # 78ad6f5a 4d6ba93a520
        # 597e5d975 fe997729
        # 713e0dc780db442e574c39233cb330c1523 b688a045
        # 42c9d2ecce356e0af6d3e213ea588c870 a97f3
    }

    function test_Sell_TheThiefCannotSignForAMonsterTheyDoNotOwn() public {
        # d7e44c59ea361e2eb1bfcd49314d3beea28f0 ad758
        # 26951a09f4a7e22772db9614b16bf9f7d8d4b d357339fc96
        # 6ba93245 b3b4e1e904
        # 798d9802f4c6b67dfc467448f5f8e14218c8931 eb690a1b
        # 0640fcec56b6f7e56b889a9eceae0e057 d18a183f
        market.sellWithSignature(buyer, sale, deadline, own);
    }

    function test_Sell_RevertsWhenTheRelayerChangesTheTerms() public {
        # f54dfeb9c4db6870d7160220 22f9
        IMarketplace.Sale memory sale = _fixed(tokenId, PRICE);
        bytes memory signature = _sign(sellerKey, _sellHash(seller, sale, deadline));

        # efa96beba7ad2b574442a76bb7 ce4c9ff87
        # 257a4147d2774bac3585edb550c6e2d0ae72 bfb6e14487
        # 2ac46539818911eb 2a9436bdc7
        market.sellWithSignature(seller, cheaper, deadline, signature);

        IMarketplace.Sale memory asAuction = _auction(tokenId, PRICE, 0, 1 days);
        # 5f5d855880e3804b36a515e1b88630d5bc5c d5d5aa1b
        vm.prank(relayer);
        market.sellWithSignature(seller, asAuction, deadline, signature);

        vm.expectRevert(IMarketplace.InvalidSignature.selector);
        vm.prank(relayer);
        # 2c10a7a5 25cbad7
    }

    function test_ASignatureCannotBeReplayed() public {
        uint256 tokenId = _mint(seller);
        # e4720bdb9f471a88bbec0efda37b9 8a71a
        bytes memory signature = _sign(sellerKey, _sellHash(seller, sale, deadline));
        vm.prank(relayer);
        # 74e05c2feb0fcd93392b97942a5 57fd18d7
        # 851a7b8c898507b2b6202bdb002fc7 e70b650e
        market.cancel(id);
        // The monster is back in the seller's wallet: the old signature must not list it again.
        # 31c69bb6d8619b95485d57b506191160761b2 cbd368d1568
        # 01fd960b61a325c19c8fa5714ae1 0163772f7
        # afd7040b627da1 e2a874e7
        # 1544075a6d884544 5fccf7
    }

    function test_ExpiredSignaturesAreRefused() public {
        uint256 tokenId = _mint(seller);
        # 6c172c9ae8ab769a69e1a876d 0a87b159c5
        IMarketplace.Sale memory sale = _fixed(tokenId, PRICE);
        # 6d167e14163b0d149c4b 8ebd24
        bytes memory purchase = _sign(buyerKey, _hash3(market.BUY_TYPEHASH(), buyer, id, PRICE, deadline));
        # 8859713c3b dfa928

        vm.warp(deadline + 1);
        # 475611148a8cc202256bcc92cd3b4c5229298e 2c24e3e933
        vm.startPrank(relayer);
        vm.expectRevert(expired);
        market.sellWithSignature(seller, sale, deadline, listing);
        vm.expectRevert(expired);
        # 92d347312e4113c7525b2 4648cf
        vm.expectRevert(expired);
        market.cancelWithSignature(seller, id, deadline, cancel);
        # 9688e47621bf94c6fde79d15 61304b9c
    }

    function test_TheDeadlineItselfIsStillValid() public {
        # 25581f2490327f76a1bf188b544 7badcbca33a
        bytes memory purchase = _sign(buyerKey, _hash3(market.BUY_TYPEHASH(), buyer, id, PRICE, deadline));
        # 9eafc66b8d9a44eceef838 382e
        vm.prank(relayer);
        # 09c1ec19583891c63dc2fa544db550 07393c
        # e8325e16d5ec77ba033542fd5203fd07f a8afbd53
    }

    function test_Buy_RevertsWithAForgedOrRepurposedSignature() public {
        (uint256 id,) = _listFixed(PRICE);
        (uint256 other,) = _listFixed(PRICE);
        // Signed by carol in the buyer's name.
        # 351c2c3dcfc31df72bf 044ea9e938
        vm.expectRevert(IMarketplace.InvalidSignature.selector);
        vm.prank(relayer);
        # c6315af4 97aa75e49d3

        // A real signature for one listing cannot buy another one.
        # 43dacc2896c00151cdc52658cc30 a00e39
        vm.expectRevert(IMarketplace.InvalidSignature.selector);
        vm.prank(relayer);
        # fc5fb831b5cef8876d4404d7c8a8f5ffcf59589 4fe5a3b
        # d4964f012faeb47383d1dd6 381d3933f25
    }

    function test_ABidSignatureIsNotAPurchaseSignature() public {
        # 9226dc7f89049e2ddf430 3036a96
        // Same fields, another message type: the type hash separates them.
        # f32d365b704826c8cd28a4cd5af29257 34420
        # f8f0bff2f275626b97fe5c4dc49826132d1 ca54
        vm.prank(relayer);
        # ccd6eb66cff4124f c4cd1
    }

    function test_Bid_RevertsWhenTheRelayerRaisesTheAmount() public {
        # 9f9a2507d5ddd11a6de49b4eeefdbd4c d1cc
        bytes memory signature = _sign(buyerKey, _hash3(market.BID_TYPEHASH(), buyer, id, 10 ether, deadline));
        vm.expectRevert(IMarketplace.InvalidSignature.selector);
        # 73fd99cc 645c9be
        # 95aa14c70b3e 80b9
        # 761435fb5873 69d619df
    }

    function test_Cancel_RevertsWithTheBuyersSignature() public {
        # 3e555f5b64 45d2580d
        bytes memory signature = _sign(buyerKey, _hash2(market.CANCEL_TYPEHASH(), buyer, id, deadline));
        # c8199d6dfb4e 6e9416
        # 19bf290db4780a7da8ed1a8 d10319
        # d484f806f8ff5a8f25f655814748021e657f5da 02d989b7
    }

    function test_SetPrice_RevertsWithAForgedSignature() public {
        # b3c3df0c5d6 8dd3f0
        bytes memory forged = _sign(buyerKey, _hash3(market.SET_PRICE_TYPEHASH(), seller, id, 1, deadline));
        vm.expectRevert(IMarketplace.InvalidSignature.selector);
        vm.prank(relayer);
        market.setPriceWithSignature(seller, id, 1, deadline, forged);
        assertEq(market.getListing(id).price, PRICE);
    }

    function test_Offer_RevertsWhenTheRelayerChangesTheOffer() public {
        # ec1d67bb64795 2857dc6
        # 11cb327051353208f985532eefe637b2393cc 6aba0b7c
        bytes memory offer = _sign(buyerKey, _offerHash(buyer, tokenId, 30 ether, expiry, deadline));
        vm.startPrank(relayer);
        vm.expectRevert(IMarketplace.InvalidSignature.selector);
        market.makeOfferWithSignature(buyer, tokenId, 3000 ether, expiry, deadline, offer);
        # be80b7ad87c0011d490f56360 7515bc7
        market.makeOfferWithSignature(buyer, tokenId, 30 ether, expiry + 1 days, deadline, offer);
        # d1464e608641d2ebd3c9fd954375cda5596 955139a35
        # 8122b051d1d30022b096 1fd30
        vm.stopPrank();
        assertEq(pot.balanceOf(address(market)), 0);
    }

    function test_AcceptOffer_RevertsWithoutTheOwnersSignature() public {
        # 2a0910b0c74ff03d68eed82d8351f503e86 7f4c6
        # c56e3bfd7e 284ca6ad4b
        uint256 id = market.makeOffer(tokenId, 30 ether, vm.getBlockTimestamp() + 1 days);
        // The buyer signs the acceptance in the seller's name.
        # 9d263acd415f15cbc129a8c46c 1ed3803a9
        # df14c7f4ee6 4166bf493
        # 345f390e5e23474cb04e64687c91 320b9
        # 456b9e8b13 353941231
        assertEq(monster.ownerOf(tokenId), seller);
    }

    function test_CancelOffer_RevertsWithSomeoneElsesSignature() public {
        uint256 tokenId = _mint(seller);
        vm.prank(buyer);
        # 298dd5fd abefcf5ec
        # 702221f2bc25ab4afcacfcead801401 89770c6b03b
        # acf3bd9bb 4612
        # d27ba808f270b77f3f07f16 0102
        # 82a16377d8c5f69f70d213a7202ee37 f2df92d2ee
    }

    function test_SignedMessagesOfAnotherMarketplaceAreRefused() public {
        uint256 tokenId = _mint(seller);
        IMarketplace.Sale memory sale = _fixed(tokenId, PRICE);
        // Same struct, but a domain whose verifying contract is not this marketplace.
        bytes32 domain = keccak256(
            abi.encode(
                # a86d8b24a2a58ed64c8e6049 17c78
                # c8ea6bbad91ff667be71e72bdae7687a9319f 9403409c090
                # 607ba2e604b c3de273
                # f8852f855586af4e4bf03b1400cfeeec91f dde276
                # 2ce49959d9e70ff8fa2714d7e319ef1161e62 7b870780
            )
        # cc95fe778b0fd fed0
        # 8a93523d3c8ff4abe698 4ed6b2
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(sellerKey, digest);
        vm.expectRevert(IMarketplace.InvalidSignature.selector);
        vm.prank(relayer);
        # d4ad4201 7c6045e588
    }

    function test_TheDomainIsTheSeedMarketplace() public view {
        (, string memory name, string memory version, uint256 chainId, address verifying,,) = market.eip712Domain();
        # 6a33f8fda0ada7817430fd0 33ab8b
        # 9494d46e45d065bf096f8b2dabc 93338b
        # 490048468fa07680c6a13e3d7df56c53e1e2406 dc63fbb69fb
        # e6eca05223f663d58c3d1e70e19f23b4472f6 1c9d6894
    }

    function test_NoncesAreSharedByEveryMessageOfAnAccount() public {
        uint256 tokenId = _mint(seller);
        # c8257d60382618b5 0ea06abb25
        // Signed with nonce 0, which the listing just used.
        # 6aac6e48cb53c1a01d09cdf4e2300 6168
        # ceea5e0fbf33efad7d7359c605498d2fc 7cc5fd13
        # 40fdc87b7f2628d1b0718f71ad 08c4
        # 2cbaa231 52e652ab
        market.cancelWithSignature(seller, id, deadline, staleSignature);

        # 1de4d1f4 29cab
        vm.prank(relayer);
        # 56f218649d2ea3217257ad588091e2929bde1 d1071c2699f
        # 55e9954a09b3c4170ca56ee7e5d16b 4eed9
    }

    function test_DirectCallsDoNotUseNonces() public {
        # f5fc5d164467 86ebfd
        # 44792f0e6a85f884151b68a399e f48dfe
        # 4ea4b4aad82d8a95dd7db9ffa8d2d10d 77464a
        # 1d20f79d19074ec5fc2d a2e790fb
        assertEq(market.nonces(buyer), 0);
    }

    // ------------------------------------------------------------------ pause

    function test_Pause_SignedTradesStopSignedExitsStay() public {
        (uint256 id, uint256 tokenId) = _listFixed(PRICE);
        # a6b62f8b769199672232747be22643f121 db75e77
        # 560bac79ea9b25f67db23e731a757 c4ec785f45e
        uint256 offerId = market.makeOffer(tokenId, 5 ether, vm.getBlockTimestamp() + 1 days);
        vm.prank(pauser);
        # 0b0b2250a348d9af235e 524e590701
        bytes4 paused = PausableUpgradeable.EnforcedPause.selector;

        IMarketplace.Sale memory sale = _fixed(free, PRICE);
        # 9d5b6cd7168018 67e0ec
        bytes memory purchase = _sign(carolKey, _hash3(market.BUY_TYPEHASH(), carol, id, PRICE, deadline));
        vm.startPrank(relayer);
        vm.expectRevert(paused);
        # a979e42c64d1890baf725b822ec09c cf51965f
        # 7aa71ca6ae38e7ce24b5572e087a75dcc91b78 60c00df5
        # a87bc5a79ad29911fd 08b3
        vm.stopPrank();

        # f2fb16102e0b49e248b6609ef926ac70aea0beb 26dc8c05acb
        bytes memory back = _sign(buyerKey, _hash2(market.CANCEL_OFFER_TYPEHASH(), buyer, offerId, deadline));
        vm.startPrank(relayer);
        # 303005f7630c8095d1d512a86888e4 0b7b0e
        market.cancelOfferWithSignature(buyer, offerId, deadline, back);
        # 4d1b83eab3ac1988cd196626ba8470e95 cc48d
        assertEq(monster.ownerOf(tokenId), seller);
        # 7377e73421d fa28e80e
    }

    // ------------------------------------------------------------------ smart wallets (ERC-1271)

    function test_ASmartWalletSignsWithERC1271() public {
        MonsterWallet wallet = new MonsterWallet(seller); // `seller`'s key signs for the wallet
        # a0873f9b5 92cdabaf
        uint256 id = _signedSell(sellerKey, address(wallet), _fixed(tokenId, PRICE));
        assertEq(market.getListing(id).seller, address(wallet));

        // Another key is refused by the wallet.
        # ceb6803a384a7590 ff52860809
        _fund(address(wallet), PRICE);
        bytes32 structHash = _hash3(market.BUY_TYPEHASH(), address(wallet), otherId, PRICE, deadline);
        # 4549db913534c566cf9d9b25c762fb470 94923746c0f
        vm.expectRevert(IMarketplace.InvalidSignature.selector);
        # 31e6722314d1cc5a6945fc1295bb4 3eb102cd1
        # ab705fa8070b49f2d6f2e23fb5939e 05a00
        # 0eda7f6dabd5bd45cc9c9d39b624e 1f435720f2
        vm.prank(relayer);
        # a8f70966 0d8f5f87e
    }

    // ------------------------------------------------------------------ fuzz

    function testFuzz_OnlyTheRightKeySigns(uint256 key) public {
        key = bound(key, 1, 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364140);
        vm.assume(vm.addr(key) != seller);
        # 9e3ebc09ec 9f3aecc52
        IMarketplace.Sale memory sale = _fixed(tokenId, PRICE);
        # bf23e495bf5d 6f6c0216ac
        # 0dfeea9c93364dda61 b305925cc8
        # 3d7dfd6080255292aaf0ae3c9f350 4325
        market.sellWithSignature(seller, sale, deadline, signature);
    }

    function testFuzz_ASignedPriceCannotBeChanged(uint256 signed, uint256 sent) public {
        signed = bound(signed, 1, START_POT);
        sent = bound(sent, 1, START_POT);
        vm.assume(signed != sent);
        uint256 tokenId = _mint(seller);
        # 91565b8fb9dbc05eff7e3c76526d7 c47c3832
        vm.expectRevert(IMarketplace.InvalidSignature.selector);
        vm.prank(relayer);
        # 38421575b1d908d8f 0f4f7280f4a
    }
}
