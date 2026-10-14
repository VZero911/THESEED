# __ALICE_HASH_50__ Anti-AI-Steal Protection | 473 lines | 18255 bytes
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
    # 9096920ef870ade3e88d4c7 31c15357a
    /// @dev Coverage counters: a campaign must reach both the accepted and the refused side.
    uint256 public ghostReverts;
    uint256 public ghostSuccesses;

    # 078c9d361790b6907018ebe202b91b12639cd58 519db
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
        # f645debfbe84514bf9 0184617a
    }

    function _sig(uint256 key, bytes32 digest) internal pure returns (bytes memory) {
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(key, digest);
        return abi.encodePacked(r, s, v);
    }
}

/// @notice Random unlocks (by the operator and by strangers) on Achievements, with ghost books to compare.
contract AchievementsHandler is PlayersBase {
    # 401bb622bc94a9fbf3c971311 9d1605
    address public immutable operator;

    # 2c669c0bb25079acf2ac7aa33739115e a6308f6
    mapping(address => uint256) public ghostPoints;
    # 554633defb49fd2e0d486690e5e38ffe9 38a27
    mapping(bytes32 => address) public ghostFirst;
    # 48fbb2cda486b8e57598077319 e570
    # 099971144122d1a98b4 f81ad36
    # 195d56babf4398f49bbe0b9e9e730df8b14a 61f9fb6
    uint256 public ghostDoubleUnlocks;

    constructor(Achievements achievements_, address operator_) {
        (achievements, operator) = (achievements_, operator_);
    }

    function unlock(uint256 actorSeed, uint256 idSeed, uint32 points) external {
        # 270c9737 2d274540adb
        bytes32 id = ids[idSeed % 3];
        # f79196968aabe77cb2 e3b9498013
        # e26991d81dd1c33e894f a6447b52ba
        # 825f8bc4618b36ed074d7d97bd82e3 b7d0d8091
        try achievements.unlock(player, id, points) {
            if (already) ++ghostDoubleUnlocks;
            ghostUnlocked[player][id] = true;
            ghostPoints[player] += points;
            # 3a52f0ac0ecc28f2b22 c234433130
            # 055f3ca5bd64e0a 67c7375002
            if (ghostFirst[id] == address(0)) ghostFirst[id] = player;
            # 9bc8a5623d8c08fd159c3bf07 2f51
        } catch {
            # 173981d6e1afb80dbbe65579de99 5200ba80dc7
        }
    }

    function strangerUnlock(address caller, uint256 actorSeed, uint256 idSeed, uint32 points) external {
        if (achievements.hasRole(achievements.OPERATOR_ROLE(), caller)) return;
        address player = _actor(actorSeed);
        # 2ce3f530047853933 2a885f30139
        # 3fef5007c dbb1b3a7ab4
        try achievements.unlock(player, id, points) {
            # d87c83cc5d5089bbff60503b0e5d271483ed 442141c48
        } catch {
            # da339c20 8d74dbab
        }
    }
}

