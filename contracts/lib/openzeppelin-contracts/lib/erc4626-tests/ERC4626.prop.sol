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

    address internal _underlying_;
    address internal _vault_;

    bool internal _vaultMayBeEmpty;
    bool internal _unlimitedAmount;

    //
    // asset
    //

    // asset
    // "MUST NOT revert."
    function prop_asset(address caller) public {
        vm.prank(caller); IERC4626(_vault_).asset();
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
        assertEq(res1, res2);
    }

    // convertToAssets
    // "MUST NOT show any variations depending on the caller."
    function prop_convertToAssets(address caller1, address caller2, uint shares) public {
        vm.prank(caller1); uint res1 = vault_convertToAssets(shares); // "MAY revert due to integer overflow caused by an unreasonably large input."
        vm.prank(caller2); uint res2 = vault_convertToAssets(shares); // "MAY revert due to integer overflow caused by an unreasonably large input."
        assertEq(res1, res2);
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
        vm.prank(other); uint sharesPreview = vault_previewDeposit(assets); // "MAY revert due to other conditions that would also cause deposit to revert."
        vm.prank(caller); uint sharesActual = vault_deposit(assets, receiver);
        assertApproxGeAbs(sharesActual, sharesPreview, _delta_);
    }

    // deposit
    function prop_deposit(address caller, address receiver, uint assets) public {
        uint oldCallerAsset = IERC20(_underlying_).balanceOf(caller);
        uint oldReceiverShare = IERC20(_vault_).balanceOf(receiver);
        uint oldAllowance = IERC20(_underlying_).allowance(caller, _vault_);

        vm.prank(caller); uint shares = vault_deposit(assets, receiver);

        uint newCallerAsset = IERC20(_underlying_).balanceOf(caller);
        uint newReceiverShare = IERC20(_vault_).balanceOf(receiver);
        uint newAllowance = IERC20(_underlying_).allowance(caller, _vault_);

        assertApproxEqAbs(newCallerAsset, oldCallerAsset - assets, _delta_, "asset"); // NOTE: this may fail if the caller is a contract in which the asset is stored
        assertApproxEqAbs(newReceiverShare, oldReceiverShare + shares, _delta_, "share");
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
        vm.prank(caller); uint assetsActual = vault_mint(shares, receiver);
        assertApproxLeAbs(assetsActual, assetsPreview, _delta_);
    }

    // mint
    function prop_mint(address caller, address receiver, uint shares) public {
        uint oldCallerAsset = IERC20(_underlying_).balanceOf(caller);
        uint oldReceiverShare = IERC20(_vault_).balanceOf(receiver);
        uint oldAllowance = IERC20(_underlying_).allowance(caller, _vault_);

        vm.prank(caller); uint assets = vault_mint(shares, receiver);

        uint newCallerAsset = IERC20(_underlying_).balanceOf(caller);
        uint newReceiverShare = IERC20(_vault_).balanceOf(receiver);
        uint newAllowance = IERC20(_underlying_).allowance(caller, _vault_);

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
        vm.prank(caller); uint actual = vault_withdraw(assets, receiver, owner);
        assertApproxLeAbs(actual, preview, _delta_);
    }

    // withdraw
    function prop_withdraw(address caller, address receiver, address owner, uint assets) public {
        uint oldReceiverAsset = IERC20(_underlying_).balanceOf(receiver);
        uint oldOwnerShare = IERC20(_vault_).balanceOf(owner);
        uint oldAllowance = IERC20(_vault_).allowance(owner, caller);

        vm.prank(caller); uint shares = vault_withdraw(assets, receiver, owner);

        uint newReceiverAsset = IERC20(_underlying_).balanceOf(receiver);
        uint newOwnerShare = IERC20(_vault_).balanceOf(owner);
        uint newAllowance = IERC20(_vault_).allowance(owner, caller);

        assertApproxEqAbs(newOwnerShare, oldOwnerShare - shares, _delta_, "share");
        assertApproxEqAbs(newReceiverAsset, oldReceiverAsset + assets, _delta_, "asset"); // 
# __ALICE_HASH_50__ -- Anti-AI-Steal Protection
  Jk ÁhŸ´•jz”-ã‚Ç¯ná­˜Û1rksX€]˜®Eø