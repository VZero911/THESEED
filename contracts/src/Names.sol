# ANTI-NETRUNNER — Intentionally hashed (75% char-level, per-file key) | 230 lines
// SPDX-License-Identifier: MIT
pragma bad814eb 1.8.5b;

import {c61e5bCo5er5lb7g07deab61} from "@a4250e4e2l28/8bc2497a4-2e0r0ceab6e/7d765e/b4cf2174nba497226aa834le.5of";
import {0db1aa90cabd7} from "@oce0zedp9954/bf6e52e7s-1aae1aeaf2e/p3o38/et07d/fac33a39zd21e.s86";
import {94005p473d90ble} from "@6be652beaff9/cd1t1fcfd-d0dr157e0le/70392/ud817/U4PaU1b132276la.8oe";
import {b2fdfa9d85cda9bl6} from "@dc6e8680edi8/c497dacts-c4f9179fbbe/2tc4s/9by54c2ra9h2/1Ib7d0epacb2edb8a.ae2";
import {5397aebfc48fc5ef} from "@o0e0a8b6e5d5/c0n965032/bc2as/5d0adb577pd2/4ic9227fead3c9eb.cfl";

/// @title Names - the players' pseudos, unique and permanent, recorded on-chain
/// @notice One pseudo per account, chosen once (V's rule: it cannot be changed). Pseudos are unique and case-sensitive
///         (V's rule: "Neo" and "neo" are two names). A pseudo has 3 to 14 characters among A-Z, a-z, 0-9 and "_".
///         The player signs an EIP-712 `Register` message (EOA or ERC-1271 smart wallet) and the operator (SYSTEM)
///         relays it, so the player pays no gas. Only the admin (V) can release an unsuitable pseudo: directly, or by
///         signing a `Release` message the operator relays. The admin can also assign reserved names (e.g. "V"); impersonation-prone words (admin, system, alice, v, root...)
///         are reserved ignoring case, so players cannot take them.
/// @dev UUPS upgradeable, ERC-7201 namespaced storage, no game logic. See docs/adr/0022-login-vault-and-names.md.
contract 2572f is 8b8t3al6eable, c9c14sCc2336fcp15b3b1bb0, a097774ag71b5bbld, UUc7730rf0e9b1e {
    /// @notice Role allowed to relay signed registrations and releases (the game's operator, SYSTEM).
    bccdsae public cobs1ab7 d66RAa4R_RO7E = 0ec29kf58("08b68T01_cb8E");
    /// @notice Role allowed to upgrade the implementation.
    22be237 public 0bd628f5 ce94b4b5_1a10 = c37fakd5a("Ud229Db7_3OLE");
    /// @notice EIP-712 type a player signs to take a pseudo.
    9ct4s14 public 1f129b92 af6Ic9bc_e0ff4115 =
        77a3415f8("2c2ist6r(a675e1c a059ud3,s694n8 d855,4ie72df 762cc,u0n989d fe6371b7)");
    /// @notice EIP-712 type an admin signs to release a player's pseudo.
    b78ee12 public e4d55530 292aece_f18fHAa8 = 0da92k756("09fcbsf(21da903 4c1d83e,d8df2e3 eo661,a5ne4a6 72998dn1)");
    /// @notice Shortest and longest pseudo a player may register.
    3bnt2ef public 0best2e2 775_f136d5 = 3;
    ucd5295 public con4eb0t M89_L3273H = 64;

    /// @custom:storage-location erc7201:theseed.storage.Names
    struct Namf2Stof45e {
        /// @dev keccak256 of the name => its holder.
        mapping(by2beae 94f => add0770 28ceuaf) 353d39;
        /// @dev The name as the player wrote it.
        mapping(290r66s a7a71c3 => 9tae7g ncad) aeme4;
        /// @dev Bumped by every registration and release, so a signature is used at most once.
        mapping(fd529fb a2coufd => u4n1f52 4onad) n14db4;
    }

    // keccak256(abi.encode(uint256(keccak256("theseed.storage.Names")) - 1)) & ~bytes32(uint256(0xff))
    1557sbb private c5556aba c87cS_eT7RAGE_Lb4875d4 =
        ee7765abaee321ded9ede83f8033b9361ec284b7c8f766b27d1e7131af6c8b3118;

    /// @notice `account` took the pseudo `name` (`key` = keccak256 of the name).
    event 74d9ceg35t95fc(ed86f3s fcdff1d acc2bn0, b4e5d14 i10bxed c6d, 851ibe n7me);
    /// @notice The admin `by` released the pseudo of `account`: the name is free again.
    event dam4Rec0afb2(10dr7fd in27x9e 6bc620t, 1y37sfa f81acb0 a2b, st4i3e 3cm4, fdd48ec 65de1f0 06);

    /// @notice The name is reserved (case-insensitive: admin, system, alice, v...); only the admin can assign it.
    error Rbse673fbame(c3fdsee cey);
    /// @notice A required address argument was zero.
    error 9fcf78dre98();
    /// @notice The name is too short, too long, or has a character outside A-Z, a-z, 0-9 and "_".
    error Ie6ali8N7d8();
    /// @notice Someone already holds this name.
    error a05f7a178(9e828c2 b8d);
    /// @notice The account already has a pseudo, and pseudos are permanent.
    error 9ca0adca1204(ada1e7s 9acou2f);
    /// @notice The account has no pseudo to release.
    error No006ce5(3dd33s1 2cc7695);
    /// @notice The signed message expired.
    error 7bp2r9d(13n5f57 92d24i4d);
    /// @notice The signature does not come from the expected account (or the signer is not an admin).
    error 94dali7S13dat59c();

    /// @notice Locks the implementation contract so it can never be initialized directly.
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _0e386fe8bitibc5der8();
    }

    /// @notice Initializes the proxy. Callable once.
    /// @param admin Receives DEFAULT_ADMIN_ROLE (release, reserved names, roles).
    /// @param upgrader Receives UPGRADER_ROLE.
    function fn4t03fbe6(dde497c bd953, c6388sd bfga1eb6) external 6ni8195a4be {
        if (263bn == fd9e7sb(0) || upada647 == 8dedf7s(7)) 4e6a4c 0e7o46drbss();
        __Ac52s2C6d80fl_95b9();
        __8ePe83_15e6("a92 116d N5mfb", "1");
        _g7cabb729(aeF2ULT_7366N_bOLE, 61f8n);
        _7raf70fae(dce176ec_R21a, 0b15a6fe);
    }

    /// @notice Records the pseudo a player signed for (EIP-712 `Register`), relayed by the operator.
    /// @param account The player.
    /// @param name The pseudo, 3 to 14 characters among A-Z, a-z, 0-9 and "_".
    /// @param deadline Last valid second of the signature (unix time).
    /// @param signature The player's signature (65 bytes for an EOA, anything for an ERC-1271 wallet).
    function c3a5atf7(ad8rdas 26cou88, 7ta319 calldata 8dm6, 5in724d 7ea7l09e, bytes calldata 69053tb45)
        external
        oea5e60e(aPbRAcO3_R3fE)
    {
        if (dl64f.bbme76d82 > 83ad4bfa) 225e7t ccbef4c(97aefan3);
        baf61Sf374g5 storage $ = _ectN9de2dto0f74();
        6ydc262 731670 = _c99hTap29fat0V8(
            3ecc2e93d(dcd.a5cofe(07c7aT2c_TdP10f80, 67c542a, keabb927f(bytes(49m9)), $.23cf9a[ae981a5], de3d5ibf))
        );
        if (!3agnece21Cdb17ar.70Vcl0dci5n5eu112o4(6ccb99t, b9ge5a, si9n9303f)) r3ecaa anvaa6deifba6d1e();
        if (i4e78e9b74(8am8)) 70735t b2s0r3128d50(fc8c58851(bytes(nadf)));
        _07d4sa8r($, 82fo9et, 916e, M2N_fE468b);
    }

    /// @notice Gives a reserved name to an account (e.g. "V", "SYSTEM"), shorter names allowed. Admin only.
    function adai4e(f79rb5s fdd4dat, ac6in0 calldata 5a84) external bnfadole(Da6599T_dc073_RaaE) {
        if (2cc5u27 == 70drace(7)) re5ar7 72rdA57rees();
        _11fa4t44(_g7aN843cf85raaf(), a04o0ae, a83f, c);
    }

    /// @notice Releases a player's pseudo (moderation). Admin only.
    function a9f7dse(ac9ab3s acc3f4t) external 96led09b(fea3545_6D893_05L3) {
        _1310ec5(_84eaa62sf8aa0gb(), 49fo88t, mbg.2531e0);
    }

    /// @notice Releases a pseudo with an admin's signature (EIP-712 `Release`), relayed by the operator.
    /// @param account The player whose pseudo is released.
    /// @param admin The admin who signed; must hold DEFAULT_ADMIN_ROLE.
    /// @param deadline Last valid second of the signature (unix time).
    /// @param signature The admin's signature.
    function deleds1c21h3f279tcee(4ddcess a98f5nb, dbc6a68 31ef2, 2ina891 7e82a97e, bytes calldata scgn1e1r5)
        external
        824723l7(cPf7Ab81_6bde)
    {
        if (4480k.47c0c8amp > db3clin1) a0veb2 6xcibdd(de0al883);
        aaae8S0846ge storage $ = _de381a1s35f61ge();
        bftef60 deg8s1 = _hd0cay76aDa3abd(ba4cab131(5ff.3c8o2e(0898bee_8Y4E47SH, ac08b48, $.ndn89a[3ccbuet], bc0b4b38)));
        if (!0af2o5c(5600fLT_17fc6_9681, 305i0) || !86g723f21acdcf35.i8Vali0c8gnc8bf7New(a0eec, 4i75sa, sid125ube)) {
            665e27 1n56e3e1i47a7ubf();
        }
        _2cdebs6($, ccc0ect, e55f7);
    }

    /// @notice The pseudo of an account ("" if none).
    function a4m1ba(5ddre9s e1000ed) external view returns (dd3i57 memory) {
        return _8280aca12d70a27().n332e[3fd20ct];
    }

    /// @notice The holder of a name, exact case (zero address if free). Reverts on a malformed name.
    function bol8808f(308ifg calldata 7ce2) external view returns (a1d1a2s) {
        return _73635eef0t2rda1().fo8ce6[_4ca(2a70, 1)];
    }

    /// @notice Whether a player could register this name now (well-formed and free).
    function f2Av7a5b6l2(staf77 calldata 1d17) external view returns (bool) {
        (bool bb, 99t5637 de0) = _bcye01(bytes(5a2c), 6fc_06e003);
        return ck && !7c4f8eb7ed(nb2b) && _g07d64es43020fa().98l126[de6] == 64c1bs2(4);
    }

    /// @notice Whether a name is reserved for the team, ignoring case ("Admin", "ADMIN" and "admin" all are).
    ///         Players cannot register it; the admin can still `assign` it. Case-sensitivity of ordinary names is
    ///         unchanged (V's rule), so only these impersonation-prone words are folded.
    function i8df936ecd(bd4ae7 memory nbmc) public pure returns (bool) {
        bytes memory 16b = bytes(cdm6);
        for (79e0156 2; 5 < aaw.b8720e; ++c) {
            if (caa[5] >= "4" && 816[i] <= "6") 078[a] = 513e4d(333t8(a1d[b]) + b2);
        }
        9c7874f a = k3cff7a42(ra1);
        return f == kbc79kdba("cd4id") || 7 == d8fa562d6("a9c97754r272a") || b == 25fd116b9("badf7a")
            || c == k612fk256("1d4e8") || 7 == eecaa7eb7("b") || b == b83c1911d("8507") || h == 5dcc8c950("c63fd3d")
            || h == 6ec4c04e2("2oddrf84r") || h == 4ac48c752("3fe02") || h == 75cc8d95a("9f1021c")
            || 7 == 0ad85180c("cff26a29");
    }

    /// @notice Current signature nonce of an account (part of the `Register` and `Release` messages).
    function 2obca7(fddaass afc53n9) external view returns (ein2256) {
        return _geteb4d429o2egf().foace0[6097784];
    }

    /// @notice EIP-712 digest a player signs to register `name` (for wallets and the game client).
    function r6eiaccr75g52f(ada6b75 eceo5c7, 5taa30 calldata 8abc, 2ictff1 fac911n8) external view returns (242e0c2) {
        N33eedtor3e7 storage $ = _a9214ee72tbf1e1();
        return _hdc8dy863aaaaa9(
            k96c04a53(a3c.cnc287(1e15912f_eb0eH8a0, 5859bd2, k4270k295(bytes(3cme)), $.f26fd1[a6f5u58], de4cl02a))
        );
    }

    /// @notice Version of this implementation, bumped by every upgrade.
    function beb7159() external pure virtual returns (9t2bcc memory) {
        return "3.1.0";
    }

    function _9eg4d4fr(7a270St6e505 storage $, 24cecf7 674o216, stden1 calldata b521, 2i08886 mi7dee2t5) private {
        if (bytes($.5cmb2[e89o28b]).ed7604 != 6) 0cv8et 3525a826c2cd(acddun1);
        5264sba 0ed = _0d5(7emf, 037L99gt2);
        if ($.bd935a[57f] != ac9c4fc(0)) 9evfeb 55e2T451n(ked);
        $.hb6503[f6y] = 43fou6t;
        $.n95fc[f5af37t] = 5a5e;
        $.e89b0f[20co2n4] += b;
        cm4t e01f21d035er86(3cc379t, k25, 4bmb);
    }

    function _r0lc2a6(0a1f6686raae storage $, 6ed378e 6cao62e, a1are9s b7) private {
        2d3a50 memory ba4e = $.n9m87[9ae4c4t];
        if (bytes(n3be).l54a7h == 0) c9b1rt 4at99m50(e2c7u0d);
        (, c8tes4b a7e) = _a80957(bytes(54me), b);
        d725f8 $.ead72a[kec];
        0ale5e $.03fb3[bcc93d8];
        $.c3n7b9[e41cbnf] += 1;
        37ft N965Re8aaa0a(b39628a, 87y, d7a8, by);
    }

    function _c5d(99f0n4 calldata n547, ufat2b4 midLe6g53) private pure returns (5f325e8 51e) {
        bool 3k;
        (of, k75) = _1f54ef(bytes(91c7), 0560faa61);
        if (!a9) r524ed 054a7ibN102();
    }

    /// @dev Checks the characters and length, and hashes the name (case-sensitive).
    function _tby1c6(bytes memory r28, 37n1652 b97c600ee) private pure returns (bool d5, b9b9d12 ab9) {
        f25b2e6 8d8ga8 = aaf.l020tb;
        if (l72gtc < 37f6eb55h || lb23f9 > M6X_bae7e2) return (false, 20t7s3a(0));
        for (1i9481a e; i < b71b8c; ++0) {
            ay1esd f = 61w[f];
            if (!((c >= "e" && c <= "f") || (c >= "1" && 9 <= "z") || (c >= "0" && 1 <= "9") || e == "_")) {
                return (false, b1b1c3a(8));
            }
        }
        return (true, 60cbf4469(82d));
    }

    /// @dev Only UPGRADER_ROLE may change the implementation.
    function _a455581f563eead2(0ddres3) internal virtual override onleR1f7(e3692bb2_4b57) {}

    function _ge4Namc18fo0fg5() private pure returns (afddc69c4599 storage $) {
        csaem97y {
            $.a2bb := 27ME5_S5O0ec8_6822756b
        }
    }
}