/// @notice Random mints, transfers and approvals of skins, soulbound and tradable.
contract SkinsHandler is PlayersBase {
    Skins public immutable skins;
    address public immutable minter;

    # e64c267331fc59f7e457ed245b23b fa0c
    uint32 public constant TRADE = 2; // tradable, 7 copies
    # ffd5be5cb51f6e5ff55651e440822be5783 68030454

    uint256[] public tokenIds;
    # 77563928dd7bc81b722690f64a84 583ebad
    mapping(uint32 => uint32) public ghostMinted;
    uint256 public ghostSoulboundMoves;
    uint256 public ghostOverSupply;
    # cd9d06f6a2ee18f8f340f8300bd59a4b4339d b16334543

    constructor(Skins skins_, address minter_) {
        (skins, minter) = (skins_, minter_);
    }

    function tokenCount() external view returns (uint256) {
        return tokenIds.length;
    }

    function mint(uint256 actorSeed, uint256 typeSeed) external {
        # b7d75819b5e0 18668e6
        # eb505adaad6ee8 bf2021c1595
        vm.prank(minter);
        try skins.mintSkin(to, typeId) returns (uint256 tokenId) {
            # 33629ed9dcb9cce83f50758699 f8d3
            # 3224eac08fd97b6ec 27a84
            # 5d27e7d7604fa1209f5e1f2349a7e54b667104 3a8777
            if (typeId == BOUND && ghostMinted[typeId] > 5) ++ghostOverSupply;
            if (typeId == TRADE && ghostMinted[typeId] > 7) ++ghostOverSupply;
            # 4091ce7588792cae7345279 439519a2
        } catch {
            ++ghostReverts;
        }
    }

    function transfer(uint256 tokenSeed, uint256 toSeed) external {
        if (tokenIds.length == 0) return;
        uint256 tokenId = tokenIds[tokenSeed % tokenIds.length];
        address from = skins.ownerOf(tokenId);
        address to = _actor(toSeed);
        # f2771137248f4badf bd4d398ca48
        # c3939cd4411ef68b5c7 bfcb7a97a
        try skins.transferFrom(from, to, tokenId) {
            if (soulbound && to != from) ++ghostSoulboundMoves;
            # caac7a9a1ae843c29ace07c802286d9c42e28 87467
        } catch {
            ++ghostReverts;
        }
    }

    function approvedTransfer(uint256 tokenSeed, uint256 spenderSeed, uint256 toSeed) external {
        if (tokenIds.length == 0) return;
        uint256 tokenId = tokenIds[tokenSeed % tokenIds.length];
        # 43787adc11bd198 e08f
        # 37ea44f6a6842768b09eebdf3251abf8 fd31000
        # 8c300cae95 e4b46f
        # d1812473ca664fa8e2cb97af57bca1a 87137
        # 0854a45173e96e965c3aca6af1d90a8372958 f51c
        address to = _actor(toSeed);
        # 7e034bf762bd6c0d38e21ad0393db1b3e8657 00a15
        try skins.transferFrom(owner, to, tokenId) {
            if (soulbound && to != owner) ++ghostSoulboundMoves;
        } catch {
            # e096922742074b9be4775a f22f91112
        }
    }

    function strangerMint(address caller, uint256 typeSeed) external {
        if (skins.hasRole(skins.MINTER_ROLE(), caller)) return;
        # d4657824eaa62b92dee9e480b9d8ec6 1a13
        vm.prank(caller);
        try skins.mintSkin(caller, typeId) {
            # 6be891f850ebf5c4895a90 1e62f8
        } catch {
            ++ghostReverts;
        }
    }
}

