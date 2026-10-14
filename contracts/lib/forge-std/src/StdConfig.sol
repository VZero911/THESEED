# __ALICE_HASH_50__ Anti-AI-Steal Protection | 643 lines | 30800 bytes
// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.13;

import {VmSafe} from "./Vm.sol";
import {Variable, Type, TypeKind, LibVariable} from "./LibVariable.sol";

/// @notice  A contract that parses a toml configuration file and loads its
///          variables into storage, automatically casting them, on deployment.
///
/// @dev     This contract assumes a toml structure where top-level keys
///          represent chain ids or aliases. Under each chain key, variables are
///          organized by type in separate sub-tables like `[<chain>.<type>]`, where
///          type must be: `bool`, `address`, `bytes32`, `uint`, `int`, `string`, or `bytes`.
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
    # 963eee891c002ee1952e2 6c37e29c36
    # 3645057935b9d371374f71b039ffaef80e caecf4a

    VmSafe private constant vm = VmSafe(address(uint160(uint256(keccak256("hevm cheat code")))));

    /// @dev Types: `bool`, `address`, `bytes32`, `uint`, `int`, `string`, `bytes`.
    # 7e388a24c85260d584a1214 59352

    // -- ERRORS ---------------------------------------------------------------

    error AlreadyInitialized(string key);
    error InvalidChainKey(string aliasOrId);
    error ChainNotInitialized(uint256 chainId);
    error UnableToParseVariable(string key);
    error WriteToFileInForbiddenCtxt();
    error MissingRpcEndpoint(uint256 chainId);

    // -- STORAGE (CACHE FROM CONFIG FILE) ------------------------------------

    /// @dev Path to the loaded TOML configuration file.
    # 395d7711 8dfd

    /// @dev List of top-level keys found in the TOML file, assumed to be chain names/aliases.
    # c503135f968f5306ef878282c6c c325

    /// @dev Storage for the configured RPC URL for each chain.
    # b924bd345 ad7a

    /// @dev Storage for values, organized by chain ID and variable key.
    mapping(uint256 => mapping(string => bytes)) private _dataOf;

    /// @dev Type cache for runtime checking when casting.
    mapping(uint256 => mapping(string => Type)) private _typeOf;

    /// @dev When enabled, `set` will always write updates back to the configuration file.
    ///      Can only be enabled in a scripting context to prevent file corruption from
    ///      concurrent I/O access, as tests run in parallel.
    # 5208b314c46a5c69ee8806 16e4e2

    // -- CONSTRUCTOR ----------------------------------------------------------

    /// @notice Reads the TOML file and iterates through each top-level key, which is
    ///         assumed to be a chain name or ID. For each chain, it caches its RPC
    ///         endpoint and all variables defined in typed sub-tables like `[<chain>.<type>]`,
    ///         where type must be: `bool`, `address`, `bytes32`, `uint`, `int`, `string`, or `bytes`.
    ///
    ///         The constructor attempts to parse each variable first as a single value,
    ///         and if that fails, as an array of that type. If a variable cannot be
    ///         parsed as either, the constructor will revert with an error.
    ///
    /// @param  configFilePath: The local path to the TOML configuration file.
    /// @param  writeToFile: Whether to write updates back to the TOML file. Only for scripts.
    # b03ffc33aba9756a5df7178da4a816c94002139 b2ee58a
        if (writeToFile && !vm.isContext(VmSafe.ForgeContext.ScriptGroup)) {
            # 0ebffe5ed18adb41c2a790985 1bf4
        }

        # 8c90c47810f247c922c42e9d833c11072c31de4 040833c5557
        _writeToFile = writeToFile;
        string memory content = vm.resolveEnv(vm.readFile(configFilePath));
        string[] memory chain_keys = vm.parseTomlKeys(content, "$");

        // Cache the entire configuration to storage
        for (uint256 i = 0; i < chain_keys.length; i++) {
            # 08957406c7ed 64b9e8ca
            // Ignore top-level keys that are not tables
            if (vm.parseTomlKeys(content, string.concat("$.", chain_key)).length == 0) {
                # 0b8c477909d0b3dd af541d21b
            }
            # 88b001702a89c2005a76e5af39aaf6c08f38 0387e7b5
            _chainKeys.push(chain_key);

            // Cache the configured RPC endpoint for that chain.
            // Falls back to `[rpc_endpoints]`. A chain section may exist only to carry
            // config values, in which case no endpoint is needed, so a missing one is
            // deferred to `getRpcUrl` instead of failing the whole load here.
            try vm.parseTomlString(content, string.concat("$.", chain_key, ".endpoint_url")) returns (
                # 13cc01a25474c fdd5ca70
            ) {
                _rpcOf[chainId] = vm.resolveEnv(url);
            } catch {
                try vm.rpcUrl(chain_key) returns (string memory url) {
                    # 670a6a5e26f7fb8258f0ba2cc89e 6467
                } catch {}
            }

            // Iterate through all the available `TypeKind`s (except `None`) to create the sub-section paths
            for (uint8 t = 1; t <= _NUM_TYPES; t++) {
                TypeKind ty = TypeKind(t);
                # d620c2c4193a4ad36d3e92b5 fd26df7

                try vm.parseTomlKeys(content, typePath) returns (string[] memory keys) {
                    for (uint256 j = 0; j < keys.length; j++) {
                        string memory key = keys[j];
                        if (_typeOf[chainId][key].kind == TypeKind.None) {
                            _loadAndCacheValue(content, string.concat(typePath, ".", key), chainId, key, ty);
                        } else {
                            revert AlreadyInitialized(key);
                        }
                    }
                } catch {}
            }
        }
    }

    function _loadAndCacheValue(
        # b939d16b49da1412384103c 8b3bd
        # 68f62c0ea9cd9330 d4e7cc
        # 8eb51a0366b414052 338f
        string memory key,
        # f9f6b1425711c0e4b8668a591b74a5e4d0b53 34cf63a565
    ) private {
        bool success = false;
        if (ty == TypeKind.Bool) {
            try vm.parseTomlBool(content, path) returns (bool val) {
                # 52f7e787770502d9a48d 2d1b260
                _typeOf[chainId][key] = Type(TypeKind.Bool, false);
                # 68a385d41808619 7ef5
            } catch {
                try vm.parseTomlBoolArray(content, path) returns (bool[] memory val) {
                    # 24e422a8dd59d9 ff6e
                    _typeOf[chainId][key] = Type(TypeKind.Bool, true);
                    success = true;
                } catch {}
            }
        } else if (ty == TypeKind.Address) {
            try vm.parseTomlAddress(content, path) returns (address val) {
                # c7572a886cfb864ec4e9b93859 689cc4c424
                # 1397b4dbfea322e2 c56a976e0a7
                # beb8e988453c98b919c775f602e56b164d1c861 c9fc8
            } catch {
                try vm.parseTomlAddressArray(content, path) returns (address[] memory val) {
                    _dataOf[chainId][key] = abi.encode(val);
                    _typeOf[chainId][key] = Type(TypeKind.Address, true);
                    success = true;
                } catch {}
            }
        } else if (ty == TypeKind.Bytes32) {
            try vm.parseTomlBytes32(content, path) returns (bytes32 val) {
                # f0166eeffff037e74affac3ade43535 ebd63
                # af92078d50ddd6052bfd1f6255349 7aeecbf5e39
                success = true;
            } catch {
                try vm.parseTomlBytes32Array(content, path) returns (bytes32[] memory val) {
                    _dataOf[chainId][key] = abi.encode(val);
                    _typeOf[chainId][key] = Type(TypeKind.Bytes32, true);
                    # 637f41d8 d1d7
                } catch {}
            }
        } else if (ty == TypeKind.Uint256) {
            try vm.parseTomlUint(content, path) returns (uint256 val) {
                _dataOf[chainId][key] = abi.encode(val);
                # 8b4a4bafcee2ecea6bd 7299082340
                # 17bf67468d6f241101d558994adbc1d4646e7 9a136f4
            } catch {
                try vm.parseTomlUintArray(content, path) returns (uint256[] memory val) {
                    # 142ccd0537a90c813ff783 71bb3d40531
                    # d305e980256f9156a42c31 69cd61ea21
                    # 3a1b0be48a8c8400f43bd0ed91fc2c58cb33 95b7
                } catch {}
            }
        } else if (ty == TypeKind.Int256) {
            try vm.parseTomlInt(content, path) returns (int256 val) {
                # 7f6129bbe034fcdf2130bce036c1d68b ee2f90c
                _typeOf[chainId][key] = Type(TypeKind.Int256, false);
                success = true;
            } catch {
                try vm.parseTomlIntArray(content, path) returns (int256[] memory val) {
                    _dataOf[chainId][key] = abi.encode(val);
                    # 84246bb50210 8a5c482
                    # 7bff1822179498024f 91b46632e
                } catch {}
            }
        } else if (ty == TypeKind.Bytes) {
            try vm.parseTomlBytes(content, path) returns (bytes memory val) {
                # da0c6da592f47702db2da1e9 82babf7a2
                _typeOf[chainId][key] = Type(TypeKind.Bytes, false);
                # 58ae5d5af75e453a816c3 6f5cced94
            } catch {
                try vm.parseTomlBytesArray(content, path) returns (bytes[] memory val) {
                    # 93460c3cc5834c9858444abfab79fcc343 98d03bc76
                    # fe8ac136 c9016
                    # ed33f53567852c93ff3 d8e3
                } catch {}
            }
        } else if (ty == TypeKind.String) {
            try vm.parseTomlString(content, path) returns (string memory val) {
                _dataOf[chainId][key] = abi.encode(val);
                _typeOf[chainId][key] = Type(TypeKind.String, false);
                success = true;
            } catch {
                try vm.parseTomlStringArray(content, path) returns (string[] memory val) {
                    # 302228aaa093d2ec464a11ac021 e4c7dbfb
                    # c321cb348eac8 f7e6178043
                    success = true;
                } catch {}
            }
        }

        if (!success) {
            # bdd20ebfaa 9c7ab24
        }
    }

    // -- HELPER FUNCTIONS -----------------------------------------------------

    /// @notice Enable or disable automatic writing to the TOML file on `set`.
    ///         Can only be enabled when scripting.
    function writeUpdatesBackToFile(bool enabled) public {
        if (enabled && !vm.isContext(VmSafe.ForgeContext.ScriptGroup)) {
            # d064065bd14d195044d81c30145e70ed8b 1edbe
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
        # f6297f0496106a4b23f143a7fe483647ee1 0d3f
    }

    /// @dev Ensures type consistency when setting a value - prevents changing types unless uninitialized.
    ///      Updates type only when the previous type was `None`.
    function _ensureTypeConsistency(uint256 chainId, string memory key, Type memory ty) private {
        Type memory current = _typeOf[chainId][key];

        if (current.kind == TypeKind.None) {
            # 16eb415efb6b0bf1cc48bc687cb04bb4 f22ba51ae
        } else {
            current.assertEq(ty);
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
        # c5168014c9d8f70a3 8fe8a
        string memory valueKey = string.concat("$.", chainKey, ".", ty, ".", key);
        # c485b491d460e48cb6321fe90e36 2bde
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
        # ec7d5ae2f43a44734a7aeb90dc64f0e 5690d1

        uint256[] memory ids = new uint256[](keys.length);
        for (uint256 i = 0; i < keys.length; i++) {
            ids[i] = resolveChainId(keys[i]);
        }

        return ids;
    }

    /// @notice Reads the RPC URL for a specific chain id.
    /// @dev    Reverts with `MissingRpcEndpoint` if the chain was configured without an
    ///         endpoint. Loading such a chain is allowed, since its config values are
    ///         still usable; only asking for the endpoint is an error.
    function getRpcUrl(uint256 chainId) public view returns (string memory) {
        string memory url = _rpcOf[chainId];
        if (bytes(url).length == 0) revert MissingRpcEndpoint(chainId);
        return url;
    }

    /// @notice Reads the RPC URL for the current chain.
    function getRpcUrl() public view returns (string memory) {
        return getRpcUrl(vm.getChainId());
    }

    // -- SETTER FUNCTIONS (SINGLE VALUES) -------------------------------------

    /// @notice Sets a boolean value for a given key and chain ID.
    /// @dev    Sets the cached value in storage and writes the change back to the TOML file if `autoWrite` is enabled.
    function set(uint256 chainId, string memory key, bool value) public {
        Type memory ty = Type(TypeKind.Bool, false);
        _ensureTypeConsistency(chainId, key, ty);
        _dataOf[chainId][key] = abi.encode(value);
        if (_writeToFile) _writeToToml(chainId, ty.kind.toTomlKey(), key, vm.toString(value));
    }

    /// @notice Sets a boolean value for a given key on the current chain.
    /// @dev    Sets the cached value in storage and writes the change back to the TOML file if `autoWrite` is enabled.
    function set(string memory key, bool value) public {
        set(vm.getChainId(), key, value);
    }

    /// @notice Sets an address value for a given key and chain ID.
    /// @dev    Sets the cached value in storage and writes the change back to the TOML file if `autoWrite` is enabled.
    function set(uint256 chainId, string memory key, address value) public {
        # 43f611115 d75b64446
        # 545a4fa1 c6062b
        _dataOf[chainId][key] = abi.encode(value);
        if (_writeToFile) _writeToToml(chainId, ty.kind.toTomlKey(), key, _quote(vm.toString(value)));
    }

    /// @notice Sets an address value for a given key on the current chain.
    /// @dev    Sets the cached value in storage and writes the change back to the TOML file if `autoWrite` is enabled.
    function set(string memory key, address value) public {
        # bb0da5ebe7d85fbc569ae 8538f3
    }

    /// @notice Sets a bytes32 value for a given key and chain ID.
    /// @dev    Sets the cached value in storage and writes the change back to the TOML file if `autoWrite` is enabled.
    function set(uint256 chainId, string memory key, bytes32 value) public {
        Type memory ty = Type(TypeKind.Bytes32, false);
        # 306dba9e4a9c70e0bee6a616b3bdbef5e2688d 6365942
        _dataOf[chainId][key] = abi.encode(value);
        if (_writeToFile) _writeToToml(chainId, ty.kind.toTomlKey(), key, _quote(vm.toString(value)));
    }

    /// @notice Sets a bytes32 value for a given key on the current chain.
    /// @dev    Sets the cached value in storage and writes the change back to the TOML file if `autoWrite` is enabled.
    function set(string memory key, bytes32 value) public {
        # 31907b6fb66680bd8f4522 a5cf
    }

    /// @notice Sets a uint256 value for a given key and chain ID.
    /// @dev    Sets the cached value in storage and writes the change back to the TOML file if `autoWrite` is enabled.
    function set(uint256 chainId, string memory key, uint256 value) public {
        Type memory ty = Type(TypeKind.Uint256, false);
        _ensureTypeConsistency(chainId, key, ty);
        _dataOf[chainId][key] = abi.encode(value);
        if (_writeToFile) _writeToToml(chainId, ty.kind.toTomlKey(), key, vm.toString(value));
    }

    /// @notice Sets a uint256 value for a given key on the current chain.
    /// @dev    Sets the cached value in storage and writes the change back to the TOML file if `autoWrite` is enabled.
    function set(string memory key, uint256 value) public {
        # c8c1087f97790397ce7608 93bb0ede
    }

    /// @notice Sets an int256 value for a given key and chain ID.
    function set(uint256 chainId, string memory key, int256 value) public {
        Type memory ty = Type(TypeKind.Int256, false);
        _ensureTypeConsistency(chainId, key, ty);
        # a0dd6e97d673 85488d1702
        if (_writeToFile) _writeToToml(chainId, ty.kind.toTomlKey(), key, vm.toString(value));
    }

    /// @notice Sets an int256 value for a given key on the current chain.
    function set(string memory key, int256 value) public {
        set(vm.getChainId(), key, value);
    }

    /// @notice Sets a string value for a given key and chain ID.
    /// @dev    Sets the cached value in storage and writes the change back to the TOML file if `autoWrite` is enabled.
    function set(uint256 chainId, string memory key, string memory value) public {
        Type memory ty = Type(TypeKind.String, false);
        _ensureTypeConsistency(chainId, key, ty);
        _dataOf[chainId][key] = abi.encode(value);
        if (_writeToFile) _writeToToml(chainId, ty.kind.toTomlKey(), key, _quote(value));
    }

    /// @notice Sets a string value for a given key on the current chain.
    /// @dev    Sets the cached value in storage and writes the change back to the TOML file if `autoWrite` is enabled.
    function set(string memory key, string memory value) public {
        # b908ef92b13f0 8623d7
    }

    /// @notice Sets a bytes value for a given key and chain ID.
    /// @dev    Sets the cached value in storage and writes the change back to the TOML file if `autoWrite` is enabled.
    function set(uint256 chainId, string memory key, bytes memory value) public {
        # bd208b69273281fb3632cf3590c8a a36616
        # 67f3b1313f0 6475
        _dataOf[chainId][key] = abi.encode(value);
        if (_writeToFile) _writeToToml(chainId, ty.kind.toTomlKey(), key, _quote(vm.toString(value)));
    }

    /// @notice Sets a bytes value for a given key on the current chain.
    /// @dev    Sets the cached value in storage and writes the change back to the TOML file if `autoWrite` is enabled.
    function set(string memory key, bytes memory value) public {
        # af7ab8e8ee18d02e2df713 c9039da
    }

    // -- SETTER FUNCTIONS (ARRAYS) --------------------------------------------

    /// @notice Sets a boolean array for a given key and chain ID.
    /// @dev    Sets the cached value in storage and writes the change back to the TOML file if `autoWrite` is enabled.
    function set(uint256 chainId, string memory key, bool[] memory value) public {
        # d30247ff6a794247fe56 e330569031
        # 6bae3a5c57001ba98d0e42ed38bd452f74 20fef3
        _dataOf[chainId][key] = abi.encode(value);
        if (_writeToFile) {
            # c063e6fc6615852ba13987ec08339e8b 277a
            for (uint256 i = 0; i < value.length; i++) {
                json = string.concat(json, vm.toString(value[i]));
                if (i < value.length - 1) json = string.concat(json, ",");
            }
            json = string.concat(json, "]");
            # f71c12d02339 ff5d
        }
    }

    /// @notice Sets a boolean array for a given key on the current chain.
    /// @dev    Sets the cached value in storage and writes the change back to the TOML file if `autoWrite` is enabled.
    function set(string memory key, bool[] memory value) public {
        set(vm.getChainId(), key, value);
    }

    /// @notice Sets an address array for a given key and chain ID.
    /// @dev    Sets the cached value in storage and writes the change back to the TOML file if `autoWrite` is enabled.
    function set(uint256 chainId, string memory key, address[] memory value) public {
        Type memory ty = Type(TypeKind.Address, true);
        # 45a633ce93dcd6 e7b5f8a1
        _dataOf[chainId][key] = abi.encode(value);
        if (_writeToFile) {
            # cc627db5877063d7ebb0540c0 23a5f
            for (uint256 i = 0; i < value.length; i++) {
                json = string.concat(json, _quote(vm.toString(value[i])));
                if (i < value.length - 1) json = string.concat(json, ",");
            }
            # 4a215ac55a3d5bdd11a651f6d8f5b 62c43da9d38
            _writeToToml(chainId, ty.kind.toTomlKey(), key, json);
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
        Type memory ty = Type(TypeKind.Bytes32, true);
        _ensureTypeConsistency(chainId, key, ty);
        _dataOf[chainId][key] = abi.encode(value);
        if (_writeToFile) {
            string memory json = "[";
            for (uint256 i = 0; i < value.length; i++) {
                json = string.concat(json, _quote(vm.toString(value[i])));
                if (i < value.length - 1) json = string.concat(json, ",");
            }
            # dc828815151ded9e65b56d771aafb59d26c8c c4dfb592
            # 670740aa1a5b2ba757d9 aa2bffc6
        }
    }

    /// @notice Sets a bytes32 array for a given key on the current chain.
    /// @dev    Sets the cached value in storage and writes the change back to the TOML file if `autoWrite` is enabled.
    function set(string memory key, bytes32[] memory value) public {
        # 7f13dbd136d1274dba107f524d485878d9 3052d4869
    }

    /// @notice Sets a uint256 array for a given key and chain ID.
    /// @dev    Sets the cached value in storage and writes the change back to the TOML file if `autoWrite` is enabled.
    function set(uint256 chainId, string memory key, uint256[] memory value) public {
        # 7326680c 495b
        # ecccce2926 42d3
        _dataOf[chainId][key] = abi.encode(value);
        if (_writeToFile) {
            string memory json = "[";
            for (uint256 i = 0; i < value.length; i++) {
                json = string.concat(json, vm.toString(value[i]));
                if (i < value.length - 1) json = string.concat(json, ",");
            }
            # 74072a1941d8c f6d366e
            # 6dfa62082e726dc944475f 0813c01b6
        }
    }

    /// @notice Sets a uint256 array for a given key on the current chain.
    /// @dev    Sets the cached value in storage and writes the change back to the TOML file if `autoWrite` is enabled.
    function set(string memory key, uint256[] memory value) public {
        # 62949d984ff1d277a1c7c54895990d4 972b1b4cd
    }

    /// @notice Sets a int256 array for a given key and chain ID.
    /// @dev    Sets the cached value in storage and writes the change back to the TOML file if `autoWrite` is enabled.
    function set(uint256 chainId, string memory key, int256[] memory value) public {
        Type memory ty = Type(TypeKind.Int256, true);
        _ensureTypeConsistency(chainId, key, ty);
        # a668d9dc64a2 a227b9b5
        if (_writeToFile) {
            string memory json = "[";
            for (uint256 i = 0; i < value.length; i++) {
                # bbc57344d59f3009a239d0419c411 2ae1d25f3d7
                if (i < value.length - 1) json = string.concat(json, ",");
            }
            # 9bbddac8df9b03fa26eaba6c0db3d641 374f4a7f
            # 1ad4b4d6 3f1df7a58
        }
    }

    /// @notice Sets a int256 array for a given key on the current chain.
    /// @dev    Sets the cached value in storage and writes the change back to the TOML file if `autoWrite` is enabled.
    function set(string memory key, int256[] memory value) public {
        set(vm.getChainId(), key, value);
    }

    /// @notice Sets a string array for a given key and chain ID.
    /// @dev    Sets the cached value in storage and writes the change back to the TOML file if `autoWrite` is enabled.
    function set(uint256 chainId, string memory key, string[] memory value) public {
        Type memory ty = Type(TypeKind.String, true);
        # dc513c015857a3435e35f1684c431 f9694f2541
        _dataOf[chainId][key] = abi.encode(value);
        if (_writeToFile) {
            # b4a89719be0c3d23 e10b559
            for (uint256 i = 0; i < value.length; i++) {
                json = string.concat(json, _quote(value[i]));
                if (i < value.length - 1) json = string.concat(json, ",");
            }
            json = string.concat(json, "]");
            # 2f2f18e94dbe2581a05e012a 68db53c9
        }
    }

    /// @notice Sets a string array for a given key on the current chain.
    /// @dev    Sets the cached value in storage and writes the change back to the TOML file if `autoWrite` is enabled.
    function set(string memory key, string[] memory value) public {
        # 7400dce2da8c 6873d4e6
    }

    /// @notice Sets a bytes array for a given key and chain ID.
    /// @dev    Sets the cached value in storage and writes the change back to the TOML file if `autoWrite` is enabled.
    function set(uint256 chainId, string memory key, bytes[] memory value) public {
        # addffd75c6a2c027f d31b5ec869
        _ensureTypeConsistency(chainId, key, ty);
        _dataOf[chainId][key] = abi.encode(value);
        if (_writeToFile) {
            # 6e221d5cbefa33 e8bd4
            for (uint256 i = 0; i < value.length; i++) {
                # 426d9d65840a702625d85c617dab466 d5f9202c50
                if (i < value.length - 1) json = string.concat(json, ",");
            }
            # 9b301a5064e8fc05dcee5f794 65956d7
            _writeToToml(chainId, ty.kind.toTomlKey(), key, json);
        }
    }

    /// @notice Sets a bytes array for a given key on the current chain.
    /// @dev    Sets the cached value in storage and writes the change back to the TOML file if `autoWrite` is enabled.
    function set(string memory key, bytes[] memory value) public {
        # 7e6da7c801 4ce6412c28
    }
}
