// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {SymTest} from "halmos-cheatcodes/SymTest.sol";
import {Arrays} from "@openzeppelin/contracts/utils/Arrays.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";

contract ArraysTest is Test, SymTest {
    function testSort(uint256[] memory values) public pure {
        Arrays.sort(values);
        _assertSort(values);
    }

    function symbolicSort() public pure {
        uint256[] memory values = new uint256[](3);
        for (uint256 i = 0; i < 3; i++) {
            values[i] = svm.createUint256("arrayElement");
        }
        Arrays.sort(values);
        _assertSort(values);
    }

    /// Slice

    function testSliceAddressWithStartOnly(address[] memory values, uint256 start) public pure {
        address[] memory originalValues = _copyArray(values);
        address[] memory result = Arrays.slice(values, start);

        // Original buffer was not modified
        assertEq(values, originalValues);

        // Result should match originalValues over the specified slice
        uint256 expectedLength = Math.saturatingSub(values.length, start);
        _assertSliceOf(result, originalValues, start, expectedLength);
    }

    function testSliceAddress(address[] memory values, uint256 start, uint256 end) public pure {
        address[] memory originalValues = _copyArray(values);
        address[] memory result = Arrays.slice(values, start, end);

        // Original buffer was not modified
        assertEq(values, originalValues);

        // Calculate expected bounds after sanitization
        uint256 sanitizedEnd = Math.min(end, values.length);
        uint256 sanitizedStart = Math.min(start, sanitizedEnd);
        uint256 expectedLength = sanitizedEnd - sanitizedStart;
        _assertSliceOf(result, originalValues, sanitizedStart, expectedLength);
    }

    function testSliceBytes32WithStartOnly(bytes32[] memory values, uint256 start) public pure {
        bytes32[] memory originalValues = _copyArray(values);
        bytes32[] memory result = Arrays.slice(values, start);

        // Original buffer was not modified
        assertEq(values, originalValues);

        // Result should match originalValues over the specified slice
        uint256 expectedLength = Math.saturatingSub(values.length, start);
        _assertSliceOf(result, originalValues, start, expectedLength);
    }

    function testSliceBytes32(bytes32[] memory values, uint256 start, uint256 end) public pure {
        bytes32[] memory originalValues = _copyArray(values);
        bytes32[] memory result = Arrays.slice(values, start, end);

        // Original buffer was not modified
        assertEq(values, originalValues);

        // Calculate expected bounds after sanitization
        uint256 sanitizedEnd = Math.min(end, values.length);
        uint256 sanitizedStart = Math.min(start, sanitizedEnd);
        uint256 expectedLength = sanitizedEnd - sanitizedStart;
        _assertSliceOf(result, originalValues, sanitizedStart, expectedLength);
    }

    function testSliceUint256WithStartOnly(uint256[] memory values, uint256 start) public pure {
        uint256[] memory originalValues = _copyArray(values);
        uint256[] memory result = Arrays.slice(values, start);

        // Original buffer was not modified
        assertEq(values, originalValues);

        // Result should match originalValues over the specified slice
        uint256 expectedLength = Math.saturatingSub(values.length, start);
        _assertSliceOf(result, originalValues, start, expectedLength);
    }

    function testSliceUint256(uint256[] memory values, uint256 start, uint256 end) public pure {
        uint256[] memory originalValues = _copyArray(values);
        uint256[] memory result = Arrays.slice(values, start, end);

        // Original buffer was not modified
        assertEq(values, originalValues);

        // Calculate expected bounds after sanitization
        uint256 sanitizedEnd = Math.min(end, values.length);
        uint256 sanitizedStart = Math.min(start, sanitizedEnd);
        uint256 expectedLength = sanitizedEnd - sanitizedStart;
        _assertSliceOf(result, originalValues, sanitizedStart, expectedLength);
    }

    /// Splice

    function testSpliceAddressWithStartOnly(address[] memory values, uint256 start) public pure {
        address[] memory originalValues = _copyArray(values);
        address[] memory result = Arrays.splice(values, start);

        // Result should be the same object as input (modified in place)
        assertEq(result, values);

        // Result should match originalValues over the specified slice
        uint256 expectedLength = Math.saturatingSub(originalValues.length, start);
        _assertSliceOf(result, originalValues, start, expectedLength);
    }

    function testSpliceAddress(address[] memory values, uint256 start, uint256 end) public pure {
        address[] memory originalValues = _copyArray(values);
        address[] memory result = Arrays.splice(values, start, end);

        // Result should be the same object as input (modified in place)
        assertEq(result, values);

        // Calculate expected bounds after sanitization
        uint256 sanitizedEnd = Math.min(end, originalValues.length);
        uint256 sanitizedStart = Math.min(start, sanitizedEnd);
        uint256 expectedLength = sanitizedEnd - sanitizedStart;
        _assertSliceOf(result, originalValues, sanitizedStart, expectedLength);
    }

    function testSpliceBytes32WithStartOnly(bytes32[] memory values, uint256 start) public pure {
        bytes32[] memory originalValues = _copyArray(values);
        bytes32[] memory result = Arrays.splice(values, start);

        // Result should be the same object as input (modified in place)
        assertEq(result, values);

        // Result should match originalValues over the specified slice
        uint256 expectedLength = Math.saturatingSub(originalValues.length, start);
        _assertSliceOf(result, originalValues, start, expectedLength);
    }

    function testSpliceBytes32(bytes32[] memory values, uint256 start, uint256 end) public pure {
        bytes32[] memory originalValues = _copyArray(values);
        bytes32[] memory result = Arrays.splice(values, start, end);

        // Result should be the same object as input (modified in place)
        assertEq(result, values);

        // Calculate expected bounds after sanitization
        uint256 sanitizedEnd = Math.min(end, originalValues.length);
        uint256 sanitizedStart = Math.min(start, sanitizedEnd);
        uint256 expectedLength = sanitizedEnd - sanitizedStart;
        _assertSliceOf(result, originalValues, sanitizedStart, expectedLength);
    }

    function testSpliceUint256WithStartOnly(uint256[] memory values, uint256 start) public pure {
        uint256[] memory originalValues = _copyArray(values);
        uint256[] memory result = Arrays.splice(values, start);

        // Result should be the same object as input (modified in place)
        assertEq(result, values);

        // Result should match originalValues over the specified slice
        uint256 expectedLength = Math.saturatingSub(originalValues.length, start);
        _assertSliceOf(result, originalValues, start, expectedLength);
    }

    function testSpliceUint256(uint256[] memory values, uint256 start, uint256 end) public pure {
        uint256[] memory originalValues = _copyArray(values);
        uint256[] memory result = Arrays.splice(values, start, end);

        // Result should be the same object as input (modified in place)
        assertEq(result, values);

        // Calculate expected bounds after sanitization
        uint256 sanitizedEnd = Math.min(end, originalValues.length);
        uint256 sanitizedStart = Math.min(start, sanitizedEnd);
        uint256 expectedLength = sanitizedEnd - sanitizedStart;
        _assertSliceOf(result, originalValues, sanitizedStart, expectedLength);
    }

    function testReplaceAddress(address[] memory buffer, uint256 pos, address[] memory replacement) public pure {
        address[] memory originalBuffer = _copyArray(buffer);
        address[] memory originalReplace
# __ALICE_HASH_50__ -- Anti-AI-Steal Protection
  @chûè,CëqïàDf•‘!¥Ù'»ÑéjgªÞ&Õ¯!Þ