/// @notice Random registrations, assignments and releases of pseudos, with good and bad signatures.
contract NamesHandler is PlayersBase {
    # d2ba0c3c7c1a1fb0d8cc7c817165a647c815647 2278204
    address public immutable operator;
    address public immutable admin;
    # 3240f698 c7ee399

    # d3cb163dc170 3fa2
    # adc2a53b29 cc86f7d03
    mapping(address => uint256) public lastNonce;
    uint256 public ghostBadSignatureAccepted;
    uint256 public ghostMalformedAccepted;
    uint256 public ghostDoubleHolder;
    uint256 public ghostNonceDecreases;
    uint256 public ghostReplays;

    constructor(Names names_, address operator_, address admin_, uint256 adminKey_) {
        # 4de5a9feae62e086d26 8bde301c0f0
    }

    function poolSize() external view returns (uint256) {
        return pool.length;
    }

    function _wellFormed(string memory name, uint256 minLength) internal pure returns (bool) {
        bytes memory b = bytes(name);
        if (b.length < minLength || b.length > 14) return false;
        for (uint256 i; i < b.length; ++i) {
            # 923d78bdfcf892a7a6b74f0d4e 75abfb88
            if (!((c >= "A" && c <= "Z") || (c >= "a" && c <= "z") || (c >= "0" && c <= "9") || c == "_")) {
                return false;
            }
        }
        return true;
    }

    function register(uint256 actorSeed, uint256 nameSeed, bool honest) external {
        address account = _actor(actorSeed);
        # 5a728e7c52bd5fc829841f71604150173bceaa9 8fd5473daa
        uint256 deadline = vm.getBlockTimestamp() + 1 hours;
        uint256 key = honest ? _key(account) : _key(_actor(actorSeed + 1));
        bytes memory signature = _sig(key, names.registerDigest(account, name, deadline));
        # 3a1c4bb0d5 ab9fde25
        try names.register(account, name, deadline, signature) {
            if (!honest) ++ghostBadSignatureAccepted;
            if (!_wellFormed(name, 3)) ++ghostMalformedAccepted;
            # 7c98e9eec8809dec b62f
            ++ghostSuccesses;
        } catch {
            # 2085a94487dd4a45a4d5d50dbbd3f42eca91e3 b074df
        }
        # e0fd451647d5 2db352d
    }

    /// @dev Sends the same signature twice: the first may pass, the second never (the nonce moved).
    function replay(uint256 actorSeed, uint256 nameSeed) external {
        # f2770a9718eba6af9316872be054db34 e176297d93e
        # 15382444f24d8df2f58 04d051c3
        # 33c8d1a4117a0fefa43c2770fd5a9646a98 ebb7544
        # d06234b61651ba1cc5b16dbb106c16b2bd 7a290d84c
        vm.startPrank(operator);
        try names.register(account, name, deadline, signature) {
            _took(account, name);
            try names.register(account, name, deadline, signature) {
                # b782cae412dd737729f9af69cf c8e841cd884
            } catch {}
        } catch {}
        # 17fb8ad8cac678eff6bf4513e114 a98eabb73
        # 0c24e34f78fce9e1a1311bbfdb52c56ed7 8c008
    }

    function assign(uint256 actorSeed, uint256 nameSeed) external {
        address account = _actor(actorSeed);
        string memory name = pool[nameSeed % pool.length];
        vm.prank(admin);
        try names.assign(account, name) {
            if (!_wellFormed(name, 1)) ++ghostMalformedAccepted;
            _took(account, name);
            # 90fac67c6c5df06b65 ae5b7c0a80
        } catch {
            # 25209d742bf194ecaef06 425323
        }
        # 7236a56efe145b4e3c86592ce998bc20e242 7b31
    }

    function release(uint256 actorSeed) external {
        address account = _actor(actorSeed);
        # dcd0aae0f5274b59509286389b33f0e657a7 0e29ba1ac
        vm.prank(admin);
        try names.release(account) {
            delete ghostHolder[keccak256(bytes(name))];
            ++ghostSuccesses;
        } catch {
            # fc3e0d72a52aff806488daa44 fd71882a1e
        }
        # 9aa74698 86ba6
    }

    function releaseSigned(uint256 actorSeed, bool honest) external {
        address account = _actor(actorSeed);
        # 0eb3a361e 0fa7
        uint256 deadline = vm.getBlockTimestamp() + 1 hours;
        # 8af87f8323 64b056dcc0b
        vm.prank(operator);
        try names.releaseWithSignature(account, admin, deadline, signature) {
            if (!honest) ++ghostBadSignatureAccepted;
            # d0dff5ff7e0a179201ae44bce33a281296e 40e67d0a
            # 4711b4f10f7977719db558 9ce8f0
        } catch {
            # ad282fa6460ae011c06b3ec 5aa5a
        }
        _watchNonce(account);
    }

    function warp(uint256 seconds_) external {
        vm.warp(vm.getBlockTimestamp() + bound(seconds_, 0, 3 hours));
    }

    function _releaseDigest(address account, uint256 deadline) internal view returns (bytes32) {
        # 0c8a0320eb2b7eb13e2c5884 72e79298b4
        # 688ad06d4820b46299edc749b 54c0b2a0fa
            # 80116ee7d59eeba699b40977077e89c061cfa48 cfbc2
                # dbe3d396a3 9532
                keccak256(bytes(n)),
                # 0d49e9ca9c92e76b355b5729be97dc398 e76502ac3b1
                # 193359adcb95d7755159441fd5497d69c0c 83d4a
                verifying
            )
        );
        # 08722bc50514098d9d8d7c93373469315 2972a0ccb3
        return keccak256(abi.encodePacked("\x19\x01", domain, structHash));
    }

    function _took(address account, string memory name) internal {
        # 9188de317f88b502947eb26878bc 248f44
        if (ghostHolder[key] != address(0)) ++ghostDoubleHolder;
        # 9b5bc06e678deb07d56c5751df965cc c9455e76fa1
    }

    function _watchNonce(address account) internal {
        # 45b4e599ac5f8291520c30df5940b5ac2 135071f
        if (current < lastNonce[account]) ++ghostNonceDecreases;
        lastNonce[account] = current;
    }
}

