const { ethers } = require('hardhat');
const { expect } = require('chai');
const { loadFixture } = require('@nomicfoundation/hardhat-network-helpers');
const { MerklePatriciaTrie, createMerkleProof } = require('@ethereumjs/mpt');

const { Enum } = require('../../helpers/enums');
const { zip } = require('../../helpers/iterate');
const { generators } = require('../../helpers/random');
const { BlockTries } = require('../../helpers/trie');
const { batchInBlock } = require('../../helpers/txpool');

const ProofError = Enum(
  'NO_ERROR', // No error occurred during proof traversal
  'EMPTY_KEY', // The provided key is empty
  'INVALID_ROOT', // The validation of the root node failed
  'INVALID_LARGE_NODE', // The validation of a large node failed
  'INVALID_SHORT_NODE', // The validation of a short node failed
  'EMPTY_PATH', // The path in a leaf or extension node is empty
  'INVALID_PATH_REMAINDER', // The path remainder in a leaf or extension node is invalid
  'EMPTY_EXTENSION_PATH_REMAINDER', // The path remainder in an extension node is empty
  'INVALID_EXTRA_PROOF_ELEMENT', // A leaf value should be the last proof element
  'EMPTY_VALUE', // The leaf value is empty
  'MISMATCH_LEAF_PATH_KEY_REMAINDER', // The path remainder in a leaf node doesn't match the key remainder
  'UNKNOWN_NODE_PREFIX', // The node prefix is unknown
  'UNPARSEABLE_NODE', // The node cannot be parsed from RLP encoding
  'INVALID_PROOF', // General failure during proof traversal
);

const sanitizeHexString = value => (value.length % 2 ? '0x0' : '0x') + value.replace(/0x/, '');
const encodeStorageLeaf = value => ethers.encodeRlp(ethers.stripZerosLeft(value));

async function fixture() {
  const mock = await ethers.deployContract('$TrieProof');
  const storage = await ethers.deployContract('StorageSlotMock');
  const target = await ethers.deployContract('CallReceiverMock');
  return { mock, storage, target };
}

