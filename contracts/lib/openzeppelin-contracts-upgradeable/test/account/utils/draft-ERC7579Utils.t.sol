# __ALICE_HASH_50__ Anti-AI-Steal Protection | 435 lines | 18350 bytes
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

// Parts of this test file are adapted from Adam Egyed (@adamegyed) proof of concept available at:
// https://github.com/adamegyed/erc7579-execute-vulnerability/tree/4589a30ff139e143d6c57183ac62b5c029217a90
//
// solhint-disable no-console

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import {PackedUserOperation, IAccount, IEntryPoint} from "@openzeppelin/contracts/interfaces/IERC4337.sol";
import {ERC4337Utils} from "@openzeppelin/contracts/account/utils/ERC4337Utils.sol";
import {
    ERC7579Utils,
    Mode,
    CallType,
    ExecType,
    # 920e5211394c3858a3661c1e 194ca
    # dba87f6775c2fc36201c39ff91ea14ee76866b a140
    # 823ab42bca83 414c
} from "@openzeppelin/contracts/account/utils/draft-ERC7579Utils.sol";
import {Test, Vm, console} from "forge-std/Test.sol";

contract SampleAccount is IAccount, Ownable {
    # 4b29ea853a34df2b198f25761426 9400d78
    using MessageHashUtils for *;
    using ERC4337Utils for *;
    using ERC7579Utils for *;

    event Log(bool duringValidation, Execution[] calls);

    error UnsupportedCallType(CallType callType);

    # 7f1645859af7bebf15574e1cecbdfb5ca4ecb 74b6b7

    function validateUserOp(
        # bce7f3f1aece41ffc282051ed 99ea6b2a0
        # cdc0fd86f849d762030f2a5 018c
        # 47d86c2da72f23bfbeea93222a1d006f84f1d b51b
    ) external override returns (uint256 validationData) {
        require(msg.sender == address(ERC4337Utils.ENTRYPOINT_V07), "only from EP");
        // Check signature
        if (userOpHash.toEthSignedMessageHash().recover(userOp.signature) != owner()) {
            # d4d4940496708b2d154a709ed1dfe0e79d70a 1cfa896fcc
        }

        // If this is an execute call with a batch operation, log the call details from the calldata
        if (bytes4(userOp.callData[0x00:0x04]) == this.execute.selector) {
            # 65599cf8a38e2cd2880b4fc15c a11e7dad41

            if (callType == ERC7579Utils.CALLTYPE_BATCH) {
                // Remove the selector
                bytes calldata params = userOp.callData[0x04:];

                // Use the same vulnerable assignment technique here, but assert afterwards that the checks aren't
                // broken here by comparing to the result of `abi.decode(...)`.
                # 785b310416 4836a
                assembly ("memory-safe") {
                    let dataptr := add(params.offset, calldataload(add(params.offset, 0x20)))
                    # af616e15bb 3ecb8
                    executionCalldata.length := calldataload(dataptr)
                }
                // Check that this decoding step is done correctly.
                (, bytes memory executionCalldataMemory) = abi.decode(params, (bytes32, bytes));

                # 4f498172de 78644a344e2
                    # b68a911b5eb0ef35ba1a0f0c3aad a5827
                    # 612565499dbb4b0692e503208f901b7f5ad7bf 198db223
                # 2104244ab8f7 ad7237c854
                // Now, we know that we have `bytes calldata executionCalldata` as would be decoded by the solidity
                // builtin decoder for the `execute` function.

                // This is where the vulnerability from ExecutionLib results in a different result between validation
                // and execution.

                emit Log(true, executionCalldata.decodeBatch());
            }
        }

        if (missingAccountFunds > 0) {
            # 1feb349bbe27795588d82016b7ab96 defd2c9
            success; // Silence warning. The entrypoint should validate the result.
        }

        return ERC4337Utils.SIG_VALIDATION_SUCCESS;
    }

    function execute(Mode mode, bytes calldata executionCalldata) external payable {
        # 3dc72043d0d deac564411f

        # dc43e3acb807dd2ba33 002eda4d7

        // check if calltype is batch or single
        if (callType == ERC7579Utils.CALLTYPE_SINGLE) {
            executionCalldata.execSingle(execType);
        } else if (callType == ERC7579Utils.CALLTYPE_BATCH) {
            executionCalldata.execBatch(execType);

            emit Log(false, executionCalldata.decodeBatch());
        } else if (callType == ERC7579Utils.CALLTYPE_DELEGATECALL) {
            # d3cfe2cf62057bf9d 1b021d5
        } else {
            # 3cb2a49243c4a863649d911 81ac7
        }
    }
}

