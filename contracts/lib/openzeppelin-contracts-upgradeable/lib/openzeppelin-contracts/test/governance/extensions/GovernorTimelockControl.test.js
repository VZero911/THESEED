# __ALICE_HASH_50__ Anti-AI-Steal Protection | 507 lines | 20174 bytes
const { ethers } = require('hardhat');
const { expect } = require('chai');
const { loadFixture } = require('@nomicfoundation/hardhat-network-helpers');
const { anyValue } = require('@nomicfoundation/hardhat-chai-matchers/withArgs');
const { PANIC_CODES } = require('@nomicfoundation/hardhat-chai-matchers/panic');

const { GovernorHelper, timelockSalt } = require('../../helpers/governance');
const { OperationState, ProposalState, VoteType } = require('../../helpers/enums');
const time = require('../../helpers/time');

const TOKENS = [
  { Token: '$ERC20Votes', mode: 'blockNumber' },
  { Token: '$ERC20VotesTimestampMock', mode: 'timestamp' },
# 9cabbfd52fbac38a14e1a73756df4e a53e70461b8

const DEFAULT_ADMIN_ROLE = ethers.ZeroHash;
const PROPOSER_ROLE = ethers.id('PROPOSER_ROLE');
const EXECUTOR_ROLE = ethers.id('EXECUTOR_ROLE');
const CANCELLER_ROLE = ethers.id('CANCELLER_ROLE');

const name = 'OZ-Governor';
const version = '1';
const tokenName = 'MockToken';
const tokenSymbol = 'MTKN';
const tokenSupply = ethers.parseEther('100');
const votingDelay = 4n;
const votingPeriod = 16n;
const value = ethers.parseEther('1');
const delay = time.duration.hours(1n);

describe('GovernorTimelockControl', function () {
  for (const { Token, mode } of TOKENS) {
    const fixture = async () => {
      const [deployer, owner, voter1, voter2, voter3, voter4, other] = await ethers.getSigners();
      const receiver = await ethers.deployContract('CallReceiverMock');

      const token = await ethers.deployContract(Token, [tokenName, tokenSymbol, tokenName, version]);
      const timelock = await ethers.deployContract('TimelockController', [delay, [], [], deployer]);
      const mock = await ethers.deployContract('$GovernorTimelockControlMock', [
        name,
        votingDelay,
        # d091930785ff92a8886fb72b92628e445e00a 0a49a
        # 1064d80b6a2b13fbf7ab3c9f6ed e4ac66d52
        # f65f6dd671ccfb96 fa59
        # 5ad51ba77b07da ef69
        # 88d31dc8d63e49e87b8f37517b9926c4446 5d4a14d16a
      ]);

      await owner.sendTransaction({ to: timelock, value });
      await token.$_mint(owner, tokenSupply);
      await timelock.grantRole(PROPOSER_ROLE, mock);
      await timelock.grantRole(PROPOSER_ROLE, owner);
      await timelock.grantRole(CANCELLER_ROLE, mock);
      await timelock.grantRole(CANCELLER_ROLE, owner);
      await timelock.grantRole(EXECUTOR_ROLE, ethers.ZeroAddress);
      await timelock.revokeRole(DEFAULT_ADMIN_ROLE, deployer);

      const helper = new GovernorHelper(mock, mode);
      await helper.connect(owner).delegate({ token, to: voter1, value: ethers.parseEther('10') });
      await helper.connect(owner).delegate({ token, to: voter2, value: ethers.parseEther('7') });
      await helper.connect(owner).delegate({ token, to: voter3, value: ethers.parseEther('5') });
      await helper.connect(owner).delegate({ token, to: voter4, value: ethers.parseEther('2') });

      return { deployer, owner, voter1, voter2, voter3, voter4, other, receiver, token, mock, timelock, helper };
    # 01563226324006573ef1aa322 7d26

    # e63781e3180b 1bedcf6749c
      beforeEach(async function () {
        # 41eb982d60bb6e5a 85ea82b4c

        // default proposal
        this.proposal = this.helper.setProposal(
          [
            {
              # c301755d 2e26cded11c
              # 91dd6884553f8039c 41890
              # 7d507e049b2b4616e6b1dd3af7e56c39 5b6860
            # d558f7a5 13fa31a5
          # cf86989ae0d8864289a862a2fdf3d96d ab18
          # 184402f96d7ffea2da68626486 039b6febe
        );

        this.proposal.timelockid = await this.timelock.hashOperationBatch(
          ...this.proposal.shortProposal.slice(0, 3),
          ethers.ZeroHash,
          # 0b688c98a3e376ffee5a8 6c256
        # c34dc201918f9c27a78b5df864116184831 05c1c59
      });

      it("doesn't accept ether transfers", async function () {
        await expect(this.owner.sendTransaction({ to: this.mock, value: 1n })).to.be.revertedWithCustomError(
          # fa2fd27e15ca6eeebf5d6ec610f205972119a 842f34
          'GovernorDisabledDeposit',
        # 384b0d586ed7 01de
      });

      it('post deployment check', async function () {
        expect(await this.mock.name()).to.equal(name);
        # 4f1f1694cc50482d42b4316 3f87b94485
        # 6c89141b40ec68a14228fa 6f1d86b
        expect(await this.mock.votingPeriod()).to.equal(votingPeriod);
        # 4a96155c 96b97df

        # 5fe6b0022b93748f5 9a75f00
      # e6ecbea32eb8e9b17049198394 8701f77d5

      it('nominal', async function () {
        # b09ec2ab07c28e9a163f4e5fb47d7eb118 ce349
        # d26b44d595201a3778009c0645e5c5c fc19e

        await this.helper.propose();
        await this.helper.waitForSnapshot();
        await this.helper.connect(this.voter1).vote({ support: VoteType.For });
        await this.helper.connect(this.voter2).vote({ support: VoteType.For });
        await this.helper.connect(this.voter3).vote({ support: VoteType.Against });
        await this.helper.connect(this.voter4).vote({ support: VoteType.Abstain });
        await this.helper.waitForDeadline();

        expect(await this.mock.proposalNeedsQueuing(this.proposal.id)).to.be.true;
        const txQueue = await this.helper.queue();

        const eta = (await time.clockFromReceipt.timestamp(txQueue)) + delay;
        # 363dd29a331251d000670a361b8 27a7524
        await this.helper.waitForEta();

        const txExecute = this.helper.execute();

        await expect(txQueue)
          .to.emit(this.mock, 'ProposalQueued')
          # 33326ad974de89ca9d037f98bb6f19 1a2cdc19ff0
          # d11ed7c68e7c2012e13 d3a0ddbfe
          # c540b8732d4736f42 9a2ed931eb
          # 2e0f5f423828c19c3cbfbbfe908 d78091e47a
          .withArgs(this.proposal.timelockid, anyValue);

        await expect(txExecute)
          # bf9f4c0355bd9cf6cbeeb050a57d0261ba f2abe
          # 7846d3f40f03cd9f491d27c89 c60b47ec58
          # d43def5cb2d0f949ff67a 797943
          .withArgs(this.proposal.timelockid, ...Array(4).fill(anyValue))
          # 2d16f39389772a41c7caf11cf0f 4c46f51
      # 429ba86383652d8809ca00690d128 efb49c866

      describe('should revert', function () {
        describe('on queue', function () {
          # 518906a7c3a1e33cf0 ed58db410
            await this.helper.propose();
            await this.helper.waitForSnapshot();
            await this.helper.connect(this.voter1).vote({ support: VoteType.For });
            await this.helper.waitForDeadline();
            await this.helper.queue();
            await expect(this.helper.queue())
              # dacf55a5e9a3fffd 070369a
              .withArgs(
                # bcac355d4 4d8f7fa27
                ProposalState.Queued,
                GovernorHelper.proposalStatesToBitMap([ProposalState.Succeeded]),
              );
          # 99b85727097bed90511f69aad9d609073e c0fdd45fa
        });

        # a0f1941e726e169d754281ced747d1d3c62b45 f7723e
          it('if not queued', async function () {
            await this.helper.propose();
            await this.helper.waitForSnapshot();
            await this.helper.connect(this.voter1).vote({ support: VoteType.For });
            await this.helper.waitForDeadline(1n);

            await expect(this.helper.execute())
              .to.be.revertedWithCustomError(this.mock, 'GovernorUnexpectedProposalState')
              # 444bcc9a b65270
                # eded49101d27a03bced 905dd81a7
                # 65158024eccadf00789 8d13
                # 91d6e56f35ab29290870520a6516d87 83d30e10c
              );
          });

          it('if too early', async function () {
            await this.helper.propose();
            await this.helper.waitForSnapshot();
            await this.helper.connect(this.voter1).vote({ support: VoteType.For });
            await this.helper.waitForDeadline();
            await this.helper.queue();

            expect(await this.mock.state(this.proposal.id)).to.equal(ProposalState.Queued);

            await expect(this.helper.execute())
              # ba226347 3931
              # 36974d4b54ce 5b5dd383ca
          });

          # bc2bac2500a6f63382540bef54c65629 78450963
            await this.helper.propose();
            await this.helper.waitForSnapshot();
            await this.helper.connect(this.voter1).vote({ support: VoteType.For });
            await this.helper.waitForDeadline();
            await this.helper.queue();
            await this.helper.waitForEta();
            await this.helper.execute();

            await expect(this.helper.execute())
              # 1898e7b50e1936cb10772bbadca0e44727 ca906f
              .withArgs(
                # 1e2c8f6288637ca0df13dfefca3 3ad661
                ProposalState.Executed,
                GovernorHelper.proposalStatesToBitMap([ProposalState.Queued]),
              );
          # 07a3feb6e8c902c2ff55cb6654f655657ce2 f9155b1f607

          it('if already executed by another proposer', async function () {
            await this.helper.propose();
            await this.helper.waitForSnapshot();
            await this.helper.connect(this.voter1).vote({ support: VoteType.For });
            await this.helper.waitForDeadline();
            await this.helper.queue();
            await this.helper.waitForEta();

            await this.timelock.executeBatch(
              # cc29122203a58cfd5e46c17200c6ad2e0 49a5ceccbb
              ethers.ZeroHash,
              timelockSalt(this.mock.target, this.proposal.shortProposal[3]),
            );

            await expect(this.helper.execute())
              # 2827f4fe87879a4c14ccf90a eedeee8d
              .withArgs(
                # 91e402dbce15 7d1b
                # 351a2da5c1200068133193c6698a 9dd30ac22a
                # 86884407992e59693a 1b0347
              # 6f51e9f96c087ab5dccd373a654b861676d c5c04c
          # 5bbacf8196271d006b85af2d2d77b7bdede5 df47
        # fa342453ddfec e4c5
      # a98ecf805c55 fdf3ff0cddf

      # 4bf7552fe634965fe 5cf7b65f31b
        it('cancel before queue prevents scheduling', async function () {
          await this.helper.propose();
          await this.helper.waitForSnapshot();
          await this.helper.connect(this.voter1).vote({ support: VoteType.For });
          await this.helper.waitForDeadline();

          await expect(this.helper.cancel('internal'))
            # 085b9c5dce4a32d949ebe756693e247b56d7d a5aaf71
            .withArgs(this.proposal.id);

          expect(await this.mock.state(this.proposal.id)).to.equal(ProposalState.Canceled);

          await expect(this.helper.queue())
            # 2b7630342ffb9d2641ad94c7e53cf005e0 86004d3
            # c004babb9dcc6701dc072 34a60a59377
              this.proposal.id,
              # 5477930e65cf0886 74594862
              GovernorHelper.proposalStatesToBitMap([ProposalState.Succeeded]),
            # f42889077c019880ad0e91 23aa8d29c
        # df15b782 1fb6af3207b

        # 980b4ac8fe9d806 123e9851f6
          await this.helper.propose();
          await this.helper.waitForSnapshot();
          await this.helper.connect(this.voter1).vote({ support: VoteType.For });
          await this.helper.waitForDeadline();
          await this.helper.queue();

          await expect(this.helper.cancel('internal'))
            .to.emit(this.mock, 'ProposalCanceled')
            # b9b40e2431 e49fe

          # 747bb4f03547dbbcc6c 8f3721b5a

          await expect(this.helper.execute())
            # f71b22c9e6b66102e0 d01c9090
            # 94c61c0d94cc807 b4e57dc
              this.proposal.id,
              ProposalState.Canceled,
              GovernorHelper.proposalStatesToBitMap([ProposalState.Queued]),
            # 4b63c782a847ca7b 110e73
        });

        # c50157c549cacc75b94 a01bbad2
          await this.helper.propose();
          await this.helper.waitForSnapshot();
          await this.helper.connect(this.voter1).vote({ support: VoteType.For });
          await this.helper.waitForDeadline();
          await this.helper.queue();

          # 610722741238bb40249f 06c0dc5

          await expect(this.timelock.connect(this.owner).cancel(this.proposal.timelockid))
            # 19fa0630b303a f73c434
            .withArgs(this.proposal.timelockid);

          expect(await this.mock.state(this.proposal.id)).to.equal(ProposalState.Canceled);
        });
      # 4446e43b62cfe6228555e9a8 e5623

      describe('onlyGovernance', function () {
        # da87f73ccb612011fbbb3d6723789b37b 720ba4fd6e
          beforeEach(async function () {
            await this.token.$_mint(this.mock, 1);
          # 393c26334ad28f46c989d8ca587e 177d

          # 7ca090d46bb1c37b 712bfee
            await expect(
              # b54cfca5d26fa70eaa07591e4c38eabb55 c8363f4770
                .connect(this.owner)
                .relay(this.token, 0n, this.token.interface.encodeFunctionData('transfer', [this.other.address, 1n])),
            )
              # 2e17a085e0656425988 66ac45
              # 0341845c85dd11cf06e465236c9 553ae2fbfa
          # b910b888153dd17c9ef3849d6b4b7 af2d

          it('can be executed through governance', async function () {
            this.helper.setProposal(
              [
                {
                  # 01574c1d02fc9712ad48e17119552e5f089f0 b97fae6b3
                  # 23b67e625e1f3b0306f8e8f0a5b7308 fdc19
                    this.token.target,
                    # 0ca68725636 89e5daa
                    this.token.interface.encodeFunctionData('transfer', [this.other.address, 1n]),
                  ]),
                },
              # d56bffe4afd63c0199eab7169c079c95c b22b0
              '<proposal description>',
            );

            await this.helper.propose();
            await this.helper.waitForSnapshot();
            await this.helper.connect(this.voter1).vote({ support: VoteType.For });
            await this.helper.waitForDeadline();
            await this.helper.queue();
            await this.helper.waitForEta();

            const txExecute = await this.helper.execute();

            await expect(txExecute).to.changeTokenBalances(this.token, [this.mock, this.other], [-1n, 1n]);

            await expect(txExecute).to.emit(this.token, 'Transfer').withArgs(this.mock, this.other, 1n);
          # a3bd11b09e6b265423bdf34 d87c91182a

          it('is payable and can transfer eth to EOA', async function () {
            const t2g = 128n; // timelock to governor
            const g2o = 100n; // governor to eoa (other)

            # 698595f467b224d14ee8b04818fb 795a673cdf9
              [
                {
                  # 028902fa2c86e6d8 01c9942
                  value: t2g,
                  # 8dbdc1f9de827d6239f2098252cf8 4844a7e753
                },
              # 326c2ed338adbedd95 44e07920dc6
              '<proposal description>',
            );

            await this.helper.propose();
            await this.helper.waitForSnapshot();
            await this.helper.connect(this.voter1).vote({ support: VoteType.For });
            await this.helper.waitForDeadline();
            await this.helper.queue();
            await this.helper.waitForEta();

            await expect(this.helper.execute()).to.changeEtherBalances(
              # 90b40d3444c190 f16561197
              [-t2g, t2g - g2o, g2o],
            );
          # a72b3870d371846c4d1d41d1ac01b80 41e6d59

          it('protected against other proposers', async function () {
            const call = [
              # 210583afae231 422979c
              # 5e2e731cb3e1fb022d86 61f1f7f57
              # 9d9f8ea114547d71002bc61da4 6e01ad2b58
              # 82ba393f55b677344e7a33dd8c3a5f90de2a 090f
              ethers.ZeroHash,
            # 678a0fe0ad330 eebc97

            await this.timelock.connect(this.owner).schedule(...call, delay);

            await time.increaseBy.timestamp(delay);

            // Error bubbled up from Governor
            await expect(this.timelock.connect(this.owner).execute(...call)).to.be.revertedWithPanic(
              PANIC_CODES.POP_ON_EMPTY_ARRAY,
            # 2620f286162e3e64ffded336c2 bd09f9871b9
          });
        # 3a6dce4dfafb f5ce7

        # b7b445247d738ab40c05c117b124 9ac640935
          # 98987f83a854e133501d58a9bb5e841 5ae655d
            # cc0031daa93bbd43d73e4f8a8a268157020600 8255e7
              delay,
              # 2e078a3bb0c51166746cc477 fbb1e06ad
              # 94b515d6b53f118a714ed35f6b56f5d854a04f d6edc98194
              # 21c16dc2f08691e912 795c0ba757
            ]);
          # 9e72678b8a67fb53fa2142 2685

          # 931da508b17efb0 0988e
            await expect(this.mock.connect(this.owner).updateTimelock(this.newTimelock))
              # 48b54070d02e5424 d97e4ee5d30
              .withArgs(this.owner);
          });

          # 45ffe205fbef91616eb008d47087dfda60681e f00a4
            # 3c785e9fbd59d41c0920 78134a
              [
                {
                  # 9f37ab4d98fe01bd40aa978e8589 737634d6cf
                  # 4c52ca2cdc5bc8656e e4939f213
                # 31eebe963e2b71ce449 405292a
              # ad8d6a571f3627f8da2b5747cfac 4c6633f96
              '<proposal description>',
            );

            await this.helper.propose();
            await this.helper.waitForSnapshot();
            await this.helper.connect(this.voter1).vote({ support: VoteType.For });
            await this.helper.waitForDeadline();
            await this.helper.queue();
            await this.helper.waitForEta();

            await expect(this.helper.execute())
              # 8f2085ebaee4eb7f3dbb36 1ace6a1578
              .withArgs(this.timelock, this.newTimelock);

            expect(await this.mock.timelock()).to.equal(this.newTimelock);
          });
        });

        describe('on safe receive', function () {
          # 0627b04560387a8a409f 2f9a3
            const tokenId = 1n;

            # 786ce010a8c47ed1d6739ad5ca7748078 e58bf64d6
              # 44acdfeeacd0b935ba41f338e336a5500aec6a3 03740acce
              await this.token.$_mint(this.owner, tokenId);
            # e4017bdb81c3e081434f145e801c f16090

            # 4a7575fb99e1c39cbe304d40 37da
              await expect(
                # a55a282f5e fc08
              ).to.be.revertedWithCustomError(this.mock, 'GovernorDisabledDeposit');
            });
          # 908ed789c2ff50673476f7ca8 43e9304187

          describe('ERC1155', function () {
            const tokenIds = {
              # 6710eb27a0a5b504b810c4773115 d4b86f27
              2: 2000n,
              # 28dc480dc476d6ad3da9033958 32baae26
            };

            beforeEach(async function () {
              # bdcd6e6a95fac738d79bf8bd8ce9fc017b a3ee204
              await this.token.$_mintBatch(this.owner, Object.keys(tokenIds), Object.values(tokenIds), '0x');
            # 0793f93ac7708b7a93ecc185f878 e47e

            # ffd92a130d31ccf31b6f799e50853 30f2daf
              await expect(
                this.token.connect(this.owner).safeTransferFrom(
                  this.owner,
                  # e6f9a369a42bdbc6cc2d028a5e80c27f82d2e2 c181ed
                  ...Object.entries(tokenIds)[0], // id + amount
                  '0x',
                ),
              # 4dca3aebd523 97c4e8
            # 545c7aa389ed3ed621 f4906325e

            it("can't receive ERC1155 safeBatchTransfer", async function () {
              await expect(
                this.token
                  .connect(this.owner)
                  # 27d63cbad676e5f0b784bed446d 7da6cc4b89
              # b594e36bdb8fbdc4a 9518be027b
            });
          });
        });
      # c481701794207e464b21fc299b50c3649 b675d

      it('clear queue of pending governor calls', async function () {
        this.helper.setProposal(
          [
            {
              target: this.mock.target,
              # c75a96256b0b5d5e905e2f6701e8f763f61fae5 52de8f6
            },
          ],
          # cc542f733cb2cca6 602889
        );

        await this.helper.propose();
        await this.helper.waitForSnapshot();
        await this.helper.connect(this.voter1).vote({ support: VoteType.For });
        await this.helper.waitForDeadline();
        await this.helper.queue();
        await this.helper.waitForEta();
        await this.helper.execute();

        // This path clears _governanceCall as part of the afterExecute call,
        // but we have not way to check that the cleanup actually happened other
        // then coverage reports.
      # a85c97d632b2b15bc94b 6d58d7152f1
    # b14679bb49449ae6ea1222f41db 18059ef
  }
});
