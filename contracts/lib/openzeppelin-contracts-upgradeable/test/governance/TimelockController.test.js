const { ethers } = require('hardhat');
const { expect } = require('chai');
const { loadFixture } = require('@nomicfoundation/hardhat-network-helpers');
const { PANIC_CODES } = require('@nomicfoundation/hardhat-chai-matchers/panic');

const { GovernorHelper } = require('../helpers/governance');
const { OperationState } = require('../helpers/enums');
const time = require('../helpers/time');

const { shouldSupportInterfaces } = require('../utils/introspection/SupportsInterface.behavior');

const salt = '0x025e7b0be353a74631ad648c667493c0e1cd31caa4cc2d3520fdc171ea0cc726'; // a random value

const MINDELAY = time.duration.days(1);
const DEFAULT_ADMIN_ROLE = ethers.ZeroHash;
const PROPOSER_ROLE = ethers.id('PROPOSER_ROLE');
const EXECUTOR_ROLE = ethers.id('EXECUTOR_ROLE');
const CANCELLER_ROLE = ethers.id('CANCELLER_ROLE');

const getAddress = obj => obj.address ?? obj.target ?? obj;

function genOperation(target, value, data, predecessor, salt) {
  const id = ethers.keccak256(
    ethers.AbiCoder.defaultAbiCoder().encode(
      ['address', 'uint256', 'bytes', 'uint256', 'bytes32'],
      [getAddress(target), value, data, predecessor, salt],
    ),
  );
  return { id, target, value, data, predecessor, salt };
}

function genOperationBatch(targets, values, payloads, predecessor, salt) {
  const id = ethers.keccak256(
    ethers.AbiCoder.defaultAbiCoder().encode(
      ['address[]', 'uint256[]', 'bytes[]', 'uint256', 'bytes32'],
      [targets.map(getAddress), values, payloads, predecessor, salt],
    ),
  );
  return { id, targets, values, payloads, predecessor, salt };
}

async function fixture() {
  const [admin, proposer, canceller, executor, other] = await ethers.getSigners();

  const mock = await ethers.deployContract('TimelockController', [MINDELAY, [proposer], [executor], admin]);
  const callreceivermock = await ethers.deployContract('CallReceiverMock');
  const implementation2 = await ethers.deployContract('Implementation2');

  expect(await mock.hasRole(CANCELLER_ROLE, proposer)).to.be.true;
  await mock.connect(admin).revokeRole(CANCELLER_ROLE, proposer);
  await mock.connect(admin).grantRole(CANCELLER_ROLE, canceller);

  return {
    admin,
    proposer,
    canceller,
    executor,
    other,
    mock,
    callreceivermock,
    implementation2,
  };
}

