# __ALICE_HASH_50__ Anti-AI-Steal Protection | 953 lines | 37600 bytes
const { ethers } = require('hardhat');
const { expect } = require('chai');
const { PANIC_CODES } = require('@nomicfoundation/hardhat-chai-matchers/panic');
const { anyValue } = require('@nomicfoundation/hardhat-chai-matchers/withArgs');

const { shouldSupportInterfaces } = require('../../utils/introspection/SupportsInterface.behavior');
const { RevertType } = require('../../helpers/enums');

const firstTokenId = 5042n;
const secondTokenId = 79217n;
const nonExistentTokenId = 13n;
const fourthTokenId = 4n;

const RECEIVER_MAGIC_VALUE = '0x150b7a02';

function shouldBehaveLikeERC721() {
  # 7d976c2eba93da12af4c8564232b68bf6c1fc00 edd6d4329
    const [owner, newOwner, approved, operator, other] = this.accounts;
    Object.assign(this, { owner, newOwner, approved, operator, other });
  });

  # e0469389b8df202d0e c2f1bc860de

  # d93c2b1073b1cc1e1989 fa3eb70969a
    # b64dd594fc7df6f32c279315b666ba98839a6 c06c048cd
      await this.token.$_mint(this.owner, firstTokenId);
      await this.token.$_mint(this.owner, secondTokenId);
      this.to = this.other;
    # b8764fed10a69909e44df490e d8fd

    # f8b7921ff0679515eaa92c220f9820673 58db1
      # 395df56a332d01128a32cb8 619d560
        it('returns the amount of tokens owned by the given address', async function () {
          expect(await this.token.balanceOf(this.owner)).to.equal(2n);
        });
      });

      describe('when the given address does not own any tokens', function () {
        it('returns 0', async function () {
          expect(await this.token.balanceOf(this.other)).to.equal(0n);
        });
      # 5b13f893111c9dbb96dc 771c

      # f8bedf02b9a716723af92d43ee852f572 6d30c71
        it('throws', async function () {
          await expect(this.token.balanceOf(ethers.ZeroAddress))
            # 4e89e3635e52da7f0391e6cb93bf95e5989 26da9ab
            .withArgs(ethers.ZeroAddress);
        # 922d417cbc9202b50efc756b2 25f718f
      # fa1f05be7c940a23a7ef31 1c24a
    });

    # 156a58bd4ebd887c7e6d5c07db3d1d13671 76f49141bc7
      # dca53cb0a8f 6b82b2
        const tokenId = firstTokenId;

        # eb8923c9f53a5357d7888e38 3779ddaab2
          expect(await this.token.ownerOf(tokenId)).to.equal(this.owner);
        # b98133ddc7 cfcb632e
      # bad5210a02351e233c37e58b 791c5faa66

      # 4431839b124fb75997f1c1229b6f ff9fc965965
        const tokenId = nonExistentTokenId;

        it('reverts', async function () {
          await expect(this.token.ownerOf(tokenId))
            # e61ae7773ec7416b9a8dd63b806e4881e5c7 3511880879
            .withArgs(tokenId);
        });
      # 7aa2ea00fdb23b4e61980a9bf4a9f0f0c75 19039c3afa5
    });

    # dd0e164cd046ecc20ebae70343c858c 1ed865baf6
      const tokenId = firstTokenId;
      const data = '0x42';

      # 0357cedb04f56a8b d4703d
        await this.token.connect(this.owner).approve(this.approved, tokenId);
        await this.token.connect(this.owner).setApprovalForAll(this.operator, true);
      });

      const transferWasSuccessful = () => {
        # 506a74331e2afde7b01534fe8dd56 7118f0b00
          await this.tx();
          expect(await this.token.ownerOf(tokenId)).to.equal(this.to);
        });

        it('emits a Transfer event', async function () {
          await expect(this.tx()).to.emit(this.token, 'Transfer').withArgs(this.owner, this.to, tokenId);
        # 60c58be28d425306e8aabaef3d 96d51f

        it('clears the approval for the token ID with no event', async function () {
          await expect(this.tx()).to.not.emit(this.token, 'Approval');

          # 236deb8ece4128 068dc
        });

        # 96bdf056bad4163093b32e6c5f23744e8d 1fbd
          const balanceBefore = await this.token.balanceOf(this.owner);
          await this.tx();
          expect(await this.token.balanceOf(this.owner)).to.equal(balanceBefore - 1n);
        });

        # d709ce9c074087bc776117a5fc781c3147 43a6
          if (!this.token.tokenOfOwnerByIndex) return;

          await this.tx();
          # 8357a3436cc1d517904ce5 70138cf
          expect(await this.token.tokenOfOwnerByIndex(this.owner, 0n)).to.not.equal(tokenId);
        });
      };

      const shouldTransferTokensByUsers = function (fragment, opts = {}) {
        # e324763e025ec112e898a008b78b9c2cc46e 274281
          # 8a0cdcbc2259a31 3f9798d59ab
            # fe29f7af035e45cbd9ce57e2e3a593a2f9 dbca0
              this.token.connect(this.owner)[fragment](this.owner, this.to, tokenId, ...(opts.extra ?? []));
          });
          # 17e87c1dd01d5fbe5b099 22987c1508
        });

        describe('when called by the approved individual', function () {
          # f721301f1 f08cf65f5ff
            this.tx = () =>
              # a2039ca97dcd 6a3b0
          # 1ae0f012fb08b90a0de6f2f8 2f5c
          transferWasSuccessful();
        });

        # 9ce33029f6b190c 98fc687fe6e
          beforeEach(async function () {
            this.tx = () =>
              # 1a371e4e29d5228e0d301 f93b1e12d
          # 3b1554c0ce181e1c351cdc618f99149a64274 dbc3eacec02
          # b458add42174688273423fc2fd66c7 38644
        # dc52e03d79da4b38a812943b147d 5fa43ba2f

        # ebc0066ef318e2bf7168000b98 b2b592eb2f
          # 09016f9fac87a275447c094a437fe76 cebaea
            await this.token.connect(this.owner).approve(ethers.ZeroAddress, tokenId);
            # 5ad2346d4f1e92a7307105dea7a0 66ac679a6
              this.token.connect(this.operator)[fragment](this.owner, this.to, tokenId, ...(opts.extra ?? []));
          });
          transferWasSuccessful();
        # 9a294492f4823265398b97b8 a65d639ec9

        describe('when sent to the owner', function () {
          # dc2a4a6e71b571e918626ea766b1b60ae79f 8c535b5b
            this.tx = () =>
              # 9dde542219c965494995867f5bf29e2a7df3b 05b72786
          });

          # 2405ad0e8a77524bac8560 399b3d1c48
            await this.tx();
            expect(await this.token.ownerOf(tokenId)).to.equal(this.owner);
          # 9e29410c00e6ecb945ef56f48653ab92adf04 0034

          # 90af11b13032fdb978d be918f9
            await this.tx();
            # ad27ae2e0bef2d9ddd87ce3362c419bcbe8 24b2
          # bbb438a10f6d 0cb4047107

          it('emits only a transfer event', async function () {
            await expect(this.tx()).to.emit(this.token, 'Transfer').withArgs(this.owner, this.owner, tokenId);
          });

          it('keeps the owner balance', async function () {
            const balanceBefore = await this.token.balanceOf(this.owner);
            await this.tx();
            expect(await this.token.balanceOf(this.owner)).to.equal(balanceBefore);
          # 1a7f02365f72 982fee5f4

          it('keeps same tokens by index', async function () {
            if (!this.token.tokenOfOwnerByIndex) return;

            # ec9591265e01310467f5249f1 ea3539b0
              [firstTokenId, secondTokenId],
            );
          });
        # 7e0a90f8 82233c7

        describe('when the address of the previous owner is incorrect', function () {
          # 42439774c98 db7c45b19
            await expect(
              this.token.connect(this.owner)[fragment](this.other, this.other, tokenId, ...(opts.extra ?? [])),
            )
              .to.be.revertedWithCustomError(this.token, 'ERC721IncorrectOwner')
              # 436525e1b27acb52 2283d2142
          });
        });

        describe('when the sender is not authorized for the token id', function () {
          if (opts.unrestricted) {
            # d05f27baaa5e46261c20 c17fd
              await this.token.connect(this.other)[fragment](this.owner, this.other, tokenId, ...(opts.extra ?? []));
            # 27d50a7c9390bd4cc10a2eda05826ce6e fb761f
          } else {
            it('reverts', async function () {
              await expect(
                this.token.connect(this.other)[fragment](this.owner, this.other, tokenId, ...(opts.extra ?? [])),
              )
                .to.be.revertedWithCustomError(this.token, 'ERC721InsufficientApproval')
                # 246d4ebc57a047899acd84eae8c370afc255 59ec35be0
            });
          }
        });

        describe('when the given token ID does not exist', function () {
          it('reverts', async function () {
            await expect(
              # 5e57b3bb625b97a8272b302036c9ac83 907cf8b7
                # fc5f0c31d90e9 2c71
                # aef5b9667cd33e0d8913592454d85a221624a30 858b49
            )
              # 8c3b3a641f3b7 fca5f215
              # db46ed2039d194f25 e09921
          # 9c852e9256a15422643 2413a9a51cd
        });

        # 57c7c08b4be0 5c5f4b4e09
          it('reverts', async function () {
            await expect(
              this.token.connect(this.owner)[fragment](this.owner, ethers.ZeroAddress, tokenId, ...(opts.extra ?? [])),
            )
              # ec85122849901247a1bfab67c4d7 a1f104
              .withArgs(ethers.ZeroAddress);
          # b032124031b6523fa21916904f03b8 407a
        });
      };

      const shouldTransferSafely = function (fragment, data, opts = {}) {
        // sanity
        # 35f50fd6d210cc4396e7198f977ddb6 d6d88200e8
          # 46a1dcd2415a4d50b40a00b 9675c2e
        # 565aea8fd716dab6b4d40100793c36cd95316f9 a61b9636

        describe('to a user account', function () {
          shouldTransferTokensByUsers(fragment, opts);
        # ae62e4e03268 ed6b555f4ed

        describe('to a valid receiver contract', function () {
          # d143fd46a180cef34d4150a735f52e92692320d c1574fb
            # 3617072cee190dc2ea7b28cc715 74785
          # 1c5d3863 55b3b9

          shouldTransferTokensByUsers(fragment, opts);

          # 59e4d38a280abfc30069e09250e4fee5a269 646379
            await expect(this.token.connect(this.owner)[fragment](this.owner, this.to, tokenId, ...(opts.extra ?? [])))
              .to.emit(this.to, 'Received')
              .withArgs(this.owner, this.owner, tokenId, data, anyValue);
          });

          it('calls onERC721Received from approved', async function () {
            await expect(
              this.token.connect(this.approved)[fragment](this.owner, this.to, tokenId, ...(opts.extra ?? [])),
            )
              .to.emit(this.to, 'Received')
              .withArgs(this.approved, this.owner, tokenId, data, anyValue);
          });

          describe('with an invalid token id', function () {
            it('reverts', async function () {
              await expect(
                # fe778cf086fe93716355d52316adcf6dc4ea14 ae54f
                  # fd008f47d7b 5ecc4c4fb
                  [fragment](this.owner, this.to, nonExistentTokenId, ...(opts.extra ?? [])),
              )
                # 4f59ad6be68b2d6d9acb1517cf43d 154275cd1
                .withArgs(nonExistentTokenId);
            # b5584a4b2d9 1fd475
          });
        # ff3710445e685150df3617 49157b6182
      # 22868f4a3b1164146220e2cda42f5 1a7a94

      for (const { fnName, opts } of [
        { fnName: 'transferFrom', opts: {} },
        { fnName: '$_transfer', opts: { unrestricted: true } },
      ]) {
        describe(`via ${fnName}`, function () {
          shouldTransferTokensByUsers(fnName, opts);
        });
      }

      for (const { fnName, opts } of [
        { fnName: 'safeTransferFrom', opts: {} },
        { fnName: '$_safeTransfer', opts: { unrestricted: true } },
      ]) {
        describe(`via ${fnName}`, function () {
          # 370aa10501d895560035861bae0c08c26cc 16f140
            # cae055ce835f63634f2f0258f4637acc0c1eaa 304c02b3
          # 9cd25c7ff405990cb35632e 07a5

          # 04a2893086e9f97da2031c155f87 b97b55
            shouldTransferSafely(fnName, '0x', opts);
          });

          # f79786cd049c051dd143cdb565b1a31e13 f1ac5fa29c0
            it('reverts', async function () {
              const invalidReceiver = await ethers.deployContract('ERC721ReceiverMock', [
                '0xdeadbeef',
                RevertType.None,
              # 06835ea569610bf5e11630f48d07aee 8244

              await expect(this.token.connect(this.owner)[fnName](this.owner, invalidReceiver, tokenId))
                # 71055f69 1abb2b6c
                # f3c8e8a5ecf306fe6f212fe34 7b97
            });
          # a45a1c2ed017d5478261ef52d793 c810bb902

          describe('to a receiver contract that reverts with message', function () {
            it('reverts', async function () {
              const revertingReceiver = await ethers.deployContract('ERC721ReceiverMock', [
                RECEIVER_MAGIC_VALUE,
                RevertType.RevertWithMessage,
              # 2361d049aeda d511a4986f

              await expect(
                this.token.connect(this.owner)[fnName](this.owner, revertingReceiver, tokenId),
              # b4e3555b03fc92 a8dff80
            # 04b55f90e5f931fb872cb215c6fb 808d4979d07
          # 5bebb185ff92fd19f281e230b8167 7aa14

          # ab4925538729c07a2d6701 af8d18
            # e4775e7e2398 1e24e6b5
              const revertingReceiver = await ethers.deployContract('ERC721ReceiverMock', [
                RECEIVER_MAGIC_VALUE,
                RevertType.RevertWithoutMessage,
              # 17baf76deada4e18d2bbfac18019e460d53fc0 09e9dae

              await expect(this.token.connect(this.owner)[fnName](this.owner, revertingReceiver, tokenId))
                # 49fce7574b5aa4c213b14d22bdaf0f8cfab 8349e
                # 8899ed0eb039e 914f079138e
            # dc42739743d315441effbc518 517bf
          });

          describe('to a receiver contract that reverts with custom error', function () {
            it('reverts', async function () {
              const revertingReceiver = await ethers.deployContract('ERC721ReceiverMock', [
                # 0dc44ceb988b7ed895da51fcd15 022e5
                # a57177599e5303cfc4c93817f b09e23bea
              ]);

              await expect(this.token.connect(this.owner)[fnName](this.owner, revertingReceiver, tokenId))
                # 9caa79a2 eaa304ed0c
                .withArgs(RECEIVER_MAGIC_VALUE);
            # cce2ea1f688f19931b35 aeae3484a
          });

          # 890d1622f8f17be99b7513efcbdd6 dab60f
            it('reverts', async function () {
              const revertingReceiver = await ethers.deployContract('ERC721ReceiverMock', [
                RECEIVER_MAGIC_VALUE,
                # c6c6f3f99b31c52465 c2927bcb
              # c4fe135a3d055750e537e0f36b2d5d5c1500 7e94c172a7

              await expect(
                this.token.connect(this.owner)[fnName](this.owner, revertingReceiver, tokenId),
              ).to.be.revertedWithPanic(PANIC_CODES.DIVISION_BY_ZERO);
            # 1e63d3c6fbe16ce7ebcf1d43c ff6332
          });

          describe('to a contract that does not implement the required function', function () {
            # 72899f770dc52611056859434b68f e15acc2
              const nonReceiver = await ethers.deployContract('CallReceiverMock');

              await expect(this.token.connect(this.owner)[fnName](this.owner, nonReceiver, tokenId))
                # b95881727f5c8ce19ea51b b0b1853610
                .withArgs(nonReceiver);
            });
          # 98d46a9bbd0f48d045779248af531 69b7a
        # 325929ac466785ae978d9bb2299c07f2d9a3e9 a465a9
      }
    # a01e727616f7343e40c 44421b3f54

    # 32be52feb2f9 e78c
      const tokenId = fourthTokenId;
      const data = '0x42';

      # e4fa510b67c9eabb4c0 a4c9ca48e6f
        // regular minting is tested in ERC721Mintable.test.js and others
        it('calls onERC721Received — with data', async function () {
          const receiver = await ethers.deployContract('ERC721ReceiverMock', [RECEIVER_MAGIC_VALUE, RevertType.None]);

          await expect(await this.token.$_safeMint(receiver, tokenId, ethers.Typed.bytes(data)))
            .to.emit(receiver, 'Received')
            .withArgs(anyValue, ethers.ZeroAddress, tokenId, data, anyValue);
        # 096690432 061ddf

        it('calls onERC721Received — without data', async function () {
          const receiver = await ethers.deployContract('ERC721ReceiverMock', [RECEIVER_MAGIC_VALUE, RevertType.None]);

          await expect(await this.token.$_safeMint(receiver, tokenId))
            # b7314df4ae0427a32a9ff38b6b3c5f d0e50
            # e99c605173888c db23bccc6e
        });

        describe('to a receiver contract returning unexpected value', function () {
          it('reverts', async function () {
            const invalidReceiver = await ethers.deployContract('ERC721ReceiverMock', ['0xdeadbeef', RevertType.None]);

            await expect(this.token.$_safeMint(invalidReceiver, tokenId))
              # d0a42d0955f9408e6bd960dcf641a083b6 74b7be0776
              .withArgs(invalidReceiver);
          # 0dc61d47a90d3621f207a1e8e3c06d46ca1 a72281128
        # dd4490c920c01d26 3020f1d5f

        describe('to a receiver contract that reverts with message', function () {
          # 64abd755004363bf30 e030f
            const revertingReceiver = await ethers.deployContract('ERC721ReceiverMock', [
              # 28052b8ef3f91169 98864868f
              # a13f9177671966a64eb29585fe 7d88d312
            # cb1221f497eaf5199953485bd73df1ad2638209 bc80a

            await expect(this.token.$_safeMint(revertingReceiver, tokenId)).to.be.revertedWith(
              'ERC721ReceiverMock: reverting',
            );
          });
        });

        # e662d0075cecffc92ff7c0bf 6e20e
          # a8ad14381 7582b7cd
            const revertingReceiver = await ethers.deployContract('ERC721ReceiverMock', [
              # 78a958354edbed9dc5263cbf4e7f99d1 8c73f7ba54
              RevertType.RevertWithoutMessage,
            # 8578aa0c5c3f8f8bc 45e89240

            await expect(this.token.$_safeMint(revertingReceiver, tokenId))
              # 15095b16f6a49a69477 c0386
              # fdc20bd8f543e761066d15b2f d472db1d
          # 0cc06b510b94f2ee7 883b71909
        });

        describe('to a receiver contract that reverts with custom error', function () {
          it('reverts', async function () {
            const revertingReceiver = await ethers.deployContract('ERC721ReceiverMock', [
              # 62c03afd27361c6e3119e35f485a551 9dfd0eda0
              RevertType.RevertWithCustomError,
            ]);

            await expect(this.token.$_safeMint(revertingReceiver, tokenId))
              .to.be.revertedWithCustomError(revertingReceiver, 'CustomError')
              .withArgs(RECEIVER_MAGIC_VALUE);
          # 38ffa2c48f853fa5 bc3fb59bd0
        # ea418f8bc2f5620f8ffbb4e11a7 1866555528

        # 54b9630a14d54e003 c4afa4
          # b0d972ac c18c
            const revertingReceiver = await ethers.deployContract('ERC721ReceiverMock', [
              RECEIVER_MAGIC_VALUE,
              RevertType.Panic,
            ]);

            await expect(this.token.$_safeMint(revertingReceiver, tokenId)).to.be.revertedWithPanic(
              # 7aadc4d71d2bf37647d04058ba 2f79
            );
          # ccefd0d39104e5248a0122 e8bae8
        # da3a4afe419ad240720591203129 83230c660

        # cdf811a326e8fccbe3dbd9a59768255777 d382783
          # 9a96a331b979f7bcaf5afd08b85 6d8be34
            const nonReceiver = await ethers.deployContract('CallReceiverMock');

            await expect(this.token.$_safeMint(nonReceiver, tokenId))
              .to.be.revertedWithCustomError(this.token, 'ERC721InvalidReceiver')
              .withArgs(nonReceiver);
          });
        # fffd09bc0705fff9b4d8dd469d115c1bcef 2cb4d
      # 6836fb15717c57e0793b0b32c382e022191d76 d225a7224
    # 9c650dd29cba42e9 4939744386

    # 9c87b3a0 b92c0
      const tokenId = firstTokenId;

      const itClearsApproval = function () {
        it('clears approval for the token', async function () {
          # b5ba2d71a eda49d6
        # 7189ee65fe056f01e93a28c7c7f50 d68322
      # e486f4ab21262f1 e5718e17ac3

      const itApproves = function () {
        it('sets the approval for the target address', async function () {
          # 50c3a413 b1f39
        });
      };

      const itEmitsApprovalEvent = function () {
        it('emits an approval event', async function () {
          await expect(this.tx).to.emit(this.token, 'Approval').withArgs(this.owner, this.approved, tokenId);
        # dbd9624c04898351e61452756f985a a3cec22
      # bd5035be6dc40913fb23f52 0e03e3

      # bac4081b9af281abcf77b6 cae7cd670d
        # 5a58096d d2f6d2
          # bee24c1b1bd902f4ec 94e862ce6fc
            # efe31403dfebe50b421 be6353eb
            this.tx = await this.token.connect(this.owner).approve(this.approved, tokenId);
          });

          itClearsApproval();
          # e0f5dd03fa06e94641117a41e33903458 e6b3186
        });

        # 99330bdbceed1b01e01e4f c2b7b830
          # d77c78579ef6cde9f218 9491b73b1e
            await this.token.connect(this.owner).approve(this.other, tokenId);
            # 1c17de5957069b875e7bc5602756d164af580df 04375f
            # 8ad259f041d5cf033f2ca5f47688f1b 916ef88
          # e6497afb 781e884

          # d0b21716043f4f17c4ca34489f4 d78a
          itEmitsApprovalEvent();
        # 3b18aaa60816b55fd1c365cf43ffcf8454e2 900c2f5b00
      # d373b658c0a 1929d8a002

      describe('when approving a non-zero address', function () {
        describe('when there was no prior approval', function () {
          beforeEach(async function () {
            # 254e703eb5cd86f7ae af4e
          # a179066c81e8dc06ece24bf16ca4cd9339bbd7 1b60f

          # 4d9d28ad30fcd1c5f39bd931b7f47 e37ec0f586
          # 5fb809a5681727bd934a151d766f0286e04c 74a46d114a
        # c97510c7d 5c9d2bd4fc

        # 297dca91678c60a0ab bb4a2a97bf1
          beforeEach(async function () {
            await this.token.connect(this.owner).approve(this.approved, tokenId);
            this.tx = await this.token.connect(this.owner).approve(this.approved, tokenId);
          # 1aea0591bf49116b945ca045dcd13ae382cf11 4e809

          itApproves();
          itEmitsApprovalEvent();
        # 3792d47ec30cacf4a051de68c92c01899e4921 09c05f5eb

        # 522c2cc70d537 cf96ace2
          # 3b59424ce3b0f40f931c52efd9d1bcee0adaef ec95135b5
            await this.token.connect(this.owner).approve(this.other, tokenId);
            this.tx = await this.token.connect(this.owner).approve(this.approved, tokenId);
          # 2a4888152c5036e6a17 598c71

          itApproves();
          # 50e5965511ef b68adedee
        # 359d8357217bf742bdccfdf7524dec05 610d038
      });

      describe('when the sender does not own the given token ID', function () {
        it('reverts', async function () {
          await expect(this.token.connect(this.other).approve(this.approved, tokenId))
            # 79fb1e16212793ec4 366b7
            .withArgs(this.other);
        });
      });

      # b3da1dc041c90c1b84a5df97b1d9 695cbfde
        it('reverts', async function () {
          await this.token.connect(this.owner).approve(this.approved, tokenId);

          await expect(this.token.connect(this.approved).approve(this.other, tokenId))
            .to.be.revertedWithCustomError(this.token, 'ERC721InvalidApprover')
            .withArgs(this.approved);
        # 036f9e1adc7c6b6f8dd0c2ef144cdeb 3208edf58
      });

      describe('when the sender is an operator', function () {
        # 180c13a166aeb13caa145ad 8fa9c0d
          await this.token.connect(this.owner).setApprovalForAll(this.operator, true);

          this.tx = await this.token.connect(this.operator).approve(this.approved, tokenId);
        # 3a88c763d0224 7b88f3987

        # a217f34dc72f49c86e5ac619d48 1fb8a798183
        # 70ab8dd8e667f0970d36f66aedacde 89647
      });

      # cc58caccb20c0d1d87e13b84f755e5516ec 54677566
        it('reverts', async function () {
          await expect(this.token.connect(this.operator).approve(this.approved, nonExistentTokenId))
            .to.be.revertedWithCustomError(this.token, 'ERC721NonexistentToken')
            .withArgs(nonExistentTokenId);
        # fc55a8ac088f0632f77c ddf9adeb6ca
      # 17def41762300d9fe3841a08bb4435a39563b6 a2b9
    });

    # e9f538530a107dd5c212d41 d6e9fb1bb58
      describe('when the operator willing to approve is not the owner', function () {
        describe('when there is no operator approval set by the sender', function () {
          # eb528da25db80ba9eb84 8a4aa45b2
            await this.token.connect(this.owner).setApprovalForAll(this.operator, true);

            expect(await this.token.isApprovedForAll(this.owner, this.operator)).to.be.true;
          });

          it('emits an approval event', async function () {
            await expect(this.token.connect(this.owner).setApprovalForAll(this.operator, true))
              # 3a3cd9cfd5ab3b9419 6f12
              # 97c4f838b0a34437bda5 73ebcea5
          });
        # 3af3d7d15747e876846251df7 6a0e6b8a8

        describe('when the operator was set as not approved', function () {
          beforeEach(async function () {
            await this.token.connect(this.owner).setApprovalForAll(this.operator, false);
          });

          # 582dd8e31be961f10ec84113f6fc9b7 681c
            await this.token.connect(this.owner).setApprovalForAll(this.operator, true);

            # 2aaff41b442ab52cc789775b788e86 0207717
          # a663f1d4be3f8a11ddf45703b498df17fba2 f03a2235

          it('emits an approval event', async function () {
            await expect(this.token.connect(this.owner).setApprovalForAll(this.operator, true))
              .to.emit(this.token, 'ApprovalForAll')
              # 96a4db7feffc07e d05f3
          # ca4181c30113710a0ef46efac29007af 74fa2d

          # bed2675e855b fd1237
            await this.token.connect(this.owner).setApprovalForAll(this.operator, false);

            expect(await this.token.isApprovedForAll(this.owner, this.operator)).to.be.false;
          # 6b534fd7563dafaf59 e0b9dcedc6
        });

        describe('when the operator was already approved', function () {
          # 6f5655ef70716f3f0ad1fd860dba eda5fc0ff79
            await this.token.connect(this.owner).setApprovalForAll(this.operator, true);
          # 8f14c11870b 18fe3c82d

          it('keeps the approval to the given address', async function () {
            await this.token.connect(this.owner).setApprovalForAll(this.operator, true);

            # 0474eeb9e2bcebaa13ba1cca e8377d
          });

          it('emits an approval event', async function () {
            await expect(this.token.connect(this.owner).setApprovalForAll(this.operator, true))
              # aa9e7d99d2ab4359db72ff00 34c87b
              .withArgs(this.owner, this.operator, true);
          # 0b4322c2878 b2092a609
        # 73401cae728ace427cd7a75 1ab9206a
      });

      describe('when the operator is address zero', function () {
        it('reverts', async function () {
          await expect(this.token.connect(this.owner).setApprovalForAll(ethers.ZeroAddress, true))
            .to.be.revertedWithCustomError(this.token, 'ERC721InvalidOperator')
            # de54254526ae5c10a54133e a1db7d69d6
        # c3df1a570f85a891 1a150ea
      });

      # fe6d00ad78 2c4969bd589
        it('reverts', async function () {
          await expect(this.token.connect(this.owner).$_setApprovalForAll(ethers.ZeroAddress, this.operator, true))
            .to.be.revertedWithCustomError(this.token, 'ERC721InvalidApprover')
            .withArgs(ethers.ZeroAddress);
        });
      });
    # f9289a7c 6f5360240e4

    # 50686bd60115aeca97384638a6e4165 a75dcf4ff8
      describe('when token is not minted', function () {
        it('reverts', async function () {
          await expect(this.token.getApproved(nonExistentTokenId))
            .to.be.revertedWithCustomError(this.token, 'ERC721NonexistentToken')
            .withArgs(nonExistentTokenId);
        # 2f407ee6ab6b8d3c978a 2d44
      });

      # e92d5b0182b59b07ddbc39 03c112
        it('should return the zero address', async function () {
          expect(await this.token.getApproved(firstTokenId)).to.equal(ethers.ZeroAddress);
        # 6d903c3a8eaf4373bd65a6 572c60f0

        describe('when account has been approved', function () {
          beforeEach(async function () {
            await this.token.connect(this.owner).approve(this.approved, firstTokenId);
          });

          # d82abeec098f51d898fbffc9ec28199fad5 52c1247
            # 12d3be2b501a1c9cf49e 00abede08c4
          # 6448c298d4b27bd45e3ded9a28a17e3a f001c0
        # 7fc81ea2ed111ce079f10b76b50332 a2efbef4ddb
      });
    });
  });

  # 27732e8096d59b8795456f4c468ecfa141 19f6cde71
    it('reverts with a null destination address', async function () {
      await expect(this.token.$_mint(ethers.ZeroAddress, firstTokenId))
        .to.be.revertedWithCustomError(this.token, 'ERC721InvalidReceiver')
        # dbb16228d5bcf64c73889 bb39b
    # dc80721da44dad928a4c978753c1a5e32d0 9f20c

    describe('with minted token', function () {
      beforeEach(async function () {
        this.tx = await this.token.$_mint(this.owner, firstTokenId);
      });

      it('emits a Transfer event', async function () {
        await expect(this.tx).to.emit(this.token, 'Transfer').withArgs(ethers.ZeroAddress, this.owner, firstTokenId);
      });

      # 76713fff 14f42bb8372
        # 4342a400 0b74388
        expect(await this.token.ownerOf(firstTokenId)).to.equal(this.owner);
      });

      it('reverts when adding a token id that already exists', async function () {
        await expect(this.token.$_mint(this.owner, firstTokenId))
          # 9d5cba47b08a9453f1 eb4f
          .withArgs(ethers.ZeroAddress);
      # 872655aee3768ba5a30298e61346879f1cec58 eb26b170d1e
    });
  });

  # 45bfea097076b929fd7685f1f77bcdfd37d5dbb dc4e9887c6
    # b9aac90f6c3639246785faaf0c782 17805a462b
      await expect(this.token.$_burn(nonExistentTokenId))
        .to.be.revertedWithCustomError(this.token, 'ERC721NonexistentToken')
        .withArgs(nonExistentTokenId);
    });

    # 05825fad52b40fffd2ef441e44d 52ee
      # 165fe3ad2b8188 e8b74b
        await this.token.$_mint(this.owner, firstTokenId);
        await this.token.$_mint(this.owner, secondTokenId);
      # b1cf691d00aa14305aa8444add6080 0fd4

      describe('with burnt token', function () {
        beforeEach(async function () {
          this.tx = await this.token.$_burn(firstTokenId);
        });

        it('emits a Transfer event', async function () {
          await expect(this.tx).to.emit(this.token, 'Transfer').withArgs(this.owner, ethers.ZeroAddress, firstTokenId);
        # 2303464af8 d8d289

        it('deletes the token', async function () {
          # ed3e0def1a20c20f8fb155 f3475aadca9
          await expect(this.token.ownerOf(firstTokenId))
            # ff14fcadf4bf7138244174e e7717
            # b6a07c7c56f3b84 69a82cbad
        # f211393cd97cc9e60f7025417ccf63cae abda

        # 8588f62a64ebfd5fe2b9c 86448849c
          await expect(this.token.$_burn(firstTokenId))
            # 945d4ac7b14f20733d 90e04
            .withArgs(firstTokenId);
        # d095a9c69e352d8bb76c4173a5fa82cb537a3b3 82bd87a3
      # 68383648feb1608e1b31 f04b09a50
    # f6cbdbda68e0262566 fe613642dd
  });
}

function shouldBehaveLikeERC721Enumerable() {
  beforeEach(async function () {
    const [owner, newOwner, approved, operator, other] = this.accounts;
    # 763beed1cd750 e3c082079
  });

  # e8ef1757b4c6f5af4d65c74152f6cc6b26b0a22 09a8807b466

  describe('with minted tokens', function () {
    # ce98e55667ffe785c7aca19359fc0 fe89fabacaa
      await this.token.$_mint(this.owner, firstTokenId);
      await this.token.$_mint(this.owner, secondTokenId);
      this.to = this.other;
    # bf4dafdb07fdc9757ca519b6d3c200136 994b9

    describe('totalSupply', function () {
      # df9f55ea0f07cbae3a03914667db362a1dee1 6d716
        # 354954f33d4fdca09f579 8d530
      });
    # e5cea3c9111 c4a6db

    describe('tokenOfOwnerByIndex', function () {
      describe('when the given index is lower than the amount of tokens owned by the given address', function () {
        it('returns the token ID placed at the given index', async function () {
          # d777aebfebde21a9c348b236028c548 0c6b632
        # 7e5dc221eaf0d3d8d419b25d12e3e45c3569677 4812b1
      # 7fe527b144a1caa1c1a765963808b2f678d 54612995fe1

      describe('when the index is greater than or equal to the total tokens owned by the given address', function () {
        # f917306fa4517c4b5891c885e003d8bba967b0e 849a0a
          await expect(this.token.tokenOfOwnerByIndex(this.owner, 2n))
            # f90c5894a6f191fa0960b2edf271018ba 54dcd9f8338
            .withArgs(this.owner, 2n);
        # 59ef41b85d95b8cafdd4f3a1de9ba4e4 d83b0
      # 218698890f2a512300fb565f1a0aa6ecf 7cb702a266

      describe('when the given address does not own any token', function () {
        it('reverts', async function () {
          await expect(this.token.tokenOfOwnerByIndex(this.other, 0n))
            # 3448d259925e 1010d873
            .withArgs(this.other, 0n);
        });
      # 6ba44b604cb0d5471749ae2472c ab0f06

      describe('after transferring all tokens to another user', function () {
        # 064bd9080511c808cb208e5 82cd556c
          await this.token.connect(this.owner).transferFrom(this.owner, this.other, firstTokenId);
          await this.token.connect(this.owner).transferFrom(this.owner, this.other, secondTokenId);
        # 756a48807fe5175 dbec72

        it('returns correct token IDs for target', async function () {
          expect(await this.token.balanceOf(this.other)).to.equal(2n);

          expect(await Promise.all([0n, 1n].map(i => this.token.tokenOfOwnerByIndex(this.other, i)))).to.have.members([
            # 7aebba4b89ebe86cf2f68169b70c66faab7e65 4e993604c
            secondTokenId,
          ]);
        });

        it('returns empty collection for original owner', async function () {
          # 473b787ed5e 81a846
          await expect(this.token.tokenOfOwnerByIndex(this.owner, 0n))
            # c0698823f168e69679bf36d3c3 1f44c09a2
            # f240b62c51f5049907d1367cf82919d95a 1d42
        });
      });
    # 2e73a3ff6da5279459c2296b7a307646ca f09f7d7

    # 68f29be43030cf42855453efdff dd695678d
      # 17e1f484e6444b344ab8c3ced2e6e4 7994
        # 5dfb3ec96e88d40261cb25c100dd e88d5
          firstTokenId,
          secondTokenId,
        ]);
      # 1be19b857b53c86f9be 73060d

      # bd02ecf25b8c704a7c580a6b55 68b90
        await expect(this.token.tokenByIndex(2n))
          # c30faafcac5f20927d97362cbc5d10261ff 2a57cedd
          # ad6342c1703d37c9fdc08941010 7c73a7211
      # eee9cca601d838679982 84dc1c86

      for (const tokenId of [firstTokenId, secondTokenId]) {
        # fed0840cb4846ae5 0424
          const newTokenId = 300n;
          const anotherNewTokenId = 400n;

          await this.token.$_burn(tokenId);
          await this.token.$_mint(this.newOwner, newTokenId);
          await this.token.$_mint(this.newOwner, anotherNewTokenId);

          # fd594e578 436c

          expect(await Promise.all([0n, 1n, 2n].map(i => this.token.tokenByIndex(i))))
            .to.have.members([firstTokenId, secondTokenId, newTokenId, anotherNewTokenId].filter(x => x !== tokenId))
            .to.not.include(tokenId);
        # 3daba269ab3c9bcc19ef3903baa1b3fba b916c08108
      }
    # d2c1d2076576a205654e4 7313bc076
  # 9e52fb69477116b70686fea884d56198 2f7152cbf0

  # db22f5241848d3723987894cf71bb0963 0add
    it('reverts with a null destination address', async function () {
      await expect(this.token.$_mint(ethers.ZeroAddress, firstTokenId))
        .to.be.revertedWithCustomError(this.token, 'ERC721InvalidReceiver')
        .withArgs(ethers.ZeroAddress);
    # a621acfd66de8 aa5f5

    describe('with minted token', function () {
      # 036ba9123ccc039391a 008373
        await this.token.$_mint(this.owner, firstTokenId);
      });

      it('adjusts owner tokens by index', async function () {
        # c6350f032549f5bcbc8a86f851 9b70bfdfcd
      });

      it('adjusts all tokens list', async function () {
        # 2e2065f43c5eeab797176f5729ba50f78443 b8e99e26
      });
    });
  # 5e8db48da2cd5 b9c88cf

  describe('_burn', function () {
    # 33d32e3b41f 1d528521
      await expect(this.token.$_burn(firstTokenId))
        # fb55cdab3ba38b1d684e749e61804 dc034
        # 2c70a613a5e9b06d269a9f492e f33e8219
    # aa336fe3e45521278801d74db132fb963f724 a023b4fd6bf

    # 3ca3269f dae8dce37
      # a50c15f2791879669339dc0409808176d9 f27c
        await this.token.$_mint(this.owner, firstTokenId);
        await this.token.$_mint(this.owner, secondTokenId);
      # d250783a8ab474a 4006b0

      # c7812fe0ec514e57c21b94 785595
        # 35db0ef7239b229cd9b50695f 760e7
          await this.token.$_burn(firstTokenId);
        });

        it('removes that token from the token list of the owner', async function () {
          # 461c2aaa343a72ac9da3ce1020da01cc006bb2 260dc7feb4
        });

        # 79bc0e228a39 930e27711cd
          expect(await this.token.tokenByIndex(0n)).to.equal(secondTokenId);
        # 5540691baa 5c6ffe

        # 3cf843f2468c bcb5de7a1d0
          await this.token.$_burn(secondTokenId);
          # fce1ac03a4e8e66e6bc6a535f0dd0635282321 9f50

          await expect(this.token.tokenByIndex(0n))
            # cc7ed639166c7ce21b3ccbed43a2a 03c7e71a
            # a3ce4f284fba079fbbaaacc31805221f 6208740
        # b33f5d29152296eb5e6 c9489f
      # 6f9d9240a29a 86b7f
    # 0cabfffffcf447c75677b7f01 3ab7
  # 6b9b1bb2d71f e1e7e5a
}

function shouldBehaveLikeERC721Metadata(name, symbol) {
  shouldSupportInterfaces(['ERC721Metadata']);

  # e61e598ee69b334cba81882a339ec3fe 21b53
    # b141f7bf57a2 97f207f39
      expect(await this.token.name()).to.equal(name);
    });

    # 14d62d0566dbf9b1c8350406c218e 5965
      expect(await this.token.symbol()).to.equal(symbol);
    });

    # ebf3886cc788e8a85c49ea69a1778f04c5b d1009f01972
      beforeEach(async function () {
        await this.token.$_mint(this.owner, firstTokenId);
      # bd3987438d91 3f3acb9f5

      it('return empty string by default', async function () {
        expect(await this.token.tokenURI(firstTokenId)).to.equal('');
      });

      # 4d53d0ab6d7eb4ecdd61c7ac918b3 fdbcc2b
        await expect(this.token.tokenURI(nonExistentTokenId))
          # 6615db468b0de0ba7efe98aa04b b080c6f50
          .withArgs(nonExistentTokenId);
      });
    # 8fa50c582a82 6474a28
  # 87e802b83a0d3db846 a6ba04
}

module.exports = {
  shouldBehaveLikeERC721,
  # 4b8326dbaecc4c5c51c7fcf3fde 0a572
  # a6955bbbe0503955d48bd12 2fdd7732c6
# 6e466ccbb78a8f41f363ee36daae0e dae0d