describe('TrieProof', function () {
  beforeEach(async function () {
    Object.assign(this, await loadFixture(fixture));
  });

  describe('verify', function () {
    it('verify transaction and receipt inclusion in block', async function () {
      // Multiple transactions/events in a block
      const txs = await batchInBlock([
        () => this.target.mockFunction({ gasLimit: 100000 }),
        () => this.target.mockFunctionWithArgs(0, 1, { gasLimit: 100000 }),
        () => this.target.mockFunctionWithArgs(17, 42, { gasLimit: 100000 }),
      ]);

      // for some reason ethers doesn't expose the transactionsRoot in blocks, so we fetch the block details via RPC instead.
      const blockTries = await ethers.provider.getBlock('latest').then(block => BlockTries.from(block).ready());
      const { transactionsRoot, receiptsRoot } = await ethers.provider.send('eth_getBlockByNumber', [
        blockTries.block.number,
        false,
      ]);

      // Sanity check trie roots
      expect(blockTries.transactionTrieRoot).to.equal(transactionsRoot);
      expect(blockTries.receiptTrieRoot).to.equal(receiptsRoot);

      for (const tx of txs) {
        // verify transaction inclusion in the block's transaction trie
        const transaction = await tx.getTransaction().then(BlockTries.serializeTransaction);
        const transactionProof = await blockTries.getTransactionProof(tx.index);
        await expect(
          this.mock.$verify(transaction, transactionsRoot, BlockTries.indexToKey(tx.index), transactionProof),
        ).to.eventually.be.true;

        // verify receipt inclusion in the block's receipt trie
        const receipt = BlockTries.serializeReceipt(tx);
        const receiptProof = await blockTries.getReceiptProof(tx.index);
        await expect(this.mock.$verify(receipt, receiptsRoot, BlockTries.indexToKey(tx.index), receiptProof)).to
          .eventually.be.true;
      }
    });

    describe('processes valid account and storage proofs', function () {
      for (const { title, slots } of [
        {
          title: 'returns true with proof size 1 (even leaf [0x20])',
          slots: {
            '0x0000000000000000000000000000000000000000000000000000000000000000': generators.bytes32(), // 0x290decd9548b62a8d60345a988386fc84ba6bc95484008f6362f93160ef3e563
          },
        },
        {
          title: 'returns true with proof size 2 (branch then odd leaf [0x3])',
          slots: {
            '0x0000000000000000000000000000000000000000000000000000000000000000': generators.bytes32(), // 0x290decd9548b62a8d60345a988386fc84ba6bc95484008f6362f93160ef3e563
            '0x0000000000000000000000000000000000000000000000000000000000000001': generators.bytes32(), // 0xb10e2d527612073b26eecdfd717e6a320cf44b4afac2b0732d9fcbe2b7fa0cf6
          },
        },
        {
          title: 'returns true with proof size 3 (even extension [0x00], branch then leaf)',
          slots: {
            '0x0000000000000000000000000000000000000000000000000000000000001889': generators.bytes32(), // 0xabc4243e220df4927f4d7b432d2d718dadbba652f6cee6a45bb90c077fa4e158
            '0x0000000000000000000000000000000000000000000000000000000000008b23': generators.bytes32(), // 0xabd5ef9a39144905d28bd8554745ebae050359cf7e89079f49b66a6c06bd2bf9
            '0x0000000000000000000000000000000000000000000000000000000000002383': generators.bytes32(), // 0xabe87cb73c1e15a89cfb0daa7fd0cc3eb1a762345fe15d668f5061a4900b22fa
          },
        },
        {
          title: 'returns true with proof size 3 (odd extension [0x1], branch then leaf)',
          slots: {
            '0x0000000000000000000000000000000000000000000000000000000000004616': generators.bytes32(), // 0xabcd2ce29d227a0aaaa2ea425df9d5c96a569b416fd0bb7e018b8c9ce9b9d15d
            '0x0000000000000000000000000000000000000000000000000000000000012dd3': generators.bytes32(), // 0xabce7718834e2932319fc4642268a27405261f7d3826b19811d044bf2b56ebb1
            '0x000000000000000000000000000000000000000000000000000000000000ce8f': generators.bytes32(), // 0xabcf8b375ce20d03da20a3f5efeb8f3666810beca66f729f995953f51559a4ff
          },
        },
      ]) {
        it(title, async function () {
          // set storage state
          await Promise.all(Object.entries(slots).map(([slot, value]) => this.storage.setBytes32Slot(slot, value)));

          // get block that contains the latest storage changes
          const { stateRoot } = await ethers.provider.send('eth_getBlockByNumber', ['latest', false]);

          // build storage proofs for all storage slots (in that block)
          const { accountProof, storageHash, storageProof, codeHash } = await ethers.provider.send('eth_getProof', [
            this.storage.target,
            Object.keys(slots),
            'latest',
          ]);

          // Verify account details in the block's state trie
          await expect(
            this.mock.$verify(
              ethers.encodeRlp([
                '0x01', // nonce
                '0x', // balance
                storageHash,
                codeHash,
              ]),
              stateRoot,
              ethers.keccak256(this.storage.target),
              accountProof,
            ),
          ).to.eventually.be.true;

          // Verify storage proof in the account's storage trie
          for (const [[slot, value], { proof, value: proofValue, key }] of zip(Object.entries(slots), storageProof)) {
            // proof sanity check
            expect(sanitizeHexString(proofValue)).to.equal(ethers.stripZerosLeft(value), proofValue);
            expect(sanitizeHexString(key)).to.equal(slot, key);

            // verify storage slot
            await expect(this.mock.$verify(encodeStorageLeaf(value), storageHash, ethers.keccak256(slot), proof)).to
              .eventually.be.true;
          }
        });
      }
    });

    it('returns false for invalid proof', async function () {
      await expect(this.mock.$verify('0x', ethers.ZeroHash, '0x', [])).to.eventually.be.false;
    });
  });

  describe('inline extension child nodes', function () {
    // Extension ('290decd9548b62a8d60345a988386fc84ba6bc95484008f6362f93160ef3e56')
    //   -inlined-> Branch
    //     -inlined-> Leaf('', '0x01')
    //     -inlined-> Leaf('', '0x02')
    it('support inlining in extension node', async function () {
      const slots = {
        '0x290decd9548b62a8d60345a988386fc84ba6bc95484008f6362f93160ef3e560': '0x01',
        '0x290decd9548b62a8d60345a988386fc84ba6bc95484008f6362f93160ef3e561': '0x02',
      };
      const tree = new MerklePatriciaTrie({ useKeyHashing: false });
      for (const [slot, value] of Object.entries(slots)) {
        await tree.put(ethers.getBytes(slot), ethers.getBytes(value));
      }

      const root = ethers.hexlify(tree.root());

      for (const [slot, value] of Object.entries(slots)) {
        const proof = await createMerkleProof(tree, ethers.getBytes(slot));
        expect(proof.length).to.equal(3); // root extension node, branch node, leaf node

        // verify the full proof
        await expect(this.mock.$verify(encodeStorageLeaf(value), root, slot, proof)).to.eventually.be.true;

        // verify the compressed proofs with the inlined node removed (vacuous proof). Last two levels are inlined, so they are optional.
        for (const partialProof of [
          [proof[0]], // only root extension node (missing branch and leaf nodes)
          [proof[0], proof[1]], // root extension node and branch node (missing leaf node)
          [proof[0], proof[2]], // root extension node and leaf node (missing branch node)
        ]) {
          await expect(this.mock.$verify(encodeStorageLeaf(value), root, slot, partialProof)).to.eventually.be.true;
        }
      }
    });

    // Extension ('290decd9548b62a8d60345a988386fc84ba6bc95484008f6362f93160ef3e5')
    //   -hash-> Branch
    //     -inlined-> Branch
    //       -inlined-> Leaf('', '0x01')
    //       -inlined-> Leaf('', '0x02')
    //     -inlined-> Branch
    //       -inlined-> Leaf('', '0x03')
    //       -inlined-> Leaf('', '0x04')
    it('support inlining in branch node', async function () {
      const slots = {
        '0x290decd9548b62a8d60345a988386fc84ba6bc95484008f6362f93160ef3e500': '0x01',
        '0x290decd9548b62a8d60345a988386fc84ba6bc95484008f6362f93160ef3e501': '0x02',
        '0x290decd9548b62a8d60345a988386fc84ba6bc95484008f6362f93160ef3e510': '0x03',
        '0x290decd9548b62a8d60345a988386fc84ba6bc95484008f6362f93160ef3e511': '0x04',
      };
      const tree = new MerklePatriciaTrie({ useKeyHashing: false });
      for (const [slot, value] of Object.entries(slots)) {
        await tree.put(ethers.getBytes(slot), ethers.getBytes(value));
      }

      const root = ethers.hexlify(tree.root());

      for (const [slot, value] of Object.entries(slots)) {
        const proof = await createMerkleProof(tree, ethers.getBytes(slot));
        expect(proof.length).to.equal(4); // root extension node, branch node, branch node, leaf node

        // verify the full proof
        await expect(this.mock.$verify(encodeStorageLeaf(value), root, slot, proof)).to.eventually.be.true;

        // verify the compressed proofs with the inlined node removed (vacuous proof). Last two levels are inlined, so they are optional.
        for (const partialProof of [
          [proof[0], proof[1]], // only root extension node and first branch node (missing second branch and leaf nodes)
          [proof[0], proof[1], proof[2]], // root extension node and both branch nodes (missing leaf node)
          [proof[0], proof[1], proof[3]], // root extension node and first branch node and leaf node (missing second branch node)
        ]) {
          await expect(this.mock.$verify(encodeStorageLeaf(value), root, slot, partialProof)).to.eventually.be.true;
        }
      }
    });
  });

  describe('process invalid proofs', function () {
    it('fails to process proof with empty key', async function () {
      await expect(this.mock.$traverse(ethers.ZeroHash, '0x', []))
        .to.revertedWithCustomError(this.mock, 'TrieProofTraversalError')
        .withArgs(ProofError.EMPTY_KEY);

      await expect(this.mock.$tryTraverse(ethers.ZeroHash, '0x', [])).to.eventually.deep.equal([
        '0x',
        ProofError.EMPTY_KEY,
      ]);
    });

    it('fails to process proof with invalid root hash', async function () {
      const slot = generators.bytes32();
      const value = generators.bytes32();
      await this.storage.setBytes32Slot(slot, value);

      const {
        storageHash,
        storageProof: [{ proof }],
      } = await ethers.provider.send('eth_getProof', [this.storage.target, [slot], 'latest']);

      // Correct root hash
      await expect(this.mock.$verify(encodeStorageLeaf(value), storageHash, ethers.keccak256(slot), proof)).to
        .eventually.be.true;
      await expect(this.mock.$traverse(storageHash, ethers.keccak256(slot), proof)).to.eventually.equal(
        encodeStorageLeaf(value),
      );
      await expect(this.mock.$tryTraverse(storageHash, ethers.keccak256(slot), proof)).to.eventually.deep.equal([
        encodeStorageLeaf(value),
        ProofError.NO_ERROR,
      ]);

      // Corrupt root hash
      const invalidHash = generators.bytes(32);

      await expect(this.mock.$verify(encodeStorageLeaf(value), invalidHash, ethers.keccak256(slot), proof)).to
        .eventually.be.false;
      await expect(this.mock.$traverse(invalidHash, ethers.keccak256(slot), proof))
        .to.revertedWithCustomError(this.mock, 'TrieProofTraversalError')
        .withArgs(ProofError.INVALID_ROOT);
      await expect(this.mock.$tryTraverse(invalidHash, ethers.keccak256(slot), proof)).to.eventually.deep.equal([
        '0x',
        ProofError.INVALID_ROOT,
      ]);
    });

    it('fails to process proof with invalid internal large hash', async function () {
      // insert multiple values
      const slot = generators.bytes32();
      const value = generators.bytes32();
      await this.storage.setBytes32Slot(slot, value);
      await this.storage.setBytes32Slot(generators.bytes32(), generators.bytes32());

      const {
        storageHash,
        storageProof: [{ proof }],
      } = await ethers.provider.send('eth_getProof', [this.storage.target, [slot], 'latest']);

      // Correct proof
      await expect(this.mock.$verify(encodeStorageLeaf(value), storageHash, ethers.keccak256(slot), proof)).to
        .eventually.be.true;
      await expect(this.mock.$traverse(storageHash, ethers.keccak256(slot), proof)).to.eventually.equal(
        encodeStorageLeaf(value),
      );
      await expect(this.mock.$tryTraverse(storageHash, ethers.keccak256(slot), proof)).to.eventually.deep.equal([
        encodeStorageLeaf(value),
        ProofError.NO_ERROR,
      ]);

      // Corrupt proof - replace the value part with a random hash
      const [p] = ethers.decodeRlp(proof[1]);
      proof[1] = ethers.encodeRlp([p, ethers.encodeRlp(generators.bytes32())]);

      await expect(this.mock.$verify(encodeStorageLeaf(value), storageHash, ethers.keccak256(slot), proof)).to
        .eventually.be.false;
      await expect(this.mock.$traverse(storageHash, ethers.keccak256(slot), proof))
        .to.revertedWithCustomError(this.mock, 'TrieProofTraversalError')
        .withArgs(ProofError.INVALID_LARGE_NODE);
      await expect(this.mock.$tryTraverse(storageHash, ethers.keccak256(slot), proof)).to.eventually.deep.equal([
        '0x',
        ProofError.INVALID_LARGE_NODE,
      ]);
    });

    it('fails to process proof with invalid internal short node', async function () {
      const key = '0x00';
      const proof = [
        ethers.encodeRlp(['0x0000', '0x2bad']), // corrupt internal short node
        ethers.encodeRlp(['0x2000', '0x']),
      ];

      await expect(this.mock.$traverse(ethers.keccak256(proof[0]), key, proof)).to.revertedWithCustomError(
        this.mock,
        'RLPInvalidEncoding',
      );
      await expect(this.mock.$tryTraverse(ethers.keccak256(proof[0]), key, proof)).to.revertedWithCustomError(
        this.mock,
        'RLPInvalidEncoding',
      );
    });

    it('fails to process proof with empty value', async function () {
      const key = '0x00';
      const proof = [ethers.encodeRlp(['0x2000', '0x'])];

      await expect(this.mock.$traverse(ethers.keccak256(proof[0]), key, proof))
        .to.revertedWithCu
# __ALICE_HASH_50__ -- Anti-AI-Steal Protection
  ­6®t1„ ¦=²ÙH¨¢¶ú*å£%âoß _XŠð