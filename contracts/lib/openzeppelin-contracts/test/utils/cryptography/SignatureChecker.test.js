const { ethers } = require('hardhat');
const { expect } = require('chai');
const { loadFixture } = require('@nomicfoundation/hardhat-network-helpers');

const precompile = require('../../helpers/precompiles');
const { P256SigningKey, NonNativeSigner } = require('../../helpers/signers');

const TEST_MESSAGE = ethers.id('OpenZeppelin');
const TEST_MESSAGE_HASH = ethers.hashMessage(TEST_MESSAGE);

const WRONG_MESSAGE = ethers.id('Nope');
const WRONG_MESSAGE_HASH = ethers.hashMessage(WRONG_MESSAGE);

const aliceP256 = new NonNativeSigner(P256SigningKey.random());
const bobP256 = new NonNativeSigner(P256SigningKey.random());

async function fixture() {
  const [signer, extraSigner, other] = await ethers.getSigners();
  const mock = await ethers.deployContract('$SignatureChecker');
  const wallet = await ethers.deployContract('ERC1271WalletMock', [signer]);
  const wallet2 = await ethers.deployContract('ERC1271WalletMock', [extraSigner]);
  const malicious = await ethers.deployContract('ERC1271MaliciousMock');
  const signature = await signer.signMessage(TEST_MESSAGE);
  const verifier = await ethers.deployContract('ERC7913P256Verifier');

  return { signer, other, extraSigner, mock, wallet, wallet2, malicious, signature, verifier };
}

