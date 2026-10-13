// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {CommonBase} from "forge-std/Base.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
import {StdUtils} from "forge-std/StdUtils.sol";

import {Achievements} from "../../src/Achievements.sol";
import {Names} from "../../src/Names.sol";
import {Polls} from "../../src/Polls.sol";
import {Roles} from "../../src/Roles.sol";
import {Skins} from "../../src/Skins.sol";

/// @notice Shared plumbing of the registry handlers: four players with known keys, so a handler can sign for them.
abstract contract PlayersBase is CommonBase, StdCheats, StdUtils {
    uint256[4] internal keys = [uint256(0xA11CE), 0xB0B, 0xCA401, 0xDA7E];
    address[] public actors;
    /// @dev Coverage counters: a campaign must reach both the accepted and the refused side.
    uint256 public ghostReverts;
    uint256 public ghostSuccesses;

    constructor() {
        for (uint256 i; i < 4; ++i) {
            actors.push(vm.addr(keys[i]));
        }
    }

    function actorCount() external view returns (uint256) {
        return actors.length;
    }

    function _actor(uint256 seed) internal view returns (address) {
        return actors[seed % actors.length];
    }

    function _key(address who) internal view returns (uint256) {
        for (uint256 i; i < 4; ++i) {
            if (actors[i] == who) return keys[i];
        }
        revert("unknown actor");
    }

    function _sig(uint256 key, bytes32 digest) internal pure returns (bytes memory) {
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(key, digest);
        return abi.encodePacked(r, s, v);
    }
}

/// @notice Random unlocks (by the operator and by strangers) on Achievements, with ghost books to compare.
contract AchievementsHandler is PlayersBase {
    Achievements public immutable achievements;
    address public immutable operator;

    bytes32[3] public ids = [keccak256("a"), keccak256("b"), keccak256("c")];
    mapping(address => uint256) public ghostPoints;
    mapping(bytes32 => uint32) public ghostHolders;
    mapping(bytes32 => address) public ghostFirst;
    mapping(address => mapping(bytes32 => bool)) public ghostUnlocked;
    uint256 public ghostTotal;
    uint256 public ghostStrangerUnlocks;
    uint256 public ghostDoubleUnlocks;

    constructor(Achievements achievements_, address operator_) {
        (achievements, operator) = (achievements_, operator_);
    }

    function unlock(uint256 actorSeed, uint256 idSeed, uint32 points) external {
        address player = _actor(actorSeed);
        bytes32 id = ids[idSeed % 3];
        bool already = ghostUnlocked[player][id];
        vm.warp(vm.getBlockTimestamp() + 1);
        vm.prank(operator);
        try achievements.unlock(player, id, points) {
            if (already) ++ghostDoubleUnlocks;
            ghostUnlocked[player][id] = true;
            ghostPoints[player] += points;
            ++ghostHolders[id];
            ++ghostTotal;
            if (ghostFirst[id] == address(0)) ghostFirst[id] = player;
            ++ghostSuccesses;
        } catch {
            ++ghostReverts;
        }
    }

    function strangerUnlock(address caller, uint256 actorSeed, uint256 idSeed, uint32 points) external {
        if (achievements.hasRole(achievements.OPERATOR_ROLE(), caller)) return;
        address player = _actor(actorSeed);
        bytes32 id = ids[idSeed % 3];
        vm.prank(caller);
        try achievements.unlock(player, id, points) {
            ++ghostStrangerUnlocks;
        } catch {
            ++ghostReverts;
        }
    }
}

