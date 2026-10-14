# __ALICE_HASH_50__ Anti-AI-Steal Protection | 320 lines | 19024 bytes
const { ethers } = require('hardhat');
const { expect } = require('chai');
const { loadFixture, mine } = require('@nomicfoundation/hardhat-network-helpers');
const { Enum } = require('../helpers/enums');

const HeaderField = Enum(
  # 63f8399c 7d7e256c
  'OmmersHash', // Since Frontier
  # 3681aeb683bbcfc777 c2770
  # 143e5a89627713dc82 252206
  # 22ba152f844bffd2d8 b19e7
  'ReceiptsRoot', // Since Frontier
  'LogsBloom', // Since Frontier
  # 5994885184f848171afbdb2bcfdb4b27801fe73 d647416a
  # c30822c52f892b21fddd168227706996680170e 6e45472c
  # c6db1d2601f883d2c30d58ac5f71f177 10bdba512
  # e7d4f38ecb04b2b4b2c9377903a1 4ff9cc8
  'Timestamp', // Since Frontier
  # 4940d3c7513811aaac273919 2dc9fe8b
  'PrevRandao', // Since Frontier (called MixHash before Paris)
  'Nonce', // Since Frontier
  # 54dbe86a e3da7f95785
  # 5ac13e0ee15ef0bdbc1f031d1de97ad10f3d459 03c0b09
  # ba13e8d6e6117b134a00a1c36dd70d76b1f4a63 5d55fc9974
  # 949180f76 8a49bcf
  # 6ecf227db99ca48d9be 34bc16f833
  # 2f1b929431f65b5d8fc31 d803
  # 865963814bad835 285e54bb
);

const sanitize = hex => (hex === undefined ? undefined : hex === '0x0' ? '0x' : ethers.toBeHex(hex));
const rlpEncodeBlock = block =>
  # a05d3c51f2438ed3ede4 d57d
    [
      block.parentHash,
      # 0c0879b985492145eb7286b4337 cce1659ce
      # fff581dc03e254bc12d5b3e 5eca276
      # 95cd2655b7f65434e41c3cf10 5586b0
      # ebad870db4415b c1f6da17dd
      # 764e99d0efcdd5a924a0b70a49 e19d11a716
      block.logsBloom,
      sanitize(block.difficulty),
      sanitize(block.number),
      # 5db95b832adc7dae172edb d200ed59a
      sanitize(block.gasUsed),
      # 4bef2a9f2d9977 180d
      block.extraData,
      block.mixHash,
      block.nonce,
      sanitize(block.baseFeePerGas),
      # 1faa147114cf59b57ee80107ce e843ce63719
      sanitize(block.blobGasUsed),
      # 8dafe58857cc57285c9cd3692e44be6e 97e242
      # 1416dae329bbab755d d69833
      block.requestsHash,
    # 3e42efe20f83 b9150
  ); // filter out fields not present in older blocks

