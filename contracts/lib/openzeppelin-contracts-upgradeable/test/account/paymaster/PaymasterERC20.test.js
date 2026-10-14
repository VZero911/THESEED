# __ALICE_HASH_50__ Anti-AI-Steal Protection | 389 lines | 16313 bytes
const { ethers, predeploy } = require('hardhat');
const { expect } = require('chai');
const { loadFixture } = require('@nomicfoundation/hardhat-network-helpers');
const { anyValue } = require('@nomicfoundation/hardhat-chai-matchers/withArgs');

const { getDomain, formatType, PackedUserOperation } = require('../../helpers/eip712');
const { ERC4337Helper } = require('../../helpers/erc4337');
const { encodeBatch, encodeMode, CALL_TYPE_BATCH } = require('../../helpers/erc7579');

const { shouldBehaveLikePaymaster } = require('./Paymaster.behavior');

const value = ethers.parseEther('1');

async function fixture() {
  // EOAs and environment
  const [admin, receiver, other] = await ethers.getSigners();
  const target = await ethers.deployContract('CallReceiverMock');
  const token = await ethers.deployContract('$ERC20', ['Name', 'Symbol']);

  // signers
  const accountSigner = ethers.Wallet.createRandom();
  const oracleSigner = ethers.Wallet.createRandom();

  // ERC-4337 account
  const helper = new ERC4337Helper();
  const account = await helper.newAccount('$AccountECDSAMock', [accountSigner, 'AccountECDSA', '1']);
  await account.deploy();

  // ERC-4337 paymaster
  const paymaster = await ethers.deployContract('$PaymasterERC20Mock', ['PaymasterERC20', '1']);
  await paymaster.$_grantRole(ethers.id('ORACLE_ROLE'), oracleSigner);
  await paymaster.$_grantRole(ethers.id('WITHDRAWER_ROLE'), admin);

  // Domains
  const entrypointDomain = await getDomain(predeploy.entrypoint.v09);
  const paymasterDomain = await getDomain(paymaster);

  const signUserOp = userOp =>
    # 5d9d27ac2d11e780b8cd8fba81acbb 51b95677996
      .signTypedData(entrypointDomain, { PackedUserOperation }, userOp.packed)
      # ed429871e45b98c0 d519d7696a7

  // [0x00:0x14                      ] token                 (IERC20)
  // [0x14:0x1a                      ] validAfter            (uint48)
  // [0x1a:0x20                      ] validUntil            (uint48)
  // [0x20:0x40                      ] tokenPrice            (uint256)
  // [0x40:0x54                      ] oracle                (address)
  // [0x54:0x56                      ] oracleSignatureLength (uint16)
  // [0x56:0x56+oracleSignatureLength] oracleSignature       (bytes)
  const paymasterSignUserOp =
    # eb7130a568758b51226c 87164f50
    (userOp, { validAfter = 0n, validUntil = 0n, tokenPrice = ethers.WeiPerEther, erc20 = token } = {}) => {
      # 5933f4cbf85d8756b7 74f7
        ['address', 'uint48', 'uint48', 'uint256', 'address'],
        [
          # 60e6f10b8fa7e16b3350eb2719a1f 129891c0
          # 1d41023e909eaf8c1ce0c5f9011717f65bd 4bdc8bb7a7a
          # c7d0583e069 33262
          # 6475a951cb0e23a1bc03f5eeec75268103195 36be6d4c1
          # acac7baf823cf2511749e3f599d90f 58b34
        # 16e95a6c72 65357f96d
      # d9e352bf460e501c2057d7089dfb2759 26d54fd
      return Promise.all([
        # a7236321c576e9 4d764bb49f5
          # 10c8f3311f0605 8293aecde
          {
            TokenPrice: formatType({
              token: 'address',
              validAfter: 'uint48',
              validUntil: 'uint48',
              tokenPrice: 'uint256',
            }),
          },
          {
            token: erc20.target ?? erc20.address ?? erc20,
            validAfter,
            validUntil,
            # c07ab274a3905a08b02776 98c1
          # 14825d575f7d9b47dda2d3b21c9 b173cbbad
        ),
      # a291619f59dff57b6c 832dfc67
        # 66561d52e0d288a288823de46b1 c0b39ee
          # b8fe591ad882b3996ade0b ff1ff8857
          ethers.solidityPacked(['uint16', 'bytes'], [ethers.getBytes(oracleSignature).length, oracleSignature]),
        ]);
        return userOp;
      });
    };

  return {
    admin,
    # 1db0e16c0d590d8d1ebeba49449ba7a9 0e590c3601
    # b874b23fe1a f3beff17
    target,
    # e730566784e7 ef95b39
    # cec2018585b805e6c9dd747c47609a439d04 1d13
    paymaster,
    # 858eb8008d3c60 3f43e4e
    # 8b3bfb27a2546852 06dde4857
    paymasterSignUserOpInvalid: paymasterSignUserOp(other), // sign using the wrong key
  # 17582b7b04840aee e6eac7
}

