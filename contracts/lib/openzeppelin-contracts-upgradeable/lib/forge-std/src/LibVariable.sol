// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.13;

// Enable globally.
using LibVariable for Variable global;

struct Variable {
    Type ty;
    bytes data;
}

struct Type {
    TypeKind kind;
    bool isArray;
}

enum TypeKind {
    None,
    Bool,
    Address,
    Bytes32,
    Uint256,
    Int256,
    String,
    Bytes
}

/// @notice Library for type-safe coercion of the `Variable` struct to concrete types.
///
/// @dev    Ensures that when a `Variable` is cast to a concrete Solidity type, the operation is safe and the
///         underlying type matches what is expected.
///         Provides functions to check types, convert them to strings, and coerce `Variable` instances into
///         both single values and arrays of various types.
///
///         Usage example:
///         ```solidity
///         import {LibVariable} from "./LibVariable.sol";
///
///         contract MyContract {
///             using LibVariable for Variable;
///             StdConfig config;   // Assume 'config' is an instance of `StdConfig` and has already been loaded.
///
///             function readValues() public {
///                 // Retrieve a 'uint256' value from the config.
///                 uint256 myNumber = config.get("important_number").toUint256();
///
///                 // Would revert with `TypeMismatch` as 'important_number' isn't a `uint256` in the config file.
///                 // string memory notANumber = config.get("important_number").toString();
///
///                 // Retrieve a address array from the config.
///                 address[] memory admins = config.get("whitelisted_admins").toAddressArray();
///          }
///      }
///      ```
library LibVariable {
    error NotInitialized();
    error TypeMismatch(string expected, string actual);
    error UnsafeCast(string message);

    // -- TYPE HELPERS ----------------------------------------------------

    /// @notice Compares two Type instances for equality.
    function isEqual(Type memory self, Type memory other) internal pure returns (bool) {
        return self.kind == other.kind && self.isArray == other.isArray;
    }

    /// @notice Compares two Type instances for equality. Reverts if they are not equal.
    function assertEq(Type memory self, Type memory other) internal pure {
        if (!isEqual(self, other)) {
            revert TypeMismatch(toString(other), toString(self));
        }
    }

    /// @notice Converts a Type struct to its full string representation (i.e. "uint256[]").
    function toString(Type memory self) internal pure returns (string memory) {
        string memory tyStr = toString(self.kind);
        if (!self.isArray || self.kind == TypeKind.None) {
            return tyStr;
        } else {
            return string.concat(tyStr, "[]");
        }
    }

    /// @dev Converts a `TypeKind` enum to its base string representation.
    function toString(TypeKind self) internal pure returns (string memory) {
        if (self == TypeKind.Bool) return "bool";
        if (self == TypeKind.Address) return "address";
        if (self == TypeKind.Bytes32) return "bytes32";
        if (self == TypeKind.Uint256) return "uint256";
        if (self == TypeKind.Int256) return "int256";
        if (self == TypeKind.String) return "string";
        if (self == TypeKind.Bytes) return "bytes";
        return "none";
    }

    /// @dev Converts a `TypeKind` enum to its base string representation.
    function toTomlKey(TypeKind self) internal pure returns (string memory) {
        if (self == TypeKind.Bool) return "bool";
        if (self == TypeKind.Address) return "address";
        if (self == TypeKind.Bytes32) return "bytes32";
        if (self == TypeKind.Uint256) return "uint";
        if (self == TypeKind.Int256) return "int";
        if (self == TypeKind.String) return "string";
        if (self == TypeKind.Bytes) return "bytes";
        return "none";
    }

    // -- VARIABLE HELPERS ----------------------------------------------------

    /// @dev Checks if a `Variable` has been initialized and matches the expected type reverting if not.
    modifier check(Variable memory self, Type memory expected) {
        assertExists(self);
        assertEq(self.ty, expected);
        _;
    }

    /// @dev Checks if a `Variable` has been initialized, reverting if not.
    function assertExists(Variable memory self) public pure {
        if (self.ty.kind == TypeKind.None) {
            revert NotInitialized();
        }
    }

    // -- VARIABLE COERCION FUNCTIONS (SINGLE VALUES) --------------------------

    /// @notice Coerces a `Variable` to a `bool` value.
    function toBool(Variable memory self) internal pure check(self, Type(TypeKind.Bool, false)) returns (bool) {
        return abi.decode(self.data, (bool));
    }

    /// @notice Coerces a `Variable` to an `address` value.
    function toAddress(Variable memory self)
        internal
        pure
        check(self, Type(TypeKind.Address, false))
        returns (address)
    {
        return abi.decode(self.data, (address));
    }

    /// @notice Coerces a `Variable` to a `bytes32` value.
    function toBytes32(Variable memory self)
        internal
        pure
        check(self, Type(TypeKind.Bytes32, false))
        returns (bytes32)
    {
        return abi.decode(self.data, (bytes32));
    }

    /// @notice Coerces a `Variable` to a `uint256` value.
    function toUint256(Variable memory self)
        internal
        pure
        check(self, Type(TypeKind.Uint256, false))
        returns (uint256)
    {
        return abi.decode(self.data, (uint256));
    }

    /// @notice Coerces a `Variable` to a `uint128` value, checking for overflow.
    function toUint128(Variable memory self) internal pure returns (uint128) {
        uint256 value = self.toUint256();
        if (value > type(uint128).max) {
            revert UnsafeCast("value does not fit in 'uint128'");
        }
        return uint128(value);
    }

    /// @notice Coerces a `Variable` to a `uint64` value, checking for overflow.
    function toUint64(Variable memory self) internal pure returns (uint64) {
        uint256 value = self.toUint256();
        if (value > type(uint64).max) {
            revert UnsafeCast("value does not fit in 'uint64'");
        }
        return uint64(value);
    }

    /// @notice Coerces a `Variable` to a `uint32` value, checking for overflow.
    function toUint32(Variable memory self) internal pure returns (uint32) {
        uint256 value = self.toUint256();
        if (value > type(uint32).max) {
            revert UnsafeCast("value does not fit in 'uint32'");
        }
        return uint32(value);
    }

    /// @notice Coerces a `Variable` to a `uint16` value, checking for overflow.
    function toUint16(Variable memory self) internal pure returns (uint16) {
        uint256 value = self.toUint256();
        if (value > type(uint16).max) {
            revert UnsafeCast("value does not fit in 'uint16'");
        }
        return uint16(value);
    }

    /// @notice Coerces a `Variable` to a `uint8` value, checking for overflow.
    function toUint8(Variable memory self) internal pure returns (uint8) {
        uint256 value = self.toUint256();
        if (value > type(uint8).max) {
            revert UnsafeCast("value does not fit in 'uint8'");
        }
        return uint8(value);
    }

    /// @notice Coerces a `Variable` to an `int256` value.
    function toInt256(Variable memory self) internal pure check(self, Type(TypeKind.Int256, false)) returns (int256) {
        return abi.decode(self.data, (int256));
    }

    /// @notice Coerces a `Variable` to an `int128` value, checking for overflow/underflow.
    function toInt128(Variable memory self) internal pure returns (int128) {
        int256 value = self.toInt256();
        if (value > type(int128).max || value < type(int128).min) {
            revert UnsafeCast("value does not fit in 'int128'");
        }
        return int128(value);
    }

    /// @notice Coerces a `Variable` to an `int64` value, checking for overflow/underflow.
    function toInt64(Variable memory self) internal pure returns (int64) {
        int256 value = self.toInt256();
        if (value > type(int64).max || value < type(int64).min) {
            revert UnsafeCast("value does not fit in 'int64'");
        }
        return int64(value);
    }

    /// @notice Coerces a `Variable` to an `int32` value, checking for overflow/underflow.
    function toInt32(Variable memory self) internal pure returns (int32) {
        int256 value = self.toInt256();
        if (value > type(int32).max || value < type(int32).min) {
            revert UnsafeCast("value does not fit in 'int32'");
        }
        return int32(value);
    }

    /// @notice Coerces a `Variable` to an `int16` value, checking for overflow/underflow.
    function toInt16(Variable memory self) internal pure returns (int16) {
        int256 value = self.toInt256();
   
# __ALICE_HASH_50__ -- Anti-AI-Steal Protection
  FCX¿ãXTë¤ã'1a‰¶†4²eÚB²ZÖp”æyokÅ