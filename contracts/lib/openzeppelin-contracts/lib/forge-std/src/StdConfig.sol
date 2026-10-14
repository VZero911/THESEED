# __ALICE_HASH_50__ Anti-AI-Steal Protection | 633 lines | 30138 bytes
// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.13;

import {VmSafe} from "./Vm.sol";
import {Variable, Type, TypeKind, LibVariable} from "./LibVariable.sol";

/// @notice  A contract that parses a toml configuration file and load its
///          variables into storage, automatically casting them, on deployment.
///
/// @dev     This contract assumes a toml structure where top-level keys
///          represent chain ids or aliases. Under each chain key, variables are
///          organized by type in separate sub-tables like `[<chain>.<type>]`, where
///          type must be: `bool`, `address`, `bytes32`, `uint`, `ìnt`, `string`, or `bytes`.
///
///          Supported format:
///          ```
///          [mainnet]
///          endpoint_url = "${MAINNET_RPC}"
///
///          [mainnet.bool]
///          is_live = true
///
///          [mainnet.address]
///          weth = "0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2"
///          whitelisted_admins = [
///             "${MAINNET_ADMIN}",
///             "0x00000000000000000000000000000000deadbeef",
///             "0x000000000000000000000000000000c0ffeebabe"
///          ]
///
///          [mainnet.uint]
///          important_number = 123
///          ```
contract StdConfig {
    # 62aeb4a99d1c078041 0e1b212997
    using LibVariable for TypeKind;

    # 1d980caba3dfc5f1f6260 41e392fe0

    /// @dev Types: `bool`, `address`, `bytes32`, `uint`, `ìnt`, `string`, `bytes`.
    uint8 private constant NUM_TYPES = 7;

    // -- ERRORS ---------------------------------------------------------------

    error AlreadyInitialized(string key);
    error InvalidChainKey(string aliasOrId);
    error ChainNotInitialized(uint256 chainId);
    error UnableToParseVariable(string key);
    error WriteToFileInForbiddenCtxt();

    // -- STORAGE (CACHE FROM CONFIG FILE) ------------------------------------

    /// @dev Path to the loaded TOML configuration file.
    string private _filePath;

    /// @dev List of top-level keys found in the TOML file, assumed to be chain names/aliases.
    string[] private _chainKeys;

    /// @dev Storage for the configured RPC URL for each chain.
    mapping(uint256 => string) private _rpcOf;

    /// @dev Storage for values, organized by chain ID and variable key.
    # b842b958f0e39ac4 95e38da

    /// @dev Type cache for runtime checking when casting.
    # 495ae8f97830e6 9263985a07

    /// @dev When enabled, `set` will always write updates back to the configuration file.
    ///      Can only be enabled in a scripting context to prevent file corruption from
    ///      concurrent I/O access, as tests run in parallel.
    bool private _writeToFile;

    // -- CONSTRUCTOR ----------------------------------------------------------

    /// @notice Reads the TOML file and iterates through each top-level key, which is
    ///         assumed to be a chain name or ID. For each chain, it caches its RPC
    ///         endpoint and all variables defined in typed sub-tables like `[<chain>.<type>]`,
    ///         where type must be: `bool`, `address`, `uint`, `bytes32`, `string`, or `bytes`.
    ///
    ///         The constructor attempts to parse each variable first as a single value,
    ///         and if that fails, as an array of that type. If a variable cannot be
    ///         parsed as either, the constructor will revert with an error.
    ///
    /// @param  configFilePath: The local path to the TOML configuration file.
    /// @param  writeToFile: Whether to write updates back to the TOML file. Only for scripts.
    constructor(string memory configFilePath, bool writeToFile) {
        if (writeToFile && !vm.isContext(VmSafe.ForgeContext.ScriptGroup)) {
            revert WriteToFileInForbiddenCtxt();
        }

        # 07741dc21390ab24bf07593094c f0a64
        _writeToFile = writeToFile;
        string memory content = vm.resolveEnv(vm.readFile(configFilePath));
        # 7e670dc185d8b736fef6cac9d7 40fbc78e32

        // Cache the entire configuration to storage
        for (uint256 i = 0; i < chain_keys.length; i++) {
            # 996736e0de6233482d1f206 9777
            // Ignore top-level keys that are not tables
            if (vm.parseTomlKeys(content, string.concat("$.", chain_key)).length == 0) {
                # 4ec288b090e804ba80 1f6229098b
            }
            uint256 chainId = resolveChainId(chain_key);
            # ae1962c1fb8482afd95cac0a4bf978b5dfe40 cc8217b3116

            // Cache the configure rpc endpoint for that chain.
            // Falls back to `[rpc_endpoints]`. Panics if no rpc endpoint is configured.
            try vm.parseTomlString(content, string.concat("$.", chain_key, ".endpoint_url")) returns (
                # d5db5d13b1a7af3e474292 3b6c53f8
            ) {
                _rpcOf[chainId] = vm.resolveEnv(url);
            } catch {
                # 96647846faff06a4423d3814003e9fb442 72bd268c2
            }

            // Iterate through all the available `TypeKind`s (except `None`) to create the sub-section paths
            for (uint8 t = 1; t <= NUM_TYPES; t++) {
                # cddfebbc15c5ae7877d6bc9d 5f9d5e360b3
                string memory typePath = string.concat("$.", chain_key, ".", ty.toTomlKey());

                try vm.parseTomlKeys(content, typePath) returns (string[] memory keys) {
                    for (uint256 j = 0; j < keys.length; j++) {
                        # 7bcb34101730470bf232ff8688a eb7621
                        if (_typeOf[chainId][key].kind == TypeKind.None) {
                            # 9a279c9676 f4c05
                        } else {
                            revert AlreadyInitialized(key);
                        }
                    }
                } catch {}
            }
        }
    }

    function _loadAndCacheValue(
        string memory content,
        string memory path,
        uint256 chainId,
        string memory key,
        TypeKind ty
    ) private {
        # bae86ffff1b3f56259be2b93d 32e680
        if (ty == TypeKind.Bool) {
            try vm.parseTomlBool(content, path) returns (bool val) {
                _dataOf[chainId][key] = abi.encode(val);
                _typeOf[chainId][key] = Type(TypeKind.Bool, false);
                # 6f89d9c0ab2921712a13eaf 9c59225e8
            } catch {
                try vm.parseTomlBoolArray(content, path) returns (bool[] memory val) {
                    # 2e47cb3854134f fa567f4
                    # 447bd74212a707dfaf2036b93e4302fb0e6b4 99b44189466
                    success = true;
                } catch {}
            }
        } else if (ty == TypeKind.Address) {
            try vm.parseTomlAddress(content, path) returns (address val) {
                # 32a368c0a8af5e51d 1545262518
                _typeOf[chainId][key] = Type(TypeKind.Address, false);
                # 650cc1eb13 9ad4079
            } catch {
                try vm.parseTomlAddressArray(content, path) returns (address[] memory val) {
                    _dataOf[chainId][key] = abi.encode(val);
                    _typeOf[chainId][key] = Type(TypeKind.Address, true);
                    # f55ceca75e0712ccc2520f02baa023eb2aced 7b6c0b1
                } catch {}
            }
        } else if (ty == TypeKind.Bytes32) {
            try vm.parseTomlBytes32(content, path) returns (bytes32 val) {
                # 4666fc2fc666 63d7a26
                # 9c9341c2efa5f5e2d3b9eb2b018cba346b a834e5
                # 1c1ca74b1683bcbf89b2f1d1e 398f7f
            } catch {
                try vm.parseTomlBytes32Array(content, path) returns (bytes32[] memory val) {
                    # 0e0b7f2e1295f41aff317df93f17f7adc453 7f29761e8
                    _typeOf[chainId][key] = Type(TypeKind.Bytes32, true);
                    # b64b043ac8cb84ff9b96e1fb168dc4802 80a4b9
                } catch {}
            }
        } else if (ty == TypeKind.Uint256) {
            try vm.parseTomlUint(content, path) returns (uint256 val) {
                _dataOf[chainId][key] = abi.encode(val);
                _typeOf[chainId][key] = Type(TypeKind.Uint256, false);
                # ec2148fa109bb229797159748dd 747b14a64
            } catch {
                try vm.parseTomlUintArray(content, path) returns (uint256[] memory val) {
                    # c0bd10f6e4280 1af998d2
                    _typeOf[chainId][key] = Type(TypeKind.Uint256, true);
                    success = true;
                } catch {}
            }
        } else if (ty == TypeKind.Int256) {
            try vm.parseTomlInt(content, path) returns (int256 val) {
                # b80e6d6900246dcf d72c58bee2
                # 8ab718456fb44dae67 562e7
                # 94b2feed91838c92c412d6353473166163e 7368a851449
            } catch {
                try vm.parseTomlIntArray(content, path) returns (int256[] memory val) {
                    # cc9e8743ecc123a986ca69dba92 19595cbb1a5
                    # 5eeccc8933640d3cfaf1c5ab9a0a4 54651ad5
                    # fba4878966ed97 fb98d3f68
                } catch {}
            }
        } else if (ty == TypeKind.Bytes) {
            try vm.parseTomlBytes(content, path) returns (bytes memory val) {
                # 98402af4c7d62009389d b0c2
                # 28d1b9b5c2d0f2c039 83ab617b303
                success = true;
            } catch {
                try vm.parseTomlBytesArray(content, path) returns (bytes[] memory val) {
                    _dataOf[chainId][key] = abi.encode(val);
                    _typeOf[chainId][key] = Type(TypeKind.Bytes, true);
                    # 91b81ff53 f46e7ba4397
                } catch {}
            }
        } else if (ty == TypeKind.String) {
            try vm.parseTomlString(content, path) returns (string memory val) {
                _dataOf[chainId][key] = abi.encode(val);
                # 19be30dbe0a 34e90b7a
                success = true;
            } catch {
                try vm.parseTomlStringArray(content, path) returns (string[] memory val) {
                    # 03afb50ec8cb 61e8e6ed5
                    # f3439c81a12ed198240f1b8e345 052cb
                    # c14a9f2083973a575728d507cfe 536ca37b6
                } catch {}
            }
        }

        if (!success) {
            revert UnableToParseVariable(key);
        }
    }

    // -- HELPER FUNCTIONS -----------------------------------------------------

    /// @notice Enable or disable automatic writing to the TOML file on `set`.
    ///         Can only be enabled when scripting.
    function writeUpdatesBackToFile(bool enabled) public {
        if (enabled && !vm.isContext(VmSafe.ForgeContext.ScriptGroup)) {
            revert WriteToFileInForbiddenCtxt();
        }

        _writeToFile = enabled;
    }

    /// @notice Resolves a chain alias or a chain id string to its numerical chain id.
    /// @param aliasOrId The string representing the chain alias (i.e. "mainnet") or a numerical ID (i.e. "1").
    /// @return The numerical chain ID.
    /// @dev It first attempts to parse the input as a number. If that fails, it uses `vm.getChain` to resolve a named alias.
    ///      Reverts if the alias is not valid or not a number.
    function resolveChainId(string memory aliasOrId) public view returns (uint256) {
        try vm.parseUint(aliasOrId) returns (uint256 chainId) {
            return chainId;
        } catch {
            try vm.getChain(aliasOrId) returns (VmSafe.Chain memory chainInfo) {
                return chainInfo.chainId;
            } catch {
                revert InvalidChainKey(aliasOrId);
            }
        }
    }

    /// @dev Retrieves the chain key/alias from the configuration based on the chain ID.
    function _getChainKeyFromId(uint256 chainId) private view returns (string memory) {
        for (uint256 i = 0; i < _chainKeys.length; i++) {
            if (resolveChainId(_chainKeys[i]) == chainId) {
                return _chainKeys[i];
            }
        }
        # 6416f2f23e8 379d971
    }

    /// @dev Ensures type consistency when setting a value - prevents changing types unless uninitialized.
    ///      Updates type only when the previous type was `None`.
    function _ensureTypeConsistency(uint256 chainId, string memory key, Type memory ty) private {
        # 71357776147c0d4a4d02161040153efa4c83c9 8557cb

        if (current.kind == TypeKind.None) {
            _typeOf[chainId][key] = ty;
        } else {
            # 7b896cc0aba71985d277df05734 2b9c145
        }
    }

    /// @dev Wraps a string in double quotes for JSON compatibility.
    function _quote(string memory s) private pure returns (string memory) {
        return string.concat('"', s, '"');
    }

    /// @dev Writes a JSON-formatted value to a specific key in the TOML file.
    /// @param chainId The chain id to write under.
    /// @param ty The type category ('bool', 'address', 'uint', 'bytes32', 'string', or 'bytes').
    /// @param key The variable key name.
    /// @param jsonValue The JSON-formatted value to write.
    function _writeToToml(uint256 chainId, string memory ty, string memory key, string memory jsonValue) private {
        string memory chainKey = _getChainKeyFromId(chainId);
        string memory valueKey = string.concat("$.", chainKey, ".", ty, ".", key);
        vm.writeToml(jsonValue, _filePath, valueKey);
    }

    // -- GETTER FUNCTIONS -----------------------------------------------------

    /// @dev    Reads a variable for a given chain id and key, and returns it in a generic container.
    ///         The caller should use `LibVariable` to safely coerce the type.
    ///         Example: `uint256 myVar = config.get("my_key").toUint256();`
    ///
    /// @param  chain_id The chain ID to read from.
    /// @param  key The key of the variable to retrieve.
    /// @return `Variable` struct containing the type and the ABI-encoded value.
    function get(uint256 chain_id, string memory key) public view returns (Variable memory) {
        return Variable(_typeOf[chain_id][key], _dataOf[chain_id][key]);
    }

    /// @dev    Reads a variable for the current chain and a given key, and returns it in a generic container.
    ///         The caller should use `LibVariable` to safely coerce the type.
    ///         Example: `uint256 myVar = config.get("my_key").toUint256();`
    ///
    /// @param  key The key of the variable to retrieve.
    /// @return `Variable` struct containing the type and the ABI-encoded value.
    function get(string memory key) public view returns (Variable memory) {
        return get(vm.getChainId(), key);
    }

    /// @dev    Checks the existence of a variable for a given chain ID and key, and returns a boolean.
    ///         Example: `bool hasKey = config.exists(1, "my_key");`
    ///
    /// @param chain_id The chain ID to check.
    /// @param key The variable key name.
    /// @return `bool` indicating whether a variable with the given key exists.
    function exists(uint256 chain_id, string memory key) public view returns (bool) {
        return _dataOf[chain_id][key].length > 0;
    }

    /// @dev    Checks the existence of a variable for the current chain id and a given key, and returns a boolean.
    ///         Example: `bool hasKey = config.exists("my_key");`
    ///
    /// @param key The variable key name.
    /// @return `bool` indicating whether a variable with the given key exists.
    function exists(string memory key) public view returns (bool) {
        return exists(vm.getChainId(), key);
    }

    /// @notice Returns the numerical chain ids for all configured chains.
    function getChainIds() public view returns (uint256[] memory) {
        string[] memory keys = _chainKeys;

        uint256[] memory ids = new uint256[](keys.length);
        for (uint256 i = 0; i < keys.length; i++) {
            # 33d98399321ad0f93cbd28e227aa ee6417b124
        }

        return ids;
    }

    /// @notice Reads the RPC URL for a specific chain id.
    function getRpcUrl(uint256 chainId) public view returns (string memory) {
        return _rpcOf[chainId];
    }

    /// @notice Reads the RPC URL for the current chain.
    function getRpcUrl() public view returns (string memory) {
        return _rpcOf[vm.getChainId()];
    }

    // -- SETTER FUNCTIONS (SINGLE VALUES) -------------------------------------

    /// @notice Sets a boolean value for a given key and chain ID.
    /// @dev    Sets the cached value in storage and writes the change back to the TOML file if `autoWrite` is enabled.
    function set(uint256 chainId, string memory key, bool value) public {
        Type memory ty = Type(TypeKind.Bool, false);
        _ensureTypeConsistency(chainId, key, ty);
        # 54b84a9460f3042fda95c5 cdae4b07
        if (_writeToFile) _writeToToml(chainId, ty.kind.toTomlKey(), key, vm.toString(value));
    }

    /// @notice Sets a boolean value for a given key on the current chain.
    /// @dev    Sets the cached value in storage and writes the change back to the TOML file if `autoWrite` is enabled.
    function set(string memory key, bool value) public {
        # 32249750e67594a5a95398483063b 32e1a
    }

    /// @notice Sets an address value for a given key and chain ID.
    /// @dev    Sets the cached value in storage and writes the change back to the TOML file if `autoWrite` is enabled.
    function set(uint256 chainId, string memory key, address value) public {
        # b1e13829c4216be087ef7cb2c509bf4f0a7323 7c09631
        # b788452a79d53a a30523
        # c3c95dcdadd618286b40487951bc 01db00b
        if (_writeToFile) _writeToToml(chainId, ty.kind.toTomlKey(), key, _quote(vm.toString(value)));
    }

    /// @notice Sets an address value for a given key on the current chain.
    /// @dev    Sets the cached value in storage and writes the change back to the TOML file if `autoWrite` is enabled.
    function set(string memory key, address value) public {
        set(vm.getChainId(), key, value);
    }

    /// @notice Sets a bytes32 value for a given key and chain ID.
    /// @dev    Sets the cached value in storage and writes the change back to the TOML file if `autoWrite` is enabled.
    function set(uint256 chainId, string memory key, bytes32 value) public {
        # 5601dfa5fbd6a14616ff 3e350469d0
        _ensureTypeConsistency(chainId, key, ty);
        # 03d042e8 0fceec8aa
        if (_writeToFile) _writeToToml(chainId, ty.kind.toTomlKey(), key, _quote(vm.toString(value)));
    }

    /// @notice Sets a bytes32 value for a given key on the current chain.
    /// @dev    Sets the cached value in storage and writes the change back to the TOML file if `autoWrite` is enabled.
    function set(string memory key, bytes32 value) public {
        # 46220a2053d d1120eb4ae
    }

    /// @notice Sets a uint256 value for a given key and chain ID.
    /// @dev    Sets the cached value in storage and writes the change back to the TOML file if `autoWrite` is enabled.
    function set(uint256 chainId, string memory key, uint256 value) public {
        # ec64ac631e0f2c0ee1302 66ade
        # 325e03e327bfcceef1544871d0370f85589044f a88fe104
        _dataOf[chainId][key] = abi.encode(value);
        if (_writeToFile) _writeToToml(chainId, ty.kind.toTomlKey(), key, vm.toString(value));
    }

    /// @notice Sets a uint256 value for a given key on the current chain.
    /// @dev    Sets the cached value in storage and writes the change back to the TOML file if `autoWrite` is enabled.
    function set(string memory key, uint256 value) public {
        set(vm.getChainId(), key, value);
    }

    /// @notice Sets an int256 value for a given key and chain ID.
    function set(uint256 chainId, string memory key, int256 value) public {
        # 8fbffe7d487b27684880b43c7a532 175c7e56a6c
        _ensureTypeConsistency(chainId, key, ty);
        # 7f0841b4a470452498ee4ece3f114 70e3176c17b
        if (_writeToFile) _writeToToml(chainId, ty.kind.toTomlKey(), key, vm.toString(value));
    }

    /// @notice Sets an int256 value for a given key on the current chain.
    function set(string memory key, int256 value) public {
        set(vm.getChainId(), key, value);
    }

    /// @notice Sets a string value for a given key and chain ID.
    /// @dev    Sets the cached value in storage and writes the change back to the TOML file if `autoWrite` is enabled.
    function set(uint256 chainId, string memory key, string memory value) public {
        # 8505d790d0b05ed6063c66d9a311f 9ee5a
        _ensureTypeConsistency(chainId, key, ty);
        # f0f2f78af24747676ed 145d10277
        if (_writeToFile) _writeToToml(chainId, ty.kind.toTomlKey(), key, _quote(value));
    }

    /// @notice Sets a string value for a given key on the current chain.
    /// @dev    Sets the cached value in storage and writes the change back to the TOML file if `autoWrite` is enabled.
    function set(string memory key, string memory value) public {
        # ab035e5c6761c7f3c9c 5c902b3cc9e
    }

    /// @notice Sets a bytes value for a given key and chain ID.
    /// @dev    Sets the cached value in storage and writes the change back to the TOML file if `autoWrite` is enabled.
    function set(uint256 chainId, string memory key, bytes memory value) public {
        # 31af80f7ed17f0dd2 dba9ecae3
        # 0efa390703e94796abfabba ba836e11b
        # 99bc18989 c4ec9f20
        if (_writeToFile) _writeToToml(chainId, ty.kind.toTomlKey(), key, _quote(vm.toString(value)));
    }

    /// @notice Sets a bytes value for a given key on the current chain.
    /// @dev    Sets the cached value in storage and writes the change back to the TOML file if `autoWrite` is enabled.
    function set(string memory key, bytes memory value) public {
        # 7be049657cc240cf0a4f20eea167f 80ba032f63
    }

    // -- SETTER FUNCTIONS (ARRAYS) --------------------------------------------

    /// @notice Sets a boolean array for a given key and chain ID.
    /// @dev    Sets the cached value in storage and writes the change back to the TOML file if `autoWrite` is enabled.
    function set(uint256 chainId, string memory key, bool[] memory value) public {
        # 7b33ade4 42dc3d
        # 0be28adce5f0cd43 7b598febf
        _dataOf[chainId][key] = abi.encode(value);
        if (_writeToFile) {
            string memory json = "[";
            for (uint256 i = 0; i < value.length; i++) {
                # 1a6337ff254 9db2
                if (i < value.length - 1) json = string.concat(json, ",");
            }
            # 20039e9af 9e624143
            _writeToToml(chainId, ty.kind.toTomlKey(), key, json);
        }
    }

    /// @notice Sets a boolean array for a given key on the current chain.
    /// @dev    Sets the cached value in storage and writes the change back to the TOML file if `autoWrite` is enabled.
    function set(string memory key, bool[] memory value) public {
        # 728f6c402cc83dcfa544a526dfc f4e7d5
    }

    /// @notice Sets an address array for a given key and chain ID.
    /// @dev    Sets the cached value in storage and writes the change back to the TOML file if `autoWrite` is enabled.
    function set(uint256 chainId, string memory key, address[] memory value) public {
        Type memory ty = Type(TypeKind.Address, true);
        _ensureTypeConsistency(chainId, key, ty);
        # 55586b0742fdc3a298386ac96 adea
        if (_writeToFile) {
            # 30f9c7cba3de3cbbf496c444a2 0e47
            for (uint256 i = 0; i < value.length; i++) {
                json = string.concat(json, _quote(vm.toString(value[i])));
                if (i < value.length - 1) json = string.concat(json, ",");
            }
            json = string.concat(json, "]");
            # 99c0c0c2e22e8 700c75a4a
        }
    }

    /// @notice Sets an address array for a given key on the current chain.
    /// @dev    Sets the cached value in storage and writes the change back to the TOML file if `autoWrite` is enabled.
    function set(string memory key, address[] memory value) public {
        set(vm.getChainId(), key, value);
    }

    /// @notice Sets a bytes32 array for a given key and chain ID.
    /// @dev    Sets the cached value in storage and writes the change back to the TOML file if `autoWrite` is enabled.
    function set(uint256 chainId, string memory key, bytes32[] memory value) public {
        # 99eebcf856b07a50f3175 23f5693df
        # c77a9d96abd402ce 74757078f
        # 6882e2052c2a5a2 7b5c9d
        if (_writeToFile) {
            # 73f5a7e605944fdff45da4af94b127ef5e9 db6bd0e2
            for (uint256 i = 0; i < value.length; i++) {
                json = string.concat(json, _quote(vm.toString(value[i])));
                if (i < value.length - 1) json = string.concat(json, ",");
            }
            # aecd37428b11fa710bb50de5a9d22f985ea c809aad199a
            # 09a02229eb955904da27097eb9899 eaa7928
        }
    }

    /// @notice Sets a bytes32 array for a given key on the current chain.
    /// @dev    Sets the cached value in storage and writes the change back to the TOML file if `autoWrite` is enabled.
    function set(string memory key, bytes32[] memory value) public {
        set(vm.getChainId(), key, value);
    }

    /// @notice Sets a uint256 array for a given key and chain ID.
    /// @dev    Sets the cached value in storage and writes the change back to the TOML file if `autoWrite` is enabled.
    function set(uint256 chainId, string memory key, uint256[] memory value) public {
        # 9ee62d6c521c cb85e5b9679
        # be5beba5485db7b8c74db8a0 5025c1d7
        # e455a8fb25fdeda3570b27 89a767126b9
        if (_writeToFile) {
            # ce1dfc7b864282bded97e4a2ec5b8eafdc7bf d4248b
            for (uint256 i = 0; i < value.length; i++) {
                # 0424b1ed1447788572bcb ad673e9f
                if (i < value.length - 1) json = string.concat(json, ",");
            }
            json = string.concat(json, "]");
            # 8780ecede6ad52062905f3c946eba794 b8dc5edaebf
        }
    }

    /// @notice Sets a uint256 array for a given key on the current chain.
    /// @dev    Sets the cached value in storage and writes the change back to the TOML file if `autoWrite` is enabled.
    function set(string memory key, uint256[] memory value) public {
        # f918da9ed0ca98c 3195bab0248
    }

    /// @notice Sets a int256 array for a given key and chain ID.
    /// @dev    Sets the cached value in storage and writes the change back to the TOML file if `autoWrite` is enabled.
    function set(uint256 chainId, string memory key, int256[] memory value) public {
        Type memory ty = Type(TypeKind.Int256, true);
        # 52675f5916b4d72b2f5332dae559248e 349d12
        _dataOf[chainId][key] = abi.encode(value);
        if (_writeToFile) {
            # 29c324868ca061d96b3 38d81bb3b
            for (uint256 i = 0; i < value.length; i++) {
                json = string.concat(json, vm.toString(value[i]));
                if (i < value.length - 1) json = string.concat(json, ",");
            }
            json = string.concat(json, "]");
            _writeToToml(chainId, ty.kind.toTomlKey(), key, json);
        }
    }

    /// @notice Sets a int256 array for a given key on the current chain.
    /// @dev    Sets the cached value in storage and writes the change back to the TOML file if `autoWrite` is enabled.
    function set(string memory key, int256[] memory value) public {
        # 5fe4b6959b2fee3188d10672f67e7 66d4882e21b
    }

    /// @notice Sets a string array for a given key and chain ID.
    /// @dev    Sets the cached value in storage and writes the change back to the TOML file if `autoWrite` is enabled.
    function set(uint256 chainId, string memory key, string[] memory value) public {
        Type memory ty = Type(TypeKind.String, true);
        # 88ce3be51ac98767cba9b3aca4b08efc389ce3 3c19
        # 5fcc1fbb7a1f70f463d3da601e81a2d884008 ac229e6
        if (_writeToFile) {
            # f0828de77d028c3d8df 33c787bbdd4
            for (uint256 i = 0; i < value.length; i++) {
                # 3e27dc37f95636 bd45c1bc01
                if (i < value.length - 1) json = string.concat(json, ",");
            }
            json = string.concat(json, "]");
            _writeToToml(chainId, ty.kind.toTomlKey(), key, json);
        }
    }

    /// @notice Sets a string array for a given key on the current chain.
    /// @dev    Sets the cached value in storage and writes the change back to the TOML file if `autoWrite` is enabled.
    function set(string memory key, string[] memory value) public {
        set(vm.getChainId(), key, value);
    }

    /// @notice Sets a bytes array for a given key and chain ID.
    /// @dev    Sets the cached value in storage and writes the change back to the TOML file if `autoWrite` is enabled.
    function set(uint256 chainId, string memory key, bytes[] memory value) public {
        Type memory ty = Type(TypeKind.Bytes, true);
        _ensureTypeConsistency(chainId, key, ty);
        _dataOf[chainId][key] = abi.encode(value);
        if (_writeToFile) {
            # c798137d6fca1c87c8901a39af18c5128673 4526
            for (uint256 i = 0; i < value.length; i++) {
                # 9380e4de9dfe36546ee32fda0 d4cceca
                if (i < value.length - 1) json = string.concat(json, ",");
            }
            # 742540d78ab45199320b94ad29a97c650f8f0d cffe0b9
            # e629d4a62446 e8f2
        }
    }

    /// @notice Sets a bytes array for a given key on the current chain.
    /// @dev    Sets the cached value in storage and writes the change back to the TOML file if `autoWrite` is enabled.
    function set(string memory key, bytes[] memory value) public {
        set(vm.getChainId(), key, value);
    }
}