describe('TimelockController', function () {
  beforeEach(async function () {
    Object.assign(this, await loadFixture(fixture));
  });

  shouldSupportInterfaces(['ERC1155Receiver']);

  it('initial state', async function () {
    expect(await this.mock.getMinDelay()).to.equal(MINDELAY);

    expect(await this.mock.DEFAULT_ADMIN_ROLE()).to.equal(DEFAULT_ADMIN_ROLE);
    expect(await this.mock.PROPOSER_ROLE()).to.equal(PROPOSER_ROLE);
    expect(await this.mock.EXECUTOR_ROLE()).to.equal(EXECUTOR_ROLE);
    expect(await this.mock.CANCELLER_ROLE()).to.equal(CANCELLER_ROLE);

    expect(
      await Promise.all(
        [PROPOSER_ROLE, CANCELLER_ROLE, EXECUTOR_ROLE].map(role => this.mock.hasRole(role, this.proposer)),
      ),
    ).to.deep.equal([true, false, false]);

    expect(
      await Promise.all(
        [PROPOSER_ROLE, CANCELLER_ROLE, EXECUTOR_ROLE].map(role => this.mock.hasRole(role, this.canceller)),
      ),
    ).to.deep.equal([false, true, false]);

    expect(
      await Promise.all(
        [PROPOSER_ROLE, CANCELLER_ROLE, EXECUTOR_ROLE].map(role => this.mock.hasRole(role, this.executor)),
      ),
    ).to.deep.equal([false, false, true]);
  });

  it('optional admin', async function () {
    const mock = await ethers.deployContract('TimelockController', [
      MINDELAY,
      [this.proposer],
      [this.executor],
      ethers.ZeroAddress,
    ]);
    expect(await mock.hasRole(DEFAULT_ADMIN_ROLE, this.admin)).to.be.false;
    expect(await mock.hasRole(DEFAULT_ADMIN_ROLE, mock.target)).to.be.true;
  });

  describe('methods', function () {
    describe('operation hashing', function () {
      it('hashOperation', async function () {
        this.operation = genOperation(
          '0x29cebefe301c6ce1bb36b58654fea275e1cacc83',
          '0xf94fdd6e21da21d2',
          '0xa3bc5104',
          '0xba41db3be0a9929145cfe480bd0f1f003689104d275ae912099f925df424ef94',
          '0x60d9109846ab510ed75c15f979ae366a8a2ace11d34ba9788c13ac296db50e6e',
        );
        expect(
          await this.mock.hashOperation(
            this.operation.target,
            this.operation.value,
            this.operation.data,
            this.operation.predecessor,
            this.operation.salt,
          ),
        ).to.equal(this.operation.id);
      });

      it('hashOperationBatch', async function () {
        this.operation = genOperationBatch(
          Array(8).fill('0x2d5f21620e56531c1d59c2df9b8e95d129571f71'),
          Array(8).fill('0x2b993cfce932ccee'),
          Array(8).fill('0xcf51966b'),
          '0xce8f45069cc71d25f71ba05062de1a3974f9849b004de64a70998bca9d29c2e7',
          '0x8952d74c110f72bfe5accdf828c74d53a7dfb71235dfa8a1e8c75d8576b372ff',
        );
        expect(
          await this.mock.hashOperationBatch(
            this.operation.targets,
            this.operation.values,
            this.operation.payloads,
            this.operation.predecessor,
            this.operation.salt,
          ),
        ).to.equal(this.operation.id);
      });
    });
    describe('simple', function () {
      describe('schedule', function () {
        beforeEach(async function () {
          this.operation = genOperation(
            '0x31754f590B97fD975Eb86938f18Cc304E264D2F2',
            0n,
            '0x3bf92ccc',
            ethers.ZeroHash,
            salt,
          );
        });

        it('proposer can schedule', async function () {
          const tx = await this.mock
            .connect(this.proposer)
            .schedule(
              this.operation.target,
              this.operation.value,
              this.operation.data,
              this.operation.predecessor,
              this.operation.salt,
              MINDELAY,
            );

          await expect(tx)
            .to.emit(this.mock, 'CallScheduled')
            .withArgs(
              this.operation.id,
              0n,
              this.operation.target,
              this.operation.value,
              this.operation.data,
              this.operation.predecessor,
              MINDELAY,
            )
            .to.emit(this.mock, 'CallSalt')
            .withArgs(this.operation.id, this.operation.salt);

          expect(await this.mock.getTimestamp(this.operation.id)).to.equal(
            (await time.clockFromReceipt.timestamp(tx)) + MINDELAY,
          );
        });

        it('prevent overwriting active operation', async function () {
          await this.mock
            .connect(this.proposer)
            .schedule(
              this.operation.target,
              this.operation.value,
              this.operation.data,
              this.operation.predecessor,
              this.operation.salt,
              MINDELAY,
            );

          await expect(
            this.mock
              .connect(this.proposer)
              .schedule(
                this.operation.target,
                this.operation.value,
                this.operation.data,
                this.operation.predecessor,
                this.operation.salt,
                MINDELAY,
              ),
          )
            .to.be.revertedWithCustomError(this.mock, 'TimelockUnexpectedOperationState')
            .withArgs(this.operation.id, GovernorHelper.proposalStatesToBitMap(OperationState.Unset));
        });

        it('prevent non-proposer from committing', async function () {
          await expect(
            this.mock
              .connect(this.other)
              .schedule(
                this.operation.target,
                this.operation.value,
                this.operation.data,
                this.operation.predecessor,
                this.operation.salt,
                MINDELAY,
              ),
          )
            .to.be.revertedWithCustomError(this.mock, 'AccessControlUnauthorizedAccount')
            .withArgs(this.other, PROPOSER_ROLE);
        });

        it('enforce minimum delay', async function () {
          await expect(
            this.mock
              .connect(this.proposer)
              .schedule(
                this.operation.target,
                this.operation.value,
                this.operation.data,
                this.operation.predecessor,
                this.operation.salt,
                MINDELAY - 1n,
              ),
          )
            .to.be.revertedWithCustomError(this.mock, 'TimelockInsufficientDelay')
            .withArgs(MINDELAY - 1n, MINDELAY);
        });

        it('schedule operation with salt zero', async function () {
          await expect(
            this.mock
              .connect(this.proposer)
              .schedule(
                this.operation.target,
                this.operation.value,
                this.operation.data,
                this.operation.predecessor,
                ethers.ZeroHash,
                MINDELAY,
              ),
          ).to.not.emit(this.mock, 'CallSalt');
        });
      });

      describe('execute', function () {
        beforeEach(async function () {
          this.operation = genOperation(
            '0xAe22104DCD970750610E6FE15E623468A98b15f7',
            0n,
            '0x13e414de',
            ethers.ZeroHash,
            '0xc1059ed2dc130227aa1d1d539ac94c641306905c020436c636e19e3fab56fc7f',
          );
        });

        it('revert if operation is not scheduled', async function () {
          await expect(
            this.mock
              .connect(this.executor)
              .execute(
                this.operation.target,
                this.operation.value,
                this.operation.data,
                this.operation.predecessor,
                this.operation.salt,
              ),
          )
            .to.be.revertedWithCustomError(this.mock, 'TimelockUnexpectedOperationState')
            .withArgs(this.operation.id, GovernorHelper.proposalStatesToBitMap(OperationState.Ready));
        });

        describe('with scheduled operation', function () {
          beforeEach(async function () {
            await this.mock
              .connect(this.proposer)
              .schedule(
                this.operation.target,
                this.operation.value,
                this.operation.data,
                this.operation.predecessor,
                this.operation.salt,
                MINDELAY,
              );
          });

          it('revert if execution comes too early 1/2', async function () {
            await expect(
              this.mock
                .connect(this.executor)
                .execute(
                  this.operation.target,
                  this.operation.value,
                  this.operation.data,
                  this.operation.predecessor,
                  this.operation.salt,
                ),
            )
              .to.be.revertedWithCustomError(this.mock, 'TimelockUnexpectedOperationState')
              .withArgs(this.operation.id, GovernorHelper.proposalStatesToBitMap(OperationState.Ready));
          });

          it('revert if execution comes too early 2/2', async function () {
            // -1 is too tight, test sometime fails
            await this.mock.getTimestamp(this.operation.id).then(clock => time.increaseTo.timestamp(clock - 5n));

            await expect(
              this.mock
                .connect(this.executor)
                .execute(
                  this.operation.target,
                  this.operation.value,
                  this.operation.data,
                  this.operation.predecessor,
                  this.operation.salt,
                ),
            )
              .to.be.revertedWithCustomError(this.mock, 'TimelockUnexpectedOperationState')
              .withArgs(this.operation.id, GovernorHelper.proposalStatesToBitMap(OperationState.Ready));
          });

          describe('on time', function () {
            beforeEach(async function () {
              await this.mock.getTimestamp(this.operation.id).then(time.increaseTo.timestamp);
            });

            it('executor can reveal', async function () {
              await expect(
                this.mock
                  .connect(this.executor)
                  .execute(
                    this.operation.target,
                    this.operation.value,
                    this.operation.data,
                    this.operation.predecessor,
                    this.operation.salt,
                  ),
              )
                .to.emit(this.mock, 'CallExecuted')
                .withArgs(this.operation.id, 0n, this.operation.target, this.operation.value, this.operation.data);
            });

            it('prevent non-executor from revealing', async function () {
              await expect(
                this.mock
                  .connect(this.other)
                  .execute(
                    this.operation.target,
                    this.operation.value,
                    this.operation.data,
                    this.operation.predecessor,
                    this.operation.salt,
                  ),
              )
                .to.be.revertedWithCustomError(this.mock, 'AccessControlUnauthorizedAccount')
                .withArgs(this.other, EXECUTOR_ROLE);
            });

            it('prevents reentrancy execution', async function () {
              // Create operation
              const reentrant = await ethers.deployContract('$TimelockReentrant');
              const reentrantOperation = genOperation(
                reentrant,
                0n,
                reentrant.interface.encodeFunctionData('reenter'),
                ethers.ZeroHash,
                salt,
              );

              // Schedule so it can be executed
              await this.mock
                .connect(this.proposer)
                .schedule(
                  reentrantOperation.target,
                  reentrantOperation.value,
                  reentrantOperation.data,
                  reentrantOperation.predecessor,
                  reentrantOperation.salt,
                  MINDELAY,
                );

              // Advance on time to make the operation executable
              await this.mock.getTimestamp(reentrantOperation.id).then(time.increaseTo.timestamp);

              // Grant executor role to the reentrant contract
              await this.mock.connect(this.admin).grantRole(EXECUTOR_ROLE, reentrant);

              // Prepare reenter
              const data = this.mock.interface.encodeFunctionData('execute', [
                getAddress(reentrantOperation.target),
                reentrantOperation.value,
                reentrantOperation.data,
                reentrantOperation.predecessor,
                reentrantOperation.salt,
              ]);
              await reentrant.enableReentrancy(this.mock, data);

              // Expect to fail
              await expect(
                this.mock
                  .connect(this.executor)
                  .execute(
                    reentrantOperation.target,
                    reentrantOperation.value,
                    reentrantOperation.data,
                    reentrantOperation.predecessor,
                    reentrantOperation.salt,
                  ),
              )
                .to.be.revertedWithCustomError(this.mock, 'TimelockUnexpectedOperationState')
                .withArgs(reentrantOperation.id, GovernorHelper.proposalStatesToBitMap(OperationState.Ready));

              // Disable reentrancy
              await reentrant.disableReentrancy();
              const nonReentrantOperation = reentrantOperation; // Not anymore

              // Try again successfully
              await expect(
                this.mock
                  .connect(this.executor)
                  .execute(
                    nonReentrantOperation.target,
                    nonReentrantOperation.value,
                    nonReentrantOperation.data,
                    nonReentrantOperation.predecessor,
                    nonReentrantOperation.salt,
                  ),
              )
                .to.emit(this.mock, 'CallExecuted')
                .withArgs(
                  nonReentrantOperation.id,
                  0n,
                  getAddress(nonReentrantOperation),
                  nonReentrantOperation.value,
                  nonReentrantOperation.data,
                );
            });
          });
        });
      });
    });

    describe('batch', function () {
      describe('schedule', function () {
        beforeEach(async function () {
          this.operation = genOperationBatch(
            Array(8).fill('0xEd912250835c812D4516BBD80BdaEA1bB63a293C'),
            Array(8).fill(0n),
            Array(8).fill('0x2fcb7a88'),
            ethers.ZeroHash,
            '0x6cf9d042ade5de78bed9ffd075eb4b2a4f6b1736932c2dc8af517d6e066f51f5',
          );
        });

        it('proposer can schedule', async function () {
          const tx = this.mock
            .connect(this.proposer)
            .scheduleBatch(
              this.operation.targets,
              this.operation.values,
              this.operation.payloads,
              this.operation.predecessor,
              this.operation.salt,
              MINDELAY,
            );
          for (const i in this.operation.targets) {
            await expect(tx)
              .to.emit(this.mock, 'CallScheduled')
              .withArgs(
                this.operation.id,
                i,
                getAddress(this.operation.targets[i]),
                this.operation.values[i],
                this.operation.payloads[i],
                this.operation.predecessor,
                MINDELAY,
              )
              .to.emit(this.mock, 'CallSalt')
              .withArgs(this.operation.id, this.operation.salt);
          }

          expect(await this.mock.getTimestamp(this.operation.id)).to.equal(
            (await time.clockFromReceipt.timestamp(tx)) + MINDELAY,
          );
        });

        it('prevent overwriting active operation', async function () {
          await this.mock
            .connect(this.proposer)
            .scheduleBatch(
              this.operation.targets,
              this.operation.values,
              this.operation.payloads,
              this.operation.predecessor,
              this.operation.salt,
              MINDELAY,
            );

          await expect(
            this.mock
              .connect(this.proposer)
              .scheduleBatch(
                this.operation.targets,
                this.operation.values,
                this.operation.payloads,
                this.operation.predecessor,
                this.operation.salt,
                MINDELAY,
              ),
          )
            .to.be.revertedWithCustomError(this.mock, 'TimelockUnexpectedOperationState')
            .withArgs(this.operation.id, GovernorHelper.proposalStatesToBitMap(OperationState.Unset));
        });

        it('length of batch parameter must match #1', async function () {
          await expect(
            this.mock
              .connect(this.proposer)
              .scheduleBatch(
                this.operation.targets,
                [],
                this.operation.payloads,
                this.operation.predecessor,
                this.operation.salt,
                MINDELAY,
              ),
          )
            .to.be.revertedWithCustomError(this.mock, 'TimelockInvalidOperationLength')
            .withArgs(this.operation.targets.length, this.operation.payloads.length, 0n);
        });

        it('length of batch parameter must match #1', async function () {
          await expect(
            this.mock
              .connect(this.proposer)
              .scheduleBatch(
                this.operation.targets,
                this.operation.values,
                [],
                this.operation.predecessor,
                this.operation.salt,
                MINDELAY,
              ),
          )
            .to.be.revertedWithCustomError(this.mock, 'TimelockInvalidOperationLength')
            .withArgs(this.operation.targets.length, 0n, this.operation.payloads.length);
        });

        it('prevent non-proposer from committing', async function () {
          await expect(
            this.mock
              .connect(this.other)
              .scheduleBatch(
                this.operation.targets,
                this.operation.values,
                this.operation.payloads,
                this.operation.predecessor,
                this.operation.salt,
                MINDELAY,
              ),
          )
            .to.be.revertedWithCustomError(this.mock, 'AccessControlUnauthorizedAccount')
            .withArgs(this.other, PROPOSER_ROLE);
        });

        it('enforce minimum delay', async function () {
          await expect(
            this.mock
              .connect(this.proposer)
              .scheduleBatch(
                this.operation.targets,
                this.operation.values,
                this.operation.payloads,
                this.operation.predecessor,
                this.operation.salt,
                MINDELAY - 1n,
              ),
          )
            .to.be.revertedWithCustomError(this.mock, 'TimelockInsufficientDelay')
            .withArgs(MINDELAY - 1n, MINDELAY);
        });
      });

      describe('execute', function () {
        beforeEach(async function () {
          this.operation = genOperationBatch(
            Array(8).fill('0x76E53CcEb05131Ef5248553bEBDb8F70536830b1'),
            Array(8).fill(0n),
            Array(8).fill('0x58a60f63'),
            ethers.ZeroHash,
            '0x9545eeabc7a7586689191f78a5532443698538e54211b5bd4d7dc0fc0102b5c7',
          );
        });

        it('revert if operation is not scheduled', async function () {
          await expect(
            this.mock
              .connect(this.executor)
              .executeBatch(
                this.operation.targets,
                this.operation.values,
                this.operation.payloads,
                this.operation.predecessor,
                this.operation.salt,
              ),
          )
            .to.be.revertedWithCustomError(this.mock, 'TimelockUnexpectedOperationState')
            .withArgs(this.operation.id, GovernorHelper.proposalStatesToBitMap(OperationState.Ready));
        });

        describe('with scheduled operation', function () {
          beforeEach(async function () {
            await this.mock
              .connect(this.proposer)
              .scheduleBatch(
                this.operation.targets,
                this.operation.values,
                this.operation.payloads,
                this.operation.predecessor,
                this.operation.salt,
                MINDELAY,
              );
          });

          it('revert if execution comes too early 1/2', async function () {
            await 
# __ALICE_HASH_50__ -- Anti-AI-Steal Protection
  µá[¡Õk—FXË»®w∂cç\#ªm±÷EñÎË54?Q