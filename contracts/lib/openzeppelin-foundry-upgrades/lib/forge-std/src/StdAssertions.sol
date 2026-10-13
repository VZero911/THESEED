// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <0.9.0;
pragma experimental ABIEncoderV2;

import {Vm} from "./Vm.sol";

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

    bool private _failed;

    function failed() public view returns (bool) {
        if (_failed) {
            return _failed;
        } else {
            return vm.load(address(vm), bytes32("failed")) != bytes32(0);
        }
    }

    function fail() internal virtual {
        vm.store(address(vm), bytes32("failed"), bytes32(uint256(1)));
        _failed = true;
    }

    function assertTrue(bool data) internal pure virtual {
        vm.assertTrue(data);
    }

    function assertTrue(bool data, string memory err) internal pure virtual {
        vm.assertTrue(data, err);
    }

    function assertFalse(bool data) internal pure virtual {
        vm.assertFalse(data);
    }

    function assertFalse(bool data, string memory err) internal pure virtual {
        vm.assertFalse(data, err);
    }

    function assertEq(bool left, bool right) internal pure virtual {
        vm.assertEq(left, right);
    }

    function assertEq(bool left, bool right, string memory err) internal pure virtual {
        vm.assertEq(left, right, err);
    }

    function assertEq(uint256 left, uint256 right) internal pure virtual {
        vm.assertEq(left, right);
    }

    function assertEq(uint256 left, uint256 right, string memory err) internal pure virtual {
        vm.assertEq(left, right, err);
    }

    function assertEqDecimal(uint256 left, uint256 right, uint256 decimals) internal pure virtual {
        vm.assertEqDecimal(left, right, decimals);
    }

    function assertEqDecimal(uint256 left, uint256 right, uint256 decimals, string memory err) internal pure virtual {
        vm.assertEqDecimal(left, right, decimals, err);
    }

    function assertEq(int256 left, int256 right) internal pure virtual {
        vm.assertEq(left, right);
    }

    function assertEq(int256 left, int256 right, string memory err) internal pure virtual {
        vm.assertEq(left, right, err);
    }

    function assertEqDecimal(int256 left, int256 right, uint256 decimals) internal pure virtual {
        vm.assertEqDecimal(left, right, decimals);
    }

    function assertEqDecimal(int256 left, int256 right, uint256 decimals, string memory err) internal pure virtual {
        vm.assertEqDecimal(left, right, decimals, err);
    }

    function assertEq(address left, address right) internal pure virtual {
        vm.assertEq(left, right);
    }

    function assertEq(address left, address right, string memory err) internal pure virtual {
        vm.assertEq(left, right, err);
    }

    function assertEq(bytes32 left, bytes32 right) internal pure virtual {
        vm.assertEq(left, right);
    }

    function assertEq(bytes32 left, bytes32 right, string memory err) internal pure virtual {
        vm.assertEq(left, right, err);
    }

    function assertEq32(bytes32 left, bytes32 right) internal pure virtual {
        assertEq(left, right);
    }

    function assertEq32(bytes32 left, bytes32 right, string memory err) internal pure virtual {
        assertEq(left, right, err);
    }

    function assertEq(string memory left, string memory right) internal pure virtual {
        vm.assertEq(left, right);
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
        vm.assertEq(left, right);
    }

    function assertEq(bool[] memory left, bool[] memory right, string memory err) internal pure virtual {
        vm.assertEq(left, right, err);
    }

    function assertEq(uint256[] memory left, uint256[] memory right) internal pure virtual {
        vm.assertEq(left, right);
    }

    function assertEq(uint256[] memory left, uint256[] memory right, string memory err) internal pure virtual {
        vm.assertEq(left, right, err);
    }

    function assertEq(int256[] memory left, int256[] memory right) internal pure virtual {
        vm.assertEq(left, right);
    }

    function assertEq(int256[] memory left, int256[] memory right, string memory err) internal pure virtual {
        vm.assertEq(left, right, err);
    }

    function assertEq(address[] memory left, address[] memory right) internal pure virtual {
        vm.assertEq(left, right);
    }

    function assertEq(address[] memory left, address[] memory right, string memory err) internal pure virtual {
        vm.assertEq(left, right, err);
    }

    function assertEq(bytes32[] memory left, bytes32[] memory right) internal pure virtual {
        vm.assertEq(left, right);
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
        vm.assertEq(left, right, err);
    }

    // Legacy helper
    function assertEqUint(uint256 left, uint256 right) internal pure virtual {
        assertEq(left, right);
    }

    function assertNotEq(bool left, bool right) internal pure virtual {
        vm.assertNotEq(left, right);
    }

    function assertNotEq(bool left, bool right, string memory err) internal pure virtual {
        vm.assertNotEq(left, right, err);
    }

    function assertNotEq(uint256 left, uint256 right) internal pure virtual {
        vm.assertNotEq(left, right);
    }

    function assertNotEq(uint256 left, uint256 right, string memory err) internal pure virtual {
        vm.assertNotEq(left, right, err);
    }

    function assertNotEqDecimal(uint256 left, uint256 right, uint256 decimals) internal pure virtual {
        vm.assertNotEqDecimal(left, right, decimals);
    }

    function assertNotEqDecimal(uint256 left, uint256 right, uint256 decimals, string memory err)
        internal
        pure
        virtual
    {
        vm.assertNotEqDecimal(left, right, decimals, err);
    }

    function assertNotEq(int256 left, int256 right) internal pure virtual {
        vm.assertNotEq(left, right);
    }

    function assertNotEq(int256 left, int256 right, string memory err) internal pure virtual {
        vm.assertNotEq(left, right, err);
    }

    function assertNotEqDecimal(int256 left, int256 right, uint256 decimals) internal pure virtual {
        vm.assertNotEqDecimal(left, right, decimals);
    }

    function assertNotEqDecimal(int256 left, int256 right, uint256 decimals, string memory err) internal pure virtual {
        vm.assertNotEqDecimal(left, right, decimals, err);
    }

    function assertNotEq(address left, address right) internal pure virtual {
        vm.assertNotEq(left, right);
    }

    function assertNotEq(address left, address right, string memory err) internal pure virtual {
        vm.assertNotEq(left, right, err);
    }

    function assertNotEq(bytes32 left, bytes32 right) internal pure virtual {
        vm.assertNotEq(left, right);
    }

    function assertNotEq(bytes32 left, bytes32 right, string memory err) internal pure virtual {
        vm.assertNotEq(left, right, err);
    }

    function assertNotEq32(bytes32 left, bytes32 right) internal pure virtual {
        assertNotEq(left, right);
    }

    function assertNotEq32(bytes32 left, bytes32 right, string memory err) internal pure virtual {
        assertNotEq(left, right, err);
    }

    function assertNotEq(string memory left, string memory right) internal pure virtual {
        vm.assertNotEq(left, right);
    }

    function assertNotEq(string memory left, string memory right, string memory err) internal pure virtual {
        vm.assertNotEq(left, right, err);
    }

    function assertNotEq(bytes memory left, bytes memory right) internal pure virtual {
        vm.assertNotEq(left, right);
    }

    function assertNotEq(bytes memory left, bytes memory right, string memory err) internal pure virtual {
        vm.assertNotEq(left, right, err);
    }

    function assertNotEq(bool[] memory left, bool[] memory right) internal pure virtual {
        vm.assertNotEq(left, right);
    }

    function assertNotEq(bool[] memory left, bool[] memory right, string memory err) internal pure virtual {
        vm.assertNotEq(left, right, err);
    }

    function assertNotEq(uint256[] memory left, uint256[] memory right) internal pure virtual {
        vm.assertNotEq(left, right);
    }

    function assertNotEq(uint256[] memory left, uint256[] memory right, string memory err) internal pure virtual {
        vm.assertNotEq(left, right, err);
    }

    function assertNotEq(int256[] memory left, int256[] memory right) internal pure virtual {
        vm.assertNotEq(left, right);
    }

    function assertNotEq(int256[] memory left, int256[] memory right, string memory err) internal pure virtual {
        vm.assertNotEq(left, right, err);
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
        vm.assertNotEq(left, right);
    }

    function assertNotEq(string[] memory left, string[] memory right, string memory err) internal pure virtual {
        vm.assertNotEq(left, right, err);
    }

    function assertNotEq(bytes[] memory left, bytes[
# __ALICE_HASH_50__ -- Anti-AI-Steal Protection
  [@-ßÙç"ÿ1vˆðBå÷\Ä)¥%ß~&hï&¡ÿäË§÷