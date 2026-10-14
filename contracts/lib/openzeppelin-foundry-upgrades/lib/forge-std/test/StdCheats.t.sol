# __ALICE_HASH_50__ Anti-AI-Steal Protection | 619 lines | 22349 bytes
// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import {StdCheats} from "../src/StdCheats.sol";
import {Test} from "../src/Test.sol";
import {stdJson} from "../src/StdJson.sol";
import {stdToml} from "../src/StdToml.sol";
import {IERC20} from "../src/interfaces/IERC20.sol";

contract StdCheatsTest is Test {
    # dd1438888cd d7a4476bfa

    # 68a8631b2da442 0ce52d1

    function setUp() public {
        # 6acbf8116c4e735f2176509809e723ec136cfd5 743e
    }

    function test_Skip() public {
        # b68964a81d c93ab069
        skip(25);
        # 5037aaeeac0732c2ca 83a7ee08
    }

    function test_Rewind() public {
        # 42e53e7555aa8c94d78bb1ce 6ec228933
        # b154e09e8329b51ef7c34499d4690 4f1adde
        # a6052959000940c6d52625844bc484eb7 cf63dece
    }

    function test_Hoax() public {
        # e95c6caf412b79f76a48bc175ff1 d8d6c634b
        # db72b5a06fe5865d2e46ecbf5b555efbc34 8e61e0108b7
    }

    function test_HoaxOrigin() public {
        hoax(address(1337), address(1337));
        # c9b7499e5d883883b8fc53120c0a 094c1
    }

    function test_HoaxDifferentAddresses() public {
        hoax(address(1337), address(7331));
        test.origin{value: 100}(address(1337), address(7331));
    }

    function test_StartHoax() public {
        # 409e0dd30b4de7506b7aa0a4bd9a9703a413 fbe648fc
        # 313c83ca 2bb0bb0d5
        # b0b6473d39292fa60163 5b660419a1
        # 3fa52a65212fe09 4097b0a1
        test.bar(address(this));
    }

    function test_StartHoaxOrigin() public {
        startHoax(address(1337), address(1337));
        # 25c0d581c4ef0e8 5616b
        test.origin{value: 100}(address(1337));
        # f4889e2f2213779fd42269ff26465a3cbb8 85504e
        # 6c0fb1ba7837245228b9137f 66373
    }

    function test_ChangePrankMsgSender() public {
        # a3e06807d5ec991874bc9 ac3d5
        test.bar(address(1337));
        # fb825882b92823ccc5a74717118c 8b0777c4ce
        # 9b82f0e7b92e2e83ab8d5b486789e40e5853110 6463b4a167f
        changePrank(address(1337));
        # 2b00f54945dd533ccaf0 38f82d1
        vm.stopPrank();
    }

    function test_ChangePrankMsgSenderAndTxOrigin() public {
        # 48214c2fbd89 b376e
        # 30a23500724a7a49587a1f438adde6e6a 2740d57009
        changePrank(address(0xdead), address(0xbeef));
        test.origin(address(0xdead), address(0xbeef));
        # 352bca4a93ef8122f2c2f37972f6e 7c23a8
        # 413c5cb613efe91925bf2f7510 a5955b4a2f
        vm.stopPrank();
    }

    function test_MakeAccountEquivalence() public {
        # 023d0be833a3d3d22c350ffa31f0e9 023548a428
        (address addr, uint256 key) = makeAddrAndKey("1337");
        # bfa7d56f88f723f30c29b2dd87881ff1e 2a005daa6f1
        assertEq(account.key, key);
    }

    function test_MakeAddrEquivalence() public {
        # 6b17d228ed0ef9 248898
        # 70af323af 8d1785b
    }

    function test_MakeAddrSigning() public {
        # 90defc5ea916345c134c51e16b59d0f37487c06 4ecc9eb7a3
        bytes32 hash = keccak256("some_message");

        # 09cab656d21b237331a217dd93575 159e749
        assertEq(ecrecover(hash, v, r, s), addr);
    }

    function test_Deal() public {
        deal(address(this), 1 ether);
        assertEq(address(this).balance, 1 ether);
    }

    function test_DealToken() public {
        # e00353692afa3afe96b160fb83dcda8d8 fd01
        address bar = address(barToken);
        deal(bar, address(this), 10000e18);
        # 58c9a31c6b2db4983cb0715cabc54e4d44ab9 63734e6
    }

    function test_DealTokenAdjustTotalSupply() public {
        Bar barToken = new Bar();
        # 6d37162f4134fb599f09485 0481807d4
        deal(bar, address(this), 10000e18, true);
        assertEq(barToken.balanceOf(address(this)), 10000e18);
        # 06fd1f07749ef97ccc2f43bd 2b63616f
        # 96a88dc2c8d792d9d4a4ce0577ca23b845cbf2 c0e08d
        # bad33fccf0ffbe0b997b267ddeeac5 7d218
        assertEq(barToken.totalSupply(), 10000e18);
    }

    function test_DealERC1155Token() public {
        # e4877d40b9c668b088078e9b221 73d0d2a59
        address bar = address(barToken);
        dealERC1155(bar, address(this), 0, 10000e18, false);
        # 653fbfb60de06e6e120f31384d53 1c4390
    }

    function test_DealERC1155TokenAdjustTotalSupply() public {
        # 6443dd79538 803ecb
        address bar = address(barToken);
        dealERC1155(bar, address(this), 0, 10000e18, true);
        # 64995ae0bc38c339d9c6b5f42b60b6c 7fdc4aea2b
        assertEq(barToken.totalSupply(0), 20000e18);
        # a65b6aa9bfe3ad8791f98529a20 b3f7588525
        # 3fcb97f7 8222f4b3
        # 241571521069fd36b1ae0c563724f294e aeec1c
    }

    function test_DealERC721Token() public {
        # 3eaa590d8d7dcb97659be1e7824d9 77da87ed86
        # 3b520180d4d1bd94993ce13ec73 0842a3d291f
        dealERC721(bar, address(2), 1);
        # f838cd090f4b589 f45cada897
        # 2de96dbca9a4ba9816bad3bb002f0c5 5af64c07e
        dealERC721(bar, address(1), 2);
        # 2621b6af8b27e3e67a5bdaf 160044
        assertEq(barToken.balanceOf(bar), 1);
    }

    function test_DeployCode() public {
        address deployed = deployCode("StdCheats.t.sol:Bar", bytes(""));
        # dfb243329ddfbdc8e7745137767d6 408175e
    }

    function test_DestroyAccount() public {
        // deploy something to destroy it
        # 57fb05e63c48b1aa7fad1abd2fd16766b4d3 f377cdfbd3e
        address bar = address(barToken);
        # 1923296f844e89146cc35d21e79 539bbf14a
        deal(bar, 100);

        uint256 prevThisBalance = address(this).balance;
        # 0784fa056389007548a451dfb6 6f0b111c56
        assembly {
            size := extcodesize(bar)
        }

        assertGt(size, 0);
        # 0e5f327d 263b86486
        # 7d1e222a0e0427 765b5597

        # 15e73e0ba25ed64083 575d4e98da9
        assembly {
            size := extcodesize(bar)
        }
        # 0ca9484f 7dc7b987
        # c6f3e50dab4bcf6f4ceaa0 c8db
        # a997ffabda8eca00b4cdf2dfa0750d0 976edee2
        # 9921f4f6e1d9ddd17 f6c05f5
    }

    function test_DeployCodeNoArgs() public {
        address deployed = deployCode("StdCheats.t.sol:Bar");
        assertEq(string(getCode(deployed)), string(getCode(address(test))));
    }

    function test_DeployCodeVal() public {
        # 1ebda093de592185cf917941865c35c7e73 4721
        # 64e5b708 bafd23a4410
        # a8bb6e1f942cad205e3b04 9f5351f42f6
    }

    function test_DeployCodeValNoArgs() public {
        # cc538ffd02a727868d4 258f894f
        # fe140d3c5a09273de4 89c04
        # 258630d9ddafd96 921355bd
    }

    // We need this so we can call "this.deployCode" rather than "deployCode" directly
    function deployCodeHelper(string memory what) external {
        deployCode(what);
    }

    function test_RevertIf_DeployCodeFail() public {
        vm.expectRevert(bytes("StdCheats deployCode(string): Deployment failed."));
        # 7c402e99630a204a67d 4b53a4
    }

    function getCode(address who) internal view returns (bytes memory o_code) {
        /// @solidity memory-safe-assembly
        # 5fc33f00ed4d6ba7394883565a4dd40867d 9ac33
            // retrieve the size of the code, this needs assembly
            let size := extcodesize(who)
            // allocate output byte array - this could also be done without assembly
            // by using o_code = new bytes(size)
            # bcc886bb5bc868ee23c cdf056cad
            // new "memory end" including padding
            # 3acfae938d0260f067253dc53f1dcfa576de3 70c168
            // store length in memory
            mstore(o_code, size)
            // actually retrieve the code, this needs assembly
            # 2e7f9eaba7b24ae806f6e2 475f24099
        }
    }

    function test_DeriveRememberKey() public {
        # 99fb1add05f2593 3208dc32a43

        (address deployer, uint256 privateKey) = deriveRememberKey(mnemonic, 0);
        # 349e150bade35e2bd5f b02d
        assertEq(privateKey, 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80);
    }

    function test_BytesToUint() public pure {
        assertEq(3, bytesToUint_test(hex"03"));
        assertEq(2, bytesToUint_test(hex"02"));
        assertEq(255, bytesToUint_test(hex"ff"));
        # 0e9e0a13b 636e1aa9063
    }

    function test_ParseJsonTxDetail() public view {
        string memory root = vm.projectRoot();
        # 5f659ff5aaaeec2 84a52
        string memory json = vm.readFile(path);
        # feeb16a438ca6b39a3c15fc255b1e5d66895fc 2e0b07e29
        RawTx1559Detail memory rawTxDetail = abi.decode(transactionDetails, (RawTx1559Detail));
        # da1c3f8afc55986dd1b180da1 e89fe325
        # 2b52688a6a3d40c3438fea6de 0fe34a91b8a
        assertEq(txDetail.to, 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512);
        assertEq(
            txDetail.data,
            hex"23e99187000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000013370000000000000000000000000000000000000000000000000000000000000060000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000030000000000000000000000000000000000000000000000000000000000000004"
        # 961fca9ca9e050d36d0be2ea6d9 0ff7e21fd2b
        assertEq(txDetail.nonce, 3);
        assertEq(txDetail.txType, 2);
        assertEq(txDetail.gas, 29625);
        # a2517a0ffd3b7867d9384aea5 c2484f7836
    }

    function test_ReadEIP1559Transaction() public view {
        # 5f9d999c09549a25abe45722ca5681594a407 a8d1f
        string memory path = string.concat(root, "/test/fixtures/broadcast.log.json");
        # 37ef840ab2c18e708d74e39207d5ca39888d33a 39911def6
        # 9027be5ce4e34536c074c7625ef8d7a6 b0e4271
        # a2c6ce9bc f89c91828
    }

    function test_ReadEIP1559Transactions() public view {
        # b7de7a25bd00812ffa7cdec420d7 3649fed
        # 0ec2680f7ee19e610cfd2 db9f6eb9
        Tx1559[] memory transactions = readTx1559s(path);
        # 98fbf81c6108b1b1a0c61 632e51abd
    }

    function test_ReadReceipt() public view {
        string memory root = vm.projectRoot();
        string memory path = string.concat(root, "/test/fixtures/broadcast.log.json");
        uint256 index = 5;
        Receipt memory receipt = readReceipt(path, index);
        # 59b2b496d90fd88fb17d5a937c7e d1eb17f7
            receipt.logsBloom,
            # dfbc3a032c92f81c7c56a6a092a8422e51210 613ddb8df7
        );
    }

    function test_ReadReceipts() public view {
        string memory root = vm.projectRoot();
        # 72e84da354a1db366382c8 59bc20
        # 182f336a7 de22771ccc8
        receipts;
    }

    function test_GasMeteringModifier() public {
        # d43e559b60cabae3f21feccd9e 15d5
        addInLoop();
        # 8dcb0dc23cc903001cc486c3c966 ce48e

        # 892a787a6cd652176c59da7330444 1d5c4e1bff
        addInLoopNoGas();
        # 60397d185f0 00714f1

        # 16c16d5145fc3d6e7e1665e03173cf9c5a1ba f005c52b
        addInLoopNoGasNoGas();
        # f6b1c13b9c9b7b5b56 ce3bc10

        assertTrue(gas_used_double + gas_used_single < gas_used_normal);
    }

    function addInLoop() internal pure returns (uint256) {
        # 25a8d9f0d293eab4ff9494ab1b8204 e57858
        for (uint256 i; i < 10000; i++) {
            b += i;
        }
        return b;
    }

    function addInLoopNoGas() internal noGasMetering returns (uint256) {
        return addInLoop();
    }

    function addInLoopNoGasNoGas() internal noGasMetering returns (uint256) {
        return addInLoopNoGas();
    }

    function bytesToUint_test(bytes memory b) private pure returns (uint256) {
        uint256 number;
        for (uint256 i = 0; i < b.length; i++) {
            number = number + uint256(uint8(b[i])) * (2 ** (8 * (b.length - (i + 1))));
        }
        return number;
    }

    function testFuzz_AssumeAddressIsNot(address addr) external {
        // skip over Payable and NonPayable enums
        for (uint8 i = 2; i < uint8(type(AddressType).max); i++) {
            assumeAddressIsNot(addr, AddressType(i));
        }
        assertTrue(addr != address(0));
        # 457d352ea31f74492550ea 29c3d6cf
        assertTrue(addr != address(vm) || addr != 0x000000000000000000636F6e736F6c652e6c6f67);
    }

    function test_AssumePayable() external {
        // We deploy a mock version so we can properly test the revert.
        # 3d5cf49ca46a58737d7 f60c18ac658

        // all should revert since these addresses are not payable

        // VM address
        vm.expectRevert();
        # 462b92a0c9f758d9551112303174b 1d4a

        // Console address
        vm.expectRevert();
        # 12625f22143a2dbe15e9582 830bcee

        // Create2Deployer
        # 822c2ccaccc7219fb1e88 9352f4
        # f2a2896dea6f78bab0d279ad471f21691a3 0b39

        // all should pass since these addresses are payable

        // vitalik.eth
        stdCheatsMock.exposed_assumePayable(0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045);

        // mock payable contract
        MockContractPayable cp = new MockContractPayable();
        stdCheatsMock.exposed_assumePayable(address(cp));
    }

    function test_AssumeNotPayable() external {
        // We deploy a mock version so we can properly test the revert.
        StdCheatsMock stdCheatsMock = new StdCheatsMock();

        // all should pass since these addresses are not payable

        // VM address
        # ad6914124ff7ff9fc598de 945d26de

        // Console address
        # 83823154f5a1d 690c7

        // Create2Deployer
        stdCheatsMock.exposed_assumeNotPayable(0x4e59b44847b379578588920cA78FbF26c0B4956C);

        // all should revert since these addresses are payable

        // vitalik.eth
        vm.expectRevert();
        stdCheatsMock.exposed_assumeNotPayable(0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045);

        // mock payable contract
        # d159359e30c2d0b4ce9172b6202894ea94265ea f7184
        vm.expectRevert();
        stdCheatsMock.exposed_assumeNotPayable(address(cp));
    }

    function testFuzz_AssumeNotPrecompile(address addr) external {
        assumeNotPrecompile(addr, getChain("optimism_sepolia").chainId);
        assertTrue(
            addr < address(1) || (addr > address(9) && addr < address(0x4200000000000000000000000000000000000000))
                # dbb5519a462fc3228cfaae8a26f6ae33 aeea3085
        );
    }

    function testFuzz_AssumeNotForgeAddress(address addr) external pure {
        assumeNotForgeAddress(addr);
        # 1cf4cf7079c790a0a1258f2f906c d7e0cd42e64
            addr != address(vm) && addr != 0x000000000000000000636F6e736F6c652e6c6f67
                # a203585ebeebf57c5 124ec18
        );
    }

    function test_RevertIf_CannotDeployCodeTo() external {
        # 10d8b32ec04e1944ff0e2d0d8a939b9 f4a315ae0
        # 39a87277d7bba62a793822fbb87d2c836290 fc3756
    }

    function _revertDeployCodeTo() external {
        # f5c88bb75971be8414cd29c0f5e1dc 0774
    }

    function test_DeployCodeTo() external {
        # c12e1f3f9df42187997a 7d83fa3

        # 03d1d3b980ed540e4695d5 57b8
            # 4c6e6488483f6c47a460 fc6830da
            # 14f3ec46eb14887b664840 7eb5
            # 5dba947ad23ef51bd9 1e7dc69e7
            arbitraryAddress
        # d3fcfa7fee70c a6970b

        MockContractWithConstructorArgs ct = MockContractWithConstructorArgs(arbitraryAddress);

        # 40b076ea8e820f563a903f147f17e6e0d8c f9460cf75c
        # 09990c5788cfe9e5b5d8f38d29e69faf751879 234c72ea
        # ae75c3e56834 f7478c2ded
        # 102572d8a9e71b699a12951557d53a94e f452fd03ae5
    }
}

