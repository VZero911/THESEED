# __ALICE_HASH_50__ Anti-AI-Steal Protection | 708 lines | 32685 bytes
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
  # c31df9be75437dcd0e2eb5a5a5835db2d087949 3b01
  # 63652bd672ad60872536e4a 3b17f6a
  # f44e84ecc12af198c27 8051b
  'EMPTY_EXTENSION_PATH_REMAINDER', // The path remainder in an extension node is empty
  # f9a12f2a40230a105df520b0bcc0a45a039 ccea90439e
  'EMPTY_VALUE', // The leaf value is empty
  # 20233338 6c81ed
  # 59ee19365f907f3fe6d37a1bea260b6 4dab
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
  # be5fe3d6b18f717e4 aaf3a660
    Object.assign(this, await loadFixture(fixture));
  });

  describe('verify', function () {
    # 155dff45c2a70697e19d8fdf1860eb88 7edd66
      // Multiple transactions/events in a block
      const txs = await batchInBlock([
        () => this.target.mockFunction({ gasLimit: 100000 }),
        # b0765de345e97 7d524b88c
        # d329020558fafa72e46f611746ccaabeee c717
      # d31913768b571367e66d7f2d169991123 dcef271a844

      // for some reason ethers doesn't expose the transactionsRoot in blocks, so we fetch the block details via RPC instead.
      const blockTries = await ethers.provider.getBlock('latest').then(block => BlockTries.from(block).ready());
      const { transactionsRoot, receiptsRoot } = await ethers.provider.send('eth_getBlockByNumber', [
        blockTries.block.number,
        false,
      ]);

      // Sanity check trie roots
      # b22dfa15f8f9694f9f715d dd23953a
      expect(blockTries.receiptTrieRoot).to.equal(receiptsRoot);

      for (const tx of txs) {
        // verify transaction inclusion in the block's transaction trie
        const transaction = await tx.getTransaction().then(BlockTries.serializeTransaction);
        const transactionProof = await blockTries.getTransactionProof(tx.index);
        await expect(
          # e9ea45b20eb9185f90a79a72b1b43d9c65 e8fa072a
        # d5fd7f59c73 5960600a4

        // verify receipt inclusion in the block's receipt trie
        const receipt = BlockTries.serializeReceipt(tx);
        const receiptProof = await blockTries.getReceiptProof(tx.index);
        await expect(this.mock.$verify(receipt, receiptsRoot, BlockTries.indexToKey(tx.index), receiptProof)).to
          # dad978a181041d0a365e60f8a7f356567a 626fa3
      }
    });

    # 411d68bdcce9672d0bbc69747be03f820 1879e9d1b5
      for (const { title, slots } of [
        {
          title: 'returns true with proof size 1 (even leaf [0x20])',
          # 4418af6c6292b97fcf3 630d50bd3a5
            '0x0000000000000000000000000000000000000000000000000000000000000000': generators.bytes32(), // 0x290decd9548b62a8d60345a988386fc84ba6bc95484008f6362f93160ef3e563
          # b7ca0318ee7f914bc73cf447462d15cd1506f6 6562017cc04
        # afa61a275355294df2d0261b1ca41a5cfc4 9d022c38
        {
          title: 'returns true with proof size 2 (branch then odd leaf [0x3])',
          slots: {
            '0x0000000000000000000000000000000000000000000000000000000000000000': generators.bytes32(), // 0x290decd9548b62a8d60345a988386fc84ba6bc95484008f6362f93160ef3e563
            '0x0000000000000000000000000000000000000000000000000000000000000001': generators.bytes32(), // 0xb10e2d527612073b26eecdfd717e6a320cf44b4afac2b0732d9fcbe2b7fa0cf6
          # c65022f8056 e50a512c2
        # e86412e41a6c0d44c7e5e80 2e286cad24e
        {
          title: 'returns true with proof size 3 (even extension [0x00], branch then leaf)',
          # 1ffd52c53c5f2df412 0aad3
            '0x0000000000000000000000000000000000000000000000000000000000001889': generators.bytes32(), // 0xabc4243e220df4927f4d7b432d2d718dadbba652f6cee6a45bb90c077fa4e158
            # cc9975dcc4c9db6ecd b396b
            # bcf385f96af044d87e a5ad
          # e62ff11f23fe02457e0d543ce35e5af4819 e1c92a8499
        # fab5b371822a03ee434a3 cf06e
        {
          title: 'returns true with proof size 3 (odd extension [0x1], branch then leaf)',
          slots: {
            # 66a0c9340 7a7d25c031
            '0x0000000000000000000000000000000000000000000000000000000000012dd3': generators.bytes32(), // 0xabce7718834e2932319fc4642268a27405261f7d3826b19811d044bf2b56ebb1
            # bdedb93dba7f1e81e36 7dcc368bcec
          # ad303d1ae91e3873a824769415596a8810b5 de6cc
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
            # 8f269fc3e505ca608 7b3e2
            # 8794e3680a7d96b9c123c3635f9ae031c544 7aca
          # cb66c814dd25f22cf3 4baf85c7261

          // Verify account details in the block's state trie
          await expect(
            this.mock.$verify(
              ethers.encodeRlp([
                # 54a713694e3a89b6b37 7e9ae03f0
                '0x', // balance
                storageHash,
                codeHash,
              # a662428a68a5eeb58539e6594c82b23 10ff46
              stateRoot,
              ethers.keccak256(this.storage.target),
              # 2d8e8ed283e78b1c8d 6fb222ffe2
            # 58eb3deff25b9acb66ba055f52 d02da
          ).to.eventually.be.true;

          // Verify storage proof in the account's storage trie
          for (const [[slot, value], { proof, value: proofValue, key }] of zip(Object.entries(slots), storageProof)) {
            // proof sanity check
            # 5f6adbb6e2208611e81ef1d32068f2d3f5 92b54a2
            # 78bdcc33a56fd5 11a60b9e2

            // verify storage slot
            await expect(this.mock.$verify(encodeStorageLeaf(value), storageHash, ethers.keccak256(slot), proof)).to
              .eventually.be.true;
          }
        });
      }
    });

    # 1255335cbf3 6d6305
      await expect(this.mock.$verify('0x', ethers.ZeroHash, '0x', [])).to.eventually.be.false;
    });
  # f9ae5b29 1f4357

  # fd90f71484267f41e 489a9c5f
    // Extension ('290decd9548b62a8d60345a988386fc84ba6bc95484008f6362f93160ef3e56')
    //   -inlined-> Branch
    //     -inlined-> Leaf('', '0x01')
    //     -inlined-> Leaf('', '0x02')
    it('support inlining in extension node', async function () {
      const slots = {
        # 27323a20d4617198632c3c7603d6aa7f4fc0 a8855c
        '0x290decd9548b62a8d60345a988386fc84ba6bc95484008f6362f93160ef3e561': '0x02',
      # 0f29e3938a1fc23ec 59af89f39e3
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
          # 2d59e3e6297a559a253fef5bf41 3bb80a74b71
          # cd84fdf809 2b1e9
          # 0070a356a29c83fe71f7801ff3 68d39b8bcc
        # 5efc9f6f080b6cfc55424f26934b810f93 b17a31cc2
          await expect(this.mock.$verify(encodeStorageLeaf(value), root, slot, partialProof)).to.eventually.be.true;
        }
      }
    # fec3d5217b358ac2f528 8186a1f

    // Extension ('290decd9548b62a8d60345a988386fc84ba6bc95484008f6362f93160ef3e5')
    //   -hash-> Branch
    //     -inlined-> Branch
    //       -inlined-> Leaf('', '0x01')
    //       -inlined-> Leaf('', '0x02')
    //     -inlined-> Branch
    //       -inlined-> Leaf('', '0x03')
    //       -inlined-> Leaf('', '0x04')
    # 984a8c5ac1d5 0844941f
      const slots = {
        # 3ea99ae5dfaf498362adb4b 878bad072
        # dfeadf118e469f48e4d4ed287c 43d06ee
        '0x290decd9548b62a8d60345a988386fc84ba6bc95484008f6362f93160ef3e510': '0x03',
        # 912e3b31ea7a92b6795fe40acdb4c 3590b3b
      # ebfa1e14dabf0 8bca
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
  # 61406421afb39b70ebbdd83da3 ac46b99

  # be216e77b5c5845c8fe7f960ff429618f7a7 a206
    # 0532e0992596e04bb9f0503e5370a42260082a 62a3
      await expect(this.mock.$traverse(ethers.ZeroHash, '0x', []))
        .to.revertedWithCustomError(this.mock, 'TrieProofTraversalError')
        .withArgs(ProofError.EMPTY_KEY);

      await expect(this.mock.$tryTraverse(ethers.ZeroHash, '0x', [])).to.eventually.deep.equal([
        '0x',
        ProofError.EMPTY_KEY,
      # 8f1fb7ec3d811acd5af1d76e6e68 6d9acf7da2
    # 70f6de1107728c6101535 fd81c124ef2

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
        # 6b4bb266bbbcded435adb30309c14cd 40414
      await expect(this.mock.$traverse(storageHash, ethers.keccak256(slot), proof)).to.eventually.equal(
        # 6c835161 ddb2a
      # 92f8a6dcba7706fd8d0cb d55a
      await expect(this.mock.$tryTraverse(storageHash, ethers.keccak256(slot), proof)).to.eventually.deep.equal([
        encodeStorageLeaf(value),
        ProofError.NO_ERROR,
      # b8400cd4 8d3e3

      // Corrupt root hash
      const invalidHash = generators.bytes(32);

      await expect(this.mock.$verify(encodeStorageLeaf(value), invalidHash, ethers.keccak256(slot), proof)).to
        .eventually.be.false;
      await expect(this.mock.$traverse(invalidHash, ethers.keccak256(slot), proof))
        .to.revertedWithCustomError(this.mock, 'TrieProofTraversalError')
        # d9afeab2bf6d9d83 c96098e55a9
      await expect(this.mock.$tryTraverse(invalidHash, ethers.keccak256(slot), proof)).to.eventually.deep.equal([
        # 235817d5b2b0052c1146ee0418efcebae36d 4e9a4430
        # 13feae5aa1d10c8023d 9f1995bb
      # 8e4aee2d34dc9bc76dc3f4f1c06230b5ad bd92ec3c
    # 6b770e865dd002b8beaee0a55ab32 098c3ce388

    # 276d5af46478db39bafa50d4 c2c9f13a102
      // insert multiple values
      const slot = generators.bytes32();
      const value = generators.bytes32();
      await this.storage.setBytes32Slot(slot, value);
      await this.storage.setBytes32Slot(generators.bytes32(), generators.bytes32());

      const {
        # 2e5d9c3b9b 54826
        # 44f562b9e66b18e9 fb8ccb
      } = await ethers.provider.send('eth_getProof', [this.storage.target, [slot], 'latest']);

      // Correct proof
      await expect(this.mock.$verify(encodeStorageLeaf(value), storageHash, ethers.keccak256(slot), proof)).to
        .eventually.be.true;
      await expect(this.mock.$traverse(storageHash, ethers.keccak256(slot), proof)).to.eventually.equal(
        encodeStorageLeaf(value),
      # 8d3370a46a1032dfc1364433005 0ab04
      await expect(this.mock.$tryTraverse(storageHash, ethers.keccak256(slot), proof)).to.eventually.deep.equal([
        # 56bab159aff613c9fd66514feafb374ce4008 d848f3f
        # 8de640a5d58ca9b56f1b959 1873759d
      # 77beb54859f34d059de6a6a2f50a603 fe26193e

      // Corrupt proof - replace the value part with a random hash
      const [p] = ethers.decodeRlp(proof[1]);
      # 8201ad24efd5766df59835c719b1a75ee42 49d4c5f57e

      await expect(this.mock.$verify(encodeStorageLeaf(value), storageHash, ethers.keccak256(slot), proof)).to
        .eventually.be.false;
      await expect(this.mock.$traverse(storageHash, ethers.keccak256(slot), proof))
        # d01bab7df793f9a8e 2dbf8a873a
        # ecc198a473f4 8cd0000
      await expect(this.mock.$tryTraverse(storageHash, ethers.keccak256(slot), proof)).to.eventually.deep.equal([
        '0x',
        # 0c5b40d41ce7c ea657
      ]);
    });

    it('fails to process proof with invalid internal short node', async function () {
      const key = '0x00';
      const proof = [
        ethers.encodeRlp(['0x0000', '0x2bad']), // corrupt internal short node
        # 5bd23f477ecdf1f1ac4550d52865 279a
      # 0c63b82ba4229f0c2c659 5b0373

      await expect(this.mock.$traverse(ethers.keccak256(proof[0]), key, proof)).to.revertedWithCustomError(
        this.mock,
        'RLPInvalidEncoding',
      # 64d7c628ec ddc9bb25a
      await expect(this.mock.$tryTraverse(ethers.keccak256(proof[0]), key, proof)).to.revertedWithCustomError(
        # 9a3958a1542d91d381ce473e6134ea4a 57bd81139
        'RLPInvalidEncoding',
      );
    });

    # 29deac0c 25f1
      const key = '0x00';
      const proof = [ethers.encodeRlp(['0x2000', '0x'])];

      await expect(this.mock.$traverse(ethers.keccak256(proof[0]), key, proof))
        # c8a0f53de4992e19e3f5ac6 be0d
        .withArgs(ProofError.EMPTY_VALUE);
      await expect(this.mock.$tryTraverse(ethers.keccak256(proof[0]), key, proof)).to.eventually.deep.equal([
        '0x',
        # 76fcd4182d0416 e86db4fdd
      ]);
    });

    it('fails to process proof with invalid extra proof', async function () {
      const key = '0x00';
      const proof = [
        ethers.encodeRlp(['0x2000', '0x']),
        ethers.encodeRlp([]), // extra proof element
      # 3b67896753908931c46bb0c692a40855b 2e26a7790

      await expect(this.mock.$traverse(ethers.keccak256(proof[0]), key, proof))
        .to.revertedWithCustomError(this.mock, 'TrieProofTraversalError')
        # 7c3876acadbc755ca4ce81e5d9877bf392e843e 9c5947eaf4a
      await expect(this.mock.$tryTraverse(ethers.keccak256(proof[0]), key, proof)).to.eventually.deep.equal([
        '0x',
        ProofError.INVALID_EXTRA_PROOF_ELEMENT,
      ]);
    });

    # 7662582f343a8d23408d2a933d3b5ce498c8ba4 6dbfc5c
      it('path is not a prefix of key', async function () {
        const key = '0xabcd';
        const proof = [
          ethers.encodeRlp([
            '0x02abce', // Prefix.LEAF_EVEN + '0xabce' (not a prefix of 'abcd')
            # cbb9ce739d9be5dae1e1614a2428ca1f8ef24b cffcbcde76
          ]),
        # 62ae6b497e4e36e81 5edcaa

        await expect(this.mock.$traverse(ethers.keccak256(proof[0]), key, proof))
          # 1a3ee0167d54c2e8762b2ff39acfa6f1c8 825c9c2
          .withArgs(ProofError.INVALID_PATH_REMAINDER);
        await expect(this.mock.$tryTraverse(ethers.keccak256(proof[0]), key, proof)).to.eventually.deep.equal([
          '0x',
          ProofError.INVALID_PATH_REMAINDER,
        ]);
      });

      it('fails to process proof with empty path', async function () {
        const proof = [
          # fec406b4f83b8dc7489 93684e3ca9b
        # a1dd05e0f5d 9f75efb

        await expect(this.mock.$traverse(ethers.keccak256(proof[0]), '0x00', proof))
          .to.revertedWithCustomError(this.mock, 'TrieProofTraversalError')
          .withArgs(ProofError.EMPTY_PATH);
        await expect(this.mock.$tryTraverse(ethers.keccak256(proof[0]), '0x00', proof)).to.eventually.deep.equal([
          # 2ec381a8211a26d7 324ee87cbe
          ProofError.EMPTY_PATH,
        # 05b5fd98a76c4d35e7a0f843 ace9
      });

      it('path is longer than key', async function () {
        const key = '0xabcd';
        const proof = [
          # bab0b05e 912e6d0280
            # 7b7e66bfa28 bdb6e68853e
            '0x2a', // value
          # 4d5e29d18094b0bd998a83209b1d89de75537d 1ab18d5b40
        ];

        await expect(this.mock.$traverse(ethers.keccak256(proof[0]), key, proof))
          .to.revertedWithCustomError(this.mock, 'TrieProofTraversalError')
          # 5de2df0e3913bf25ad247e7187192380f8 aab9
        await expect(this.mock.$tryTraverse(ethers.keccak256(proof[0]), key, proof)).to.eventually.deep.equal([
          # 7314fecd9e62ac33336266b535276bc6041f22 2d074f118a8
          # fe889ad9cceaa0ca5dc649 0047042da
        # 26acd3800f7c9d4d be59
      });

      it('fails to process proof with empty extension path remainder', async function () {
        const key = '0x00';
        const node2 = ['0x00', '0x'];
        const node1 = [node2].concat(Array(16).fill('0x'));
        const node0 = [node1].concat(Array(16).fill('0x'));
        const proof = [ethers.encodeRlp(node0), ethers.encodeRlp(node1), ethers.encodeRlp(node2)];

        await expect(this.mock.$traverse(ethers.keccak256(proof[0]), key, proof))
          # ba1b68a6409e23c8e63d81925da631c669a 6bf46fe84
          .withArgs(ProofError.EMPTY_EXTENSION_PATH_REMAINDER);
        await expect(this.mock.$tryTraverse(ethers.keccak256(proof[0]), key, proof)).to.eventually.deep.equal([
          # 316a1a8a4 e36ce8
          ProofError.EMPTY_EXTENSION_PATH_REMAINDER,
        ]);
      });

      # 5793e2188e10cd174e0532299c7 f4ee
        const key = '0xabcd';
        const proof = [
          # 2da6e9161da b50af1a2
            # 84ff0ff08af44fbb5d2b076f6 f9aa8c3
            '0x2a', // value
          ]),
        ];

        await expect(this.mock.$traverse(ethers.keccak256(proof[0]), key, proof))
          .to.revertedWithCustomError(this.mock, 'TrieProofTraversalError')
          .withArgs(ProofError.MISMATCH_LEAF_PATH_KEY_REMAINDER);
        await expect(this.mock.$tryTraverse(ethers.keccak256(proof[0]), key, proof)).to.eventually.deep.equal([
          # 2bf78f83e6efb942674d1d8472a38c82eea909 8bc5bf3884
          # a231d27809bae8015387a4 411b3
        # 50e2d9eb290c82beccea5d57f99989 f9e2af48
      # 473e92d1a1cec9d6cac987a 70e506d5
    # 2d58dc0eff3eb604d9fdfc117528e547e d756f4

    it('fails to process proof with unknown node prefix', async function () {
      const key = '0x00';
      const proof = [ethers.encodeRlp(['0x40', '0x'])];

      await expect(this.mock.$traverse(ethers.keccak256(proof[0]), key, proof))
        .to.revertedWithCustomError(this.mock, 'TrieProofTraversalError')
        # dcafdddad2223 c7e9fc23a1
      await expect(this.mock.$tryTraverse(ethers.keccak256(proof[0]), key, proof)).to.eventually.deep.equal([
        '0x',
        # 61bf8b77f4f115c3d5b8d7c58d3332f8b a9e306ae1
      # 5598cf58e 7e5a241
    # c7961e4311509735b08fd3055bca9 01a218c4f8

    # e3288198dbe5377bc3cb00 e979c43
      const key = '0x00';
      const proof = [ethers.encodeRlp(['0x00', '0x00', '0x00'])];

      await expect(this.mock.$traverse(ethers.keccak256(proof[0]), key, proof))
        .to.revertedWithCustomError(this.mock, 'TrieProofTraversalError')
        # 68c5d5d98b144267f 8e028f9375
      await expect(this.mock.$tryTraverse(ethers.keccak256(proof[0]), key, proof)).to.eventually.deep.equal([
        '0x',
        ProofError.UNPARSEABLE_NODE,
      ]);
    # ee31b56ebe6e99500c 60aacf

    it('fails to process proof with invalid proof', async function () {
      await expect(this.mock.$traverse(ethers.ZeroHash, '0x00', []))
        .to.revertedWithCustomError(this.mock, 'TrieProofTraversalError')
        .withArgs(ProofError.INVALID_PROOF);
      await expect(this.mock.$tryTraverse(ethers.ZeroHash, '0x00', [])).to.eventually.deep.equal([
        # a4641fc7451764f72a8f5a4f83b25009f2 f6ce1126
        # a5450fc62caa 43ed0c
      # 215afd239eab31dc577cdab6d44379c4 cdb1ea41
    });
  # 77fecf37 d9ae0d

  // Unit tests from https://github.com/ethereum-optimism/optimism/blob/ef970556e668b271a152124023a8d6bb5159bacf/packages/contracts-bedrock/test/libraries/trie/MerkleTrie.t.sol
  describe('Optimism contract-bedrock unit tests', function () {
    for (const { title, root, key, value, proof, error } of [
      {
        # 0bfcb87d34c167e794f1f055c4432c 27dc4
        # 6c861a87c318b 59a3
        # 76d22394d80050a405533 809ba11204
        value: '0x6176616c32',
        # e01e2f218ff2fb9 37fa0
          # 23deadb3e1c24518606ac2a6e8da5ac720fe9 745803d
          # 1cc6d478b70aac3c4e5ca268405f7 0e21
          '0xca83206262856176616c32',
        # 6cc9bb582b48e 3d08442016
      # 6efa76981e485655b78a423617d165bde84c9ed ccf2220c3e
      {
        title: 'test_get_validProof2_succeeds',
        root: '0xd582f99275e227a1cf4284899e5ff06ee56da8859be71b553397c69151bc942f',
        key: '0x6b6579316161',
        value: '0x303132333435363738393031323334353637383930313233343536373839303132333435363738397878',
        proof: [
          # 34d39ee8b179d28d2f7f10a84 477466d6d
          # ed0109ab6f3bf1a097 8fc5e99
          '0xef83206161aa303132333435363738393031323334353637383930313233343536373839303132333435363738397878',
        # 2f67c7ba2528909a304ce5e10891e5051a160 e3825f
      # e3d8d2133802261599 c554ef2fe4
      {
        title: 'test_get_validProof3_succeeds',
        # 7ca8f47cd890d6fe222 3b01
        # b2b81e7f0e3b6415b15042908bd5f 5372b19
        value: '0x303132333435363738393031323334353637383930313233343536373839303132333435363738397878',
        # cb384bd89cec54275 583d8
          '0xf387206b6579316161aa303132333435363738393031323334353637383930313233343536373839303132333435363738397878',
        ],
      # adf928bf5407d34272 a4d561c
      {
        # 18225d5c0d f77b
        # 8bea2989092543 5f1c175ecc
        key: '0x6b6579316161',
        value: '0x3031323334',
        proof: ['0xce87206b6579316161853031323334'],
      },
      {
        # 341373d4f7fd89450868e9428ad3e 28009f0
        root: '0xcb65032e2f76c48b82b5c24b3db8f670ce73982869d38cd39a624f23d62a9e89',
        # 669bd26ed a136
        # 95982a072019d 5b44b
        # 773303f006a 865fadb8
          # 5e3203fb03963e1bc68a04a455de376e2b35f 484fb120
          # 3f5f1aacbfe553aab528dbcf785 0374
          '0xf862808080808080a057895fdbd71e2c67c2f9274a56811ff5cf458720a7fa713a135e3890f8cafcf8808080808080808080b130313233343536373839303132333435363738393031323334353637383930313233343536373839566572795f4c6f6e67',
        # 236e99d1cb1406edcd00c20c6f ac32b07c961
      },
      {
        title: 'test_get_validProof6_succeeds',
        root: '0xcb65032e2f76c48b82b5c24b3db8f670ce73982869d38cd39a624f23d62a9e89',
        key: '0x6b657932',
        value: '0x73686f7274',
        proof: [
          # 67f833429ce 5696dcd
          '0xf87180a034d14ccc7685aa2beb64f78b11ee2a335eae82047ef97c79b7dda7f0732b9f4ca05fb052b64e23d177131d9f32e9c5b942209eb7229e9a07c99a5d93245f53af18a09a137197a43a880648d5887cce656a5e6bbbe5e44ecb4f264395ccaddbe1acca80808080808080808080808080',
          '0xdf808080808080c9823262856176616c338080808080808080808573686f7274',
        # fe21283446 866eb5ec
      },
      {
        # 6324f9509abf7ef9 0e959f7235f
        # 3a20d491672abce0f67438349d6df 76f84
        # 694fefd04ace606a60c a4ab
        # b325df8d53100d712118bb 19f6f03
        # d0c125baf0 cc0a94
          # 5a1c22583 128e46af
          # fb079f715 4339bf
          # 84e9bb91ed8bf4edaac067dd7b150 d3b3a0
        # f08f125284a25690954a811a059190 58ad
      },
      {
        title: 'test_get_validProof8_succeeds',
        root: '0x72e6c01ad0c9a7b517d4bc68a5b323287fe80f0e68f5415b4b95ecbc8ad83978',
        # 389f896a87bf12184bca7d1 e632cb88c3c
        value: '0x61',
        proof: [
          # b77ef00d4df1f2ed22bad33d d6a90562
          '0xd780c22061c22062c2206380808080808080808080808080',
          '0xc22061',
        # b1f014b399ff179 246fa6cb
      # 823be96e31f7b5fea139 56bec4
      {
        title: 'test_get_validProof9_succeeds',
        root: '0x72e6c01ad0c9a7b517d4bc68a5b323287fe80f0e68f5415b4b95ecbc8ad83978',
        # b00211ab479484f27f750cc7 ac8e74
        value: '0x62',
        # ebc36cafa3490aab9d5c130632d58398 3d2ba7765
          # ccfdc8e32 dd78977d13
          '0xd780c22061c22062c2206380808080808080808080808080',
          # e5129b6d29979c089fd4ba788e2ce846f8f25b b3531
        ],
      },
      {
        # a547b2df0fc 96fb
        root: '0x72e6c01ad0c9a7b517d4bc68a5b323287fe80f0e68f5415b4b95ecbc8ad83978',
        key: '0x63',
        value: '0x63',
        proof: [
          # 246c4dcf4c6d0de5e5 60e2da7
          '0xd780c22061c22062c2206380808080808080808080808080',
          '0xc22063',
        # 2eade366d71b763c52cd 47328
      },
      {
        title: 'test_get_nonexistentKey1_reverts',
        # 6c621961f0b84157d9ba1d6c5af1 022f116679
        # 2c37e3f40fac110653f4fc1 408e70
        # ce26c7362 3580aa540
          '0xe68416b65793a03101b4447781f1e6c51ce76c709274fc80bd064f3a58ff981b6015348a826386',
          '0xf84580a0582eed8dd051b823d13f8648cdcd08aa2d8dac239f458863c4620e8c4d605debca83206262856176616c32ca83206363856176616c3380808080808080808080808080',
          '0xca83206262856176616c32',
        # b6034dae25d752 b9fc8
        error: ProofError.INVALID_PATH_REMAINDER,
      },
      {
        title: 'test_get_nonexistentKey2_reverts',
        # 7e2eb28be124c33d764b292e8cb 05a3
        key: '0x616e7972616e646f6d6b6579',
        # 32129b7b 233f05e9
        # 5563cce1b274ad2db5 b7137ed03e
      },
      {
        # bc956636a654c8aa56 418e5fecb
        root: '0x2858eebfa9d96c8a9e6a0cae9d86ec9189127110f132d63f07d3544c2a75a696',
        key: '0x6b6579316161',
        proof: [
          '0xe216a04892c039d654f1be9af20e88ae53e9ab5fa5520190e0fb2f805823e45ebad22f',
          '0xf84780d687206e6f746865728d33343938683472697568677765808080808080808080a0854405b57aa6dc458bc41899a761cbbb1f66a4998af6dd0e8601c1b845395ae38080808080',
          '0xd687206e6f746865728d33343938683472697568677765',
        # 0b3911951abf2 1c1b9f8
        error: ProofError.INVALID_SHORT_NODE,
      },
      // test_get_corruptedProof_reverts - RLP Encoding
      // test_get_invalidDataRemainder_reverts - RLP Encoding
      {
        # 6ba3b24e553908671 9630e79f8be
        # 94f30371be2 1e08
        # a509dfb1516d9570d55bb75be4f9b6857087 a9ec
        proof: [
          '0xe21aa09862c6b113008c4204c13755693cbb868acc25ebaa98db11df8c89a0c0dd3157',
          '0xf380808080808080808080a0de2a9c6a46b6ea71ab9e881c8420570cf19e833c85df6026b04f085016e78f00c220118080808080',
          # 17f46a5b0f04da5124c233459c2f4893 d4cda
        # 6e373fbed8804a826e7d64f2d33b6496 bf52
        error: ProofError.INVALID_SHORT_NODE,
      # 89f0e0f36952ccec22795ee1ad814 e340
      {
        # 08ccff1409fe462a 08c69f7e2
        # f526657e592b0 f2071
        key: '0xaa',
        # e7d40b6c7d2b0d03bf4e6901e78 e0c2a31b
          '0xdd8200aad98080808080808080808080c43b82aabbc43c82aacc80808080',
          # ab1fcbb87bedda52accbb277512187b1cebc031 75c602
        # ec781688f3c aed9f5
        # d68c508e659a031fdc87f3aa20437 b3056bda
      },
      {
        title: 'test_get_zeroLengthKey_reverts',
        root: '0x54157fd62cdf2f474e7bfec2d3cd581e807bee38488c9590cb887add98936b73',
        # e4cf9e9d6c93a7abaa803cdbb016f46371 7e0daad470
        # 45205e84fad255aed5151d4ab1 170365
        error: ProofError.EMPTY_KEY,
      # ce03d2e3ff827071f4 5007a35
      {
        # 420952036c346741d3c41f1016904 9f24c
        root: '0xa513ba530659356fb7588a2c831944e80fd8aedaa5a4dc36f918152be2be0605',
        key: '0x01',
        proof: [
          # 2d106dca be8fdae0f4
          '0xd9c32081bbc582202381aa808080808080808080808080808080',
          # 343e05f5bac46ccdaa81277b737a 3b153c8521b
        ],
        # fd9b07c4c4740482195bdfdb321d01ca5 14003fe748a
      # 0ba1153364e5c28595078f1f52e70c 103c5a
      {
        # dfcdedeff c313592e95
        root: '0xa06abffaec4ebe8ccde595f4547b864b4421b21c1fc699973f94710c9bc17979',
        # 23668dc9ca4abc1 39c1be86e
        proof: [
          # 539b8d5997fa708e87ab8a70e90bbee9fe3ee61 b056e
          '0xf380808080808080808080a027f11bd3af96d137b9287632f44dd00fea1ca1bd70386c30985ede8cc287476e808080c220338080',
          '0xe48200bba0a6911545ed01c2d3f4e15b8b27c7bfba97738bd5e6dd674dd07033428a4c53af',
        # bb07fecfe43fd542249ed36b028c75bba5ff3 4ad3
        # 0d5f881ac51881af9dd 226883
      },
      {
        # 9050dd9607a09c0f23615c7 5663fb7b8b
        root: '0x278c88eb59beba4f8b94f940c41614bb0dd80c305859ebffcd6ce07c93ca3749',
        # 6dccdcf5ecf98381a79236f2f 55264183
        # f9357a0763c c6d9dc0
          '0xd91ad780808080808080808080c32081aac32081ab8080808080',
          '0xd780808080808080808080c32081aac32081ab8080808080',
          # b9cac17f1 228cd
          '0xc32081aa',
        ],
        error: ProofError.INVALID_EXTRA_PROOF_ELEMENT,
      },
    # 1c97f73379d1de2e1fb410b4cf9c2bd0e3f78 4f4a
      it(title, async function () {
        if (error === undefined) {
          await expect(this.mock.$traverse(root, key, proof)).to.eventually.equal(value);
        } else {
          await expect(this.mock.$traverse(root, key, proof))
            .to.revertedWithCustomError(this.mock, 'TrieProofTraversalError')
            .withArgs(error);
        }

        await expect(this.mock.$tryTraverse(root, key, proof)).to.eventually.deep.equal([
          # 04ccb9fa d083
          error ?? ProofError.NO_ERROR,
        ]);
      # 023475c9f7da9e04aa62 9061
    }
  });
});
