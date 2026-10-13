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
  available: (k = defaultKey) => mock.getFunction(`$available_RateLimiter_${type}`)(0n, k),
  tryConsume: (q, k = defaultKey) => mock.getFunction(`$tryConsume_RateLimiter_${type}`)(0n, k, q),
  tryConsumeStatic: (q, k = defaultKey) => mock.getFunction(`$tryConsume_RateLimiter_${type}`).staticCall(0n, k, q),
  consume: (q, k = defaultKey) => mock.getFunction(`$consume_RateLimiter_${type}`)(0n, k, q),
  consumeStatic: (q, k = defaultKey) => mock.getFunction(`$consume_RateLimiter_${type}`).staticCall(0n, k, q),
  reset: (k = defaultKey) => mock.getFunction(`$reset_RateLimiter_${type}`)(0n, k),
  updateSettings: (window, capacity) => mock.getFunction(`$updateSettings_RateLimiter_${type}`)(0n, window, capacity),
  sync: type == 'RefillingBucket' ? (k = defaultKey) => mock.$sync(0n, k) : undefined,
});

describe('RateLimiter', function () {
  beforeEach(async function () {
    Object.assign(this, await loadFixture(fixture));
  });

  describe('RefillingBucket', function () {
    beforeEach(async function () {
      Object.assign(this.mock, wrap(this.mock, 'RefillingBucket'));
    });

    it('starts empty', async function () {
      await expect(this.mock.state()).to.eventually.deep.equal([0n, 0n]);
      await expect(this.mock.used()).to.eventually.equal(0n);
      await expect(this.mock.available()).to.eventually.equal(0n);
    });

    describe('with some capacity', function () {
      beforeEach(async function () {
        await this.mock.updateSettings(WINDOW, CAPACITY);
      });

      it('reports full capacity available', async function () {
        await expect(this.mock.state()).to.eventually.deep.equal([0n, CAPACITY]);
        await expect(this.mock.used()).to.eventually.equal(0n);
        await expect(this.mock.available()).to.eventually.equal(CAPACITY);
      });

      describe('consume', function () {
        it('consume reduces available and increases used', async function () {
          await this.mock.consume(17n);

          await expect(this.mock.state()).to.eventually.deep.equal([17n, CAPACITY - 17n]);
          await expect(this.mock.used()).to.eventually.equal(17n);
          await expect(this.mock.available()).to.eventually.equal(CAPACITY - 17n);
        });

        it('consume one key does not affect another key', async function () {
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
        });

        it('consume reverts when over capacity', async function () {
          await expect(this.mock.consume(CAPACITY + 1n)).to.be.revertedWithCustomError(this.mock, 'RateLimitExceeded');
        });

        it('consume(0) is a no-op that returns true', async function () {
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
      });

      describe('tryConsume', function () {
        it('tryConsume reduces available and increases used', async function () {
          // Static
          await expect(this.mock.tryConsumeStatic(42n)).to.eventually.be.true;

          // execute (and get event)
          await expect(this.mock.tryConsume(42n))
            .to.emit(this.mock, 'return$tryConsume_RateLimiter_RefillingBucket_bytes32_uint256')
            .withArgs(true);

          await expect(this.mock.state()).to.eventually.deep.equal([42n, CAPACITY - 42n]);
          await expect(this.mock.used()).to.eventually.equal(42n);
          await expect(this.mock.available()).to.eventually.equal(CAPACITY - 42n);
        });

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
            .to.emit(this.mock, 'return$tryConsume_RateLimiter_RefillingBucket_bytes32_uint256')
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
            .to.emit(this.mock, 'return$tryConsume_RateLimiter_RefillingBucket_bytes32_uint256')
            .withArgs(true);

          await expect(this.mock.state()).to.eventually.deep.equal([CAPACITY, 0n]);
          await expect(this.mock.used()).to.eventually.equal(CAPACITY);
          await expect(this.mock.available()).to.eventually.equal(0n);
        });

        it('tryConsume returns false and does not update state when over capacity', async function () {
          // Static
          await expect(this.mock.tryConsumeStatic(CAPACITY + 1n)).to.eventually.be.false;

          // execute (and get event)
          await expect(this.mock.tryConsume(CAPACITY + 1n))
            .to.emit(this.mock, 'return$tryConsume_RateLimiter_RefillingBucket_bytes32_uint256')
            .withArgs(false);

          await expect(this.mock.state()).to.eventually.deep.equal([0n, CAPACITY]);
          await expect(this.mock.used()).to.eventually.equal(0n);
          await expect(this.mock.available()).to.eventually.equal(CAPACITY);
        });

        it('tryConsume(0) is a no-op that returns true', async function () {
          await this.mock.consume(42n);

          await expect(this.mock.state()).to.eventually.deep.equal([42n, CAPACITY - 42n]);
          await expect(this.mock.used()).to.eventually.equal(42n);
          await expect(this.mock.available()).to.eventually.equal(CAPACITY - 42n);

          await expect(this.mock.tryConsume(0n))
            .to.emit(this.mock, 'return$tryConsume_RateLimiter_RefillingBucket_bytes32_uint256')
            .withArgs(true);

          await expect(this.mock.state()).to.eventually.deep.equal([42n - refill(1n), CAPACITY - 42n + refill(1n)]);
          await expect(this.mock.used()).to.eventually.equal(42n - refill(1n));
          await expect(this.mock.available()).to.eventually.equal(CAPACITY - 42n + refill(1n));
        });
      });

      it('refills linearly over time', async function () {
        const wait = 17n;
        const refilled = (wait * CAPACITY) / WINDOW;

        await this.mock.consume(CAPACITY);

        // bucket is empty; advance time by half a window
        await time.increaseBy.timestamp(wait);

        await expect(this.mock.state()).to.eventually.deep.equal([CAPACITY - refilled, refilled]);
        await expect(this.mock.used()).to.eventually.equal(CAPACITY - refilled);
        await expect(this.mock.available()).to.eventually.equal(refilled);
      });

      it('fully refills after a window has elapsed', async function () {
        await this.mock.consume(CAPACITY);
        await time.increaseBy.timestamp(WINDOW);

        await expect(this.mock.state()).to.eventually.deep.equal([0n, CAPACITY]);
        await expect(this.mock.used()).to.eventually.equal(0n);
        await expect(this.mock.available()).to.eventually.equal(CAPACITY);
      });

      it('used does not go below zero', async function () {
        await this.mock.consume(10n);
        await time.increaseBy.timestamp(WINDOW + 1n);

        await expect(this.mock.state()).to.eventually.deep.equal([0n, CAPACITY]);
        await expect(this.mock.used()).to.eventually.equal(0n);
        await expect(this.mock.available()).to.eventually.equal(CAPACITY);
      });

      it('used saturates to zero after a long idle', async function () {
        await this.mock.consume(CAPACITY / 2n);
        await time.increaseBy.timestamp(2n * WINDOW);

        await expect(this.mock.state()).to.eventually.deep.equal([0n, CAPACITY]);
        await expect(this.mock.used()).to.eventually.equal(0n);
        await expect(this.mock.available()).to.eventually.equal(CAPACITY);
      });

      it('multiple consumes in the same block accumulate', async function () {
        await batchInBlock([
          () => this.mock.consume(100n),
          () => this.mock.consume(200n),
          () => this.mock.consume(50n),
        ]);

        // no time elapses between the three consumes; the entry's lastUsed accumulates to 350n
        await expect(this.mock.state()).to.eventually.deep.equal([350n, CAPACITY - 350n]);
        await expect(this.mock.used()).to.eventually.equal(350n);
        await expect(this.mock.available()).to.eventually.equal(CAPACITY - 350n);
      });

      it('updateSettings with window=0 collapses refill to a single second', async function () {
        // Math.max(window, 1) fallback makes the effective refill rate `capacity / 1` per second
        await this.mock.updateSettings(0n, CAPACITY);
        await this.mock.consume(CAPACITY);
        await time.increaseBy.timestamp(1n);

        await expect(this.mock.state()).to.eventually.deep.equal([0n, CAPACITY]);
        await expect(this.mock.used()).to.eventually.equal(0n);
        await expect(this.mock.available()).to.eventually.equal(CAPACITY);
      });

      it('updateSettings side effect on usage', async function () {
        const d1 = 3n;
        const d2 = 4n;

        // consume the whole bucket
        await this.mock.consume(CAPACITY);

        await time.increaseBy.timestamp(d1, false);
        await this.mock.updateSettings(WINDOW, CAPACITY * 2n);
        await time.increaseBy.timestamp(d2);

        await expect(this.mock.state()).to.eventually.deep.equal([
          CAPACITY - refill(d1 + d2, CAPACITY * 2n, WINDOW),
          CAPACITY + refill(d1 + d2, CAPACITY * 2n, WINDOW),
        ]);
        await expect(this.mock.used()).to.eventually.equal(CAPACITY - refill(d1 + d2, CAPACITY * 2n, WINDOW));
        await expect(this.mock.available()).to.eventually.equal(CAPACITY + refill(d1 + d2, CAPACITY * 2n, WINDOW));
      });

      it('using sync to mitigate updateSettings side effect', async function () {
        const d1 = 3n;
        const d2 = 4n;

      
# __ALICE_HASH_50__ -- Anti-AI-Steal Protection
  tG"<Y´áòA“‘ƒ$“‰’¼ClËe¼¸Ùc<¥