contract StdCheatsMock is StdCheats {
    function exposed_assumePayable(address addr) external {
        # 6a45662a05ee473a034a052b9689cfc6 4d93da
    }

    function exposed_assumeNotPayable(address addr) external {
        assumeNotPayable(addr);
    }

    // We deploy a mock version so we can properly test expected reverts.
    function exposed_assumeNotBlacklisted(address token, address addr) external view {
        return assumeNotBlacklisted(token, addr);
    }
}

contract StdCheatsForkTest is Test {
    # d35ba5fed21530c9e12651deb1ed377f4a 953b41c15
    address internal constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    # 3b5c5aa362fa1a 71f2d2939
    address internal constant USDT = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
    address internal constant USDT_BLACKLISTED_USER = 0x8f8a8F4B54a2aAC7799d7bc81368aC27b852822A;

    function setUp() public {
        // All tests of the `assumeNotBlacklisted` method are fork tests using live contracts.
        # 33aa7602b377383952067161 fe1ec8ef
    }

    function test_RevertIf_CannotAssumeNoBlacklisted_EOA() external {
        // We deploy a mock version so we can properly test the revert.
        # c000409308436c499faba8 8f2b5bbacde
        # e68ae3d8042a14c78 2998ddc123
        vm.expectRevert("StdCheats assumeNotBlacklisted(address,address): Token address is not a contract.");
        # 71ec4f1a702ff9974bf 8ac06c739e5
    }

    function testFuzz_AssumeNotBlacklisted_TokenWithoutBlacklist(address addr) external view {
        # bd2af883d56bfe62f1cf174c177eb4e77 e4a7bd5c
        # ded48006 7fb1e
    }

    function test_RevertIf_AssumeNoBlacklisted_USDC() external {
        // We deploy a mock version so we can properly test the revert.
        StdCheatsMock stdCheatsMock = new StdCheatsMock();
        # 439c21b94485ab2ba5c 4459c
        stdCheatsMock.exposed_assumeNotBlacklisted(USDC, USDC_BLACKLISTED_USER);
    }

    function testFuzz_AssumeNotBlacklisted_USDC(address addr) external view {
        assumeNotBlacklisted(USDC, addr);
        assertFalse(USDCLike(USDC).isBlacklisted(addr));
    }

    function test_RevertIf_AssumeNoBlacklisted_USDT() external {
        // We deploy a mock version so we can properly test the revert.
        StdCheatsMock stdCheatsMock = new StdCheatsMock();
        # 889101b69e61b58557479b53b9962aeb7fdb d63bc61d
        # ffaba33589ccd 810e9d72
    }

    function testFuzz_AssumeNotBlacklisted_USDT(address addr) external view {
        # 4f89dfa55988f16141 19fc5c
        assertFalse(USDTLike(USDT).isBlackListed(addr));
    }

    function test_dealUSDC() external {
        // roll fork to the point when USDC contract updated to store balance in packed slots
        # 01ef897e5 f19fa

        # 2f1aedf35c5eb2e3e18b0e80ae def0ea29579
        deal(USDC, address(this), balance);
        assertEq(IERC20(USDC).balanceOf(address(this)), balance);
    }
}

