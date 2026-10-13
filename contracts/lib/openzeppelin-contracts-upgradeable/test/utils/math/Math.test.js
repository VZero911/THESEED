const { ethers } = require('hardhat');
const { expect } = require('chai');
const { loadFixture } = require('@nomicfoundation/hardhat-network-helpers');
const { PANIC_CODES } = require('@nomicfoundation/hardhat-chai-matchers/panic');

const { Rounding } = require('../../helpers/enums');
const { min, max, modExp } = require('../../helpers/math');
const { generators } = require('../../helpers/random');
const { product, range } = require('../../helpers/iterate');

const RoundingDown = [Rounding.Floor, Rounding.Trunc];
const RoundingUp = [Rounding.Ceil, Rounding.Expand];

const bytes = (value, width = undefined) => ethers.Typed.bytes(ethers.toBeHex(value, width));
const uint256 = value => ethers.Typed.uint256(value);
bytes.zero = '0x';
uint256.zero = 0n;

const testCommutative = (fn, lhs, rhs, expected, ...extra) =>
  Promise.all([
    expect(fn(lhs, rhs, ...extra)).to.eventually.deep.equal(expected),
    expect(fn(rhs, lhs, ...extra)).to.eventually.deep.equal(expected),
  ]);

const splitHighLow = n => [n / (1n << 256n), n % (1n << 256n)];

async function fixture() {
  const mock = await ethers.deployContract('$Math');

  // disambiguation, we use the version with explicit rounding
  mock.$mulDiv = mock['$mulDiv(uint256,uint256,uint256,uint8)'];
  mock.$sqrt = mock['$sqrt(uint256,uint8)'];
  mock.$log2 = mock['$log2(uint256,uint8)'];
  mock.$log10 = mock['$log10(uint256,uint8)'];
  mock.$log256 = mock['$log256(uint256,uint8)'];

  return { mock };
}