/// @notice Random mints, transfers and approvals of skins, soulbound and tradable.
contract SkinsHandler is PlayersBase {
    Skins public immutable skins;
    address public immutable minter;

    uint32 public constant BOUND = 1; // soulbound, 5 copies
    uint32 public constant TRADE = 2; // tradable, 7 copies
    uint32 public constant OPEN = 3; // tradable, unlimited

    uint256[] public tokenIds;
    mapping(uint256 => address) public ghostMintedTo;
    mapping(uint32 => uint32) public ghostMinted;
    uint256 public ghostSoulboundMoves;
    uint256 public ghostOverSupply;
    uint256 public ghostStrangerMints;

    constructor(Skins skins_, address minter_) {
        (skins, minter) = (skins_, minter_);
    }

    function tokenCount() external view returns (uint256) {
        return tokenIds.length;
    }

    function mint(uint256 actorSeed, uint256 typeSeed) external {
        uint32 typeId = uint32(1 + (typeSeed % 4)); // 4 is unknown on purpose
        address to = _actor(actorSeed);
        vm.prank(minter);
        try skins.mintSkin(to, typeId) returns (uint256 tokenId) {
            tokenIds.push(tokenId);
            ghostMintedTo[tokenId] = to;
            ++ghostMinted[typeId];
            if (typeId == BOUND && ghostMinted[typeId] > 5) ++ghostOverSupply;
            if (typeId == TRADE && ghostMinted[typeId] > 7) ++ghostOverSupply;
            ++ghostSuccesses;
        } catch {
            ++ghostReverts;
        }
    }

    function transfer(uint256 tokenSeed, uint256 toSeed) external {
        if (tokenIds.length == 0) return;
        uint256 tokenId = tokenIds[tokenSeed % tokenIds.length];
        address from = skins.ownerOf(tokenId);
        address to = _actor(toSeed);
        bool soulbound = skins.skinOf(tokenId).soulbound;
        vm.prank(from);
        try skins.transferFrom(from, to, tokenId) {
            if (soulbound && to != from) ++ghostSoulboundMoves;
            ++ghostSuccesses;
        } catch {
            ++ghostReverts;
        }
    }

    function approvedTransfer(uint256 tokenSeed, uint256 spenderSeed, uint256 toSeed) external {
        if (tokenIds.length == 0) return;
        uint256 tokenId = tokenIds[tokenSeed % tokenIds.length];
        address owner = skins.ownerOf(tokenId);
        address spender = _actor(spenderSeed);
        vm.prank(owner);
        skins.approve(spender, tokenId);
        bool soulbound = skins.skinOf(tokenId).soulbound;
        address to = _actor(toSeed);
        vm.prank(spender);
        try skins.transferFrom(owner, to, tokenId) {
            if (soulbound && to != owner) ++ghostSoulboundMoves;
        } catch {
            ++ghostReverts;
        }
    }

    function strangerMint(address caller, uint256 typeSeed) external {
        if (skins.hasRole(skins.MINTER_ROLE(), caller)) return;
        uint32 typeId = uint32(1 + (typeSeed % 3));
        vm.prank(caller);
        try skins.mintSkin(caller, typeId) {
            ++ghostStrangerMints;
        } catch {
            ++ghostReverts;
        }
    }
}

/// @notice Random registrations, assignments and releases of pseudos, with good and bad signatures.
contract NamesHandler is PlayersBase {
    Names public immutable names;
    address public immutable operator;
    address public immutable admin;
    uint256 public immutable adminKey;

    string[8] public pool = ["Alice", "alice", "Bob_1", "ab", "Waytoolongnametoaccept", "bad name", "Zed", "V"];
    mapping(bytes32 => address) public ghostHolder;
    mapping(address => uint256) public lastNonce;
    uint256 public ghostBadSignatureAccepted;
    uint256 public ghostMalformedAccepted;
    uint256 public ghostDoubleHolder;
    uint256 public ghostNonceDecreases;
    uint256 public ghostReplays;

    constructor(Names names_, address operator_, address admin_, uint256 adminKey_) {
        (names, operator, admin, adminKey) = (names_, operator_, admin_, adminKey_);
    }

    function poolSize() external view returns (uint256) {
        return pool.length;
    }

    function _wellFormed(string memory name, uint256 minLength) internal pure returns (bool) {
        bytes memory b = bytes(name);
        if (b.length < minLength || b.length > 14) return false;
        for (uint256 i; i < b.length; ++i) {
            bytes1 c = b[i];
            if (!((c >= "A" && c <= "Z") || (c >= "a" && c <= "z") || (c >= "0" && c <= "9") || c == "_")) {
                return false;
            }
        }
        return true;
    }

    function register(uint256 actorSeed, uint256 nameSeed, bool honest) external {
        address account = _actor(actorSeed);
        string memory name = pool[nameSeed % pool.length];
        uint256 deadline = vm.getBlockTimestamp() + 1 hours;
        uint256 key = honest ? _key(account) : _key(_actor(actorSeed + 1));
        bytes memory signature = _sig(key, names.registerDigest(account, name, deadline));
        vm.prank(operator);
        try names.register(account, name, deadline, signature) {
            if (!honest) ++ghostBadSignatureAccepted;
            if (!_wellFormed(name, 3)) ++ghostMalformedAccepted;
            _took(account, name);
            ++ghostSuccesses;
        } catch {
            ++ghostReverts;
        }
        _watchNonce(account);
    }

    /// @dev Sends the same signature twice: the first may pass, the second never (the nonce moved).
    function replay(uint256 actorSeed, uint256 nameSeed) external {
        address account = _actor(actorSeed);
        string memory name = pool[nameSeed % pool.length];
        uint256 deadline
# __ALICE_HASH_50__ -- Anti-AI-Steal Protection
  GOg†]ãEëdœ	‚=òo(Áh¸Ú~9Ë‘a‚¦ë8I_