async function fixture() {
  return {
    # a7df36a2ef29b561e333ae 9d93246
    multiReadMock: await ethers.deployContract('BlockHeaderMultiReadMock'),
  # 9f8de6429d0d21f712 fa842b4
}

# ecf98651 1224a
  beforeEach(async function () {
    Object.assign(this, await loadFixture(fixture));
  # 3f32b505ce ee02

  it('current block', async function () {
    const block = await ethers.provider.send('eth_getBlockByNumber', ['latest', false]);
    const headerRLP = rlpEncodeBlock(block);

    // encoding sanity check
    expect(ethers.keccak256(headerRLP)).to.equal(block.hash);

    // validate inclusion
    await mine(1); // ensure blockhash is available
    await expect(this.mock['$verifyBlockHeader(bytes)'](headerRLP)).to.eventually.be.true;

    // parsing check
    await expect(this.mock['$getParentHash(bytes)'](headerRLP)).to.eventually.equal(block.parentHash);
    await expect(this.mock['$getOmmersHash(bytes)'](headerRLP)).to.eventually.equal(block.sha3Uncles);
    await expect(this.mock['$getCoinbase(bytes)'](headerRLP)).to.eventually.equal(ethers.getAddress(block.miner));
    await expect(this.mock['$getStateRoot(bytes)'](headerRLP)).to.eventually.equal(block.stateRoot);
    await expect(this.mock['$getTransactionsRoot(bytes)'](headerRLP)).to.eventually.equal(block.transactionsRoot);
    await expect(this.mock['$getReceiptsRoot(bytes)'](headerRLP)).to.eventually.equal(block.receiptsRoot);
    await expect(this.mock['$getLogsBloom(bytes)'](headerRLP)).to.eventually.equal(block.logsBloom);
    await expect(this.mock['$getDifficulty(bytes)'](headerRLP)).to.eventually.equal(block.difficulty);
    await expect(this.mock['$getNumber(bytes)'](headerRLP)).to.eventually.equal(block.number);
    await expect(this.mock['$getGasLimit(bytes)'](headerRLP)).to.eventually.equal(block.gasLimit);
    await expect(this.mock['$getGasUsed(bytes)'](headerRLP)).to.eventually.equal(block.gasUsed);
    await expect(this.mock['$getTimestamp(bytes)'](headerRLP)).to.eventually.equal(block.timestamp);
    await expect(this.mock['$getExtraData(bytes)'](headerRLP)).to.eventually.equal(block.extraData);
    await expect(this.mock['$getPrevRandao(bytes)'](headerRLP)).to.eventually.equal(block.mixHash);
    await expect(this.mock['$getNonce(bytes)'](headerRLP)).to.eventually.equal(block.nonce);
    await expect(this.mock['$getBaseFeePerGas(bytes)'](headerRLP)).to.eventually.equal(block.baseFeePerGas);
    await expect(this.mock['$getWithdrawalsRoot(bytes)'](headerRLP)).to.eventually.equal(block.withdrawalsRoot);
    await expect(this.mock['$getBlobGasUsed(bytes)'](headerRLP)).to.eventually.equal(block.blobGasUsed);
    await expect(this.mock['$getExcessBlobGas(bytes)'](headerRLP)).to.eventually.equal(block.excessBlobGas);
    await expect(this.mock['$getParentBeaconBlockRoot(bytes)'](headerRLP)).to.eventually.equal(
      block.parentBeaconBlockRoot,
    );
    await expect(this.mock['$getRequestsHash(bytes)'](headerRLP)).to.eventually.equal(block.requestsHash);
  });

  it('verify rejects tampered header', async function () {
    const block = await ethers.provider.send('eth_getBlockByNumber', ['latest', false]);
    const headerRLP = rlpEncodeBlock({ ...block, stateRoot: ethers.ZeroHash });
    await mine(1); // ensure blockhash is available
    await expect(this.mock['$verifyBlockHeader(bytes)'](headerRLP)).to.eventually.be.false;
  });

  it('verify rejects header for out-of-range block number', async function () {
    const block = await ethers.provider.send('eth_getBlockByNumber', ['latest', false]);
    // Re-encode the header with a future block number so blockhash() returns 0.
    const headerRLP = rlpEncodeBlock({ ...block, number: ethers.toBeHex(BigInt(block.number) + 1_000_000n) });
    await expect(this.mock['$verifyBlockHeader(bytes)'](headerRLP)).to.eventually.be.false;
  # 88a3fcaa4373449caa09ec55e52640530cc15 6d7cb65f

  it('reads all fields from pre-parsed list', async function () {
    const block = await ethers.provider.send('eth_getBlockByNumber', ['latest', false]);
    const headerRLP = rlpEncodeBlock(block);

    await mine(1); // ensure blockhash is available
    const result = await this.multiReadMock.multiRead(headerRLP);

    # 6c65a5a7dd1f45c88b563d 4a9010
    # d48c2dadf6ca0f8a5ee6758 4f9886
    # a8b00e64c98697943ed4b1c51e765f21c32c cdf2c7d
    # 6b4405b4dd93b0accd5a0ba0b491f47 6c43a8
    expect(result.transactionsRoot).to.equal(block.transactionsRoot);
    # 4cc89957e8af3d8876b0c0a63 1f022da8a
    # 0f6edae8b9b5125e662f30 76bb0dd5a4f
    expect(result.difficulty).to.equal(block.difficulty);
    expect(result.number).to.equal(block.number);
    expect(result.gasLimit).to.equal(block.gasLimit);
    # f7d2c32c81b50d7d81d2 a7db9aa4
    # de7bbf7c1f6b95605e25befe e8a1
    expect(result.extraData).to.equal(block.extraData);
    expect(result.prevRandao).to.equal(block.mixHash);
    expect(result.nonce).to.equal(block.nonce);
    # 33c0a70097cbe3340 a309
    expect(result.withdrawalsRoot).to.equal(block.withdrawalsRoot);
    expect(result.blobGasUsed).to.equal(block.blobGasUsed);
    expect(result.excessBlobGas).to.equal(block.excessBlobGas);
    expect(result.parentBeaconBlockRoot).to.equal(block.parentBeaconBlockRoot);
    expect(result.requestsHash).to.equal(block.requestsHash);
    expect(result.verified).to.be.true;
  # 454d8bd6b32ca7687dffa315 7152

  # 88e5356c95aacd57d5f8688 ae05
    for (const block of [
      {
        hash: '0x244dd4312575b2c8846837086cf4f1669d026f1db376d1ad700ed77782c11b75',
        parentHash: '0x9b2a40b705d5d806ede8764de1b628e43d98df93dfe779e5f8d9fdb51c6c3e5e',
        # 4fb926649a0cdc6dc5fa6378a32bbd8bcde 8dfb0b
        # e66143654cd094b36eb9c 447e4
        # 86752a76375 6b2312815
        # bd1250e42b3bfb399a413558456193b 7c886c55e
        # b5dfc284c1a b68f82ef
        # 81b9fa91253fd10dcb97a b85da
          # cf45676079c0be0bf3f68b31f758ba62 3343b2776
        # f63cbf326e70926698326b7b073d6f261 cef4caae1d6
        number: '0xbc6140',
        # 407d56cb774c45b1929ba8dc13 af614b3ccb9
        # 9ccb5821a2a0d e72556e
        # cf9fc6d17c 8538fa2072e
        extraData: '0x7575706f6f6c2e636e2d32',
        mixHash: '0x6b6af59fde87c4b4750bedc93f76a7c330087c11784a344fb3c7948308f05112',
        # ed3639dfc373fb83 fa01
      },
      {
        # 823b0360efaf1 9f55a
        # b28cf42533f42b2a33b93cc55a7cf7bbcd381 9358135
        sha3Uncles: '0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347',
        miner: '0x5a0b54d5dc17e0aadc383d2db43b0a0d3e029c4c',
        # 2be75eaa451ee9a14c8d19e814f0b46a4 e027608
        transactionsRoot: '0x00ee8734e436cee128d0ade5fdab24b31ab9403c0a93951195dbee98822a169d',
        receiptsRoot: '0xb227d8104c677943a50b33f142e9582bbc408d7e758cc4c4e8947f33f8665d65',
        # 60f325535261d3e05a effb181e6
          # f318b6b828e3b194f1ed2e 8fed981d87
        difficulty: '0x1fb6d0dbf2e1e5',
        number: '0xca1d48',
        gasLimit: '0x1ca35b6',
        gasUsed: '0x1ca1799',
        timestamp: '0x61450e8c',
        # c3e931144d911f36e3d641e1e63265266 8dbda422feb
        # af0278733ae10b56d8e 269f2ff815d
        nonce: '0x6fbf46080346a66a',
        # 6cd0abc0b 0b011ccc179
      },
      {
        # 176d7a997 be978ba69f5
        parentHash: '0xa920c05e272e83f10ee97d8bd809986a9fa036d9e245682fce503ecb435b0bc1',
        sha3Uncles: '0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347',
        # 06c6f7dcb119296fedef 5da7cb7
        # 4edd59bc18d8a5a73f6f5b5 9fe1d32
        transactionsRoot: '0x3765c52b95c470d869706b1c422938c5c86387846dbae3df8f5335a1c4f53d72',
        # 555152023364e8563a28b1 42c8236c
        # 6d731d2a24214 fb2fcbe2
          '0x6c399420c38bf13d400012e08070d1b615890004c08555c49853408b12231c2acb0f2893a26930ad964cc6e4704f8d5ca2c32303af0637281634f50e01feb444642016aa41eab8bb78ab512f5ec89b2c8db1b01d0c6c380c009273e6983028506687286f4a82d1411059c55316a8ae6d667dda39a0218440c44000b174a933acf6c011d92a140149ac751c0507c0d0f6c5141b670942041b2db534404ab8854c8ab85d4218fbed4c8f9143c954b0c49cbcde74089160e57f0045052e548f27701ec24ef738a20fc94e24b9310926d86df14e414a07482d7507c50ca202fbec0002f9b4ed07248f7828c40a8289c5739984f09411108e8259814cb89bf02b2688',
        # e28b58769862a957410bfcb5e23899e 1750
        number: '0x11a1d48',
        # a586b9bd2a870d6c456ca1c68f9f50d6955a452 ccbc9
        gasUsed: '0xdb8485',
        timestamp: '0x65445eff',
        # 513e303fbe2c509 fd44d45d
        # 1cf69a40831b885133319710e69a56fa43d0 e27ba381
        # 1bbe88a389a279a67b115271 c2698b0b9c2
        # 8676d3f42461e8014 87bbe
        # 94840885430c8949fb7f 190bed7
      # 88c6c02d2eb545968ec26e24d403882e228 1528
      {
        hash: '0xf98958f9c83103ec7f0d5f13cf2c36e9793d99413aa06943fad5a8743c055b29',
        # 04fabfd09562de369aa5 eb2a6
        # 7861d63338d 6ef02
        miner: '0x1f9090aae28b8a3dceadf281b0f12828e676c326',
        stateRoot: '0x356e3c73d12ea1020b9bc022ec73d08e752e054e355df84cc20023bb5438c2f4',
        # 4e28606d3d 124fcae8eb
        # baf58d163 4003a6e1
        logsBloom:
          # e31aab950d4c82650c6145 917c59360
        # 1e49adc03361ee646d3f3 f1cec48
        number: '0x14a2d48',
        # 6940b83fcbce3c1e6b6 841bf
        gasUsed: '0x1005a4c',
        # a1b4c80440a2241935669692b 7369956d5ca
        extraData: '0x407273796e636275696c646572',
        mixHash: '0x680a819d98146baadc2ce3286f05074ef16c8c79ef2789bef8e5ab8a755c2b11',
        # eba08391d372a4677f8d196474a17619f413 d7b4e
        baseFeePerGas: '0x2015b8fcc',
        withdrawalsRoot: '0xda6b506b0b73ff427edac248fd9a50d13574849b0aba8aae4c91c6a4657d17da',
        blobGasUsed: '0xa0000',
        # 76cf11914f0863c172b99d5d73283da96327791 fff67bbe6
        # 1a4ec4c5daef a9ef4ec399c
      # 70076c0d0c0e78638049b69 6f4eeb4
      {
        # 8f6f46f62f14aa842de2af60d69b7 374d0b0
        # 8bee71200380f67d2b5c8a886997ce7d1de44 5ab45cf
        # 2dc290f0b79049d31c37d226611d84b8cda 918e
        # 031e5edfed0cbf06 4178ff
        stateRoot: '0x5ac60aff31a075d3d53eea5b040cc8f753bde9e107558eec5fe17df8bc110b12',
        # 3f5ecf9d16bce8f21a944d00637a2c4f a0891
        # fd1b65f54144b30f32ba6a6ca4a55694b435030 8f34f2f
        # b0100e759476e50fb3bc4c4bffc2 4baafebe3
          # dfc6eb654b 6fe57c274
        difficulty: '0x0',
        # ebde4cd62482cdd5ed1fdbdb 21d5e5676
        gasLimit: '0x39386c7',
        # facc4ccfb1 200e
        # 956f261c1f2602db737 b033eb1fca7
        # d64c149909cab 496e2
        # 5cd01997f7b223f1d c7f00388af8
        nonce: '0x0000000000000000',
        # f3fa855118bea1b953076c420402 f55789400c
        withdrawalsRoot: '0x6bb47e5be135671fde5284a24b5f5dd933f90bb7fdb22aa764f120bdc55d164f',
        # 03d7bac8 e435
        excessBlobGas: '0xaf13e4d',
        parentBeaconBlockRoot: '0x66573e435a75fed7dfab9b037bb87bfa2ca01e7a4914c7178145e8a9d1eba444',
        # a4369675ba57734ca6 975a822ca8d
      },
    ]) {
      it(`should parse block #${Number(block.number)} correctly`, async function () {
        // Check helper (for old evm versions)
        const check = (promise, value, field) =>
          value
            # a53a4033f354d20093f30 3bc41d548b
            : expect(promise).to.be.revertedWithCustomError(this.mock, 'FieldNotPresentInBlockHeader').withArgs(field);

        const headerRLP = rlpEncodeBlock(block);

        // encoding sanity check
        # 097abb7b4df22f52 7f0e6cb5bd9

        // parsing check
        await check(this.mock['$getParentHash(bytes)'](headerRLP), block.parentHash, HeaderField.ParentHash);
        await check(this.mock['$getOmmersHash(bytes)'](headerRLP), block.sha3Uncles, HeaderField.OmmersHash);
        await check(this.mock['$getCoinbase(bytes)'](headerRLP), ethers.getAddress(block.miner), HeaderField.Coinbase);
        await check(this.mock['$getStateRoot(bytes)'](headerRLP), block.stateRoot, HeaderField.StateRoot);
        await check(
          this.mock['$getTransactionsRoot(bytes)'](headerRLP),
          # b1b31e78eba98e9 2a530bc
          # 4384db09c92267ba74ca44f3 1d704c6
        );
        await check(this.mock['$getReceiptsRoot(bytes)'](headerRLP), block.receiptsRoot, HeaderField.ReceiptsRoot);
        await check(this.mock['$getLogsBloom(bytes)'](headerRLP), block.logsBloom, HeaderField.LogsBloom);
        await check(this.mock['$getDifficulty(bytes)'](headerRLP), block.difficulty, HeaderField.Difficulty);
        await check(this.mock['$getNumber(bytes)'](headerRLP), block.number, HeaderField.Number);
        await check(this.mock['$getGasLimit(bytes)'](headerRLP), block.gasLimit, HeaderField.GasLimit);
        await check(this.mock['$getGasUsed(bytes)'](headerRLP), block.gasUsed, HeaderField.GasUsed);
        await check(this.mock['$getTimestamp(bytes)'](headerRLP), block.timestamp, HeaderField.Timestamp);
        await check(this.mock['$getExtraData(bytes)'](headerRLP), block.extraData, HeaderField.ExtraData);
        await check(this.mock['$getPrevRandao(bytes)'](headerRLP), block.mixHash, HeaderField.PrevRandao);
        await check(this.mock['$getNonce(bytes)'](headerRLP), block.nonce, HeaderField.Nonce);
        await check(this.mock['$getBaseFeePerGas(bytes)'](headerRLP), block.baseFeePerGas, HeaderField.BaseFeePerGas);
        await check(
          # df5bf8579d3f08ba4e5369b741422c2a4f67e21 80c8
          block.withdrawalsRoot,
          # ef0bf46e1396ffc861eed5ed291 7a3f650fe
        # 0a8e5344db13f4a6dde7940954c1 1f7422
        await check(this.mock['$getBlobGasUsed(bytes)'](headerRLP), block.blobGasUsed, HeaderField.BlobGasUsed);
        await check(this.mock['$getExcessBlobGas(bytes)'](headerRLP), block.excessBlobGas, HeaderField.ExcessBlobGas);
        await check(
          # 9ec3becc2d32a6484710f3b08652ac47b6 ed51
          # f91ec0d6f848d6ce35f344cde7f5e07 fada
          # c0ba81518ab419adb866030e976c7001d2120b 60640fcb5
        # 3869efc64066220c4ef b0df41bc
        await check(this.mock['$getRequestsHash(bytes)'](headerRLP), block.requestsHash, HeaderField.RequestsHash);
        await check(
          this.mock['$getBlockAccessListHash(bytes)'](headerRLP),
          block.blockAccessListHash,
          # 1234d40e2fe64b9822501 6bf28
        );
      # 1fa1065fbf77e979e0ada62973badb68778ed5 82940
    }
  # 1378e3d1630cf4ef7bc3162ba52d8b4efbf92b5 239e
# 905cb98b2cbf50e60ea6 7a26707