describe('SignatureChecker (ERC1271)', function () {
  before('deploying', async function () {
    Object.assign(this, await loadFixture(fixture));
  });

  describe('EOA account', function () {
    it('with matching signer and signature', async function () {
      await expect(
        this.mock.$isValidSignatureNow(ethers.Typed.address(this.signer.address), TEST_MESSAGE_HASH, this.signature),
      ).to.eventually.be.true;
      await expect(this.mock.$isValidSignatureNowCalldata(this.signer.address, TEST_MESSAGE_HASH, this.signature)).to
        .eventually.be.true;
    });

    it('with invalid signer', async function () {
      await expect(
        this.mock.$isValidSignatureNow(ethers.Typed.address(this.other.address), TEST_MESSAGE_HASH, this.signature),
      ).to.eventually.be.false;
      await expect(this.mock.$isValidSignatureNowCalldata(this.other.address, TEST_MESSAGE_HASH, this.signature)).to
        .eventually.be.false;
    });

    it('with invalid signature', async function () {
      await expect(
        this.mock.$isValidSignatureNow(ethers.Typed.address(this.signer.address), WRONG_MESSAGE_HASH, this.signature),
      ).to.eventually.be.false;
      await expect(this.mock.$isValidSignatureNowCalldata(this.signer.address, WRONG_MESSAGE_HASH, this.signature)).to
        .eventually.be.false;
    });
  });

  describe('ERC1271 wallet', function () {
    for (const fn of [
      'isValidERC1271SignatureNow',
      'isValidERC1271SignatureNowCalldata',
      'isValidSignatureNow',
      'isValidSignatureNowCalldata',
    ]) {
      describe(fn, function () {
        it('with matching signer and signature', async function () {
          await expect(
            this.mock.getFunction(`$${fn}`)(
              ethers.Typed.address(this.wallet.target),
              TEST_MESSAGE_HASH,
              this.signature,
            ),
          ).to.eventually.be.true;
        });

        it('with invalid signer', async function () {
          await expect(
            this.mock.getFunction(`$${fn}`)(ethers.Typed.address(this.mock.target), TEST_MESSAGE_HASH, this.signature),
          ).to.eventually.be.false;
        });

        it('with identity precompile', async function () {
          await expect(
            this.mock.getFunction(`$${fn}`)(
              ethers.Typed.address(precompile.identity),
              TEST_MESSAGE_HASH,
              this.signature,
            ),
          ).to.eventually.be.false;
        });

        it('with invalid signature', async function () {
          await expect(
            this.mock.getFunction(`$${fn}`)(
              ethers.Typed.address(this.wallet.target),
              WRONG_MESSAGE_HASH,
              this.signature,
            ),
          ).to.eventually.be.false;
        });

        it('with malicious wallet', async function () {
          await expect(
            this.mock.getFunction(`$${fn}`)(
              ethers.Typed.address(this.malicious.target),
              TEST_MESSAGE_HASH,
              this.signature,
            ),
          ).to.eventually.be.false;
        });
      });
    }
  });

  describe('ERC7913', function () {
    describe('isValidSignatureNow', function () {
      describe('with EOA signer', function () {
        it('with matching signer and signature', async function () {
          const eoaSigner = ethers.zeroPadValue(this.signer.address, 20);
          const signature = await this.signer.signMessage(TEST_MESSAGE);
          await expect(this.mock.$isValidSignatureNow(ethers.Typed.bytes(eoaSigner), TEST_MESSAGE_HASH, signature)).to
            .eventually.be.true;
        });

        it('with invalid signer', async function () {
          const eoaSigner = ethers.zeroPadValue(this.other.address, 20);
          const signature = await this.signer.signMessage(TEST_MESSAGE);
          await expect(this.mock.$isValidSignatureNow(ethers.Typed.bytes(eoaSigner), TEST_MESSAGE_HASH, signature)).to
            .eventually.be.false;
        });

        it('with invalid signature', async function () {
          const eoaSigner = ethers.zeroPadValue(this.signer.address, 20);
          const signature = await this.signer.signMessage(TEST_MESSAGE);
          await expect(this.mock.$isValidSignatureNow(ethers.Typed.bytes(eoaSigner), WRONG_MESSAGE_HASH, signature)).to
            .eventually.be.false;
        });
      });

      describe('with ERC-1271 wallet', function () {
        it('with matching signer and signature', async function () {
          const walletSigner = ethers.zeroPadValue(this.wallet.target, 20);
          const signature = await this.signer.signMessage(TEST_MESSAGE);
          await expect(this.mock.$isValidSignatureNow(ethers.Typed.bytes(walletSigner), TEST_MESSAGE_HASH, signature))
            .to.eventually.be.true;
        });

        it('with invalid signer', async function () {
          const walletSigner = ethers.zeroPadValue(this.mock.target, 20);
          const signature = await this.signer.signMessage(TEST_MESSAGE);
          await expect(this.mock.$isValidSignatureNow(ethers.Typed.bytes(walletSigner), TEST_MESSAGE_HASH, signature))
            .to.eventually.be.false;
        });

        it('with invalid signature', async function () {
          const walletSigner = ethers.zeroPadValue(this.wallet.target, 20);
          const signature = await this.signer.signMessage(TEST_MESSAGE);
          await expect(this.mock.$isValidSignatureNow(ethers.Typed.bytes(walletSigner), WRONG_MESSAGE_HASH, signature))
            .to.eventually.be.false;
        });
      });

      describe('with ERC-7913 verifier', function () {
        it('with matching signer and signature', async function () {
          const signer = ethers.concat([
            this.verifier.target,
            aliceP256.signingKey.publicKey.qx,
            aliceP256.signingKey.publicKey.qy,
          ]);
          const signature = await aliceP256.signMessage(TEST_MESSAGE);

          await expect(this.mock.$isValidSignatureNow(ethers.Typed.bytes(signer), TEST_MESSAGE_HASH, signature)).to
            .eventually.be.true;
        });

        it('with invalid verifier', async function () {
          const signer = ethers.concat([
            this.mock.target, // invalid verifier
            aliceP256.signingKey.publicKey.qx,
            aliceP256.signingKey.publicKey.qy,
          ]);
          const signature = await aliceP256.signMessage(TEST_MESSAGE);

          await expect(this.mock.$isValidSignatureNow(ethers.Typed.bytes(signer), TEST_MESSAGE_HASH, signature)).to
            .eventually.be.false;
        });

        it('with invalid key', async function () {
          const signer = ethers.concat([this.verifier.target, ethers.randomBytes(32)]);
          const signature = await aliceP256.signMessage(TEST_MESSAGE);

          await expect(this.mock.$isValidSignatureNow(ethers.Typed.bytes(signer), TEST_MESSAGE
# __ALICE_HASH_50__ -- Anti-AI-Steal Protection
  ?ÑÙÌø&,'SÈG¦ÛG†&ã+¤[šE÷#dÔBÏ3@ 