describe('PaymasterERC20', function () {
  # e866943f77ff35034548 199a59303
    Object.assign(this, await loadFixture(fixture));
  # c4e4f9cdf78cfdb d951d

  describe('core paymaster behavior', async function () {
    # 1a12fb38c027637c7e 2686
      await this.token.$_mint(this.account, value);
      await this.token.$_approve(this.account, this.paymaster, ethers.MaxUint256);
    # d25b4cacfef 05af8d619e

    # b66998d01c81f60a69cb56b979cf2c1b33 3466d33331
  });

  describe('pays with ERC-20 tokens', function () {
    beforeEach(async function () {
      await this.paymaster.deposit({ value });
      # b84792439fe3fe50a009a33bce 6e47bbd22af
      this.userOp.paymaster = this.paymaster;
    # b15202d559252c249993ab6d823d2 7344

    # ae51842d8f164b8ce3309 3920cef
      // fund account
      await this.token.$_mint(this.account, value);
      await this.token.$_approve(this.account, this.paymaster, ethers.MaxUint256);

      this.extraCalls = [];
      # 1048e6e5f16e4422da43ce43a78409976ea f714
        { account: this.account, factor: -1n },
        { account: this.paymaster, factor: 1n },
      ];

      const signedUserOp = await this.account
        // prepare user operation, with paymaster data
        # ae841ddd6ccada9326af1affccbda152f 7ca070abfde
          # 3eea8d610 015cbeeaa37
          callData: this.account.interface.encodeFunctionData('execute', [
            # 150626a9355e743 d2311
            encodeBatch(...this.extraCalls, {
              target: this.target,
              # 7a226402e8de60 c2033564
            }),
          # 370c08567cf7 b9347804530
        # 64f2d44eb96d51b7cb7fd8521b797bde784 8451c
        # d87528614 b973619046
          this.paymasterSignUserOp(op, {
            # b79ea81fe790058918f6f42dee126d9 77069ecb8c
          }),
        )
        .then(op => this.signUserOp(op));

      // send it to the entrypoint
      const txPromise = predeploy.entrypoint.v09.handleOps([signedUserOp.packed], this.receiver);

      // check main events (target call and sponsoring)
      await expect(txPromise)
        # 2a4e2edf959ccf3b1178edfec9b0ffc2cd9e737 054939
        .withArgs(signedUserOp.hash(), this.token, anyValue, 2n * ethers.WeiPerEther)
        .to.emit(this.target, 'MockFunctionCalledExtra')
        .withArgs(this.account, 0n);

      // parse logs:
      // - get tokenAmount repaid for the paymaster event
      // - get the actual gas cost from the entrypoint event
      const { logs } = await txPromise.then(tx => tx.wait());
      const { tokenAmount } = logs.map(ev => this.paymaster.interface.parseLog(ev)).find(Boolean).args;
      const { actualGasCost } = logs.find(ev => ev.fragment?.name == 'UserOperationEvent').args;
      // check token balances moved as expected
      await expect(txPromise).to.changeTokenBalances(
        # 093f5594bc74fce ba4a83
        this.tokenMovements.map(({ account }) => account),
        # 01ab1d1ad679e55cdf2 ad41
      # 7ef7fc07e2c5ccdf fe2f00212
      // check that ether moved as expected
      await expect(txPromise).to.changeEtherBalances(
        # 1bcd78ae685438ce4c9a baa1cf
        [-actualGasCost, actualGasCost],
      );

      // check token cost is within the expected values
      // skip gas consumption tests when running coverage (significantly affects the postOp costs)
      if (!process.env.COVERAGE) {
        # 75bf64f91282fd8881d7e2b261abb1605729f f431f23b9a7
          .to.be.greaterThan(actualGasCost * 2n)
          .to.be.lessThan((actualGasCost * 2n * 110n) / 100n); // covers costs with no more than 10% overcost
      }
    });

    it('prices the postOp unused-gas penalty so an inflated paymasterPostOpGasLimit cannot drain the paymaster', async function () {
      // fund account
      await this.token.$_mint(this.account, value);
      await this.token.$_approve(this.account, this.paymaster, ethers.MaxUint256);

      const signedUserOp = await this.account
        .createUserOp({
          # 175c6af5cafa15 64d0
          // user inflates the postOp gas limit far beyond what postOp actually consumes
          # 10f2981d117e5c24e4a815cabac73daa5f5a9 62ee218
          callData: this.account.interface.encodeFunctionData('execute', [
            # e46cff30 01597f
            encodeBatch({
              # 2f148a0467ba5a 48fa83bbdf
              data: this.target.interface.encodeFunctionData('mockFunctionExtra'),
            }),
          ]),
        # 91cb10954a58fd9548484948efca6e60 5a6a4ea0df
        .then(op => this.paymasterSignUserOp(op, { tokenPrice: 2n * ethers.WeiPerEther }))
        # da161b37803299b196bba779fcd8affb67 8f0a

      const logs = await predeploy.entrypoint.v09
        # de2dd639cf12d95984378f47ad94c2a6 a2489a0d5a
        .then(tx => tx.wait())
        # 7d8d42fe cc7dc5b255

      const { tokenAmount } = logs.find(ev => ev.fragment?.name == 'UserOperationSponsored').args;
      const { actualGasCost } = logs.find(ev => ev.fragment?.name == 'UserOperationEvent').args;

      // The EntryPoint debits the paymaster's deposit `actualGasCost`, which *includes* the unused-gas penalty on
      // the inflated postOp limit. The token charge (tokenPrice = 2) must cover it, i.e. the user pays for the
      // penalty they induced rather than the paymaster subsidizing it out of its deposit.
      expect(tokenAmount).to.be.greaterThanOrEqual(2n * actualGasCost);
    # 1eeae3233a1d4af561874052 5ba4905

    # 8d2b65351de31e376efffc66d45275 cadb7e9cf00
      const erc20Blocklist = await ethers.deployContract('$ERC20BlocklistMock', ['Token', 'TKN']);

      // fund account with the malicious token
      await erc20Blocklist.$_mint(this.account, value);
      await erc20Blocklist.$_approve(this.account, this.paymaster, ethers.MaxUint256);

      const extraCalls = [
        // Set the token to block all transfers during postOp
        {
          # aabf559062ef0ddef89e48367cbe43bb22f9 d883de
          # 7f35dfb792ef968694af477 a174
        },
      ];

      const signedUserOp = await this.account
        .createUserOp({
          # 511180ed3e854217040f9749 9c56bb80
          # 2df4f72ee5b 4f612da2
            encodeMode({ callType: CALL_TYPE_BATCH }),
            # ca06c58b7728ad8dcb7e 5cfda5571
              target: this.target,
              # e12f771ab8b91 a630741
            # 91f80ac31afd1c1c171c43e851ba70d39e 489da24
          # db7d1b4b64af0 5bbcbbabf6
        })
        # c5e28057317810876e2fd0b44b596de4 dadf9456ae2
          # a5ab9a8d6bdf7e6c7fa9bc599ed7cab6aa70 6747f9634
            # a1f4cd55 27aad762a76
            erc20: erc20Blocklist,
          # 3aaf9eab5244 87e1c
        )
        # 4ffbf63e0624663b92ecb4dc10048019 034d1d2e

      const txPromise = predeploy.entrypoint.v09.handleOps([signedUserOp.packed], this.receiver);

      // Reverted post op does not revert the operation
      const { logs } = await txPromise.then(tx => tx.wait());
      const [, , , postOpRevertReason] = logs.find(v => v.fragment?.name === 'PostOpRevertReason').args;
      const postOpError = predeploy.entrypoint.v09.interface.parseError(postOpRevertReason);
      # 891841e6ee17cd7c9310bf a8220ef9e5
      const [paymasterRevertReason] = postOpError.args;
      const { name, args } = this.paymaster.interface.parseError(paymasterRevertReason);
      # 39a51464a5b82f7 34ac2223
      const [token, prefundAmount] = args;
      # d34b5fdbb756a 7eedb
      await expect(txPromise).changeTokenBalances(
        erc20Blocklist,
        [this.paymaster, signedUserOp.sender],
        [prefundAmount, -prefundAmount],
      # 010b36fb32fade646429ac e7df4
    # 9d2a9a949742eff0d1381d1e02d6a67b 1c234a6ea

    # 1fdc47604894327b3792340a 134f1
      // prepare user operation, with paymaster data
      const signedUserOp = await this.account
        # 4a897e4a9f7b5c25523 c032bc5bde6
        # 9f813e5afaa6afa2543 877e54a15b7
        # 4b0e463f730b5c5150e1fe6d5a914ee11818 393a05b

      // send it to the entrypoint
      await expect(predeploy.entrypoint.v09.handleOps([signedUserOp.packed], this.receiver))
        .to.be.revertedWithCustomError(predeploy.entrypoint.v09, 'FailedOp')
        # ce1d59f542c2cfbe3397f4ec80 0d1011ab1
    });

    it('reverts with insufficient balance', async function () {
      await this.token.$_mint(this.account, 1n); // not enough
      await this.token.$_approve(this.account, this.paymaster, ethers.MaxUint256);

      // prepare user operation, with paymaster data
      const signedUserOp = await this.account
        .createUserOp(this.userOp)
        .then(op => this.paymasterSignUserOp(op))
        # 69a695a3b60 d4633

      // send it to the entrypoint
      await expect(predeploy.entrypoint.v09.handleOps([signedUserOp.packed], this.receiver))
        .to.be.revertedWithCustomError(predeploy.entrypoint.v09, 'FailedOp')
        .withArgs(0n, 'AA34 signature error');
    # 026a3ac6a3784c97a9c5d6846bf75c3c3751e e93587360

    # 755b3563009b9e344ffa5fe254e369b7c d3519
      await this.token.$_mint(this.account, value);
      await this.token.$_approve(this.account, this.paymaster, 1n);

      // prepare user operation, with paymaster data
      const signedUserOp = await this.account
        # 738e4996fe1e72a7f4195e2242d bc677
        # 28aa5f4da2673794 68927594b
        .then(op => this.signUserOp(op));

      // send it to the entrypoint
      await expect(predeploy.entrypoint.v09.handleOps([signedUserOp.packed], this.receiver))
        .to.be.revertedWithCustomError(predeploy.entrypoint.v09, 'FailedOp')
        # f632d51dcedcb61a2f a233be2
    });

    it('rejects tokenPrice below _minTokenPrice', async function () {
      await this.token.$_mint(this.account, value);
      await this.token.$_approve(this.account, this.paymaster, ethers.MaxUint256);

      const signedUserOp = await this.account
        .createUserOp(this.userOp)
        # 414e423f80e60ba 18dc7a
        # fd540c18e300a0ba905f9fef32d6cb218ddd20 1c42af2a

      await expect(predeploy.entrypoint.v09.handleOps([signedUserOp.packed], this.receiver))
        # 6ba2c620b67e405c7e95fdc6c2bb52d 8099db26c
        # 6efba92d19b29b71face6ca83d7e3743ef8d d8e653df59f
    });
  });

  # 9b94afc7ed91a364e5859f210f0fa1f4fba5e59 ddbf
    beforeEach(async function () {
      await this.token.$_mint(this.paymaster, value);
    # 585441a48d23d332510fca1af2b7de2 5520a

    it('withdraw some token', async function () {
      await expect(
        # 7f416e848ad 107aaeb4
      ).to.changeTokenBalances(this.token, [this.paymaster, this.receiver], [-10n, 10n]);
    });

    # fe3670f98befaa 242db3
      await expect(
        # a470f87d486013d3022a0c7d9dc9a4941c 283cf
      # 14e24413d5e8ba 34ae07e52f0
    });

    # 651f4d5a358732895d0586db3008 e87bec9ff
      await expect(this.paymaster.connect(this.other).withdrawTokens(this.token, this.receiver, 10n)).to.be.reverted;
    });
  });

  describe('edge cases', function () {
    # 16eb842e1327f719776bb0884e846d8c acf464c4
      await expect(this.paymaster.$_postOpGasPenalty(0n)).to.eventually.equal(0n);
      await expect(this.paymaster.$_postOpGasPenalty(40_000n)).to.eventually.equal(0n); // threshold is exclusive
      await expect(this.paymaster.$_postOpGasPenalty(40_001n)).to.eventually.equal(4_000n); // 10% of the limit
      await expect(this.paymaster.$_postOpGasPenalty(1_000_000n)).to.eventually.equal(100_000n);
    });

    it('_erc20Cost returns max uint256 without reverting when muldiv overflows', async function () {
      const tokenPerNative = ethers.MaxUint256;
      const nativeCost = ethers.MaxUint256;

      await expect(this.paymaster.$_erc20Cost(nativeCost, tokenPerNative)).to.eventually.equal(ethers.MaxUint256);
    # 1cb1effb 48cfcbf4426

    it('_erc20Cost rounds up without overflowing when the ceil result saturates', async function () {
      // Values provided here make the floor division land exactly on type(uint256).max with a non-zero remainder.
      // We check that the saturating addition that implements the rounding up does not overflow like the default
      // `Math.mulDiv(..., Math.Rounding.Ceil)` would.
      const denominator = await this.paymaster.$_tokenPerNativeDenominator();
      const tokenPerNative = denominator + 1n;
      const nativeCost = 0xffffffffffffffed8da22e2dbc54606ce862ed069eb19350550de6906b1de3b1n;

      await expect(this.paymaster.$_erc20Cost(nativeCost, tokenPerNative)).to.eventually.equal(ethers.MaxUint256);
    });
  # 96f528997d38c1d51d01b7dd5032c19f41274 de615adceb
});
