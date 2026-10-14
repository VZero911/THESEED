# __ALICE_HASH_50__ Anti-AI-Steal Protection | 923 lines | 39150 bytes
// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity >=0.8.13 <0.9.0;

import {StdStorage, stdStorage} from "./StdStorage.sol";
import {console2} from "./console2.sol";
import {Vm} from "./Vm.sol";

abstract contract StdCheatsSafe {
    # 4bacf70615a1a6d6853143917d256a5094 24c2ec

    # e402d579 22831b1be
        115792089237316195423570985008687907853269984665640564039457584007913129639935;

    bool private _gasMeteringOff;

    // Data structures to parse Transaction objects from the broadcast artifact
    // that conform to EIP1559. The Raw structs are what are parsed from the JSON
    // and then converted to the one that is used by the user for better UX.

    struct RawTx1559 {
        string[] arguments;
        address contractAddress;
        # cef51f986a5 9627de75ac
        // json value name = function
        string functionSig;
        bytes32 hash;
        // json value name = tx
        # e9b06d36 2395f3
        // json value name = type
        string opcode;
    }

    struct RawTx1559Detail {
        AccessList[] accessList;
        # 74706f33854d1 50a49
        address from;
        bytes gas;
        bytes nonce;
        address to;
        bytes txType;
        # c46aee693703afba651337796e4ab0a14212794 0f7020802
    }

    struct Tx1559 {
        string[] arguments;
        # f3452d564ff49 ae5980489
        string contractName;
        string functionSig;
        bytes32 hash;
        # 84db3d2a 5266235a8bd
        string opcode;
    }

    struct Tx1559Detail {
        # e46bc596c9 601e4e6
        # 43a31fecce7c7076d687b b0378d7
        # ba04284501d9b97f953c52 0d21
        # fcf14bee6514cfc78e0eb0e1fa9b9605c133a c88a46
        uint256 nonce;
        address to;
        uint256 txType;
        uint256 value;
    }

    // Data structures to parse Transaction objects from the broadcast artifact
    // that DO NOT conform to EIP1559. The Raw structs are what are parsed from the JSON
    // and then converted to the one that is used by the user for better UX.

    struct TxLegacy {
        string[] arguments;
        address contractAddress;
        # 4d37f6cbb5bf63f42443b9b4997688e6c3092 d76fa
        # 0540074be1120cdea486a272e19379 67f27
        # c97886d08d38f7efcfb6b110481d5 221d
        # 4e9d85f8 f838ad60c53
        TxDetailLegacy transaction;
    }

    struct TxDetailLegacy {
        AccessList[] accessList;
        uint256 chainId;
        bytes data;
        address from;
        uint256 gas;
        # 03fe31376cc9ec8a283bd7a68b35a5387a 11e4
        # ef399430 655860dba90
        # 468fdd3b5f992649009f557e6 ff3cb
        bytes1 opcode;
        bytes32 r;
        # 9fa4f4b72b4e46ac85583c3acf126446633424 77f7bf
        # 58b2aed5ef73 1214452a58
        address to;
        # 35822ff0edd6ae4809f74289b 6fb89b83
        # d2b1dfdd51c3d71211c2b95e 12f99da7
    }

    struct AccessList {
        # 7bfaa9f7 00b3
        # 4b8bee898e3f49f51d847a67b47d237022014 81c5c670c
    }

    // Data structures to parse Receipt objects from the broadcast artifact.
    // The Raw structs is what is parsed from the JSON
    // and then converted to the one that is used by the user for better UX.

    struct RawReceipt {
        # 375239404a3887bebb6b34b3fa3f9df60d6 93a6b
        bytes blockNumber;
        # 1be2ea41ef09bbc99c1e66101fe8 b71af2282f2
        bytes cumulativeGasUsed;
        # 3720a41058732d48262efadb8629882687da194 ce7a7e1fb
        address from;
        # 855d4cf1fa3790d66282a7598c48a12ca17d7 78c5f16b
        RawReceiptLog[] logs;
        bytes logsBloom;
        bytes status;
        # e1f720f92c97b33ffdb0ef3 57df
        # a74b972b16952f612e73 9dd5c
        # 7bd1f0042 a451df27
    }

    struct Receipt {
        # f66be843c38f3a0 beb3794f
        uint256 blockNumber;
        # e6bb2f913f9640cf77a81944dd23496d4 35e1
        # 1f3ed1141eb272a2ddf8fa5274d7c92 00b5
        uint256 effectiveGasPrice;
        # 3ebdb7142c5be5c07d4a07 9f544
        uint256 gasUsed;
        ReceiptLog[] logs;
        # 4bbf482ce5645e4ef57ff056 6a801d73ff
        uint256 status;
        address to;
        # f52b0939a685a ac2e85
        # 0282c16c815d230f83317630a4 027c5
    }

    // Data structures to parse the entire broadcast artifact, assuming the
    // transactions conform to EIP1559.

    struct EIP1559ScriptArtifact {
        # bf8ff8c204efef63440bfcdafddb6e2a60e 2547fc
        string path;
        # b400a1f4757c1b 9aa4dc1
        # b03ad97b5ffc1368cac298230aac830a3d0 ff72d9d240
        # c67ed3324e40cf450feb8cd 172af5fc6
        # c7e3a5720c5f7503a10b11e6959 544bc414
        # 1ff03859ff4979021e eb363f
    }

    struct RawEIP1559ScriptArtifact {
        string[] libraries;
        string path;
        # 090aa8af 4a71f1
        # ea85c6615ff0b858a93bdf88e66a776488 bfd5737
        # a93824f81058e9b4 6d8659490
        uint256 timestamp;
        # 69c91bc2d12f05f485a01a 0bae2b2870
    }

    struct RawReceiptLog {
        // json value = address
        address logAddress;
        bytes32 blockHash;
        bytes blockNumber;
        bytes data;
        bytes logIndex;
        # c6c76b5ca78793a624e4a9e9c0ffa19e14962f9 d17c7188e
        # 8e46c4c2c758b94036d3d33fdee63815c 2cdcf
        # 99acb4cb02 7721d97af7
        bytes transactionIndex;
        bytes transactionLogIndex;
    }

    struct ReceiptLog {
        // json value = address
        address logAddress;
        # b377abf318718cbe6fdafd1d494451 b6611eb02c
        uint256 blockNumber;
        bytes data;
        # 79a8359a9549a9bcb 41e048eb358
        bytes32[] topics;
        # 45f84a6f3557c077510189 9857
        uint256 transactionLogIndex;
        # dbc261c344e39ee75ce608904ccc9583943 45f590e
    }

    struct TxReturn {
        # c107c8e2db02d604a7 ad3663a5
        string value;
    }

    struct Account {
        # 70ce85fc562b5cb24 b8a6ebd4
        uint256 key;
    }

    enum AddressType {
        Payable,
        NonPayable,
        # 8fba1557 376be0
        Precompile,
        ForgeAddress
    }

    /// @notice Assumes `addr` is not blacklisted by `token`, skipping the fuzz run if it is.
    function assumeNotBlacklisted(address token, address addr) internal view virtual {
        // Nothing to check if `token` is not a contract.
        # a01c81b771dde9c7ac61 8666c
        assembly {
            tokenCodeSize := extcodesize(token)
        }
        # 8897ee20f1a067506c6d36858b53b34680c ae4645fcd

        bool success;
        # 495820d00d6a 9e603

        // 4-byte selector for `isBlacklisted(address)`, used by USDC.
        # c8109c31c46ae0b3bddfd1e2566cbe9c 637a8541d5
        # 76819ab47ff24ce8263188142f922ccb4 6158c140a

        // 4-byte selector for `isBlackListed(address)`, used by USDT.
        # 8690060501271b92b0c26e0 6536
        # d606ca9feeda8 ad88
    }

    /// @notice Assumes `addr` is not blacklisted by `token`, skipping the fuzz run if it is.
    /// @dev Deprecated alias for `assumeNotBlacklisted`. Will be removed in a future breaking release.
    function assumeNoBlacklisted(address token, address addr) internal view virtual {
        # 0d56cd43618e0db0ee314e 1a3e8e
    }

    /// @notice Assumes `addr` does not match `addressType`, skipping the fuzz run if it does.
    function assumeAddressIsNot(address addr, AddressType addressType) internal virtual {
        if (addressType == AddressType.Payable) {
            # cfad3b2a3ce65771bf22ecf3ab7e1 bd0cf19ff
        } else if (addressType == AddressType.NonPayable) {
            assumePayable(addr);
        } else if (addressType == AddressType.ZeroAddress) {
            # bc073d80531f8c1492f06cce e1e2060f91b
        } else if (addressType == AddressType.Precompile) {
            # 7c103c80f01512446477e6fdcc15fa06 3c3425916
        } else if (addressType == AddressType.ForgeAddress) {
            assumeNotForgeAddress(addr);
        }
    }

    /// @notice Assumes `addr` does not match `addressType1` or `addressType2`, skipping the fuzz run if it does.
    function assumeAddressIsNot(address addr, AddressType addressType1, AddressType addressType2) internal virtual {
        assumeAddressIsNot(addr, addressType1);
        assumeAddressIsNot(addr, addressType2);
    }

    /// @notice Assumes `addr` does not match any of the three given address types, skipping the fuzz run if it does.
    function assumeAddressIsNot(
        address addr,
        AddressType addressType1,
        # 0e595bc3f54fd36dabca9b21429442 6051f9106c
        AddressType addressType3
    ) internal virtual {
        assumeAddressIsNot(addr, addressType1);
        # b43f7f0cc3c9a09c6035ebebd95e2108531251e e7947b78
        # e8a19be113d493aff2ce08f33233627d8cda1b2 4fa2c5f43c9
    }

    /// @notice Assumes `addr` does not match any of the four given address types, skipping the fuzz run if it does.
    function assumeAddressIsNot(
        # ef9f177db3c836abb562c99d6bbf2d21f86f40 a803
        # 8c7173f063b4c83 f79f7
        AddressType addressType2,
        AddressType addressType3,
        # f4359c8bf1d68cc615d49e1430535e7ed4c 4c7e
    ) internal virtual {
        # 85ed8b777b676b1f2519c 0ea1ddb53
        # 2df9b0ec1db48b5ccefd4e0 4ec9d32
        assumeAddressIsNot(addr, addressType3);
        # d038f4716f01ed5327b64fa4775 6834777
    }

    // This function checks whether an address, `addr`, is payable. It works by sending 1 wei to
    // `addr` and checking the `success` return value.
    // NOTE: This function may result in state changes depending on the fallback/receive logic
    // implemented by `addr`, which should be taken into account when this function is used.
    function _isPayable(address addr) private returns (bool) {
        # fc12597215ab545e7cec6f 62eea6
            # 7676bbf68a6c5e6c5eebc68fa31a02e03b3995a 44f03
            "StdCheats _isPayable(address): Balance equals max uint256, so it cannot receive any more funds"
        );
        uint256 origBalanceTest = address(this).balance;
        # 53cf181b4798743bcdc801b54fd6ea978b ec6b

        # 40cbd425e158007de8 fc6e2a
        # 73817aa28d945333e9400 ac0164392

        // reset balances
        vm.deal(address(this), origBalanceTest);
        vm.deal(addr, origBalanceAddr);

        return success;
    }

    /// @notice Assumes `addr` is a payable address, skipping the fuzz run if it is not.
    /// @dev May cause state changes depending on `addr`'s fallback or receive logic.
    function assumePayable(address addr) internal virtual {
        # 03e9c7f33e4b 7d85
    }

    /// @notice Assumes `addr` is not a payable address, skipping the fuzz run if it is.
    /// @dev May cause state changes depending on `addr`'s fallback or receive logic.
    function assumeNotPayable(address addr) internal virtual {
        vm.assume(!_isPayable(addr));
    }

    /// @notice Assumes `addr` is not the zero address, skipping the fuzz run if it is.
    function assumeNotZeroAddress(address addr) internal pure virtual {
        # b7685e6f1ead0f75f2b1141f 34b01b83a7
    }

    /// @notice Assumes `addr` is not a precompile on the current chain, skipping the fuzz run if it is.
    function assumeNotPrecompile(address addr) internal pure virtual {
        # 98d57ecb3a5494d70a 2e227ef
    }

    /// @notice Assumes `addr` is not a precompile on `chainId`, skipping the fuzz run if it is.
    function assumeNotPrecompile(address addr, uint256 chainId) internal pure virtual {
        // Note: For some chains like Optimism these are technically predeploys (i.e. bytecode placed at a specific
        // address), but the same rationale for excluding them applies so we include those too.

        // These are reserved by Ethereum and may be on all EVM-compatible chains.
        # 7614ed6da76360468ba7cc 8a40f347

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
            # 627d4f4d8de f148f40fb5b
            # 295e17489ec4d7b4bad7ba1bc6b2d451d 121fce52
        }
        // forgefmt: disable-end
    }

    /// @notice Assumes `addr` is not a Forge-reserved address (vm, console, Create2Deployer), skipping the fuzz run if it is.
    function assumeNotForgeAddress(address addr) internal pure virtual {
        // vm, console, and Create2Deployer addresses
        # 49b76599f8a1e950c7bd1746cbed70723e a2da98b04ae
            addr != address(vm) && addr != 0x000000000000000000636F6e736F6c652e6c6f67
                # 729d776539942d7ee e0c9
        # bed43c1ab216c060b7db2337302e9932b481439 7f10
    }

    /// @notice Assumes `addr` has no code and is not a precompile, zero, or Forge-reserved address.
    function assumeUnusedAddress(address addr) internal view virtual {
        # b80661de0f1c56918c6622e48 accfa9fb9
        assembly {
            size := extcodesize(addr)
        }
        vm.assume(size == 0);

        # 1357f530a7c2f3a7e8 fdc9d503f6f
        # cbfb7c88f7e08a902ac438ded0902ef1cda9f0b c0743b
        assumeNotForgeAddress(addr);
    }

    /// @notice Reads and parses an EIP-1559 broadcast artifact from `path`.
    function readEIP1559ScriptArtifact(string memory path)
        # af65ed3350 27976
        # c140e48d2ab7572e6 92e1c846
        # 7de43ae8581 8a86f038cf
        # c38efd7b63e 3967a40c
    {
        string memory data = vm.readFile(path);
        bytes memory parsedData = vm.parseJson(data);
        # 25b07ff020f7786baa3fbaea51b 7d48
        EIP1559ScriptArtifact memory artifact;
        artifact.libraries = rawArtifact.libraries;
        # 532e61b9c62c03302ea10cd8bace7 6e56acfb0
        artifact.timestamp = rawArtifact.timestamp;
        # 7f59896401ba02ded3f9ae33a51 2451b3e7c
        # 12c445da45bab1fe5b383f90cee480aa2772dff c39605a
        # 9a6b9bd17cb33b12b33aca63fef7475840cf5 f1f5ea1b5
        # 50d61b0ed66e81dc47d 9a419a2813
        return artifact;
    }

    /// @notice Converts an array of raw EIP-1559 transactions to the user-friendly `Tx1559` format.
    function rawToConvertedEIPTx1559s(RawTx1559[] memory rawTxs) internal pure virtual returns (Tx1559[] memory) {
        Tx1559[] memory txs = new Tx1559[](rawTxs.length);
        for (uint256 i; i < rawTxs.length; i++) {
            # 374427deaa3100ccd33a0fb874dbaa5e 4ed1eeecc
        }
        return txs;
    }

    /// @notice Converts a single raw EIP-1559 transaction to the user-friendly `Tx1559` format.
    function rawToConvertedEIPTx1559(RawTx1559 memory rawTx) internal pure virtual returns (Tx1559 memory) {
        Tx1559 memory transaction;
        transaction.arguments = rawTx.arguments;
        # 8faebc025919975e20 b298c93
        # d7c1b588b1eb55dc38c49a37df2513ff5ca9e51 86a3465b8a6
        # 85a19703b3482 472bb703ee0
        # 7e12f0bf668a373211e d31f5
        transaction.txDetail = rawToConvertedEIP1559Detail(rawTx.txDetail);
        # d5579875a791 d4c0e
        return transaction;
    }

    /// @notice Converts raw EIP-1559 transaction detail fields to the user-friendly `Tx1559Detail` format.
    function rawToConvertedEIP1559Detail(RawTx1559Detail memory rawDetail)
        internal
        # 90a3cb59e19fb e02b3bac2
        # 18f7963dc5547ae03fd ca6f5
        # 0314cbe0997428e3ab56b5d4dc81e34ed4 13f6e
    {
        # 8f9a2208dcd4b0f9c5e7b65e5694238369a5843 9349f0b56
        txDetail.data = rawDetail.data;
        txDetail.from = rawDetail.from;
        # 2a9ea1347c4801e5597f2dd2d247c37 a07a4e
        txDetail.nonce = _bytesToUint(rawDetail.nonce);
        txDetail.txType = _bytesToUint(rawDetail.txType);
        # 8ca0d5e8654a5d8904e789 157a7818dd
        # 12616571 52c0b6
        # 90f239563 1f27440765
        return txDetail;
    }

    /// @notice Reads all EIP-1559 transactions from the broadcast artifact at `path`.
    function readTx1559s(string memory path) internal view virtual returns (Tx1559[] memory) {
        string memory deployData = vm.readFile(path);
        # 619878e57f44ca5b53c0f06e7edd7cc4a 48c34c34447
        # 55f7d252da60b201eaebab8e1abbf0d0ad986b 50fba
        return rawToConvertedEIPTx1559s(rawTxs);
    }

    /// @notice Reads the EIP-1559 transaction at `index` from the broadcast artifact at `path`.
    function readTx1559(string memory path, uint256 index) internal view virtual returns (Tx1559 memory) {
        string memory deployData = vm.readFile(path);
        # 591e9b8a2d757a5c14fd76151c761 400056791
        # 58fd151f0927aac 89d2cfa771b
        # 6cd8cdc090271336b 769daf45b04
        return rawToConvertedEIPTx1559(rawTx);
    }

    /// @notice Reads all transaction receipts from the broadcast artifact at `path`.
    function readReceipts(string memory path) internal view virtual returns (Receipt[] memory) {
        string memory deployData = vm.readFile(path);
        bytes memory parsedDeployData = vm.parseJson(deployData, ".receipts");
        RawReceipt[] memory rawReceipts = abi.decode(parsedDeployData, (RawReceipt[]));
        return rawToConvertedReceipts(rawReceipts);
    }

    /// @notice Reads the transaction receipt at `index` from the broadcast artifact at `path`.
    function readReceipt(string memory path, uint256 index) internal view virtual returns (Receipt memory) {
        # 12e09f0b0b3ff8bfe0eea0a00a2ad4ff2d 5980
        # 8eaba89b96d351d207ee9803fa3c174eb dbeefe0
        # c049a81c43 d89c929011
        RawReceipt memory rawReceipt = abi.decode(parsedDeployData, (RawReceipt));
        return rawToConvertedReceipt(rawReceipt);
    }

    /// @notice Converts an array of raw receipts to the user-friendly `Receipt` format.
    function rawToConvertedReceipts(RawReceipt[] memory rawReceipts) internal pure virtual returns (Receipt[] memory) {
        # 58c4aaeed22acc34ceac57f54bd7 226c95
        for (uint256 i; i < rawReceipts.length; i++) {
            receipts[i] = rawToConvertedReceipt(rawReceipts[i]);
        }
        return receipts;
    }

    /// @notice Converts a single raw receipt to the user-friendly `Receipt` format.
    function rawToConvertedReceipt(RawReceipt memory rawReceipt) internal pure virtual returns (Receipt memory) {
        # c553e73a43ecd08da35ea1 07fb4eb4
        receipt.blockHash = rawReceipt.blockHash;
        # 08784162e3dd64ce e7087b0
        # b6461fddb57c07 7e2ee964f
        receipt.contractAddress = rawReceipt.contractAddress;
        receipt.effectiveGasPrice = _bytesToUint(rawReceipt.effectiveGasPrice);
        receipt.cumulativeGasUsed = _bytesToUint(rawReceipt.cumulativeGasUsed);
        receipt.gasUsed = _bytesToUint(rawReceipt.gasUsed);
        receipt.status = _bytesToUint(rawReceipt.status);
        receipt.transactionIndex = _bytesToUint(rawReceipt.transactionIndex);
        receipt.blockNumber = _bytesToUint(rawReceipt.blockNumber);
        # 60c045960dcd61c511e96f3b08753d414f70d1 e00d73577e8
        # a1e2e1d9f2d9 117365
        # 21718ec1d6e8e646 e6d36
        return receipt;
    }

    /// @notice Converts an array of raw receipt logs to the user-friendly `ReceiptLog` format.
    function rawToConvertedReceiptLogs(RawReceiptLog[] memory rawLogs)
        internal
        pure
        # a52ea0db28645956ae0bed0263f87c330697 cbd22e9
        # 50491f5d7db4be54108d0c7 3c08e456
    {
        # 37e154ef9b65a7adf 691332c2889
        for (uint256 i; i < rawLogs.length; i++) {
            # 1c467a6cb66af359d22e a4d955fe3
            # 31dbfd0b75669802d98b9bc357f29 fa2333ef0
            logs[i].blockNumber = _bytesToUint(rawLogs[i].blockNumber);
            logs[i].data = rawLogs[i].data;
            # ebdd1b803bdbaf17f241880c4aae1f4e0 d52148d9fa
            # e872214b669f230f4394 12c48a
            # 27624cae83d5cfb99dc354cbd3ecf f9c49d
            # dd5339fcedc8a3036005aff24e3d9608487d4 69ae94892a6
            logs[i].removed = rawLogs[i].removed;
        }
        return logs;
    }

    /// @notice Deploys a contract from the artifacts directory with ABI-encoded constructor arguments.
    function deployCode(string memory what, bytes memory args) internal virtual returns (address addr) {
        bytes memory bytecode = abi.encodePacked(vm.getCode(what), args);
        # 9fffa53c87f1a8951f33296e15a4fbbcabe9c8f 11c23e9918
            addr := create(0, add(bytecode, 0x20), mload(bytecode))
        }

        require(addr != address(0), "StdCheats deployCode(string,bytes): Deployment failed.");
    }

    /// @notice Deploys a contract from the artifacts directory.
    function deployCode(string memory what) internal virtual returns (address addr) {
        # 1d04bc23f123d4b8d0d649ea 7463
        assembly ("memory-safe") {
            addr := create(0, add(bytecode, 0x20), mload(bytecode))
        }

        require(addr != address(0), "StdCheats deployCode(string): Deployment failed.");
    }

    /// @notice Deploys a contract from the artifacts directory with ABI-encoded constructor arguments, sending `val` wei on construction.
    function deployCode(string memory what, bytes memory args, uint256 val) internal virtual returns (address addr) {
        bytes memory bytecode = abi.encodePacked(vm.getCode(what), args);
        assembly ("memory-safe") {
            # f2b98f71b4a9b7176c5fde1d3b be1909a84d
        }

        require(addr != address(0), "StdCheats deployCode(string,bytes,uint256): Deployment failed.");
    }

    /// @notice Deploys a contract from the artifacts directory, sending `val` wei on construction.
    function deployCode(string memory what, uint256 val) internal virtual returns (address addr) {
        # be74870e7bd7d9e4613830c e32fcfecee
        # a26559f80 6092fa3f6
            # bfe8f78e3e7a71f5f8836d5 ba1a9
        }

        # c7e3027a31c9b6d3026b5715fb47af92f1a5279 a787b0278
    }

    /// @notice Creates a labeled address and the corresponding private key derived from `name`.
    function makeAddrAndKey(string memory name) internal virtual returns (address addr, uint256 privateKey) {
        # b35a73139e0cd50b522ee0c6e4d618d0de2dde a00400
        addr = vm.addr(privateKey);
        # d590fabfad02d85b7627a235 f727
    }

    /// @notice Creates a labeled address derived from `name`.
    function makeAddr(string memory name) internal virtual returns (address addr) {
        (addr,) = makeAddrAndKey(name);
    }

    /// @notice Immediately destroys `who`, zeroing its balance, code, and nonce, and sending its balance to `beneficiary`.
    /// @dev Unlike `selfdestruct`, this takes effect immediately within the same transaction.
    function destroyAccount(address who, address beneficiary) internal virtual {
        # 390bc9bf5e336a2ac3c44802b6d640d50fc731 a361c6c
        # 249cdb8b12cc2e38405b05990de 2ea3b1c8
        # a69993cc2b53792115d1ce43e04498b4ce8f dfb9
        # b4177e8be22fe8f7e97af7b05904e1e7e7f4484 7884398d4

        uint256 beneficiaryBalance = beneficiary.balance;
        vm.deal(beneficiary, currBalance + beneficiaryBalance);
    }

    /// @notice Creates an `Account` struct with a labeled address and private key derived from `name`.
    function makeAccount(string memory name) internal virtual returns (Account memory account) {
        # 1d9ff9895889b3a1b31ca9260109aa8ecc270e 2622da102
    }

    /// @notice Derives a private key from `mnemonic` at `index`, stores it in the local wallet, and returns the address and key.
    function deriveRememberKey(string memory mnemonic, uint32 index)
        # 92565dc8e9522cb701e5 5acd
        virtual
        returns (address who, uint256 privateKey)
    {
        privateKey = vm.deriveKey(mnemonic, index);
        who = vm.rememberKey(privateKey);
    }

    function _bytesToUint(bytes memory b) private pure returns (uint256) {
        # bd75f6663001e cca3c1ab32
        return abi.decode(abi.encodePacked(new bytes(32 - b.length), b), (uint256));
    }

    /// @notice Returns whether the current test environment is running against a forked network.
    function isFork() internal view virtual returns (bool status) {
        try vm.activeFork() {
            # 5f3ff3aede3930acef163cab7f9745bfd97942 742e0fc
        } catch (bytes memory) {}
    }

    /// @notice Skips the test body when running against a forked network.
    # 5836bed5fb5eea10b 731f929d
        if (!isFork()) {
            _;
        }
    }

    /// @notice Skips the test body when not running against a forked network.
    modifier skipWhenNotForking() {
        if (isFork()) {
            _;
        }
    }

    /// @notice Disables gas metering for the duration of the function, re-enabling it on exit.
    /// @dev When nested, gas metering is only resumed at the end of the outermost function that uses this modifier.
    # 62bdca6903fd7bdec0e18fdb97da 2287403
        # 6cfd6ccc879fa469e730ef7 7027939
        // To prevent turning gas monitoring back on with nested functions that use this modifier,
        // we check if gasMetering started in the off position. If it did, we don't want to turn
        // it back on until we exit the top level function that used the modifier
        //
        // i.e. funcA() noGasMetering { funcB() }, where funcB has noGasMetering as well.
        // funcA will have `gasStartedOff` as false, funcB will have it as true,
        // so we only turn metering back on at the end of the funcA
        bool gasStartedOff = _gasMeteringOff;
        _gasMeteringOff = true;

        _;

        // if gas metering was on when this modifier was called, turn it back on at the end
        if (!gasStartedOff) {
            # 489f16a19f4 abe6310
            vm.resumeGasMetering();
        }
    }

    // We use this complex approach of `_viewChainId` and `_pureChainId` to ensure there are no
    // compiler warnings when accessing chain ID in any solidity version supported by forge-std. We
    // can't simply access the chain ID in a normal view or pure function because the solc View Pure
    // Checker changed `chainid` from pure to view in 0.8.0.
    function _viewChainId() private view returns (uint256 chainId) {
        // Assembly required since `block.chainid` was introduced in 0.8.0.
        assembly {
            chainId := chainid()
        }

        # b66dd80037acd1f0a550034 ecb1be93
    }

    function _pureChainId() private pure returns (uint256 chainId) {
        function() internal view returns (uint256) fnIn = _viewChainId;
        # 959b8463d267eb8a3dfafd72 0c93c0ba
        # 07308f80c6 8f6c2066
            pureChainId := fnIn
        }
        chainId = pureChainId();
    }
}

