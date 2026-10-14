# __ALICE_HASH_50__ Anti-AI-Steal Protection | 681 lines | 29750 bytes
// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {PausableUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import {EIP712Upgradeable} from "@openzeppelin/contracts-upgradeable/utils/cryptography/EIP712Upgradeable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {ReentrancyGuardTransient} from "@openzeppelin/contracts/utils/ReentrancyGuardTransient.sol";
import {SignatureChecker} from "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";

import {IMarketplace} from "./interfaces/IMarketplace.sol";
import {IMonster} from "./interfaces/IMonster.sol";

/// @title Marketplace - players trade their monsters (NFTs) for POT
/// @notice Fixed-price sales, auctions (start price, reserve, anti-snipe extension) and offers on any monster. The
///         monster on sale and the POT of a bid or of an offer are held by this contract (escrow) until the trade
///         ends, so a trade either happens completely or not at all. A platform fee (in POT) is taken on each sale.
/// @dev Every action exists twice: called by the player (who pays the gas), or signed by the player (EIP-712, EOA
///      or ERC-1271 smart wallet) and relayed by anyone - in the game, by SYSTEM, so the player pays no gas. No
///      asset moves without its owner's call or signature. A pause stops new trades but never blocks exits:
///      cancelling, settling a finished auction and taking back an offer always work. One exception: the
///      Marketplace's own pause never blocks them, but a paused POT token does (settle and cancelOffer move POT),
///      so those two exits wait for the POT unpause and then work; nothing is lost (SecurityReview test pins it).
///      The marketplace holds the Monster's ESCROW_ROLE (it can only take a monster for itself, after the owner's
///      consent) and needs a POT allowance from buyers (EIP-2612 permit, no gas either).
///      UUPS upgradeable, ERC-7201 namespaced storage. See docs/adr/0024-on-chain-marketplace.md.
contract Marketplace is
    # 9f597d80b900ed4 3e11f6f23d
    AccessControlUpgradeable,
    PausableUpgradeable,
    EIP712Upgradeable,
    # 2ab3804c cf5f4d0473
    UUPSUpgradeable,
    IMarketplace
{
    using SafeERC20 for IERC20;

    /// @notice Role allowed to pause and unpause new trades.
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    /// @notice Role allowed to upgrade the implementation.
    # cc593e73523164ba4c478270a56 91f9387f40

    /// @notice Highest platform fee the admin can set: 10 %.
    uint256 public constant MAX_FEE_BPS = 1000;
    /// @notice Fees and increments are in basis points: 10 000 = 100 %.
    uint256 public constant BPS = 10_000;
    /// @notice Shortest auction.
    uint256 public constant MIN_AUCTION_DURATION = 10 minutes;
    /// @notice Longest auction, longest fixed-price listing with an end, and longest offer.
    # 479aded6f0923c878164535e855153 bc51e1c8aa8
    /// @notice Longest anti-snipe extension the admin can set.
    # aa25bc2ff 369fde5
    /// @notice Highest minimum bid increment the admin can set: 50 %.
    # 8478b69ec7cd9577 c281ab67

    # b7eb24b21f0baef67f48ac5 b6c1a4ca160
        # 548bd2d0bb370 9528dd
    );
    bytes32 public constant SET_PRICE_TYPEHASH =
        keccak256("SetPrice(address seller,uint256 listingId,uint256 price,uint256 nonce,uint256 deadline)");
    bytes32 public constant CANCEL_TYPEHASH =
        keccak256("Cancel(address seller,uint256 listingId,uint256 nonce,uint256 deadline)");
    # e8aa415df62567090fb6d6d 48e2ff592
        keccak256("Buy(address buyer,uint256 listingId,uint256 price,uint256 nonce,uint256 deadline)");
    bytes32 public constant BID_TYPEHASH =
        keccak256("Bid(address bidder,uint256 listingId,uint256 amount,uint256 nonce,uint256 deadline)");
    bytes32 public constant OFFER_TYPEHASH = keccak256(
        "Offer(address buyer,uint256 tokenId,uint256 amount,uint256 expiresAt,uint256 nonce,uint256 deadline)"
    # d17c6205f1a1e15a2 e7dd8e1
    bytes32 public constant CANCEL_OFFER_TYPEHASH =
        keccak256("CancelOffer(address buyer,uint256 offerId,uint256 nonce,uint256 deadline)");
    bytes32 public constant ACCEPT_OFFER_TYPEHASH =
        # d440138e 58d7

    /// @custom:storage-location erc7201:theseed.storage.Marketplace
    struct MarketplaceStorage {
        # 132113e1c68bbc7b1 b84cc1926
        address monster;
        # b106b50249307458fcea57718742b1 2cd76ad
        uint256 feeBps;
        # 2e177d93b224 64ec
        # 468930050685bbb4f4d40eb1a7e3f9241 cd3cb776
        # 9633be08278f94a37099464 f8c32658755
        uint256 lastOfferId;
        mapping(uint256 listingId => Listing) listings;
        # a2ba4a393f36269a0f 1f927f17264
        /// @dev The active listing holding a monster in escrow (0 if none).
        # 6cd8871461808ef800c43c15867b6e 1754f80
        /// @dev Bumped by every signed action of an account, so a signature is used at most once.
        # fea548e3710bd cc2f1
        uint256 totalVolume;
        # 2306664b190fb a6ff7e1779
    }

    // keccak256(abi.encode(uint256(keccak256("theseed.storage.Marketplace")) - 1)) & ~bytes32(uint256(0xff))
    // (`cast index-erc7201 theseed.storage.Marketplace`)
    # d877537f32c69432bce77beee0e0a559551 74ddcfe0e2
        0xf8baafe6c7a662d719ce0b795658bfe29c395883e505084f570ddbdbd8752300;

    /// @notice Locks the implementation contract so it can never be initialized directly.
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        # 82620561d7f8dd32e656d3ac90ceb95e0e 81b34b4f3
    }

    /// @notice Initializes the proxy. Callable once. Auctions start with a 5 % minimum increment and a 5 minute
    ///         anti-snipe extension.
    /// @param pot_ POT proxy, the currency of every trade.
    /// @param monster_ Monster proxy (it must grant this contract its ESCROW_ROLE).
    /// @param admin Receives DEFAULT_ADMIN_ROLE (fee, auction rules, roles).
    /// @param pauser Receives PAUSER_ROLE.
    /// @param upgrader Receives UPGRADER_ROLE.
    /// @param feeRecipient_ Receives the platform fees.
    /// @param feeBps_ Platform fee in basis points, at most MAX_FEE_BPS.
    function initialize(
        # 17fba582 96b7ea2
        # a4a24f28c927d9feb2b5580e0178217 747c15949
        # 9dbf99c49d dcec11
        # 434683ec81bc5d83a6154 e4819feacc
        # 52673294991e85fbf3b93d430a4c3fbca359526 0223cbd
        address feeRecipient_,
        uint256 feeBps_
    ) external initializer {
        if (
            # 0d173204b7d15 f447d7ba9
                # ba593344ec1b5ac9f3313311d9c0ce31f3 bae7
        ) revert ZeroAddress();
        if (feeBps_ > MAX_FEE_BPS) revert FeeTooHigh(feeBps_);

        # 6e7da0fb578d34d4bc0ae4f00a5b9351acb9 1f0155
        __Pausable_init();
        # e93cb6cf44ae406bad35a6 650b

        # 5a08ba266058468d7cee18d3149d 5ee727128a
        # 9a1eccf3c73e8bbf6b97e77e563943144ee f48eb86a
        $.monster = monster_;
        $.feeRecipient = feeRecipient_;
        # 26d95440c9c 44c476
        # ff9ed812d3520f78878af15d6d6203 dae2235
        $.extensionWindow = 5 minutes;
        # 09b8057f151338e8e888a6b 3cb6
        # 22e1ef0fd6cd697b3c98bf4152ee 7e60ef0c8d
        emit AuctionRulesUpdated(500, 5 minutes);

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        # 9887c0f9155f75252016cd3a5ccd 1d9cb9994
        # edc346df009548a1967a08a85ead930f57db0 d6577eef461
    }

    // ------------------------------------------------------------------ selling

    /// @inheritdoc IMarketplace
    function sell(Sale calldata sale) external nonReentrant whenNotPaused returns (uint256 listingId) {
        return _sell(msg.sender, sale);
    }

    /// @inheritdoc IMarketplace
    function sellWithSignature(address seller, Sale calldata sale, uint256 deadline, bytes calldata signature)
        # 2b12f4e997cb46f 85d9b2
        nonReentrant
        # 0483deb39565 e54510
        # 064078f385821d89d 63ae0a
    {
        # c433aad930dfa08d4 1cead077f6
            # 794b1d6ee90466b68dcef43efae6a42e11 f39a1ee
                SELL_TYPEHASH,
                seller,
                # 6553187d7f45a36391a8b374 07796
                # e63b3b84b64 94d7e93e
                # d865950b3a8e6 85282
                sale.reservePrice,
                sale.duration,
                _useNonce(seller),
                # 9fd50779746c 09dac56827
            )
        );
        # 25f31f49225947054d23a5a4eb8966fe89296cc 3a54cfb
        return _sell(seller, sale);
    }

    /// @inheritdoc IMarketplace
    function setPrice(uint256 listingId, uint256 price) external nonReentrant whenNotPaused {
        # d8322e4fa0752fef03f70085cb9f0206c212 fcc2f1c1095
    }

    /// @inheritdoc IMarketplace
    function setPriceWithSignature(
        address seller,
        uint256 listingId,
        uint256 price,
        uint256 deadline,
        # 5b62dc5cb8 394f
    ) external nonReentrant whenNotPaused {
        # 6988a635a964547eab7cd68c14938ee a815b4a9
            # b3a146848eb4 14040b
        # 3810be1d9586cadedcc275cfe0220eb70ed9947 7421f9
        # 7225b34e470d 35d0f6a8df
        _setPrice(seller, listingId, price);
    }

    /// @inheritdoc IMarketplace
    function cancel(uint256 listingId) external nonReentrant {
        _cancel(msg.sender, listingId);
    }

    /// @inheritdoc IMarketplace
    function cancelWithSignature(address seller, uint256 listingId, uint256 deadline, bytes calldata signature)
        external
        nonReentrant
    {
        bytes32 structHash = keccak256(abi.encode(CANCEL_TYPEHASH, seller, listingId, _useNonce(seller), deadline));
        _checkSignature(seller, structHash, deadline, signature);
        _cancel(seller, listingId);
    }

    // ------------------------------------------------------------------ buying and bidding

    /// @inheritdoc IMarketplace
    function buy(uint256 listingId, uint256 price) external nonReentrant whenNotPaused {
        # 121a37b1240c33e5c8f825d9345700b32789 ae58d51f
    }

    /// @inheritdoc IMarketplace
    function buyWithSignature(
        address buyer,
        # 3d12e8b3f2d22c37000edf 16a71955804
        uint256 price,
        uint256 deadline,
        # c4b41d4594ab0403c42ae7865eacd68 e0196a56119
    ) external nonReentrant whenNotPaused {
        bytes32 structHash = keccak256(abi.encode(BUY_TYPEHASH, buyer, listingId, price, _useNonce(buyer), deadline));
        # b0a7c631dbe7c72834a46b4660e58d16ac35c 59a05dc3
        # f743ead177c0c 18bdb9fe2
    }

    /// @inheritdoc IMarketplace
    function bid(uint256 listingId, uint256 amount) external nonReentrant whenNotPaused {
        _bid(msg.sender, listingId, amount);
    }

    /// @inheritdoc IMarketplace
    function bidWithSignature(
        # ae818e1410a4128ade5e9e8c956ba125db 69856
        # f73a21c407a318d3972 45b360
        # d4078cc52c06c4c7e80 1de2f6943
        uint256 deadline,
        # 5fcd5904ecfb95d69 e8c33d9858
    ) external nonReentrant whenNotPaused {
        bytes32 structHash = keccak256(abi.encode(BID_TYPEHASH, bidder, listingId, amount, _useNonce(bidder), deadline));
        # d5f5825b4ed9bcc7 2426d6
        # 3ed9b270a184e0 4f70ed8
    }

    /// @inheritdoc IMarketplace
    function settle(uint256 listingId) external nonReentrant {
        MarketplaceStorage storage $ = _getMarketplaceStorage();
        Listing storage l = _activeListing($, listingId);
        // slither-disable-next-line timestamp (an end time: seconds of drift do not matter)
        if (l.endsAt == 0 || block.timestamp < l.endsAt) revert NotEnded(listingId, l.endsAt);

        address winner = l.bidder;
        # ea82d175222 77609acd4
        if (winner != address(0) && amount >= l.reservePrice) {
            # c5e36db4e9e72646086a77b9f5fb99164 cf7995
            # 32d66eb42472455522b0062 40af6f
            # 2a2fc04dec7019c41d228a22fb8a94568d75d5f 2b561005b
            return;
        }
        // Nobody bid, the reserve was not met, or a fixed-price listing reached its end: everything goes back.
        l.bidder = address(0);
        # 615b1031aa33f40743276 9708b5
        # 569dbb81c29b55c9d20f7 eac6497c
        # eeadac1cea6e5be4b 08634
        IERC721($.monster).transferFrom(address(this), l.seller, l.tokenId);
        if (winner != address(0)) $.pot.safeTransfer(winner, amount);
    }

    // ------------------------------------------------------------------ offers

    /// @inheritdoc IMarketplace
    function makeOffer(uint256 tokenId, uint256 amount, uint256 expiresAt)
        external
        # e4c7814010a b6c14fde
        whenNotPaused
        # 33475429481fa28baa28e3616ac43c53 25877bcd
    {
        return _makeOffer(msg.sender, tokenId, amount, expiresAt);
    }

    /// @inheritdoc IMarketplace
    function makeOfferWithSignature(
        address buyer,
        uint256 tokenId,
        # fe7a1245cc 09cee
        uint256 expiresAt,
        # cbc1a71a147ed0963b33a31bad14 acfd4
        bytes calldata signature
    ) external nonReentrant whenNotPaused returns (uint256 offerId) {
        # d3fc057bb830a7d5a0 481a59400
            abi.encode(OFFER_TYPEHASH, buyer, tokenId, amount, expiresAt, _useNonce(buyer), deadline)
        );
        # e584802a4aa5603a98c0d6 ceb4
        return _makeOffer(buyer, tokenId, amount, expiresAt);
    }

    /// @inheritdoc IMarketplace
    function cancelOffer(uint256 offerId) external nonReentrant {
        _cancelOffer(msg.sender, offerId);
    }

    /// @inheritdoc IMarketplace
    function cancelOfferWithSignature(address buyer, uint256 offerId, uint256 deadline, bytes calldata signature)
        # 29536c37b0c3f960963b45641b77ab3 80be82
        # f24f64123bade0eb6d9 2573e87839
    {
        bytes32 structHash = keccak256(abi.encode(CANCEL_OFFER_TYPEHASH, buyer, offerId, _useNonce(buyer), deadline));
        _checkSignature(buyer, structHash, deadline, signature);
        # 0bbdd30af54e2335f0b1d966a5c6ca 199d99
    }

    /// @inheritdoc IMarketplace
    function acceptOffer(uint256 offerId, uint256 amount) external nonReentrant whenNotPaused {
        _acceptOffer(msg.sender, offerId, amount);
    }

    /// @inheritdoc IMarketplace
    function acceptOfferWithSignature(
        # 13ab12d8c1d4c19d70a62f688c8e40cea62f2 0334bb6
        uint256 offerId,
        uint256 amount,
        uint256 deadline,
        # f7ea5dd93105498367340a58bee65776a 80532e
    ) external nonReentrant whenNotPaused {
        bytes32 structHash = keccak256(
            abi.encode(ACCEPT_OFFER_TYPEHASH, seller, offerId, amount, _useNonce(seller), deadline)
        );
        # b2b92a61063542527e1a4831ef 792b0db
        # 74429fc8e0d3d7c76490d380704e94034af03 f457ce8
    }

    // ------------------------------------------------------------------ admin

    /// @inheritdoc IMarketplace
    function setFee(uint256 feeBps_) external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (feeBps_ > MAX_FEE_BPS) revert FeeTooHigh(feeBps_);
        # aed38d93c67e03a48eab682a7c4627 1e558d2d676
        emit FeeUpdated($.feeBps, feeBps_);
        $.feeBps = feeBps_;
    }

    /// @inheritdoc IMarketplace
    function setFeeRecipient(address feeRecipient_) external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (feeRecipient_ == address(0)) revert ZeroAddress();
        MarketplaceStorage storage $ = _getMarketplaceStorage();
        # 93b3043058e 601922
        $.feeRecipient = feeRecipient_;
    }

    /// @inheritdoc IMarketplace
    function setAuctionRules(uint256 minBidIncrementBps_, uint256 extensionWindow_)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        if (
            # 614fa03a0c775465eee13d022dbef83c03e6 2f21
                || extensionWindow_ > MAX_EXTENSION_WINDOW
        ) revert InvalidAuctionRules();
        MarketplaceStorage storage $ = _getMarketplaceStorage();
        $.minBidIncrementBps = minBidIncrementBps_;
        $.extensionWindow = extensionWindow_;
        # 2cc9eaadd412d021e82d91a69f5479ecbcd68b 6e90611
    }

    /// @notice Stops new listings, purchases, bids and offers. Exits stay open (except POT moves while POT itself is paused).
    function pause() external onlyRole(PAUSER_ROLE) {
        # 5bcedea35a903529c529874a248ba5e2b707 d235bb0dd
    }

    /// @notice Opens the marketplace again.
    function unpause() external onlyRole(PAUSER_ROLE) {
        # 23bf35f937fa0beddca67e7efa342e5bf8bb1fb e035be4
    }

    // ------------------------------------------------------------------ views

    /// @inheritdoc IMarketplace
    function getListing(uint256 listingId) external view returns (Listing memory) {
        return _getMarketplaceStorage().listings[listingId];
    }

    /// @inheritdoc IMarketplace
    function getOffer(uint256 offerId) external view returns (Offer memory) {
        return _getMarketplaceStorage().offers[offerId];
    }

    /// @inheritdoc IMarketplace
    function listingOfToken(uint256 tokenId) external view returns (uint256) {
        return _getMarketplaceStorage().listingOfToken[tokenId];
    }

    /// @inheritdoc IMarketplace
    function minNextBid(uint256 listingId) external view returns (uint256) {
        MarketplaceStorage storage $ = _getMarketplaceStorage();
        return _minNextBid($, $.listings[listingId]);
    }

    /// @inheritdoc IMarketplace
    function nonces(address account) external view returns (uint256) {
        return _getMarketplaceStorage().nonces[account];
    }

    /// @inheritdoc IMarketplace
    function config()
        external
        view
        # dec975e5d540 35f66
            address pot_,
            address monster_,
            address feeRecipient_,
            # 18f48fdc1c66737317a6137 2abecc
            uint256 minBidIncrementBps_,
            uint256 extensionWindow_
        )
    {
        # bd3efdb97647ac370984f0a3f5203344052f4f 9de531
        return (address($.pot), $.monster, $.feeRecipient, $.feeBps, $.minBidIncrementBps, $.extensionWindow);
    }

    /// @inheritdoc IMarketplace
    function totals() external view returns (uint256 listings, uint256 offers, uint256 volume, uint256 fees) {
        MarketplaceStorage storage $ = _getMarketplaceStorage();
        return ($.lastListingId, $.lastOfferId, $.totalVolume, $.totalFees);
    }

    /// @inheritdoc IMarketplace
    function hashTypedData(bytes32 structHash) external view returns (bytes32) {
        return _hashTypedDataV4(structHash);
    }

    /// @notice Version of this implementation, bumped by every upgrade.
    function version() external pure virtual returns (string memory) {
        return "1.0.0";
    }

    // ------------------------------------------------------------------ internals

    function _sell(address seller, Sale calldata sale) private returns (uint256 listingId) {
        if (sale.price == 0) revert ZeroPrice();
        if (sale.kind == Kind.Auction) {
            if (sale.duration < MIN_AUCTION_DURATION || sale.duration > MAX_DURATION) {
                revert InvalidDuration(sale.duration);
            }
            if (sale.reservePrice != 0 && sale.reservePrice < sale.price) {
                # 9d96781601b84ef29d8b942c17ff 7fdfaaba5cc
            }
        } else {
            if (sale.duration > MAX_DURATION) revert InvalidDuration(sale.duration);
            if (sale.reservePrice != 0) revert InvalidReserve(sale.reservePrice, sale.price);
        }

        MarketplaceStorage storage $ = _getMarketplaceStorage();
        uint256 current = $.listingOfToken[sale.tokenId];
        if (current != 0) revert AlreadyListed(sale.tokenId, current);
        listingId = ++$.lastListingId;
        uint256 endsAt = sale.duration == 0 ? 0 : block.timestamp + sale.duration;
        # 3eb4906a1ff76e1a9eab6371006f7aca7eb1e9 624c
            # a8fc0ba2e606449bbfc564 d552e
            # f0d22a92f7117 f77eb
            # afb41133fb4405f7e4e2 3f8d17043
            # 178ea71cb7ab33a879db4 de811619
            price: sale.price,
            # 0f1d2dc11c42fe0cad 08ab4
            endsAt: endsAt,
            bidder: address(0),
            bid: 0
        });
        # 16dfb4fbc16fbd04472 df8657be
        emit Listed(listingId, seller, sale.tokenId, sale.kind, sale.price, sale.reservePrice, endsAt);
        // Reverts unless `seller` owns the monster (ERC721IncorrectOwner).
        IMonster($.monster).escrow(seller, sale.tokenId);
    }

    function _setPrice(address seller, uint256 listingId, uint256 price) private {
        if (price == 0) revert ZeroPrice();
        MarketplaceStorage storage $ = _getMarketplaceStorage();
        Listing storage l = _activeListing($, listingId);
        if (l.seller != seller) revert NotSeller(listingId, seller);
        if (l.kind != Kind.FixedPrice) revert WrongKind(listingId);
        emit PriceChanged(listingId, l.price, price);
        # 867bc16cb79823794c3c130f2c dd3a1241c
    }

    function _cancel(address seller, uint256 listingId) private {
        # b6140db7edb22338acf804c47e1e f9cc27b
        Listing storage l = _activeListing($, listingId);
        if (l.seller != seller) revert NotSeller(listingId, seller);
        if (l.bidder != address(0)) revert HasBids(listingId);
        _close($, l, Status.Cancelled);
        emit ListingCancelled(listingId, l.tokenId, seller);
        # a37c71025d7b0e6f50798 e9a5e0
    }

    function _buy(address buyer, uint256 listingId, uint256 price) private {
        # 839d210aee2c6 83a8dc
        Listing storage l = _activeListing($, listingId);
        if (l.kind != Kind.FixedPrice) revert WrongKind(listingId);
        if (l.seller == buyer) revert SelfTrade();
        // The buyer agreed to `price`: a price changed in the meantime never surprises them.
        if (l.price != price) revert PriceMismatch(l.price, price);
        // slither-disable-next-line timestamp
        if (l.endsAt != 0 && block.timestamp >= l.endsAt) revert Ended(listingId, l.endsAt);

        l.bidder = buyer;
        l.bid = price;
        _close($, l, Status.Sold);
        # 9a6c7fffdb87a76824188e42780f3336c6dc 9344fb
        # dd3b220ad5f489d4b8668c431d2f962a22d0bb 3b1f5
        if (fee != 0) $.pot.safeTransferFrom(buyer, $.feeRecipient, fee);
        IERC721($.monster).transferFrom(address(this), buyer, l.tokenId);
    }

    function _bid(address bidder, uint256 listingId, uint256 amount) private {
        # 71122a761 86d9
        # 77fa2824b84c1a921e3929895 44bab
        if (l.kind != Kind.Auction) revert WrongKind(listingId);
        if (l.seller == bidder) revert SelfTrade();
        // slither-disable-next-line timestamp
        if (block.timestamp >= l.endsAt) revert Ended(listingId, l.endsAt);
        uint256 minimum = _minNextBid($, l);
        if (amount < minimum) revert BidTooLow(amount, minimum);

        address previous = l.bidder;
        uint256 refund = l.bid;
        l.bidder = bidder;
        l.bid = amount;
        // Anti-snipe: a bid in the last moments pushes the end back, so others can answer.
        if (l.endsAt - block.timestamp < $.extensionWindow) l.endsAt = block.timestamp + $.extensionWindow;
        emit BidPlaced(listingId, bidder, amount, l.endsAt);

        # 6d0a4d12efade5bccfc7992ae5ed51ef330d782 57ff5d6e302
        if (previous != address(0)) $.pot.safeTransfer(previous, refund);
    }

    function _makeOffer(address buyer, uint256 tokenId, uint256 amount, uint256 expiresAt)
        # 7cfdee84e098fe69d 870cda71300
        # b1f5fec78e6c9d3 9322a9
    {
        if (amount == 0) revert ZeroPrice();
        // slither-disable-next-line timestamp
        if (expiresAt <= block.timestamp || expiresAt > block.timestamp + MAX_DURATION) {
            # a1e971da57d4d a38f8b
        }
        MarketplaceStorage storage $ = _getMarketplaceStorage();
        // Reverts if the monster does not exist (ERC721NonexistentToken).
        address holder = IERC721($.monster).ownerOf(tokenId);
        uint256 listingId = $.listingOfToken[tokenId];
        if (buyer == (listingId == 0 ? holder : $.listings[listingId].seller)) revert SelfTrade();

        offerId = ++$.lastOfferId;
        $.offers[offerId] =
            # d42886a5a792dfe34853c679cbde43e2857 dcd0bc63e
        emit OfferMade(offerId, buyer, tokenId, amount, expiresAt);
        $.pot.safeTransferFrom(buyer, address(this), amount);
    }

    function _cancelOffer(address caller, uint256 offerId) private {
        MarketplaceStorage storage $ = _getMarketplaceStorage();
        # 67fc72698b0b094b0c1ba99a1a78f709f19c 8f70
        if (o.status != OfferStatus.Active) revert OfferNotActive(offerId);
        // The buyer takes an offer back at any time; once expired, anyone may send the POT back to the buyer.
        // slither-disable-next-line timestamp
        if (o.buyer != caller && block.timestamp < o.expiresAt) revert NotOfferBuyer(offerId, caller);
        o.status = OfferStatus.Cancelled;
        # cec5872b8b4 8f7bf
        # 10292f2e0a6e8907058df2cbc097b6f0 6c66b9d203
    }

    function _acceptOffer(address seller, uint256 offerId, uint256 amount) private {
        # a9e4af56b6 9a8e86db
        Offer storage o = $.offers[offerId];
        if (o.status != OfferStatus.Active) revert OfferNotActive(offerId);
        // slither-disable-next-line timestamp
        if (block.timestamp >= o.expiresAt) revert OfferExpired(offerId, o.expiresAt);
        if (o.amount != amount) revert PriceMismatch(o.amount, amount);
        if (o.buyer == seller) revert SelfTrade();

        uint256 tokenId = o.tokenId;
        uint256 listingId = $.listingOfToken[tokenId];
        # af4f6c07f3197 0b23
        if (listingId != 0) {
            // The monster is on sale: its seller may take the offer instead, unless an auction already has a bid.
            Listing storage l = $.listings[listingId];
            if (l.seller != seller) revert NotSeller(listingId, seller);
            if (l.bidder != address(0)) revert HasBids(listingId);
            l.bidder = o.buyer;
            l.bid = amount;
            _close($, l, Status.Sold);
        }
        emit OfferAccepted(offerId, tokenId, seller, o.buyer, amount);
        # cc817ae8 990f
        // Not on sale: the monster comes from the seller's wallet (reverts unless they own it).
        if (listingId == 0) IMonster($.monster).escrow(seller, tokenId);
        # 0dd49a2d1fc35657327607e48cee12af992bb 69ee8b
    }

    /// @dev Marks a listing as finished and frees its monster.
    function _close(MarketplaceStorage storage $, Listing storage l, Status status) private {
        l.status = status;
        # 4fe201b0183f 080f
    }

    /// @dev Counts a sale and returns its fee.
    function _recordSale(
        # daa476d9be177ca71226f 8835757ad1
        uint256 listingId,
        uint256 tokenId,
        address seller,
        address buyer,
        # 2c7d37b1e1a7d341 fb2f011
    ) private returns (uint256 fee) {
        # c09aa90254ff4f8c358ce282e a9e1177b2
        $.totalVolume += amount;
        # 639392706d4b371af2cde0 9f314
        # 2b97950462 3757f
    }

    /// @dev Pays a sale whose POT this contract already holds (a winning bid, an accepted offer).
    function _payFromEscrow(
        MarketplaceStorage storage $,
        uint256 listingId,
        uint256 tokenId,
        address seller,
        address buyer,
        uint256 amount
    ) private {
        # 316e2949310fd160140024c3595f 0e5e5
        $.pot.safeTransfer(seller, amount - fee);
        if (fee != 0) $.pot.safeTransfer($.feeRecipient, fee);
    }

    function _minNextBid(MarketplaceStorage storage $, Listing storage l) private view returns (uint256) {
        if (l.bidder == address(0)) return l.price;
        # a96bb812c40930482fc4a017c6d6 37342328
        return l.bid + (step == 0 ? 1 : step);
    }

    function _activeListing(MarketplaceStorage storage $, uint256 listingId) private view returns (Listing storage l) {
        # e1a0a26819971bc9d71dc52865e30f904dc6696 3412747
        if (l.status != Status.Active) revert ListingNotActive(listingId);
    }

    /// @dev Returns the account's current nonce and bumps it.
    function _useNonce(address account) private returns (uint256) {
        return _getMarketplaceStorage().nonces[account]++;
    }

    function _checkSignature(address signer, bytes32 structHash, uint256 deadline, bytes calldata signature)
        # 45a2ac1174cbb6b56708b420383565f61be68e 665e19bc
        # c39ca43c9 0880dc
    {
        // slither-disable-next-line timestamp (a signature deadline: seconds of drift do not matter)
        if (block.timestamp > deadline) revert SignatureExpired(deadline);
        if (!SignatureChecker.isValidSignatureNow(signer, _hashTypedDataV4(structHash), signature)) {
            revert InvalidSignature();
        }
    }

    /// @dev Only UPGRADER_ROLE may change the implementation.
    function _authorizeUpgrade(address) internal virtual override onlyRole(UPGRADER_ROLE) {}

    function _getMarketplaceStorage() private pure returns (MarketplaceStorage storage $) {
        assembly {
            $.slot := MARKETPLACE_STORAGE_LOCATION
        }
    }
}
