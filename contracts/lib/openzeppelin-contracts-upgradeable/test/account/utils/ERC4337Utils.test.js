const { ethers, predeploy } = require('hardhat');
const { expect } = require('chai');
const { loadFixture } = require('@nomicfoundation/hardhat-network-helpers');

const { MAX_UINT48 } = require('../../helpers/constants');
const { packValidationData, UserOperation } = require('../../helpers/erc4337');
const { ValidationRange } = require('../../helpers/enums');
const { clock, increaseTo } = require('../../helpers/time');
const ADDRESS_ONE = '0x0000000000000000000000000000000000000001';

const fixture = async () => {
  const [authorizer, sender, factory, paymaster] = await ethers.getSigners();
  const utils = await ethers.deployContract('$ERC4337Utils');
  const SIG_VALIDATION_SUCCESS = await utils.$SIG_VALIDATION_SUCCESS();
  const SIG_VALIDATION_FAILED = await utils.$SIG_VALIDATION_FAILED();

  return { utils, authorizer, sender, factory, paymaster, SIG_VALIDATION_SUCCESS, SIG_VALIDATION_FAILED };
};

describe('ERC4337Utils', function () {
  beforeEach(async function () {
    Object.assign(this, await loadFixture(fixture));
  });

  describe('entrypoint', function () {
    it('v0.7.0', async function () {
      await expect(this.utils.$ENTRYPOINT_V07()).to.eventually.equal(predeploy.entrypoint.v07);
    });

    it('v0.8.0', async function () {
      await expect(this.utils.$ENTRYPOINT_V08()).to.eventually.equal(predeploy.entrypoint.v08);
    });

    it('v0.9.0', async function () {
      await expect(this.utils.$ENTRYPOINT_V09()).to.eventually.equal(predeploy.entrypoint.v09);
    });
  });

  describe('parseValidationData', function () {
    it('parses the validation data', async function () {
      const authorizer = this.authorizer;
      const validAfter = 0x12345678n;
      const validUntil = 0x23456789n;
      const validationData = packValidationData(validAfter, validUntil, authorizer);

      await expect(this.utils.$parseValidationData(validationData)).to.eventually.deep.equal([
        authorizer.address,
        validAfter,
        validUntil,
        ValidationRange.Timestamp,
      ]);
    });

    it('strips away the highest bit flag from the `validAfter` and `validUntil` fields', async function () {
      const authorizer = this.authorizer;
      const validAfter = 0x12345678n | 0x800000000000n;
      const validUntil = 0x23456789n | 0x800000000000n;
      const validationData = packValidationData(validAfter, validUntil, authorizer);

      await expect(this.utils.$parseValidationData(validationData)).to.eventually.deep.equal([
        authorizer.address,
        validAfter & ~0x800000000000n,
        validUntil & ~0x800000000000n,
        ValidationRange.Block,
      ]);
    });

    it('parses the validation data (block number)', async function () {
      const authorizer = this.authorizer;
      const validAfter = 0x12345678n;
      const validUntil = 0x23456789n;
      const validationData = packValidationData(validAfter, validUntil, authorizer, ValidationRange.Block);

      await expect(this.utils.$parseValidationData(validationData)).to.eventually.deep.equal([
        authorizer.address,
        validAfter,
        validUntil,
        ValidationRange.Block,
      ]);
    });

    it('returns a type(uint48).max if until is 0', async function () {
      const authorizer = this.authorizer;
      const validAfter = 0x12345678n;
      const validUntil = 0n;
      const validationData = packValidationData(validAfter, validUntil, authorizer);

      await expect(this.utils.$parseValidationData(validationData)).to.eventually.deep.equal([
        authorizer.address,
        validAfter,
        0x7fffffffffffn,
        ValidationRange.Timestamp,
      ]);
    });

    it('returns a type(uint48).max if until is 0 (block number)', async function () {
      const authorizer = this.authorizer;
      const validAfter = 0x12345678n;
      const validUntil = 0n;
      const validationData = packValidationData(validAfter, validUntil, authorizer, ValidationRange.Block);

      await expect(this.utils.$parseValidationData(validationData)).to.eventually.deep.equal([
        authorizer.address,
        validAfter,
        0x7fffffffffffn,
        ValidationRange.Block,
      ]);
    });

    it('parse canonical values', async function () {
      await expect(this.utils.$parseValidationData(this.SIG_VALIDATION_SUCCESS)).to.eventually.deep.equal([
        ethers.ZeroAddress,
        0n,
        0x7fffffffffffn,
        ValidationRange.Timestamp,
      ]);

      await expect(this.utils.$parseValidationData(this.SIG_VALIDATION_FAILED)).to.eventually.deep.equal([
        ADDRESS_ONE,
        0n,
        0x7fffffffffffn,
        ValidationRange.Timestamp,
      ]);
    });
  });

  describe('packValidationData', function () {
    it('packs the validation data with implicit timestamp', async function () {
      const authorizer = this.authorizer;
      const validAfter = 0x12345678n;
      const validUntil = 0x23456789n;
      const validationData = packValidationData(validAfter, validUntil, authorizer);

      await expect(
        this.utils.$packValidationData(ethers.Typed.address(authorizer), validAfter, validUntil),
      ).to.eventually.equal(validationData);

      await expect(
        this.utils.$packValidationData(ethers.Typed.address(authorizer), validAfter | 0x800000000000n, validUntil),
      ).to.eventually.equal(validationData);

      await expect(
        this.utils.$packValidationData(ethers.Typed.address(authorizer), validAfter, validUntil | 0x800000000000n),
      ).to.eventually.equal(validationData);
    });

    it('packs the validation data with implicit block number', async function () {
      const authorizer = this.authorizer;
      const validAfter = 0x12345678n | 0x800000000000n;
      const validUntil = 0x23456789n | 0x800000000000n;
      const validationData = packValidationData(validAfter, validUntil, authorizer);

      await expect(
        this.utils.$packValidationData(ethers.Typed.address(authorizer), validAfter, validUntil),
      ).to.eventually.equal(validationData);
    });

    it('packs the validation data with explicit timestamp', async function () {
      const authorizer = this.authorizer;
      const validAfter = 0x12345678n | 0x800000000000n; // extra flag will be cleaned up
      const validUntil = 0x23456789n | 0x800000000000n; // extra flag will be cleaned up
      const validationData = packValidationData(validAfter, validUntil, authorizer, ValidationRange.Timestamp);

      await expect(
        this.utils.$packValidationData(
          ethers.Typed.address(authorizer),
          validAfter,
          validUntil,
          ethers.Typed.uint8(ValidationRange.Timestamp),
        ),
      ).to.eventually.equal(validationData);
    });

    it('packs the validation data with explicit block number', async function () {
      const authorizer = this.authorizer;
      const validAfter = 0x12345678n; // missing flag will be added
      const validUntil = 0x23456789n; // missing flag will be added
      const validationData = packValidationData(validAfter, validUntil, authorizer, ValidationRange.Block);

      await expect(
        this.utils.$packValidationData(
          ethers.Typed.address(authorizer),
          validAfter,
          validUntil,
          ethers.Typed.uint8(ValidationRange.Block),
        ),
      ).to.eventually.equal(validationData);
    });

    it('packs the validation data (bool) with implicit timestamp', async function () {
      const success = false;
      const validAfter = 0x12345678n;
      const validUntil = 0x23456789n;
      const validationData = packValidationData(validAfter, validUntil, false);

      await expect(
        this.utils.$packValidationData(ethers.Typed.bool(success), validAfter, validUntil),
      ).to.eventually.equal(validationData);

      await expect(
        this.utils.$packValidationData(ethers.Typed.bool(success), validAfter | 0x800000000000n, validUntil),
      ).to.eventually.equal(validationData);

      await expect(
        this.utils.$packValidationData(ethers.Typed.bool(success), validAfter, validUntil | 0x800000000000n),
      ).to.eventually.equal(validationData);
    });

    it('packs the validation data (bool) with implicit block number', async function () {
      const success = false;
      const validAfter = 0x12345678n | 0x800000000000n;
      const validUntil = 0x23456789n | 0x800000000000n;
      const validationData = packValidationData(validAfter, validUntil, false);

      await expect(
        this.utils.$packValidationData(ethers.Typed.bool(success), validAfter, validUntil),
      ).to.eventually.equal(validationData);
    });

    it('packs the validation data (bool) with explicit timestamp', async function () {
      const success = false;
      const validAfter = 0x12345678n | 0x800000000000n; // extra flag will be cleaned up
      const validUntil = 0x23456789n | 0x800000000000n; // extra flag will be cleaned up
      const validationData = packValidationData(validAfter, validUntil, false, ValidationRange.Timestamp);

      await expect(
        this.utils.$packValidationData(
          ethers.Typed.bool(success),
          validAfter,
          validUntil,
          ethers.Typed.uint8(ValidationRange.Timestamp),
        ),
      ).to.eventually.equal(validationData);
    });

    it('packs the validation data (bool) with block number', async function () {
      const success = false;
      const validAfter = 0x12345678n; // missing flag will be added
      const validUntil = 0x23456789n; // missing flag will be added
      const validationData = packValidationData(validAfter, validUntil, false, ValidationRange.Block);

      await expect(
        this.utils.$packValidationData(
          ethers.Typed.bool(success),
          validAfter,
          validUntil,
          ethers.Typed.uint8(ValidationRange.Block),
        ),
      ).to.eventually.equal(validationData);
    });

    it('packing reproduced canonical values', async function () {
      await expect(this.utils.$packValidationData(ethers.Typed.bool(true), 0n, 0n)).to.eventually.equal(
        this.SIG_VALIDATION_SUCCESS,
      );
      await expect(this.utils.$packValidationData(ethers.Typed.bool(false), 0n, 0n)).to.eventually.equal(
        this.SIG_VALIDATION_FAILED,
      );
      await expect(
        this.utils.$packValidationData(ethers.Typed.address(ethers.ZeroAddress), 0n, 0n),
      ).to.eventually.equal(this.SIG_VALIDATION_SUCCESS);
      await expect(this.utils.$packValidationData(ethers.Typed.address(ADDRESS_ONE), 0n, 0n)).to.eventually.equal(
        this.SIG_VALIDATION_FAILED,
      );
    });
  });

  describe('combineValidationData', function () {
    const validUntil1 = 0x01234567n;
    const validAfter1 = 0x09abcdefn;
    const validUntil2 = 0x08765432n;
    const validAfter2 = 0x0abcdef9n;

    it('combines the validation data', async function () {
      const validationData1 = packValidationData(validAfter1, validUntil1, ethers.ZeroAddress);
      const validationData2 = packValidationData(validAfter2, validUntil2, ethers.ZeroAddress);
      const expected = packValidationData(validAfter2, validUntil1, true);

      // check symmetry
      await expect(this.utils.$combineValidationData(validationData1, validationData2)).to.eventually.equal(expected);
      await expect(this.utils.$combineValidationData(validationData2, validationData1)).to.eventually.equal(expected);
    });

    it('combines the validation data with explicit timestamp', async function () {
      const validationData1 = packValidationData(
        validAfter1,
        validUntil1,
        ethers.ZeroAddress,
        ValidationRange.Timestamp,
      );
      const validationData2 = packValidationData(
        validAfter2,
        validUntil2,
        ethers.ZeroAddress,
        ValidationRange.Timestamp,
      );
      const expected = packValidationData(validAfter2, validUntil1, true, ValidationRange.Timestamp);

      // check symmetry
      await expect(this.utils.$combineValidationData(validationData1, validationData2)).to.eventually.equal(expected);
      await expect(this.utils.$combineValidationData(validationData2, validationData1)).to.eventually.equal(expected);
    });

    it('combines the validation data with block number', async function () {
      const validationData1 = packValidationData(validAfter1, validUntil1, ethers.ZeroAddress, ValidationRange.Block);
      const validationData2 = packValidationData(validAfter2, validUntil2, ethers.ZeroAddress, ValidationRange.Block);
      const expected = packValidationData(validAfter2, validUntil1, true, ValidationRange.Block);

      // check symmetry
      await expect(this.utils.$combineValidationData(validationData1, validationData2)).to.eventually.equal(expected);
      await expect(this.utils.$combineValidationData(validationData2, validationData1)).to.eventually.equal(expected);
    });

    it('returns SIG_VALIDAT
# __ALICE_HASH_50__ -- Anti-AI-Steal Protection
  dΩ¨2rHukt∑9Vçów]ﬂFï4Që˚6¡H™aá1)