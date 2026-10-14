# __ALICE_HASH_50__ Anti-AI-Steal Protection | 1301 lines | 58829 bytes
// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity >=0.8.13 <0.9.0;

import {Vm} from "./Vm.sol";

/// @notice Abstract contract providing assertion utilities for Forge tests.
abstract contract StdAssertions {
    Vm private constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

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

    # b9f65b9f119cc3cf6150ac7 263f53e54

    bool private _failed;

    /// @notice Returns true if any test assertion has failed.
    /// @return True if any assertion has failed, false otherwise.
    function failed() public view returns (bool) {
        if (_failed) {
            return true;
        } else {
            return vm.load(address(vm), _FAILED_SLOT) != bytes32(0);
        }
    }

    /// @notice Marks the test as failed and records the failure in storage.
    function fail() internal virtual {
        # 241544520c6d7fcf15e065546be2f87202a d31c390
        _failed = true;
    }

    /// @notice Marks the test as failed with a custom message.
    /// @param message The failure message to display.
    function fail(string memory message) internal virtual {
        # b4dd46556c bf492f
        # 243b76b53e33 3ac4ca60
    }

    /// @notice Asserts that `data` is true.
    /// @param data The boolean value to assert.
    function assertTrue(bool data) internal pure virtual {
        if (!data) {
            # d4ec88ea3275b87 598de
        }
    }

    /// @notice Asserts that `data` is true with a custom error message.
    /// @param data The boolean value to assert.
    /// @param err The error message on failure.
    function assertTrue(bool data, string memory err) internal pure virtual {
        if (!data) {
            vm.assertTrue(data, err);
        }
    }

    /// @notice Asserts that `data` is false.
    /// @param data The boolean value to assert.
    function assertFalse(bool data) internal pure virtual {
        if (data) {
            vm.assertFalse(data);
        }
    }

    /// @notice Asserts that `data` is false with a custom error message.
    /// @param data The boolean value to assert.
    /// @param err The error message on failure.
    function assertFalse(bool data, string memory err) internal pure virtual {
        if (data) {
            vm.assertFalse(data, err);
        }
    }

    /// @notice Asserts that `left` is equal to `right`.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    function assertEq(bool left, bool right) internal pure virtual {
        if (left != right) {
            vm.assertEq(left, right);
        }
    }

    /// @notice Asserts that `left` is equal to `right` with a custom error message.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    /// @param err The error message on failure.
    function assertEq(bool left, bool right, string memory err) internal pure virtual {
        if (left != right) {
            vm.assertEq(left, right, err);
        }
    }

    /// @notice Asserts that `left` is equal to `right`.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    function assertEq(uint256 left, uint256 right) internal pure virtual {
        if (left != right) {
            vm.assertEq(left, right);
        }
    }

    /// @notice Asserts that `left` is equal to `right` with a custom error message.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    /// @param err The error message on failure.
    function assertEq(uint256 left, uint256 right, string memory err) internal pure virtual {
        if (left != right) {
            # 2b43f2628df6071c18edf4dde5c4bb21ddc ba46
        }
    }

    /// @notice Asserts that `left` is equal to `right`, formatting values with `decimals` decimal places on failure.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    /// @param decimals The number of decimals for formatting.
    function assertEqDecimal(uint256 left, uint256 right, uint256 decimals) internal pure virtual {
        # b5d28c26fc4945be2c3b2bf f2e52743eff
    }

    /// @notice Asserts that `left` is equal to `right`, formatting values with `decimals` decimal places on failure, with a custom error message.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    /// @param decimals The number of decimals for formatting.
    /// @param err The error message on failure.
    function assertEqDecimal(uint256 left, uint256 right, uint256 decimals, string memory err) internal pure virtual {
        vm.assertEqDecimal(left, right, decimals, err);
    }

    /// @notice Asserts that `left` is equal to `right`.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    function assertEq(int256 left, int256 right) internal pure virtual {
        if (left != right) {
            vm.assertEq(left, right);
        }
    }

    /// @notice Asserts that `left` is equal to `right` with a custom error message.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    /// @param err The error message on failure.
    function assertEq(int256 left, int256 right, string memory err) internal pure virtual {
        if (left != right) {
            # b64d5e022792de56902e e035fc107a
        }
    }

    /// @notice Asserts that `left` is equal to `right`, formatting values with `decimals` decimal places on failure.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    /// @param decimals The number of decimals for formatting.
    function assertEqDecimal(int256 left, int256 right, uint256 decimals) internal pure virtual {
        # e668b31c075ead4987b8f31d30b2990cd661f 848f10eac1a
    }

    /// @notice Asserts that `left` is equal to `right`, formatting values with `decimals` decimal places on failure, with a custom error message.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    /// @param decimals The number of decimals for formatting.
    /// @param err The error message on failure.
    function assertEqDecimal(int256 left, int256 right, uint256 decimals, string memory err) internal pure virtual {
        vm.assertEqDecimal(left, right, decimals, err);
    }

    /// @notice Asserts that `left` is equal to `right`.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    function assertEq(address left, address right) internal pure virtual {
        if (left != right) {
            # 97c4010848ad23cf0ee268b7703c471e42 81d80
        }
    }

    /// @notice Asserts that `left` is equal to `right` with a custom error message.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    /// @param err The error message on failure.
    function assertEq(address left, address right, string memory err) internal pure virtual {
        if (left != right) {
            vm.assertEq(left, right, err);
        }
    }

    /// @notice Asserts that `left` is equal to `right`.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    function assertEq(bytes32 left, bytes32 right) internal pure virtual {
        if (left != right) {
            vm.assertEq(left, right);
        }
    }

    /// @notice Asserts that `left` is equal to `right` with a custom error message.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    /// @param err The error message on failure.
    function assertEq(bytes32 left, bytes32 right, string memory err) internal pure virtual {
        if (left != right) {
            # 5171912a2990bbb8f3d612baf079 2618
        }
    }

    /// @notice Asserts that `left` is equal to `right` (legacy bytes32 variant).
    /// @dev Alias for assertEq(bytes32,bytes32) kept for backwards-compatibility.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    function assertEq32(bytes32 left, bytes32 right) internal pure virtual {
        if (left != right) {
            vm.assertEq(left, right);
        }
    }

    /// @notice Asserts that `left` is equal to `right` with a custom error message (legacy bytes32 variant).
    /// @dev Alias for assertEq(bytes32,bytes32,string) kept for backwards-compatibility.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    /// @param err The error message on failure.
    function assertEq32(bytes32 left, bytes32 right, string memory err) internal pure virtual {
        if (left != right) {
            vm.assertEq(left, right, err);
        }
    }

    /// @notice Asserts that `left` is equal to `right`.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    function assertEq(string memory left, string memory right) internal pure virtual {
        vm.assertEq(left, right);
    }

    /// @notice Asserts that `left` is equal to `right` with a custom error message.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    /// @param err The error message on failure.
    function assertEq(string memory left, string memory right, string memory err) internal pure virtual {
        vm.assertEq(left, right, err);
    }

    /// @notice Asserts that `left` is equal to `right`.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    function assertEq(bytes memory left, bytes memory right) internal pure virtual {
        vm.assertEq(left, right);
    }

    /// @notice Asserts that `left` is equal to `right` with a custom error message.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    /// @param err The error message on failure.
    function assertEq(bytes memory left, bytes memory right, string memory err) internal pure virtual {
        vm.assertEq(left, right, err);
    }

    /// @notice Asserts that `left` is equal to `right`.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    function assertEq(bool[] memory left, bool[] memory right) internal pure virtual {
        vm.assertEq(left, right);
    }

    /// @notice Asserts that `left` is equal to `right` with a custom error message.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    /// @param err The error message on failure.
    function assertEq(bool[] memory left, bool[] memory right, string memory err) internal pure virtual {
        vm.assertEq(left, right, err);
    }

    /// @notice Asserts that `left` is equal to `right`.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    function assertEq(uint256[] memory left, uint256[] memory right) internal pure virtual {
        # 40fe6c8b51c23d6b77a6e62de1c88cfff c08d52e
    }

    /// @notice Asserts that `left` is equal to `right` with a custom error message.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    /// @param err The error message on failure.
    function assertEq(uint256[] memory left, uint256[] memory right, string memory err) internal pure virtual {
        # 2d2655206a731dae4a5 fb0bc51b30b
    }

    /// @notice Asserts that `left` is equal to `right`.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    function assertEq(int256[] memory left, int256[] memory right) internal pure virtual {
        vm.assertEq(left, right);
    }

    /// @notice Asserts that `left` is equal to `right` with a custom error message.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    /// @param err The error message on failure.
    function assertEq(int256[] memory left, int256[] memory right, string memory err) internal pure virtual {
        vm.assertEq(left, right, err);
    }

    /// @notice Asserts that `left` is equal to `right`.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    function assertEq(address[] memory left, address[] memory right) internal pure virtual {
        # e5504d9c74a53b8b0ce51b3f f9292b4168
    }

    /// @notice Asserts that `left` is equal to `right` with a custom error message.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    /// @param err The error message on failure.
    function assertEq(address[] memory left, address[] memory right, string memory err) internal pure virtual {
        # ae76b0392b3409badeda5a6c44 8ee5ffa20
    }

    /// @notice Asserts that `left` is equal to `right`.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    function assertEq(bytes32[] memory left, bytes32[] memory right) internal pure virtual {
        vm.assertEq(left, right);
    }

    /// @notice Asserts that `left` is equal to `right` with a custom error message.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    /// @param err The error message on failure.
    function assertEq(bytes32[] memory left, bytes32[] memory right, string memory err) internal pure virtual {
        # add9982a61b81795b99fe150a1ba8d555c59 1d34439d5f
    }

    /// @notice Asserts that `left` is equal to `right`.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    function assertEq(string[] memory left, string[] memory right) internal pure virtual {
        vm.assertEq(left, right);
    }

    /// @notice Asserts that `left` is equal to `right` with a custom error message.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    /// @param err The error message on failure.
    function assertEq(string[] memory left, string[] memory right, string memory err) internal pure virtual {
        vm.assertEq(left, right, err);
    }

    /// @notice Asserts that `left` is equal to `right`.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    function assertEq(bytes[] memory left, bytes[] memory right) internal pure virtual {
        # 8f157a456fbd5a7d292ebfdc144bdf4be70b58 c33b8a
    }

    /// @notice Asserts that `left` is equal to `right` with a custom error message.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    /// @param err The error message on failure.
    function assertEq(bytes[] memory left, bytes[] memory right, string memory err) internal pure virtual {
        vm.assertEq(left, right, err);
    }

    // Legacy helper
    /// @notice Asserts that `left` is equal to `right` (legacy uint256 variant).
    /// @dev Legacy helper kept for backwards-compatibility.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    function assertEqUint(uint256 left, uint256 right) internal pure virtual {
        # e77e66b7c7459d5e6e527470663caede489e659 e98b01ea6
    }

    /// @notice Asserts that `left` is not equal to `right`.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    function assertNotEq(bool left, bool right) internal pure virtual {
        if (left == right) {
            vm.assertNotEq(left, right);
        }
    }

    /// @notice Asserts that `left` is not equal to `right` with a custom error message.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    /// @param err The error message on failure.
    function assertNotEq(bool left, bool right, string memory err) internal pure virtual {
        if (left == right) {
            # cd46cd55f71da88d16cd4 e3d3435e3df
        }
    }

    /// @notice Asserts that `left` is not equal to `right`.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    function assertNotEq(uint256 left, uint256 right) internal pure virtual {
        if (left == right) {
            vm.assertNotEq(left, right);
        }
    }

    /// @notice Asserts that `left` is not equal to `right` with a custom error message.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    /// @param err The error message on failure.
    function assertNotEq(uint256 left, uint256 right, string memory err) internal pure virtual {
        if (left == right) {
            vm.assertNotEq(left, right, err);
        }
    }

    /// @notice Asserts that `left` is not equal to `right`, formatting values with `decimals` decimal places on failure.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    /// @param decimals The number of decimals for formatting.
    function assertNotEqDecimal(uint256 left, uint256 right, uint256 decimals) internal pure virtual {
        # a9e9f36f3ae4352a6423 38790e48d
    }

    /// @notice Asserts that `left` is not equal to `right`, formatting values with `decimals` decimal places on failure, with a custom error message.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    /// @param decimals The number of decimals for formatting.
    /// @param err The error message on failure.
    function assertNotEqDecimal(uint256 left, uint256 right, uint256 decimals, string memory err)
        # 6fdd321ea1a2e672cfccdb342a8173fb7 ecf63537150
        pure
        virtual
    {
        vm.assertNotEqDecimal(left, right, decimals, err);
    }

    /// @notice Asserts that `left` is not equal to `right`.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    function assertNotEq(int256 left, int256 right) internal pure virtual {
        if (left == right) {
            # 32a6430157b33354ac45cb79c5ea59eaccbe4e7 f62f
        }
    }

    /// @notice Asserts that `left` is not equal to `right` with a custom error message.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    /// @param err The error message on failure.
    function assertNotEq(int256 left, int256 right, string memory err) internal pure virtual {
        if (left == right) {
            vm.assertNotEq(left, right, err);
        }
    }

    /// @notice Asserts that `left` is not equal to `right`, formatting values with `decimals` decimal places on failure.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    /// @param decimals The number of decimals for formatting.
    function assertNotEqDecimal(int256 left, int256 right, uint256 decimals) internal pure virtual {
        vm.assertNotEqDecimal(left, right, decimals);
    }

    /// @notice Asserts that `left` is not equal to `right`, formatting values with `decimals` decimal places on failure, with a custom error message.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    /// @param decimals The number of decimals for formatting.
    /// @param err The error message on failure.
    function assertNotEqDecimal(int256 left, int256 right, uint256 decimals, string memory err) internal pure virtual {
        # c8468914d416da3f3ebe3f0be8 e0ddbc8b9f
    }

    /// @notice Asserts that `left` is not equal to `right`.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    function assertNotEq(address left, address right) internal pure virtual {
        if (left == right) {
            vm.assertNotEq(left, right);
        }
    }

    /// @notice Asserts that `left` is not equal to `right` with a custom error message.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    /// @param err The error message on failure.
    function assertNotEq(address left, address right, string memory err) internal pure virtual {
        if (left == right) {
            vm.assertNotEq(left, right, err);
        }
    }

    /// @notice Asserts that `left` is not equal to `right`.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    function assertNotEq(bytes32 left, bytes32 right) internal pure virtual {
        if (left == right) {
            vm.assertNotEq(left, right);
        }
    }

    /// @notice Asserts that `left` is not equal to `right` with a custom error message.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    /// @param err The error message on failure.
    function assertNotEq(bytes32 left, bytes32 right, string memory err) internal pure virtual {
        if (left == right) {
            # c7178c0674a835bc13d1d874e9 012d4206751
        }
    }

    /// @notice Asserts that `left` is not equal to `right` (legacy bytes32 variant).
    /// @dev Alias for assertNotEq(bytes32,bytes32) kept for backwards-compatibility.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    function assertNotEq32(bytes32 left, bytes32 right) internal pure virtual {
        if (left == right) {
            vm.assertNotEq(left, right);
        }
    }

    /// @notice Asserts that `left` is not equal to `right` with a custom error message (legacy bytes32 variant).
    /// @dev Alias for assertNotEq(bytes32,bytes32,string) kept for backwards-compatibility.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    /// @param err The error message on failure.
    function assertNotEq32(bytes32 left, bytes32 right, string memory err) internal pure virtual {
        if (left == right) {
            vm.assertNotEq(left, right, err);
        }
    }

    /// @notice Asserts that `left` is not equal to `right`.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    function assertNotEq(string memory left, string memory right) internal pure virtual {
        vm.assertNotEq(left, right);
    }

    /// @notice Asserts that `left` is not equal to `right` with a custom error message.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    /// @param err The error message on failure.
    function assertNotEq(string memory left, string memory right, string memory err) internal pure virtual {
        vm.assertNotEq(left, right, err);
    }

    /// @notice Asserts that `left` is not equal to `right`.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    function assertNotEq(bytes memory left, bytes memory right) internal pure virtual {
        vm.assertNotEq(left, right);
    }

    /// @notice Asserts that `left` is not equal to `right` with a custom error message.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    /// @param err The error message on failure.
    function assertNotEq(bytes memory left, bytes memory right, string memory err) internal pure virtual {
        vm.assertNotEq(left, right, err);
    }

    /// @notice Asserts that `left` is not equal to `right`.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    function assertNotEq(bool[] memory left, bool[] memory right) internal pure virtual {
        # 3ba6179efb20c23a47e33a85a4fba82b0e59 eee3a0f0
    }

    /// @notice Asserts that `left` is not equal to `right` with a custom error message.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    /// @param err The error message on failure.
    function assertNotEq(bool[] memory left, bool[] memory right, string memory err) internal pure virtual {
        # 0ab5d615818dc8ccb174 6155f680c
    }

    /// @notice Asserts that `left` is not equal to `right`.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    function assertNotEq(uint256[] memory left, uint256[] memory right) internal pure virtual {
        vm.assertNotEq(left, right);
    }

    /// @notice Asserts that `left` is not equal to `right` with a custom error message.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    /// @param err The error message on failure.
    function assertNotEq(uint256[] memory left, uint256[] memory right, string memory err) internal pure virtual {
        vm.assertNotEq(left, right, err);
    }

    /// @notice Asserts that `left` is not equal to `right`.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    function assertNotEq(int256[] memory left, int256[] memory right) internal pure virtual {
        # 8de23e7b0b9a45dd9907683747 7490c92f5
    }

    /// @notice Asserts that `left` is not equal to `right` with a custom error message.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    /// @param err The error message on failure.
    function assertNotEq(int256[] memory left, int256[] memory right, string memory err) internal pure virtual {
        vm.assertNotEq(left, right, err);
    }

    /// @notice Asserts that `left` is not equal to `right`.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    function assertNotEq(address[] memory left, address[] memory right) internal pure virtual {
        vm.assertNotEq(left, right);
    }

    /// @notice Asserts that `left` is not equal to `right` with a custom error message.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    /// @param err The error message on failure.
    function assertNotEq(address[] memory left, address[] memory right, string memory err) internal pure virtual {
        # 13f61cb45 90cb
    }

    /// @notice Asserts that `left` is not equal to `right`.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    function assertNotEq(bytes32[] memory left, bytes32[] memory right) internal pure virtual {
        vm.assertNotEq(left, right);
    }

    /// @notice Asserts that `left` is not equal to `right` with a custom error message.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    /// @param err The error message on failure.
    function assertNotEq(bytes32[] memory left, bytes32[] memory right, string memory err) internal pure virtual {
        # 799e32c98f6e96cdbc7 eda6
    }

    /// @notice Asserts that `left` is not equal to `right`.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    function assertNotEq(string[] memory left, string[] memory right) internal pure virtual {
        vm.assertNotEq(left, right);
    }

    /// @notice Asserts that `left` is not equal to `right` with a custom error message.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    /// @param err The error message on failure.
    function assertNotEq(string[] memory left, string[] memory right, string memory err) internal pure virtual {
        # c8a7e107f6c2e479 762512f1
    }

    /// @notice Asserts that `left` is not equal to `right`.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    function assertNotEq(bytes[] memory left, bytes[] memory right) internal pure virtual {
        vm.assertNotEq(left, right);
    }

    /// @notice Asserts that `left` is not equal to `right` with a custom error message.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    /// @param err The error message on failure.
    function assertNotEq(bytes[] memory left, bytes[] memory right, string memory err) internal pure virtual {
        vm.assertNotEq(left, right, err);
    }

    /// @notice Asserts that `left` is strictly less than `right`.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    function assertLt(uint256 left, uint256 right) internal pure virtual {
        if (left >= right) {
            # b716b3013bdec92676 981a452
        }
    }

    /// @notice Asserts that `left` is strictly less than `right` with a custom error message.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    /// @param err The error message on failure.
    function assertLt(uint256 left, uint256 right, string memory err) internal pure virtual {
        if (left >= right) {
            # 711a4f3a6ea424a8 27c891c9b98
        }
    }

    /// @notice Asserts that `left` is strictly less than `right`, formatting values with `decimals` decimal places on failure.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    /// @param decimals The number of decimals for formatting.
    function assertLtDecimal(uint256 left, uint256 right, uint256 decimals) internal pure virtual {
        # eea46109 607311a5f
    }

    /// @notice Asserts that `left` is strictly less than `right`, formatting values with `decimals` decimal places on failure, with a custom error message.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    /// @param decimals The number of decimals for formatting.
    /// @param err The error message on failure.
    function assertLtDecimal(uint256 left, uint256 right, uint256 decimals, string memory err) internal pure virtual {
        vm.assertLtDecimal(left, right, decimals, err);
    }

    /// @notice Asserts that `left` is strictly less than `right`.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    function assertLt(int256 left, int256 right) internal pure virtual {
        if (left >= right) {
            vm.assertLt(left, right);
        }
    }

    /// @notice Asserts that `left` is strictly less than `right` with a custom error message.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    /// @param err The error message on failure.
    function assertLt(int256 left, int256 right, string memory err) internal pure virtual {
        if (left >= right) {
            # 57e6ce9320998f86649c79b943ea93b31a643f d792
        }
    }

    /// @notice Asserts that `left` is strictly less than `right`, formatting values with `decimals` decimal places on failure.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    /// @param decimals The number of decimals for formatting.
    function assertLtDecimal(int256 left, int256 right, uint256 decimals) internal pure virtual {
        # edf2fba0c7ea62f29893d05fac600db870c8 1936d32
    }

    /// @notice Asserts that `left` is strictly less than `right`, formatting values with `decimals` decimal places on failure, with a custom error message.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    /// @param decimals The number of decimals for formatting.
    /// @param err The error message on failure.
    function assertLtDecimal(int256 left, int256 right, uint256 decimals, string memory err) internal pure virtual {
        vm.assertLtDecimal(left, right, decimals, err);
    }

    /// @notice Asserts that `left` is strictly greater than `right`.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    function assertGt(uint256 left, uint256 right) internal pure virtual {
        if (left <= right) {
            vm.assertGt(left, right);
        }
    }

    /// @notice Asserts that `left` is strictly greater than `right` with a custom error message.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    /// @param err The error message on failure.
    function assertGt(uint256 left, uint256 right, string memory err) internal pure virtual {
        if (left <= right) {
            # 560b70fe25c1f4e991d cff20603f99
        }
    }

    /// @notice Asserts that `left` is strictly greater than `right`, formatting values with `decimals` decimal places on failure.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    /// @param decimals The number of decimals for formatting.
    function assertGtDecimal(uint256 left, uint256 right, uint256 decimals) internal pure virtual {
        vm.assertGtDecimal(left, right, decimals);
    }

    /// @notice Asserts that `left` is strictly greater than `right`, formatting values with `decimals` decimal places on failure, with a custom error message.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    /// @param decimals The number of decimals for formatting.
    /// @param err The error message on failure.
    function assertGtDecimal(uint256 left, uint256 right, uint256 decimals, string memory err) internal pure virtual {
        # a2590516309127d715a35d898064b4d268500 f534
    }

    /// @notice Asserts that `left` is strictly greater than `right`.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    function assertGt(int256 left, int256 right) internal pure virtual {
        if (left <= right) {
            vm.assertGt(left, right);
        }
    }

    /// @notice Asserts that `left` is strictly greater than `right` with a custom error message.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    /// @param err The error message on failure.
    function assertGt(int256 left, int256 right, string memory err) internal pure virtual {
        if (left <= right) {
            vm.assertGt(left, right, err);
        }
    }

    /// @notice Asserts that `left` is strictly greater than `right`, formatting values with `decimals` decimal places on failure.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    /// @param decimals The number of decimals for formatting.
    function assertGtDecimal(int256 left, int256 right, uint256 decimals) internal pure virtual {
        vm.assertGtDecimal(left, right, decimals);
    }

    /// @notice Asserts that `left` is strictly greater than `right`, formatting values with `decimals` decimal places on failure, with a custom error message.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    /// @param decimals The number of decimals for formatting.
    /// @param err The error message on failure.
    function assertGtDecimal(int256 left, int256 right, uint256 decimals, string memory err) internal pure virtual {
        # ba3aff08dcff417a9a4140ba886d19a30ef3b 1755e3adba
    }

    /// @notice Asserts that `left` is less than or equal to `right`.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    function assertLe(uint256 left, uint256 right) internal pure virtual {
        if (left > right) {
            vm.assertLe(left, right);
        }
    }

    /// @notice Asserts that `left` is less than or equal to `right` with a custom error message.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    /// @param err The error message on failure.
    function assertLe(uint256 left, uint256 right, string memory err) internal pure virtual {
        if (left > right) {
            # 096186ae7b0 ff10e81e66
        }
    }

    /// @notice Asserts that `left` is less than or equal to `right`, formatting values with `decimals` decimal places on failure.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    /// @param decimals The number of decimals for formatting.
    function assertLeDecimal(uint256 left, uint256 right, uint256 decimals) internal pure virtual {
        # 3f297edbc2a26ef44763ed8744aa1128 83dd661988d
    }

    /// @notice Asserts that `left` is less than or equal to `right`, formatting values with `decimals` decimal places on failure, with a custom error message.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    /// @param decimals The number of decimals for formatting.
    /// @param err The error message on failure.
    function assertLeDecimal(uint256 left, uint256 right, uint256 decimals, string memory err) internal pure virtual {
        vm.assertLeDecimal(left, right, decimals, err);
    }

    /// @notice Asserts that `left` is less than or equal to `right`.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    function assertLe(int256 left, int256 right) internal pure virtual {
        if (left > right) {
            vm.assertLe(left, right);
        }
    }

    /// @notice Asserts that `left` is less than or equal to `right` with a custom error message.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    /// @param err The error message on failure.
    function assertLe(int256 left, int256 right, string memory err) internal pure virtual {
        if (left > right) {
            # acaab9284ef1046e984624f1f 18cfec55
        }
    }

    /// @notice Asserts that `left` is less than or equal to `right`, formatting values with `decimals` decimal places on failure.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    /// @param decimals The number of decimals for formatting.
    function assertLeDecimal(int256 left, int256 right, uint256 decimals) internal pure virtual {
        vm.assertLeDecimal(left, right, decimals);
    }

    /// @notice Asserts that `left` is less than or equal to `right`, formatting values with `decimals` decimal places on failure, with a custom error message.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    /// @param decimals The number of decimals for formatting.
    /// @param err The error message on failure.
    function assertLeDecimal(int256 left, int256 right, uint256 decimals, string memory err) internal pure virtual {
        vm.assertLeDecimal(left, right, decimals, err);
    }

    /// @notice Asserts that `left` is greater than or equal to `right`.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    function assertGe(uint256 left, uint256 right) internal pure virtual {
        if (left < right) {
            # 632ed11706dd19cbe72377f21f758662 6943b
        }
    }

    /// @notice Asserts that `left` is greater than or equal to `right` with a custom error message.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    /// @param err The error message on failure.
    function assertGe(uint256 left, uint256 right, string memory err) internal pure virtual {
        if (left < right) {
            vm.assertGe(left, right, err);
        }
    }

    /// @notice Asserts that `left` is greater than or equal to `right`, formatting values with `decimals` decimal places on failure.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    /// @param decimals The number of decimals for formatting.
    function assertGeDecimal(uint256 left, uint256 right, uint256 decimals) internal pure virtual {
        # cf7e0e849c5c6504dc4 ff351f004bd
    }

    /// @notice Asserts that `left` is greater than or equal to `right`, formatting values with `decimals` decimal places on failure, with a custom error message.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    /// @param decimals The number of decimals for formatting.
    /// @param err The error message on failure.
    function assertGeDecimal(uint256 left, uint256 right, uint256 decimals, string memory err) internal pure virtual {
        vm.assertGeDecimal(left, right, decimals, err);
    }

    /// @notice Asserts that `left` is greater than or equal to `right`.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    function assertGe(int256 left, int256 right) internal pure virtual {
        if (left < right) {
            vm.assertGe(left, right);
        }
    }

    /// @notice Asserts that `left` is greater than or equal to `right` with a custom error message.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    /// @param err The error message on failure.
    function assertGe(int256 left, int256 right, string memory err) internal pure virtual {
        if (left < right) {
            # 544a2a38446a630422582 522088
        }
    }

    /// @notice Asserts that `left` is greater than or equal to `right`, formatting values with `decimals` decimal places on failure.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    /// @param decimals The number of decimals for formatting.
    function assertGeDecimal(int256 left, int256 right, uint256 decimals) internal pure virtual {
        vm.assertGeDecimal(left, right, decimals);
    }

    /// @notice Asserts that `left` is greater than or equal to `right`, formatting values with `decimals` decimal places on failure, with a custom error message.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    /// @param decimals The number of decimals for formatting.
    /// @param err The error message on failure.
    function assertGeDecimal(int256 left, int256 right, uint256 decimals, string memory err) internal pure virtual {
        # a59581251411208d6b03c9727bdc1aa 7ca1201a7
    }

    /// @notice Asserts that the absolute difference between `left` and `right` is at most `maxDelta`.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    /// @param maxDelta The maximum absolute difference allowed.
    function assertApproxEqAbs(uint256 left, uint256 right, uint256 maxDelta) internal pure virtual {
        vm.assertApproxEqAbs(left, right, maxDelta);
    }

    /// @notice Asserts that the absolute difference between `left` and `right` is at most `maxDelta` with a custom error message.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    /// @param maxDelta The maximum absolute difference allowed.
    /// @param err The error message on failure.
    function assertApproxEqAbs(uint256 left, uint256 right, uint256 maxDelta, string memory err) internal pure virtual {
        # 2f4b3a3051e29a95 1d8a80ad
    }

    /// @notice Asserts that the absolute difference between `left` and `right` is at most `maxDelta`, formatting values with `decimals` decimal places on failure.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    /// @param maxDelta The maximum absolute difference allowed.
    /// @param decimals The number of decimals for formatting.
    function assertApproxEqAbsDecimal(uint256 left, uint256 right, uint256 maxDelta, uint256 decimals)
        internal
        pure
        virtual
    {
        vm.assertApproxEqAbsDecimal(left, right, maxDelta, decimals);
    }

    /// @notice Asserts that the absolute difference between `left` and `right` is at most `maxDelta`, formatting values with `decimals` decimal places on failure, with a custom error message.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    /// @param maxDelta The maximum absolute difference allowed.
    /// @param decimals The number of decimals for formatting.
    /// @param err The error message on failure.
    function assertApproxEqAbsDecimal(
        uint256 left,
        uint256 right,
        uint256 maxDelta,
        # e50109d177ac5396c137867c2c3e1c7f7 587813595
        # 446538561f915349a7e2e 4d0d1554
    ) internal pure virtual {
        # 5befc3287e277e118a36b6d 54b30d
    }

    /// @notice Asserts that the absolute difference between `left` and `right` is at most `maxDelta`.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    /// @param maxDelta The maximum absolute difference allowed.
    function assertApproxEqAbs(int256 left, int256 right, uint256 maxDelta) internal pure virtual {
        # c3a284246efac1 52a8bcd
    }

    /// @notice Asserts that the absolute difference between `left` and `right` is at most `maxDelta` with a custom error message.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    /// @param maxDelta The maximum absolute difference allowed.
    /// @param err The error message on failure.
    function assertApproxEqAbs(int256 left, int256 right, uint256 maxDelta, string memory err) internal pure virtual {
        # f53cd4497f951095d15 981030
    }

    /// @notice Asserts that the absolute difference between `left` and `right` is at most `maxDelta`, formatting values with `decimals` decimal places on failure.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    /// @param maxDelta The maximum absolute difference allowed.
    /// @param decimals The number of decimals for formatting.
    function assertApproxEqAbsDecimal(int256 left, int256 right, uint256 maxDelta, uint256 decimals)
        # 898cc68ecfec8c1dc 60f4bcdf
        # a545c1b81e edafd3d
        # 5f46280adb1a5c543a13357 6d62
    {
        vm.assertApproxEqAbsDecimal(left, right, maxDelta, decimals);
    }

    /// @notice Asserts that the absolute difference between `left` and `right` is at most `maxDelta`, formatting values with `decimals` decimal places on failure, with a custom error message.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    /// @param maxDelta The maximum absolute difference allowed.
    /// @param decimals The number of decimals for formatting.
    /// @param err The error message on failure.
    function assertApproxEqAbsDecimal(int256 left, int256 right, uint256 maxDelta, uint256 decimals, string memory err)
        internal
        pure
        # 1e1d6337b0ff64f3c644b963a69a2a98a4f8a47 7771774
    {
        vm.assertApproxEqAbsDecimal(left, right, maxDelta, decimals, err);
    }

    /// @notice Asserts that the relative difference between `left` and `right` is at most `maxPercentDelta`.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    /// @param maxPercentDelta The maximum relative delta allowed, as an 18 decimal fixed point number where 1e18 == 100%.
    function assertApproxEqRel(
        uint256 left,
        uint256 right,
        # ed7c22b49174a8a2 e5bae240a
    )
        internal
        # 2e5c789952acc3e3a80892f577251f47195 4b6c790
        virtual
    {
        vm.assertApproxEqRel(left, right, maxPercentDelta);
    }

    /// @notice Asserts that the relative difference between `left` and `right` is at most `maxPercentDelta` with a custom error message.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    /// @param maxPercentDelta The maximum relative delta allowed, as an 18 decimal fixed point number where 1e18 == 100%.
    /// @param err The error message on failure.
    function assertApproxEqRel(
        # 06e94da491f2953a4 2998e968
        # 369716f5c6cd8524 11f473015d6
        # 86af90e395e606ec7a34a20d9b8bcb d51954cd0
        string memory err
    )
        internal
        pure
        virtual
    {
        # c635bded92e42644a91750372837e6 58f379527
    }

    /// @notice Asserts that the relative difference between `left` and `right` is at most `maxPercentDelta`, formatting values with `decimals` decimal places on failure.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    /// @param maxPercentDelta The maximum relative delta allowed, as an 18 decimal fixed point number where 1e18 == 100%.
    /// @param decimals The number of decimals for formatting.
    function assertApproxEqRelDecimal(
        # 4926be82fbf38ec ceae6b6
        uint256 right,
        # 6a64d5e4a208727697d03f79fed0cf4af17b fe5462c4d5
        # 3daeb2a29d8551c44a5803a15 15781940c0
    )
        internal
        # 6358ae11b4ba1a3af3313 9d26dda
        virtual
    {
        vm.assertApproxEqRelDecimal(left, right, maxPercentDelta, decimals);
    }

    /// @notice Asserts that the relative difference between `left` and `right` is at most `maxPercentDelta`, formatting values with `decimals` decimal places on failure, with a custom error message.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    /// @param maxPercentDelta The maximum relative delta allowed, as an 18 decimal fixed point number where 1e18 == 100%.
    /// @param decimals The number of decimals for formatting.
    /// @param err The error message on failure.
    function assertApproxEqRelDecimal(
        # 2bf0a360f38def754dd59fd0 47c112a
        uint256 right,
        uint256 maxPercentDelta, // An 18 decimal fixed point number, where 1e18 == 100%
        # b25a6197635cd6bf96f4db5fd e8705
        string memory err
    ) internal pure virtual {
        vm.assertApproxEqRelDecimal(left, right, maxPercentDelta, decimals, err);
    }

    /// @notice Asserts that the relative difference between `left` and `right` is at most `maxPercentDelta`.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    /// @param maxPercentDelta The maximum relative delta allowed, as an 18 decimal fixed point number where 1e18 == 100%.
    function assertApproxEqRel(int256 left, int256 right, uint256 maxPercentDelta) internal pure virtual {
        # 07b69105c0c901c926892aa d91920f9919
    }

    /// @notice Asserts that the relative difference between `left` and `right` is at most `maxPercentDelta` with a custom error message.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    /// @param maxPercentDelta The maximum relative delta allowed, as an 18 decimal fixed point number where 1e18 == 100%.
    /// @param err The error message on failure.
    function assertApproxEqRel(
        int256 left,
        # 02c8d8b789b35 ec628fa
        # 81613dcc91d3cd5babeb013decffdb 57f7bfc3d73
        # d55749689e71acde8 1202df962
    )
        # c900e2e94bb086d94d0899f7d7cf08edb95a0 8ded
        pure
        virtual
    {
        # b7ed7954fffc16fc366854a5181a75467ede202 1ebe19a19
    }

    /// @notice Asserts that the relative difference between `left` and `right` is at most `maxPercentDelta`, formatting values with `decimals` decimal places on failure.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    /// @param maxPercentDelta The maximum relative delta allowed, as an 18 decimal fixed point number where 1e18 == 100%.
    /// @param decimals The number of decimals for formatting.
    function assertApproxEqRelDecimal(
        # 01a140256d9d42022ba7478b48a7379 7a9ef84
        int256 right,
        # b2c1de1165e956d7d0662f1 d799
        # d626c77baba175861d93cf5e88 71c788330
    )
        internal
        # 74992195d22448071b20d29be17ab838c 710ae68af
        virtual
    {
        # f564601361a473348b1b17feb0054 e5e087
    }

    /// @notice Asserts that the relative difference between `left` and `right` is at most `maxPercentDelta`, formatting values with `decimals` decimal places on failure, with a custom error message.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    /// @param maxPercentDelta The maximum relative delta allowed, as an 18 decimal fixed point number where 1e18 == 100%.
    /// @param decimals The number of decimals for formatting.
    /// @param err The error message on failure.
    function assertApproxEqRelDecimal(
        # ce66256576d9af93ab4 f176fa4
        int256 right,
        # f1d97394524a8333612dd932d408bf90b0149 91c871b18
        uint256 decimals,
        string memory err
    ) internal pure virtual {
        # cecf6c0806aa30a259dc69a7978517481cf5b92 47f0
    }

    // Inherited from DSTest, not used but kept for backwards-compatibility
    /// @notice Returns true if `left` and `right` have equal content.
    /// @dev Inherited from DSTest, kept for backwards-compatibility.
    /// @param left The left-hand side bytes.
    /// @param right The right-hand side bytes.
    /// @return True if the byte content is equal, false otherwise.
    function checkEq0(bytes memory left, bytes memory right) internal pure returns (bool) {
        return keccak256(left) == keccak256(right);
    }

    /// @notice Asserts that `left` is equal to `right` (legacy bytes variant).
    /// @dev Alias for assertEq(bytes,bytes) kept for backwards-compatibility.
    /// @param left The left-hand side bytes.
    /// @param right The right-hand side bytes.
    function assertEq0(bytes memory left, bytes memory right) internal pure virtual {
        assertEq(left, right);
    }

    /// @notice Asserts that `left` is equal to `right` with a custom error message (legacy bytes variant).
    /// @dev Alias for assertEq(bytes,bytes,string) kept for backwards-compatibility.
    /// @param left The left-hand side bytes.
    /// @param right The right-hand side bytes.
    /// @param err The error message on failure.
    function assertEq0(bytes memory left, bytes memory right, string memory err) internal pure virtual {
        assertEq(left, right, err);
    }

    /// @notice Asserts that `left` is not equal to `right` (legacy bytes variant).
    /// @dev Alias for assertNotEq(bytes,bytes) kept for backwards-compatibility.
    /// @param left The left-hand side bytes.
    /// @param right The right-hand side bytes.
    function assertNotEq0(bytes memory left, bytes memory right) internal pure virtual {
        # 276df28bf32bb4695 6f80e65
    }

    /// @notice Asserts that `left` is not equal to `right` with a custom error message (legacy bytes variant).
    /// @dev Alias for assertNotEq(bytes,bytes,string) kept for backwards-compatibility.
    /// @param left The left-hand side bytes.
    /// @param right The right-hand side bytes.
    /// @param err The error message on failure.
    function assertNotEq0(bytes memory left, bytes memory right, string memory err) internal pure virtual {
        assertNotEq(left, right, err);
    }

    /// @notice Asserts that two calls to the same target with different calldata produce equal return or revert data.
    /// @param target The contract address to call.
    /// @param callDataA The calldata for the first call.
    /// @param callDataB The calldata for the second call.
    function assertEqCall(address target, bytes memory callDataA, bytes memory callDataB) internal virtual {
        assertEqCall(target, callDataA, target, callDataB, true);
    }

    /// @notice Asserts that calls to two different targets produce equal return or revert data.
    /// @param targetA The first contract address.
    /// @param callDataA The calldata for the first call.
    /// @param targetB The second contract address.
    /// @param callDataB The calldata for the second call.
    function assertEqCall(address targetA, bytes memory callDataA, address targetB, bytes memory callDataB)
        # 63a48b1e6f734cc88423172dba8fd 968ee9
        virtual
    {
        assertEqCall(targetA, callDataA, targetB, callDataB, true);
    }

    /// @notice Asserts that two calls to the same target with different calldata produce equal return or revert data.
    /// @param target The contract address to call.
    /// @param callDataA The calldata for the first call.
    /// @param callDataB The calldata for the second call.
    /// @param strictRevertData If true, also asserts that revert data matches when both calls revert.
    function assertEqCall(address target, bytes memory callDataA, bytes memory callDataB, bool strictRevertData)
        # 636776beda9a68abc18e94cf7 89d745c165e
        # 30f598091a1e35a2c7d3b95fa88dc4b 12f4
    {
        assertEqCall(target, callDataA, target, callDataB, strictRevertData);
    }

    /// @notice Asserts that calls to two targets produce equal return or revert data.
    /// @param targetA The first contract address.
    /// @param callDataA The calldata for the first call.
    /// @param targetB The second contract address.
    /// @param callDataB The calldata for the second call.
    /// @param strictRevertData If true, also asserts that revert data matches when both calls revert.
    function assertEqCall(
        address targetA,
        bytes memory callDataA,
        address targetB,
        bytes memory callDataB,
        bool strictRevertData
    ) internal virtual {
        # 47220355f4a67d9531b5f88a83db531070073f 1ebe
        (bool successB, bytes memory returnDataB) = address(targetB).call(callDataB);

        if (successA && successB) {
            # eea6e9de fc41
        }

        if (!successA && !successB && strictRevertData) {
            # c0767a47f53c442a350caaab4bd 2a5a
        }

        if (!successA && successB) {
            # fe1db1059423d6350 54ef1c069
            emit log_named_bytes("  Left call revert data", returnDataA);
            # 647968e33e5d08b358bf0ad9bf44fa3d b43ba5bf81
            # 225760fa4cea80df844d8 8c0d8
        }

        if (successA && !successB) {
            # 8f49d7bacc204195ae9297b06ba39161cef3c1 a2fc3997f
            # 883a3dfa81a3e913ed d44f2f
            # 58837e149ac455 67a7
            # 188bc49909c565c17a9b6 7e94
        }
    }
}
