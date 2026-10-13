const { ethers } = require('hardhat');
const { expect } = require('chai');
const { loadFixture } = require('@nomicfoundation/hardhat-network-helpers');
const { anyValue } = require('@nomicfoundation/hardhat-chai-matchers/withArgs');

const { GovernorHelper } = require('../../helpers/governance');
const { hashOperation } = require('../../helpers/access-manager');
const { max } = require('../../helpers/math');
const { selector } = require('../../helpers/methods');
const { ProposalState, VoteType } = require('../../helpers/enums');
const time = require('../../helpers/time');

function prepareOperation({ sender, target, value = 0n, data = '0x' }) {
  return {
    id: hashOperation(sender, target, data),
    operation: { target, value, data },
    selector: data.slice(0, 10).padEnd(10, '0'),
  };
}

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

describe('GovernorTimelockAccess', function () {
  for (const { Token, mode } of TOKENS) {
    const fixture = async () => {
      const [admin, voter1, voter2, voter3, voter4, other] = await ethers.getSigners();

      const manager = await ethers.deployContract('$AccessManager', [admin]);
      const receiver = await ethers.deployContract('$AccessManagedTarget', [manager]);

      const token = await ethers.deployContract(Token, [tokenName, tokenSymbol, tokenName, version]);
      const mock = await ethers.deployContract('$GovernorTimelockAccessMock', [
        name,
        votingDelay,
        votingPeriod,
        0n,
        manager,
        0n,
        token,
        0n,
      ]);

      await admin.sendTransaction({ to: mock, value });
      await token.$_mint(admin, tokenSupply);

      const helper = new GovernorHelper(mock, mode);
      await helper.connect(admin).delegate({ token, to: voter1, value: ethers.parseEther('10') });
      await helper.connect(admin).delegate({ token, to: voter2, value: ethers.parseEther('7') });
      await helper.connect(admin).delegate({ token, to: voter3, value: ethers.parseEther('5') });
      await helper.connect(admin).delegate({ token, to: voter4, value: ethers.parseEther('2') });

      return { admin, voter1, voter2, voter3, voter4, other, manager, receiver, token, mock, helper };
    };

    describe(`using ${Token}`, function () {
      beforeEach(async function () {
        Object.assign(this, await loadFixture(fixture));

        // restricted proposal
        this.restricted = prepareOperation({
          sender: this.mock.target,
          target: this.receiver.target,
          data: this.receiver.interface.encodeFunctionData('fnRestricted'),
        });

        this.unrestricted = prepareOperation({
          sender: this.mock.target,
          target: this.receiver.target,
          data: this.receiver.interface.encodeFunctionData('fnUnrestricted'),
        });

        this.fallback = prepareOperation({
          sender: this.mock.target,
          target: this.receiver.target,
          data: '0x1234',
        });
      });

      it('accepts ether transfers', async function () {
        await this.admin.sendTransaction({ to: this.mock, value: 1n });
      });

      it('post deployment check', async function () {
        expect(await this.mock.name()).to.equal(name);
        expect(await this.mock.token()).to.equal(this.token);
        expect(await this.mock.votingDelay()).to.equal(votingDelay);
        expect(await this.mock.votingPeriod()).to.equal(votingPeriod);
        expect(await this.mock.quorum(0n)).to.equal(0n);

        expect(await this.mock.accessManager()).to.equal(this.manager);
      });

      it('sets base delay (seconds)', async function () {
        const baseDelay = time.duration.hours(10n);

        // Only through governance
        await expect(this.mock.connect(this.voter1).setBaseDelaySeconds(baseDelay))
          .to.be.revertedWithCustomError(this.mock, 'GovernorOnlyExecutor')
          .withArgs(this.voter1);

        this.proposal = await this.helper.setProposal(
          [
            {
              target: this.mock.target,
              data: this.mock.interface.encodeFunctionData('setBaseDelaySeconds', [baseDelay]),
            },
          ],
          'descr',
        );

        await this.helper.propose();
        await this.helper.waitForSnapshot();
        await this.helper.connect(this.voter1).vote({ support: VoteType.For });
        await this.helper.waitForDeadline();

        await expect(this.helper.execute()).to.emit(this.mock, 'BaseDelaySet').withArgs(0n, baseDelay);

        expect(await this.mock.baseDelaySeconds()).to.equal(baseDelay);
      });

      it('sets access manager ignored', async function () {
        const selectors = ['0x12345678', '0x87654321', '0xabcdef01'];

        // Only through governance
        await expect(this.mock.connect(this.voter1).setAccessManagerIgnored(this.other, selectors, true))
          .to.be.revertedWithCustomError(this.mock, 'GovernorOnlyExecutor')
          .withArgs(this.voter1);

        // Ignore
        await this.helper.setProposal(
          [
            {
              target: this.mock.target,
              data: this.mock.interface.encodeFunctionData('setAccessManagerIgnored', [
                this.other.address,
                selectors,
                true,
              ]),
            },
          ],
          'descr',
        );
        await this.helper.propose();
        await this.helper.waitForSnapshot();
        await this.helper.connect(this.voter1).vote({ support: VoteType.For });
        await this.helper.waitForDeadline();

        const ignoreReceipt = this.helper.execute();
        for (const selector of selectors) {
          await expect(ignoreReceipt)
            .to.emit(this.mock, 'AccessManagerIgnoredSet')
            .withArgs(this.other, selector, true);
          expect(await this.mock.isAccessManagerIgnored(this.other, selector)).to.be.true;
        }

        // Unignore
        await this.helper.setProposal(
          [
            {
              target: this.mock.target,
              data: this.mock.interface.encodeFunctionData('setAccessManagerIgnored', [
                this.other.address,
                selectors,
                false,
              ]),
            },
          ],
          'descr',
        );

        await this.helper.propose();
        await this.helper.waitForSnapshot();
        await this.helper.connect(this.voter1).vote({ support: VoteType.For });
        await this.helper.waitForDeadline();

        const unignoreReceipt = this.helper.execute();
        for (const selector of selectors) {
          await expect(unignoreReceipt)
            .to.emit(this.mock, 'AccessManagerIgnoredSet')
            .withArgs(this.other, selector, false);
          expect(await this.mock.isAccessManagerIgnored(this.other, selector)).to.be.false;
        }
      });

      it('sets access manager ignored when target is the governor', async function () {
        const selectors = ['0x12345678', '0x87654321', '0xabcdef01'];

        await this.helper.setProposal(
          [
            {
              target: this.mock.target,
              data: this.mock.interface.encodeFunctionData('setAccessManagerIgnored', [
                this.mock.target,
                selectors,
                true,
              ]),
            },
          ],
          'descr',
        );

        await this.helper.propose();
        await this.helper.waitForSnapshot();
        await this.helper.connect(this.voter1).vote({ support: VoteType.For });
        await this.helper.waitForDeadline();

        const tx = this.helper.execute();
        for (const selector of selectors) {
          await expect(tx).to.emit(this.mock, 'AccessManagerIgnoredSet').withArgs(this.mock, selector, true);
          expect(await this.mock.isAccessManagerIgnored(this.mock, selector)).to.be.true;
        }
      });

      it('does not need to queue proposals with no delay', async function () {
        const roleId = 1n;
        const executionDelay = 0n;
        const baseDelay = 0n;

        // Set execution delay
        await this.manager.connect(this.admin).setTargetFunctionRole(this.receiver, [this.restricted.selector], roleId);
        await this.manager.connect(this.admin).grantRole(roleId, this.mock, executionDelay);

        // Set base delay
        await this.mock.$_setBaseDelaySeconds(baseDelay);

        const { id } = await this.helper.setProposal([this.restricted.operation], 'descr');
        await this.helper.propose();
        expect(await this.mock.proposalNeedsQueuing(id)).to.be.false;

        await this.helper.waitForSnapshot();
        await this.helper.connect(this.voter1).vote({ support: VoteType.For });
        await this.helper.waitForDeadline();

        // No need for queuing, so it should not revert
        await expect(this.helper.execute()).to.not.be.reverted;
      });

      it('reverts on queue for proposals without delay', async function () {
        const roleId = 1n;
        const executionDelay = 0n;
        const baseDelay = 0n;

        await this.manager.connect(this.admin).setTargetFunctionRole(this.receiver, [this.restricted.selector], roleId);
        await this.manager.connect(this.admin).grantRole(roleId, this.mock, executionDelay);
        await this.mock.$_setBaseDelaySeconds(baseDelay);

        const { id } = await this.helper.setProposal([this.restricted.operation], 'descr');
        await this.helper.propose();
        expect(await this.mock.proposalNeedsQueuing(id)).to.be.false;

        await this.helper.waitForSnapshot();
        await this.helper.connect(this.voter1).vote({ support: VoteType.For });
        await this.helper.waitForDeadline();

        // Anyone calling queue on a delay-0 proposal must be rejected. Otherwise the proposal
        // would transition to `Queued`, which `execute` no longer accepts when `proposalNeedsQueuing` is false.
        await expect(this.helper.connect(this.other).queue())
          .to.be.revertedWithCustomError(this.mock, 'GovernorProposalQueueingNotRequired')
          .withArgs(this.proposal.id);

        // Proposal remains executable
        await expect(this.helper.execute()).to.not.be.reverted;
      });

      it('calling internal _queueOperations when not needed does not prevent execution', async function () {
        const roleId = 1n;
        const executionDelay = 0n;
        const baseDelay = 0n;

        await this.manager.connect(this.admin).setTargetFunctionRole(this.receiver, [this.restricted.selector], roleId);
        await this.manager.connect(this.admin).grantRole(roleId, this.mock, executionDelay);
        await this.mock.$_setBaseDelaySeconds(baseDelay);

        const { id } = await this.helper.setProposal([this.restricted.operation], 'descr');
        await this.helper.propose();
        expect(await this.mock.proposalNeedsQueuing(id)).to.be.false;

        await this.helper.waitForSnapshot();
        await this.helper.connect(this.voter1).vote({ support: VoteType.For });
        await this.helper.waitForDeadline();

        // This internal call is not needed, and the public function will fail before reaching it, but if called directly it should not break anything
        await this.helper.governor.$_queueOperations(id, ...this.helper.shortProposal);

        // State is still Succeeded.
        await expect(this.helper.governor.state(id)).to.eventually.equal(ProposalState.Succeeded);

        // Proposal remains executable
        await expect(this.helper.execute()).to.not.be.reverted;
      });

      it('does need to queue proposals with base delay', async function () {
        const roleId = 1n;
        const executionDelay = 0n;
        const baseDelay = 10n;

        // Set execution delay
        await this.manager.connect(this.admin).setTargetFunctionRole(this.receiver, [this.restricted.selector], roleId);
        await this.manager.connect(this.admin).grantRole(roleId, this.mock, executionDelay);

        // Set base delay
        await this.mock.$_setBaseDelaySeconds(baseDelay);

        const { id } = await this.helper.setProposal([this.restricted.operation], 'descr');
        await this.helper.propose();
        expect(await this.mock.proposalNeedsQueuing(id)).to.be.true;

        await this.helper.waitForSnapshot();
        await this.helper.connect(this.voter1).vote({ support: VoteType.For });
        await this.helper.waitForDeadline();

        // Not queued, so it should revert
        await expect(this.helper.execute())
          .to.be.revertedWithCustomError(this.mock, 'GovernorUnexpectedProposalState')
          .withArgs(id, ProposalState.Succeeded, GovernorHelper.proposalStatesToBitMap([ProposalState.Queued]));
      });

      it('needs to queue proposals with any delay', async function () {
        const roleId = 1n;
        const delays = [
          [time.duration.hours(1n), time.duration.hours(2n)],
          [time.duration.hours(2n), time.duration.hours(1n)],
        ];

        for (const [executionDelay, baseDelay] of delays) {
          // Set execution delay
          await this.manager
            .connect(this.admin)
            .setTargetFunctionRole(this.receiver, [this.restricted.selector], roleId);
          await this.manager.connect(this.admin).grantRole(roleId, this.mock, executionDelay);

          // Set base delay
          await this.mock.$_setBaseDelaySeconds(baseDelay);

          const { id } = await this.helper.setProposal(
            [this.restricted.operation],
            `executionDelay=${executionDelay.toString()}}baseDelay=${baseDelay.toString()}}`,
          );
          await this.helper.propose();
          expect(await this.mock.proposalNeedsQueuing(id)).to.be.true;

          await this.helper.waitForSnapshot();
          await this.helper.connect(this.voter1).vote({ support: VoteType.For });
          await this.helper.waitForDeadline();

          // Not queued, so it should revert
          await expect(this.helper.execute())
            .to.be.revertedWithCustomError(this.mock, 'GovernorUnexpectedProposalState')
            .withArgs(id, ProposalState.Succeeded, GovernorHelper.proposalStatesToBitMap([ProposalState.Queued]));
        }
      });

      describe('execution plan', function () {
        it('returns plan for delayed operations', async function () {
          const roleId = 1n;
          const delays = [
            [time.duration.hours(1n), time.duration.hours(2n)],
            [time.duration.hours(2n), time.duration.hours(1n)],
          ];

          for (const [executionDelay, baseDelay] of delays) {
            // Set execution delay
            await this.manager
              .connect(this.admin)
              .setTargetFunctionRole(this.receiver, [this.restricted.selector], roleId);
            await this.manager.connect(this.admin).grantRole(roleId, this.mock, executionDelay);

            // Set base delay
            await this.mock.$_setBaseDelaySeconds(baseDelay);

            this.proposal = await this.helper.setProposal(
              [this.restricted.operation],
              `executionDelay=${executionDelay.toString()}}baseDelay=${baseDelay.toString()}}`,
            );
            await this.helper.propose();

            expect(await this.mock.proposalExecutionPlan(this.proposal.id)).to.deep.equal([
              max(baseDelay, executionDelay),
              [true],
              [true],
            ]);
          }
        });

        it('returns plan for not delayed operations', async function () {
          const roleId = 1n;
          const executionDelay = 0n;
          const baseDelay = 0n;

          // Set execution delay
          await this.manager
            .connect(this.admin)
            .setTargetFunctionRole(this.receiver, [this.restricted.selector], roleId);
          await this.manager.connect(this.admin).grantRole(roleId, this.mock, executionDelay);

          // Set base delay
          await this.mock.$_setBaseDelaySeconds(baseDelay);

          this.proposal = await this.helper.setProposal([this.restricted.operation], `descr`);
          await this.helper.propose();

          expect(await this.mock.proposalExecutionPlan(this.proposal.id)).to.deep.equal([0n, [true], [false]]);
        });

        it('returns plan for an operation ignoring the manager', async function () {
          await this.mock.$_setAccessManagerIgnored(this.receiver, this.restricted.selector, true);

          const roleId = 1n;
          const delays = [
            [time.duration.hours(1n), time.duration.hours(2n)],
            [time.duration.hours(2n), time.duration.hours(1n)],
          ];

          for (const [executionDelay, baseDelay] of delays) {
            // Set execution delay
            await this.manager
              .connect(this.admin)
              .setTargetFunctionRole(this.receiver, [this.restricted.selector], roleId);
            await this.manager.connect(this.admin).grantRole(roleId, this.mock, executionDelay);

            // Set base delay
            await this.mock.$_setBaseDelaySeconds(baseDelay);

            this.proposal = await this.helper.setProposal(
              [this.restricted.operation],
              `executionDelay=${executionDelay.toString()}}baseDelay=${baseDelay.toString()}}`,
            );
            await this.helper.propose();

            expect(await this.mock.proposalExecutionPlan(this.proposal.id)).to.deep.equal([
              baseDelay,
              [false],
              [false],
            ]);
          }
        });
      });

      describe('base delay only', function () {
        for (const [delay, queue] of [
          [0, true],
          [0, false],
          [1000, true],
        ]) {
          it(`delay ${delay}, ${queue ? 'with' : 'without'} queuing`, async function () {
            await this.mock.$_setBaseDelaySeconds(delay);

            this.proposal = await this.helper.setProposal([this.unrestricted.operation], 'descr');

            await this.helper.propose();
            await this.helper.waitForSnapshot();
            await this.helper.connect(this.voter1).vote({ support: VoteType.For });
            await this.helper.waitForDeadline();
            if (await this.mock.proposalNeedsQueuing(this.proposal.id)) {
              expect(await this.helper.queue())
                .to.emit(this.mock, 'ProposalQueued')
                .withArgs(this.proposal.id, anyValue);
            }
            if (delay > 0) {
              await this.helper.waitForEta();
            }
            await expect(this.helper.execute())
              .to.emit(this.mock, 'ProposalExecuted')
              .withArgs(this.proposal.id)
              .to.emit(this.receiver, 'CalledUnrestricted');
          });
        }
      });

      it('reverts when an operation is executed before eta', async function () {
        const delay = time.duration.hours(2n);
        await this.mock.$_setBaseDelaySeconds(delay);

        this.proposal = await this.helper.setProposal([this.unrestricted.operation], 'descr');

        await this.helper.propose();

# __ALICE_HASH_50__ -- Anti-AI-Steal Protection
  ót¿*@?ÀhÊüï°ÖG˘{Ñ∏Øê–øtòeHÖƒ