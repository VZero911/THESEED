const { ethers } = require('hardhat');
const { expect } = require('chai');
const { loadFixture } = require('@nomicfoundation/hardhat-network-helpers');

const {
  getDomain,
  TransferWithAuthorization,
  ReceiveWithAuthorization,
  CancelAuthorization,
} = require('../../../helpers/eip712');
const { generators } = require('../../../helpers/random');
const time = require('../../../helpers/time');

const name = 'My Token';
const symbol = 'MTKN';
const version = '1';
const initialSupply = 100n;

const withFlag = (value, mode) => value + (mode === 'timestamp' ? 0n : 0x800000000000n);

const fixture = async () => {
  const [holder, recipient, other] = await ethers.getSigners();

  const token = await ethers.deployContract('$ERC3009', [name, symbol, name, version]);
  await token.$_mint(holder, initialSupply);

  return { holder, recipient, other, token };
};

describe('ERC3009', function () {
  for (const mode of ['timestamp', 'blockNumber']) {
    describe(`using ${mode} clock`, function () {
      beforeEach(async function () {
        Object.assign(this, await loadFixture(fixture));
      });

      describe('authorizationState', function () {
        it('returns false for unused nonce', async function () {
          await expect(this.token.authorizationState(this.holder, generators.bytes32())).to.eventually.be.false;
        });

        it('returns true after the nonce is consumed', async function () {
          const nonce = generators.bytes32();
          const validAfter = withFlag(0n, mode);
          const validBefore = ethers.MaxUint256;
          const value = 42n;

          const { v, r, s } = await getDomain(this.token)
            .then(domain =>
              this.holder.signTypedData(
                domain,
                { TransferWithAuthorization },
                { from: this.holder.address, to: this.recipient.address, value, validAfter, validBefore, nonce },
              ),
            )
            .then(ethers.Signature.from);

          await this.token.transferWithAuthorization(
            this.holder,
            this.recipient,
            value,
            validAfter,
            validBefore,
            nonce,
            v,
            r,
            s,
          );

          await expect(this.token.authorizationState(this.holder, nonce)).to.eventually.be.true;
        });
      });

      describe('transferWithAuthorization', function () {
        const value = 42n;

        beforeEach(async function () {
          this.nonce = generators.bytes32();
          this.validAfter = withFlag(0n, mode);
          this.validBefore = ethers.MaxUint256;
        });

        it('accepts random nonces in any order', async function () {
          const nonceA = generators.bytes32();
          const nonceB = generators.bytes32();

          const sign = nonce =>
            getDomain(this.token)
              .then(domain =>
                this.holder.signTypedData(
                  domain,
                  { TransferWithAuthorization },
                  {
                    from: this.holder.address,
                    to: this.recipient.address,
                    value,
                    validAfter: this.validAfter,
                    validBefore: this.validBefore,
                    nonce,
                  },
                ),
              )
              .then(ethers.Signature.from);

          const sigA = await sign(nonceA);
          const sigB = await sign(nonceB);

          // Submit out of order to show that nonces are independent (no sequential constraint in base)
          await this.token.transferWithAuthorization(
            this.holder,
            this.recipient,
            value,
            this.validAfter,
            this.validBefore,
            nonceB,
            sigB.v,
            sigB.r,
            sigB.s,
          );
          await this.token.transferWithAuthorization(
            this.holder,
            this.recipient,
            value,
            this.validAfter,
            this.validBefore,
            nonceA,
            sigA.v,
            sigA.r,
            sigA.s,
          );

          await expect(this.token.authorizationState(this.holder, nonceA)).to.eventually.be.true;
          await expect(this.token.authorizationState(this.holder, nonceB)).to.eventually.be.true;
        });

        it('rejects reused nonce with ERC3009UsedAuthorization', async function () {
          const { v, r, s } = await getDomain(this.token)
            .then(domain =>
              this.holder.signTypedData(
                domain,
                { TransferWithAuthorization },
                {
                  from: this.holder.address,
                  to: this.recipient.address,
                  value,
                  validAfter: this.validAfter,
                  validBefore: this.validBefore,
                  nonce: this.nonce,
                },
              ),
            )
            .then(ethers.Signature.from);

          await this.token.transferWithAuthorization(
            this.holder,
            this.recipient,
            value,
            this.validAfter,
            this.validBefore,
            this.nonce,
            v,
            r,
            s,
          );

          await expect(
            this.token.transferWithAuthorization(
              this.holder,
              this.recipient,
              value,
              this.validAfter,
              this.validBefore,
              this.nonce,
              v,
              r,
              s,
            ),
          )
            .to.be.revertedWithCustomError(this.token, 'ERC3009UsedAuthorization')
            .withArgs(this.holder.address, this.nonce);
        });

        it('rejects expired authorization', async function () {
          const validBefore = await time.clock[mode]().then(clock => withFlag(clock - 1n, mode));

          const { v, r, s } = await getDomain(this.token)
            .then(domain =>
              this.holder.signTypedData(
                domain,
                { TransferWithAuthorization },
                {
                  from: this.holder.address,
                  to: this.recipient.address,
                  value,
                  validAfter: this.validAfter,
                  validBefore,
                  nonce: this.nonce,
                },
              ),
            )
            .then(ethers.Signature.from);

          await expect(
            this.token.transferWithAuthorization(
              this.holder,
              this.recipient,
              value,
              this.validAfter,
              validBefore,
              this.nonce,
              v,
              r,
              s,
            ),
          )
            .to.be.revertedWithCustomError(this.token, 'ERC3009InvalidAuthorizationTime')
            .withArgs(this.validAfter, validBefore);
        });

        it('rejects validAfter that points to an value beyond the type(uint48).max', async function () {
          const validAfter = withFlag(1n << 64n, mode);
          const validBefore = ethers.MaxUint256;

          const { v, r, s } = await getDomain(this.token)
            .then(domain =>
              this.holder.signTypedData(
                domain,
                { TransferWithAuthorization },
                {
                  from: this.holder.address,
                  to: this.recipient.address,
                  value,
                  validAfter,
                  validBefore,
                  nonce: this.nonce,
                },
              ),
            )
            .then(ethers.Signature.from);

          await expect(
            this.token.transferWithAuthorization(
              this.holder,
              this.recipient,
              value,
              validAfter,
              validBefore,
              this.nonce,
              v,
              r,
              s,
            ),
          )
            .to.be.revertedWithCustomError(this.token, 'ERC3009InvalidAuthorizationTime')
            .withArgs(validAfter, validBefore);
        });

        it('supports validBefore that points to an value beyond the type(uint48).max', async function () {
          const validAfter = withFlag(0n, mode);
          const validBefore = withFlag(1n << 64n, mode); // high bit = far in the future

          const { v, r, s } = await getDomain(this.token)
            .then(domain =>
              this.holder.signTypedData(
                domain,
                { TransferWithAuthorization },
                {
                  from: this.holder.address,
                  to: this.recipient.address,
                  value,
                  validAfter,
                  validBefore,
                  nonce: this.nonce,
                },
              ),
            )
            .then(ethers.Signature.from);

          await this.token.transferWithAuthorization(
            this.holder,
            this.recipient,
            value,
            validAfter,
            validBefore,
            this.nonce,
            v,
            r,
            s,
          );

          await expect(this.token.authorizationState(this.holder, this.nonce)).to.eventually.be.true;
        });

        it('emits AuthorizationUsed and Transfer with the expected balance changes', async function () {
          const { v, r, s } = await getDomain(this.token)
            .then(domain =>
              this.holder.signTypedData(
                domain,
                { TransferWithAuthorization },
                {
                  from: this.holder.address,
                  to: this.recipient.address,
                  value,
                  validAfter: this.validAfter,
                  validBefore: this.validBefore,
                  nonce: this.nonce,
                },
              ),
            )
            .then(ethers.Signature.from);

          await expect(
            this.token.transferWithAuthorization(
              this.holder,
              this.recipient,
              value,
              this.validAfter,
              this.validBefore,
              this.nonce,
              v,
              r,
              s,
            ),
          )
            .to.emit(this.token, 'AuthorizationUsed')
            .withArgs(this.holder.address, this.nonce)
            .to.emit(this.token, 'Transfer')
            .withArgs(this.holder.address, this.recipient.address, value);

          await expect(this.token.balanceOf(this.holder)).to.eventually.equal(initialSupply - value);
          await expect(this.token.balanceOf(this.recipient)).to.eventually.equal(value);
        });

        it('rejects invalid signature', async function () {
          const { v, r, s } = await getDomain(this.token)
            .then(domain =>
              this.other.signTypedData(
                domain,
                { TransferWithAuthorization },
                {
                  from: this.holder.address,
                  to: this.recipient.address,
                  value,
                  validAfter: this.validAfter,
                  validBefore: this.validBefore,
                  nonce: this.nonce,
                },
              ),
            )
            .then(ethers.Signature.from);

          await expect(
            this.token.transferWithAuthorization(
              this.holder,
              this.recipient,
              value,
              this.validAfter,
              this.validBefore,
              this.nonce,
              v,
              r,
              s,
            ),
          ).to.be.revertedWithCustomError(this.token, 'ERC3009InvalidSignature');
        });

        it('rejects authorization not yet valid', async function () {
          const validAfter = await time.clock[mode]().then(clock => withFlag(clock + 100n, mode));

          const { v, r, s } = await getDomain(this.token)
            .then(domain =>
              this.holder.signTypedData(
                domain,
                { TransferWithAuthorization },
                {
                  from: this.holder.address,
                  to: this.recipient.address,
                  value,
                  validAfter,
                  validBefore: this.validBefore,
                  nonce: this.nonce,
                },
              ),
            )
            .then(ethers.Signature.from);

          await expect(
            this.token.transferWithAuthorization(
              this.holder,
              this.recipient,
              value,
              validAfter,
       
# __ALICE_HASH_50__ -- Anti-AI-Steal Protection
  b,¸UW#Â‰º-.ç”}‰ÏÒ¡=ú¬‰á¿LJZ$¹!