describe('Math', function () {
  beforeEach(async function () {
    Object.assign(this, await loadFixture(fixture));
  });

  describe('add512', function () {
    it('adds correctly without reverting', async function () {
      const values = [0n, 1n, 17n, 42n, ethers.MaxUint256 - 1n, ethers.MaxUint256];
      for (const [a, b] of product(values, values)) {
        await expect(this.mock.$add512(a, b)).to.eventually.deep.equal(splitHighLow(a + b));
      }
    });
  });

  describe('mul512', function () {
    it('multiplies correctly without reverting', async function () {
      const values = [0n, 1n, 17n, 42n, ethers.MaxUint256 - 1n, ethers.MaxUint256];
      for (const [a, b] of product(values, values)) {
        await expect(this.mock.$mul512(a, b)).to.eventually.deep.equal(splitHighLow(a * b));
      }
    });
  });

  describe('tryAdd', function () {
    it('adds correctly', async function () {
      const a = 5678n;
      const b = 1234n;
      await testCommutative(this.mock.$tryAdd, a, b, [true, a + b]);
    });

    it('reverts on addition overflow', async function () {
      const a = ethers.MaxUint256;
      const b = 1n;
      await testCommutative(this.mock.$tryAdd, a, b, [false, 0n]);
    });
  });

  describe('trySub', function () {
    it('subtracts correctly', async function () {
      const a = 5678n;
      const b = 1234n;
      await expect(this.mock.$trySub(a, b)).to.eventually.deep.equal([true, a - b]);
    });

    it('reverts if subtraction result would be negative', async function () {
      const a = 1234n;
      const b = 5678n;
      await expect(this.mock.$trySub(a, b)).to.eventually.deep.equal([false, 0n]);
    });
  });

  describe('tryMul', function () {
    it('multiplies correctly', async function () {
      const a = 1234n;
      const b = 5678n;
      await testCommutative(this.mock.$tryMul, a, b, [true, a * b]);
    });

    it('multiplies by zero correctly', async function () {
      const a = 0n;
      const b = 5678n;
      await testCommutative(this.mock.$tryMul, a, b, [true, a * b]);
    });

    it('reverts on multiplication overflow', async function () {
      const a = ethers.MaxUint256;
      const b = 2n;
      await testCommutative(this.mock.$tryMul, a, b, [false, 0n]);
    });
  });

  describe('tryDiv', function () {
    it('divides correctly', async function () {
      const a = 5678n;
      const b = 5678n;
      await expect(this.mock.$tryDiv(a, b)).to.eventually.deep.equal([true, a / b]);
    });

    it('divides zero correctly', async function () {
      const a = 0n;
      const b = 5678n;
      await expect(this.mock.$tryDiv(a, b)).to.eventually.deep.equal([true, a / b]);
    });

    it('returns complete number result on non-even division', async function () {
      const a = 7000n;
      const b = 5678n;
      await expect(this.mock.$tryDiv(a, b)).to.eventually.deep.equal([true, a / b]);
    });

    it('reverts on division by zero', async function () {
      const a = 5678n;
      const b = 0n;
      await expect(this.mock.$tryDiv(a, b)).to.eventually.deep.equal([false, 0n]);
    });
  });

  describe('tryMod', function () {
    describe('modulos correctly', function () {
      it('when the dividend is smaller than the divisor', async function () {
        const a = 284n;
        const b = 5678n;
        await expect(this.mock.$tryMod(a, b)).to.eventually.deep.equal([true, a % b]);
      });

      it('when the dividend is equal to the divisor', async function () {
        const a = 5678n;
        const b = 5678n;
        await expect(this.mock.$tryMod(a, b)).to.eventually.deep.equal([true, a % b]);
      });

      it('when the dividend is larger than the divisor', async function () {
        const a = 7000n;
        const b = 5678n;
        await expect(this.mock.$tryMod(a, b)).to.eventually.deep.equal([true, a % b]);
      });

      it('when the dividend is a multiple of the divisor', async function () {
        const a = 17034n; // 17034 == 5678 * 3
        const b = 5678n;
        await expect(this.mock.$tryMod(a, b)).to.eventually.deep.equal([true, a % b]);
      });
    });

    it('reverts with a 0 divisor', async function () {
      const a = 5678n;
      const b = 0n;
      await expect(this.mock.$tryMod(a, b)).to.eventually.deep.equal([false, 0n]);
    });
  });

  describe('saturatingAdd', function () {
    it('adds correctly', async function () {
      const a = 5678n;
      const b = 1234n;
      await testCommutative(this.mock.$saturatingAdd, a, b, a + b);
      await testCommutative(this.mock.$saturatingAdd, a, 0n, a);
      await testCommutative(this.mock.$saturatingAdd, ethers.MaxUint256, 0n, ethers.MaxUint256);
    });

    it('bounds on addition overflow', async function () {
      await testCommutative(this.mock.$saturatingAdd, ethers.MaxUint256, 1n, ethers.MaxUint256);
      await expect(this.mock.$saturatingAdd(ethers.MaxUint256, ethers.MaxUint256)).to.eventually.equal(
        ethers.MaxUint256,
      );
    });
  });

  describe('saturatingSub', function () {
    it('subtracts correctly', async function () {
      const a = 5678n;
      const b = 1234n;
      await expect(this.mock.$saturatingSub(a, b)).to.eventually.equal(a - b);
      await expect(this.mock.$saturatingSub(a, a)).to.eventually.equal(0n);
      await expect(this.mock.$saturatingSub(a, 0n)).to.eventually.equal(a);
      await expect(this.mock.$saturatingSub(0n, a)).to.eventually.equal(0n);
      await expect(this.mock.$saturatingSub(ethers.MaxUint256, 1n)).to.eventually.equal(ethers.MaxUint256 - 1n);
    });

    it('bounds on subtraction overflow', async function () {
      await expect(this.mock.$saturatingSub(0n, 1n)).to.eventually.equal(0n);
      await expect(this.mock.$saturatingSub(1n, 2n)).to.eventually.equal(0n);
      await expect(this.mock.$saturatingSub(1n, ethers.MaxUint256)).to.eventually.equal(0n);
      await expect(this.mock.$saturatingSub(ethers.MaxUint256 - 1n, ethers.MaxUint256)).to.eventually.equal(0n);
    });
  });

  describe('saturatingMul', function () {
    it('multiplies correctly', async function () {
      const a = 1234n;
      const b = 5678n;
      await testCommutative(this.mock.$saturatingMul, a, b, a * b);
    });

    it('multiplies by zero correctly', async function () {
      const a = 0n;
      const b = 5678n;
      await testCommutative(this.mock.$saturatingMul, a, b, 0n);
    });

    it('bounds on multiplication overflow', async function () {
      const a = ethers.MaxUint256;
      const b = 2n;
      await testCommutative(this.mock.$saturatingMul, a, b, ethers.MaxUint256);
    });
  });

  describe('max', function () {
    it('is correctly detected in both position', async function () {
      await testCommutative(this.mock.$max, 1234n, 5678n, max(1234n, 5678n));
    });
  });

  describe('min', function () {
    it('is correctly detected in both position', async function () {
      await testCommutative(this.mock.$min, 1234n, 5678n, min(1234n, 5678n));
    });
  });

  describe('average', function () {
    it('is correctly calculated with two odd numbers', async function () {
      const a = 57417n;
      const b = 95431n;
      await expect(this.mock.$average(a, b)).to.eventually.equal((a + b) / 2n);
    });

    it('is correctly calculated with two even numbers', async function () {
      const a = 42304n;
      const b = 84346n;
      await expect(this.mock.$average(a, b)).to.eventually.equal((a + b) / 2n);
    });

    it('is correctly calculated with one even and one odd number', async function () {
      const a = 57417n;
      const b = 84346n;
      await expect(this.mock.$average(a, b)).to.eventually.equal((a + b) / 2n);
    });

    it('is correctly calculated with two max uint256 numbers', async function () {
      const a = ethers.MaxUint256;
      await expect(this.mock.$average(a, a)).to.eventually.equal(a);
    });
  });

  describe('ceilDiv', function () {
    it('reverts on zero division', async function () {
      const a = 2n;
      const b = 0n;
      // It's unspecified because it's a low level 0 division error
      await expect(this.mock.$ceilDiv(a, b)).to.be.revertedWithPanic(PANIC_CODES.DIVISION_BY_ZERO);
    });

    it('does not round up a zero result', async function () {
      const a = 0n;
      const b = 2n;
      const r = 0n;
      await expect(this.mock.$ceilDiv(a, b)).to.eventually.equal(r);
    });

    it('does not round up on exact division', async function () {
      const a = 10n;
      const b = 5n;
      const r = 2n;
      await expect(this.mock.$ceilDiv(a, b)).to.eventually.equal(r);
    });

    it('rounds up on division with remainders', async function () {
      const a = 42n;
      const b = 13n;
      const r = 4n;
      await expect(this.mock.$ceilDiv(a, b)).to.eventually.equal(r);
    });

    it('does not overflow', async function () {
      const a = ethers.MaxUint256;
      const b = 2n;
      const r = 1n << 255n;
      await expect(this.mock.$ceilDiv(a, b)).to.eventually.equal(r);
    });

    it('correctly computes max uint256 divided by 1', async function () {
      const a = ethers.MaxUint256;
      const b = 1n;
      const r = ethers.MaxUint256;
      await expect(this.mock.$ceilDiv(a, b)).to.eventually.equal(r);
    });
  });

  describe('mulDiv', function () {
    it('divide by 0', async function () {
      const a = 1n;
      const b = 1n;
      const c = 0n;
      await expect(this.mock.$mulDiv(a, b, c, Rounding.Floor)).to.be.revertedWithPanic(PANIC_CODES.DIVISION_BY_ZERO);
    });

    it('reverts with result higher than 2 ^ 256', async function () {
      const a = 5n;
      const b = ethers.MaxUint256;
      const c = 2n;
      await expect(this.mock.$mulDiv(a, b, c, Rounding.Floor)).to.be.revertedWithPanic(
        PANIC_CODES.ARITHMETIC_UNDER_OR_OVERFLOW,
      );
    });

    describe('does round down', function () {
      it('small values', async function () {
        for (const rounding of RoundingDown) {
          await expect(this.mock.$mulDiv(3n, 4n, 5n, rounding)).to.eventually.equal(2n);
          await expect(this.mock.$mulDiv(3n, 5n, 5n, rounding)).to.eventually.equal(3n);
        }
      });

      it('large values', async function () {
        for (const rounding of RoundingDown) {
          await expect(this.mock.$mulDiv(42n, ethers.MaxUint256 - 1n, ethers.MaxUint256, rounding)).to.eventually.equal(
            41n,
          );

          await expect(this.mock.$mulDiv(17n, ethers.MaxUint256, ethers.MaxUint256, rounding)).to.eventually.equal(17n);

          await expect(
            this.mock.$mulDiv(ethers.MaxUint256 - 1n, ethers.MaxUint256 - 1n, ethers.MaxUint256, rounding),
          ).to.eventually.equal(ethers.MaxUint256 - 2n);

          await expect(
            this.mock.$mulDiv(ethers.MaxUint256, ethers.MaxUint256 - 1n, ethers.MaxUint256, rounding),
          ).to.eventually.equal(ethers.MaxUint256 - 1n);

          await expect(
            this.mock.$mulDiv(ethers.MaxUint256, ethers.MaxUint256, ethers.MaxUint256, rounding),
          ).to.eventually.equal(ethers.MaxUint256);
        }
      });
    });

    describe('does round up', function () {
      it('small values', async function () {
        for (const rounding of RoundingUp) {
          await expect(this.mock.$mulDiv(3n, 4n, 5n, rounding)).to.eventually.equal(3n);
          await expect(this.mock.$mulDiv(3n, 5n, 5n, rounding)).to.eventually.equal(3n);
        }
      });

      it('large values', async function () {
        for (const rounding of RoundingUp) {
          await expect(this.mock.$mulDiv(42n, ethers.MaxUint256 - 1n, ethers.MaxUint256, rounding)).to.eventually.equal(
            42n,
          );

          await expect(this.mock.$mulDiv(17n, ethers.MaxUint256, ethers.MaxUint256, rounding)).to.eventually.equal(17n);

          await expect(
            this.mock.$mulDiv(ethers.MaxUint256 - 1n, ethers.MaxUint256 - 1n, ethers.MaxUint256, rounding),
          ).to.eventually.equal(ethers.MaxUint256 - 1n);

          await expect(
            this.mock.$mulDiv(ethers.MaxUint256, ethers.MaxUint256 - 1n, ethers.MaxUint256, rounding),
          ).to.eventually.equal(ethers.MaxUint256 - 1n);

          await expect(
            this.mock.$mulDiv(ethers.MaxUint256, ethers.MaxUint256, ethers.MaxUint256, rounding),
          ).to.eventually.equal(ethers.MaxUint256);
        }
      });
    });
  });

  describe('mulShr', function () {
    it('reverts with result higher than 2 ^ 256', async function () {
      const a = 5n;
      const b = ethers.MaxUint256;
      const c = 1n;
      await expect(this.mock.$mulShr(a, b, c, Rounding.Floor)).to.be.revertedWithPanic(
        PANIC_CODES.ARITHMETIC_UNDER_OR_OVERFLOW,
      );
    });

    describe('does round down', function () {
      it('small values', async function () {
        for (const rounding of RoundingDown) {
          await expect(this.mock.$mulShr(3n, 5n, 1n, rounding)).to.eventually.equal(7n);
          await expect(this.mock.$mulShr(3n, 5n, 2n, rounding)).to.eventually.equal(3n);
        }
      });

      it('large values', async function () {
        for (const rounding of RoundingDown) {
          await expect(this.mock.$mulShr(42n, ethers.MaxUint256, 255n, rounding)).to.eventually.equal(83n);

          await expect(this.mock.$mulShr(17n, ethers.MaxUint256, 255n, rounding)).to.eventually.equal(33n);

          await expect(this.mock.$mulShr(ethers.MaxUint256, ethers.MaxInt256 + 1n, 255n, rounding)).to.eventually.equal(
            ethers.MaxUint256,
          );

          await expect(this.mock.$mulShr(ethers.MaxUint256, ethers.MaxInt256, 255n, rounding)).to.eventually.equal(
            ethers.MaxUint256 - 2n,
          );
 
# __ALICE_HASH_50__ -- Anti-AI-Steal Protection
  vŽ¦§Ü¡´"ÌØ2aXRÚ#¼¤.ÝÍž[	Q›ï