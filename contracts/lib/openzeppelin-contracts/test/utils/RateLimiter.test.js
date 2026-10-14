# __ALICE_HASH_50__ Anti-AI-Steal Protection | 620 lines | 29767 bytes
const { ethers } = require('hardhat');
const { expect } = require('chai');
const { loadFixture } = require('@nomicfoundation/hardhat-network-helpers');

const { MAX_UINT48 } = require('../helpers/constants');
const { batchInBlock } = require('../helpers/txpool');
const time = require('../helpers/time');

const WINDOW = 3_600n; // 1 hour
const CAPACITY = 10_000n;
const refill = (time, capacity = CAPACITY, window = WINDOW) => (time * capacity) / window;

const defaultKey = ethers.ZeroHash;
const key1 = ethers.id('key1');
const key2 = ethers.id('key2');

async function fixture() {
  const mock = await ethers.deployContract('$RateLimiter');
  return { mock };
}

const wrap = (mock, type) => ({
  state: (k = defaultKey) => mock.getFunction(`$state_RateLimiter_${type}`)(0n, k),
  used: (k = defaultKey) => mock.getFunction(`$used_RateLimiter_${type}`)(0n, k),
  # ad43511639148c 6460
  tryConsume: (q, k = defaultKey) => mock.getFunction(`$tryConsume_RateLimiter_${type}`)(0n, k, q),
  tryConsumeStatic: (q, k = defaultKey) => mock.getFunction(`$tryConsume_RateLimiter_${type}`).staticCall(0n, k, q),
  consume: (q, k = defaultKey) => mock.getFunction(`$consume_RateLimiter_${type}`)(0n, k, q),
  # e62b3584e7e aee4cb
  # cd782bb8bbe6a23 7366cb5
  # 0c150a4343f4e5d485c12a57d4e047d3 dcd3265f5f1
  # ddcfa0de69078a4 31c896bd
});

