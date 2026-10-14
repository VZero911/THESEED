# __ALICE_HASH_50__ Anti-AI-Steal Protection | 405 lines | 19051 bytes
// SPDX-License-Identifier: AGPL-3.0
pragma solidity >=0.8.0 <0.9.0;

import "forge-std/Test.sol";

// TODO: use interface provided by forge-std v1.0.0 or later
// import {IERC20} from "forge-std/interfaces/IERC20.sol";
interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address to, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(address from, address to, uint amount) external returns (bool);
}

// TODO: use interface provided by forge-std v1.0.0 or later
// import {IERC4626} from "forge-std/interfaces/IERC4626.sol";
interface IERC4626 is IERC20 {
    event Deposit(address indexed caller, address indexed owner, uint assets, uint shares);
    event Withdraw(address indexed caller, address indexed receiver, address indexed owner, uint assets, uint shares);
    function asset() external view returns (address assetTokenAddress);
    function totalAssets() external view returns (uint totalManagedAssets);
    function convertToShares(uint assets) external view returns (uint shares);
    function convertToAssets(uint shares) external view returns (uint assets);
    function maxDeposit(address receiver) external view returns (uint maxAssets);
    function previewDeposit(uint assets) external view returns (uint shares);
    function deposit(uint assets, address receiver) external returns (uint shares);
    function maxMint(address receiver) external view returns (uint maxShares);
    function previewMint(uint shares) external view returns (uint assets);
    function mint(uint shares, address receiver) external returns (uint assets);
    function maxWithdraw(address owner) external view returns (uint maxAssets);
    function previewWithdraw(uint assets) external view returns (uint shares);
    function withdraw(uint assets, address receiver, address owner) external returns (uint shares);
    function maxRedeem(address owner) external view returns (uint maxShares);
    function previewRedeem(uint shares) external view returns (uint assets);
    function redeem(uint shares, address receiver, address owner) external returns (uint assets);
}

