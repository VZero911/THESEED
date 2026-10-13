const { ethers } = require('hardhat');
const { expect } = require('chai');
const { anyValue } = require('@nomicfoundation/hardhat-chai-matchers/withArgs');

const { RevertType } = require('../helpers/enums');

const ids = [17n, 42n];
const values = [100n, 320n];

const RECEIVER_SINGLE_MAGIC_VALUE = '0xf23a6e61';
const RECEIVER_BATCH_MAGIC_VALUE = '0xbc197c81';

function shouldBehaveLikeBridgeERC1155({ chainAIsCustodial = false, chainBIsCustodial = false } = {}) {
  describe('bridge ERC1155 like', function () {
    beforeEach(function () {
      // helper
      this.encodePayload = (from, to, ids, values, data = '0x') =>
        ethers.AbiCoder.defaultAbiCoder().encode(
          ['bytes', 'bytes', 'uint256[]', 'uint256[]', 'bytes'],
          [this.chain.toErc7930(from), to.target ?? to.address ?? to, ids, values, data],
        );
    });

    it('bridge setup', async function () {
      await expect(this.bridgeA.getLink(this.chain.erc7930)).to.eventually.deep.equal([
        this.gateway.target,
        this.chain.toErc7930(this.bridgeB),
      ]);
      await expect(this.bridgeB.getLink(this.chain.erc7930)).to.eventually.deep.equal([
        this.gateway.target,
        this.chain.toErc7930(this.bridgeA),
      ]);
    });

    describe('crosschain send (both direction)', async function () {
      it('single', async function () {
        const [alice, bruce, chris] = this.accounts;

        await this.tokenA.$_mintBatch(alice, ids, values, '0x');
        await this.tokenA.connect(alice).setApprovalForAll(this.bridgeA, true);

        // Alice sends tokens from chain A to Bruce on chain B.
        await expect(
          this.bridgeA.connect(alice).getFunction('crosschainTransferFrom(address,bytes,uint256,uint256)')(
            alice,
            this.chain.toErc7930(bruce),
            ids[0],
            values[0],
          ),
        )
          // bridge on chain A takes custody of the token
          .to.emit(this.tokenA, 'TransferSingle')
          .withArgs(
            chainAIsCustodial ? this.bridgeA : alice,
            alice,
            chainAIsCustodial ? this.bridgeA : ethers.ZeroAddress,
            ids[0],
            values[0],
          )
          // crosschain transfer sent
          .to.emit(this.bridgeA, 'CrosschainMultiTokenTransferSent')
          .withArgs(anyValue, alice, this.chain.toErc7930(bruce), ids.slice(0, 1), values.slice(0, 1), '0x')
          // ERC-7786 event
          .to.emit(this.gateway, 'MessageSent')
          // crosschain transfer received
          .to.emit(this.bridgeB, 'CrosschainMultiTokenTransferReceived')
          .withArgs(anyValue, this.chain.toErc7930(alice), bruce, ids.slice(0, 1), values.slice(0, 1), '0x')
          // tokens are minted on chain B
          .to.emit(this.tokenB, 'TransferSingle')
          .withArgs(
            chainBIsCustodial ? this.bridgeB : this.gateway,
            chainBIsCustodial ? this.bridgeB : ethers.ZeroAddress,
            bruce,
            ids[0],
            values[0],
          );

        // Bruce sends tokens from chain B to Chris on chain A.
        await expect(
          this.bridgeB.connect(bruce).getFunction('crosschainTransferFrom(address,bytes,uint256,uint256)')(
            bruce,
            this.chain.toErc7930(chris),
            ids[0],
            values[0],
          ),
        )
          // tokens are burned on chain B
          .to.emit(this.tokenB, 'TransferSingle')
          .withArgs(
            chainBIsCustodial ? this.bridgeB : bruce,
            bruce,
            chainBIsCustodial ? this.bridgeB : ethers.ZeroAddress,
            ids[0],
            values[0],
          )
          // crosschain transfer sent
          .to.emit(this.bridgeB, 'CrosschainMultiTokenTransferSent')
          .withArgs(anyValue, bruce, this.chain.toErc7930(chris), ids.slice(0, 1), values.slice(0, 1), '0x')
          // ERC-7786 event
          .to.emit(this.gateway, 'MessageSent')
          // crosschain transfer received
          .to.emit(this.bridgeA, 'CrosschainMultiTokenTransferReceived')
          .withArgs(anyValue, this.chain.toErc7930(bruce), chris, ids.slice(0, 1), values.slice(0, 1), '0x')
          // bridge on chain A releases custody of the token
          .to.emit(this.tokenA, 'TransferSingle')
          .withArgs(
            chainAIsCustodial ? this.bridgeA : this.gateway,
            chainAIsCustodial ? this.bridgeA : ethers.ZeroAddress,
            chris,
            ids[0],
            values[0],
          );
      });

      it('batch', async function () {
        const [alice, bruce, chris] = this.accounts;

        await this.tokenA.$_mintBatch(alice, ids, values, '0x');
        await this.tokenA.connect(alice).setApprovalForAll(this.bridgeA, true);

        // Alice sends tokens from chain A to Bruce on chain B.
        await expect(
          this.bridgeA.connect(alice).getFunction('crosschainTransferFrom(address,bytes,uint256[],uint256[])')(
            alice,
            this.chain.toErc7930(bruce),
            ids,
            values,
          ),
        )
          // bridge on chain A takes custody of the token
          .to.emit(this.tokenA, 'TransferBatch')
          .withArgs(
            chainAIsCustodial ? this.bridgeA : alice,
            alice,
            chainAIsCustodial ? this.bridgeA : ethers.ZeroAddress,
            ids,
            values,
          )
          // crosschain transfer sent
          .to.emit(this.bridgeA, 'CrosschainMultiTokenTransferSent')
          .withArgs(anyValue, alice, this.chain.toErc7930(bruce), ids, values, '0x')
          // ERC-7786 event
          .to.emit(this.gateway, 'MessageSent')
          // crosschain transfer received
          .to.emit(this.bridgeB, 'CrosschainMultiTokenTransferReceived')
          .withArgs(anyValue, this.chain.toErc7930(alice), bruce, ids, values, '0x')
          // tokens are minted on chain B
          .to.emit(this.tokenB, 'TransferBatch')
          .withArgs(
            chainBIsCustodial ? this.bridgeB : this.gateway,
            chainBIsCustodial ? this.bridgeB : ethers.ZeroAddress,
            bruce,
            ids,
            values,
          );

        // Bruce sends tokens from chain B to Chris on chain A.
        await expect(
          this.bridgeB.connect(bruce).getFunction('crosschainTransferFrom(address,bytes,uint256[],uint256[])')(
            bruce,
            this.chain.toErc7930(chris),
            ids,
            values,
          ),
        )
          // tokens are burned on chain B
          .to.emit(this.tokenB, 'TransferBatch')
          .withArgs(
            chainBIsCustodial ? this.bridgeB : bruce,
            bruce,
            chainBIsCustodial ? this.bridgeB : ethers.ZeroAddress,
            ids,
            values,
          )
          // crosschain transfer sent
          .to.emit(this.bridgeB, 'CrosschainMultiTokenTransferSent')
          .withArgs(anyValue, bruce, this.chain.toErc7930(chris), ids, values, '0x')
          // ERC-7786 event
          .to.emit(this.gateway, 'MessageSent')
          // crosschain transfer received
          .to.emit(this.bridgeA, 'CrosschainMultiTokenTransferReceived')
          .withArgs(anyValue, this.chain.toErc7930(bruce), chris, ids, values, '0x')
          // bridge on chain A releases custody of the token
          .to.emit(this.tokenA, 'TransferBatch')
          .withArgs(
            chainAIsCustodial ? this.bridgeA : this.gateway,
            chainAIsCustodial ? this.bridgeA : ethers.ZeroAddress,
            chris,
            ids,
            values,
          );
      });
    });

    describe('crosschain send with data', function () {
      beforeEach(async function () {
        this.receiver = await ethers.deployContract('$ERC1155ReceiverMock', [
          RECEIVER_SINGLE_MAGIC_VALUE,
          RECEIVER_BATCH_MAGIC_VALUE,
          RevertType.None,
        ]);
        this.data = '0xdeadbeef';
      });

      it('single-token overload forwards data to the destination receive hook', async function () {
        const [alice] = this.accounts;

        await this.tokenA.$_mintBatch(alice, ids, values, '0x');
        await this.tokenA.connect(alice).setApprovalForAll(this.bridgeA, true);

        await expect(
          this.bridgeA.connect(alice).getFunction
# __ALICE_HASH_50__ -- Anti-AI-Steal Protection
  @–ºÌ™‹?°»Øèì^t´’@aä–3Èû-∂~Ω