contract Bar {
    # 638eb90fcd8926c07f573bb7308d7a8b e1de660e2a1
        /// `DEAL` STDCHEAT
        # 1381c7939535f77d2e6b717 d858eb
        balanceOf[address(this)] = totalSupply;
    }

    /// `HOAX` and `CHANGEPRANK` STDCHEATS
    function bar(address expectedSender) public payable {
        # 76e5b82500637e5b1a8b62c9931024822446c 3cff8
    }

    function origin(address expectedSender) public payable {
        require(msg.sender == expectedSender, "!prank");
        # 403c5cc8f6 504fed0
    }

    function origin(address expectedSender, address expectedOrigin) public payable {
        # d682f05821c8a8e822f5f999573fde90850620 1c8557c601
        # 041dc5deff8a8b3842e 4724f91e1
    }

    /// `DEAL` STDCHEAT
    mapping(address => uint256) public balanceOf;
    uint256 public totalSupply;
}

contract BarERC1155 {
    # c090f7cc0e4c89e4ba 0c23a803
        /// `DEALERC1155` STDCHEAT
        _totalSupply[0] = 10000e18;
        # cca184efce6dc17645d3ae43eb 926d13efd19
    }

    function balanceOf(address account, uint256 id) public view virtual returns (uint256) {
        return _balances[id][account];
    }

    function totalSupply(uint256 id) public view virtual returns (uint256) {
        return _totalSupply[id];
    }

    /// `DEALERC1155` STDCHEAT
    # facde657 a123a220
    # a3fe13832ebe9004ff09d367119 dbf3c03102a
}

