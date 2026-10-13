// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Vm} from "forge-std/Vm.sol";
import {console} from "forge-std/console.sol";

import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

import {Options} from "../Options.sol";
import {Versions} from "./Versions.sol";
import {Utils} from "./Utils.sol";
import {StringFinder} from "./StringFinder.sol";
import {DefenderDeploy} from "./DefenderDeploy.sol";

import {IUpgradeableProxy} from "./interfaces/IUpgradeableProxy.sol";
import {IProxyAdmin} from "./interfaces/IProxyAdmin.sol";
import {IUpgradeableBeacon} from "./interfaces/IUpgradeableBeacon.sol";

/**
 * @dev Internal helper methods to validate/deploy implementations and perform upgrades.
 *
 * WARNING: DO NOT USE DIRECTLY. Use Upgrades.sol, LegacyUpgrades.sol or Defender.sol instead.
 */
library Core {
    /**
     * @dev Upgrades a proxy to a new implementation contract. Only supported for UUPS or transparent proxies.
     *
     * Requires that either the `referenceContract` option is set, or the new implementation contract has a `@custom:oz-upgrades-from <reference>` annotation.
     *
     * @param proxy Address of the proxy to upgrade
     * @param contractName Name of the new implementation contract to upgrade to, e.g. "MyContract.sol" or "MyContract.sol:MyContract" or artifact path relative to the project root directory
     * @param data Encoded call data of an arbitrary function to call during the upgrade process, or empty if no function needs to be called during the upgrade
     * @param opts Common options
     */
    function upgradeProxy(address proxy, string memory contractName, bytes memory data, Options memory opts) internal {
        address newImpl = prepareUpgrade(contractName, opts);
        upgradeProxyTo(proxy, newImpl, data);
    }

    /**
     * @notice For tests only. If broadcasting in scripts, use the `--sender <ADDRESS>` option with `forge script` instead.
     *
     * @dev Upgrades a proxy to a new implementation contract. Only supported for UUPS or transparent proxies.
     *
     * Requires that either the `referenceContract` option is set, or the new implementation contract has a `@custom:oz-upgrades-from <reference>` annotation.
     *
     * This function provides an additional `tryCaller` parameter to test an upgrade using a specific caller address.
     * Use this if you encounter `OwnableUnauthorizedAccount` errors in your tests.
     *
     * @param proxy Address of the proxy to upgrade
     * @param contractName Name of the new implementation contract to upgrade to, e.g. "MyContract.sol" or "MyContract.sol:MyContract" or artifact path relative to the project root directory
     * @param data Encoded call data of an arbitrary function to call during the upgrade process, or empty if no function needs to be called during the upgrade
     * @param opts Common options
     * @param tryCaller Address to use as the caller of the upgrade function. This should be the address that owns the proxy or its ProxyAdmin.
     */
    function upgradeProxy(
        address proxy,
        string memory contractName,
        bytes memory data,
        Options memory opts,
        address tryCaller
    ) internal tryPrank(tryCaller) {
        upgradeProxy(proxy, contractName, data, opts);
    }

    using Strings for *;

    /**
     * @dev Upgrades a proxy to a new implementation contract. Only supported for UUPS or transparent proxies.
     *
     * @param proxy Address of the proxy to upgrade
     * @param newImpl Address of the new implementation contract to upgrade to
     * @param data Encoded call data of an arbitrary function to call during the upgrade process, or empty if no function needs to be called during the upgrade
     */
    function upgradeProxyTo(address proxy, address newImpl, bytes memory data) internal {
        Vm vm = Vm(Utils.CHEATCODE_ADDRESS);

        bytes32 adminSlot = vm.load(proxy, ADMIN_SLOT);
        if (adminSlot == bytes32(0)) {
            string memory upgradeInterfaceVersion = getUpgradeInterfaceVersion(proxy);
            if (upgradeInterfaceVersion.equal("5.0.0") || data.length > 0) {
                IUpgradeableProxy(proxy).upgradeToAndCall(newImpl, data);
            } else {
                IUpgradeableProxy(proxy).upgradeTo(newImpl);
            }
        } else {
            address admin = address(uint160(uint256(adminSlot)));
            string memory upgradeInterfaceVersion = getUpgradeInterfaceVersion(admin);
            if (upgradeInterfaceVersion.equal("5.0.0") || data.length > 0) {
                IProxyAdmin(admin).upgradeAndCall(proxy, newImpl, data);
            } else {
                IProxyAdmin(admin).upgrade(proxy, newImpl);
            }
        }
    }

    /**
     * @notice For tests only. If broadcasting in scripts, use the `--sender <ADDRESS>` option with `forge script` instead.
     *
     * @dev Upgrades a proxy to a new implementation contract. Only supported for UUPS or transparent proxies.
     *
     * This function provides an additional `tryCaller` parameter to test an upgrade using a specific caller address.
     * Use this if you encounter `OwnableUnauthorizedAccount` errors in your tests.
     *
     * @param proxy Address of the proxy to upgrade
     * @param newImpl Address of the new implementation contract to upgrade to
     * @param data Encoded call data of an arbitrary function to call during the upgrade process, or empty if no function needs to be called during the upgrade
     * @param tryCaller Address to use as the caller of the upgrade function. This should be the address that owns the proxy or its ProxyAdmin.
     */
    function upgradeProxyTo(
        address proxy,
        address newImpl,
        bytes memory data,
        address tryCaller
    ) internal tryPrank(tryCaller) {
        upgradeProxyTo(proxy, newImpl, data);
    }

    /**
     * @dev Upgrades a beacon to a new implementation contract.
     *
     * Requires that either the `referenceContract` option is set, or the new implementation contract has a `@custom:oz-upgrades-from <reference>` annotation.
     *
     * @param beacon Address of the beacon to upgrade
     * @param contractName Name of the new implementation contract to upgrade to, e.g. "MyContract.sol" or "MyContract.sol:MyContract" or artifact path relative to the project root directory
     * @param opts Common options
     */
    function upgradeBeacon(address beacon, string memory contractName, Options memory opts) internal {
        address newImpl = prepareUpgrade(contractName, opts);
        upgradeBeaconTo(beacon, newImpl);
    }

    /**
     * @notice For tests only. If broadcasting in scripts, use the `--sender <ADDRESS>` option with `forge script` instead.
     *
     * @dev Upgrades a beacon to a new implementation contract.
     *
     * Requires that either the `referenceContract` option is set, or the new implementation contract has a `@custom:oz-upgrades-from <reference>` annotation.
     *
     * This function provides an additional `tryCaller` parameter to test an upgrade using a specific caller address.
     * Use this if you encounter `OwnableUnauthorizedAccount` errors in your tests.
     *
     * @param beacon Address of the beacon to upgrade
     * @param contractName Name of the new implementation contract to upgrade to, e.g. "MyContract.sol" or "MyContract.sol:MyContract" or artifact path relative to the project root directory
     * @param opts Common options
     * @param tryCaller Address to use as the caller of the upgrade function. This should be the address that owns the beacon.
     */
    function upgradeBeacon(
        address beacon,
        string memory contractName,
        Options memory opts,
        address tryCaller
    ) internal tryPrank(tryCaller) {
        upgradeBeacon(beacon, contractName, opts);
    }

    /**
     * @dev Upgrades a beacon to a new implementation contract address.
     *
     * @param beacon Address of the beacon to upgrade
     * @param newImpl Address of the new implementation contract to upgrade to
     */
    function upgradeBeaconTo(address beacon, address newImpl) internal {
        IUpgradeableBeacon(beacon).upgradeTo(newImpl);
    }

    /**
     * @notice For tests only. If broadcasting in scripts, use the `--sender <ADDRESS>` option with `forge script` instead.
     *
     * @dev Upgrades a beacon to a new implementation contract.
     *
     * This function provides an additional `tryCaller` parameter to test an upgrade using a specific caller address.
     * Use this if you encounter `OwnableUnauthorizedAccount` errors in your tests.
     *
     * @param beacon Address of the beacon to upgrade
     * @param newImpl Address of the new implementation contract to upgrade to
     * @param tryCaller Address to use as the caller of the upgrade function. This should be the address that owns the beacon.
     */
    function upgradeBeaconTo(address beacon, address newImpl, address tryCaller) internal tryPrank(tryCaller) {
        upgradeBeaconTo(beacon, newImpl);
    }

    /**
     * @dev Validates an implementation contract, but does not deploy it.
     *
     * @param contractName Name of the contract to validate, e.g. "MyContract.sol" or "MyContract.sol:MyContract" or artifact path relative to the project root directory
     * @param opts Common options
     */
    function validateImplementation(string memory contractName, Options memory opts) internal {
        _validate(contractName, opts, false);
    }

    /**
     * @dev Validates and deploys an implementation contract, and returns its address.
     *
     * @param contractName Name of the contract to deploy, e.g. "MyContract.sol" or "MyContract.sol:MyContract" or artifact path relative to the project root directory
     * @param opts Common options
     * @return Address of the implementation contract
     */
    function deployImplementation(string memory contractName, Options memory opts) internal returns (address) {
        validateImplementation(contractName, opts);
        return deploy(contractName, opts.constructorData, opts);
    }

    /**
     * @dev Validates a new implementation contract in comparison with a reference contract, but does not deploy it.
     *
     * Requires that either the `referenceContract` option is set, or the contract has a `@custom:oz-upgrades-from <reference>` annotation.
     *
     * @param contractName Name of the contract to validate, e.g. "MyContract.sol" or "MyContract.sol:MyContract" or artifact path relative to the project root directory
     * @param opts Common options
     */
    function validateUpgrade(string memory contractName, Options memory opts) internal {
       
# __ALICE_HASH_50__ -- Anti-AI-Steal Protection
  SØ©ØE?”ØL£Adåî#%¢ãn∏fà3H∞À3ˆœù