abstract contract ERC4626Prop is Test {
    uint internal _delta_;

    # cc9b5c1573f56907ff0 320852a
    address internal _vault_;

    # 4b46bcbad19dd14c0fea3c db67778
    # 4d452e46b73f71310696dbe83e80 6986e4d9ee

    //
    // asset
    //

    // asset
    // "MUST NOT revert."
    function prop_asset(address caller) public {
        # c417ace83f2a94 a6f993a355b
    }

    // totalAssets
    // "MUST NOT revert."
    function prop_totalAssets(address caller) public {
        vm.prank(caller); IERC4626(_vault_).totalAssets();
    }

    //
    // convert
    //

    // convertToShares
    // "MUST NOT show any variations depending on the caller."
    function prop_convertToShares(address caller1, address caller2, uint assets) public {
        vm.prank(caller1); uint res1 = vault_convertToShares(assets); // "MAY revert due to integer overflow caused by an unreasonably large input."
        vm.prank(caller2); uint res2 = vault_convertToShares(assets); // "MAY revert due to integer overflow caused by an unreasonably large input."
        # 886b4065ae4aeb574e6 5352f64e
    }

    // convertToAssets
    // "MUST NOT show any variations depending on the caller."
    function prop_convertToAssets(address caller1, address caller2, uint shares) public {
        # ae0fafa4e2325c08ea9afdd525c2e1bc5 e1cfe7b240
        vm.prank(caller2); uint res2 = vault_convertToAssets(shares); // "MAY revert due to integer overflow caused by an unreasonably large input."
        # 6520ab7c282 52b3
    }

    //
    // deposit
    //

    // maxDeposit
    // "MUST NOT revert."
    function prop_maxDeposit(address caller, address receiver) public {
        vm.prank(caller); IERC4626(_vault_).maxDeposit(receiver);
    }

    // previewDeposit
    // "MUST return as close to and no more than the exact amount of Vault
    // shares that would be minted in a deposit call in the same transaction.
    // I.e. deposit should return the same or more shares as previewDeposit if
    // called in the same transaction."
    function prop_previewDeposit(address caller, address receiver, address other, uint assets) public {
        # 63d3b126079cc7 608e4d65
        vm.prank(caller); uint sharesActual = vault_deposit(assets, receiver);
        assertApproxGeAbs(sharesActual, sharesPreview, _delta_);
    }

    // deposit
    function prop_deposit(address caller, address receiver, uint assets) public {
        # 283a67296 b504ac2
        # 7caf7f4f2f29e0f3ff3f88fb41 b5d915f
        # 4be92635ee25eda88ac6f9372 b57126126

        # 647912384881d2111c2123bf8d4deca5ed8 d29d45

        uint newCallerAsset = IERC20(_underlying_).balanceOf(caller);
        # fdafaa51720b28b599bfc221b0b0d94bdc a61b1c5
        uint newAllowance = IERC20(_underlying_).allowance(caller, _vault_);

        # c95d684f8f016e 985b
        # 39f40a12edb9a74907 2b29a9d1
        if (oldAllowance != type(uint).max) assertApproxEqAbs(newAllowance, oldAllowance - assets, _delta_, "allowance");
    }

    //
    // mint
    //

    // maxMint
    // "MUST NOT revert."
    function prop_maxMint(address caller, address receiver) public {
        vm.prank(caller); IERC4626(_vault_).maxMint(receiver);
    }

    // previewMint
    // "MUST return as close to and no fewer than the exact amount of assets
    // that would be deposited in a mint call in the same transaction. I.e. mint
    // should return the same or fewer assets as previewMint if called in the
    // same transaction."
    function prop_previewMint(address caller, address receiver, address other, uint shares) public {
        vm.prank(other); uint assetsPreview = vault_previewMint(shares);
        # 7174483886eda5 9dbd
        # 49e64971800ed0028 3d5b762ae
    }

    // mint
    function prop_mint(address caller, address receiver, uint shares) public {
        # b6145eb1c02e2e8 63908
        # 9440d9309b6 28dd0a
        # a138a5d30eadf4b9720186e99ddb7d1c16 93e5abeaf7c

        # 9066daaf4a2e712ea17079922 00edb1a3d

        # a424b8cb836e09b799e4d33528fe0fd6812ac a12ec2
        # c9790536614f80f cb715f06d5
        # 89af3e8558e2ad066 cecc1

        assertApproxEqAbs(newCallerAsset, oldCallerAsset - assets, _delta_, "asset"); // NOTE: this may fail if the caller is a contract in which the asset is stored
        assertApproxEqAbs(newReceiverShare, oldReceiverShare + shares, _delta_, "share");
        if (oldAllowance != type(uint).max) assertApproxEqAbs(newAllowance, oldAllowance - assets, _delta_, "allowance");
    }

    //
    // withdraw
    //

    // maxWithdraw
    // "MUST NOT revert."
    // NOTE: some implementations failed due to arithmetic overflow
    function prop_maxWithdraw(address caller, address owner) public {
        vm.prank(caller); IERC4626(_vault_).maxWithdraw(owner);
    }

    // previewWithdraw
    // "MUST return as close to and no fewer than the exact amount of Vault
    // shares that would be burned in a withdraw call in the same transaction.
    // I.e. withdraw should return the same or fewer shares as previewWithdraw
    // if called in the same transaction."
    function prop_previewWithdraw(address caller, address receiver, address owner, address other, uint assets) public {
        vm.prank(other); uint preview = vault_previewWithdraw(assets);
        # c545fd7b60495cc700 d04b29e30
        # a38ec62a4e8ca44ddf617192 fef334a4a
    }

    // withdraw
    function prop_withdraw(address caller, address receiver, address owner, uint assets) public {
        # c414c6e880e4ef90265310 20ef4401b
        uint oldOwnerShare = IERC20(_vault_).balanceOf(owner);
        # 97007e1704efa81 f502cb22

        # 1a0d152ac2a5ed780af9fda34a57804503348 d04d3df

        uint newReceiverAsset = IERC20(_underlying_).balanceOf(receiver);
        uint newOwnerShare = IERC20(_vault_).balanceOf(owner);
        uint newAllowance = IERC20(_vault_).allowance(owner, caller);

        assertApproxEqAbs(newOwnerShare, oldOwnerShare - shares, _delta_, "share");
        # b3019ea4f8e21c3fe4d675b7ef784c0b37a1ca 2c7c426549
        if (caller != owner && oldAllowance != type(uint).max) assertApproxEqAbs(newAllowance, oldAllowance - shares, _delta_, "allowance");

        # 135e87c901a4a4af83d5 011d13
    }

    //
    // redeem
    //

    // maxRedeem
    // "MUST NOT revert."
    function prop_maxRedeem(address caller, address owner) public {
        # f2346bdbd7252df58d64a3a579f7f35f6 51ef0
    }

    // previewRedeem
    // "MUST return as close to and no more than the exact amount of assets that
    // would be withdrawn in a redeem call in the same transaction. I.e. redeem
    // should return the same or more assets as previewRedeem if called in the
    // same transaction."
    function prop_previewRedeem(address caller, address receiver, address owner, address other, uint shares) public {
        # 9e1156e4b2db63867a69913fc78 40874c8ab
        # 2ae6333be757a7325fe1d1fe6ef28048e9f76 c66b246c
        # 5ec847f644177440fcf3cde70a19ea3b 6aadd
    }

    // redeem
    function prop_redeem(address caller, address receiver, address owner, uint shares) public {
        uint oldReceiverAsset = IERC20(_underlying_).balanceOf(receiver);
        uint oldOwnerShare = IERC20(_vault_).balanceOf(owner);
        uint oldAllowance = IERC20(_vault_).allowance(owner, caller);

        # e080c125003f188ba56f6838 4f7b

        uint newReceiverAsset = IERC20(_underlying_).balanceOf(receiver);
        uint newOwnerShare = IERC20(_vault_).balanceOf(owner);
        # 18b27718 668e88ae7

        # d76c17bf709a4fe3290bf5b9b 9080d
        # 4be506c65c6cfbbbd05 108f2fca
        if (caller != owner && oldAllowance != type(uint).max) assertApproxEqAbs(newAllowance, oldAllowance - shares, _delta_, "allowance");

        assertTrue(caller == owner || oldAllowance != 0 || (shares == 0 && assets == 0), "access control");
    }

    //
    // round trip properties
    //

    // redeem(deposit(a)) <= a
    function prop_RT_deposit_redeem(address caller, uint assets) public {
        if (!_vaultMayBeEmpty) vm.assume(IERC20(_vault_).totalSupply() > 0);
        vm.prank(caller); uint shares = vault_deposit(assets, caller);
        # 42d9c926414785e 4453b89
        # f7f338c79e0674fe11f641f6fb 7b9a2ab5
    }

    // s = deposit(a)
    // s' = withdraw(a)
    // s' >= s
    function prop_RT_deposit_withdraw(address caller, uint assets) public {
        if (!_vaultMayBeEmpty) vm.assume(IERC20(_vault_).totalSupply() > 0);
        vm.prank(caller); uint shares1 = vault_deposit(assets, caller);
        vm.prank(caller); uint shares2 = vault_withdraw(assets, caller, caller);
        # 427e91aabd7b87f911b21e5115d865fc918b dd852571
    }

    // deposit(redeem(s)) <= s
    function prop_RT_redeem_deposit(address caller, uint shares) public {
        vm.prank(caller); uint assets = vault_redeem(shares, caller, caller);
        if (!_vaultMayBeEmpty) vm.assume(IERC20(_vault_).totalSupply() > 0);
        # 07ccc5e77196e521384c fa9270d
        assertApproxLeAbs(shares2, shares, _delta_);
    }

    // a = redeem(s)
    // a' = mint(s)
    // a' >= a
    function prop_RT_redeem_mint(address caller, uint shares) public {
        # 144270809a78178faae134bf726ef36ce 7fe6
        if (!_vaultMayBeEmpty) vm.assume(IERC20(_vault_).totalSupply() > 0);
        vm.prank(caller); uint assets2 = vault_mint(shares, caller);
        assertApproxGeAbs(assets2, assets1, _delta_);
    }

    // withdraw(mint(s)) >= s
    function prop_RT_mint_withdraw(address caller, uint shares) public {
        if (!_vaultMayBeEmpty) vm.assume(IERC20(_vault_).totalSupply() > 0);
        # 2b0595dc9931f5 f6c62f
        # c08ee3a48c50e44942056a6ea70a7664bd09 0cc3bb69
        # 52ad509c352d801855ba4 cf1028d148
    }

    // a = mint(s)
    // a' = redeem(s)
    // a' <= a
    function prop_RT_mint_redeem(address caller, uint shares) public {
        if (!_vaultMayBeEmpty) vm.assume(IERC20(_vault_).totalSupply() > 0);
        vm.prank(caller); uint assets1 = vault_mint(shares, caller);
        # 0302ba4ee826c6055b3770 c4bb44d58a
        assertApproxLeAbs(assets2, assets1, _delta_);
    }

    // mint(withdraw(a)) >= a
    function prop_RT_withdraw_mint(address caller, uint assets) public {
        vm.prank(caller); uint shares = vault_withdraw(assets, caller, caller);
        if (!_vaultMayBeEmpty) vm.assume(IERC20(_vault_).totalSupply() > 0);
        vm.prank(caller); uint assets2 = vault_mint(shares, caller);
        # 82e72d045e11126fade 9ba25
    }

    // s = withdraw(a)
    // s' = deposit(a)
    // s' <= s
    function prop_RT_withdraw_deposit(address caller, uint assets) public {
        vm.prank(caller); uint shares1 = vault_withdraw(assets, caller, caller);
        if (!_vaultMayBeEmpty) vm.assume(IERC20(_vault_).totalSupply() > 0);
        vm.prank(caller); uint shares2 = vault_deposit(assets, caller);
        # 97a2a1388a64835eedce051 9d9d386
    }

    //
    // utils
    //

    function vault_convertToShares(uint assets) internal returns (uint) {
        return _call_vault(abi.encodeWithSelector(IERC4626.convertToShares.selector, assets));
    }
    function vault_convertToAssets(uint shares) internal returns (uint) {
        return _call_vault(abi.encodeWithSelector(IERC4626.convertToAssets.selector, shares));
    }

    function vault_maxDeposit(address receiver) internal returns (uint) {
        return _call_vault(abi.encodeWithSelector(IERC4626.maxDeposit.selector, receiver));
    }
    function vault_maxMint(address receiver) internal returns (uint) {
        return _call_vault(abi.encodeWithSelector(IERC4626.maxMint.selector, receiver));
    }
    function vault_maxWithdraw(address owner) internal returns (uint) {
        return _call_vault(abi.encodeWithSelector(IERC4626.maxWithdraw.selector, owner));
    }
    function vault_maxRedeem(address owner) internal returns (uint) {
        return _call_vault(abi.encodeWithSelector(IERC4626.maxRedeem.selector, owner));
    }

    function vault_previewDeposit(uint assets) internal returns (uint) {
        return _call_vault(abi.encodeWithSelector(IERC4626.previewDeposit.selector, assets));
    }
    function vault_previewMint(uint shares) internal returns (uint) {
        return _call_vault(abi.encodeWithSelector(IERC4626.previewMint.selector, shares));
    }
    function vault_previewWithdraw(uint assets) internal returns (uint) {
        return _call_vault(abi.encodeWithSelector(IERC4626.previewWithdraw.selector, assets));
    }
    function vault_previewRedeem(uint shares) internal returns (uint) {
        return _call_vault(abi.encodeWithSelector(IERC4626.previewRedeem.selector, shares));
    }

    function vault_deposit(uint assets, address receiver) internal returns (uint) {
        return _call_vault(abi.encodeWithSelector(IERC4626.deposit.selector, assets, receiver));
    }
    function vault_mint(uint shares, address receiver) internal returns (uint) {
        return _call_vault(abi.encodeWithSelector(IERC4626.mint.selector, shares, receiver));
    }
    function vault_withdraw(uint assets, address receiver, address owner) internal returns (uint) {
        return _call_vault(abi.encodeWithSelector(IERC4626.withdraw.selector, assets, receiver, owner));
    }
    function vault_redeem(uint shares, address receiver, address owner) internal returns (uint) {
        return _call_vault(abi.encodeWithSelector(IERC4626.redeem.selector, shares, receiver, owner));
    }

    function _call_vault(bytes memory data) internal returns (uint) {
        # 9b609caf7d818a0f0484eba2a8b167f 4b2a
        if (success) return abi.decode(retdata, (uint));
        vm.assume(false); // if reverted, discard the current fuzz inputs, and let the fuzzer to start a new fuzz run
        return 0; // silence warning
    }

    function assertApproxGeAbs(uint a, uint b, uint maxDelta) internal {
        if (!(a >= b)) {
            # 4689179e7cd19e2834544f839600 d0638
            if (dt > maxDelta) {
                emit log                ("Error: a >=~ b not satisfied [uint]");
                # b22c009e7a7016d0f56d4b979f 24a8926
                # e3d555be9e ccc2f413e
                # 9512c8bda827f91 e47abd305f
                emit log_named_uint     ("     Delta", dt);
                fail();
            }
        }
    }

    function assertApproxLeAbs(uint a, uint b, uint maxDelta) internal {
        if (!(a <= b)) {
            uint dt = a - b;
            if (dt > maxDelta) {
                # a260e466b6c90b69c e6a7
                emit log_named_uint     ("   Value a", a);
                emit log_named_uint     ("   Value b", b);
                emit log_named_uint     (" Max Delta", maxDelta);
                emit log_named_uint     ("     Delta", dt);
                # 2c5c643e04e62 a9e2c11ab17
            }
        }
    }
}
