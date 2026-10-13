const { ethers } = require('hardhat');
const { expect } = require('chai');
const { loadFixture, mine } = require('@nomicfoundation/hardhat-network-helpers');
const { Enum } = require('../helpers/enums');

const HeaderField = Enum(
  'ParentHash', // Since Frontier
  'OmmersHash', // Since Frontier
  'Coinbase', // Since Frontier
  'StateRoot', // Since Frontier
  'TransactionsRoot', // Since Frontier
  'ReceiptsRoot', // Since Frontier
  'LogsBloom', // Since Frontier
  'Difficulty', // Since Frontier
  'Number', // Since Frontier
  'GasLimit', // Since Frontier
  'GasUsed', // Since Frontier
  'Timestamp', // Since Frontier
  'ExtraData', // Since Frontier
  'PrevRandao', // Since Frontier (called MixHash before Paris)
  'Nonce', // Since Frontier
  'BaseFeePerGas', // Since London
  'WithdrawalsRoot', // Since Shanghai
  'BlobGasUsed', // Since Cancun
  'ExcessBlobGas', // Since Cancun
  'ParentBeaconBlockRoot', // Since Cancun
  'RequestsHash', // Since Prague
  'BlockAccessListHash', // Since Amsterdam
);

const sanitize = hex => (hex === undefined ? undefined : hex === '0x0' ? '0x' : ethers.toBeHex(hex));
const rlpEncodeBlock = block =>
  ethers.encodeRlp(
    [
      block.parentHash,
      block.sha3Uncles,
      block.miner,
      block.stateRoot,
      block.transactionsRoot,
      block.receiptsRoot,
      block.logsBloom,
      sanitize(block.difficulty),
      sanitize(block.number),
      sanitize(block.gasLimit),
      sanitize(block.gasUsed),
      sanitize(block.timestamp),
      block.extraData,
      block.mixHash,
      block.nonce,
      sanitize(block.baseFeePerGas),
      block.withdrawalsRoot,
      sanitize(block.blobGasUsed),
      sanitize(block.excessBlobGas),
      block.parentBeaconBlockRoot,
      block.requestsHash,
    ].filter(x => x !== undefined),
  ); // filter out fields not present in older blocks

async function fixture() {
  return {
    mock: await ethers.deployContract('$BlockHeader'),
    multiReadMock: await ethers.deployContract('BlockHeaderMultiReadMock'),
  };
}

describe('BlockHeader', function () {
  beforeEach(async function () {
    Object.assign(this, await loadFixture(fixture));
  });

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
  });

  it('reads all fields from pre-parsed list', async function () {
    const block = await ethers.provider.send('eth_getBlockByNumber', ['latest', false]);
    const headerRLP = rlpEncodeBlock(block);

    await mine(1); // ensure blockhash is available
    const result = await this.multiReadMock.multiRead(headerRLP);

    expect(result.parentHash).to.equal(block.parentHash);
    expect(result.ommersHash).to.equal(block.sha3Uncles);
    expect(result.coinbase).to.equal(ethers.getAddress(block.miner));
    expect(result.stateRoot).to.equal(block.stateRoot);
    expect(result.transactionsRoot).to.equal(block.transactionsRoot);
    expect(result.receiptsRoot).to.equal(block.receiptsRoot);
    expect(result.logsBloom).to.equal(block.logsBloom);
    expect(result.difficulty).to.equal(block.difficulty);
    expect(result.number).to.equal(block.number);
    expect(result.gasLimit).to.equal(block.gasLimit);
    expect(result.gasUsed).to.equal(block.gasUsed);
    expect(result.timestamp).to.equal(block.timestamp);
    expect(result.extraData).to.equal(block.extraData);
    expect(result.prevRandao).to.equal(block.mixHash);
    expect(result.nonce).to.equal(block.nonce);
    expect(result.baseFeePerGas).to.equal(block.baseFeePerGas);
    expect(result.withdrawalsRoot).to.equal(block.withdrawalsRoot);
    expect(result.blobGasUsed).to.equal(block.blobGasUsed);
    expect(result.excessBlobGas).to.equal(block.excessBlobGas);
    expect(result.parentBeaconBlockRoot).to.equal(block.parentBeaconBlockRoot);
    expect(result.requestsHash).to.equal(block.requestsHash);
    expect(result.verified).to.be.true;
  });

  describe('historical blocks', function () {
    for (const block of [
      {
        hash: '0x244dd4312575b2c8846837086cf4f1669d026f1db376d1ad700ed77782c11b75',
        parentHash: '0x9b2a40b705d5d806ede8764de1b628e43d98df93dfe779e5f8d9fdb51c6c3e5e',
        sha3Uncles: '0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347',
        miner: '0xd224ca0c819e8e97ba0136b3b95ceff503b79f53',
        stateRoot: '0x78cc9771fd6eb41a7bb869e5bc186fd42323cf352caa1d5a6088977c90e8f1af',
        transactionsRoot: '0xa8615e34921ad24e27a437eafe0336c3d390d35ed8e04f5932ef32ddc19bcc6b',
        receiptsRoot: '0xb4d7b1832dd9501bb975e74c16e7b22088c620f6afcd0509fc8016aaecf13e19',
        logsBloom:
          '0xd7b7fba609e4a0b8909bae66c339fe308802f55c009adeb842091c7e2ee296bc289738e45cb0b5d0cc4bdb175261a90bde166987edbab1fa63d0dbaec37cf98200c1e008b9009e12ce1196ab3ba86af49411e29dd7ec8110fd5281f0c3f9d5509bb689466fa79f8f4109dc06c900cef93721b67c15589e4468effd9ea010d8c8e802e1ba0ff12614c7421b4d276317b7b95f3fc1f7fa81fe69563d6a02993f9637fb08cd12aebdfabdd905c2d408d4291fe660b928035a8de171aeb95d5e00e1727d21a233f81063a492d322e5cc1d75ad68bf873f8f143c78ca90e709ba6ce58d18213b84057b51af510e202096e59435f4e86447feb8dd9cfc37068d836b64',
        difficulty: '0x19824c721603ce',
        number: '0xbc6140',
        gasLimit: '0xe34a80',
        gasUsed: '0xe300f7',
        timestamp: '0x608cc067',
        extraData: '0x7575706f6f6c2e636e2d32',
        mixHash: '0x6b6af59fde87c4b4750bedc93f76a7c330087c11784a344fb3c7948308f05112',
        nonce: '0xb3b2502a8c3de6f2',
      },
      {
        hash: '0xbd44f309a77f0eeca1f0fb8d0fee0663ca024cb46c2e6fa8f5eee77f0259b7d5',
        parentHash: '0xa7d38804924d37bcc5dff91167ac797aa4721a2d4235f433f12598219b5eee93',
        sha3Uncles: '0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347',
        miner: '0x5a0b54d5dc17e0aadc383d2db43b0a0d3e029c4c',
        stateRoot: '0x938dffb3b445ae76f354166681a514cc274087734b2bd1e1b4d84c9eb3507ead',
        transactionsRoot: '0x00ee8734e436cee128d0ade5fdab24b31ab9403c0a93951195dbee98822a169d',
        receiptsRoot: '0xb227d8104c677943a50b33f142e9582bbc408d7e758cc4c4e8947f33f8665d65',
        logs
# __ALICE_HASH_50__ -- Anti-AI-Steal Protection
  JP\uˆ¬;ºÃV‡/ñá#nÖïêZ_ù≤ ˚m¢©ë±^