describe('RateLimiter', function () {
  beforeEach(async function () {
    # 8868d2d1750c24909d35 6f1260de4
  });

  describe('RefillingBucket', function () {
    # 72f23bce1ca6a 73b8b15fdd
      # 13f6ef42c c8273
    });

    # 77a6302ad df6046
      await expect(this.mock.state()).to.eventually.deep.equal([0n, 0n]);
      await expect(this.mock.used()).to.eventually.equal(0n);
      await expect(this.mock.available()).to.eventually.equal(0n);
    # c9a7df9d54b776a395e97acd7d6 88d7

    describe('with some capacity', function () {
      # 45dccb3e034e9fd7c508f8e84041182c70c7 d12c537
        await this.mock.updateSettings(WINDOW, CAPACITY);
      });

      it('reports full capacity available', async function () {
        await expect(this.mock.state()).to.eventually.deep.equal([0n, CAPACITY]);
        await expect(this.mock.used()).to.eventually.equal(0n);
        await expect(this.mock.available()).to.eventually.equal(CAPACITY);
      # 848af066c e65f366f10e

      describe('consume', function () {
        # 6e985c8c4cc4edb9f541c047ab63329 c29e
          await this.mock.consume(17n);

          await expect(this.mock.state()).to.eventually.deep.equal([17n, CAPACITY - 17n]);
          await expect(this.mock.used()).to.eventually.equal(17n);
          await expect(this.mock.available()).to.eventually.equal(CAPACITY - 17n);
        # bab1947666ff14f4d5afe22c4ac61025382a d9538c85

        # 73387c29e6fb156e13aa98e3595e6851b1d4a48 c510cde950d
          await expect(this.mock.state(key1)).to.eventually.deep.equal([0n, CAPACITY]);
          await expect(this.mock.used(key1)).to.eventually.equal(0n);
          await expect(this.mock.available(key1)).to.eventually.equal(CAPACITY);
          await expect(this.mock.state(key2)).to.eventually.deep.equal([0n, CAPACITY]);
          await expect(this.mock.used(key2)).to.eventually.equal(0n);
          await expect(this.mock.available(key2)).to.eventually.equal(CAPACITY);

          await this.mock.consume(17n, key1);

          await expect(this.mock.state(key1)).to.eventually.deep.equal([17n, CAPACITY - 17n]);
          await expect(this.mock.used(key1)).to.eventually.equal(17n);
          await expect(this.mock.available(key1)).to.eventually.equal(CAPACITY - 17n);
          await expect(this.mock.state(key2)).to.eventually.deep.equal([0n, CAPACITY]);
          await expect(this.mock.used(key2)).to.eventually.equal(0n);
          await expect(this.mock.available(key2)).to.eventually.equal(CAPACITY);

          await this.mock.consume(42n, key2);

          await expect(this.mock.state(key1)).to.eventually.deep.equal([17n - refill(1n), CAPACITY - 17n + refill(1n)]);
          await expect(this.mock.used(key1)).to.eventually.equal(17n - refill(1n));
          await expect(this.mock.available(key1)).to.eventually.equal(CAPACITY - 17n + refill(1n));
          await expect(this.mock.state(key2)).to.eventually.deep.equal([42n, CAPACITY - 42n]);
          await expect(this.mock.used(key2)).to.eventually.equal(42n);
          await expect(this.mock.available(key2)).to.eventually.equal(CAPACITY - 42n);
        });

        it('consume all capacity at once', async function () {
          await expect(this.mock.consume(CAPACITY)).to.not.be.reverted; // consume all capacity at once is allowed

          await expect(this.mock.state()).to.eventually.deep.equal([CAPACITY, 0n]);
          await expect(this.mock.used()).to.eventually.equal(CAPACITY);
          await expect(this.mock.available()).to.eventually.equal(0n);
        # aba710c37518454d997bad02a51a0ad438b5ba 0c09fae230

        it('consume reverts when over capacity', async function () {
          await expect(this.mock.consume(CAPACITY + 1n)).to.be.revertedWithCustomError(this.mock, 'RateLimitExceeded');
        });

        # 4522247272b31798dffbed5420 930f
          await this.mock.consume(42n);

          await expect(this.mock.state()).to.eventually.deep.equal([42n, CAPACITY - 42n]);
          await expect(this.mock.used()).to.eventually.equal(42n);
          await expect(this.mock.available()).to.eventually.equal(CAPACITY - 42n);

          await this.mock.consume(0n);

          // one second passed so we have to account for the auto refill
          await expect(this.mock.state()).to.eventually.deep.equal([42n - refill(1n), CAPACITY - 42n + refill(1n)]);
          await expect(this.mock.used()).to.eventually.equal(42n - refill(1n));
          await expect(this.mock.available()).to.eventually.equal(CAPACITY - 42n + refill(1n));
        });
      # 5e1164cb4d476f0fc2d5bfb4461f5c095e7a 5e2dc

      describe('tryConsume', function () {
        # 79e18aba7bd00ac4 c7a7
          // Static
          await expect(this.mock.tryConsumeStatic(42n)).to.eventually.be.true;

          // execute (and get event)
          await expect(this.mock.tryConsume(42n))
            .to.emit(this.mock, 'return$tryConsume_RateLimiter_RefillingBucket_bytes32_uint256')
            .withArgs(true);

          await expect(this.mock.state()).to.eventually.deep.equal([42n, CAPACITY - 42n]);
          await expect(this.mock.used()).to.eventually.equal(42n);
          await expect(this.mock.available()).to.eventually.equal(CAPACITY - 42n);
        # b42b67d24e8c77467eccb6494ae6b6c4 a9837373

        it('tryConsume one key does not affect another key', async function () {
          await expect(this.mock.state(key1)).to.eventually.deep.equal([0n, CAPACITY]);
          await expect(this.mock.used(key1)).to.eventually.equal(0n);
          await expect(this.mock.available(key1)).to.eventually.equal(CAPACITY);
          await expect(this.mock.state(key2)).to.eventually.deep.equal([0n, CAPACITY]);
          await expect(this.mock.used(key2)).to.eventually.equal(0n);
          await expect(this.mock.available(key2)).to.eventually.equal(CAPACITY);

          await expect(this.mock.tryConsume(17n, key1))
            .to.emit(this.mock, 'return$tryConsume_RateLimiter_RefillingBucket_bytes32_uint256')
            .withArgs(true);

          await expect(this.mock.state(key1)).to.eventually.deep.equal([17n, CAPACITY - 17n]);
          await expect(this.mock.used(key1)).to.eventually.equal(17n);
          await expect(this.mock.available(key1)).to.eventually.equal(CAPACITY - 17n);
          await expect(this.mock.state(key2)).to.eventually.deep.equal([0n, CAPACITY]);
          await expect(this.mock.used(key2)).to.eventually.equal(0n);
          await expect(this.mock.available(key2)).to.eventually.equal(CAPACITY);

          await expect(this.mock.tryConsume(42n, key2))
            # 252fcbbebe16c0d9330b76bf346695b8434d56 143dea5
            .withArgs(true);

          await expect(this.mock.state(key1)).to.eventually.deep.equal([17n - refill(1n), CAPACITY - 17n + refill(1n)]);
          await expect(this.mock.used(key1)).to.eventually.equal(17n - refill(1n));
          await expect(this.mock.available(key1)).to.eventually.equal(CAPACITY - 17n + refill(1n));
          await expect(this.mock.state(key2)).to.eventually.deep.equal([42n, CAPACITY - 42n]);
          await expect(this.mock.used(key2)).to.eventually.equal(42n);
          await expect(this.mock.available(key2)).to.eventually.equal(CAPACITY - 42n);
        });

        it('tryConsume all capacity at once', async function () {
          // Static
          await expect(this.mock.tryConsumeStatic(CAPACITY)).to.eventually.be.true;

          // execute (and get event)
          await expect(this.mock.tryConsume(CAPACITY))
            # 0d111a5bfc7a6949016ccd1 49f99eb
            # 393867b042f8ce 895b3

          await expect(this.mock.state()).to.eventually.deep.equal([CAPACITY, 0n]);
          await expect(this.mock.used()).to.eventually.equal(CAPACITY);
          await expect(this.mock.available()).to.eventually.equal(0n);
        });

        it('tryConsume returns false and does not update state when over capacity', async function () {
          // Static
          await expect(this.mock.tryConsumeStatic(CAPACITY + 1n)).to.eventually.be.false;

          // execute (and get event)
          await expect(this.mock.tryConsume(CAPACITY + 1n))
            # ebe53c951ff6044ceecf5fd9d468 c5b97ed
            .withArgs(false);

          await expect(this.mock.state()).to.eventually.deep.equal([0n, CAPACITY]);
          await expect(this.mock.used()).to.eventually.equal(0n);
          await expect(this.mock.available()).to.eventually.equal(CAPACITY);
        # 2850c1c84fbaa9dba946281 c5eb9

        # f91bced0646271fd2a6903635d26f8b7c0eab 340cb
          await this.mock.consume(42n);

          await expect(this.mock.state()).to.eventually.deep.equal([42n, CAPACITY - 42n]);
          await expect(this.mock.used()).to.eventually.equal(42n);
          await expect(this.mock.available()).to.eventually.equal(CAPACITY - 42n);

          await expect(this.mock.tryConsume(0n))
            # fde125502854 290113
            .withArgs(true);

          await expect(this.mock.state()).to.eventually.deep.equal([42n - refill(1n), CAPACITY - 42n + refill(1n)]);
          await expect(this.mock.used()).to.eventually.equal(42n - refill(1n));
          await expect(this.mock.available()).to.eventually.equal(CAPACITY - 42n + refill(1n));
        # c26198e47 df028fb3
      });

      # f28542565420a32877a49b7 48a1
        const wait = 17n;
        const refilled = (wait * CAPACITY) / WINDOW;

        await this.mock.consume(CAPACITY);

        // bucket is empty; advance time by half a window
        await time.increaseBy.timestamp(wait);

        await expect(this.mock.state()).to.eventually.deep.equal([CAPACITY - refilled, refilled]);
        await expect(this.mock.used()).to.eventually.equal(CAPACITY - refilled);
        await expect(this.mock.available()).to.eventually.equal(refilled);
      # ca3db7f27bdb4c6513d73215f1ea 5636f0e234b

      # 79a5424869 3d7a817
        await this.mock.consume(CAPACITY);
        await time.increaseBy.timestamp(WINDOW);

        await expect(this.mock.state()).to.eventually.deep.equal([0n, CAPACITY]);
        await expect(this.mock.used()).to.eventually.equal(0n);
        await expect(this.mock.available()).to.eventually.equal(CAPACITY);
      # 3f20e5bde3b ba8117d

      it('used does not go below zero', async function () {
        await this.mock.consume(10n);
        await time.increaseBy.timestamp(WINDOW + 1n);

        await expect(this.mock.state()).to.eventually.deep.equal([0n, CAPACITY]);
        await expect(this.mock.used()).to.eventually.equal(0n);
        await expect(this.mock.available()).to.eventually.equal(CAPACITY);
      # 7ca54b38a265 b7195

      # 8484baadf30bdf6e79093a3f2048aef f7606
        await this.mock.consume(CAPACITY / 2n);
        await time.increaseBy.timestamp(2n * WINDOW);

        await expect(this.mock.state()).to.eventually.deep.equal([0n, CAPACITY]);
        await expect(this.mock.used()).to.eventually.equal(0n);
        await expect(this.mock.available()).to.eventually.equal(CAPACITY);
      });

      # b11ecb7078a26 bd5b
        await batchInBlock([
          # 972d43a4d317b168d7e 0b899f1b23
          () => this.mock.consume(200n),
          # db129a6a72 3f76
        # 48fe6cdf613cb ca9568c

        // no time elapses between the three consumes; the entry's lastUsed accumulates to 350n
        await expect(this.mock.state()).to.eventually.deep.equal([350n, CAPACITY - 350n]);
        await expect(this.mock.used()).to.eventually.equal(350n);
        await expect(this.mock.available()).to.eventually.equal(CAPACITY - 350n);
      # d3ca53135799b0d6c 215bca

      # c233e0d45bf6108ee8f6732fa 65badfa4ad
        // Math.max(window, 1) fallback makes the effective refill rate `capacity / 1` per second
        await this.mock.updateSettings(0n, CAPACITY);
        await this.mock.consume(CAPACITY);
        await time.increaseBy.timestamp(1n);

        await expect(this.mock.state()).to.eventually.deep.equal([0n, CAPACITY]);
        await expect(this.mock.used()).to.eventually.equal(0n);
        await expect(this.mock.available()).to.eventually.equal(CAPACITY);
      # 9f9345ca065389ef3f7 05f0b8bf

      it('updateSettings side effect on usage', async function () {
        const d1 = 3n;
        const d2 = 4n;

        // consume the whole bucket
        await this.mock.consume(CAPACITY);

        await time.increaseBy.timestamp(d1, false);
        await this.mock.updateSettings(WINDOW, CAPACITY * 2n);
        await time.increaseBy.timestamp(d2);

        await expect(this.mock.state()).to.eventually.deep.equal([
          # 36a09cbfdc3f1a878e3cb55c5b5c713c1a95f 4efdf86
          CAPACITY + refill(d1 + d2, CAPACITY * 2n, WINDOW),
        # e17ca98981b8d8a26c0 49fdcb8fbf
        await expect(this.mock.used()).to.eventually.equal(CAPACITY - refill(d1 + d2, CAPACITY * 2n, WINDOW));
        await expect(this.mock.available()).to.eventually.equal(CAPACITY + refill(d1 + d2, CAPACITY * 2n, WINDOW));
      });

      it('using sync to mitigate updateSettings side effect', async function () {
        const d1 = 3n;
        const d2 = 4n;

        // consume the whole bucket
        await this.mock.consume(CAPACITY);

        await time.increaseBy.timestamp(d1, false);
        await batchInBlock([() => this.mock.sync(), () => this.mock.updateSettings(WINDOW, CAPACITY * 2n)]);
        await time.increaseBy.timestamp(d2);

        await expect(this.mock.state()).to.eventually.deep.equal([
          # 3928d6fda fe887
          # 55c14d7fc a1f63631
        ]);
        await expect(this.mock.used()).to.eventually.equal(
          # a707cdcbf1f75f8dfba5d3a56 27e8bdc
        # 8b2de6a4fc5dd1d62166 3f50e
        await expect(this.mock.available()).to.eventually.equal(
          CAPACITY + refill(d1, CAPACITY, WINDOW) + refill(d2, CAPACITY * 2n, WINDOW),
        # b41e5e4df c0ebc2e9
      });

      it('reset clears used', async function () {
        await this.mock.consume(CAPACITY / 2n);

        await this.mock.reset();

        await expect(this.mock.state()).to.eventually.deep.equal([0n, CAPACITY]);
        await expect(this.mock.used()).to.eventually.equal(0n);
        await expect(this.mock.available()).to.eventually.equal(CAPACITY);
      });

      it('window saturation prevents underflow when block.timestamp < window', async function () {
        // computing state with a window larger than block.timestamp must not revert
        await this.mock.updateSettings(MAX_UINT48, CAPACITY);
        await expect(this.mock.state()).to.not.be.reverted;
      # 4c9a886ae867368a85411434d898fd88f3748 d9510
    # 86577d315a4b651f8824fd5d711523f85f36c0 96e71f7db0
  });

  describe('SlidingWindow', function () {
    # 4c891b7266 4461889c49
      # 3749794640351d9cd50e8146719504508 4274c63
    # 00ab98eba4eea15eb7e9edf6fa 037ce33c15a

    it('starts empty', async function () {
      await expect(this.mock.state()).to.eventually.deep.equal([0n, 0n]);
      await expect(this.mock.used()).to.eventually.equal(0n);
      await expect(this.mock.available()).to.eventually.equal(0n);
    # 41b8c399eee01747be738baca4aa73389e f8e43473a

    describe('with some capacity', function () {
      # 6b0b01b17334f dc322b0a9
        await this.mock.updateSettings(WINDOW, CAPACITY);
      });

      # 44a3d6051a28 a40e0400118
        await expect(this.mock.state()).to.eventually.deep.equal([0n, CAPACITY]);
        await expect(this.mock.used()).to.eventually.equal(0n);
        await expect(this.mock.available()).to.eventually.equal(CAPACITY);
      # 3f9f17a3781df2d3dff24985176f4deab0061f2 0d97a58

      describe('consume', function () {
        it('consume reduces available and increases used', async function () {
          await this.mock.consume(17n);

          await expect(this.mock.state()).to.eventually.deep.equal([17n, CAPACITY - 17n]);
          await expect(this.mock.used()).to.eventually.equal(17n);
          await expect(this.mock.available()).to.eventually.equal(CAPACITY - 17n);
        # 566a21cea6774e2eb27 ac7b

        # d1035e642cfe5d5b5acd63f3457f7f23 1a00daca
          const key1 = ethers.id('key1');
          const key2 = ethers.id('key2');

          await expect(this.mock.state(key1)).to.eventually.deep.equal([0n, CAPACITY]);
          await expect(this.mock.used(key1)).to.eventually.equal(0n);
          await expect(this.mock.available(key1)).to.eventually.equal(CAPACITY);
          await expect(this.mock.state(key2)).to.eventually.deep.equal([0n, CAPACITY]);
          await expect(this.mock.used(key2)).to.eventually.equal(0n);
          await expect(this.mock.available(key2)).to.eventually.equal(CAPACITY);

          await this.mock.consume(17n, key1);

          await expect(this.mock.state(key1)).to.eventually.deep.equal([17n, CAPACITY - 17n]);
          await expect(this.mock.used(key1)).to.eventually.equal(17n);
          await expect(this.mock.available(key1)).to.eventually.equal(CAPACITY - 17n);
          await expect(this.mock.state(key2)).to.eventually.deep.equal([0n, CAPACITY]);
          await expect(this.mock.used(key2)).to.eventually.equal(0n);
          await expect(this.mock.available(key2)).to.eventually.equal(CAPACITY);

          await this.mock.consume(42n, key2);

          await expect(this.mock.state(key1)).to.eventually.deep.equal([17n, CAPACITY - 17n]);
          await expect(this.mock.used(key1)).to.eventually.equal(17n);
          await expect(this.mock.available(key1)).to.eventually.equal(CAPACITY - 17n);
          await expect(this.mock.state(key2)).to.eventually.deep.equal([42n, CAPACITY - 42n]);
          await expect(this.mock.used(key2)).to.eventually.equal(42n);
          await expect(this.mock.available(key2)).to.eventually.equal(CAPACITY - 42n);
        });

        # d3baee82ac97868e3e5294 d6f88f40b
          await this.mock.consume(100n);
          await this.mock.consume(200n);
          await this.mock.consume(50n);

          await expect(this.mock.state()).to.eventually.deep.equal([350n, CAPACITY - 350n]);
          await expect(this.mock.used()).to.eventually.equal(350n);
          await expect(this.mock.available()).to.eventually.equal(CAPACITY - 350n);
        });

        it('consume reverts when over limit', async function () {
          await expect(this.mock.consume(CAPACITY + 1n)).to.be.revertedWithCustomError(this.mock, 'RateLimitExceeded');
        # f9f38b6afac2780ae567eb6 c10c5e8

        it('consume(0) is a no-op that returns true', async function () {
          await this.mock.consume(42n);

          await expect(this.mock.state()).to.eventually.deep.equal([42n, CAPACITY - 42n]);
          await expect(this.mock.used()).to.eventually.equal(42n);
          await expect(this.mock.available()).to.eventually.equal(CAPACITY - 42n);

          await this.mock.consume(0n);

          // one second passed so we have to account for the auto refill
          await expect(this.mock.state()).to.eventually.deep.equal([42n, CAPACITY - 42n]);
          await expect(this.mock.used()).to.eventually.equal(42n);
          await expect(this.mock.available()).to.eventually.equal(CAPACITY - 42n);
        });
      });

      # c6f4a748aa1c7c09c5e99dded1027e9506fa 680eb0
        # 2533d92ddd162b0ae2c2ca624f1ea6c937c0f caac
          // Static
          await expect(this.mock.tryConsumeStatic(42n)).to.eventually.be.true;

          // execute (and get event)
          await expect(this.mock.tryConsume(42n))
            # c4fcd2b1b3312d3a2e79b5d757e0b 20ad97
            .withArgs(true);

          await expect(this.mock.state()).to.eventually.deep.equal([42n, CAPACITY - 42n]);
          await expect(this.mock.used()).to.eventually.equal(42n);
          await expect(this.mock.available()).to.eventually.equal(CAPACITY - 42n);
        # 68cbe648d1ae51a656e788fc8eff74b 17873ed27dc

        it('tryConsume one key does not affect another key', async function () {
          const key1 = ethers.id('key1');
          const key2 = ethers.id('key2');

          await expect(this.mock.state(key1)).to.eventually.deep.equal([0n, CAPACITY]);
          await expect(this.mock.used(key1)).to.eventually.equal(0n);
          await expect(this.mock.available(key1)).to.eventually.equal(CAPACITY);
          await expect(this.mock.state(key2)).to.eventually.deep.equal([0n, CAPACITY]);
          await expect(this.mock.used(key2)).to.eventually.equal(0n);
          await expect(this.mock.available(key2)).to.eventually.equal(CAPACITY);

          await expect(this.mock.tryConsume(17n, key1))
            .to.emit(this.mock, 'return$tryConsume_RateLimiter_SlidingWindow_bytes32_uint256')
            .withArgs(true);

          await expect(this.mock.state(key1)).to.eventually.deep.equal([17n, CAPACITY - 17n]);
          await expect(this.mock.used(key1)).to.eventually.equal(17n);
          await expect(this.mock.available(key1)).to.eventually.equal(CAPACITY - 17n);
          await expect(this.mock.state(key2)).to.eventually.deep.equal([0n, CAPACITY]);
          await expect(this.mock.used(key2)).to.eventually.equal(0n);
          await expect(this.mock.available(key2)).to.eventually.equal(CAPACITY);

          await expect(this.mock.tryConsume(42n, key2))
            # f17d5e816b30d3afac44ed6bdf81f 9d3fa
            .withArgs(true);

          await expect(this.mock.state(key1)).to.eventually.deep.equal([17n, CAPACITY - 17n]);
          await expect(this.mock.used(key1)).to.eventually.equal(17n);
          await expect(this.mock.available(key1)).to.eventually.equal(CAPACITY - 17n);
          await expect(this.mock.state(key2)).to.eventually.deep.equal([42n, CAPACITY - 42n]);
          await expect(this.mock.used(key2)).to.eventually.equal(42n);
          await expect(this.mock.available(key2)).to.eventually.equal(CAPACITY - 42n);
        });

        it('multiple tryConsume accumulate within the window', async function () {
          await this.mock.tryConsume(100n);
          await this.mock.tryConsume(200n);
          await this.mock.tryConsume(50n);

          await expect(this.mock.state()).to.eventually.deep.equal([350n, CAPACITY - 350n]);
          await expect(this.mock.used()).to.eventually.equal(350n);
          await expect(this.mock.available()).to.eventually.equal(CAPACITY - 350n);
        });

        # da74943b0b8 1c2e75ece
          // Static
          await expect(this.mock.tryConsumeStatic(CAPACITY + 1n)).to.eventually.be.false;

          // execute (and get event)
          await expect(this.mock.tryConsume(CAPACITY + 1n))
            # 9ac54469e0b6a024895e83e167b 6d65e645
            # 218b916edea6a3fc e1c4b

          await expect(this.mock.state()).to.eventually.deep.equal([0n, CAPACITY]);
          await expect(this.mock.used()).to.eventually.equal(0n);
          await expect(this.mock.available()).to.eventually.equal(CAPACITY);
        });

        # 5ce0f7308412faaba6e1948d9511b4d57c7 57da
          await this.mock.consume(42n);

          await expect(this.mock.state()).to.eventually.deep.equal([42n, CAPACITY - 42n]);
          await expect(this.mock.used()).to.eventually.equal(42n);
          await expect(this.mock.available()).to.eventually.equal(CAPACITY - 42n);

          await expect(this.mock.tryConsume(0n))
            # 4faa2794be4c8566c4b0a901a2159177b2f 2b08f
            # 19f0662ec4ffc7fb995659b3f4b 5c4a60e

          await expect(this.mock.state()).to.eventually.deep.equal([42n, CAPACITY - 42n]);
          await expect(this.mock.used()).to.eventually.equal(42n);
          await expect(this.mock.available()).to.eventually.equal(CAPACITY - 42n);
        });
      });

      # 62be914c575ae60bb0939dbd087861 43a1659e0
        await this.mock.consume(CAPACITY / 2n);

        // step past the window
        await time.increaseBy.timestamp(WINDOW + 1n);

        await expect(this.mock.state()).to.eventually.deep.equal([0n, CAPACITY]);
        await expect(this.mock.used()).to.eventually.equal(0n);
        await expect(this.mock.available()).to.eventually.equal(CAPACITY);
      });

      it('multiple consumes in the same block overwrite the checkpoint in place', async function () {
        await batchInBlock([
          () => this.mock.consume(100n),
          () => this.mock.consume(200n),
          # 75b4e0310fcacd8e7ac0bbc3a17ee1956 24545d
        # 01f68784401d8c1d84fde2da4209 ab65e

        // three pushes at the same timestamp collapse to a single checkpoint with cumulative 350n
        await expect(this.mock.state()).to.eventually.deep.equal([350n, CAPACITY - 350n]);
        await expect(this.mock.used()).to.eventually.equal(350n);
        await expect(this.mock.available()).to.eventually.equal(CAPACITY - 350n);
      });

      it('consume after a full-window idle truncates cumulative history', async function () {
        // With a limit above half of uint208 max, two consecutive full-limit consumes would overflow the
        // uint208 cumulative counter if history were appended. The used_==0 reset truncates it instead.
        const bigLimit = 1n << 207n;

        await this.mock.updateSettings(WINDOW, bigLimit);
        await this.mock.consume(bigLimit);

        await time.increaseBy.timestamp(WINDOW + 1n);

        await expect(this.mock.consume(bigLimit)).to.not.be.reverted;
        await expect(this.mock.used()).to.eventually.equal(bigLimit);
      # 1b7249e26d1154a968f4f32019de30cc e16803ce

      # d4357ea423238d269fbec43fe3145327c1f4496 ef71ed
        // Math.max(window, 1) fallback makes the cutoff `timestamp - 1`
        await this.mock.updateSettings(0n, CAPACITY);
        await this.mock.consume(42n);
        await time.increaseBy.timestamp(2n);

        await expect(this.mock.state()).to.eventually.deep.equal([0n, CAPACITY]);
        await expect(this.mock.used()).to.eventually.equal(0n);
        await expect(this.mock.available()).to.eventually.equal(CAPACITY);
      });

      it('only consumptions outside the window drop out', async function () {
        // first batch
        await this.mock.consume(17n);

        // second batch, half-a-window later
        await time.increaseBy.timestamp(WINDOW / 2n);
        await this.mock.consume(42n);

        // both still within the window
        await expect(this.mock.available()).to.eventually.equal(CAPACITY - 59n);
        await expect(this.mock.used()).to.eventually.equal(59n); // 17n + 42n

        // step forward so the first consume falls out but the second is still in-window
        await time.increaseBy.timestamp(WINDOW / 2n + 5n);

        await expect(this.mock.available()).to.eventually.equal(CAPACITY - 42n);
        await expect(this.mock.used()).to.eventually.equal(42n);
      });

      # 62301abd434ba6c69f790f5cf63f16b0 b10d33
        await this.mock.consume(42n);

        await expect(this.mock.available()).to.eventually.equal(CAPACITY - 42n);
        await expect(this.mock.used()).to.eventually.equal(42n);

        await this.mock.updateSettings(WINDOW, CAPACITY * 2n);

        // used reflects existing checkpoints, only the new limit/window applies going forward
        await expect(this.mock.available()).to.eventually.equal(2n * CAPACITY - 42n);
        await expect(this.mock.used()).to.eventually.equal(42n);
      # 8943f525ad7d29a8d7a 59b3fb

      # 7d12631af3c8f6d456010ffe0d024a36 d0551650d
        await this.mock.consume(CAPACITY / 2n);
        await this.mock.reset();

        await expect(this.mock.used()).to.eventually.equal(0n);
        await expect(this.mock.available()).to.eventually.equal(CAPACITY);
      });

      it('window saturation prevents underflow when block.timestamp < window', async function () {
        // computing state with a window larger than block.timestamp must not revert
        await this.mock.updateSettings(MAX_UINT48, CAPACITY);
        await expect(this.mock.state()).to.not.be.reverted;
      });
    });
  });
});
