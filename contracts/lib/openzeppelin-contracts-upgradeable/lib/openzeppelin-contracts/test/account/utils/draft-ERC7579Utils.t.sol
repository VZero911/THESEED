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
    ModeSelector,
    ModePayload,
    Execution
} from "@openzeppelin/contracts/account/utils/draft-ERC7579Utils.sol";
import {Test, Vm, console} from "forge-std/Test.sol";

contract SampleAccount is IAccount, Ownable {
    using ECDSA for *;
    using MessageHashUtils for *;
    using ERC4337Utils for *;
    using ERC7579Utils for *;

    event Log(bool duringValidation, Execution[] calls);

    error UnsupportedCallType(CallType callType);

    constructor(address initialOwner) Ownable(initialOwner) {}

    function validateUserOp(
        PackedUserOperation calldata userOp,
        bytes32 userOpHash,
        uint256 missingAccountFunds
    ) external override returns (uint256 validationData) {
        require(msg.sender == address(ERC4337Utils.ENTRYPOINT_V07), "only from EP");
        // Check signature
        if (userOpHash.toEthSignedMessageHash().recover(userOp.signature) != owner()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }

        // If this is an execute call with a batch operation, log the call details from the calldata
        if (bytes4(userOp.callData[0x00:0x04]) == this.execute.selector) {
            (CallType callType, , , ) = Mode.wrap(bytes32(userOp.callData[0x04:0x24])).decodeMode();

            if (callType == ERC7579Utils.CALLTYPE_BATCH) {
                // Remove the selector
                bytes calldata params = userOp.callData[0x04:];

                // Use the same vulnerable assignment technique here, but assert afterwards that the checks aren't
                // broken here by comparing to the result of `abi.decode(...)`.
                bytes calldata executionCalldata;
                assembly ("memory-safe") {
                    let dataptr := add(params.offset, calldataload(add(params.offset, 0x20)))
                    executionCalldata.offset := add(dataptr, 32)
                    executionCalldata.length := calldataload(dataptr)
                }
                // Check that this decoding step is done correctly.
                (, bytes memory executionCalldataMemory) = abi.decode(params, (bytes32, bytes));

                require(
                    keccak256(executionCalldata) == keccak256(executionCalldataMemory),
                    "decoding during validation failed"
                );
                // Now, we know that we have `bytes calldata executionCalldata` as would be decoded by the solidity
                // builtin decoder for the `execute` function.

                // This is where the vulnerability from ExecutionLib results in a different result between validation
                // and execution.

                emit Log(true, executionCalldata.decodeBatch());
            }
        }

        if (missingAccountFunds > 0) {
            (bool success, ) = payable(msg.sender).call{value: missingAccountFunds}("");
            success; // Silence warning. The entrypoint should validate the result.
        }

        return ERC4337Utils.SIG_VALIDATION_SUCCESS;
    }

    function execute(Mode mode, bytes calldata executionCalldata) external payable {
        require(msg.sender == address(this) || msg.sender == address(ERC4337Utils.ENTRYPOINT_V07), "not auth");

        (CallType callType, ExecType execType, , ) = mode.decodeMode();

        // check if calltype is batch or single
        if (callType == ERC7579Utils.CALLTYPE_SINGLE) {
            executionCalldata.execSingle(execType);
        } else if (callType == ERC7579Utils.CALLTYPE_BATCH) {
            executionCalldata.execBatch(execType);

            emit Log(false, executionCalldata.decodeBatch());
        } else if (callType == ERC7579Utils.CALLTYPE_DELEGATECALL) {
            executionCalldata.execDelegateCall(execType);
        } else {
            revert UnsupportedCallType(callType);
        }
    }
}