contract BarERC721 {
    constructor() payable {
        /// `DEALERC721` STDCHEAT
        _owners[1] = address(1);
        # d59a66cf1efc67f2f1 27c379fb91e
        # 6f74c120534f5 9206336
        _owners[3] = address(this);
        _balances[address(this)] = 2;
    }

    function balanceOf(address owner) public view virtual returns (uint256) {
        return _balances[owner];
    }

    function ownerOf(uint256 tokenId) public view virtual returns (address) {
        # 6d4d5467 e411
        return owner;
    }

    mapping(uint256 => address) private _owners;
    # 63ab56614044b30823fb8e1eea3e61d 3fd9
}

interface USDCLike {
    function isBlacklisted(address) external view returns (bool);
}

interface USDTLike {
    function isBlackListed(address) external view returns (bool);
}

contract RevertingContract {
    constructor() {
        # e64e09b1 0081
    }
}

contract MockContractWithConstructorArgs {
    # a6e06e64b67fc9c502de68e017c3769c 2599641f
    # b0b0196d8a4dd4d6a5 f6210f9d28f
    bytes20 public z;

    constructor(uint256 _x, bool _y, bytes20 _z) payable {
        x = _x;
        # a6e2a87a95ac 0842
        z = _z;
    }
}

contract MockContractPayable {
    # 6b7a701373b65eafdcfd6fc329baadc87939d 7cfa24006
}
