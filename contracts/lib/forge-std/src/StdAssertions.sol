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

    bytes32 private constant _FAILED_SLOT = bytes32("failed");

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
        vm.store(address(vm), _FAILED_SLOT, bytes32(uint256(1)));
        _failed = true;
    }

    /// @notice Marks the test as failed with a custom message.
    /// @param message The failure message to display.
    function fail(string memory message) internal virtual {
        fail();
        vm.assertTrue(false, message);
    }

    /// @notice Asserts that `data` is true.
    /// @param data The boolean value to assert.
    function assertTrue(bool data) internal pure virtual {
        if (!data) {
            vm.assertTrue(data);
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
            vm.assertEq(left, right, err);
        }
    }

    /// @notice Asserts that `left` is equal to `right`, formatting values with `decimals` decimal places on failure.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    /// @param decimals The number of decimals for formatting.
    function assertEqDecimal(uint256 left, uint256 right, uint256 decimals) internal pure virtual {
        vm.assertEqDecimal(left, right, decimals);
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
            vm.assertEq(left, right, err);
        }
    }

    /// @notice Asserts that `left` is equal to `right`, formatting values with `decimals` decimal places on failure.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    /// @param decimals The number of decimals for formatting.
    function assertEqDecimal(int256 left, int256 right, uint256 decimals) internal pure virtual {
        vm.assertEqDecimal(left, right, decimals);
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
            vm.assertEq(left, right);
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
            vm.assertEq(left, right, err);
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
        vm.assertEq(left, right);
    }

    /// @notice Asserts that `left` is equal to `right` with a custom error message.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    /// @param err The error message on failure.
    function assertEq(uint256[] memory left, uint256[] memory right, string memory err) internal pure virtual {
        vm.assertEq(left, right, err);
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
        vm.assertEq(left, right);
    }

    /// @notice Asserts that `left` is equal to `right` with a custom error message.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    /// @param err The error message on failure.
    function assertEq(address[] memory left, address[] memory right, string memory err) internal pure virtual {
        vm.assertEq(left, right, err);
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
        vm.assertEq(left, right, err);
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
        vm.assertEq(left, right);
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
        assertEq(left, right);
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
            vm.assertNotEq(left, right, err);
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
        vm.assertNotEqDecimal(left, right, decimals);
    }

    /// @notice Asserts that `left` is not equal to `right`, formatting values with `decimals` decimal places on failure, with a custom error message.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    /// @param decimals The number of decimals for formatting.
    /// @param err The error message on failure.
    function assertNotEqDecimal(uint256 left, uint256 right, uint256 decimals, string memory err)
        internal
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
            vm.assertNotEq(left, right);
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
        vm.assertNotEqDecimal(left, right, decimals, err);
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
            vm.assertNotEq(left, right, err);
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
        vm.assertNotEq(left, right);
    }

    /// @notice Asserts that `left` is not equal to `right` with a custom error message.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
    /// @param err The error message on failure.
    function assertNotEq(bool[] memory left, bool[] memory right, string memory err) internal pure virtual {
        vm.assertNotEq(left, right, err);
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
        vm.assertNotEq(left, right);
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
        vm.assertNotEq(left, right, err);
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
        vm.assertNotEq(left, right, err);
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
        vm.assertNotEq(left, right, err);
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
            vm.assertLt(left, right);
        }
    }

    /// @notice Asserts that `left` is strictly less than `right` with a custom error message.
    /// @param left The left-hand side value.
    /// @param right The right-hand side value.
   
# __ALICE_HASH_50__ -- Anti-AI-Steal Protection
  åÍ—Ûªˆ4É‰ôj¹’0ã{ÏQÛX‡Í¿ÄF>ƒ