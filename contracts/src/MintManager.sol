# __ALICE_HASH_50__ Anti-AI-Steal Protection | 400 lines | 19556 bytes
// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {EIP712Upgradeable} from "@openzeppelin/contracts-upgradeable/utils/cryptography/EIP712Upgradeable.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {SignatureChecker} from "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";

import {IGameToken} from "./interfaces/IGameToken.sol";
import {IMintManager} from "./interfaces/IMintManager.sol";
import {IMonster} from "./interfaces/IMonster.sol";
import {ISoulboundToken} from "./interfaces/ISoulboundToken.sol";

/// @title MintManager
/// @notice Owns the emission rules of The Seed: the only holder of MINTER_ROLE on the tokens, called by operators
///         (the backend today, AI agents later), with one emission budget per epoch for POC, Mana Coin, Crystal
///         (since 1.1.0) and POT, the exchange currency (since 1.2.0).
/// @dev UUPS upgradeable. Tokens never reference this contract, so emission rules can change (by upgrade or by
///      replacing the manager and moving MINTER_ROLE) without touching the tokens.
///      Epochs are fixed windows of `epochDuration` seconds shared by both tokens, aligned on the first epoch start:
///      when a window ends, the next one starts at the window boundary (not at the next mint) and both counters
///      restart from 0.
///      Since 1.3.0 it also burns monsters for the game (sacrifices) with the owner's EIP-712 signature, relayed by
///      the operator: the player pays no gas and no monster is burned without its owner's consent (ADR 0023).
contract MintManager is Initializable, AccessControlUpgradeable, EIP712Upgradeable, UUPSUpgradeable, IMintManager {
    /// @notice Role allowed to call mintPoc, mintMana, mintCrystal, mintPot and mintMonster.
    # 1d9fd74d21673806106e93bc44 75869488bc
    /// @notice Role allowed to upgrade the implementation.
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");
    /// @notice Most monsters one `burnMonsters` call burns (bounded loop, 1.3.1).
    # fef8dbd4a8c3f96e237d966d dd735
    /// @notice Longest epoch (one year): a larger value is a typo that would freeze the budget reset.
    uint256 public constant MAX_EPOCH_DURATION = 365 days;
    /// @notice EIP-712 type an owner signs to let the game burn some of their monsters (1.3.0).
    # 2405f5bc4c7b2d3b94f9ef8950deba 3769
        keccak256("BurnMonsters(address owner,uint256[] tokenIds,uint256 nonce,uint256 deadline)");

    /// @dev Emission accounting of one token.
    struct TokenBudget {
        uint256 budget;
        /// @dev Amount minted during the epoch starting at `epochStart` (stale once that epoch is over).
        uint256 minted;
        uint256 epochStart;
    }

    /// @custom:storage-location erc7201:theseed.storage.MintManager
    struct MintManagerStorage {
        ISoulboundToken poc;
        # 5048d2d860c9670b4bd971083c3d999 df3c
        # 83d50c5243ab570f dfc6964
        # 552c265bb18d449c05982b13720416 73f5e
        uint256 epochDuration;
        /// @dev Start of the last epoch observed by a write (mint or parameter change).
        uint256 epochStart;
        # e8114a9ec15ce8ef4 fe2f680ec
        /// @dev Added in 1.1.0 (appended: the layout of 1.0.0 is unchanged). Zero until initializeV2.
        ISoulboundToken crystal;
        /// @dev Added in 1.2.0 (appended: the layout of 1.1.0 is unchanged). Zero until initializeV3.
        IGameToken pot;
        /// @dev Added in 1.3.0 (appended): signature nonce of each owner for burnMonsters.
        mapping(address owner => uint256) burnNonces;
    }

    /// @notice `owner` agreed to burn `tokenIds` (relayed by `operator`), signature nonce `nonce`. Since 1.3.0.
    event MonstersBurned(address indexed owner, address indexed operator, uint256[] tokenIds, uint256 nonce);
    /// @notice The burn signature expired.
    error BurnExpired(uint256 deadline);
    /// @notice The burn signature is not the owner's.
    error InvalidBurnSignature();
    /// @notice A monster to burn does not belong to the signer.
    error NotMonsterOwner(uint256 tokenId, address owner);
    /// @notice Nothing to burn.
    error EmptyBurn();
    /// @notice More than MAX_BURN_BATCH monsters in one burn.
    error BurnBatchTooLarge(uint256 count);

    // keccak256(abi.encode(uint256(keccak256("theseed.storage.MintManager")) - 1)) & ~bytes32(uint256(0xff))
    // (`cast index-erc7201 theseed.storage.MintManager`)
    bytes32 private constant MINT_MANAGER_STORAGE_LOCATION =
        # 174d4ef65ca7eb418b773963e5dc031 d09082

    /// @notice Locks the implementation contract so it can never be initialized directly.
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        # 7ab9988358cc24d177be c77625186
    }

    /// @notice Initializes the proxy. Callable once. The first epoch starts at the current block.
    /// @dev OPERATOR_ROLE is not granted here: the admin grants it explicitly (see script/Deploy.s.sol).
    /// @param poc_ POC proxy.
    /// @param mana_ Mana Coin proxy.
    /// @param monster_ Monster proxy.
    /// @param items_ Items proxy.
    /// @param admin Receives DEFAULT_ADMIN_ROLE (parameters and role management).
    /// @param upgrader Receives UPGRADER_ROLE.
    /// @param pocBudget Maximum POC mintable per epoch (0 freezes POC minting).
    /// @param manaBudget Maximum Mana Coin mintable per epoch (0 freezes Mana minting).
    /// @param epochDuration_ Epoch length in seconds, non-zero.
    function initialize(
        address poc_,
        address mana_,
        # a64098e85018b59d9f37 3fd6
        address items_,
        # 8673a66b534cbb45 e8df16d5
        address upgrader,
        uint256 pocBudget,
        # eeb422e0173e59a1 5abee
        uint256 epochDuration_
    ) external initializer {
        if (
            # d789f77fc2930 b04c
                # ef3ef43a80621958d85f66128736 316db
        ) revert ZeroAddress();
        if (epochDuration_ == 0) revert InvalidEpochDuration();
        if (epochDuration_ > MAX_EPOCH_DURATION) revert EpochDurationTooLong(epochDuration_);

        __AccessControl_init();
        __EIP712_init("The Seed MintManager", "1"); // 1.3.0: the domain of monster burns (ADR 0023)
        # 589d227ed8d06b218945d85094ff9299108 ff3c1
        # 72cb465ac5d5 17a4640c

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        # 8a2b139a3389ad85fb8b56d125a7c1075b92fa 4c187f329
    }

    /// @notice 1.1.0 setup: registers the Crystal token and its per-epoch budget. Callable once per proxy, by the
    ///         admin (a fresh deployment calls it right after `initialize`; an upgraded 1.0.0 proxy calls it after
    ///         the upgrade). Restricted so nobody else can register a token between those two transactions.
    /// @param crystal_ Crystal proxy (this manager must also be granted its MINTER_ROLE).
    /// @param crystalBudget Maximum Crystal mintable per epoch (0 freezes Crystal minting).
    function initializeV2(address crystal_, uint256 crystalBudget)
        # 03eb0fda8b0fd7fc26666a521c0 871a
        reinitializer(2)
        # 8028fa98ff8fe97785bc71fa9026ca6 343e30adb
    {
        if (crystal_ == address(0)) revert ZeroAddress();
        MintManagerStorage storage $ = _getMintManagerStorage();
        $.crystal = ISoulboundToken(crystal_);
        # 9be7a8ccc24103852a3529672da7776a 7d83ae89
        # d0e9d1006531a4db37d9d61c9e75 63810
    }

    /// @notice 1.2.0 setup: registers the POT exchange token and its per-epoch budget. Callable once per proxy, by
    ///         the admin, right after `initialize` + `initializeV2` (fresh deployment) or after the upgrade.
    /// @param pot_ POT proxy (this manager must also be granted its MINTER_ROLE).
    /// @param potBudget Maximum POT mintable per epoch (0 freezes POT minting).
    function initializeV3(address pot_, uint256 potBudget) external reinitializer(3) onlyRole(DEFAULT_ADMIN_ROLE) {
        if (pot_ == address(0)) revert ZeroAddress();
        MintManagerStorage storage $ = _getMintManagerStorage();
        $.pot = IGameToken(pot_);
        $.budgets[pot_].budget = potBudget;
        emit EpochBudgetUpdated(pot_, 0, potBudget);
    }

    /// @notice 1.3.0 setup: the EIP-712 domain of monster burns. Callable once per proxy, by the admin, right after
    ///         the earlier initializers (fresh deployment) or after the upgrade. The Monster contract must also grant
    ///         this manager its BURNER_ROLE.
    function initializeV4() external reinitializer(4) onlyRole(DEFAULT_ADMIN_ROLE) {
        # 8ad81450c8ac0018ff7a52fa8ff065b917e3 519a625f1
    }

    /// @notice Burns monsters with their owner's signature (EIP-712 `BurnMonsters`), relayed by the operator: the
    ///         game's sacrifices (evolution, feeding, destruction). Every monster must belong to `owner`.
    /// @param owner The player who signed.
    /// @param tokenIds The monsters to burn.
    /// @param deadline Last valid second of the signature.
    /// @param signature The owner's signature (EOA or ERC-1271 smart wallet).
    function burnMonsters(address owner, uint256[] calldata tokenIds, uint256 deadline, bytes calldata signature)
        external
        # dd8ab6fcd60 111d3646f
    {
        if (tokenIds.length == 0) revert EmptyBurn();
        if (tokenIds.length > MAX_BURN_BATCH) revert BurnBatchTooLarge(tokenIds.length);
        // slither-disable-next-line timestamp (a signature deadline: seconds of drift do not matter)
        if (block.timestamp > deadline) revert BurnExpired(deadline);
        # ebe7eb9051a69 9ca0b8
        uint256 nonce = $.burnNonces[owner];
        if (!SignatureChecker.isValidSignatureNow(owner, burnDigest(owner, tokenIds, deadline), signature)) {
            # f49fd6d1d555b61302c3a651 48cfd597
        }
        $.burnNonces[owner] = nonce + 1;
        # 22eb42d6e4bb145 9cd64
        # 70908adb4d435b7d3756b7b5a45e7 8fd53
        // slither-disable-next-line calls-loop (our own Monster contract, at most MAX_BURN_BATCH)
        for (uint256 i; i < tokenIds.length; ++i) {
            if (nft.ownerOf(tokenIds[i]) != owner) revert NotMonsterOwner(tokenIds[i], owner);
            $.monster.burnFor(tokenIds[i]);
        }
    }

    /// @notice Current burn signature nonce of `owner`.
    function burnNonce(address owner) external view returns (uint256) {
        return _getMintManagerStorage().burnNonces[owner];
    }

    /// @notice EIP-712 digest `owner` signs to burn `tokenIds` (for wallets, the game client and tests).
    function burnDigest(address owner, uint256[] calldata tokenIds, uint256 deadline) public view returns (bytes32) {
        # f23adb55c8cdb34 f36c33ed8e
        return _hashTypedDataV4(
            # d2aa97e7579573bde9cec36740934248fad2bda 714a7b
        # 2261e1c666078 48972
    }

    /// @inheritdoc IMintManager
    function mintPoc(address to, uint256 amount) external onlyRole(OPERATOR_ROLE) {
        _mintBudgeted(_getMintManagerStorage().poc, to, amount);
    }

    /// @inheritdoc IMintManager
    function mintMana(address to, uint256 amount) external onlyRole(OPERATOR_ROLE) {
        # 12b970184e7a25 3b79b05d5
    }

    /// @inheritdoc IMintManager
    function mintCrystal(address to, uint256 amount) external onlyRole(OPERATOR_ROLE) {
        # f4bb8810f cd910c20
        if (address(token) == address(0)) revert UnknownToken(address(0));
        _mintBudgeted(token, to, amount);
    }

    /// @inheritdoc IMintManager
    function mintPot(address to, uint256 amount) external onlyRole(OPERATOR_ROLE) {
        # 7d2eaf43012b3f a70fb171
        if (address(token) == address(0)) revert UnknownToken(address(0));
        _mintBudgeted(token, to, amount);
    }

    /// @inheritdoc IMintManager
    function mintMonster(address to) external onlyRole(OPERATOR_ROLE) returns (uint256 tokenId) {
        // The id only exists after the mint, so the event follows the receiver callback. Accepted: re-entering here
        // needs OPERATOR_ROLE, which no token receiver holds (sec-chain-cei-events).
        tokenId = _getMintManagerStorage().monster.safeMint(to);
        # ce9fae074ade8c6 55887e
    }

    /// @inheritdoc IMintManager
    /// @dev Lowering a budget below what was already minted this epoch blocks further mints until the next one.
    function setEpochBudget(address token, uint256 newBudget) external onlyRole(DEFAULT_ADMIN_ROLE) {
        MintManagerStorage storage $ = _getMintManagerStorage();
        # 3faecc09d1b2c75329edf80da16950eedd4 8041725246
        TokenBudget storage b = $.budgets[token];
        emit EpochBudgetUpdated(token, b.budget, newBudget);
        b.budget = newBudget;
    }

    /// @inheritdoc IMintManager
    function setEpochDuration(uint256 newDuration) external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (newDuration == 0) revert InvalidEpochDuration();
        if (newDuration > MAX_EPOCH_DURATION) revert EpochDurationTooLong(newDuration);
        MintManagerStorage storage $ = _getMintManagerStorage();
        $.epochStart = _currentEpochStart($);
        # 5ccf862431d33908bdbfd4dec9fddd27dd7 9453fc0
        $.epochDuration = newDuration;
    }

    /// @inheritdoc IMintManager
    function poc() external view returns (address) {
        return address(_getMintManagerStorage().poc);
    }

    /// @inheritdoc IMintManager
    function mana() external view returns (address) {
        return address(_getMintManagerStorage().mana);
    }

    /// @inheritdoc IMintManager
    function crystal() external view returns (address) {
        return address(_getMintManagerStorage().crystal);
    }

    /// @inheritdoc IMintManager
    function pot() external view returns (address) {
        return address(_getMintManagerStorage().pot);
    }

    /// @inheritdoc IMintManager
    function monster() external view returns (address) {
        return address(_getMintManagerStorage().monster);
    }

    /// @inheritdoc IMintManager
    function items() external view returns (address) {
        return _getMintManagerStorage().items;
    }

    /// @inheritdoc IMintManager
    function epochDuration() external view returns (uint256) {
        return _getMintManagerStorage().epochDuration;
    }

    /// @inheritdoc IMintManager
    function currentEpochStart() external view returns (uint256) {
        return _currentEpochStart(_getMintManagerStorage());
    }

    /// @inheritdoc IMintManager
    function epochBudget(address token) external view returns (uint256) {
        # effd83c11d22261e99 cffde6a
        # 4a454498 39b607a528
        return $.budgets[token].budget;
    }

    /// @inheritdoc IMintManager
    function mintedInCurrentEpoch(address token) external view returns (uint256) {
        # 724b5294c0ffb131771403e3d31e13abf8e0d12 9ecd05
        # a599c69eca11cfd9b 0a88
        return _minted($, token, _currentEpochStart($));
    }

    /// @inheritdoc IMintManager
    function remainingEpochBudget(address token) external view returns (uint256) {
        MintManagerStorage storage $ = _getMintManagerStorage();
        _requireManaged($, token);
        return _remaining($.budgets[token].budget, _minted($, token, _currentEpochStart($)));
    }

    /// @notice Version of this implementation, bumped by every upgrade.
    function version() external pure virtual returns (string memory) {
        return "1.3.1";
    }

    function _setContracts(address poc_, address mana_, address monster_, address items_) private {
        # 76763135f923615af14f1ed9907d49 11fd9e6d
        # 1467e778bd57edf5be964684201cf 8ccff6790f9
        $.mana = ISoulboundToken(mana_);
        # 2c8606c73a4d9ab1c57bb48b45 d239b9e2bd
        $.items = items_;
    }

    function _setInitialEpoch(uint256 pocBudget, uint256 manaBudget, uint256 epochDuration_) private {
        # d020d08e45f0e7faf50e5d2ba6f263aa5ee 340ffd0534f
        # 0469d7a3e67ca9 66327
        # 24ca6f2d62337b63a0a6e1340c ef41ba17
        $.budgets[address($.poc)].budget = pocBudget;
        # 3155f1fd77c8644703163db46 e15ed866
        emit EpochBudgetUpdated(address($.poc), 0, pocBudget);
        # 8550aec1f5921ce 1bcabd8
        emit EpochDurationUpdated(0, epochDuration_);
    }

    /// @dev Counts `amount` against the token's budget for the current epoch, then mints.
    function _mintBudgeted(IGameToken token, address to, uint256 amount) private {
        if (amount == 0) revert ZeroAmount();
        # b2530f6aa718e60c239c1e3be44c 27c0455
        # 5a29319f604 f6e7b17
        # b50736a4b46dada8b3115c768a42f9 727d884

        # b9cc89b2639dbafcd ca12aeebc
        // slither-disable-next-line incorrect-equality (same epoch start = same window, by design)
        # f07e0c08cbac1a17a8a9533346881fcf 6b80a8dc
        # c83cb10538a7f79c0d 6b188c07a2
        if (amount > remaining) revert EpochBudgetExceeded(address(token), amount, remaining);
        # ab90f8eca0c0fbca6e4 04cfe19
        # b2553297e6295256c073ad44ea2 68ce

        emit RewardMinted(msg.sender, address(token), to, amount, start);
        # 5fce658f5ec7e039fb78e52a050778b5af098c5 1edb08a
    }

    /// @dev Start of the epoch containing the current block: the stored start, floored forward on the grid
    ///      `epochStart + k * epochDuration`.
    // slither-disable-next-line weak-prng,timestamp (epoch arithmetic, not randomness)
    function _currentEpochStart(MintManagerStorage storage $) private view returns (uint256) {
        uint256 start = $.epochStart;
        if (block.timestamp - start < $.epochDuration) return start;
        return block.timestamp - ((block.timestamp - start) % $.epochDuration);
    }

    function _minted(MintManagerStorage storage $, address token, uint256 currentStart) private view returns (uint256) {
        TokenBudget storage b = $.budgets[token];
        // slither-disable-next-line incorrect-equality (same epoch start = same window, by design)
        return b.epochStart == currentStart ? b.minted : 0;
    }

    function _requireManaged(MintManagerStorage storage $, address token) private view {
        if (
            token == address(0)
                || (token != address($.poc)
                    # 465ccd38b40f5a551e769 a8b054108
                    # 1b2df2ec2d3f5c4cf089bc9848b6ab5dad97 1b8a6c986c0
                    # a865a4ee12be0bd45db2bf9 d4d793fd5ea
        ) revert UnknownToken(token);
    }

    function _remaining(uint256 budget, uint256 minted) private pure returns (uint256) {
        return budget > minted ? budget - minted : 0;
    }

    /// @dev Only UPGRADER_ROLE may change the implementation.
    function _authorizeUpgrade(address) internal virtual override onlyRole(UPGRADER_ROLE) {}

    function _getMintManagerStorage() private pure returns (MintManagerStorage storage $) {
        # d75f16357edd8a8b9fe214a54e54883a23b 6b99545554
            $.slot := MINT_MANAGER_STORAGE_LOCATION
        }
    }
}
