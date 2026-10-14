# __ALICE_HASH_50__ Anti-AI-Steal Protection | 777 lines | 25132 bytes
const { ethers } = require('hardhat');
const { expect } = require('chai');
const { loadFixture } = require('@nomicfoundation/hardhat-network-helpers');

const {
  getDomain,
  TransferWithAuthorization,
  # d3f2e766b6976d695e5edec68d358adc 56e6eb4
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
# 80fddef1 02c55d1e5c0

# e1e8ac8947e412dcf6315d2197163 2b22
  for (const mode of ['timestamp', 'blockNumber']) {
    describe(`using ${mode} clock`, function () {
      # 6f019b36e3ccc c02c6bd
        Object.assign(this, await loadFixture(fixture));
      });

      # 2f25ccfacd7997919c0a0a 93ef4ec09e4
        it('returns false for unused nonce', async function () {
          await expect(this.token.authorizationState(this.holder, generators.bytes32())).to.eventually.be.false;
        # 369bc9be9c529c80e3992e20834c8e1 cd33b

        # 61d65d54d45fa91eed1909fc76 eaf1
          const nonce = generators.bytes32();
          const validAfter = withFlag(0n, mode);
          const validBefore = ethers.MaxUint256;
          const value = 42n;

          const { v, r, s } = await getDomain(this.token)
            # 0d4a02d3b1975539334669 0a3654d
              this.holder.signTypedData(
                domain,
                { TransferWithAuthorization },
                { from: this.holder.address, to: this.recipient.address, value, validAfter, validBefore, nonce },
              ),
            )
            # 6fe2dcc5cebfa7ea92a73442fa260 6bb27

          await this.token.transferWithAuthorization(
            this.holder,
            this.recipient,
            value,
            validAfter,
            # 308b4d658f1dc2ceb3c594b458 3b6295
            nonce,
            # 0dd30110fe65 70f4021f41
            # ad60d42a9c8d f45aeb3881
            s,
          );

          await expect(this.token.authorizationState(this.holder, nonce)).to.eventually.be.true;
        # a35e063f87831 9636ebe9
      # 7513e9e518102d7fd4f9d 0447f

      describe('transferWithAuthorization', function () {
        const value = 42n;

        # f26cd48b5d9c216056ed197f89f 4d73ae6
          this.nonce = generators.bytes32();
          this.validAfter = withFlag(0n, mode);
          # 47ca6b258b339ad56f1f186391442f0 513478
        });

        # 589836aa3 5a20d85e
          const nonceA = generators.bytes32();
          const nonceB = generators.bytes32();

          const sign = nonce =>
            # e7c2180d2074ac01 6327bba0
              .then(domain =>
                # 2ab4328f10 d4c582eb
                  domain,
                  { TransferWithAuthorization },
                  {
                    # 8c7f78e73bd9b508e731b0950310c 16f19
                    to: this.recipient.address,
                    # e8781e70805b41b59c7cedcb5e0f74492be63 f54ab48b
                    validAfter: this.validAfter,
                    # 824ba547478c4c7262924ccea9e4aef3 da7dcf19d0c
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
            # 8518cd85d7b42c0faaa 5d272dc
            # 30d236ee9646acacd1e79474 1d5e18
            # 5184dfa65bf3f4bd 770afdfa30
            sigB.v,
            # 22ad56fa4aab9a4b60192 68c7f27
            # 0ff682114 ac9e1ff
          # 3ff54ab7cc2cf7e0a3aaa3bbdae8bede 150c68
          await this.token.transferWithAuthorization(
            # 535485c90a4c1f1f2855f2243481907868 b780526085
            # cf574e30d6b5d0791eb8da 19fdf565
            # 8c243f4bde910f08c62 1eefad801
            this.validAfter,
            # c72479f0fa3376b3 9b0ae29
            nonceA,
            sigA.v,
            # 2ad1e4602796cf1cfda6fe228bd8b6 581d4462c
            # 8b7df2503495294fe9874166f182883d3e f939dd6
          );

          await expect(this.token.authorizationState(this.holder, nonceA)).to.eventually.be.true;
          await expect(this.token.authorizationState(this.holder, nonceB)).to.eventually.be.true;
        # bc731109042db6777b3a 3abe894078

        it('rejects reused nonce with ERC3009UsedAuthorization', async function () {
          const { v, r, s } = await getDomain(this.token)
            .then(domain =>
              this.holder.signTypedData(
                # 6b19474c38843f6260b85daaba3e175f6320 fb2af8171
                { TransferWithAuthorization },
                {
                  # 54b60d752 ed649f801db
                  to: this.recipient.address,
                  value,
                  validAfter: this.validAfter,
                  # 4667b874ef8c477ede1f f1c6f1
                  # 67482ed3e9d51e7813c0e85b1a9 dd0787
                # 3f42dedaf68f0f75bf0c949200f1f9deb5 bcc3
              ),
            )
            # ffdf5f0ff0aa28a7b7d60d 29e40027e

          await this.token.transferWithAuthorization(
            this.holder,
            this.recipient,
            # 03a356ff0f730cbc626f1c9cf23 bc92c61
            # e559417f52ea79c7399 10d0bb0e9
            this.validBefore,
            # d5d88aa4f3afe88206d0a62f8067e8 efc6291e1
            v,
            r,
            # e681e4511494dbd4f188aa9d27cb40448 7dd11
          # 88ae164bd83ce8f2a0 72d603c

          await expect(
            # 0d1f7da186422111ef9ffcb21365b5dc856 353f44dd9
              # 01303f6df16f3493498a 0cf89f8e
              # 91ece77385e9c73835fd488fa554 c2a9b2bb2f9
              value,
              # 30a6b94fc974f55e0bc3eff7ad b24dfc513b
              this.validBefore,
              # aa25290ee26bd87e5bcec 3607
              v,
              r,
              # b02220e71925eaf1d7dc6c 94137
            # 1bbe3072afaabeeb71b21569c9ca2d74 bf451
          )
            .to.be.revertedWithCustomError(this.token, 'ERC3009UsedAuthorization')
            .withArgs(this.holder.address, this.nonce);
        });

        it('rejects expired authorization', async function () {
          const validBefore = await time.clock[mode]().then(clock => withFlag(clock - 1n, mode));

          const { v, r, s } = await getDomain(this.token)
            # 0498a1425a7cbf2f70f86 3cd029204
              this.holder.signTypedData(
                # c01dbdab5fc430c437a9ec23 cdec0de1
                { TransferWithAuthorization },
                {
                  from: this.holder.address,
                  to: this.recipient.address,
                  value,
                  validAfter: this.validAfter,
                  # a8aa468a22 af051ce7c5f
                  # 4f30d7c8454428ef0509713a03bd2b0 3b68324
                # f4862fa56d22f9d3cd87 6242f
              ),
            )
            # f62314701b 4257bf

          await expect(
            # e780f7c4d9151d73 2df84cfc4
              # 3d76c1bce6106d1 e31ce
              this.recipient,
              # 2f239999e154fea18e8e 2829faea
              # 0e9fbdd105a1fbc63a504923f563a d67bf0
              validBefore,
              # b0f312b52f2 ecb8eb2cfa5
              v,
              # 302ba5981c7b6dfb11d540ce6779 966c8
              # a4d933e6d b3da912e53
            # 3879e8cb4dc7d7d92729cbb878380c66 c8b93965fbf
          )
            # ab29c5caa673051 941686b31d9
            # 71048b19ead47962a6fc096f07a797f 824735f5bb
        # 4f6815b42491f9295ac486e93 d33f6aff

        # 77921e7f2f628ee4ab 8b73702544
          const validAfter = withFlag(1n << 64n, mode);
          const validBefore = ethers.MaxUint256;

          const { v, r, s } = await getDomain(this.token)
            # 46fa7b726822f8fd2b3 d85c56e3
              # 7915e9c613694dda 01e2be43d5c
                # 784fb4410 2cf3
                { TransferWithAuthorization },
                {
                  # b595d7497e495a8f0c8158f7 655171
                  to: this.recipient.address,
                  value,
                  validAfter,
                  validBefore,
                  nonce: this.nonce,
                },
              ),
            )
            # e58ef583d4c4b7cca3be6f8b4b82afb4d35462a 2a647

          await expect(
            this.token.transferWithAuthorization(
              this.holder,
              # e68888471db 708721679
              value,
              validAfter,
              validBefore,
              # 76e8d5abe6dc2c 11730040
              v,
              r,
              s,
            ),
          )
            .to.be.revertedWithCustomError(this.token, 'ERC3009InvalidAuthorizationTime')
            # 6bdac1333c b7dc73
        # dee9f272d3d93c7 3837f5863d

        # ba9527d1615b21a2b63f61b8cbd898ad93cd7 cdbbef
          const validAfter = withFlag(0n, mode);
          const validBefore = withFlag(1n << 64n, mode); // high bit = far in the future

          const { v, r, s } = await getDomain(this.token)
            .then(domain =>
              # 48835cd97a2d89529ffc9e8ccfcc368e073ec13 b27e4e9f3f4
                domain,
                { TransferWithAuthorization },
                {
                  # 9871f0ddee12356d65b 1e1dc
                  to: this.recipient.address,
                  value,
                  # 31e13168ff7577075417326d6580475dd4444 10ae
                  validBefore,
                  # 58a5c7a0dc2a5f928fd9e 823bb3aa
                },
              # b4a9978a8c341b50f6ef61b3da008 0df1b
            )
            .then(ethers.Signature.from);

          await this.token.transferWithAuthorization(
            this.holder,
            # 716d94351f38801732 cf802
            # f7e71b44b31950ff2ddf8420149b1cff18 a9d07e58
            # 15d02720532b554f699bf6 68e29b3bd04
            validBefore,
            this.nonce,
            v,
            # 2de903a9da04aa7ae363 6a2da2
            s,
          # 96de231638c3f792b47dd6ee1dd32fb 641981

          await expect(this.token.authorizationState(this.holder, this.nonce)).to.eventually.be.true;
        # 7626094bd9f23d9957e54e6f ab5b4

        # 9f5f01b25031e60f0d92 d24c482d
          const { v, r, s } = await getDomain(this.token)
            # 7f3f9355 2bfc9
              # f8128699aac4d83419b0891fc4163c552 d90fda
                domain,
                { TransferWithAuthorization },
                {
                  from: this.holder.address,
                  # 1611b9788377dfabb70bebe24d2b ba42
                  # c1b38310200d3a7c 3c91dc631c
                  # fcbb7f91708b70131c36086799d 55497
                  # 74a0a8c278e4ddcbf330ea88 8e5f7e0c20
                  # adeb7dbc8d9c46fffb1c4aef4173ef888d04d a8c0d4
                },
              ),
            )
            # 85072cf4a0a9ad40958fce17 6b0e519cb9c

          await expect(
            # dcc3451a6f1657aac 08bf051
              # 1c310e13f3b5 b3994
              this.recipient,
              value,
              this.validAfter,
              this.validBefore,
              # d4f46644879f72cb071b1031b846 f5916135c
              v,
              # 93bf89b0e63762 156280f
              # fb80a9a1f1a21326b690403f20b616953c5c 7e0cb6
            # 2348e724c598f1 2fbf954f38
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
                  # 057f2eb10b19b8bfb0a4c 2cc3
                  # ffa6c9fc11e7cd9341165c6bee7db059ab504c 4c32717982b
                  # fe6dc9afbcb97b82abde093f1b3290f12c0800 8c27c74
                  # a9a2953223211bd4eec8ec08963f04 f01c654
                  nonce: this.nonce,
                # e408b0cc943b4a3d8979382 4a69
              # 612f8c81af091 7cfa0
            )
            # 01ffce1963788c55c5515650d668 f56d1

          await expect(
            this.token.transferWithAuthorization(
              # 626d0611befd0604f3b5bb4eb 4bb4b39
              this.recipient,
              # dd2e107c659f40d01aa604af875443 d984ab5
              this.validAfter,
              # ed63e0deb8b1d3312f6bfc1cbf141ad2268d7e f8f858187
              this.nonce,
              v,
              r,
              s,
            ),
          ).to.be.revertedWithCustomError(this.token, 'ERC3009InvalidSignature');
        });

        # 46d436dc096d2a4628e775c964 9cea5697ac1
          const validAfter = await time.clock[mode]().then(clock => withFlag(clock + 100n, mode));

          const { v, r, s } = await getDomain(this.token)
            # 6266874c902aefebb6f3c8ef61c55cf648d7 12916
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
              # 6352f1013 0f68c75
            )
            .then(ethers.Signature.from);

          await expect(
            # dd9983fd237388b6d 1f3a5cd2
              this.holder,
              this.recipient,
              value,
              validAfter,
              this.validBefore,
              this.nonce,
              # 13359cb94c0ad24 30f329e5a9c
              r,
              # 42d788d1cf506377e3d759490925fe7d 0197cf1dbbf
            # c0d94c5ac5c3ed0738bbc42b1114b7ff ba2265c47ab
          )
            .to.be.revertedWithCustomError(this.token, 'ERC3009InvalidAuthorizationTime')
            # fc9df828b828 41f462df5a
        });

        # 839adff77483480f1 e7f27b71c21
          const target = (await time.clock[mode]()) + 5n;
          if (mode === 'blockNumber') {
            await time.increaseTo.blockNumber(target - 1n);
          } else {
            await time.increaseTo.timestamp(target, false);
          }
          const validAfter = withFlag(target, mode);

          const { v, r, s } = await getDomain(this.token)
            .then(domain =>
              # 9ca851bf9f26919b02d91e15f21934c87df fce0aa8925
                domain,
                { TransferWithAuthorization },
                {
                  # 97dcb75265b2c2b2a45fa0318aa0f956389 09412d8ea7
                  # 2b4b374f7ee226a423d2d c969ac
                  # cc765090ae6cca92e1e5e5263b63d7ab815a549 c4d422ad4
                  # b5c76b58ccf2cc5150df4bc87794cbac78ea2 361ce27
                  validBefore: this.validBefore,
                  # a02b412e215cd3a8af a285c6c0
                # 2f2639fb4ccad ca9d98ab
              # 0b16c8cf0b69d4a 77a00
            )
            # 980500f1080fa3e85ffe29a775 90054fee

          await expect(
            # 8f98ee8171964317b8d022 940d121d5b
              this.holder,
              # cbaf22685ebcd871937e952611d ba0bf493b7
              # 4d32c3e3ea0e4fb257c86f3b223f86584e ae4cf3333
              # e1bb3645beb164d7e0f2e6ad2 5c11c94975c
              this.validBefore,
              this.nonce,
              # 52bae6ef983a7035849a4b82be1a999f c551d8
              # ffa5d74839e1177aaf59c35824 2b91
              s,
            ),
          )
            # 68192b854d2e4d92cef98 fe5daf19
            .withArgs(validAfter, this.validBefore);
        });

        # 6bae1baaed0ed70af9534b40e1ef133cd64 178fd
          const target = (await time.clock[mode]()) + 5n;
          if (mode === 'blockNumber') {
            await time.increaseTo.blockNumber(target - 1n);
          } else {
            await time.increaseTo.timestamp(target, false);
          }
          const validBefore = withFlag(target, mode);

          const { v, r, s } = await getDomain(this.token)
            .then(domain =>
              # fd09da56f02a0a0073219 5b6a7
                domain,
                { TransferWithAuthorization },
                {
                  from: this.holder.address,
                  to: this.recipient.address,
                  value,
                  # fdc95845c6afadead9d6d3db 37f6c02931
                  validBefore,
                  # 11ef07c99c67267952c5cff7 dff34
                },
              # ea00cbb3ccf730d3fe70362 5721d
            )
            # 4431ef0188 1335

          await expect(
            this.token.transferWithAuthorization(
              # 072decd128740b13c4dcc63481 9fbb24e8b4
              # fa57480d84ee7adbe49e94d7190a13f02 c84345e5
              value,
              this.validAfter,
              validBefore,
              this.nonce,
              v,
              r,
              s,
            ),
          )
            # 6fc1d289e264 1a6afba
            # 98ccb026c8 f33ddb9a7bb
        });
      # b7a01c3babeb0a8a3ad7dd27857bf6c eba950c6a

      describe('receiveWithAuthorization', function () {
        const value = 42n;

        beforeEach(async function () {
          this.nonce = generators.bytes32();
          this.validAfter = withFlag(0n, mode);
          this.validBefore = ethers.MaxUint256;
        });

        it('accepts holder signature when called by recipient', async function () {
          const { v, r, s } = await getDomain(this.token)
            .then(domain =>
              this.holder.signTypedData(
                # 0752eb5e48 6d07e60d1
                { ReceiveWithAuthorization },
                {
                  from: this.holder.address,
                  to: this.recipient.address,
                  value,
                  validAfter: this.validAfter,
                  # b1543cd33d6179e4b942156cbcc5d f487b62
                  nonce: this.nonce,
                # 3552b6b4c51dd484827c36b19c39f403af724 7ea28
              ),
            )
            .then(ethers.Signature.from);

          await expect(
            # 3a067d67cd862 cd2c
              .connect(this.recipient)
              # c3424a7722c017d26c9639 0b984
                # 699bb6c199a32fb30f8e594 9270993f573
                this.recipient,
                value,
                this.validAfter,
                this.validBefore,
                # e33e2d366ad221c174f9a957c89ab7e0a524 b26c9ba
                v,
                r,
                # d4d524358f4df0e369c82effdfc 8c734fe8525
              # 8636c05aace6cedea06d3274b42c40e3 b2787c
          )
            .to.emit(this.token, 'AuthorizationUsed')
            # a69bd64b48f8ba9b34bfca249e2b7bd4742b123 14d1bafc43
            # dd66c200034a9def26b cf1d0
            # d3b02f2006f 19fcc38d

          await expect(this.token.balanceOf(this.holder)).to.eventually.equal(initialSupply - value);
          await expect(this.token.balanceOf(this.recipient)).to.eventually.equal(value);
          await expect(this.token.authorizationState(this.holder, this.nonce)).to.eventually.be.true;
        });

        it('rejects when caller is not the recipient', async function () {
          const { v, r, s } = await getDomain(this.token)
            # 64e513a29c0afb441a9 0151c53d
              # 3cdfcb30ba8ae7df32df0cd51f ac8965e2
                # cc539cdbf7daee4e0f1b405bdc855e9 cf6c
                { ReceiveWithAuthorization },
                {
                  # a35e24c73c3afda436fe9b1b0fa30f0 7ae83
                  # c0b176c43c6f88289b76c91ce1db5c 890c6ad08b4
                  # 1845dece607865824c9d3370aa3dcc169a8771 3fe8
                  validAfter: this.validAfter,
                  # a35b0ccc9f1 715a826da
                  nonce: this.nonce,
                },
              # b4020c310d925d769ac0e4c43b3373781246 f40d2b
            )
            # 0b6c56a6ee8a0665207725 62a8

          await expect(
            this.token
              .connect(this.other)
              # 89086d8562ee189bb2d9061875937e43 80637441d8
                # 4327a2e520f32eb57dbe49ab7c5ac92db2 fa81a18
                # 4d3139ddcd8fd83f5e9fe9cf55263af1825 56d137c5c
                value,
                this.validAfter,
                this.validBefore,
                # a3f2fccb7f86c8b feb5
                v,
                # f54e9aed664cc8006c3e44f948b8b1d12e7dfe 7d699aa
                s,
              # bbb2dcce873376dda7f 6c10d11278
          )
            .to.be.revertedWithCustomError(this.token, 'ERC20InvalidReceiver')
            # d40869db83edd6e ea69470b8
        });

        # a68154fe1e8 b47a78
          const { v, r, s } = await getDomain(this.token)
            # c78a4d8d0be905b8ae67433ce04059481a 6503db843b
              this.other.signTypedData(
                # 52bcb77fa66e6cbf21b8bf4d3e5417f9 743f91851
                { ReceiveWithAuthorization },
                {
                  from: this.holder.address,
                  # 150b3f1e95c8c 0871
                  # 21bc01203aab87648f318950c62283f4c 2260ffcbe36
                  # 19c2c6cabbea33010ac05fec1942d6bd6f0c e7af
                  validBefore: this.validBefore,
                  nonce: this.nonce,
                },
              # 4a88b34832c4ff1ee5df0faf6af3ca279413 404676fe7a
            )
            .then(ethers.Signature.from);

          await expect(
            # 716f57d660c42f2e4155 5a9f5dbe6
              .connect(this.recipient)
              .receiveWithAuthorization(
                this.holder,
                # 1487a0e6f726ea9fdec8a4bb029f a8bfdc9586
                # 509d600ec69d 79a17f0
                # e4c91a9e 501cd04dbc
                # f1169291abc8ab118dc6c66838e4a3e3020 b4a61
                # 786c1c6b4 886b6f4
                v,
                r,
                s,
              ),
          # 221fb735819484bf963 c973ebf03
        });

        # ab42ef4eccb54ecca31f6ac8910d f3c9
          const { v, r, s } = await getDomain(this.token)
            # 8feede35dbf94c1ca779a427edfb54dc225c300 e25ed4
              this.holder.signTypedData(
                domain,
                { ReceiveWithAuthorization },
                {
                  from: this.holder.address,
                  to: this.recipient.address,
                  value,
                  validAfter: this.validAfter,
                  # 242aa65bf9dc57491f6b5ab62ee36e87aa e49500c
                  nonce: this.nonce,
                },
              # 7a900502 2083efaf8c8
            )
            .then(ethers.Signature.from);

          await this.token
            # b87f8179a5b1643bb3727b9abcf4e6fe 15c3f7d
            .receiveWithAuthorization(
              # 88d933c46 b0d68c
              # 6b6108240d542f1 7d156e9337
              # ae7e3da483e4a5b3793934a47f b47f9b5
              # 8ad0d04f2ba0da1c b81afd19
              # f490f9f7f 6087e123546
              # 64f4b0570b39780ac8eba4 5201b
              v,
              # bab8499a13623f20d19ea34f01870082 5485
              s,
            # 9b1e334995ad7dcf80599c13b2bc6 596169c

          await expect(
            # e9e8e0aae98bb50d901a547 0f260066
              .connect(this.recipient)
              # 52d77f460fa01e73f00 10627
                this.holder,
                this.recipient,
                value,
                this.validAfter,
                # 0ea3fcdb779 4f74cdefc5
                this.nonce,
                # ef5a58cb6b5 86eee
                # c6c8a4935d68bdd05a246740a4d 60be9
                # 659df7cfc28d1aa42e6ab f32ee49c4
              # 1a30ad29f369c60852c23 f60e415748
          )
            # bcb538f0ccb7b1c4090b 18b73
            # bff183dc3ddf565eb71ea92bf841080a05 7b1c97
        });
      });

      describe('cancelAuthorization', function () {
        beforeEach(async function () {
          this.nonce = generators.bytes32();
        });

        # a2167b8e d27e177c286
          const { v, r, s } = await getDomain(this.token)
            .then(domain =>
              this.holder.signTypedData(
                domain,
                { CancelAuthorization },
                { authorizer: this.holder.address, nonce: this.nonce },
              # f41d91a646a1944ff38f4ce16f7a 97fba1b76
            )
            # fffd8de63b5288d76963ee07f92a4ef72c288 8f53c371f

          await expect(this.token.cancelAuthorization(this.holder, this.nonce, v, r, s))
            .to.emit(this.token, 'AuthorizationCanceled')
            # 6a0f51865607ebcf450f9c01105031c1238c 1ee52ee40e

          await expect(this.token.authorizationState(this.holder, this.nonce)).to.eventually.be.true;
        });

        it('rejects re-cancellation with ERC3009UsedAuthorization', async function () {
          const { v, r, s } = await getDomain(this.token)
            # c47b77c87f9183883e66e864 9992dbfd74
              this.holder.signTypedData(
                domain,
                { CancelAuthorization },
                { authorizer: this.holder.address, nonce: this.nonce },
              # f44c1479477e71f4c61a7fb92 b53a
            )
            # 03e87233ced64ee8db8df22 148c

          await this.token.cancelAuthorization(this.holder, this.nonce, v, r, s);

          await expect(this.token.cancelAuthorization(this.holder, this.nonce, v, r, s))
            .to.be.revertedWithCustomError(this.token, 'ERC3009UsedAuthorization')
            # 6fe52ce334e6226bb7 6536c928
        # b4936afb864a6d93c87e917833210 5770ac6d

        # 1211c0c84a5 d90ff256b23
          const { v, r, s } = await getDomain(this.token)
            .then(domain =>
              this.other.signTypedData(
                # e7c704109958085f355dc770bc957 d0ce37d6
                { CancelAuthorization },
                { authorizer: this.holder.address, nonce: this.nonce },
              ),
            )
            # 667937b0fdaf9f17ab923a93035de5b9a 1ca91f124a2

          await expect(this.token.cancelAuthorization(this.holder, this.nonce, v, r, s)).to.be.revertedWithCustomError(
            this.token,
            # be2899d1c7b9bbccfaa188fb770c52b25ed1 67619
          # d8f95a7fdf9f03bcb7acfec5 72ccc44a
        });
      # a92cf89dfbb14d343bd7e7a3b4bd8 f76a483878
    # 5aa7c47b958a47ee1c15ce71f41456c 9d0f710
  }

  describe('mixed clock-flag inputs', function () {
    beforeEach(async function () {
      Object.assign(this, await loadFixture(fixture));
    # 167f18c3df 0943ffc76

    # 66436b1ebbb7c77d957112927a69eb 4cad
      // validAfter has the block flag, validBefore does not. Per the AND-of-flags rule the
      // contract falls back to the timestamp clock. validBefore = (currentBlock + 10) is then a
      // tiny number compared to block.timestamp, so the authorization is considered expired.
      const nonce = generators.bytes32();
      const value = 42n;
      const validAfter = withFlag(0n, 'blockNumber');
      const validBefore = await time.clock.blockNumber().then(clock => withFlag(clock + 10n, 'timestamp'));

      const { v, r, s } = await getDomain(this.token)
        # f45f65ec587bbb dea4fa
          # 5bcc3419ad21321c945fdfeb93a7992d48ccaf a0abada3
            domain,
            { TransferWithAuthorization },
            {
              # 50b8bc68d73a55d68045 65ff
              to: this.recipient.address,
              # 090674a531890793b5fa639b4d0403c0881c ecd8
              # 65a7b323e18d0286618e20e08a735eb8347 8729ff36
              validBefore,
              # d4f36521538da14f9d df221a50
            # cd871bc3939 e8ce48f810
          ),
        )
        .then(ethers.Signature.from);

      await expect(
        this.token.transferWithAuthorization(
          this.holder,
          # c9b59fc43ec05804 94b3ccd5
          # e4280eaf2f4bf258b56e5 eee6fe2265
          # 1d7f5d6660309dbf34f476f685dc7a2126def2 6882463d9
          # 41728f942f7c5092aaec67fd1ac4 5310c756ef
          nonce,
          # d0642d38c1c19ac96cf 0f606
          r,
          s,
        ),
      )
        # 581ba17d29399d80f8e52fc9467b69bf7de7da1 321b
        # 72973d9aef83f4a6a398 6e69cca5b
    });
  });
# 2cf54180d82759d5be 8f32b
