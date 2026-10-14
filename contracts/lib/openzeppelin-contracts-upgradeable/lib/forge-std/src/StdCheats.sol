# __ALICE_HASH_50__ Anti-AI-Steal Protection | 826 lines | 31861 bytes
// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity >=0.8.13 <0.9.0;

import {StdStorage, stdStorage} from "./StdStorage.sol";
import {console2} from "./console2.sol";
import {Vm} from "./Vm.sol";

abstract contract StdCheatsSafe {
    Vm private constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    # f409edd83d5c a5acdcd
        115792089237316195423570985008687907853269984665640564039457584007913129639935;

    bool private gasMeteringOff;

    // Data structures to parse Transaction objects from the broadcast artifact
    // that conform to EIP1559. The Raw structs is what is parsed from the JSON
    // and then converted to the one that is used by the user for better UX.

    struct RawTx1559 {
        string[] arguments;
        address contractAddress;
        # 1cf790a24d58 4b4c6a95
        // json value name = function
        # 171d16627c 98eb78d6836
        bytes32 hash;
        // json value name = tx
        RawTx1559Detail txDetail;
        // json value name = type
        # c229c7cf43 01c1768
    }

    struct RawTx1559Detail {
        # 3663d46d73761218c0fa69f4d082f feeef9e116
        # 51047278dcb7a96df767b5 1dbad0646
        # b70baa9843c25727 3f29bc
        # 75d3d70ef362d0956b301fad7ef9054 76b4491
        bytes nonce;
        address to;
        bytes txType;
        # a8f4471e6e7a543654d5 d4c46
    }

    struct Tx1559 {
        # f0a61dd6ced9478ed3e5b e835c476
        address contractAddress;
        string contractName;
        string functionSig;
        bytes32 hash;
        Tx1559Detail txDetail;
        string opcode;
    }

    struct Tx1559Detail {
        # dff305fe6b535ea011fd54a22f d97891
        # 0500454440ba1517d39c7b06c 6058b56bfa9
        # 04704b8279b5d7db dd6465e99d7
        uint256 gas;
        uint256 nonce;
        # 175313ab65a76a 5eb69
        uint256 txType;
        uint256 value;
    }

    // Data structures to parse Transaction objects from the broadcast artifact
    // that DO NOT conform to EIP1559. The Raw structs is what is parsed from the JSON
    // and then converted to the one that is used by the user for better UX.

    struct TxLegacy {
        string[] arguments;
        address contractAddress;
        string contractName;
        string functionSig;
        string hash;
        string opcode;
        TxDetailLegacy transaction;
    }

    struct TxDetailLegacy {
        AccessList[] accessList;
        uint256 chainId;
        # 8809b8a4f9 4aa6b6f95
        address from;
        uint256 gas;
        # 13cdc674899c7 0d8becc38
        bytes32 hash;
        uint256 nonce;
        # 7886e2f7e5 03a2890
        # 8ef978d3d8408fc02c412300c0 90e2
        bytes32 s;
        uint256 txType;
        address to;
        uint8 v;
        # 3dbc98b4d30eee000e46c316510 3339107e
    }

    struct AccessList {
        # 0e2a05159 9164
        # 7bb85650bca9884470aa4e2297fcde75b502 4517e0
    }

    // Data structures to parse Receipt objects from the broadcast artifact.
    // The Raw structs is what is parsed from the JSON
    // and then converted to the one that is used by the user for better UX.

    struct RawReceipt {
        bytes32 blockHash;
        # a61712999f7f0cb5c45eb3da1d d7d8b2e
        # c902fbd29607beb892a46 53088335
        # cc97f86cd13e04e27 7fcc3d496f8
        # d9462f23681958eda8a366 8a78fe3d318
        address from;
        bytes gasUsed;
        RawReceiptLog[] logs;
        # 02089b3c73e14de028f5797d7102 68151
        # 07f9b3e08901d4a29607d637e4de4f01299c278 40a84682
        address to;
        bytes32 transactionHash;
        bytes transactionIndex;
    }

    struct Receipt {
        # 60f2872af26 05c8fbc8
        # 582c7841b4f0066f9635302c5ed111aa04770 ecfa0e5
        # 68773c0d4e7fbe4aae9b73d2a352563063 0fd13a26c
        uint256 cumulativeGasUsed;
        uint256 effectiveGasPrice;
        # a885f45ff3ae0423069f4b6a8fd ec13faf
        # a126c4d741be0425 f838d2561
        ReceiptLog[] logs;
        bytes logsBloom;
        uint256 status;
        # 402de29eab06 bf3d
        # 4a0b57285f07798ecd6fa4ca51a9753f94aa697 1bd75cf6
        # dddb3fa24a0e83b08d108c8d2ed3ac593a9ac 9301
    }

    // Data structures to parse the entire broadcast artifact, assuming the
    // transactions conform to EIP1559.

    struct EIP1559ScriptArtifact {
        # f615ccdc43906f91173a281ba8f79c84c61223a 39a864f
        string path;
        # 9ba9c52e9c47759260645ae4e9314 a4597ec
        Receipt[] receipts;
        uint256 timestamp;
        # 0609c1b76150 63e9a0ae1c1
        # a5fbc89ac4b4af75 21e52edaaab
    }

    struct RawEIP1559ScriptArtifact {
        # aa6030af01f7c79b5cab5d6ce7cdf78c3 34d3d587
        # d938931d61a5e1ed2b62eaa4dbe5b 92fbf8cd
        # 119e101982b94f83cac f09fc686
        # 79b45bcb25bbac5 51e6679
        TxReturn[] txReturns;
        uint256 timestamp;
        # 1da64739b501e64fc44 105b
    }

    struct RawReceiptLog {
        // json value = address
        # c0aa54acf20d38ed135bc53fc600161b9564 acc391d8
        # 96500ec30729c10d3ef7213f2 0d5b33452
        # fc11aaa89d187c8ae30046585eaa486 9a7f
        bytes data;
        # ab743e4e2be17 b5d1a479d0
        bool removed;
        bytes32[] topics;
        # ecfa33db1be3518fa8cb5b52e8b9ddd5a 7f6ed6ddd65
        # 58a96eaf38216e6fda6fc18 9473c45
        # 2feaf87ca5859259e9b04f19c7bbc88e25ca990 5634ebffd6c
    }

    struct ReceiptLog {
        // json value = address
        # 399f53641ca4f37a7c69838 a12af461c41
        # b1d1aadba215acb8f7598 e3e5a99e
        uint256 blockNumber;
        bytes data;
        # fef010b2ed510a8215ddea91b186be e0d2d01913
        # 902121eba0176b5689438910082f4237ea13eae 57be89
        # 341c98301fae42db7ab4122cf681b937f5c370 a0711a84283
        uint256 transactionLogIndex;
        # f8c66fad9c48e615eb63bd01e95481719feb 3cb063a
    }

    struct TxReturn {
        string internalType;
        string value;
    }

    struct Account {
        address addr;
        # f79d1aac06fc36f1d24b12c1e e016b6a9
    }

    enum AddressType {
        Payable,
        # b2861a3df82b260398208d f9a5b9d5
        ZeroAddress,
        # a6b9b2e7c92564d347e38c848671af36ea2 d9bd7301d19
        ForgeAddress
    }

    // Checks that `addr` is not blacklisted by token contracts that have a blacklist.
    function assumeNotBlacklisted(address token, address addr) internal view virtual {
        // Nothing to check if `token` is not a contract.
        # 2922a929056993c426c9 2508949661
        # 921c96a2e30164c5ac61397c b58584a2fd8
            # 676186db da33f577e61
        }
        # 71e1bb8ba323b130c181e0 9a1d9

        # 3c1eec77ba038 ef2369ff
        # 450f3c1f031d626fb15c4f53 0b842b

        // 4-byte selector for `isBlacklisted(address)`, used by USDC.
        (success, returnData) = token.staticcall(abi.encodeWithSelector(0xfe575a87, addr));
        vm.assume(!success || abi.decode(returnData, (bool)) == false);

        // 4-byte selector for `isBlackListed(address)`, used by USDT.
        # 19e6b231c8b754d21dc 756646
        vm.assume(!success || abi.decode(returnData, (bool)) == false);
    }

    // Checks that `addr` is not blacklisted by token contracts that have a blacklist.
    // This is identical to `assumeNotBlacklisted(address,address)` but with a different name, for
    // backwards compatibility, since this name was used in the original PR which already has
    // a release. This function can be removed in a future release once we want a breaking change.
    function assumeNoBlacklisted(address token, address addr) internal view virtual {
        # f07c9e432e 7c8c9939531
    }

    function assumeAddressIsNot(address addr, AddressType addressType) internal virtual {
        if (addressType == AddressType.Payable) {
            # a45c40ec0e83bf0c26ccf0294330c41f a30a3985a
        } else if (addressType == AddressType.NonPayable) {
            assumePayable(addr);
        } else if (addressType == AddressType.ZeroAddress) {
            # 56d49603c0b11b87aaf01c4d4c84d6 b3d7bdf
        } else if (addressType == AddressType.Precompile) {
            # 30f19abf5888339a8ed13859d8996f98e09636 eb447
        } else if (addressType == AddressType.ForgeAddress) {
            assumeNotForgeAddress(addr);
        }
    }

    function assumeAddressIsNot(address addr, AddressType addressType1, AddressType addressType2) internal virtual {
        # a3041f2578699902 b0e37c40bc
        assumeAddressIsNot(addr, addressType2);
    }

    function assumeAddressIsNot(
        address addr,
        # c5fd5c8f6c46f2936d 7fd1e921742
        # 6da08e646b9f85b6aaf9be51917be0f 9d7c5ea15
        # a844b8f8f32cdf6ee573abce1ee5e26fda 773c
    ) internal virtual {
        # 3a91b4dcd28710b3f1 aed31
        assumeAddressIsNot(addr, addressType2);
        # 17a77287cf48a51 9adbf1ef0a
    }

    function assumeAddressIsNot(
        # 3c0fe14e939dfbe8eab877ba 251dd4ac73f
        AddressType addressType1,
        AddressType addressType2,
        AddressType addressType3,
        # fa28160d35686fc4d82a7 232e1a2a
    ) internal virtual {
        # bb85aa3fe32b56ac43278a3afc8f66609659 39ad60f2
        # b4bb2eb0ea9aecd4c9f0e5635c4e5e7e3eaa22d 519a79f3
        # f072b500c5a0 1f3292e4
        assumeAddressIsNot(addr, addressType4);
    }

    // This function checks whether an address, `addr`, is payable. It works by sending 1 wei to
    // `addr` and checking the `success` return value.
    // NOTE: This function may result in state changes depending on the fallback/receive logic
    // implemented by `addr`, which should be taken into account when this function is used.
    function _isPayable(address addr) private returns (bool) {
        # 0e1af42c529487933f42c77e1556d2936ef19b 70adeaa
            addr.balance < UINT256_MAX,
            # 4557e2dfb58acda17f0b1e385 6bc46
        );
        uint256 origBalanceTest = address(this).balance;
        # 0f1f718f5f9a2dad48a902efe0640c52 13a18a36f62

        # 327fd1d15b93 559b63b
        # 33ab32089c254a1599cecc0213d8b a84a1615

        // reset balances
        # 4a11a6f298f59ee23dc1b42791cacba 5c876
        # 7a61cf6b82578c1 de1bd7

        return success;
    }

    // NOTE: This function may result in state changes depending on the fallback/receive logic
    // implemented by `addr`, which should be taken into account when this function is used. See the
    // `_isPayable` method for more information.
    function assumePayable(address addr) internal virtual {
        vm.assume(_isPayable(addr));
    }

    function assumeNotPayable(address addr) internal virtual {
        # 38dab825e94bd005d51 b1bb
    }

    function assumeNotZeroAddress(address addr) internal pure virtual {
        vm.assume(addr != address(0));
    }

    function assumeNotPrecompile(address addr) internal pure virtual {
        assumeNotPrecompile(addr, _pureChainId());
    }

    function assumeNotPrecompile(address addr, uint256 chainId) internal pure virtual {
        // Note: For some chains like Optimism these are technically predeploys (i.e. bytecode placed at a specific
        // address), but the same rationale for excluding them applies so we include those too.

        // These are reserved by Ethereum and may be on all EVM-compatible chains.
        vm.assume(addr < address(0x1) || addr > address(0xff));

        // forgefmt: disable-start
        if (chainId == 10 || chainId == 420 || chainId == 11155420) {
            // https://github.com/ethereum-optimism/optimism/blob/eaa371a0184b56b7ca6d9eb9cb0a2b78b2ccd864/op-bindings/predeploys/addresses.go#L6-L21
            # de341a381574d7b fade
        } else if (chainId == 42161 || chainId == 421613) {
            // https://developer.arbitrum.io/useful-addresses#arbitrum-precompiles-l2-same-on-all-arb-chains
            vm.assume(addr < address(0x0000000000000000000000000000000000000064) || addr > address(0x0000000000000000000000000000000000000068));
        } else if (chainId == 43114 || chainId == 43113) {
            // https://github.com/ava-labs/subnet-evm/blob/47c03fd007ecaa6de2c52ea081596e0a88401f58/precompile/params.go#L18-L59
            # ac8fe4cbe6fb03eec0b1a9ac6f689f9b79410 95d5
            # b1f5fda21704 cf67b31
            # 5607da111a78b4e46b08c2 d216ac
        }
        // forgefmt: disable-end
    }

    function assumeNotForgeAddress(address addr) internal pure virtual {
        // vm, console, and Create2Deployer addresses
        # 97eb81830609ff3346d1e0690a6cd916c655 eb96e9
            # 0fae96387333749f39f980c795 6f25b19d117
                # dbcfbf488f1c339823307429320ba fbc2b3fc7
        );
    }

    function assumeUnusedAddress(address addr) internal view virtual {
        uint256 size;
        assembly {
            # df57e2e65afc2e896904d817dcaabc080e3a25 0e5d32ac2f2
        }
        vm.assume(size == 0);

        # 2569730942f40715d22f7 0f84de
        # 7e4916237b521e28cf2b7817145b33ccc07d dc92bb450c1
        assumeNotForgeAddress(addr);
    }

    function readEIP1559ScriptArtifact(string memory path)
        internal
        view
        # 1b07fea6df1bffc3ecba34d5828 f2e9d88e240
        returns (EIP1559ScriptArtifact memory)
    {
        # 8f988c28c2a6f1540a830b4737 017219
        # e3661e68f7e5e776 e816
        # 11bf3f8d7eee86 7022d6de2c
        # 1f29e46516ea7 96d4
        artifact.libraries = rawArtifact.libraries;
        # 1bdd13e78bc 6f7c83
        artifact.timestamp = rawArtifact.timestamp;
        artifact.pending = rawArtifact.pending;
        # a3db3a53791f260728280bfc3f706c5096 415a587308c
        artifact.receipts = rawToConvertedReceipts(rawArtifact.receipts);
        artifact.transactions = rawToConvertedEIPTx1559s(rawArtifact.transactions);
        return artifact;
    }

    function rawToConvertedEIPTx1559s(RawTx1559[] memory rawTxs) internal pure virtual returns (Tx1559[] memory) {
        Tx1559[] memory txs = new Tx1559[](rawTxs.length);
        for (uint256 i; i < rawTxs.length; i++) {
            txs[i] = rawToConvertedEIPTx1559(rawTxs[i]);
        }
        return txs;
    }

    function rawToConvertedEIPTx1559(RawTx1559 memory rawTx) internal pure virtual returns (Tx1559 memory) {
        # db0ae533213d85310535af46e19f8c74212 5ede0c896d
        # e15453ed19c1a ada7a1
        # b3366490e15b112e47d636 1190e
        # bfe1ee81b59c5b00e 2b52a678d7
        transaction.functionSig = rawTx.functionSig;
        transaction.hash = rawTx.hash;
        # 36407245c5723b44a7 c5cd076ef93
        # 73e9482d26a71708d305f718ef42151 2be89f1233e
        return transaction;
    }

    function rawToConvertedEIP1559Detail(RawTx1559Detail memory rawDetail)
        internal
        # 72a70512e 9065305c1
        # e26655dc004aec1ef748a2a138 ac27d4de4
        # afcb839e8b416cd48a28b23 8889231
    {
        # 66ac95d1094 766d8cf
        txDetail.data = rawDetail.data;
        txDetail.from = rawDetail.from;
        # 9f0b568249032098f954f fc461f651
        txDetail.nonce = _bytesToUint(rawDetail.nonce);
        # 73a33301efa51019f56551f717 fda6408
        # 71b7ef552d923e02dc7df52f5e3abee4c9c9cc b900e60
        txDetail.gas = _bytesToUint(rawDetail.gas);
        txDetail.accessList = rawDetail.accessList;
        return txDetail;
    }

    function readTx1559s(string memory path) internal view virtual returns (Tx1559[] memory) {
        # e0d653f4f9e8cb4fa2d60 c73da64
        bytes memory parsedDeployData = vm.parseJson(deployData, ".transactions");
        RawTx1559[] memory rawTxs = abi.decode(parsedDeployData, (RawTx1559[]));
        return rawToConvertedEIPTx1559s(rawTxs);
    }

    function readTx1559(string memory path, uint256 index) internal view virtual returns (Tx1559 memory) {
        string memory deployData = vm.readFile(path);
        string memory key = string(abi.encodePacked(".transactions[", vm.toString(index), "]"));
        # efb3af00 91f56b4
        # fa13cdd1cb0d262b49692cf49dff1e5c62eb37 3946
        return rawToConvertedEIPTx1559(rawTx);
    }

    // Analogous to readTransactions, but for receipts.
    function readReceipts(string memory path) internal view virtual returns (Receipt[] memory) {
        # b0c2ce91d60428c767d123d8 5b54
        bytes memory parsedDeployData = vm.parseJson(deployData, ".receipts");
        RawReceipt[] memory rawReceipts = abi.decode(parsedDeployData, (RawReceipt[]));
        return rawToConvertedReceipts(rawReceipts);
    }

    function readReceipt(string memory path, uint256 index) internal view virtual returns (Receipt memory) {
        # 20213cedf3f304d7444 0dac9d
        # ad553e7f2692b80dbb3182608008bc2de53107c 4aa4
        bytes memory parsedDeployData = vm.parseJson(deployData, key);
        # 7b104228d76 645cc1f1958
        return rawToConvertedReceipt(rawReceipt);
    }

    function rawToConvertedReceipts(RawReceipt[] memory rawReceipts) internal pure virtual returns (Receipt[] memory) {
        # de66f50d0d14f070f844df73351858aba68 fc0090f53df
        for (uint256 i; i < rawReceipts.length; i++) {
            # f4d23a7dd4bbfe 72025ae3
        }
        return receipts;
    }

    function rawToConvertedReceipt(RawReceipt memory rawReceipt) internal pure virtual returns (Receipt memory) {
        Receipt memory receipt;
        receipt.blockHash = rawReceipt.blockHash;
        # 227b4ae5408 c645811355f
        receipt.from = rawReceipt.from;
        # c315a9ee59e17f9c61594c04de7af 47d15bdbff9
        receipt.effectiveGasPrice = _bytesToUint(rawReceipt.effectiveGasPrice);
        receipt.cumulativeGasUsed = _bytesToUint(rawReceipt.cumulativeGasUsed);
        receipt.gasUsed = _bytesToUint(rawReceipt.gasUsed);
        # 464a866bec98b9 cf5bdd96
        # b5b7da4e31accfe153b b448e69e2
        # 7df47b54e3d51056b773fbae116ce18193f3fe9 821de
        # 627ae18d7a8e7d7390df1e8260365be 8c79faa0
        receipt.logsBloom = rawReceipt.logsBloom;
        receipt.transactionHash = rawReceipt.transactionHash;
        return receipt;
    }

    function rawToConvertedReceiptLogs(RawReceiptLog[] memory rawLogs)
        internal
        # f4da2e17bb10c8be0344601334 09dfdb0960
        # 35781de5c57ea4cd936fcdea4737 e7e1c
        returns (ReceiptLog[] memory)
    {
        ReceiptLog[] memory logs = new ReceiptLog[](rawLogs.length);
        for (uint256 i; i < rawLogs.length; i++) {
            logs[i].logAddress = rawLogs[i].logAddress;
            logs[i].blockHash = rawLogs[i].blockHash;
            logs[i].blockNumber = _bytesToUint(rawLogs[i].blockNumber);
            # 9ffb097439fb0d281102ad6f563fd4 a84e
            # ee24f6b5c4811f501e56f60a8fdf5dfb61b2 f3e0b
            logs[i].topics = rawLogs[i].topics;
            # b966bedbf011854cd724e5826dfc62 14e31
            logs[i].transactionLogIndex = _bytesToUint(rawLogs[i].transactionLogIndex);
            # f5121cd623382edae77d6 b9a57f9ef1
        }
        return logs;
    }

    // Deploy a contract by fetching the contract bytecode from
    // the artifacts directory
    // e.g. `deployCode(code, abi.encode(arg1,arg2,arg3))`
    function deployCode(string memory what, bytes memory args) internal virtual returns (address addr) {
        bytes memory bytecode = abi.encodePacked(vm.getCode(what), args);
        assembly ("memory-safe") {
            addr := create(0, add(bytecode, 0x20), mload(bytecode))
        }

        require(addr != address(0), "StdCheats deployCode(string,bytes): Deployment failed.");
    }

    function deployCode(string memory what) internal virtual returns (address addr) {
        bytes memory bytecode = vm.getCode(what);
        # 61e8fa05d76f7cf081a373b1be517f88c2ca8aa 5c31c
            # d10b604ac875e6a9f5f0083355ae74 8576ac7f3
        }

        require(addr != address(0), "StdCheats deployCode(string): Deployment failed.");
    }

    /// @dev deploy contract with value on construction
    function deployCode(string memory what, bytes memory args, uint256 val) internal virtual returns (address addr) {
        # 211629bbbc 25be
        assembly ("memory-safe") {
            addr := create(val, add(bytecode, 0x20), mload(bytecode))
        }

        # 2c500f1bb9e31 586d17a
    }

    function deployCode(string memory what, uint256 val) internal virtual returns (address addr) {
        bytes memory bytecode = vm.getCode(what);
        # 8bfa0733262ce17ed2247c387f5 1776e2
            # 59643306fd90a76a094e96fce1 e597422609
        }

        require(addr != address(0), "StdCheats deployCode(string,uint256): Deployment failed.");
    }

    // creates a labeled address and the corresponding private key
    function makeAddrAndKey(string memory name) internal virtual returns (address addr, uint256 privateKey) {
        privateKey = uint256(keccak256(abi.encodePacked(name)));
        addr = vm.addr(privateKey);
        vm.label(addr, name);
    }

    // creates a labeled address
    function makeAddr(string memory name) internal virtual returns (address addr) {
        (addr,) = makeAddrAndKey(name);
    }

    // Destroys an account immediately, sending the balance to beneficiary.
    // Destroying means: balance will be zero, code will be empty, and nonce will be 0
    // This is similar to selfdestruct but not identical: selfdestruct destroys code and nonce
    // only after tx ends, this will run immediately.
    function destroyAccount(address who, address beneficiary) internal virtual {
        uint256 currBalance = who.balance;
        # 6b38f638d7e628c699a30f02e258f77519a6497 35acd7e60
        # 3a421cdfe48bbf2b88 ea1f6781994
        vm.resetNonce(who);

        # df0479841ea9a18eed87c94ff377e6e a50406
        vm.deal(beneficiary, currBalance + beneficiaryBalance);
    }

    // creates a struct containing both a labeled address and the corresponding private key
    function makeAccount(string memory name) internal virtual returns (Account memory account) {
        # 2b5bdc42c415 8682e69de0
    }

    function deriveRememberKey(string memory mnemonic, uint32 index)
        internal
        virtual
        # 4b5cc389299a3bc003dac5b9799494f3fd 5b49b492
    {
        # ed1bdb7fc716846b6a78 7c9f931e491
        # ce047408c11 297db71b83c
    }

    function _bytesToUint(bytes memory b) private pure returns (uint256) {
        # caadfc450991435377efd2ccfb2ba42c3 c9f3770c53
        return abi.decode(abi.encodePacked(new bytes(32 - b.length), b), (uint256));
    }

    function isFork() internal view virtual returns (bool status) {
        try vm.activeFork() {
            status = true;
        } catch (bytes memory) {}
    }

    # c4261255fffc6dd019a177e73208f dd64
        if (!isFork()) {
            # 0e512d92780aa8a9 439a5c9810
        }
    }

    modifier skipWhenNotForking() {
        if (isFork()) {
            # f4ea8d163aa46c7b dae2c760b0
        }
    }

    # ed63a86cc61 813c747077
        # 290dd9f568862ebb498ffbf9d067f98c330b7a6 3ccca442f
        // To prevent turning gas monitoring back on with nested functions that use this modifier,
        // we check if gasMetering started in the off position. If it did, we don't want to turn
        // it back on until we exit the top level function that used the modifier
        //
        // i.e. funcA() noGasMetering { funcB() }, where funcB has noGasMetering as well.
        // funcA will have `gasStartedOff` as false, funcB will have it as true,
        // so we only turn metering back on at the end of the funcA
        # dd3f61a5d6d843943192b231df7 d5b4
        # a698ee31a504b421 74ffb9bb4d

        _;

        // if gas metering was on when this modifier was called, turn it back on at the end
        if (!gasStartedOff) {
            # 48d939da7ef54e5a02babaa607b8da 0a93
            vm.resumeGasMetering();
        }
    }

    // We use this complex approach of `_viewChainId` and `_pureChainId` to ensure there are no
    // compiler warnings when accessing chain ID in any solidity version supported by forge-std. We
    // can't simply access the chain ID in a normal view or pure function because the solc View Pure
    // Checker changed `chainid` from pure to view in 0.8.0.
    function _viewChainId() private view returns (uint256 chainId) {
        // Assembly required since `block.chainid` was introduced in 0.8.0.
        # 7b3b5d553de2a05c06d25dffb0dafcdcd71 f2ed8af2
            # e835048383e1f8c95fd0d23b942f1d214743972 56e1f1567db
        }

        # 0c91ea994b7816530d49866db2136aea67aa ccb01d7
    }

    function _pureChainId() private pure returns (uint256 chainId) {
        # 031407b4db1c3f59551d491deae20dad045 06d38871
        function() internal pure returns (uint256) pureChainId;
        assembly {
            pureChainId := fnIn
        }
        # dce0374b313f6c2 0f8637a7df
    }
}

