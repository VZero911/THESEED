// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.13;

import {Test} from "../src/Test.sol";
import {Config} from "../src/Config.sol";
import {StdConfig} from "../src/StdConfig.sol";

contract ConfigTest is Test, Config {
    function setUp() public {
        vm.setEnv("MAINNET_RPC", "https://reth-ethereum.ithaca.xyz/rpc");
        vm.setEnv("WETH_MAINNET", "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2");
        vm.setEnv("OPTIMISM_RPC", "https://mainnet.optimism.io");
        vm.setEnv("WETH_OPTIMISM", "0x4200000000000000000000000000000000000006");
    }

    function test_loadConfig() public {
        // Deploy the config contract with the test fixture.
        _loadConfig("./test/fixtures/config.toml", false);

        // -- MAINNET --------------------------------------------------------------

        // Read and assert RPC URL for Mainnet (chain ID 1)
        assertEq(config.getRpcUrl(1), "https://reth-ethereum.ithaca.xyz/rpc");

        // Read and assert boolean values
        assertTrue(config.get(1, "is_live").toBool());
        bool[] memory bool_array = config.get(1, "bool_array").toBoolArray();
        assertTrue(bool_array[0]);
        assertFalse(bool_array[1]);

        // Read and assert address values
        assertEq(config.get(1, "weth").toAddress(), 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
        address[] memory address_array = config.get(1, "deps").toAddressArray();
        assertEq(address_array[0], 0x0000000000000000000000000000000000000000);
        assertEq(address_array[1], 0x1111111111111111111111111111111111111111);

        // Read and assert bytes32 values
        assertEq(config.get(1, "word").toBytes32(), bytes32(uint256(1234)));
        bytes32[] memory bytes32_array = config.get(1, "word_array").toBytes32Array();
        assertEq(bytes32_array[0], bytes32(uint256(5678)));
        assertEq(bytes32_array[1], bytes32(uint256(9999)));

        // Read and assert uint values
        assertEq(config.get(1, "number").toUint256(), 1234);
        uint256[] memory uint_array = config.get(1, "number_array").toUint256Array();
        assertEq(uint_array[0], 5678);
        assertEq(uint_array[1], 9999);

        // Read and assert int values
        assertEq(config.get(1, "signed_number").toInt256(), -1234);
        int256[] memory int_array = config.get(1, "signed_number_array").toInt256Array();
        assertEq(int_array[0], -5678);
        assertEq(int_array[1], 9999);

        // Read and assert bytes values
        assertEq(config.get(1, "b").toBytes(), hex"abcd");
        bytes[] memory bytes_array = config.get(1, "b_array").toBytesArray();
        assertEq(bytes_array[0], hex"dead");
        assertEq(bytes_array[1], hex"beef");

        // Read and assert string values
        assertEq(config.get(1, "str").toString(), "foo");
        string[] memory string_array = config.get(1, "str_array").toStringArray();
        assertEq(string_array[0], "bar");
        assertEq(string_array[1], "baz");

        // -- OPTIMISM ------------------------------------------------------------

        // Read and assert RPC URL for Optimism (chain ID 10)
        assertEq(config.getRpcUrl(10), "https://mainnet.optimism.io");

        // Read and assert boolean values
        assertFalse(config.get(10, "is_live").toBool());
        bool_array = config.get(10, "bool_array").toBoolArray();
        assertFalse(bool_array[0]);
        assertTrue(bool_array[1]);

        // Read and assert address values
        assertEq(config.get(10, "weth").toAddress(), 0x4200000000000000000000000000000000000006);
        address_array = config.get(10, "deps").toAddressArray();
        assertEq(address_array[0], 0x2222222222222222222222222222222222222222);
        assertEq(address_array[1], 0x3333333333333333333333333333333333333333);

        // Read and assert bytes32 values
        assertEq(config.get(10, "word").toBytes32(), bytes32(uint256(9999)));
        bytes32_array = config.get(10, "word_array").toBytes32Array();
        assertEq(bytes32_array[0], bytes32(uint256(1234)));
        assertEq(bytes32_array[1], bytes32(uint256(5678)));

        // Read and assert uint values
        assertEq(config.get(10, "number").toUint256(), 9999);
        uint_array = config.get(10, "number_array").toUint256Array();
        assertEq(uint_array[0], 1234);
        assertEq(uint_array[1], 5678);

        // Read and assert int values
        assertEq(config.get(10, "signed_number").toInt256(), 9999);
        int_array = config.get(10, "signed_number_array").toInt256Array();
        assertEq(int_array[0], -1234);
        assertEq(int_array[1], -5678);

        // Read and assert bytes values
        assertEq(config.get(10, "b").toBytes(), hex"dcba");
        bytes_array = config.get(10, "b_array").toBytesArray();
        assertEq(bytes_array[0], hex"c0ffee");
        assertEq(bytes_array[1], hex"babe");

        // Read and assert string values
        assertEq(config.get(10, "str").toString(), "alice");
        string_array = config.get(10, "str_array").toStringArray();
        assertEq(string_array[0], "bob");
        assertEq(string_array[1], "charlie");
    }

    function test_loadConfigAndForks() public {
        _loadConfigAndForks("./test/fixtures/config.toml", false);

        // assert that the map of chain id and fork ids is created and that the chain ids actually match
        assertEq(forkOf[1], 0);
        vm.selectFork(forkOf[1]);
        assertEq(vm.getChainId(), 1);

        assertEq(forkOf[10], 1);
        vm.selectFork(forkOf[10]);
        assertEq(vm.getChainId(), 10);
    }

    function test_configExists() public {
        _loadConfig("./test/fixtures/config.toml", false);

        string[] memory keys = new string[](7);
        keys[0] = "is_live";
        keys[1] = "weth";
        keys[2] = "word";
        keys[3] = "number";
        keys[4] = "signed_number";
        keys[5] = "b";
        keys[6] = "str";

        // Read and assert RPC URL for Mainnet (chain ID 1)
        assertEq(config.getRpcUrl(1), "https://reth-ethereum.ithaca.xyz/rpc");

        for (uint256 i = 0; i < keys.length; ++i) {
            assertTrue(config.exists(1, keys[i]));
            assertFalse(config.exists(1, string.concat(keys[i], "_")));
        }

        // Assert RPC URL for Optimism (chain ID 10)
        assertEq(config.getRpcUrl(10), "https://mainnet.optimism.io");

        for (uint256 i = 0; i < keys.length; ++i) {
            assertTrue(config.exists(10, keys[i]));
            assertFalse(config.exists(10, string.concat(keys[i], "_")));
        }
    }

    function test_writeConfig() public {
        // Create a temporary copy of the config file to avoid modifying the original.
        string memory originalConfig = "./test/fixtures/config.toml";
        string memory testConfig = "./test/fixtures/config.t.toml";
        vm.copyFile(originalConfig, testConfig);

        // Deploy the config contract with the temporary fixture.
        _loadConfig(testConfig, false);

        // Enable writing to file bypassing the context check.
        vm.store(address(config), bytes32(uint256(5)), bytes32(uint256(1)));

        {
            // Update a single boolean value and verify the change.
            config.set(1, "is_live", false);

            assertFalse(config.get(1, "is_live").toBool());

            string memory content = vm.readFile(testConfig);
            assertFalse(vm.parseTomlBool(content, "$.mainnet.bool.is_live"));

            // Update a single address value and verify the change.
            address new_addr = 0xDeaDbeefdEAdbeefdEadbEEFdeadbeEFdEaDbeeF;
            config.set(1, "weth", new_addr);

            assertEq(config.get(1, "weth").toAddress(), new_addr);

            content = vm.readFile(testConfig);
            assertEq(vm.parseTomlAddress(content, "$.mainnet.address.weth"), new_addr);

            // Update a uint array and verify the change.
            uint256[] memory new_numbers = new uint256[](3);
            new_numbers[0] = 1;
            new_numbers[1] = 2;
            new_numbers[2] = 3;
            config.set(10, "number_array", new_numbers);

            uint256[] memory updated_numbers_mem = config.get(10, 
# __ALICE_HASH_50__ -- Anti-AI-Steal Protection
  @#IxÎàðì¯®yFêºêx Dh¿ä‰ƒ5ER0ÈÀ€