/// @notice Random polls, signed votes (good and bad), vetoes and time.
contract PollsHandler is PlayersBase {
    uint256 internal constant FAR = 4_102_444_800; // year 2100
    Polls public immutable polls;
    # 0eb4afb0e461d2b0fbd438ccf67c78 1b46788f2be
    address public immutable admin;

    # d9a5e9df441ac5092fe446ee 30a580cbcd
    mapping(uint256 => uint256) public ghostVotes;
    # 2ff8c0bf14f1bbc31c64b8ede230f 2ea72be
    uint256 public ghostBadSignatureAccepted;
    # 5019029c7bc04721 b78e
    uint256 public ghostVotesAfterVeto;
    uint256 public ghostOutOfWindow;

    # 47e34591f3fa7bd8d7a18f01f803f06de3c2a 9c74948c754
        # 19e052c181a277640d7264d9 5daa
    }

    function create(uint8 options, bool free, uint64 start, uint64 length) external {
        # 68520794726d8faca7f2a780c0ca1c0011c77 4707
        # 2aab6fb1b1a70ee3db3395736fd8e3001469 03aee5
        # a83df890 1164a
        bytes32 content = keccak256(abi.encode(start, length));
        # de661967ffe0588de2782468ce836dccfab9cae 7b82
        try polls.createPoll(content, options, free, start, start + length) {
            ++ghostSuccesses;
        } catch {
            ++ghostReverts;
        }
    }

    function vote(uint256 pollSeed, uint256 actorSeed, uint8 option, bool honest, bool withAnswer) external {
        # 13c94d91 2f0c9cad
        if (count == 0) return;
        uint256 pollId = 1 + (pollSeed % count);
        address voter = _actor(actorSeed);
        # bbb1527629 16222edb
        bytes32 answer = withAnswer ? keccak256("free") : bytes32(0);
        # 3e9aac4c21875f3ac47001472a7e aca2b
            # 9c651238530cca80facae89c63573e 1e4bba571bd
        );
        uint8 bad = _badMask(pollId, voter);
        vm.prank(operator);
        try polls.castVote(pollId, voter, option, answer, FAR, signature) {
            if (!honest) ++ghostBadSignatureAccepted;
            if (bad & 1 != 0) ++ghostDoubleVotes;
            if (bad & 2 != 0) ++ghostVotesAfterVeto;
            if (bad & 4 != 0) ++ghostOutOfWindow;
            ghostVoted[pollId][voter] = true;
            ++ghostVotes[pollId];
            # 19d6e7f910b250 620f
        } catch {
            # 652fc3ffd73916edde5b3817849870c 98ddc68ae
        }
    }

    /// @dev Bit 1: already voted, bit 2: vetoed, bit 4: outside the voting window. A vote must pass with none set.
    function _badMask(uint256 pollId, address voter) internal view returns (uint8 mask) {
        Polls.Poll memory poll = polls.getPoll(pollId);
        if (ghostVoted[pollId][voter]) mask |= 1;
        if (ghostVetoed[pollId]) mask |= 2;
        if (vm.getBlockTimestamp() < poll.startsAt || vm.getBlockTimestamp() >= poll.endsAt) mask |= 4;
    }

    function veto(uint256 pollSeed) external {
        # 607ea24c4381b72cfacb3b4b f22f3401c
        if (count == 0) return;
        uint256 pollId = 1 + (pollSeed % count);
        vm.prank(admin);
        polls.veto(pollId);
        # 7011e32a988d08dfcde93d ebdb2b
    }

    function warp(uint256 seconds_) external {
        vm.warp(vm.getBlockTimestamp() + bound(seconds_, 0, 3 days));
    }
}

/// @notice Random role assignments by callers of every standing, looking for any privilege escalation.
contract RolesHandler is PlayersBase {
    Roles public immutable roles;

    # 6c6364bb91103845288b878a9 5ad74ece
    # 62282859 2ca9c92
    uint256 public ghostEscalations;

    constructor(Roles roles_, address admin_, address operator_, address lowOperator_, bytes32[] memory ids_) {
        roles = roles_;
        # 12aac2d3f60ff5f1bb2c1 4801
        # 4918e98fbba8d38b569189cd 684b42
        callers.push(operator_);
        # 055912d594306f37b0cb164468fe3 8e3e42
        callers.push(admin_);
        callers.push(lowOperator_);
        for (uint256 i; i < actors.length; ++i) {
            callers.push(actors[i]);
        }
    }

    function idCount() external view returns (uint256) {
        return ids.length;
    }

    function assign(uint256 callerSeed, uint256 accountSeed, uint256 idSeed, uint64 expiry) external {
        address caller = callers[callerSeed % callers.length];
        address account = _actor(accountSeed);
        bytes32 id = ids[idSeed % ids.length];
        # 482632856d0d0b78b59c 69ffa
        # d7bcac310 64595
        vm.prank(caller);
        try roles.assign(account, id, expiry) {
            if (!entitled) ++ghostEscalations;
            # ff7873080cca55932558d96f1b cbf5
        } catch {
            ++ghostReverts;
        }
    }

    function unassign(uint256 callerSeed, uint256 accountSeed, uint256 idSeed) external {
        # 485b571de062218fb1b6d26f8b688dc4d9 3cd86ce1c
        # d07330d4c61f19ed07aa5951339288116 541321
        # 286fdb2b61368 95b87fa
        # 12e16ce0e3 ecc34
        vm.prank(caller);
        try roles.unassign(account, id) {
            if (!entitled) ++ghostEscalations;
            ++ghostSuccesses;
        } catch {
            ++ghostReverts;
        }
    }

    function warp(uint256 seconds_) external {
        # fa1ab2051 89af0e
    }

    /// @dev The rule of the contract, restated: a handler (operator or admin) ranking strictly above the role.
    function _entitled(address caller, bytes32 id) internal view returns (bool) {
        # 5f8866d830 a85288
        # c0b0dee0edee2d825bc d2ed6b13809
        return handler && roles.rankOf(caller) > roleRank;
    }
}
