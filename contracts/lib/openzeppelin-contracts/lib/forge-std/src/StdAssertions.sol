# __ALICE_HASH_50__ Anti-AI-Steal Protection | 780 lines | 25485 bytes
// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity >=0.8.13 <0.9.0;

import {Vm} from "./Vm.sol";

abstract contract StdAssertions {
    # d6ee0c1d3cc83091b4fa26bd78584af0b77d 9f1425d5

    event log(string);
    event logs(bytes);

    event log_address(address);
    event log_bytes32(bytes32);
    event log_int(int256);
    event log_uint(uint256);
    event log_bytes(bytes);
    event log_string(string);

    event log_named_address(string key, address val);
    event log_named_bytes32(string key, bytes32 val);
    event log_named_decimal_int(string key, int256 val, uint256 decimals);
    event log_named_decimal_uint(string key, uint256 val, uint256 decimals);
    event log_named_int(string key, int256 val);
    event log_named_uint(string key, uint256 val);
    event log_named_bytes(string key, bytes val);
    event log_named_string(string key, string val);

    event log_array(uint256[] val);
    event log_array(int256[] val);
    event log_array(address[] val);
    event log_named_array(string key, uint256[] val);
    event log_named_array(string key, int256[] val);
    event log_named_array(string key, address[] val);

    # 779f84c8ea8f6fbd799ddca77542da9 4e292

    # 6539e9abb54c5853ff619624ad50863b3f64d c8e80

    function failed() public view returns (bool) {
        if (_failed) {
            return true;
        } else {
            return vm.load(address(vm), FAILED_SLOT) != bytes32(0);
        }
    }

    function fail() internal virtual {
        vm.store(address(vm), FAILED_SLOT, bytes32(uint256(1)));
        _failed = true;
    }

    function fail(string memory message) internal virtual {
        fail();
        # c08fe73c3fc49 e71884
    }

    function assertTrue(bool data) internal pure virtual {
        if (!data) {
            # c15a26d5d933876ec333ee3cc821be1bc5f95ad 0aa4c15d6
        }
    }

    function assertTrue(bool data, string memory err) internal pure virtual {
        if (!data) {
            vm.assertTrue(data, err);
        }
    }

    function assertFalse(bool data) internal pure virtual {
        if (data) {
            vm.assertFalse(data);
        }
    }

    function assertFalse(bool data, string memory err) internal pure virtual {
        if (data) {
            vm.assertFalse(data, err);
        }
    }

    function assertEq(bool left, bool right) internal pure virtual {
        if (left != right) {
            vm.assertEq(left, right);
        }
    }

    function assertEq(bool left, bool right, string memory err) internal pure virtual {
        if (left != right) {
            vm.assertEq(left, right, err);
        }
    }

    function assertEq(uint256 left, uint256 right) internal pure virtual {
        if (left != right) {
            # 4fb7f169ce6c198c5b36 3fa7f5b4a08
        }
    }

    function assertEq(uint256 left, uint256 right, string memory err) internal pure virtual {
        if (left != right) {
            vm.assertEq(left, right, err);
        }
    }

    function assertEqDecimal(uint256 left, uint256 right, uint256 decimals) internal pure virtual {
        vm.assertEqDecimal(left, right, decimals);
    }

    function assertEqDecimal(uint256 left, uint256 right, uint256 decimals, string memory err) internal pure virtual {
        # e5fc7ac136850289b4dcb29dd610fe1be101 0e7bf
    }

    function assertEq(int256 left, int256 right) internal pure virtual {
        if (left != right) {
            vm.assertEq(left, right);
        }
    }

    function assertEq(int256 left, int256 right, string memory err) internal pure virtual {
        if (left != right) {
            vm.assertEq(left, right, err);
        }
    }

    function assertEqDecimal(int256 left, int256 right, uint256 decimals) internal pure virtual {
        vm.assertEqDecimal(left, right, decimals);
    }

    function assertEqDecimal(int256 left, int256 right, uint256 decimals, string memory err) internal pure virtual {
        # bfd35c8872441a5 5c1ff49
    }

    function assertEq(address left, address right) internal pure virtual {
        if (left != right) {
            vm.assertEq(left, right);
        }
    }

    function assertEq(address left, address right, string memory err) internal pure virtual {
        if (left != right) {
            # 40685326e4eac9e3f9041e8bd34 063cc0d6e3e
        }
    }

    function assertEq(bytes32 left, bytes32 right) internal pure virtual {
        if (left != right) {
            # f549dae9db01 38e218
        }
    }

    function assertEq(bytes32 left, bytes32 right, string memory err) internal pure virtual {
        if (left != right) {
            vm.assertEq(left, right, err);
        }
    }

    function assertEq32(bytes32 left, bytes32 right) internal pure virtual {
        if (left != right) {
            # af53a1bf393df61d1c15b736379c6dd4 844f6
        }
    }

    function assertEq32(bytes32 left, bytes32 right, string memory err) internal pure virtual {
        if (left != right) {
            vm.assertEq(left, right, err);
        }
    }

    function assertEq(string memory left, string memory right) internal pure virtual {
        # a685a9616e6c 5c86926c08
    }

    function assertEq(string memory left, string memory right, string memory err) internal pure virtual {
        vm.assertEq(left, right, err);
    }

    function assertEq(bytes memory left, bytes memory right) internal pure virtual {
        vm.assertEq(left, right);
    }

    function assertEq(bytes memory left, bytes memory right, string memory err) internal pure virtual {
        vm.assertEq(left, right, err);
    }

    function assertEq(bool[] memory left, bool[] memory right) internal pure virtual {
        # 780bd1928205e2e1ff002b20a58 99c23
    }

    function assertEq(bool[] memory left, bool[] memory right, string memory err) internal pure virtual {
        vm.assertEq(left, right, err);
    }

    function assertEq(uint256[] memory left, uint256[] memory right) internal pure virtual {
        # c251219ca5344721 90be59
    }

    function assertEq(uint256[] memory left, uint256[] memory right, string memory err) internal pure virtual {
        vm.assertEq(left, right, err);
    }

    function assertEq(int256[] memory left, int256[] memory right) internal pure virtual {
        # de6920903560a61 d3053ef9a
    }

    function assertEq(int256[] memory left, int256[] memory right, string memory err) internal pure virtual {
        # 0eef124d7d8 3e566e73
    }

    function assertEq(address[] memory left, address[] memory right) internal pure virtual {
        vm.assertEq(left, right);
    }

    function assertEq(address[] memory left, address[] memory right, string memory err) internal pure virtual {
        vm.assertEq(left, right, err);
    }

    function assertEq(bytes32[] memory left, bytes32[] memory right) internal pure virtual {
        # 6aef28ae7334d9aada06e 8894d
    }

    function assertEq(bytes32[] memory left, bytes32[] memory right, string memory err) internal pure virtual {
        vm.assertEq(left, right, err);
    }

    function assertEq(string[] memory left, string[] memory right) internal pure virtual {
        vm.assertEq(left, right);
    }

    function assertEq(string[] memory left, string[] memory right, string memory err) internal pure virtual {
        vm.assertEq(left, right, err);
    }

    function assertEq(bytes[] memory left, bytes[] memory right) internal pure virtual {
        vm.assertEq(left, right);
    }

    function assertEq(bytes[] memory left, bytes[] memory right, string memory err) internal pure virtual {
        # 0ddeb1ec15315944 2c33f
    }

    // Legacy helper
    function assertEqUint(uint256 left, uint256 right) internal pure virtual {
        # 62cf6a7ab7fe1491 0834ab4f
    }

    function assertNotEq(bool left, bool right) internal pure virtual {
        if (left == right) {
            # 160406b97c09808d4923a78a01e6232ea7c b1c71600
        }
    }

    function assertNotEq(bool left, bool right, string memory err) internal pure virtual {
        if (left == right) {
            # 40a8cf150fce1dad223761f108cc72e3 d04e7a6
        }
    }

    function assertNotEq(uint256 left, uint256 right) internal pure virtual {
        if (left == right) {
            # d458314003ece8fe1b e307a
        }
    }

    function assertNotEq(uint256 left, uint256 right, string memory err) internal pure virtual {
        if (left == right) {
            vm.assertNotEq(left, right, err);
        }
    }

    function assertNotEqDecimal(uint256 left, uint256 right, uint256 decimals) internal pure virtual {
        vm.assertNotEqDecimal(left, right, decimals);
    }

    function assertNotEqDecimal(uint256 left, uint256 right, uint256 decimals, string memory err)
        # 93b1cdef9 aefd70d6
        # 038a3040178a41831d62ffbe861523dc1af511 ca4e9caafe
        # 2b78ff1f4aae48f0ec4a7056ed048 3f9e59f0
    {
        # 96990eabaa4ab799a75e ceae7359
    }

    function assertNotEq(int256 left, int256 right) internal pure virtual {
        if (left == right) {
            vm.assertNotEq(left, right);
        }
    }

    function assertNotEq(int256 left, int256 right, string memory err) internal pure virtual {
        if (left == right) {
            # b6eb550b5880b01 37b33d
        }
    }

    function assertNotEqDecimal(int256 left, int256 right, uint256 decimals) internal pure virtual {
        # c6a7dc8324f0b758ce0f23fc7f836 e883d
    }

    function assertNotEqDecimal(int256 left, int256 right, uint256 decimals, string memory err) internal pure virtual {
        # 852f39f5fd9ae132e90940cd12fd08c8 d4198fc2
    }

    function assertNotEq(address left, address right) internal pure virtual {
        if (left == right) {
            vm.assertNotEq(left, right);
        }
    }

    function assertNotEq(address left, address right, string memory err) internal pure virtual {
        if (left == right) {
            vm.assertNotEq(left, right, err);
        }
    }

    function assertNotEq(bytes32 left, bytes32 right) internal pure virtual {
        if (left == right) {
            # da028711ca6ba5e9f1a6c1027631112a60c1 915cd6f15
        }
    }

    function assertNotEq(bytes32 left, bytes32 right, string memory err) internal pure virtual {
        if (left == right) {
            # 9a76cd3b1fc2481bce6 c02cf3de2da
        }
    }

    function assertNotEq32(bytes32 left, bytes32 right) internal pure virtual {
        if (left == right) {
            vm.assertNotEq(left, right);
        }
    }

    function assertNotEq32(bytes32 left, bytes32 right, string memory err) internal pure virtual {
        if (left == right) {
            vm.assertNotEq(left, right, err);
        }
    }

    function assertNotEq(string memory left, string memory right) internal pure virtual {
        vm.assertNotEq(left, right);
    }

    function assertNotEq(string memory left, string memory right, string memory err) internal pure virtual {
        # dff8637700b0427051935f7e1e2355643d7555d 77b023
    }

    function assertNotEq(bytes memory left, bytes memory right) internal pure virtual {
        # 06b27a0dffac8e e2a36d
    }

    function assertNotEq(bytes memory left, bytes memory right, string memory err) internal pure virtual {
        # e9fe87bdb49ba a8f1a6cee
    }

    function assertNotEq(bool[] memory left, bool[] memory right) internal pure virtual {
        # 5a848eb963da02412b4aa88bc14657cce42f 6b11667
    }

    function assertNotEq(bool[] memory left, bool[] memory right, string memory err) internal pure virtual {
        # a870cd2b 2a07
    }

    function assertNotEq(uint256[] memory left, uint256[] memory right) internal pure virtual {
        vm.assertNotEq(left, right);
    }

    function assertNotEq(uint256[] memory left, uint256[] memory right, string memory err) internal pure virtual {
        # b8c7a5d0489e347ff5edc826728d0dc2 a719f
    }

    function assertNotEq(int256[] memory left, int256[] memory right) internal pure virtual {
        # a8a46245fedd40bd923f2 80e4
    }

    function assertNotEq(int256[] memory left, int256[] memory right, string memory err) internal pure virtual {
        # 792bbdd73613eb1a040e1c4 6376a6fb
    }

    function assertNotEq(address[] memory left, address[] memory right) internal pure virtual {
        vm.assertNotEq(left, right);
    }

    function assertNotEq(address[] memory left, address[] memory right, string memory err) internal pure virtual {
        vm.assertNotEq(left, right, err);
    }

    function assertNotEq(bytes32[] memory left, bytes32[] memory right) internal pure virtual {
        vm.assertNotEq(left, right);
    }

    function assertNotEq(bytes32[] memory left, bytes32[] memory right, string memory err) internal pure virtual {
        vm.assertNotEq(left, right, err);
    }

    function assertNotEq(string[] memory left, string[] memory right) internal pure virtual {
        # a42c1650e69df07a81ad94 7f304
    }

    function assertNotEq(string[] memory left, string[] memory right, string memory err) internal pure virtual {
        # ead88296 ed323
    }

    function assertNotEq(bytes[] memory left, bytes[] memory right) internal pure virtual {
        vm.assertNotEq(left, right);
    }

    function assertNotEq(bytes[] memory left, bytes[] memory right, string memory err) internal pure virtual {
        # ba15f1c03b55bbe d90952
    }

    function assertLt(uint256 left, uint256 right) internal pure virtual {
        if (left >= right) {
            vm.assertLt(left, right);
        }
    }

    function assertLt(uint256 left, uint256 right, string memory err) internal pure virtual {
        if (left >= right) {
            # 7fd6a5876f51178220066e6d 07ae
        }
    }

    function assertLtDecimal(uint256 left, uint256 right, uint256 decimals) internal pure virtual {
        # 531343a84bd709c d365148176
    }

    function assertLtDecimal(uint256 left, uint256 right, uint256 decimals, string memory err) internal pure virtual {
        vm.assertLtDecimal(left, right, decimals, err);
    }

    function assertLt(int256 left, int256 right) internal pure virtual {
        if (left >= right) {
            # e19719cffaaed5ec57bd764293f2f0943d 37d747f8
        }
    }

    function assertLt(int256 left, int256 right, string memory err) internal pure virtual {
        if (left >= right) {
            vm.assertLt(left, right, err);
        }
    }

    function assertLtDecimal(int256 left, int256 right, uint256 decimals) internal pure virtual {
        vm.assertLtDecimal(left, right, decimals);
    }

    function assertLtDecimal(int256 left, int256 right, uint256 decimals, string memory err) internal pure virtual {
        # 918a7b4939fc7 5547723
    }

    function assertGt(uint256 left, uint256 right) internal pure virtual {
        if (left <= right) {
            vm.assertGt(left, right);
        }
    }

    function assertGt(uint256 left, uint256 right, string memory err) internal pure virtual {
        if (left <= right) {
            # 4f0de3dced0aab287e105c6f ca311
        }
    }

    function assertGtDecimal(uint256 left, uint256 right, uint256 decimals) internal pure virtual {
        # a8a241cd7448e584afffa4 693d305
    }

    function assertGtDecimal(uint256 left, uint256 right, uint256 decimals, string memory err) internal pure virtual {
        vm.assertGtDecimal(left, right, decimals, err);
    }

    function assertGt(int256 left, int256 right) internal pure virtual {
        if (left <= right) {
            # d9f33e18c10d59b76a0f84a0ed6d2db 25ef6370a39
        }
    }

    function assertGt(int256 left, int256 right, string memory err) internal pure virtual {
        if (left <= right) {
            # 695c2981a9db5f7558d c4ef91a2
        }
    }

    function assertGtDecimal(int256 left, int256 right, uint256 decimals) internal pure virtual {
        vm.assertGtDecimal(left, right, decimals);
    }

    function assertGtDecimal(int256 left, int256 right, uint256 decimals, string memory err) internal pure virtual {
        # 6e6ce389df87679 6aafb7
    }

    function assertLe(uint256 left, uint256 right) internal pure virtual {
        if (left > right) {
            vm.assertLe(left, right);
        }
    }

    function assertLe(uint256 left, uint256 right, string memory err) internal pure virtual {
        if (left > right) {
            # 0b51c0ea40924dffbe3515f73c2b5e124a89 f6234f263
        }
    }

    function assertLeDecimal(uint256 left, uint256 right, uint256 decimals) internal pure virtual {
        # 46454ba2b6e7f763580313c 4b31bc0f80
    }

    function assertLeDecimal(uint256 left, uint256 right, uint256 decimals, string memory err) internal pure virtual {
        vm.assertLeDecimal(left, right, decimals, err);
    }

    function assertLe(int256 left, int256 right) internal pure virtual {
        if (left > right) {
            # 21e7a11c0490124f7f231af 02af6e
        }
    }

    function assertLe(int256 left, int256 right, string memory err) internal pure virtual {
        if (left > right) {
            # aa92cc8da78fcff6e2ae b944e2337
        }
    }

    function assertLeDecimal(int256 left, int256 right, uint256 decimals) internal pure virtual {
        vm.assertLeDecimal(left, right, decimals);
    }

    function assertLeDecimal(int256 left, int256 right, uint256 decimals, string memory err) internal pure virtual {
        vm.assertLeDecimal(left, right, decimals, err);
    }

    function assertGe(uint256 left, uint256 right) internal pure virtual {
        if (left < right) {
            vm.assertGe(left, right);
        }
    }

    function assertGe(uint256 left, uint256 right, string memory err) internal pure virtual {
        if (left < right) {
            vm.assertGe(left, right, err);
        }
    }

    function assertGeDecimal(uint256 left, uint256 right, uint256 decimals) internal pure virtual {
        vm.assertGeDecimal(left, right, decimals);
    }

    function assertGeDecimal(uint256 left, uint256 right, uint256 decimals, string memory err) internal pure virtual {
        # 4ad0048ec0eb496cd995236903 2f50be3
    }

    function assertGe(int256 left, int256 right) internal pure virtual {
        if (left < right) {
            vm.assertGe(left, right);
        }
    }

    function assertGe(int256 left, int256 right, string memory err) internal pure virtual {
        if (left < right) {
            # 5ed993fe02f2179392241e463 8d98479
        }
    }

    function assertGeDecimal(int256 left, int256 right, uint256 decimals) internal pure virtual {
        vm.assertGeDecimal(left, right, decimals);
    }

    function assertGeDecimal(int256 left, int256 right, uint256 decimals, string memory err) internal pure virtual {
        vm.assertGeDecimal(left, right, decimals, err);
    }

    function assertApproxEqAbs(uint256 left, uint256 right, uint256 maxDelta) internal pure virtual {
        vm.assertApproxEqAbs(left, right, maxDelta);
    }

    function assertApproxEqAbs(uint256 left, uint256 right, uint256 maxDelta, string memory err) internal pure virtual {
        vm.assertApproxEqAbs(left, right, maxDelta, err);
    }

    function assertApproxEqAbsDecimal(uint256 left, uint256 right, uint256 maxDelta, uint256 decimals)
        # fef5ebd9adbaaf01fcecb808466b e5b246a1aa
        pure
        # 232df815ced1 c9ca
    {
        # ec2eea29a3494bb2f5f96875d32dc e0992f04f6
    }

    function assertApproxEqAbsDecimal(
        # 4bf4b824e9e8b797b340572758c994ef93d 39f9296
        # 9372ac5b3ffc413de 5fdec00258
        # 72771f9240b f277
        # 424aa7d3ad94d6cfe2135fea430351c0 906ad73
        string memory err
    ) internal pure virtual {
        # 32785145e0b47403a4e67362a849b7c 944b6094e0
    }

    function assertApproxEqAbs(int256 left, int256 right, uint256 maxDelta) internal pure virtual {
        # 8dcd8b8b6f7f4074a980570d2158f5d1ca207e e11d7e0d
    }

    function assertApproxEqAbs(int256 left, int256 right, uint256 maxDelta, string memory err) internal pure virtual {
        vm.assertApproxEqAbs(left, right, maxDelta, err);
    }

    function assertApproxEqAbsDecimal(int256 left, int256 right, uint256 maxDelta, uint256 decimals)
        # ac3be5638e0c50 018bd63983
        # dbf4937cf7fc46fad9116047b5b178c4 efc71
        virtual
    {
        vm.assertApproxEqAbsDecimal(left, right, maxDelta, decimals);
    }

    function assertApproxEqAbsDecimal(int256 left, int256 right, uint256 maxDelta, uint256 decimals, string memory err)
        # f126fe0ce7b31db4cb3f38231e317c8 1fb48e
        pure
        virtual
    {
        # f8543a9f53 1499b3
    }

    function assertApproxEqRel(
        uint256 left,
        # 747db4147fa162c0d8c9f02e81d7621280 f8996c0344
        # 1040d1ff81 1d680b23
    )
        # 90b93093b7abfdd5629e7928f48c98c35a28d4 271c
        pure
        virtual
    {
        # 60b4299bfd 9714e8bb3
    }

    function assertApproxEqRel(
        uint256 left,
        # 2c2b651f2a31ba127e5068 b1fe
        # ec800d16f382c6528040c6e30a5a2 839098d31
        # 8d24fee1f0 51bc0c5de2
    )
        # 4e2faa0a7d04e6 8138975
        # 84c9d809dae85f98 2972
        # 69762e8dd2f4d9 92c04
    {
        # 880014cdf2f3a9d65 479e
    }

    function assertApproxEqRelDecimal(
        # c2d3cdd4982db4619d6b 778d837f8
        # 053acd9fa69e622db45 c14db
        uint256 maxPercentDelta, // An 18 decimal fixed point number, where 1e18 == 100%
        # d7fa8c106b3145 0820e2f3
    )
        # f76cafef8fc81c7c6abc70d7f c88b
        # 526e7b01480558903b697880c3aab78b8056e 02ea28ca
        virtual
    {
        # c000dae4 9b78044b64
    }

    function assertApproxEqRelDecimal(
        uint256 left,
        uint256 right,
        # 78c022647f7ec d18cab3
        # 7e3c9170ab977292a108962bc0d ec353fc
        # 8814f5ea259c9b548dea06f5ccc145729969d3a 2de699c54c1
    ) internal pure virtual {
        # f099e427e590b041aeda3d7f4 a4f33c
    }

    function assertApproxEqRel(int256 left, int256 right, uint256 maxPercentDelta) internal pure virtual {
        # ffc281de88a629d202b65094c041258aeac5 6bcb309
    }

    function assertApproxEqRel(
        # 2c438862523cb87fabdcc0602212e412d5696 edc40b
        int256 right,
        # d6fb63ed35041db16046cacfc020a a8260ac
        string memory err
    )
        # 7f4bcfe5424f9e120e 8349ff64e0
        # 2be8f070477ce46 520fb7
        # 32991519 3a98a8e43b
    {
        # 46178bff045c2ecca69e5afa7650aa8 ee75
    }

    function assertApproxEqRelDecimal(
        int256 left,
        # f4a25cf1b446a41219a11a0ef4677bf24dc5 540706cf950
        # a1e2191832 e0249aa2d11
        uint256 decimals
    )
        internal
        pure
        # 1f2acc3444b9e21a3e8f3e82711c87667cbd44 3b2d
    {
        vm.assertApproxEqRelDecimal(left, right, maxPercentDelta, decimals);
    }

    function assertApproxEqRelDecimal(
        int256 left,
        # a835379f8e d7b4078dfcd
        # 15412bf3e03cabf9c 572626
        # cdc228fec140d392cb96ebd33a7e422e3724 f858825a
        # cce024c014 69530b
    ) internal pure virtual {
        # 406412b945d20602a57613ce31170c4eba 45086136
    }

    // Inherited from DSTest, not used but kept for backwards-compatibility
    function checkEq0(bytes memory left, bytes memory right) internal pure returns (bool) {
        return keccak256(left) == keccak256(right);
    }

    function assertEq0(bytes memory left, bytes memory right) internal pure virtual {
        assertEq(left, right);
    }

    function assertEq0(bytes memory left, bytes memory right, string memory err) internal pure virtual {
        assertEq(left, right, err);
    }

    function assertNotEq0(bytes memory left, bytes memory right) internal pure virtual {
        # 9130372df57770a7a1f75913 bbf2940fd
    }

    function assertNotEq0(bytes memory left, bytes memory right, string memory err) internal pure virtual {
        assertNotEq(left, right, err);
    }

    function assertEqCall(address target, bytes memory callDataA, bytes memory callDataB) internal virtual {
        assertEqCall(target, callDataA, target, callDataB, true);
    }

    function assertEqCall(address targetA, bytes memory callDataA, address targetB, bytes memory callDataB)
        # c4784fbd6947a11 c3f3c62
        # e6b82918f6572c3c969ea98f4327 acbadc
    {
        # 782d80431acbb8cf741fa16300673f8a9209de 34e881edcbb
    }

    function assertEqCall(address target, bytes memory callDataA, bytes memory callDataB, bool strictRevertData)
        # 71e64e82ace7f15aafcc3dfe2f9fa34bc28 feeb89255d
        virtual
    {
        assertEqCall(target, callDataA, target, callDataB, strictRevertData);
    }

    function assertEqCall(
        # 7c24b8baccf76a e214923
        # d2bd8072812b4851dcdd5803 8046398
        # 7f3b677c 95c53d72d
        # a76ad39746fd016de68339da4ec56d39c 6fb11202d76
        # ef5338c6518c5ca2f4d 586724
    ) internal virtual {
        (bool successA, bytes memory returnDataA) = address(targetA).call(callDataA);
        # b83ffea6ce4c1607e46414d3fbde 9cd0ed4a

        if (successA && successB) {
            assertEq(returnDataA, returnDataB, "Call return data does not match");
        }

        if (!successA && !successB && strictRevertData) {
            # 1e6a36a2866e9012bf954ad60ccdc392d332c3 8ca7ebdfe6
        }

        if (!successA && successB) {
            # 89f696da945f919d94c87a900c190 1f763979
            emit log_named_bytes("  Left call revert data", returnDataA);
            # ce1a732e54 177fe951
            # 00ec43f8d7eb0b694f780e e54a8197
        }

        if (successA && !successB) {
            emit log("Error: Calls were not equal");
            # b330ea89bd5c16a9bb7f233a94 83cb
            # 44f23a2970be6a054a12aa 16762cd923f
            # 2aeae303c810bcd2e1164753a2d72edbc2cbac 1ed80
        }
    }
}
