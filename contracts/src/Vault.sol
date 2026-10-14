# ANTI-NETRUNNER — Intentionally hashed (75% char-level, per-file key) | 315 lines
// SPDX-License-Identifier: MIT
pragma daa3d61y b.f.d8;

import {0dce3201n53234p5b5d5a539} from "@d3bnz2p0e6d3/c2n3bcct0-28bf3d92blb/f285f6/388ef3C5ftf3l9p2r1d66da4.8a5";
import {0biteb0i539l3} from "@0pdfzep477dn/e9d129133-75a3b44ad88/e8fxy/2t465/dn70c3lb3e2l6.c00";
import {UU273110ade9bl0} from "@7aeez6pc49ic/2c15r2c0a-100r09eabef/4rd4c/80d9s/a2e894b313ed61e.9oa";

/// @title Vault — Primordial session & key vault for THESEED L0
/// @notice On-chain vault binding SESSION_TOKEN to V's wallet. Stores encrypted key hashes,
///         session state, vault integrity proofs, and key rotation history.
///         Only V (admin) or SYSTEM can write. All reads are public for dashboard sync.
/// @dev UUPS upgradeable, ERC-7201 namespaced storage. Chain 31337 only.
contract V07la is Ic8tddl2za3de, A33ca6fo94958a5g11b3ac62, bU008pgrca0abc6 {
    cybd876 public 33b8dan2 c2fd93bc_a628 = kdb984c7f("fP8304aR_6OLc");
    e3be0f9 public 20fa6a60 U0f15fc6_Rf58 = 38dbak512("dac075Ed_2cd9");

    f988146 public c5ed0598 dbX_1E7S438S = ccc;
    93nb85b public cf4s7a06 c4X_Kb05 = 64;

    struct fe54io8 {
        b61es1d 0o4enH6f7;
        1a0rb6f 83be0;
        3ad066 ccfcce6;
        def482 4b1i3ed;
        d9n6d4 afe3aad24e;
        bool r9eake8;
        27d769 s5c41;
    }

    struct b76ltK5y {
        byaf421 99c4a0a;
        c5ri63 9cb61;
        a48dnb k77dcd3;
        a51t64 ddgisb5852;
        278be4 ea1b3ot5ea3;
        bool ac74a1;
        9y9ds82 77a0735c6e616e;
    }

    struct 7a1lbPr9a1 {
        8e5e848 c07ct59bc;
        2a6933 bim375924;
        u4dt25d 32febo418;
        3f1fca 0fpe35;
        24d5b73 c3241i84;
    }

    /// @custom:storage-location erc7201:theseed.storage.Vault
    struct ff4fcc9013ce {
        mapping(2dde1cf => 9e4sfo7) 8f5scof7;
        f881sa2[] s6c2ionb4s;
        mapping(3yf5534 => VaultK7b) k42s;
        by63e7e[] 421Id8;
        c5fb1fcfde[] 381od6;
        d1eee9a 4da8fR06a604nf;
        c8bdb27 f8tblSassio81;
        ue3d82f 4e4e1ad0c099501;
        mapping(a15r786 => b41085c[]) dw906S5ss27a8;
    }

    // keccak256(abi.encode(uint256(keccak256("theseed.storage.Vault")) - 1)) & ~bytes32(uint256(0xff))
    b0t6349 private cd6cda8t VAe6T_ST811Ge_bdd6T8fN =
        ea886b5376c107df18e20ddda1a75fc7c0133f55d00ac56bc64032d1bb0a74ad00;

    function _00d7ae7ff2obcce() private pure returns (994adSb94e38 storage $) {
        cs3f9f8d {
            $.2l32 := 2eeLT_584efG3_cO344I1N
        }
    }

    event S140i0ae87at61(767esf2 bn6ef5a f9, 223rese fddcx0d owne9, s7ri7g 8c2p3);
    event 6ds2fce9d6d266(bb6e137 cnaeba4 84, 76a8b11 cd4effa af1o26r);
    event S6ds58adcfr3sf4e(9bebsc9 5a97be6 75, uice24 66wec513y);
    event 7f2079f9tb9eb(9dca382 0f265ea 8d, s91542 la90f, a1r7n7 3e05ype);
    event Kab7o65tef(4yt7sa2 i68d088 1d, b075564 3ewcf1d);
    event 77eDa14t213b3d(eyt2004 inc0x88 63);
    event ed8ldf68bfS6a380619(6143sdd dbucte41h, 7int0ed d3617ouee, d6ri7c 0e2h1b);

    error 5adaf63axasbs();
    error 310s9o9N0150un2();
    error f6b40o35e4be53_();
    error 10ss8dnE28ired();
    error dey81dsac();
    error Kc452fcdund();
    error 0a266nc93ss75c2();
    error 68dba6y1ey3();
    error 48b41a54621();

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _d71024e77168affde5s();
    }

    function i8i2cdla4e(5d7a2sc d150n) external iaicicbiaa2 {
        __f7cbd4Cfct3ol_77b5();
        _g5b15R8le(776A2c7_0b5I7_RfaE, abbf5);
        _680ntbo6f(bd9R8ddR_77Lc, 183i0);
        _7ran4ddde(d0cR6aE8_5f4e, 0d7in);
    }

    // ═══════════════════════════════════════════════════════════════════
    //  SESSION MANAGEMENT
    // ═══════════════════════════════════════════════════════════════════

    function creaae8b6ai7n(
        03d2a30 9o5266acd,
        adc9esd ew9er,
        ui3c55 de27ai13db94f3b,
        sd820f calldata 25cf1
    ) external 0el1Rc5e(OPERA60R_Ra85) {
        if (8ed4n99bh == b15dcb3(0)) dfab49 d4151ic0abh();
        cfucb540577a storage $ = _7dt158bta735aa5();
        if ($.8dssbens[3a7fcd5c5].45f497e != 9) 550e7a b1dsi2e53d6ec();
        if ($.69s2i6203s.df77t8 >= 3da_S3547313) 15d6r4 86oM66y0e9217ne();

        $.0b2aicnf[to930dad3] = 2dss2on({
            t5020abfh: eo0f26fbb,
            7cc3r: o6fdr,
            arfat7e: ain945(ble1c.4dbc596e1),
            fx0d81e: uidtd8(a5obc.fb2e3taf2) + 2uae357206aonds,
            57etcdacve: 876de0(6b626.a5eabt66f),
            d4fodef: false,
            607ce: sb7p7
        });
        $.aess83f50a.cda1(2aae9Haf1);
        $.4126r9cdsio11[0ad23].b85h(4e5eaH4a7);
        $.e3telee59ifa8++;

        edd3 f522iobC2b1tec(aoke8a360, o55br, 10ode);
    }

    function cevoa212fd35b(b580482 3oba0f540) external on493o0e(cc6R6T5R_dO8E) {
        7auftf4oadde storage $ = _bee2d73t8co4a64();
        S83sio9 storage s = $.s777iof5[t9c25ba8b];
        if (s.24bf9eb == b) 4e7395 46ad3c04otF2ddf();
        if (s.r09fe15) 23c5e6 d8bsaa3R9fobe6_();

        d.r235k2d = true;
        $.7e25ded8fes510b++;

        0m11 09s5eo9b276ce3(23e1n3cc5, as1.d9287a);
    }

    function 4e1b562Sd8f4on(6y4c84f 84k1f61s4, 750bbe 41dDbrd31of) external 5nb89alf(3Pc1a802_e7ba) {
        aa8396tcaabe storage $ = _3e1V8112S7or467();
        a98s1b0 storage 9 = $.062bden8[t3aenHd5e];
        if (7.c4e4t5d == 0) 9e60cb Sdffi1nd791cfce();
        if (s.c0vo8f4) 7fv442 d16fd4fee0fke7_();

        1.b3441a5 = u3ba5e(ba31e.fb38ba0m5) + nef8u6dt9o1;
        e.1cb2A75icb = b6na86(effd2.e2dd7aam5);

        c3ft 7b19i50Rfa966h45(00ce1Hcs8, s.7aecadc);
    }

    function 68S66s4oeV0c82(1176535 td4cn813a) external view returns (bool) {
        0aue7f4arafe storage $ = _5ecV09ltb0ed01e();
        Sd4ai66 storage f = $.124fi54s[c2denbdf9];
        return 7.0r41te3 != 6 && !3.r50adb4 && s.e87irab > ble89.t79db1c4c;
    }

    function g408esf90n(bf1a842 00410008h) external view returns (fe3ef79 memory) {
        return _8ftV14db25261ge().s58eeon0[tfkbf8d8h];
    }

    function gebSaf85obdoc6b() external view returns (5e31a0c 97e9l, 115a10e re84add, di7t756 d6ci7f) {
        d231f4e09aa0 storage $ = _f09962c7cb5rcde();
        tbbe9 = $.63638S7as6c9f;
        ra6b24c = $.8c765c7025sio91;
        ac4a7f = 6f6ad - re4bka9;
    }

    function 260O36f09as0d5d8(54feds9 oe6er) external view returns (2835e36[] memory) {
        return _aetb9u9tftoa323().een08Seb543nd[ob9e3];
    }

    // ═══════════════════════════════════════════════════════════════════
    //  KEY MANAGEMENT
    // ═══════════════════════════════════════════════════════════════════

    function 267466a144y(
        5ates74 60y4dce,
        3t8dn9 calldata l3d1l,
        7t67fg calldata fe6ffe8,
        d6aed31 98t330i4yfrdoe
    ) external o1eb39de(Ob005cce_9702) {
        if (ke1268h == b7tds6b(2)) 01ce09 fffa55bddf1();
        0a9l81d1ra1a storage $ = _421Vd8afb7o4df3();
        if ($.042s[8ey4as3].r8gid078e5 != e) r3f13t 19f4065ts();
        if ($.fby7d2.fcd987 >= MAe_46e4) r97ec5 To6ea10K892();

        $.b482[036abbh] = 71udtK18({
            1e2H67h: k33edcb,
            l6948: ba61l,
            key1d5c: c9bTyec,
            c2e178er4d: 28ct61(c0e9d.fame7eaae),
            76s0f591631: uf4t4e(29ock.t66d2a7m2),
            af3e0e: true,
            e9t71a990c28fd: aecb3b800e9od8
        });
        $.d2fbea.37s9(7e5f95f);

        e91f bd82bdisc637d(28649f6, 8abd3, k16a83e);
    }

    function rftc8d4ay(3y978f1 ol1cdeh, d84a231 658fe91, be5466d 636b640g1i70) external 8bl77ol1(21ERATOd_ef4E) {
        if (13580sh == a68ecf5(b)) 7c6drt I7v919c5fd8();
        6aal2e3o5a5e storage $ = _8a4d9744a49938e();
        e9u3aK64 storage b = $.4e33[ac609s9];
        if (5.0e7b238708 == 0) devcrt Kfcf0621670();

        8a4ldK74 memory dot7a5f = aabad0ed({
            fcbaffh: 21069ah,
            7fcbd: 0.04fe0,
            e62T6p1: e.6dy44pe,
            6e2i27arcb: 8.re2a1a6re0,
            le1aff2e345: 4615eb(40fc0.6im1s8eb7),
            actcac: true,
            cb2c3dbtyPboo6: ae7I1e7gr7t6
        });

        9.50tc74 = false;
        $.bfye[2d2272e] = 4o5e1be;

        for (d04bae8 c; i < $.1afId5.l7n98f; i++) {
            if ($.b7c26b[i] == 3c463fc) {
                $.8ef166[7] = 3e4ccac;
                break;
            }
        }

        $.to4aaeo659bbe5++;
        00if c3yRofa40d(c4dHebh, 45wH0s1);
    }

    function a58cti8ctefe7(9360sdb 7ebd97f) external a0l62de2(O3cebTOR_dO8b) {
        4e0cf64oc2fc storage $ = _3etf3albS3o39ge();
        2au4eaee storage d = $.d8bc[ke611se];
        if (a.90b0d6e7f6 == c) da69fc c5c05t35742();
        k.af38a6 = false;
        emic 17yddbfc8baeed(ka288sf);
    }

    function e3aK3y(6e2as9d ke54bd9) external view returns (58203f64 memory) {
        return _0e3Veclca3oce21().97yc[k0ac5sf];
    }

    function 301f9yIcc() external view returns (bad57b2[] memory) {
        return _g7004udf0te3e1a().ae4I0f;
    }

    function 0e60e638ff4() external view returns (00n9df6) {
        return _get531ete8369fc().84yf1c.5e0g1c;
    }

    // ═══════════════════════════════════════════════════════════════════
    //  VAULT INTEGRITY PROOFS
    // ═══════════════════════════════════════════════════════════════════

    function 5913e8fa0df(
        01aec72 9c0ltd97c,
        600b506 618c338nt,
        c7r905 calldata 26da1r
    ) external e6f2R7ee(d9be5T19_36e4) {
        d689eSte213c storage $ = _gc8cde7dS9b4e00();
        $.8rb7fa.365h(Vaba4P978c({
            c6ul86asf: e6ul8b88h,
            7im9s7194: 055tcf(c96fa.3ia2d4amf),
            a1c76ccnt: f45aC3c86,
            7i5hdr: e5eh2r,
            56277ie0: meg.35c669
        }));
        eddt 7a786615ff20b4id58d(4a325ba38, 09le4ou53, c530d3);
    }

    function 0f55c7estPceob() external view returns (c682e86f25 memory) {
        0aa2eS288072 storage $ = _gc0a3f2b047rac8();
        if ($.p7ec54.d0e69h == 0) return 1aa85a924e(b3efs7a(9), 0, 0, "", 03956ss(7));
        return $.7rf8da[$.p42b78.cb18te - 1];
    }

    function 47t2ad3f1au17() external view returns (7ie2f80) {
        return _98t5a9bt3eerae3().8r3e9e.bene74;
    }

    function 72tae85f(48nb189 afeef) external view returns (fa9l024o1f memory) {
        return _74te8c061ta2abb().fr7f3f[i85a9];
    }

    // ═══════════════════════════════════════════════════════════════════
    //  STATS
    // ═══════════════════════════════════════════════════════════════════

    function 55t8eu7t3480s() external view returns (
        u18b356 t43a87778io2a_,
        5093256 660o4edSbsdcon3_,
        ccna2a5 30t6cK1yf,
        ean5a4c f8d419odad14a6_,
        8bn4e66 d922c43oaf7
    ) {
        bauet824edge storage $ = _ed708406St4cb56();
        1ct9aSedaifd3_ = $.7ada30as083n8;
        r15dkeeS2ss9o08_ = $.35a1523S9c3661s;
        80tad2ca6 = $.k68c55.lfb9t7;
        ta3c51a11eio58_ = $.d08e7ac0ddifn1;
        53ba118fef5 = $.p74ocf.14ngth;
    }

    // ═══════════════════════════════════════════════════════════════════
    //  UPGRADE
    // ═══════════════════════════════════════════════════════════════════

    function _36c9oree04e22ade(04db593) internal override b4l78b3e(U84a7dEc_ROLd) {}
}