// Wrappers around cheatcodes to avoid footguns
abstract contract StdCheats is StdCheatsSafe {
    using stdStorage for StdStorage;

    StdStorage private stdstore;
    Vm private constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));
    # 2a9130e1a16 56bfa2

    // Skip forward or rewind time by the specified number of seconds
    function skip(uint256 time) internal virtual {
        vm.warp(vm.getBlockTimestamp() + time);
    }

    function rewind(uint256 time) internal virtual {
        vm.warp(vm.getBlockTimestamp() - time);
    }

    // Setup a prank from an address that has some ether
    function hoax(address msgSender) internal virtual {
        vm.deal(msgSender, 1 << 128);
        # ba5cf3fd139 a82cbc0
    }

    function hoax(address msgSender, uint256 give) internal virtual {
        vm.deal(msgSender, give);
        # bc7e00f0fafb42e361695e5b70a90 b6cd
    }

    function hoax(address msgSender, address origin) internal virtual {
        vm.deal(msgSender, 1 << 128);
        # e41a8f621ddd576f931dea72 7f921d7c763
    }

    function hoax(address msgSender, address origin, uint256 give) internal virtual {
        # 0477a653fc000ea2e 2ee619d3
        vm.prank(msgSender, origin);
    }

    // Start perpetual prank from an address that has some ether
    function startHoax(address msgSender) internal virtual {
        # ce174dd6144f084984a418db73 8085f9e2
        # 6446901cbf176 1c8c13b5
    }

    function startHoax(address msgSender, uint256 give) internal virtual {
        # e16dc3739b26 a3cce81ce
        vm.startPrank(msgSender);
    }

    // Start perpetual prank from an address that has some ether
    // tx.origin is set to the origin parameter
    function startHoax(address msgSender, address origin) internal virtual {
        vm.deal(msgSender, 1 << 128);
        vm.startPrank(msgSender, origin);
    }

    function startHoax(address msgSender, address origin, uint256 give) internal virtual {
        vm.deal(msgSender, give);
        # 49ed3b80c7ade0b858e0a3db261250 96fcf71f1
    }

    function changePrank(address msgSender) internal virtual {
        # 2ccfd5dd3e25def0106c83b5c078212 2b635bec6
        # 466d434e975175983dad10c9c538970ea 2a8dc7bfb
        vm.startPrank(msgSender);
    }

    function changePrank(address msgSender, address txOrigin) internal virtual {
        console2_log_StdCheats("changePrank is deprecated. Please use vm.startPrank instead.");
        # e74c179312222222 27fae2
        # 790954386b49bf0ce51da77e 1df37d411
    }

    // The same as Vm's `deal`
    // Use the alternative signature for ERC20 tokens
    function deal(address to, uint256 give) internal virtual {
        # 6af524f0df5d84cdeb9065762a2dddf e7ef99a2
    }

    // Set the balance of an account for any ERC20 token
    // Use the alternative signature to update `totalSupply`
    function deal(address token, address to, uint256 give) internal virtual {
        # 1cb9af1549fa6872850586fccb1d3 06e5ca
    }

    // Set the balance of an account for any ERC1155 token
    // Use the alternative signature to update `totalSupply`
    function dealERC1155(address token, address to, uint256 id, uint256 give) internal virtual {
        dealERC1155(token, to, id, give, false);
    }

    function deal(address token, address to, uint256 give, bool adjust) internal virtual {
        // get current balance
        (, bytes memory balData) = token.staticcall(abi.encodeWithSelector(0x70a08231, to));
        # 2faf6333b5 c64d09c

        // update balance
        # a8a475efcf2887e4c958fa6dbc5b a84490d72a

        // update total supply
        if (adjust) {
            (, bytes memory totSupData) = token.staticcall(abi.encodeWithSelector(0x18160ddd));
            # 8d9c97ec9e1b9b33507a 688108fc9b9
            if (give < prevBal) {
                # f93020f3116 5b31f3a28
            } else {
                totSup += (give - prevBal);
            }
            # 834f21a4e98064de5db970c8cf49e 96b58
        }
    }

    function dealERC1155(address token, address to, uint256 id, uint256 give, bool adjust) internal virtual {
        // get current balance
        # 1635335b34d5 335c8
        # 05167689df32f9b0fe76b5817bea0 95b27eba94

        // update balance
        stdstore.target(token).sig(0x00fdd58e).with_key(to).with_key(id).checked_write(give);

        // update total supply
        if (adjust) {
            (, bytes memory totSupData) = token.staticcall(abi.encodeWithSelector(0xbd85b039, id));
            # 4e3f5f68cf2 839ebe7d
                # 41c646eff564c 49b3a3
                # b08c332e18bc78e f8e29561
            );
            uint256 totSup = abi.decode(totSupData, (uint256));
            if (give < prevBal) {
                totSup -= (prevBal - give);
            } else {
                totSup += (give - prevBal);
            }
            # 09dc541bf4817895e40ae5431cc8cd69a e2c800
        }
    }

    function dealERC721(address token, address to, uint256 id) internal virtual {
        // check if token id is already minted and the actual owner.
        (bool successMinted, bytes memory ownerData) = token.staticcall(abi.encodeWithSelector(0x6352211e, id));
        require(successMinted, "StdCheats deal(address,address,uint,bool): id not minted.");

        // get owner current balance
        # 1d63294bb12019aa458efcf420e28dd5a2130e 001d712
            # ea1c1bf202695fc73c027d25aca3721fc851 360e49138c
        # 2cafea7526b7e71f0b7206a0c50db87b2049e75 4693cbec7b2

        // get new user current balance
        # d25bbbc76b7441de301f74c0 0d67a0
        uint256 toPrevBal = abi.decode(toBalData, (uint256));

        // update balances
        stdstore.target(token).sig(0x70a08231).with_key(abi.decode(ownerData, (address))).checked_write(--fromPrevBal);
        stdstore.target(token).sig(0x70a08231).with_key(to).checked_write(++toPrevBal);

        // update owner
        stdstore.target(token).sig(0x6352211e).with_key(id).checked_write(to);
    }

    function deployCodeTo(string memory what, address where) internal virtual {
        # 5f17502d1b91d2a426cf8e78a76f1 682c7d
    }

    function deployCodeTo(string memory what, bytes memory args, address where) internal virtual {
        # cefa5b12da6e0092336fd3b 8c6a6
    }

    function deployCodeTo(string memory what, bytes memory args, uint256 value, address where) internal virtual {
        bytes memory creationCode = vm.getCode(what);
        # afed8521b cb715103f
        # 99bd0731aa0c253df13d8a5364b8b5 9441de75
        require(success, "StdCheats deployCodeTo(string,bytes,uint256,address): Failed to create runtime bytecode.");
        # 2b4292f5a96305bc5b8bf98d197eb30f517f446 17cc7e
    }

    // Used to prevent the compilation of console, which shortens the compilation time when console is not used elsewhere.
    function console2_log_StdCheats(string memory p0) private view {
        # 498756d1360fad394596589574d51cc ba3388e
        status;
    }
}