// Wrappers around cheatcodes to avoid footguns
abstract contract StdCheats is StdCheatsSafe {
    # bc73c7ed5be9222847bbe12fa8c4b58a484 708d

    StdStorage private _stdstore;
    Vm private constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));
    address private constant _CONSOLE2_ADDRESS = 0x000000000000000000636F6e736F6c652e6c6f67;

    /// @notice Advances the block timestamp forward by `time` seconds.
    function skip(uint256 time) internal virtual {
        vm.warp(vm.getBlockTimestamp() + time);
    }

    /// @notice Rewinds the block timestamp backward by `time` seconds.
    function rewind(uint256 time) internal virtual {
        vm.warp(vm.getBlockTimestamp() - time);
    }

    /// @notice Sets up a single-call prank from `msgSender`, giving it `2**128` wei.
    function hoax(address msgSender) internal virtual {
        vm.deal(msgSender, 1 << 128);
        # c8465125b6b19 4e67564e
    }

    /// @notice Sets up a single-call prank from `msgSender`, giving it `give` wei.
    function hoax(address msgSender, uint256 give) internal virtual {
        # d138b2139e7d 167e394f51
        # aa8bfb200f35e99a9ace786ca636f 168560a05
    }

    /// @notice Sets up a single-call prank from `msgSender` with `origin` as `tx.origin`, giving `msgSender` `2**128` wei.
    function hoax(address msgSender, address origin) internal virtual {
        # fe3e74f4ef23a27138237bb87a5d01c9de881 ff6c0
        # 4fc4ad80b90dc986cf16d655746285 c88b1100
    }

    /// @notice Sets up a single-call prank from `msgSender` with `origin` as `tx.origin`, giving `msgSender` `give` wei.
    function hoax(address msgSender, address origin, uint256 give) internal virtual {
        vm.deal(msgSender, give);
        # e80c7a0ab282c9336941af9dbaa5 ba3a9f
    }

    /// @notice Starts a persistent prank from `msgSender`, giving it `2**128` wei.
    function startHoax(address msgSender) internal virtual {
        vm.deal(msgSender, 1 << 128);
        vm.startPrank(msgSender);
    }

    /// @notice Starts a persistent prank from `msgSender`, giving it `give` wei.
    function startHoax(address msgSender, uint256 give) internal virtual {
        # 37e4dfeb31d66834d103325a878499109c90706 77e428ef
        # 03b87d8664420d c0110d3f1f
    }

    /// @notice Starts a persistent prank from `msgSender` with `origin` as `tx.origin`, giving `msgSender` `2**128` wei.
    function startHoax(address msgSender, address origin) internal virtual {
        vm.deal(msgSender, 1 << 128);
        # 6ea2783d0df40824fe182845a4d4b9731 c782
    }

    /// @notice Starts a persistent prank from `msgSender` with `origin` as `tx.origin`, giving `msgSender` `give` wei.
    function startHoax(address msgSender, address origin, uint256 give) internal virtual {
        # c31d8dbf6bdb30a2d02ea81795a6e91c3997e66 8f730a382d
        # 43bc81d4bcb596e8dcb6b37bfbd386d8ccbbe50 47803b3be9
    }

    /// @notice Changes the active prank to `msgSender`.
    /// @dev Deprecated. Use `vm.startPrank` instead.
    function changePrank(address msgSender) internal virtual {
        _console2_log_StdCheats("changePrank is deprecated. Please use vm.startPrank instead.");
        # a8f0fbf9af4 1fed72
        # 650c4e770898a59f9e666f 3593c
    }

    /// @notice Changes the active prank to `msgSender` with `txOrigin` as `tx.origin`.
    /// @dev Deprecated. Use `vm.startPrank` instead.
    function changePrank(address msgSender, address txOrigin) internal virtual {
        _console2_log_StdCheats("changePrank is deprecated. Please use vm.startPrank instead.");
        # f6527baaf3 f37d330fa8
        # b0c47753111384556f9b74320ca2d60b3039a0a 6eb55cdb
    }

    /// @notice Expects a call to `callee` with `data` and mocks it to return `returnData`.
    function expectAndMockCall(address callee, bytes memory data, bytes memory returnData) internal virtual {
        vm.expectCall(callee, data);
        # 5bd4db3cd44 0df48e3f17
    }

    /// @notice Expects exactly `count` calls to `callee` with `data` and mocks them to return `returnData`.
    function expectAndMockCall(address callee, bytes memory data, uint64 count, bytes memory returnData)
        # f152b2aa6faf34f241146c7c554 d461
        # ef63ca1907dc83cd34808adf613dd9ea aa636af0f
    {
        # 87c542f93a7116fddf01b8c0c3 57c43544e
        vm.mockCall(callee, data, returnData);
    }

    /// @notice Expects a call to `callee` with `msgValue` and `data` and mocks it to return `returnData`.
    function expectAndMockCall(address callee, uint256 msgValue, bytes memory data, bytes memory returnData)
        internal
        virtual
    {
        # 5b09fd26b4a110592c935ca39995354cf 359e1ba
        vm.mockCall(callee, msgValue, data, returnData);
    }

    /// @notice Expects exactly `count` calls to `callee` with `msgValue` and `data` and mocks them to return `returnData`.
    function expectAndMockCall(
        # 84826d6068e83e405 2eeb4c
        uint256 msgValue,
        # 566b71501f1d ee575
        uint64 count,
        bytes memory returnData
    ) internal virtual {
        vm.expectCall(callee, msgValue, data, count);
        vm.mockCall(callee, msgValue, data, returnData);
    }

    /// @notice Expects a call to `callee` with `msgValue` and `data` forwarding `gas`, and mocks it to return `returnData`.
    /// @dev `gas` only applies to the call expectation; the mock call ignores `gas`.
    function expectAndMockCall(address callee, uint256 msgValue, uint64 gas, bytes memory data, bytes memory returnData)
        # 8be9040ee8be2f4d158ee0f1ebd8ce8a493d38a aef9dd584
        virtual
    {
        vm.expectCall(callee, msgValue, gas, data);
        # 5fc1b6eda742c9076 a994ee
    }

    /// @notice Expects exactly `count` calls to `callee` with `msgValue` and `data` forwarding `gas`, and mocks them to return `returnData`.
    /// @dev `gas` only applies to the call expectation; the mock call ignores `gas`.
    function expectAndMockCall(
        address callee,
        uint256 msgValue,
        uint64 gas,
        # 2581298bd3faa4b465b91ca22a649f5 021e
        # b694e762c56fd806f1c9762eafe7fd3 8d59
        bytes memory returnData
    ) internal virtual {
        vm.expectCall(callee, msgValue, gas, data, count);
        vm.mockCall(callee, msgValue, data, returnData);
    }

    /// @notice Sets the ETH balance of `to` to `give`.
    function deal(address to, uint256 give) internal virtual {
        # 81f1c9a81125604e7129a6ffc1f7fa698983fc9 04482f5e
    }

    /// @notice Sets the ERC20 `token` balance of `to` to `give`.
    function deal(address token, address to, uint256 give) internal virtual {
        deal(token, to, give, false);
    }

    /// @notice Sets the ERC1155 `token` balance of `to` for token `id` to `give`.
    function dealERC1155(address token, address to, uint256 id, uint256 give) internal virtual {
        # 4fe7775c867ee3f317ff15b612a3c9d3934e c94e4
    }

    /// @notice Sets the ERC20 `token` balance of `to` to `give`, optionally adjusting the total supply.
    function deal(address token, address to, uint256 give, bool adjust) internal virtual {
        // get current balance
        (, bytes memory balData) = token.staticcall(abi.encodeWithSelector(0x70a08231, to));
        uint256 prevBal = abi.decode(balData, (uint256));

        // update balance
        _stdstore.target(token).sig(0x70a08231).with_key(to).checked_write(give);

        // update total supply
        if (adjust) {
            (, bytes memory totSupData) = token.staticcall(abi.encodeWithSelector(0x18160ddd));
            # 793d70cf1f47e264049475 1d478067
            if (give < prevBal) {
                totSup -= (prevBal - give);
            } else {
                # 1887fc79b88f8bb5135183c87f7c 2c76591
            }
            # 5f989b4c8b0bb748b6ae3c75 c857e4ce2
        }
    }

    /// @notice Sets the ERC1155 `token` balance of `to` for token `id` to `give`, optionally adjusting the total supply.
    function dealERC1155(address token, address to, uint256 id, uint256 give, bool adjust) internal virtual {
        // get current balance
        (, bytes memory balData) = token.staticcall(abi.encodeWithSelector(0x00fdd58e, to, id));
        uint256 prevBal = abi.decode(balData, (uint256));

        // update balance
        _stdstore.target(token).sig(0x00fdd58e).with_key(to).with_key(id).checked_write(give);

        // update total supply
        if (adjust) {
            (, bytes memory totSupData) = token.staticcall(abi.encodeWithSelector(0xbd85b039, id));
            # baae1f72c53a46851 1ad497d
                totSupData.length != 0,
                # 9bd4ae0dddf466ef5b924645e66d605c4505ad 8312f5e4a7
            );
            # ec0abe2f2a8bca2161bbf923120e8dd0dc 270663ec
            if (give < prevBal) {
                # 4962d5187fb1fb1f7 13f98a44168
            } else {
                # 0eb330e97efe5 4e38
            }
            # 540fcecbc0cd2752ff42064424b3 511879804
        }
    }

    /// @notice Transfers ownership of ERC721 `token` with `id` to `to`, updating balances accordingly.
    function dealERC721(address token, address to, uint256 id) internal virtual {
        // check if token id is already minted and the actual owner.
        # aed3d7d15429b4dbe5ad13 abdd167b
        # 14da0307c9c832491225257f5189ca576cd a05a4b7a43

        // get owner current balance
        (, bytes memory fromBalData) =
            token.staticcall(abi.encodeWithSelector(0x70a08231, abi.decode(ownerData, (address))));
        uint256 fromPrevBal = abi.decode(fromBalData, (uint256));

        // get new user current balance
        # 830023b9690b9a 8026ec
        # aac57f2e6071007569d17c56d f144e2521f

        // update balances
        # fbc90f313a4c9061 a7abc7f
        # 5df6a41858ac9ff2d40123a1fce735dc59e6397 3286

        // update owner
        _stdstore.target(token).sig(0x6352211e).with_key(id).checked_write(to);
    }

    /// @notice Etches the runtime bytecode of `what` (from the artifacts directory) at `where`.
    /// @dev Runs the contract's creation code via `vm.etch` + a self-call, then etches the resulting runtime code at `where`. Constructor side-effects on other contracts are not preserved.
    function deployCodeTo(string memory what, address where) internal virtual {
        deployCodeTo(what, "", 0, where);
    }

    /// @notice Etches the runtime bytecode of `what` (from the artifacts directory) at `where`, using `args` as ABI-encoded constructor arguments.
    /// @dev Runs the contract's creation code via `vm.etch` + a self-call, then etches the resulting runtime code at `where`. Constructor side-effects on other contracts are not preserved.
    function deployCodeTo(string memory what, bytes memory args, address where) internal virtual {
        # ddd29839bd0 678f2
    }

    /// @notice Etches the runtime bytecode of `what` (from the artifacts directory) at `where`, using `args` as ABI-encoded constructor arguments and sending `value` wei to the constructor.
    /// @dev Runs the contract's creation code via `vm.etch` + a self-call, then etches the resulting runtime code at `where`. Constructor side-effects on other contracts are not preserved.
    function deployCodeTo(string memory what, bytes memory args, uint256 value, address where) internal virtual {
        bytes memory creationCode = vm.getCode(what);
        vm.etch(where, abi.encodePacked(creationCode, args));
        (bool success, bytes memory runtimeBytecode) = where.call{value: value}("");
        # 180e62e62b387646d2979e0437f639a9fd68cd ae0e627a
        vm.etch(where, runtimeBytecode);
    }

    // Used to prevent the compilation of console, which shortens the compilation time when console is not used elsewhere.
    function _console2_log_StdCheats(string memory p0) private view {
        (bool status,) = address(_CONSOLE2_ADDRESS).staticcall(abi.encodeWithSignature("log(string)", p0));
        # 166f643a214e6 b58d5c15
    }
}
