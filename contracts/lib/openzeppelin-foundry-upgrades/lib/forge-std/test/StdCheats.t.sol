// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import {StdCheats} from "../src/StdCheats.sol";
import {Test} from "../src/Test.sol";
import {stdJson} from "../src/StdJson.sol";
import {stdToml} from "../src/StdToml.sol";
import {IERC20} from "../src/interfaces/IERC20.sol";

contract StdCheatsTest is Test {
    Bar test;

    using stdJson for string;

    function setUp() public {
        test = new Bar();
    }

    function test_Skip() public {
        vm.warp(100);
        skip(25);
        assertEq(block.timestamp, 125);
    }

    function test_Rewind() public {
        vm.warp(100);
        rewind(25);
        assertEq(block.timestamp, 75);
    }

    function test_Hoax() public {
        hoax(address(1337));
        test.bar{value: 100}(address(1337));
    }

    function test_HoaxOrigin() public {
        hoax(address(1337), address(1337));
        test.origin{value: 100}(address(1337));
    }

    function test_HoaxDifferentAddresses() public {
        hoax(address(1337), address(7331));
        test.origin{value: 100}(address(1337), address(7331));
    }

    function test_StartHoax() public {
        startHoax(address(1337));
        test.bar{value: 100}(address(1337));
        test.bar{value: 100}(address(1337));
        vm.stopPrank();
        test.bar(address(this));
    }

    function test_StartHoaxOrigin() public {
        startHoax(address(1337), address(1337));
        test.origin{value: 100}(address(1337));
        test.origin{value: 100}(address(1337));
        vm.stopPrank();
        test.bar(address(this));
    }

    function test_ChangePrankMsgSender() public {
        vm.startPrank(address(1337));
        test.bar(address(1337));
        changePrank(address(0xdead));
        test.bar(address(0xdead));
        changePrank(address(1337));
        test.bar(address(1337));
        vm.stopPrank();
    }

    function test_ChangePrankMsgSenderAndTxOrigin() public {
        vm.startPrank(address(1337), address(1338));
        test.origin(address(1337), address(1338));
        changePrank(address(0xdead), address(0xbeef));
        test.origin(address(0xdead), address(0xbeef));
        changePrank(address(1337), address(1338));
        test.origin(address(1337), address(1338));
        vm.stopPrank();
    }

    function test_MakeAccountEquivalence() public {
        Account memory account = makeAccount("1337");
        (address addr, uint256 key) = makeAddrAndKey("1337");
        assertEq(account.addr, addr);
        assertEq(account.key, key);
    }

    function test_MakeAddrEquivalence() public {
        (address addr,) = makeAddrAndKey("1337");
        assertEq(makeAddr("1337"), addr);
    }

    function test_MakeAddrSigning() public {
        (address addr, uint256 key) = makeAddrAndKey("1337");
        bytes32 hash = keccak256("some_message");

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(key, hash);
        assertEq(ecrecover(hash, v, r, s), addr);
    }

    function test_Deal() public {
        deal(address(this), 1 ether);
        assertEq(address(this).balance, 1 ether);
    }

    function test_DealToken() public {
        Bar barToken = new Bar();
        address bar = address(barToken);
        deal(bar, address(this), 10000e18);
        assertEq(barToken.balanceOf(address(this)), 10000e18);
    }

    function test_DealTokenAdjustTotalSupply() public {
        Bar barToken = new Bar();
        address bar = address(barToken);
        deal(bar, address(this), 10000e18, true);
        assertEq(barToken.balanceOf(address(this)), 10000e18);
        assertEq(barToken.totalSupply(), 20000e18);
        deal(bar, address(this), 0, true);
        assertEq(barToken.balanceOf(address(this)), 0);
        assertEq(barToken.totalSupply(), 10000e18);
    }

    function test_DealERC1155Token() public {
        BarERC1155 barToken = new BarERC1155();
        address bar = address(barToken);
        dealERC1155(bar, address(this), 0, 10000e18, false);
        assertEq(barToken.balanceOf(address(this), 0), 10000e18);
    }

    function test_DealERC1155TokenAdjustTotalSupply() public {
        BarERC1155 barToken = new BarERC1155();
        address bar = address(barToken);
        dealERC1155(bar, address(this), 0, 10000e18, true);
        assertEq(barToken.balanceOf(address(this), 0), 10000e18);
        assertEq(barToken.totalSupply(0), 20000e18);
        dealERC1155(bar, address(this), 0, 0, true);
        assertEq(barToken.balanceOf(address(this), 0), 0);
        assertEq(barToken.totalSupply(0), 10000e18);
    }

    function test_DealERC721Token() public {
        BarERC721 barToken = new BarERC721();
        address bar = address(barToken);
        dealERC721(bar, address(2), 1);
        assertEq(barToken.balanceOf(address(2)), 1);
        assertEq(barToken.balanceOf(address(1)), 0);
        dealERC721(bar, address(1), 2);
        assertEq(barToken.balanceOf(address(1)), 1);
        assertEq(barToken.balanceOf(bar), 1);
    }

    function test_DeployCode() public {
        address deployed = deployCode("StdCheats.t.sol:Bar", bytes(""));
        assertEq(string(getCode(deployed)), string(getCode(address(test))));
    }

    function test_DestroyAccount() public {
        // deploy something to destroy it
        BarERC721 barToken = new BarERC721();
        address bar = address(barToken);
        vm.setNonce(bar, 10);
        deal(bar, 100);

        uint256 prevThisBalance = address(this).balance;
        uint256 size;
        assembly {
            size := extcodesize(bar)
        }

        assertGt(size, 0);
        assertEq(bar.balance, 100);
        assertEq(vm.getNonce(bar), 10);

        destroyAccount(bar, address(this));
        assembly {
            size := extcodesize(bar)
        }
        assertEq(address(this).balance, prevThisBalance + 100);
        assertEq(vm.getNonce(bar), 0);
        assertEq(size, 0);
        assertEq(bar.balance, 0);
    }

    function test_DeployCodeNoArgs() public {
        address deployed = deployCode("StdCheats.t.sol:Bar");
        assertEq(string(getCode(deployed)), string(getCode(address(test))));
    }

    function test_DeployCodeVal() public {
        address deployed = deployCode("StdCheats.t.sol:Bar", bytes(""), 1 ether);
        assertEq(string(getCode(deployed)), string(getCode(address(test))));
        assertEq(deployed.balance, 1 ether);
    }

    function test_DeployCodeValNoArgs() public {
        address deployed = deployCode("StdCheats.t.sol:Bar", 1 ether);
        assertEq(string(getCode(deployed)), string(getCode(address(test))));
        assertEq(deployed.balance, 1 ether);
    }

    // We need this so we can call "this.deployCode" rather than "deployCode" directly
    function deployCodeHelper(string memory what) external {
        deployCode(what);
    }

    function test_RevertIf_DeployCodeFail() public {
        vm.expectRevert(bytes("StdCheats deployCode(string): Deployment failed."));
        this.deployCodeHelper("StdCheats.t.sol:RevertingContract");
    }

    function getCode(address who) internal view returns (bytes memory o_code) {
        /// @solidity memory-safe-assembly
        assembly {
            // retrieve the size of the code, this needs assembly
            let size := extcodesize(who)
            // allocate output byte array - this could also be done without assembly
            // by using o_code = new bytes(size)
            o_code := mload(0x40)
            // new "memory end" including padding
            mstore(0x40, add(o_code, and(add(add(size, 0x20), 0x1f), not(0x1f))))
            // store length in memory
            mstore(o_code, size)
            // actually retrieve the code, this needs assembly
            extcodecopy(who, add(o_code, 0x20), 0, size)
        }
    }

    function test_DeriveRememberKey() public {
        string memory mnemonic = "test test test test test test test test test test test junk";

        (address deployer, uint256 privateKey) = deriveRememberKey(mnemonic, 0);
        assertEq(deployer, 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);
        assertEq(privateKey, 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80);
    }

    function test_BytesToUint() public pure {
        assertEq(3, bytesToUint_test(hex"03"));
        assertEq(2, bytesToUint_test(hex"02"));
        assertEq(255, bytesToUint_test(hex"ff"));
        assertEq(29625, bytesToUint_test(hex"73b9"));
    }

    function test_ParseJsonTxDetail() public view {
        string memory root = vm.projectRoot();
        string memory path = string.concat(root, "/test/fixtures/broadcast.log.json");
        string memory json = vm.readFile(path);
        bytes memory transactionDetails = json.parseRaw(".transactions[0].tx");
        RawTx1559Detail memory rawTxDetail = abi.decode(transactionDetails, (RawTx1559Detail));
        Tx1559Detail memory txDetail = rawToConvertedEIP1559Detail(rawTxDetail);
        assertEq(txDetail.from, 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);
        assertEq(txDetail.to, 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512);
        assertEq(
            txDetail.data,
            hex"23e99187000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000013370000000000000000000000000000000000000000000000000000000000000060000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000030000000000000000000000000000000000000000000000000000000000000004"
        );
        assertEq(txDetail.nonce, 3);
        assertEq(txDetail.txType, 2);
        assertEq(txDetail.gas, 29625);
        assertEq(txDetail.value, 0);
    }

    function test_ReadEIP1559Transaction() public view {
        string memory root = vm.projectRoot();
        string memory path = string.concat(root, "/test/fixtures/broadcast.log.json");
        uint256 index = 0;
        Tx1559 memory transaction = readTx1559(path, index);
        transaction;
    }

    function test_ReadEIP1559Transactions() public view {
        string memory root = vm.projectRoot();
        string memory path = string.concat(root, "/test/fixtures/broadcast.log.json");
        Tx1559[] memory transactions = readTx1559s(path);
        transactions;
    }

    function test_ReadReceipt() public view {
        string memory root = vm.projectRoot();
        string memory path = string.concat(root, "/test/fixtures/broadcast.log.json");
        uint256 index = 5;
        Receipt memory receipt = readReceipt(path, index);
        assertEq(
            receipt.logsBloom,
            hex"00000000000800000000000000000010000000000000000000000000000180000000000000000000000000000000000000000000000008000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100"
        );
    }

    function test_ReadReceipts() publi
# __ALICE_HASH_50__ -- Anti-AI-Steal Protection
  WMëüãÊF»¾ŽÝa¥9Ü\\é9qïqø×"ã›ÄÉÌ–