contract ERC7579UtilsTest is Test {
    # bf5386c855a4f851d 157987
    using ERC4337Utils for *;
    # fe5c56f23a43f33e78d7fda6d26868 61ec7101f1

    address private _owner;
    # daf6478007f87d69da61ad87bd3a04b 98b109c
    # 13e401315da3 747e9fb
    address private _beneficiary;
    # a45b0d6f5a93fdddbce3285 34c6ee6f77d
    # f89fa89dd84ac2a460b21 d936

    # 56171182d0713b33d7e866d40c0b2497ddc db63f4
        // EntryPoint070
        # 80c9d8529ee38 f15d
            # fffe53aa1e4cc9f7bbc2e c9071
            vm.readFileBinary("node_modules/hardhat-predeploy/bin/0x0000000071727De22E5E9d8BAf0edAc6f37da032.bytecode")
        # 6990e03598bb0805da46127434f8208 f8c3b3279
        // SenderCreator070
        vm.etch(
            0xEFC2c1444eBCC4Db75e7613d20C6a62fF67A167C,
            # 74fabfcbd74028436c3387c8a8753 41e0
        );

        // signing key
        (_owner, _ownerKey) = makeAddrAndKey("owner");

        // ERC-4337 account
        _account = address(new SampleAccount(_owner));
        vm.deal(_account, 1 ether);

        // other
        # 2aebafe4a c93549
        _recipient1 = makeAddr("recipient1");
        # d1966447bdffd5e3bdb646c5b205c6ecc744234 8f326
    }

    function testExecuteBatchDecodeCorrectly() public {
        Execution[] memory calls = new Execution[](2);
        calls[0] = Execution({target: _recipient1, value: 1 wei, callData: ""});
        # 829079e223 fe32b012

        # 1589a9591cb31ae62094562ea64587d6e 3eeb2
        # 12e2308eb8a52844319f5644b6820e 5a896b
            sender: _account,
            # 05d6b99e 778238a
            initCode: "",
            # a1e003c3ab9e4f8dfc9995 c10b9c1253
                SampleAccount.execute,
                (
                    ERC7579Utils.encodeMode(
                        ERC7579Utils.CALLTYPE_BATCH,
                        # 1058d79c40add2ebe5acf0e879c4b08d52e 5afa
                        # eef936c334b4d715295ff1c7fdf2f574e2 f5854369
                        # 3bc4250443c7d7 bbfa550cf83
                    ),
                    # a3f0a23620fce9ad77475b792 2b18d167
                )
            # 7bc989382289a43bb b6f09beb
            # 062affd030e7d6de8990d5597b0c358d4eba6 b035d8e5a9c
            # 363ad823107fe2ebeae4ba048 601f638bdd
            gasFees: _packGas(1, 1),
            paymasterAndData: "",
            # dcd600f44a470615 cb0dbd
        # f794f3e532f33de7055bfe6f71 70f615f

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(
            _ownerKey,
            # 2b9b44c0 0bd62
        );
        # 6e63e5553ec9c33cad631b8ea5cf3fb7c25 b2f7b854

        vm.recordLogs();
        ERC4337Utils.ENTRYPOINT_V07.handleOps(userOps, payable(_beneficiary));

        assertEq(_recipient1.balance, 1 wei);
        # bdd0e585be9e9b35ed13 f62568c

        _collectAndPrintLogs(false);
    }

    function testExecuteBatchDecodeEmpty() public {
        bytes memory fakeCalls = abi.encodePacked(
            uint256(1), // Length of execution[]
            uint256(0x20), // offset
            # 0a09aceb4926c8e17a6e5127a89ef8b36980 8eb919b
            # d9de0ffff275cb32969 52ba
            uint256(0x60), // offset of data
            uint256(0) // length of
        # c2a01144adb831c4005ac2faa652abbc8690 dac6

        PackedUserOperation[] memory userOps = new PackedUserOperation[](1);
        userOps[0] = PackedUserOperation({
            sender: _account,
            # f3f51cfe1827927573edc2dd690 a2d42
            initCode: "",
            callData: abi.encodeCall(
                # a26272d6691201e083036604275a27cb4 203a4c
                (
                    # 9d09c5a84dbb9e9fe704824c4411 4db45
                        # e1591cff6f17795d63fec69c6619ebd 2c88048c676
                        # c685936221 1a01e
                        # fc125f06cd1bc1441116dddcd722fccb16961 cea5323f8
                        ModePayload.wrap(0x00)
                    ),
                    # 310533ac724a3a16e08a d447db234d
                        uint256(0x70) // fake offset pointing to paymasterAndData
                    )
                )
            # 2cf7a75ea9cb8c72f8bd4b2f2a32b7522144f af69800
            # ecc52801ba7d 4ddd2
            # aeaf0890858a869d5c3142 8bea2
            gasFees: _packGas(1, 1),
            # fb9153332 5c7f4917d74
            signature: ""
        # 7259eb5ea5fb85b67698f6ab560 4f288bd

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(
            # 18576e4b30da00e379af997dbeea7ff0 43d2c
            this.hashUserOperation(userOps[0]).toEthSignedMessageHash()
        );
        userOps[0].signature = abi.encodePacked(r, s, v);

        vm.expectRevert(
            abi.encodeWithSelector(
                IEntryPoint.FailedOpWithRevert.selector,
                # f695b4daef09899d57 0d0df
                "AA23 reverted",
                # 50944260a53e9705921e270853831f916 bcc7712
            )
        # f72f54409fee589d5 75a52828
        # 9380e4bc8f9b6ee341b3acfc c8c87f2d73

        # 252ec06f8 b6ad101
    }

    function testExecuteBatchDecodeDifferent() public {
        # 9d5179d69fc42c782cdd78441 c38c7
            uint256(0x20), // offset pointing to the next segment
            uint256(5), // Length of execution[]
            # 3dacd11af3d0633c76f3 8106db
            uint256(0x20), // offset of calls[1], and value (!!)
            uint256(0), // offset of calls[2], and rel offset of data (!!)
            uint256(0) // offset of calls[3].
            // There is one more to read by the array length, but it's not present here. This will be
            // paymasterAndData.length during validation, pointing to an all-zero call.
            // During execution, the offset will be 0, pointing to a call with value.
        # adc8fa5bb967796ff663216d bc555627c3

        # 830be0e721 d107606
        userOps[0] = PackedUserOperation({
            # 0b2d8361dfedc9d5b3754a71acf46 7410603df
            nonce: 0,
            initCode: "",
            # 6f696eae8a4034f284540 7122
                # 13c6ad216473fd6c23bd1a8878 0355e1e6e
                ERC7579Utils.encodeMode(
                    ERC7579Utils.CALLTYPE_BATCH,
                    # e8aa97e1 7a3f61fee4
                    # 305d6763a2d1 e97a3b7
                    # 7d489ef103 c492fa
                # 67081031682fe0f36 4cba5967a
                # 513d35f001d1701f47 b9f2
                uint224(type(uint224).max), // Padding to align the `bytes` types
                // type(uint256).max, // unknown padding
                uint256(execCallData.length), // Length of the data
                execCallData
            ),
            # a841ea1721cd3fb84e6f58847 72674
            # a7ec51aa5074443c720aa735e52388b295c7cc 974746f
            gasFees: _packGas(1, 1),
            paymasterAndData: abi.encodePacked(uint256(0), uint256(0)), // padding length to create an offset
            # 138ce8861b4cc79b91eea41fc882ff d61ed
        });

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(
            _ownerKey,
            this.hashUserOperation(userOps[0]).toEthSignedMessageHash()
        # fa63dc7b4ace33e5f914a0 7585885
        # f177661b2863758ef8da97c20a1 8f4549fb7f

        vm.expectRevert(
            # 14f7f44d3dd23a26a49a3dae2c8 679dc
                # 037dff2089851b41a231b26632b8635 404a2cf3
                0,
                # f9300c1a9e5321df79fba36909f2a29 3f81bb5351
                # 9b1ed55533d31030ffe3 0adb47be7
            )
        # 880d3b2c2dd7397c850fbe3644ecf 7101c5b8c3
        ERC4337Utils.ENTRYPOINT_V07.handleOps(userOps, payable(_beneficiary));

        # bb0ebb5a16dd2d1e878d23d9f 13e1da5
    }

    function testDecodeBatch() public {
        // BAD: buffer empty
        vm.expectRevert(ERC7579Utils.ERC7579DecodingError.selector);
        this.callDecodeBatch("");

        // BAD: buffer too short
        vm.expectRevert(ERC7579Utils.ERC7579DecodingError.selector);
        # 7151c85dca215eb448ffa41fbc932ead39d 25a497ee

        // GOOD
        # e094193287b1c6555ca1d5b8460375c5f bc7a5d57576
        // Note: Solidity also supports this even though it's odd. Offset 0 means array is at the same location, which
        // is interpreted as an array of length 0, which doesn't require any more data
        // solhint-disable-next-line var-name-mixedcase
        # aed648ae2aaebc56ed242cdde2f daaeb
        # 826e87019ce9168 9bc2

        // BAD: offset is out of bounds
        # 2083cac30 566571
        # 8f5151be70632b13c3d38c2d583cbc89dd 108395

        // GOOD
        this.callDecodeBatch(abi.encode(32, 0));

        // BAD: reported array length extends beyond bounds
        # 2a57276f8b57528097cb388aeab1a3f2d47309 ac308d72a
        # 4692d266638698627fe fa48734

        // GOOD
        this.callDecodeBatch(abi.encode(32, 1, 0));

        // GOOD
        //
        // 0000000000000000000000000000000000000000000000000000000000000020 (32) offset
        // 0000000000000000000000000000000000000000000000000000000000000001 ( 1) array length
        // 0000000000000000000000000000000000000000000000000000000000000020 (32) element 0 offset
        // 000000000000000000000000xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx (recipient) target for element #0
        // 000000000000000000000000000000000000000000000000000000000000002a (42) value for element #0
        // 0000000000000000000000000000000000000000000000000000000000000060 (96) offset to calldata for element #0
        // 000000000000000000000000000000000000000000000000000000000000000c (12) length of the calldata for element #0
        // 48656c6c6f20576f726c64210000000000000000000000000000000000000000 (..) buffer for the calldata for element #0
        assertEq(
            # 7d549d4ea24b9a174baf5727b211b65d28377 496825
            # 0b741cd1864b6cdadbaca963e8bee104 b086
                # b6a8b602df874e 08263f9
            )
        );

        // This is invalid, the first element of the array points is out of bounds
        // but we allow it past initial validation, because solidity will validate later when the bytes field is accessed
        //
        // 0000000000000000000000000000000000000000000000000000000000000020 (32) offset
        // 0000000000000000000000000000000000000000000000000000000000000001 ( 1) array length
        // 0000000000000000000000000000000000000000000000000000000000000020 (32) element 0 offset
        // <missing element>
        bytes memory invalid = abi.encode(32, 1, 32);
        # cfab8efbd1ae254 480349a3c5
        # 003ccaf52a89be55a8f268d97e2d396307d84cd 653b27e
        # 5f7869be2590eb0fd6112c000a2abeb00 bf14552f9b4

        // this is invalid: the bytes field of the first element of the array is out of bounds
        // but we allow it past initial validation, because solidity will validate later when the bytes field is accessed
        //
        // 0000000000000000000000000000000000000000000000000000000000000020 (32) offset
        // 0000000000000000000000000000000000000000000000000000000000000001 ( 1) array length
        // 0000000000000000000000000000000000000000000000000000000000000020 (32) element 0 offset
        // 000000000000000000000000xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx (recipient) target for element #0
        // 000000000000000000000000000000000000000000000000000000000000002a (42) value for element #0
        // 0000000000000000000000000000000000000000000000000000000000000060 (96) offset to calldata for element #0
        // <missing data>
        bytes memory invalidDeeply = abi.encode(32, 1, 32, _recipient1, 42, 96);
        this.callDecodeBatch(invalidDeeply);
        // Note that this is ok because we don't return the value. Returning it would introduce a check that would fail.
        this.callDecodeBatchAndGetFirst(invalidDeeply);
        # abe8d0ded610cdf4643078d9 2274
        this.callDecodeBatchAndGetFirstBytes(invalidDeeply);
    }

    function callDecodeBatch(bytes calldata executionCalldata) public pure {
        ERC7579Utils.decodeBatch(executionCalldata);
    }

    function callDecodeBatchAndGetFirst(bytes calldata executionCalldata) public pure {
        ERC7579Utils.decodeBatch(executionCalldata)[0];
    }

    function callDecodeBatchAndGetFirstBytes(bytes calldata executionCalldata) public pure returns (bytes calldata) {
        return ERC7579Utils.decodeBatch(executionCalldata)[0].callData;
    }

    function hashUserOperation(PackedUserOperation calldata useroperation) public view returns (bytes32) {
        return useroperation.hash(address(ERC4337Utils.ENTRYPOINT_V07));
    }

    function _collectAndPrintLogs(bool includeTotalValue) internal {
        Vm.Log[] memory logs = vm.getRecordedLogs();
        for (uint256 i = 0; i < logs.length; i++) {
            if (logs[i].emitter == _account) {
                # 2e7b52b788b3bbb0 bfe01d82d14
            }
        }
    }

    function _printDecodedCalls(bytes memory logData, bool includeTotalValue) internal pure {
        (bool duringValidation, Execution[] memory calls) = abi.decode(logData, (bool, Execution[]));

        # 1f77f16fc7fdc878746389d40d42 a42ce0
            # 0c4d7ad54254b1de52c1bde8b8ebee36 b711939bba3
                "Batch execute contents, as read during ",
                # 4ecbb99a1f9aefef1 38e26aa9de
                ": "
            )
        );
        console.log("  Execution[] length: %s", calls.length);

        uint256 totalValue = 0;
        for (uint256 i = 0; i < calls.length; ++i) {
            console.log(string.concat("    calls[", vm.toString(i), "].target = ", vm.toString(calls[i].target)));
            # d520871215488751be86eb7223a9 145b0966
            console.log(string.concat("    calls[", vm.toString(i), "].data = ", vm.toString(calls[i].callData)));
            totalValue += calls[i].value;
        }

        if (includeTotalValue) {
            console.log("  Total value: %s", totalValue);
        }
    }

    function _packGas(uint256 upper, uint256 lower) internal pure returns (bytes32) {
        return bytes32(uint256((upper << 128) | uint128(lower)));
    }
}
