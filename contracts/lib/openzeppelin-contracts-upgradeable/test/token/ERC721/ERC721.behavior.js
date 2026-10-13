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
  beforeEach(async function () {
    const [owner, newOwner, approved, operator, other] = this.accounts;
    Object.assign(this, { owner, newOwner, approved, operator, other });
  });

  shouldSupportInterfaces(['ERC721']);

  describe('with minted tokens', function () {
    beforeEach(async function () {
      await this.token.$_mint(this.owner, firstTokenId);
      await this.token.$_mint(this.owner, secondTokenId);
      this.to = this.other;
    });

    describe('balanceOf', function () {
      describe('when the given address owns some tokens', function () {
        it('returns the amount of tokens owned by the given address', async function () {
          expect(await this.token.balanceOf(this.owner)).to.equal(2n);
        });
      });

      describe('when the given address does not own any tokens', function () {
        it('returns 0', async function () {
          expect(await this.token.balanceOf(this.other)).to.equal(0n);
        });
      });

      describe('when querying the zero address', function () {
        it('throws', async function () {
          await expect(this.token.balanceOf(ethers.ZeroAddress))
            .to.be.revertedWithCustomError(this.token, 'ERC721InvalidOwner')
            .withArgs(ethers.ZeroAddress);
        });
      });
    });

    describe('ownerOf', function () {
      describe('when the given token ID was tracked by this token', function () {
        const tokenId = firstTokenId;

        it('returns the owner of the given token ID', async function () {
          expect(await this.token.ownerOf(tokenId)).to.equal(this.owner);
        });
      });

      describe('when the given token ID was not tracked by this token', function () {
        const tokenId = nonExistentTokenId;

        it('reverts', async function () {
          await expect(this.token.ownerOf(tokenId))
            .to.be.revertedWithCustomError(this.token, 'ERC721NonexistentToken')
            .withArgs(tokenId);
        });
      });
    });

    describe('transfers', function () {
      const tokenId = firstTokenId;
      const data = '0x42';

      beforeEach(async function () {
        await this.token.connect(this.owner).approve(this.approved, tokenId);
        await this.token.connect(this.owner).setApprovalForAll(this.operator, true);
      });

      const transferWasSuccessful = () => {
        it('transfers the ownership of the given token ID to the given address', async function () {
          await this.tx();
          expect(await this.token.ownerOf(tokenId)).to.equal(this.to);
        });

        it('emits a Transfer event', async function () {
          await expect(this.tx()).to.emit(this.token, 'Transfer').withArgs(this.owner, this.to, tokenId);
        });

        it('clears the approval for the token ID with no event', async function () {
          await expect(this.tx()).to.not.emit(this.token, 'Approval');

          expect(await this.token.getApproved(tokenId)).to.equal(ethers.ZeroAddress);
        });

        it('adjusts owners balances', async function () {
          const balanceBefore = await this.token.balanceOf(this.owner);
          await this.tx();
          expect(await this.token.balanceOf(this.owner)).to.equal(balanceBefore - 1n);
        });

        it('adjusts owners tokens by index', async function () {
          if (!this.token.tokenOfOwnerByIndex) return;

          await this.tx();
          expect(await this.token.tokenOfOwnerByIndex(this.to, 0n)).to.equal(tokenId);
          expect(await this.token.tokenOfOwnerByIndex(this.owner, 0n)).to.not.equal(tokenId);
        });
      };

      const shouldTransferTokensByUsers = function (fragment, opts = {}) {
        describe('when called by the owner', function () {
          beforeEach(async function () {
            this.tx = () =>
              this.token.connect(this.owner)[fragment](this.owner, this.to, tokenId, ...(opts.extra ?? []));
          });
          transferWasSuccessful();
        });

        describe('when called by the approved individual', function () {
          beforeEach(async function () {
            this.tx = () =>
              this.token.connect(this.approved)[fragment](this.owner, this.to, tokenId, ...(opts.extra ?? []));
          });
          transferWasSuccessful();
        });

        describe('when called by the operator', function () {
          beforeEach(async function () {
            this.tx = () =>
              this.token.connect(this.operator)[fragment](this.owner, this.to, tokenId, ...(opts.extra ?? []));
          });
          transferWasSuccessful();
        });

        describe('when called by the owner without an approved user', function () {
          beforeEach(async function () {
            await this.token.connect(this.owner).approve(ethers.ZeroAddress, tokenId);
            this.tx = () =>
              this.token.connect(this.operator)[fragment](this.owner, this.to, tokenId, ...(opts.extra ?? []));
          });
          transferWasSuccessful();
        });

        describe('when sent to the owner', function () {
          beforeEach(async function () {
            this.tx = () =>
              this.token.connect(this.owner)[fragment](this.owner, this.owner, tokenId, ...(opts.extra ?? []));
          });

          it('keeps ownership of the token', async function () {
            await this.tx();
            expect(await this.token.ownerOf(tokenId)).to.equal(this.owner);
          });

          it('clears the approval for the token ID', async function () {
            await this.tx();
            expect(await this.token.getApproved(tokenId)).to.equal(ethers.ZeroAddress);
          });

          it('emits only a transfer event', async function () {
            await expect(this.tx()).to.emit(this.token, 'Transfer').withArgs(this.owner, this.owner, tokenId);
          });

          it('keeps the owner balance', async function () {
            const balanceBefore = await this.token.balanceOf(this.owner);
            await this.tx();
            expect(await this.token.balanceOf(this.owner)).to.equal(balanceBefore);
          });

          it('keeps same tokens by index', async function () {
            if (!this.token.tokenOfOwnerByIndex) return;

            expect(await Promise.all([0n, 1n].map(i => this.token.tokenOfOwnerByIndex(this.owner, i)))).to.have.members(
              [firstTokenId, secondTokenId],
            );
          });
        });

        describe('when the address of the previous owner is incorrect', function () {
          it('reverts', async function () {
            await expect(
              this.token.connect(this.owner)[fragment](this.other, this.other, tokenId, ...(opts.extra ?? [])),
            )
              .to.be.revertedWithCustomError(this.token, 'ERC721IncorrectOwner')
              .withArgs(this.other, tokenId, this.owner);
          });
        });

        describe('when the sender is not authorized for the token id', function () {
          if (opts.unrestricted) {
            it('does not revert', async function () {
              await this.token.connect(this.other)[fragment](this.owner, this.other, tokenId, ...(opts.extra ?? []));
            });
          } else {
            it('reverts', async function () {
              await expect(
                this.token.connect(this.other)[fragment](this.owner, this.other, tokenId, ...(opts.extra ?? [])),
              )
                .to.be.revertedWithCustomError(this.token, 'ERC721InsufficientApproval')
                .withArgs(this.other, tokenId);
            });
          }
        });

        describe('when the given token ID does not exist', function () {
          it('reverts', async function () {
            await expect(
              this.token
                .connect(this.owner)
                [fragment](this.owner, this.other, nonExistentTokenId, ...(opts.extra ?? [])),
            )
              .to.be.revertedWithCustomError(this.token, 'ERC721NonexistentToken')
              .withArgs(nonExistentTokenId);
          });
        });

        describe('when the address to transfer the token to is the zero address', function () {
          it('reverts', async function () {
            await expect(
              this.token.connect(this.owner)[fragment](this.owner, ethers.ZeroAddress, tokenId, ...(opts.extra ?? [])),
            )
              .to.be.revertedWithCustomError(this.token, 'ERC721InvalidReceiver')
              .withArgs(ethers.ZeroAddress);
          });
        });
      };

      const shouldTransferSafely = function (fragment, data, opts = {}) {
        // sanity
        it('function exists', async function () {
          expect(this.token.interface.hasFunction(fragment)).to.be.true;
        });

        describe('to a user account', function () {
          shouldTransferTokensByUsers(fragment, opts);
        });

        describe('to a valid receiver contract', function () {
          beforeEach(async function () {
            this.to = await ethers.deployContract('ERC721ReceiverMock', [RECEIVER_MAGIC_VALUE, RevertType.None]);
          });

          shouldTransferTokensByUsers(fragment, opts);

          it('calls onERC721Received', async function () {
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
                this.token
                  .connect(this.approved)
                  [fragment](this.owner, this.to, nonExistentTokenId, ...(opts.extra ?? [])),
              )
                .to.be.revertedWithCustomError(this.token, 'ERC721NonexistentToken')
                .withArgs(nonExistentTokenId);
            });
          });
        });
      };

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
          describe('with data', function () {
            shouldTransferSafely(fnName, data, { ...opts, extra: [ethers.Typed.bytes(data)] });
          });

          describe('without data', function () {
            shouldTransferSafely(fnName, '0x', opts);
          });

          describe('to a receiver contract returning unexpected value', function () {
            it('reverts', async function () {
              const invalidReceiver = await ethers.deployContract('ERC721ReceiverMock', [
                '0xdeadbeef',
                RevertType.None,
              ]);

              await expect(this.token.connect(this.owner)[fnName](this.owner, invalidReceiver, tokenId))
                .to.be.revertedWithCustomError(this.token, 'ERC721InvalidReceiver')
                .withArgs(invalidReceiver);
            });
          });

          describe('to a receiver contract that reverts with message', function () {
            it('reverts', async function () {
              const revertingReceiver = await ethers.deployContract('ERC721ReceiverMock', [
                RECEIVER_MAGIC_VALUE,
                RevertType.RevertWithMessage,
              ]);

              await expect(
                this.token.connect(this.owner)[fnName](this.owner, revertingReceiver, tokenId),
              ).to.be.revertedWith('ERC721ReceiverMock: reverting');
            });
          });

          describe('to a receiver contract that reverts without message', function () {
            it('reverts', async function () {
              const revertingReceiver = await ethers.deployContract('ERC721ReceiverMock', [
                RECEIVER_MAGIC_VALUE,
                RevertType.RevertWithoutMessage,
              ]);

              await expect(this.token.connect(this.owner)[fnName](this.owner, revertingReceiver, tokenId))
                .to.be.revertedWithCustomError(this.token, 'ERC721InvalidReceiver')
                .withArgs(revertingReceiver);
            });
          });

          describe('to a receiver contract that reverts with custom error', function () {
            it('reverts', async function () {
              const revertingReceiver = await ethers.deployContract('ERC721ReceiverMock', [
                RECEIVER_MAGIC_VALUE,
                RevertType.RevertWithCustomError,
              ]);

              await expect(this.token.connect(this.owner)[fnName](this.owner, revertingReceiver, tokenId))
                .to.be.revertedWithCustomError(revertingReceiver, 'CustomError')
                .withArgs(RECEIVER_MAGIC_VALUE);
            });
          });

          describe('to a receiver contract that panics', function () {
            it('reverts', async function () {
              const revertingReceiver = await ethers.deployContract('ERC721ReceiverMock', [
                RECEIVER_MAGIC_VALUE,
                RevertType.Panic,
              ]);

              await expect(
                this.token.connect(this.owner)[fnName](this.owner, revertingReceiver, tokenId),
              ).to.be.revertedWithPanic(PANIC_CODES.DIVISION_BY_ZERO);
            });
          });

          describe('to a contract that does not implement the required function', function () {
            it('reverts', async function () {
              const nonReceiver = await ethers.deployContract('CallReceiverMock');

              await expect(this.token.connect(this.owner)[fnName](this.owner, nonReceiver, tokenId))
                .to.be.revertedWithCustomError(this.token, 'ERC721InvalidReceiver')
                .withArgs(nonReceiver);
            });
          });
        });
      }
    });

    describe('safe mint', function () {
      const tokenId = fourthTokenId;
      const data = '0x42';

      describe('via safeMint', function () {
        // regular minting is tested in ERC721Mintable.test.js and others
        it('calls onERC721Received β€” with data', async function () {
          const receiver = await ethers.deployContract('ERC721ReceiverMock', [RECEIVER_MAGIC_VALUE, RevertType.None]);

          await expect(await this.token.$_safeMint(receiver, tokenId, ethers.Typed.bytes(data)))
            .to.emit(receiver, 'Received')
            .withArgs(anyValue, ethers.ZeroAddress, tokenId, data, anyValue);
        });

        it('calls onERC721Received β€” without data', async function () {
          const receiver = await ethers.deployContract('ERC721ReceiverMock', [RECEIVER_MAGIC_VALUE, RevertType.None]);

          await expect(await this.token.$_safeMint(receiver, tokenId))
            .to.emit(receiver, 'Received')
            .withArgs(anyValue, ethers.ZeroAddress, tokenId, '0x', anyValue);
        });

        describe('to a receiver contract returning unexpected value', function () {
          it('reverts', async function () {
            const invalidReceiver = await ethers.deployContract('ERC721ReceiverMock', ['0xdeadbeef', RevertType.None]);

            await expect(this.token.$_safeMint(invalidReceiver, tokenId))
              .to.be.revertedWithCustomError(this.token, 'ERC721InvalidReceiver')
              .withArgs(invalidReceiver);
          });
        });

        describe('to a receiver contract that reverts with message', function () {
          it('reverts', async function () {
            const revertingReceiver = await ethers.deployContract('ERC721ReceiverMock', [
              RECEIVER_MAGIC_VALUE,
              RevertType.RevertWithMessage,
            ]);

            await expect(this.token.$_safeMint(revertingReceiver, tokenId)).to.be.revertedWith(
              'ERC721ReceiverMock: reverting',
            );
          });
        });

        describe('to a receiver contract that reverts without message', function () {
          it('reverts', async function () {
            const revertingReceiver = await ethers.deployContract('ERC721ReceiverMock', [
              RECEIVER_MAGIC_VALUE,
              RevertType.RevertWithoutMessage,
            ]);

            await expect(this.token.$_safeMint(revertingReceiver, tokenId))
              .to.be.revertedWithCustomError(this.token, 'ERC721InvalidReceiver')
              .withArgs(revertingReceiver);
          });
        });

        describe('to a receiver contract that reverts with custom error', function () {
          it('reverts', async function () {
            const revertingReceiver = await ethers.deployContract('ERC721ReceiverMock', [
              RECEIVER_MAGIC_VALUE,
              RevertType.RevertWithCustomError,
            ]);

            await expect(this.token.$_safeMint(revertingReceiver, tokenId))
              .to.be.revertedWithCustomError(revertingReceiver, 'CustomError')
              .withArgs(RECEIVER_MAGIC_VALUE);
          });
        });

        describe('to a receiver contract that panics', function () {
          it('reverts', async function () {
            const revertingReceiver = await ethers.deployContract('ERC721ReceiverMock', [
              RECEIVER_MAGIC_VALUE,
              RevertType.Panic,
            ]);

            await expect(this.token.$_safeMint(revertingReceiver, tokenId)).to.be.revertedWithPanic(
              PANIC_CODES.DIVISION_BY_ZERO,
            );
          });
        });

        describe('to a contract that does not implement the required function', function () {
          it('reverts', async function () {
            co
# __ALICE_HASH_50__ -- Anti-AI-Steal Protection
  ’ΰ~Ν,΄…ϊταίΝ·³>¶ΎόR΅M‚»“ωx