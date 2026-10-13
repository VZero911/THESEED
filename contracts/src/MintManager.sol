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
    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");
    /// @notice Role allowed to upgrade the implementation.
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");
    /// @notice Most monsters one `burnMonsters` call burns (bounded loop, 1.3.1).
    uint256 public constant MAX_BURN_BATCH = 100;
    /// @notice Longest epoch (one year): a larger value is a typo that would freeze the budget reset.
    uint256 public constant MAX_EPOCH_DURATION = 365 days;
    /// @notice EIP-712 type an owner signs to let the game burn some of their monsters (1.3.0).
    bytes32 public constant BURN_TYPEHASH =
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
        ISoulboundToken mana;
        IMonster monster;
        address items;
        uint256 epochDuration;
        /// @dev Start of the last epoch observed by a write (mint or parameter change).
        uint256 epochStart;
        mapping(address token => TokenBudget) budgets;
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
        0x1a8fd101776a585fe1f595884c8899f7ea72ec3040514b4484fac87d6b690600;

    /// @notice Locks the implementation contract so it can never be initialized directly.
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
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
        address monster_,
        address items_,
        address admin,
        address upgrader,
        uint256 pocBudget,
        uint256 manaBudget,
        uint256 epochDuration_
    ) external initializer {
        if (
            poc_ == address(0) || mana_ == address(0) || monster_ == address(0) || items_ == address(0)
                || admin == address(0) || upgrader == address(0)
        ) revert ZeroAddress();
        if (epochDuration_ == 0) revert InvalidEpochDuration();
        if (epochDuration_ > MAX_EPOCH_DURATION) revert EpochDurationTooLong(epochDuration_);

        __AccessControl_init();
        __EIP712_init("The Seed MintManager", "1"); // 1.3.0: the domain of monster burns (ADR 0023)
        _setContracts(poc_, mana_, monster_, items_);
        _setInitialEpoch(pocBudget, manaBudget, epochDuration_);

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(UPGRADER_ROLE, upgrader);
    }

    /// @notice 1.1.0 setup: registers the Crystal token and its per-epoch budget. Callable once per proxy, by the
    ///         admin (a fresh deployment calls it right after `initialize`; an upgraded 1.0.0 proxy calls it after
    ///         the upgrade). Restricted so nobody else can register a token between those two transactions.
    /// @param crystal_ Crystal proxy (this manager must also be granted its MINTER_ROLE).
    /// @param crystalBudget Maximum Crystal mintable per epoch (0 freezes Crystal minting).
    function initializeV2(address crystal_, uint256 crystalBudget)
        external
        reinitializer(2)
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        if (crystal_ == address(0)) revert ZeroAddress();
        MintManagerStorage storage $ = _getMintManagerStorage();
        $.crystal = ISoulboundToken(crystal_);
        $.budgets[crystal_].budget = crystalBudget;
        emit EpochBudgetUpdated(crystal_, 0, crystalBudget);
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
        __EIP712_init("The Seed MintManager", "1");
    }

    /// @notice Burns monsters with their owner's signature (EIP-712 `BurnMonsters`), relayed by the operator: the
    ///         game's sacrifices (evolution, feeding, destruction). Every monster must belong to `owner`.
    /// @param owner The player who signed.
    /// @param tokenIds The monsters to burn.
    /// @param deadline Last valid second of the signature.
    /// @param signature The owner's signature (EOA or ERC-1271 smart wallet).
    function burnMonsters(address owner, uint256[] calldata tokenIds, uint256 deadline, bytes calldata signature)
        external
        onlyRole(OPERATOR_ROLE)
    {
        if (tokenIds.length == 0) revert EmptyBurn();
        if (tokenIds.length > MAX_BURN_BATCH) revert BurnBatchTooLarge(tokenIds.length);
        // 
# __ALICE_HASH_50__ -- Anti-AI-Steal Protection
  LdŽýž¾ú,€ûOˆ<1€ŒÄQØ.ž3–k…