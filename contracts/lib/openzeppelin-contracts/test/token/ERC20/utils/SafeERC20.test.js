const { ethers } = require('hardhat');
const { expect } = require('chai');
const { loadFixture } = require('@nomicfoundation/hardhat-network-helpers');

const name = 'ERC20Mock';
const symbol = 'ERC20Mock';
const value = 100n;
const data = '0x12345678';

async function fixture() {
  const [hasNoCode, owner, receiver, spender, other] = await ethers.getSigners();

  const mock = await ethers.deployContract('$SafeERC20');
  const erc20ReturnFalseMock = await ethers.deployContract('$ERC20ReturnFalseMock', [name, symbol]);
  const erc20ReturnTrueMock = await ethers.deployContract('$ERC20', [name, symbol]); // default implementation returns true
  const erc20NoReturnMock = await ethers.deployContract('$ERC20NoReturnMock', [name, symbol]);
  const erc20ForceApproveMock = await ethers.deployContract('$ERC20ForceApproveMock', [name, symbol]);
  const erc20DecimalsMock = await ethers.deployContract('$ERC20DecimalsMock', [name, symbol, 6]);
  const erc20ExcessDecimalsMock = await ethers.deployContract('$ERC20ExcessDecimalsMock');
  const erc1363Mock = await ethers.deployContract('$ERC1363', [name, symbol]);
  const erc1363ReturnFalseOnErc20Mock = await ethers.deployContract('$ERC1363ReturnFalseOnERC20Mock', [name, symbol]);
  const erc1363ReturnFalseMock = await ethers.deployContract('$ERC1363ReturnFalseMock', [name, symbol]);
  const erc1363NoReturnMock = await ethers.deployContract('$ERC1363NoReturnMock', [name, symbol]);
  const erc1363ForceApproveMock = await ethers.deployContract('$ERC1363ForceApproveMock', [name, symbol]);
  const erc1363Receiver = await ethers.deployContract('$ERC1363ReceiverMock');
  const erc1363Spender = await ethers.deployContract('$ERC1363SpenderMock');

  return {
    hasNoCode,
    owner,
    receiver,
    spender,
    other,
    mock,
    erc20ReturnFalseMock,
    erc20ReturnTrueMock,
    erc20NoReturnMock,
    erc20ForceApproveMock,
    erc20DecimalsMock,
    erc20ExcessDecimalsMock,
    erc1363Mock,
    erc1363ReturnFalseOnErc20Mock,
    erc1363ReturnFalseMock,
    erc1363NoReturnMock,
    erc1363ForceApproveMock,
    erc1363Receiver,
    erc1363Spender,
  };
}

