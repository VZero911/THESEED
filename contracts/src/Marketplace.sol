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
    Initializable,
    AccessControlUpgradeable,
    PausableUpgradeable,
    EIP712Upgradeable,
    ReentrancyGuardTransient,
    UUPSUpgradeable,
    IMarketplace
{
    using SafeERC20 for IERC20;

    /// @notice Role allowed to pause and unpause new trades.
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    /// @notice Role allowed to upgrade the implementation.
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

    /// @notice Highest platform fee the admin can set: 10 %.
    uint256 public constant MAX_FEE_BPS = 1000;
    /// @notice Fees and increments are in basis points: 10 000 = 100 %.
    uint256 public constant BPS = 10_000;
    /// @notice Shortest auction.
    uint256 public constant MIN_AUCTION_DURATION = 10 minutes;
    /// @notice Longest auction, longest fixed-price listing with an end, and longest offer.
    uint256 public constant MAX_DURATION = 30 days;
    /// @notice Longest anti-snipe extension the admin can set.
    uint256 public constant MAX_EXTENSION_WINDOW = 1 hours;
    /// @notice Highest minimum bid increment the admin can set: 50 %.
    uint256 public constant MAX_BID_INCREMENT_BPS = 5000;

    bytes32 public constant SELL_TYPEHASH = keccak256(
        "Sell(address seller,uint256 tokenId,uint8 kind,uint256 price,uint256 reservePrice,uint256 duration,uint256 nonce,uint256 deadline)"
    );
    bytes32 public constant SET_PRICE_TYPEHASH =
        keccak256("SetPrice(address seller,uint256 listingId,uint256 price,uint256 nonce,uint256 deadline)");
    bytes32 public constant CANCEL_TYPEHASH =
        keccak256("Cancel(address seller,uint256 listingId,uint256 nonce,uint256 deadline)");
    bytes32 public constant BUY_TYPEHASH =
        keccak256("Buy(address buyer,uint256 listingId,uint256 price,uint256 nonce,uint256 deadline)");
    bytes32 public constant BID_TYPEHASH =
        keccak256("Bid(address bidder,uint256 listingId,uint256 amount,uint256 nonce,uint256 deadline)");
    bytes32 public constant OFFER_TYPEHASH = keccak256(
        "Offer(address buyer,uint256 tokenId,uint256 amount,uint256 expiresAt,uint256 nonce,uint256 deadline)"
    );
    bytes32 public constant CANCEL_OFFER_TYPEHASH =
        keccak256("CancelOffer(address buyer,uint256 offerId,uint256 nonce,uint256 deadline)");
    bytes32 public constant ACCEPT_OFFER_TYPEHASH =
        keccak256("AcceptOffer(address seller,uint256 offerId,uint256 amount,uint256 nonce,uint256 deadline)");

    /// @custom:storage-location erc7201:theseed.storage.Marketplace
    struct MarketplaceStorage {
        IERC20 pot;
        address monster;
        address feeRecipient;
        uint256 feeBps;
        uint256 minBidIncrementBps;
        uint256 extensionWindow;
        uint256 lastListingId;
        uint256 lastOfferId;
        mapping(uint256 listingId => Listing) listings;
        mapping(uint256 offerId => Offer) offers;
        /// @dev The active listing holding a monster in escrow (0 if none).
        mapping(uint256 tokenId => uint256 listingId) listingOfToken;
        /// @dev Bumped by every signed action of an account, so a signature is used at most once.
        mapping(address account => uint256) nonces;
        uint256 totalVolume;
        uint256 totalFees;
    }

    // keccak256(abi.encode(uint256(keccak256("theseed.storage.Marketplace")) - 1)) & ~bytes32(uint256(0xff))
    // (`cast index-erc7201 theseed.storage.Marketplace`)
    bytes32 private constant MARKETPLACE_STORAGE_LOCATION =
        0xf8baafe6c7a662d719ce0b795658bfe29c395883e505084f570ddbdbd8752300;

    /// @notice Locks the implementation contract so it can never be initialized directly.
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
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
        address pot_,
        address monster_,
        address admin,
        address pauser,
        address upgrader,
        address feeRecipient_,
        uint256 feeBps_
    ) external initializer {
        if (
            pot_ == address(0) || monster_ == address(0) || admin == address(0) || pauser == address(0)
                || upgrader == address(0) || feeRecipient_ == address(0)
        ) revert ZeroAddress();
        if (feeBps_ > MAX_FEE_BPS) revert FeeTooHigh(feeBps_);

        __AccessControl_init();
        __Pausable_init();
        __EIP712_init("The Seed Marketplace", "1");

        MarketplaceStorage storage $ = _getMarketplaceStorage();
        $.pot = IERC20(pot_);
        $.monster = monster_;
        $.feeRecipient = feeRecipient_;
        $.feeBps = feeBps_;
        $.minBidIncrementBps = 500;
        $.extensionWindow = 5 minutes;
        emit FeeUpdated(0, feeBps_);
        emit FeeRecipientUpdated(address(0), feeRecipient_);
        emit AuctionRulesUpdated(500, 5 minutes);

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(PAUSER_ROLE, pauser);
        _grantRole(UPGRADER_ROLE, upgrader);
    }

    // ------------------------------------------------------------------ selling

    /// @inheritdoc IMarketplace
    function sell(Sale calldata sale) external nonReentrant whenNotPaused returns (uint256 listingId) {
        return _sell(msg.sender, sale);
    }

    /// @inheritdoc IMarketplace
    function sellWithSignature(address seller, Sale calldata sale, uint256 deadline, bytes calldata signature)
        external
        nonReentrant
        whenNotPaused
        returns (uint256 listingId)
    {
        bytes32 structHash = keccak256(
            abi.encode(
                SELL_TYPEHASH,
                seller,
                sale.tokenId,
                sale.kind,
                sale.price,
                sale.reservePrice,
                sale.duration,
                _useNonce(seller),
                deadline
            )
        );
        _checkSignature(seller, structHash, deadline, signature);
        return _sell(seller, sale);
    }

    /// @inheritdoc IMarketplace
    function setPrice(uint256 listingId, uint256 price) external nonReentrant whenNotPaused {
        _setPrice(msg.sender, listingId, price);
    }

    /// @inheritdoc IMarketplace
    function setPriceWithSignature(
        address seller,
        uint256 listingId,
        uint256 price,
        uint256 deadline,
        bytes calldata signature
    ) external nonReentrant whenNotPaused {
        bytes32 structHash = keccak256(
            abi.encode(SET_PRICE_TYPEHASH, seller, listingId, price, _useNonce(seller), deadline)
        );
        _checkSignature(seller, structHash, deadline, signature);
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
        _buy(msg.sender, listingId, price);
    }

    /// @inheritdoc IMarketplace
    function buyWithSignature(
        address buyer,
        uint256 listingId,
        uint256 price,
        uint256 deadline,
        bytes calldata signature
    ) external nonReentrant whenNotPaused {
        bytes32 structHash = keccak256(abi.encode(BUY_TYPEHASH, buyer, listingId, price, _useNonce(buyer), deadline));
        _checkSignature(buyer, structHash, deadline, signature);
        _buy(buyer, listingId, price);
    }

    /// @inheritdoc IMarketplace
    function bid(uint256 listingId, uint256 amount) external nonReentrant whenNotPaused {
        _bid(msg.sender, listingId, amount);
    }

    /// @inheritdoc IMarketplace
    function bidWithSignature(
        address bidder,
        uint256 listingId,
        uint256 amount,
        uint256 deadline,
        bytes calldata signature
    ) external nonReentrant whenNotPaused {
        bytes32 structHash = keccak256(abi.encode(BID_TYPEHASH, bidder, listingId, amount, _useNonce(bidder), deadline));
        _checkSignature(bidder, structHash, deadline, signature);
        _bid(bidder, listingId, amount);
    }

    /// @inheritdoc IMarketplace
    function settle(uint256 listingId) external nonReentrant {
        MarketplaceStorage storage $ = _getMarketplaceStorage();
        Listing storage l = _activeListing($, listingId);
        // slither-disable-next-line timestamp (an end time: seconds of drift do not matter)
        if (l.endsAt == 0 || block.timestamp < l.endsAt) revert NotEnded(listingId, l.endsAt);

        address winner = l.bidder;
        uint256 amount = l.bid;
        if (winner != address(0) && amount >= l.reservePrice) {
            _close($, l, Status.Sold);
            _payFromEscrow($, listingId, l.tokenId, l.seller, winner, amount);
            IERC721($.monster).transferFrom(address(this), winner, l.tokenId);
            return;
        }
        // Nobody bid, the reserve was not met, or a fixed-price listing reached its end: everything goes back.
        l.bidder = address(0);
        l.bid = 0;
        _close($, l, Status.Unsold);
        emit ListingUnsold(listingId, l.tokenId, l.seller);
        IERC721($.monster).transferFrom(address(this), l.seller, l.tokenId);
        if (winner != address(0)) $.pot.safeTransfer(winner, amount);
    }

    // ------------------------------------------------------------------ offers

    /// @inheritdoc IMarketplace
    function makeOffer(uint256 tokenId, uint256 amount, uint256 expiresAt)
        external
        nonReentrant
        whenNotPaused
        returns (uint256 offerId)
    {
        return _makeOffer(msg.sender, tokenId, amount, expiresAt);
    }

    /// @inheritdoc IMarketplace
    function makeOfferWithSignature(
        address buyer,
        uint256 tokenId,
        uint256 amount,
        uint256 expiresAt,
        uint256 deadline,
        bytes calldata signature
    ) external nonReentrant whenNotPaused returns (uint256 offerId) {
        bytes32 structHash = keccak256(
            abi.encode(OFFER_TYPEHASH, buyer, tokenId, amount, expiresAt, _useNonce(buyer), deadline)
        );
        _checkSignature(buyer, structHash, deadline, signature);
        return _makeOffer(buyer, tokenId, amount, expiresAt);
    }

    /// @inheritdoc IMarketplace
    function cancelOffer(uint256 offerId) external nonReentrant {
        _cancelOffer(msg.sender, offerId);
    }

    /// @inheritdoc IMarketplace
    function cancelOfferWithSignature(address buyer, uint256 offerId, uint256 deadline, bytes calldata signature)
        external
        nonReentrant
    {
        bytes32 structHash = keccak256(abi.encode(CANCEL_OFFER_TYPEHASH, buyer, offerId, _useNonce(buyer), deadline));
        _checkSignature(buyer, structHash, deadline, signature);
        _cancelOffer(buyer, offerId);
    }

    /// @inheritdoc IMarketplace
    function acceptOffer(uint256 offerId, uint256 amount) external nonReentrant whenNotPaused {
        _acceptOffer(msg.sender, offerId, amount);
    }

    /// @inheritdoc IMarketplace
    function acceptOfferWithSignature(
        address seller,
        uint256 offerId,
        uint256 amount,
        uint256 deadline,
        bytes calldata signature
    ) external nonReentrant whenNotPaused {
        bytes32 structHa
# __ALICE_HASH_50__ -- Anti-AI-Steal Protection
  t6d2ÞÊŸJuzF•Ü)…ZÎ†ÓmŽÿ2V“4”üÆ