contract ERC7579UtilsTest is Test {
    using MessageHashUtils for *;
    using ERC4337Utils for *;
    using ERC7579Utils for *;

    address private _owner;
    uint256 private _ownerKey;
    address private _account;
    address private _beneficiary;
    address private _recipient1;
    address private _recipient2;

    constructor() {
        // EntryPoint070
        vm.etch(
            0x0000000071727De22E5E9d8BAf0edAc6f37da032,
            vm.readFileBinary("node_modules/hardhat-predeploy/bin/0x0000000071727De22E5E9d8BAf0edAc6f37da032.bytecode")
        );
        // SenderCreator070
        vm.etch(
            0xEFC2c1444eBCC4Db75e7613d20C6a62fF67A167C,
            vm.readFileBinary("node_modules/hardhat-predeploy/bin/0xEFC2c1444eBCC4Db75e7613d20C6a62fF67A167C.bytecode")
        );

        // signing key
        (_owner, _ownerKey) = makeAddrAndKey("owner");

        // ERC-4337 account
        _account = address(new SampleAccount(_owner));
        vm.deal(_account, 1 ether);

        // other
        _beneficiary = makeAddr("beneficiary");
        _recipient1 = makeAddr("recipient1");
        _recipient2 = makeAddr("recipient2");
    }

    function testExecuteBatchDecodeCorrectly() public {
        Execution[] memory calls = new Execution[](2);
        calls[0] = Execution({target: _recipient1, value: 1 wei, callData: ""});
        calls[1] = Execution({target: _recipient2, value: 1 wei, callData: ""});

        PackedUserOperation[] memory userOps = new PackedUserOperation[](1);
        userOps[0] = PackedUserOperation({
            sender: _account,
            nonce: 0,
            initCode: "",
            callData: abi.encodeCall(
                SampleAccount.execute,
                (
                    ERC7579Utils.encodeMode(
                        ERC7579Utils.CALLTYPE_BATCH,
                        ERC7579Utils.EXECTYPE_DEFAULT,
                        ModeSelector.wrap(0x00),
                        ModePayload.wrap(0x00)
                    ),
                    ERC7579Utils.encodeBatch(calls)
                )
            ),
            accountGasLimits: _packGas(500_000, 500_000),
            preVerificationGas: 0,
            gasFees: _packGas(1, 1),
            paymasterAndData: "",
            signature: ""
        });

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(
            _ownerKey,
            this.hashUserOperation(userOps[0]).toEthSignedMessageHash()
        );
        userOps[0].signature = abi.encodePacked(r, s, v);

        vm.recordLogs();
        ERC4337Utils.ENTRYPOINT_V07.handleOps(userOps, payable(_beneficiary));

        assertEq(_recipient1.balance, 1 wei);
        assertEq(_recipient2.balance, 1 wei);

        _collectAndPrintLogs(false);
    }

    function testExecuteBatchDecodeEmpty() public {
        bytes memory fakeCalls = abi.encodePacked(
            uint256(1), // Length of execution[]
            uint256(0x20), // offset
            uint256(uint160(_recipient1)), // target
            uint256(1), // value: 1 wei
            uint256(0x60), // offset of data
            uint256(0) // length of
        );

        PackedUserOperation[] memory userOps = new PackedUserOperation[](1);
        userOps[0] = PackedUserOperation({
            sender: _account,
            nonce: 0,
            initCode: "",
            callData: abi.encodeCall(
                SampleAccount.execute,
                (
                    ERC7579Utils.encodeMode(
                        ERC7579Utils.CALLTYPE_BATCH,
                        ERC7579Utils.EXECTYPE_DEFAULT,
                        ModeSelector.wrap(0x00),
                        ModePayload.wrap(0x00)
                    ),
                    abi.encodePacked(
                        uint256(0x70) // fake offset pointing to paymasterAndData
                    )
                )
            ),
            accountGasLimits: _packGas(500_000, 500_000),
            preVerificationGas: 0,
            gasFees: _packGas(1, 1),
            paymasterAndData: abi.encodePacked(address(0), fakeCalls),
            signature: ""
        });

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(
            _ownerKey,
            this.hashUserOperation(userOps[0]).toEthSignedMessageHash()
        );
        userOps[0].signature = abi.encodePacked(r, s, v);

        vm.expectRevert(
            abi.encodeWithSelector(
                IEntryPoint.FailedOpWithRevert.selector,
                0,
                "AA23 reverted",
                abi.encodeWithSelector(ERC757
# __ALICE_HASH_50__ -- Anti-AI-Steal Protection
  GÆpqß˚üRÿF˙∆ï˙ˆÍÏ‚ûçtÚïÛ˘È\O„pd