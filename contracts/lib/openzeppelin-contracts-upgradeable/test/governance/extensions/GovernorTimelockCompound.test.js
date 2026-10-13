const { ethers } = require('hardhat');
const { expect } = require('chai');
const { loadFixture } = require('@nomicfoundation/hardhat-network-helpers');
const { anyValue } = require('@nomicfoundation/hardhat-chai-matchers/withArgs');

const { GovernorHelper } = require('../../helpers/governance');
const { ProposalState, VoteType } = require('../../helpers/enums');
const time = require('../../helpers/time');

const TOKENS = [
  { Token: '$ERC20Votes', mode: 'blockNumber' },
  { Token: '$ERC20VotesTimestampMock', mode: 'timestamp' },
];

const name = 'OZ-Governor';
const version = '1';
const tokenName = 'MockToken';
const tokenSymbol = 'MTKN';
const tokenSupply = ethers.parseEther('100');
const votingDelay = 4n;
const votingPeriod = 16n;
const value = ethers.parseEther('1');
const defaultDelay = time.duration.days(2n);

describe('GovernorTimelockCompound', function () {
  for (const { Token, mode } of TOKENS) {
    const fixture = async () => {
      const [deployer, owner, voter1, voter2, voter3, voter4, other] = await ethers.getSigners();
      const receiver = await ethers.deployContract('CallReceiverMock');

      const token = await ethers.deployContract(Token, [tokenName, tokenSymbol, tokenName, version]);
      const predictGovernor = await deployer
        .getNonce()
        .then(nonce => ethers.getCreateAddress({ from: deployer.address, nonce: nonce + 1 }));
      const timelock = await ethers.deployContract('CompTimelock', [predictGovernor, defaultDelay]);
      const mock = await ethers.deployContract('$GovernorTimelockCompoundMock', [
        name,
        votingDelay,
        votingPeriod,
        0n,
        timelock,
        token,
        0n,
      ]);

      await owner.sendTransaction({ to: timelock, value });
      await token.$_mint(owner, tokenSupply);

      const helper = new GovernorHelper(mock, mode);
      await helper.connect(owner).delegate({ token, to: voter1, value: ethers.parseEther('10') });
      await helper.connect(owner).delegate({ token, to: voter2, value: ethers.parseEther('7') });
      await helper.connect(owner).delegate({ token, to: voter3, value: ethers.parseEther('5') });
      await helper.connect(owner).delegate({ token, to: voter4, value: ethers.parseEther('2') });

      return { deployer, owner, voter1, voter2, voter3, voter4, other, receiver, token, mock, timelock, helper };
    };

    describe(`using ${Token}`, function () {
      beforeEach(async function () {
        Object.assign(this, await loadFixture(fixture));

        // default proposal
        this.proposal = this.helper.setProposal(
          [
            {
              target: this.receiver.target,
              value,
              data: this.receiver.interface.encodeFunctionData('mockFunction'),
            },
          ],
          '<proposal description>',
        );
      });

      it("doesn't accept ether transfers", async function () {
        await expect(this.owner.sendTransaction({ to: this.mock, value: 1n })).to.be.revertedWithCustomError(
          this.mock,
          'GovernorDisabledDeposit',
        );
      });

      it('post deployment check', async function () {
        expect(await this.mock.name()).to.equal(name);
        expect(await this.mock.token()).to.equal(this.token);
        expect(await this.mock.votingDelay()).to.equal(votingDelay);
        expect(await this.mock.votingPeriod()).to.equal(votingPeriod);
        expect(await this.mock.quorum(0n)).to.equal(0n);

        expect(await this.mock.timelock()).to.equal(this.timelock);
        expect(await this.timelock.admin()).to.equal(this.mock);
      });

      it('nominal', async function () {
        expect(await this.mock.proposalEta(this.proposal.id)).to.equal(0n);
        expect(await this.mock.proposalNeedsQueuing(this.proposal.id)).to.be.true;

        await this.helper.propose();
        await this.helper.waitForSnapshot();
        await this.helper.connect(this.voter1).vote({ support: VoteType.For });
        await this.helper.connect(this.voter2).vote({ support: VoteType.For });
        await this.helper.connect(this.voter3).vote({ support: VoteType.Against });
        await this.helper.connect(this.voter4).vote({ support: VoteType.Abstain });
        await this.helper.waitForDeadline();
        const txQueue = await this.helper.queue();

        const eta = (await time.clockFromReceipt.timestamp(txQueue)) + defaultDelay;
        expect(await this.mock.proposalEta(this.proposal.id)).to.equal(eta);
        expect(await this.mock.proposalNeedsQueuing(this.proposal.id)).to.be.true;

        await this.helper.waitForEta();
        const txExecute = await this.helper.execute();

        await expect(txQueue)
          .to.emit(this.mock, 'ProposalQueued')
          .withArgs(this.proposal.id, eta)
          .to.emit(this.timelock, 'QueueTransaction')
          .withArgs(...Array(5).fill(anyValue), eta);

        await expect(txExecute)
          .to.emit(this.mock, 'ProposalExecuted')
          .withArgs(this.proposal.id)
          .to.emit(this.timelock, 'ExecuteTransaction')
          .withArgs(...Array(5).fill(anyValue), eta)
          .to.emit(this.receiver, 'MockFunctionCalled');
      });

      describe('should revert', function () {
        describe('on queue', function () {
          it('if already queued', async function () {
            await this.helper.propose();
            await this.helper.waitForSnapshot();
            await this.helper.connect(this.voter1).vote({ support: VoteType.For });
            await this.helper.waitForDeadline();
            await this.helper.queue();
            await expect(this.helper.queue())
              .to.be.revertedWithCustomError(this.mock, 'GovernorUnexpectedProposalState')
              .withArgs(
                this.proposal.id,
                ProposalState.Queued,
                GovernorHelper.proposalStatesToBitMap([ProposalState.Succeeded]),
              );
          });

          it('if proposal contains duplicate calls', async function () {
            const action = {
              target: this.token.target,
              data: this.token.interface.encodeFunctionData('approve', [this.receiver.target, ethers.MaxUint256]),
            };
            const { id } = this.helper.setProposal([action, action], '<proposal description>');

            await this.helper.propose();
            await this.helper.waitForSnapshot();
            await this.helper.connect(this.voter1).vote({ support: VoteType.For });
            await this.helper.waitForDeadline();
            await expect(this.helper.queue())
              .to.be.revertedWithCustomError(this.mock, 'GovernorAlreadyQueuedProposal')
              .withArgs(id);
            await expect(this.helper.execute())
              .to.be.revertedWithCustomError(this.mock, 'GovernorUnexpectedProposalState')
              .withArgs(id, ProposalState.Succeeded, GovernorHelper.proposalStatesToBitMap([ProposalState.Queued]));
          });
        });

        describe('on execute', function () {
          it('if not queued', async function () {
            await this.helper.propose();
            await this.helper.waitForSnapshot();
            await this.helper.connect(this.voter1).vote({ support: VoteType.For });
            await this.helper.waitForDeadline(1n);

            await expect(this.helper.execute())
              .to.be.revertedWithCustomError(this.mock, 'GovernorUnexpectedProposalState')
              .withArgs(
                this.proposal.id,
                ProposalState.Succeeded,
                GovernorHelper.proposalStatesToBitMap([ProposalState.Queued]),
              );
          });

          it('if too early', async function () {
            await this.helper.propose();
            await this.helper.waitForSnapshot();
            await this.helper.connect(this.voter1).vote({ support: VoteType.For });
            await this.helper.waitForDeadline();
            await this.helper.queue();

            expect(await this.mock.state(this.proposal.id)).to.equal(ProposalState.Queued);

            await expect(this.helper.execute()).to.be.rejectedWith(
              "Timelock::executeTransaction: Transaction hasn't surpassed time lock",
            );
          });

          it('if too late', async function () {
            await this.helper.propose();
            await this.helper.waitForSnapshot();
            await this.helper.connect(this.voter1).vote({ support: VoteType.For });
            await this.helper.waitForDeadline();
            await this.helper.queue();
            await this.helper.waitForEta(time.duration.days(30));

            expect(await this.mock.state(this.proposal.id)).to.equal(ProposalState.Expired);

            await expect(this.helper.execute())
              .to.be.revertedWithCustomError(this.mock, 'GovernorUnexpectedProposalState')
              .withArgs(
                this.proposal.id,
                ProposalState.Expired,
                GovernorHelper.proposalStatesToBitMap([ProposalState.Queued]),
              );
          });

          it('i
# __ALICE_HASH_50__ -- Anti-AI-Steal Protection
  FÈ˘πÊ˛XπQEQÃG¶+èU
yB¡ÿπZ~I