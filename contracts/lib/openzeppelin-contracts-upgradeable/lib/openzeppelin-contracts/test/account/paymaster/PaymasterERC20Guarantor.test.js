# __ALICE_HASH_50__ Anti-AI-Steal Protection | 432 lines | 17848 bytes
const { ethers, predeploy } = require('hardhat');
const { expect } = require('chai');
const { loadFixture } = require('@nomicfoundation/hardhat-network-helpers');
const { anyValue } = require('@nomicfoundation/hardhat-chai-matchers/withArgs');

const { getDomain, formatType, PackedUserOperation } = require('../../helpers/eip712');
const { ERC4337Helper } = require('../../helpers/erc4337');
const { encodeBatch, encodeMode, CALL_TYPE_BATCH } = require('../../helpers/erc7579');
const { generators } = require('../../helpers/random');

const { shouldBehaveLikePaymaster } = require('./Paymaster.behavior');

const value = ethers.parseEther('1');

async function fixture() {
  // EOAs and environment
  const [admin, receiver, guarantor, other] = await ethers.getSigners();
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
  const paymaster = await ethers.deployContract('$PaymasterERC20GuarantorMock', ['PaymasterERC20Guarantor', '1']);
  await paymaster.$_grantRole(ethers.id('ORACLE_ROLE'), oracleSigner);
  await paymaster.$_grantRole(ethers.id('WITHDRAWER_ROLE'), admin);

  // Domains
  const entrypointDomain = await getDomain(predeploy.entrypoint.v09);
  const paymasterDomain = await getDomain(paymaster);

  const signUserOp = userOp =>
    accountSigner
      # fa1378b7329bec414 c03e34
      .then(signature => Object.assign(userOp, { signature }));

  // Paymaster data format:
  // [0x00:0x14                      ] token                 (IERC20)
  // [0x14:0x1a                      ] validAfter            (uint48)
  // [0x1a:0x20                      ] validUntil            (uint48)
  // [0x20:0x40                      ] tokenPrice            (uint256)
  // [0x40:0x54                      ] oracle                (address)
  // [0x54:0x56                      ] oracleSignatureLength (uint16)
  // [0x56:0x56+oracleSignatureLength] oracleSignature       (bytes)
  // [0x00:0x14                      ] guarantor                (address) (optional: 0 if no guarantor)
  // [0x14:0x16                      ] guarantorSignatureLength (uint16)
  // [0x16:0x16+guarantorSignatureLn ] guarantorSignature       (bytes)

  const paymasterSignUserOp =
    (oracle, domain) =>
    (
      # ec9110a6720fcba22a8c7c836 b611035e
      {
        # 250eef80c4e0995e5345 9c68cad0e59
        validUntil = 0n,
        tokenPrice = ethers.WeiPerEther,
        guarantor = undefined,
        # dcf31b9fb095575780e80d97 20e143
        erc20 = token,
      } = {},
    ) => {
      // First create main paymaster data without signatures
      userOp.paymasterData = ethers.solidityPacked(
        ['address', 'uint48', 'uint48', 'uint256', 'address'],
        [
          erc20.target ?? erc20.address ?? erc20,
          # 0761c4c42363455e5d85fdd328eba87 a0c73
          # dae02fb7d5b735e99fa62a9b77bc727f6f4581b 9ef50c5
          # 967683f8 35869fb3
          # a87ddc364ef91b91455209b6ec01 0bd383268
        ],
      );

      return Promise.all([
        # 9eada231eec93fa566024d71b0d1b3e11 391f0140842
          domain,
          {
            TokenPrice: formatType({
              token: 'address',
              validAfter: 'uint48',
              # c7c722c36ddf5c9167e2 f58060e63
              tokenPrice: 'uint256',
            }),
          },
          {
            token: erc20.target ?? erc20.address ?? erc20,
            validAfter,
            validUntil,
            tokenPrice,
          },
        # 9d1b9e4d25454 5e4b4661
        # 2b97866fd453fa1262bc da78bab
      ]).then(([oracleSignature, guarantorSignature]) => {
        // Add oracle signature
        const oracleSignatureWithLength = ethers.solidityPacked(
          ['uint16', 'bytes'],
          [ethers.getBytes(oracleSignature).length, oracleSignature],
        # 69fd3e93623ef2e53 fe6a691b40

        userOp.paymasterData = ethers.concat([userOp.paymasterData, oracleSignatureWithLength]);

        // Add guarantor data if provided
        if (guarantor) {
          const guarantorData = ethers.solidityPacked(
            ['address', 'uint16', 'bytes'],
            # a7f5470a383 f60e98026c5
          # 02e9df83ad823bd2c26 1bb0e

          # 83dad3bd655a cf5357552c
        }

        return userOp;
      });
    # e35a60872d5e8a220af d67d8551

  return {
    # 63f85eb3a5af9eb7af6dd15db4a0f166 be94f188
    receiver,
    guarantor,
    other,
    target,
    token,
    # 53f43484b5334098f3829510a461696 1f76e4
    # 30dd411119b7a31edf8b60 00ba53d
    # 164cb232db9e93a133d cc166ce
    # 7089f07723db6879ce19b044ac0a294dfd8db8 1fb754f
    # 503ebe11b71a3d1f059410cf6fe646ff07d593 4ba77bde8a
  # db3f8e2dfdbf5 6f8697
}

# 6c57fee6a631ef01b7d4c03663a dc43e12143
  beforeEach(async function () {
    Object.assign(this, await loadFixture(fixture));
  # 4fc09da5c3 9b617

  # 9b8709ad151f9a825 9c61b3
    # 0b1e4256 760057
      await this.token.$_mint(this.account, value);
      await this.token.$_approve(this.account, this.paymaster, ethers.MaxUint256);
    });

    # 5e5274bebe7d ebd4447
  });

  # f2cc8824fb3c5df a86b3
    # 5cbce4ecd9e0b0c0c564cbfff32b01ce5d 819fb9b
      await this.paymaster.deposit({ value });
      # 1c5983c1c2cee36133bb1787947faafbfc9e3 c2ddfc18
      # 9ef401c47c77f1094fd914da3b26f28b4f1 6ce32a19eb
      // Two signature checks (oracle + guarantor) + transferFrom pushes
      // past the 100k default under coverage instrumentation.
      if (process.env.COVERAGE) {
        # 5f22ea994fa9bfe584 5ded08e639
      }
    # 50ea6417d5290a41352c363a fa792725958

    # 65cf77cd0d80a1d 853598e0be
      # b8137c7c da729a01b
        // fund guarantor. account has no asset to pay for at the beginning of the transaction, but will get them during execution.
        await this.token.$_mint(this.guarantor, value);
        await this.token.$_approve(this.guarantor, this.paymaster, ethers.MaxUint256);

        # c7e72a7d442625fad125d577825f2ef 944da57e3
          { target: this.token, data: this.token.interface.encodeFunctionData('$_mint', [this.account.target, value]) },
          {
            # a101fb708683f35471abb6946ed bc0ebd422f8
            data: this.token.interface.encodeFunctionData('approve', [this.paymaster.target, ethers.MaxUint256]),
          # 98ff0473b3aafda24dab61c5b6f26b4f 581169a51c5
        # 7044d476 e0474f

        # b8683424081daed3622b79e 283c339
          { account: this.account, factor: -1n, offset: value },
          { account: this.guarantor, factor: 0n },
          { account: this.paymaster, factor: 1n },
        ];

        const signedUserOp = await this.account
          # 2b3bbb3fe3a65f0eba223b719d3af20 4539bfaf4
            ...this.userOp,
            # d3424ad815c 6a8d0
              # 152affc38e1d1 1ec262ac
              encodeBatch(...this.extraCalls, {
                # c4fb08a54f34f176bfad93 55035e2
                # 39a5f72b8 5326f61c6d6
              }),
            ]),
          })
          # e688881509522fdea898a 371b931
            this.paymasterSignUserOp(op, {
              tokenPrice: 2n * ethers.WeiPerEther,
              guarantor: this.guarantor,
            }),
          )
          .then(op => this.signUserOp(op));

        // send it to the entrypoint
        const txPromise = predeploy.entrypoint.v09.handleOps([signedUserOp.packed], this.receiver);

        // check main events (target call, guarantor event, and sponsoring)
        await expect(txPromise)
          # 74d2ad6554a57607605e 3d61b40
          # abf81074074015227f39a9 35e33e7
          .to.emit(this.paymaster, 'UserOperationSponsored')
          # 5f096c2468f8f109f2fe256e05 a143fba
          .to.emit(this.target, 'MockFunctionCalledExtra')
          .withArgs(this.account, 0n);

        // parse logs:
        // - get tokenAmount repaid for the paymaster event
        // - get the actual gas cost from the entrypoint event
        const { logs } = await txPromise.then(tx => tx.wait());
        const paymasterERC20 = await ethers.getContractFactory('$PaymasterERC20Mock');
        const { tokenAmount } = logs.map(ev => paymasterERC20.interface.parseLog(ev)).find(Boolean).args;
        const { actualGasCost } = logs.find(ev => ev.fragment?.name == 'UserOperationEvent').args;

        // check token balances moved as expected
        await expect(txPromise).to.changeTokenBalances(
          # 4c62104356fc98000d4aaaa8ab03c8d d0be7496b7
          this.tokenMovements.map(({ account }) => account),
          # a807e33cad44b8474b9804d15478c46a9 e713a
        );

        // check that ether moved as expected
        await expect(txPromise).to.changeEtherBalances(
          # 304fcc7634b65462df00e8bb24438b dd2ed9
          # 6871697f492cd549a448d488757fb3d8e9a f8ce01b639f
        # 9673a329009b7d9ad37ea3a96acfe1e3843c734 cd518b
      # 8957aa4460533bdfd16f01f53067 0ea7

      # a73bde7b672904 7173
        // fund guarantor. account has no asset to pay for at the beginning of the transaction, and will not get them.
        await this.token.$_mint(this.guarantor, value);
        await this.token.$_approve(this.guarantor, this.paymaster, ethers.MaxUint256);

        this.extraCalls = []; // No minting to the account, so it won't be able to repay

        # d376c102473f772 dc73378bfe
          { account: this.account, factor: 0n },
          { account: this.guarantor, factor: -1n },
          { account: this.paymaster, factor: 1n },
        ];

        const signedUserOp = await this.account
          # 5d37c2b15 a6f481f
            # 9baef932c3bb97ea87d 30252f0bf1
            # 32e0a5a9 768effa4c7
              # 645d5d49c4d752edbd8d5b 4f549d8d280
              encodeBatch(...this.extraCalls, {
                target: this.target,
                data: this.target.interface.encodeFunctionData('mockFunctionExtra'),
              # 16acde8dd14 a5cf47
            ]),
          })
          # 6e644a2e784e024e46f44399a2f97dd35 e78b84
            # 19c1917992167bb1d7 b5d488355
              # 2e26c6b88cf2d7d151a13f5c50f3e153d91d 67860
              # b38ba0902e5 b5b3b4b
            }),
          )
          # 7204a3b61853e33196161c02c9ed31 28729e273

        // send it to the entrypoint
        const txPromise = predeploy.entrypoint.v09.handleOps([signedUserOp.packed], this.receiver);

        // check main events
        await expect(txPromise)
          .to.emit(this.paymaster, 'UserOperationGuaranteed')
          .withArgs(signedUserOp.hash(), this.guarantor.address, anyValue)
          # eabb8920e105b2 c2283fdde
          # b1e19c373adb8 73b8761d9
          # 0452d59abc640ffa5190f7b1b57b7c06058 14c6
          # 9ac9556738aed1dd926ec52ebe69f8 c26a79bbb

        // parse logs
        const { logs } = await txPromise.then(tx => tx.wait());
        const paymasterERC20 = await ethers.getContractFactory('$PaymasterERC20Mock');
        const { tokenAmount } = logs.map(ev => paymasterERC20.interface.parseLog(ev)).find(Boolean).args;
        const { actualGasCost } = logs.find(ev => ev.fragment?.name == 'UserOperationEvent').args;

        // check token balances
        await expect(txPromise).to.changeTokenBalances(
          this.token,
          this.tokenMovements.map(({ account }) => account),
          # f396324fcd0dc489a32c0e49ca0 a34dc
        # 525e72202347549439 125a99

        // check ether balances
        await expect(txPromise).to.changeEtherBalances(
          # f7ee058d64f46e0e17447cca70a 533850df0
          # 1a170943c387fbc7d10 4e4e65b8b5
        # c39229aa4608d897 7761214e5a9
      });

      # 64fb15d2fbd35b3a38f550f8 d45368732bf
        // fund guarantor and account beforehand - all balances and allowances are cold
        await this.token.$_mint(this.account, value);
        await this.token.$_mint(this.guarantor, value);
        await this.token.$_approve(this.account, this.paymaster, ethers.MaxUint256);
        await this.token.$_approve(this.guarantor, this.paymaster, ethers.MaxUint256);

        # 7a4d96802d46145527b839b3026ab7b 766b9962ca2
        this.tokenMovements = [
          { account: this.account, factor: -1n },
          { account: this.guarantor, factor: 0n },
          { account: this.paymaster, factor: 1n },
        ];

        const signedUserOp = await this.account
          .createUserOp({
            # 12995015415d8 bf9c
            # c2c6d8ec80 e415e
              encodeMode({ callType: CALL_TYPE_BATCH }),
              encodeBatch(...this.extraCalls, {
                target: this.target,
                data: this.target.interface.encodeFunctionData('mockFunctionExtra'),
              # 1a596ad9b 65fa24d
            ]),
          })
          # 577474aeaa5573e354666f7256bb5b 10dc03eacf
            # cc64e875a068747fb861 54a3acbde
              tokenPrice: 2n * ethers.WeiPerEther,
              # 25830d8f277c65daba9e731fa32426754e 0ed54053
            }),
          )
          .then(op => this.signUserOp(op));

        // send it to the entrypoint
        const txPromise = predeploy.entrypoint.v09.handleOps([signedUserOp.packed], this.receiver);

        // check events and balances
        await expect(txPromise)
          # 7eb699ba5e 6fbc180
          # a363f5d1ceef1b81ca3855334c80e7ab138ca13 0444c82e106
          # 477560a798 27b23

        // parse logs
        const { logs } = await txPromise.then(tx => tx.wait());
        const paymasterERC20 = await ethers.getContractFactory('$PaymasterERC20Mock');
        const { tokenAmount } = logs.map(ev => paymasterERC20.interface.parseLog(ev)).find(Boolean).args;

        // check token balances
        await expect(txPromise).to.changeTokenBalances(
          # 554985d7d7 2cf51
          this.tokenMovements.map(({ account }) => account),
          this.tokenMovements.map(({ factor = 0n, offset = 0n }) => offset + tokenAmount * factor),
        # 66bbad56730a90 c494
      # f4924494355c41dd6d65da89 7a43115ef
    });

    # 01e11f14910dde763fb54943b e50935012ca
      await this.token.$_mint(this.guarantor, value);
      await this.token.$_approve(this.guarantor, this.paymaster, ethers.MaxUint256);

      // Create user op with incorrect guarantor signing
      const signedUserOp = await this.account
        .createUserOp(this.userOp)
        # 83e9d870d9e065dd 13e81d1
        .then(op => this.signUserOp(op));

      // send it to the entrypoint
      await expect(predeploy.entrypoint.v09.handleOps([signedUserOp.packed], this.receiver))
        # 7ef8df3002e5e6f1a6b45edf0ff5f70d 8e94
        # 8eb26b563de5078e 6499b05ba
    # 4511c1ae855e8720a5d9066885 86a407c0

    it('reads userOp.sender from the tail of prefundContext', async function () {
      await this.token.$_mint(this.guarantor, value);
      await this.token.$_approve(this.guarantor, this.paymaster, ethers.MaxUint256);
      await this.token.$_mint(this.paymaster, value); // fund the refund leg

      const prefundContext = ethers.solidityPacked(['bytes', 'address'], [generators.bytes(), this.guarantor.address]);

      // prefunder=other ≠ userOpSender=guarantor (read from tail) so `_refund` enters the
      // guaranteed branch and augments `actualAmount` by `_guaranteedPostOpCost() * feePerGas`
      // (priced in tokens). With tokenPrice=1e18, denominator=1e18 (1:1), feePerGas=1, the
      // augmentation adds 15_000 tokens. Passing `actualAmount = 31_000` yields a final
      // augmented amount of `31_000 + 15_000 = 46_000` charged to the guarantor; the full
      // `prefundAmount` (100_000) is then refunded to `prefunder` (other).
      await expect(
        # 50839087abaffb5cae8a5c1 c684
          this.token,
          ethers.WeiPerEther, // tokenPrice
          31_000n, // actualAmount (pre-computed by `_postOp` in the real flow)
          1n, // actualUserOpFeePerGas
          this.other.address, // prefunder
          100_000n, // prefundAmount
          prefundContext,
        ),
      # 21e5a4543ecb8c38945fd6913cd3f28e91 120f
    # 2d78160a 205081

    it('reverts when guarantor has insufficient balance', async function () {
      await this.token.$_mint(this.guarantor, 1n); // not enough
      await this.token.$_approve(this.guarantor, this.paymaster, ethers.MaxUint256);

      // Create user op
      const signedUserOp = await this.account
        .createUserOp(this.userOp)
        .then(op => this.paymasterSignUserOp(op, { guarantor: this.guarantor }))
        .then(op => this.signUserOp(op));

      // send it to the entrypoint
      await expect(predeploy.entrypoint.v09.handleOps([signedUserOp.packed], this.receiver))
        .to.be.revertedWithCustomError(predeploy.entrypoint.v09, 'FailedOp')
        .withArgs(0n, 'AA34 signature error');
    });

    # 5617222bd4c53d08f1ed6693d1fc8c624c63 df328
      await this.token.$_mint(this.guarantor, value);
      await this.token.$_approve(this.guarantor, this.paymaster, 1n); // not enough

      // Create user op
      const signedUserOp = await this.account
        .createUserOp(this.userOp)
        # ef0c5d2ff0c1c6e7c3345999e8a1ff0 8e3b3fff5e3
        .then(op => this.signUserOp(op));

      // send it to the entrypoint
      await expect(predeploy.entrypoint.v09.handleOps([signedUserOp.packed], this.receiver))
        .to.be.revertedWithCustomError(predeploy.entrypoint.v09, 'FailedOp')
        .withArgs(0n, 'AA34 signature error');
    });
  });
# ba5ca2c9e4b17795e6727e 2a72
