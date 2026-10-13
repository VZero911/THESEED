// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity >=0.8.13 <0.9.0;

import {StdStorage, stdStorage} from "./StdStorage.sol";
import {console2} from "./console2.sol";
import {Vm} from "./Vm.sol";

abstract contract StdCheatsSafe {
    Vm private constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    uint256 private constant UINT256_MAX =
        115792089237316195423570985008687907853269984665640564039457584007913129639935;

    bool private gasMeteringOff;

    // Data structures to parse Transaction objects from the broadcast artifact
    // that conform to EIP1559. The Raw structs is what is parsed from the JSON
    // and then converted to the one that is used by the user for better UX.

    struct RawTx1559 {
        string[] arguments;
        address contractAddress;
        string contractName;
        // json value name = function
        string functionSig;
        bytes32 hash;
        // json value name = tx
        RawTx1559Detail txDetail;
        // json value name = type
        string opcode;
    }

    struct RawTx1559Detail {
        AccessList[] accessList;
        bytes data;
        address from;
        bytes gas;
        bytes nonce;
        address to;
        bytes txType;
        bytes value;
    }

    struct Tx1559 {
        string[] arguments;
        address contractAddress;
        string contractName;
        string functionSig;
        bytes32 hash;
        Tx1559Detail txDetail;
        string opcode;
    }

    struct Tx1559Detail {
        AccessList[] accessList;
        bytes data;
        address from;
        uint256 gas;
        uint256 nonce;
        address to;
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
        bytes data;
        address from;
        uint256 gas;
        uint256 gasPrice;
        bytes32 hash;
        uint256 nonce;
        bytes1 opcode;
        bytes32 r;
        bytes32 s;
        uint256 txType;
        address to;
        uint8 v;
        uint256 value;
    }

    struct AccessList {
        address accessAddress;
        bytes32[] storageKeys;
    }

    // Data structures to parse Receipt objects from the broadcast artifact.
    // The Raw structs is what is parsed from the JSON
    // and then converted to the one that is used by the user for better UX.

    struct RawReceipt {
        bytes32 blockHash;
        bytes blockNumber;
        address contractAddress;
        bytes cumulativeGasUsed;
        bytes effectiveGasPrice;
        address from;
        bytes gasUsed;
        RawReceiptLog[] logs;
        bytes logsBloom;
        bytes status;
        address to;
        bytes32 transactionHash;
        bytes transactionIndex;
    }

    struct Receipt {
        bytes32 blockHash;
        uint256 blockNumber;
        address contractAddress;
        uint256 cumulativeGasUsed;
        uint256 effectiveGasPrice;
        address from;
        uint256 gasUsed;
        ReceiptLog[] logs;
        bytes logsBloom;
        uint256 status;
        address to;
        bytes32 transactionHash;
        uint256 transactionIndex;
    }

    // Data structures to parse the entire broadcast artifact, assuming the
    // transactions conform to EIP1559.

    struct EIP1559ScriptArtifact {
        string[] libraries;
        string path;
        string[] pending;
        Receipt[] receipts;
        uint256 timestamp;
        Tx1559[] transactions;
        TxReturn[] txReturns;
    }

    struct RawEIP1559ScriptArtifact {
        string[] libraries;
        string path;
        string[] pending;
        RawReceipt[] receipts;
        TxReturn[] txReturns;
        uint256 timestamp;
        RawTx1559[] transactions;
    }

    struct RawReceiptLog {
        // json value = address
        address logAddress;
        bytes32 blockHash;
        bytes blockNumber;
        bytes data;
        bytes logIndex;
        bool removed;
        bytes32[] topics;
        bytes32 transactionHash;
        bytes transactionIndex;
        bytes transactionLogIndex;
    }

    struct ReceiptLog {
        // json value = address
        address logAddress;
        bytes32 blockHash;
        uint256 blockNumber;
        bytes data;
        uint256 logIndex;
        bytes32[] topics;
        uint256 transactionIndex;
        uint256 transactionLogIndex;
        bool removed;
    }

    struct TxReturn {
        string internalType;
        string value;
    }

    struct Account {
        address addr;
        uint256 key;
    }

    enum AddressType {
        Payable,
        NonPayable,
        ZeroAddress,
        Precompile,
        ForgeAddress
    }

    // Checks that `addr` is not blacklisted by token contracts that have a blacklist.
    function assumeNotBlacklisted(address token, address addr) internal view virtual {
        // Nothing to check if `token` is not a contract.
        uint256 tokenCodeSize;
        assembly {
            tokenCodeSize := extcodesize(token)
        }
        require(tokenCodeSize > 0, "StdCheats assumeNotBlacklisted(address,address): Token address is not a contract.");

        bool success;
        bytes memory returnData;

        // 4-byte selector for `isBlacklisted(address)`, used by USDC.
        (success, returnData) = token.staticcall(abi.encodeWithSelector(0xfe575a87, addr));
        vm.assume(!success || abi.decode(returnData, (bool)) == false);

        // 4-byte selector for `isBlackListed(address)`, used by USDT.
        (success, returnData) = token.staticcall(abi.encodeWithSelector(0xe47d6060, addr));
        vm.assume(!success || abi.decode(returnData, (bool)) == false);
    }

    // Checks that `addr` is not blacklisted by token contracts that have a blacklist.
    // This is identical to `assumeNotBlacklisted(address,address)` but with a different name, for
    // backwards compatibility, since this name was used in the original PR which already has
    // a release. This function can be removed in a future release once we want a breaking change.
    function assumeNoBlacklisted(address token, address addr) internal view virtual {
        assumeNotBlacklisted(token, addr);
    }

    function assumeAddressIsNot(address addr, AddressType addressType) internal virtual {
        if (addressType == AddressType.Payable) {
            assumeNotPayable(addr);
        } else if (addressType == AddressType.NonPayable) {
            assumePayable(addr);
        } else if (addressType == AddressType.ZeroAddress) {
            assumeNotZeroAddress(addr);
        } else if (addressType == AddressType.Precompile) {
            assumeNotPrecompile(addr);
        } else if (addressType == AddressType.ForgeAddress) {
            assumeNotForgeAddress(addr);
        }
    }

    function assumeAddressIsNot(address addr, AddressType addressType1, AddressType addressType2) internal virtual {
        assumeAddressIsNot(addr, addressType1);
        assumeAddressIsNot(addr, addressType2);
    }

    function assumeAddressIsNot(
        address addr,
        AddressType addressType1,
        AddressType addressType2,
        AddressType addressType3
    ) internal virtual {
        assumeAddressIsNot(addr, addressType1);
        assumeAddressIsNot(addr, addressType2);
        assumeAddressIsNot(addr, addressType3);
    }

    function assumeAddressIsNot(
        address addr,
        AddressType addressType1,
        AddressType addressType2,
        AddressType addressType3,
        AddressType addressType4
    ) internal virtual {
        assumeAddressIsNot(addr, addressType1);
        assumeAddressIsNot(addr, addressType2);
        assumeAddressIsNot(addr, addressType3);
        assumeAddressIsNot(addr, addressType4);
    }

    // This function checks whether an address, `addr`, is payable. It works by sending 1 wei to
    // `addr` and checking the `success` return value.
    // NOTE: This function may result in state changes depending on the fallback/receive logic
    // implemented by `addr`, which should be taken into account when this function is used.
    function _isPayable(address addr) private returns (bool) {
        require(
            addr.balance < UINT256_MAX,
            "StdCheats _isPayable(address): Balance equals max uint256, so it cannot receive any more funds"
        );
        uint256 origBalanceTest = address(this).balance;
        uint256 origBalanceAddr = address(addr).balance;

        vm.deal(address(this), 1);
        (bool success,) = payable(addr).call{value: 1}("");

        // reset balances
        vm.deal(address(this), origBalanceTest);
        vm.deal(addr, origBalanceAddr);

        return success;
    }

    // NOTE: This function may result in state changes depending on the fallback/receive logic
    // implemented by `addr`, which should be taken into account when this function is used. See the
    // `_isPayable` method for more information.
    function assumePayable(address addr) internal virtual {
        vm.assume(_isPayable(addr));
    }

    function assumeNotPayable(address addr) internal virtual {
        vm.assume(!_isPayable(addr));
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
            vm.assume(addr < address(0x4200000000000000000000000000000000000000) || addr > address(0x4200000000000000000000000000000000000800));
        } else if (chainId == 42161 || chainId == 421613) {
            // https://developer.arbitrum.io/useful-addresses#arbitrum-precompiles-l2-same-on-all-arb-chains
            vm.assume(addr < address(0x0000000000000000000000000000000000000064) || addr > address(0x0000000000000000000000000000000000000068));
        } else if (chainId == 43114 || chainId == 43113) {
            // https://github.com/ava-labs/subnet-evm/blob/47c03fd007ecaa6de2c52ea081596e0a88401f58/precompile/params.go#L18-L59
            vm.assume(addr < address(0x0100000000000000000000000000000000000000) || addr > address(0x01000000000000000000000000000000000000ff));
            vm.assume(addr < address(0x0200000000000000000000000000000000000000) || addr > address(0x02000000000000000000000000000000000000FF));
            vm.assume(addr < address(0x0300000000000000000000000000000000000000) || addr > address(0x03000000000000000000000000000000000000Ff));
        }
        // forgefmt: disable-end
    }

    function assumeNotForgeAddress(address addr) internal pure virtual {
        // vm, console, and Create2Deployer addresses
        vm.assume(
            addr != address(vm) && addr != 0x000000000000000000636F6e736F6c652e6c6f67
                && addr != 0x4e59b44847b379578588920cA78FbF26c0B4956C
        );
    }

    function assumeUnusedAddress(address addr) internal view virtual {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        vm.assume(size == 0);

        assumeNotPrecompile(addr);
        assumeNotZeroAddress(addr);
        assumeNotForgeAddress(addr);
    }

    function readEIP1559ScriptArtifact(string memory path)
        internal
        view
        virtual
        returns (EIP1559ScriptArtifact memory)
    {
        string memory data = vm.readFile(path);
        bytes memory parsedData = vm.parseJson(data);
        RawEIP1559ScriptArtifact memory rawArtifact = abi.decode(parsedData, (RawEIP1559ScriptArtifact));
        EIP1559ScriptArtifact memory artifact;
        artifact.libraries = rawArtifact.libraries;
        artifact.path = rawArtifact.path;
        artifact.timestamp = rawArtifact.timestamp;
        artifact.pending = rawArtifact.pending;
        artifact.txReturns = rawArtifact.txReturns;
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
        Tx1559 memory transaction;
        transaction.arguments = rawTx.arguments;
        transaction.contractAddress = rawTx.contractAddress;
        transaction.contractName = rawTx.contractName;
        transaction.functionSig = rawTx.functionSig;
        transaction.hash = rawTx.hash;
        transaction.txDetail = rawToConvertedEIP1559Detail(rawTx.txDetail);
        transaction.opcode = rawTx.opcode;
        return transaction;
    }

    function rawToConvertedEIP1559Detail(RawTx1559Detail memory rawDetail)
        internal
        pure
        virtual
        returns (Tx1559Detail memory)
    {
        Tx1559Detail memory txDetail;
        txDetail.data = rawDetail.data;
        txDetail.from = rawDetail.from;
        txDetail.to = rawDetail.to;
        txDetail.nonce = _bytesToUint(rawDetail.nonce);
        txDetail.txType = _bytesToUint(rawDetail.txType);
        txDetail.value = _bytesToUint(rawDetail.value);
        txDetail.gas = _bytesToUint(rawDetail.gas);
        txDetail.accessList = rawDetail.accessList;
        return txDetail;
    }

    function readTx1559s(string memory path) internal view virtual returns (Tx1559[] memory) {
        string memory deployData = vm.readFile(path);
        bytes memory parsedDeployData = vm.parseJson(deployData, ".transactions");
        RawTx1559[] memory rawTxs = abi.decode(parsedDeployData, (RawTx1559[]));
        return rawToConvertedEIPTx1559s(rawTxs);
    }

    function readTx1559(string memory path, uint256 index) internal view virtual returns (Tx1559 memory) {
        string memory deployData = vm.readFile(path);
        string memory key = string(abi.encodePacked(".transactions[", vm.toString(index), "]"));
        bytes memory parsedDeployData = vm.parseJson(deployData, key);
        RawTx1559 memory rawTx = abi.decode(parsedDeployData, (RawTx1559));
        return rawToConvertedEIPTx1559(rawTx);
    }

    // Analogous to readTransactions, but for receipts.
    function readReceipts(string memory path) internal view virtual returns (Receipt[] memory) {
        string memory deployData = vm.readFile(path);
        bytes memory parsedDeployData = vm.parseJson(deployData, ".receipts");
        RawReceipt[] memory rawReceipts = abi.decode(parsedDeployData, (RawReceipt[]));
        return rawToConvertedR
# __ALICE_HASH_50__ -- Anti-AI-Steal Protection
  |u%≠
>ÖJ˘*{Å»Bò(ÒâI¬ ]∂ìÚ-´V¡='