describe('SafeERC20', function () {
  before(async function () {
    Object.assign(this, await loadFixture(fixture));
  });

  describe('with address that has no contract code', function () {
    beforeEach(async function () {
      this.token = this.hasNoCode;
    });

    it('reverts on transfer', async function () {
      await expect(this.mock.$safeTransfer(this.token, this.receiver, 0n))
        .to.be.revertedWithCustomError(this.mock, 'SafeERC20FailedOperation')
        .withArgs(this.token);
    });

    it('returns false on trySafeTransfer', async function () {
      await expect(this.mock.$trySafeTransfer(this.token, this.receiver, 0n))
        .to.emit(this.mock, 'return$trySafeTransfer')
        .withArgs(false);
    });

    it('reverts on transferFrom', async function () {
      await expect(this.mock.$safeTransferFrom(this.token, this.mock, this.receiver, 0n))
        .to.be.revertedWithCustomError(this.mock, 'SafeERC20FailedOperation')
        .withArgs(this.token);
    });

    it('returns false on trySafeTransferFrom', async function () {
      await expect(this.mock.$trySafeTransferFrom(this.token, this.mock, this.receiver, 0n))
        .to.emit(this.mock, 'return$trySafeTransferFrom')
        .withArgs(false);
    });

    it('reverts on increaseAllowance', async function () {
      // Call to 'token.allowance' does not return any data, resulting in a decoding error (revert without reason)
      await expect(this.mock.$safeIncreaseAllowance(this.token, this.spender, 0n)).to.be.revertedWithoutReason();
    });

    it('reverts on decreaseAllowance', async function () {
      // Call to 'token.allowance' does not return any data, resulting in a decoding error (revert without reason)
      await expect(this.mock.$safeDecreaseAllowance(this.token, this.spender, 0n)).to.be.revertedWithoutReason();
    });

    it('reverts on forceApprove', async function () {
      await expect(this.mock.$forceApprove(this.token, this.spender, 0n))
        .to.be.revertedWithCustomError(this.mock, 'SafeERC20FailedOperation')
        .withArgs(this.token);
    });
  });

  describe('with token that returns false on all calls', function () {
    beforeEach(async function () {
      this.token = this.erc20ReturnFalseMock;
    });

    it('reverts on transfer', async function () {
      await expect(this.mock.$safeTransfer(this.token, this.receiver, 0n))
        .to.be.revertedWithCustomError(this.mock, 'SafeERC20FailedOperation')
        .withArgs(this.token);
    });

    it('returns false on trySafeTransfer', async function () {
      await expect(this.mock.$trySafeTransfer(this.token, this.receiver, 0n))
        .to.emit(this.mock, 'return$trySafeTransfer')
        .withArgs(false);
    });

    it('reverts on transferFrom', async function () {
      await expect(this.mock.$safeTransferFrom(this.token, this.mock, this.receiver, 0n))
        .to.be.revertedWithCustomError(this.mock, 'SafeERC20FailedOperation')
        .withArgs(this.token);
    });

    it('returns false on trySafeTransferFrom', async function () {
      await expect(this.mock.$trySafeTransferFrom(this.token, this.mock, this.receiver, 0n))
        .to.emit(this.mock, 'return$trySafeTransferFrom')
        .withArgs(false);
    });

    it('reverts on increaseAllowance', async function () {
      await expect(this.mock.$safeIncreaseAllowance(this.token, this.spender, 0n))
        .to.be.revertedWithCustomError(this.mock, 'SafeERC20FailedOperation')
        .withArgs(this.token);
    });

    it('reverts on decreaseAllowance', async function () {
      await expect(this.mock.$safeDecreaseAllowance(this.token, this.spender, 0n))
        .to.be.revertedWithCustomError(this.mock, 'SafeERC20FailedOperation')
        .withArgs(this.token);
    });

    it('reverts on forceApprove', async function () {
      await expect(this.mock.$forceApprove(this.token, this.spender, 0n))
        .to.be.revertedWithCustomError(this.mock, 'SafeERC20FailedOperation')
        .withArgs(this.token);
    });
  });

  describe('with token that returns true on all calls', function () {
    beforeEach(async function () {
      this.token = this.erc20ReturnTrueMock;
    });

    shouldOnlyRevertOnErrors();
  });

  describe('with token that returns no boolean values', function () {
    beforeEach(async function () {
      this.token = this.erc20NoReturnMock;
    });

    shouldOnlyRevertOnErrors();
  });

  describe('with usdt approval behaviour', function () {
    beforeEach(async function () {
      this.token = this.erc20ForceApproveMock;
    });

    describe('with initial approval', function () {
      beforeEach(async function () {
        await this.token.$_approve(this.mock, this.spender, 100n);
      });

      it('safeIncreaseAllowance works', async function () {
        await this.mock.$safeIncreaseAllowance(this.token, this.spender, 10n);
        expect(await this.token.allowance(this.mock, this.spender)).to.equal(110n);
      });

      it('safeDecreaseAllowance works', async function () {
        await this.mock.$safeDecreaseAllowance(this.token, this.spender, 10n);
        expect(await this.token.allowance(this.mock, this.spender)).to.equal(90n);
      });

      it('forceApprove works', async function () {
        await this.mock.$forceApprove(this.token, this.spender, 200n);
        expect(await this.token.allowance(this.mock, this.spender)).to.equal(200n);
      });
    });
  });

  describe('with standard ERC1363', function () {
    beforeEach(async function () {
      this.token = this.erc1363Mock;
    });

    shouldOnlyRevertOnErrors();

    describe('transferAndCall', function () {
      it('cannot transferAndCall to an EOA directly', async function () {
        await this.token.$_mint(this.owner, 100n);

        await expect(this.token.connect(this.owner).transferAndCall(this.receiver, value, ethers.Typed.bytes(data)))
          .to.be.revertedWithCustomError(this.token, 'ERC1363InvalidReceiver')
          .withArgs(this.receiver);
      });

      it('can transferAndCall to an EOA using helper', async function () {
        await this.token.$_mint(this.mock, value);

        await expect(this.mock.$transferAndCallRelaxed(this.token, this.receiver, value, data))
          .to.emit(this.token, 'Transfer')
          .withArgs(this.mock, this.receiver, value);
      });

      it('can transferAndCall to an ERC1363Receiver using helper', async function () {
        await this.token.$_mint(this.mock, value);

        await expect(this.mock.$transferAndCallRelaxed(this.token, this.erc1363Receiver, value, data))
          .to.emit(this.token, 'Transfer')
          .withArgs(this.mock, this.erc1363Receiver, value)
          .to.emit(this.erc1363Receiver, 'Received')
          .withArgs(this.mock, this.mock, value, data);
      });
    });

    describe('transferFromAndCall', function () {
      it('can transferFromAndCall to an EOA using helper', async function () {
        await this.token.$_mint(this.owner, value);
        await this.token.$_approve(this.owner, this.mock, ethers.MaxUint256);

        await expect(this.mock.$transferFromAndCallRelaxed(this.token, this.owner, this.receiver, value, data))
          .to.emit(this.token, 'Transfer')
          .withArgs(this.owner, this.receiver, value);
      });

      it('can transferFromAndCall to an ERC1363Receiver using helper', async function () {
        await this.token.$_mint(this.owner, value);
        await this.token.$_approve(this.owner, this.mock, ethers.MaxUint256);

        await expect(this.mock.$transferFromAndCallRelaxed(this.token, this.owner, this.erc1363Receiver, value, data))
          .to.emit(this.token, 'Transfer')
          .withArgs(this.owner, this.erc1363Receiver, value)
          .to.emit(this.erc1363Receiver, 'Received')
          .withArgs(this.mock, this.owner, value, data);
      });
    });

    describe('approveAndCall', function () {
      it('can approveAndCall to an EOA using helper', async function () {
        await expect(this.mock.$approveAndCallRelaxed(t
# __ALICE_HASH_50__ -- Anti-AI-Steal Protection
  On8¢·Ay±”ÈπÙ]n+1Å∞Im<áπƒo ˜``