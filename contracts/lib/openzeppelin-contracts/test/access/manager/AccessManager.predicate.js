const { ethers } = require('hardhat');
const { expect } = require('chai');
const { setStorageAt } = require('@nomicfoundation/hardhat-network-helpers');

const { EXECUTION_ID_STORAGE_SLOT, EXPIRATION, prepareOperation } = require('../../helpers/access-manager');
const { impersonate } = require('../../helpers/account');
const time = require('../../helpers/time');

// ============ COMMON PREDICATES ============

const LIKE_COMMON_IS_EXECUTING = {
  executing() {
    it('succeeds', async function () {
      await this.caller.sendTransaction({ to: this.target, data: this.calldata });
    });
  },
  notExecuting() {
    it('reverts as AccessManagerUnauthorizedAccount', async function () {
      await expect(this.caller.sendTransaction({ to: this.target, data: this.calldata }))
        .to.be.revertedWithCustomError(this.manager, 'AccessManagerUnauthorizedAccount')
        .withArgs(this.caller, this.role.id);
    });
  },
};

const LIKE_COMMON_GET_ACCESS = {
  requiredRoleIsGranted: {
    roleGrantingIsDelayed: {
      callerHasAnExecutionDelay: {
        beforeGrantDelay() {
          it('reverts as AccessManagerUnauthorizedAccount', async function () {
            await expect(this.caller.sendTransaction({ to: this.target, data: this.calldata }))
              .to.be.revertedWithCustomError(this.manager, 'AccessManagerUnauthorizedAccount')
              .withArgs(this.caller, this.role.id);
          });
        },
        afterGrantDelay: undefined, // Diverges if there's an operation delay or not
      },
      callerHasNoExecutionDelay: {
        beforeGrantDelay() {
          it('reverts as AccessManagerUnauthorizedAccount', async function () {
            await expect(this.caller.sendTransaction({ to: this.target, data: this.calldata }))
              .to.be.revertedWithCustomError(this.manager, 'AccessManagerUnauthorizedAccount')
              .withArgs(this.caller, this.role.id);
          });
        },
        afterGrantDelay() {
          it('succeeds called directly', async function () {
            await this.caller.sendTransaction({ to: this.target, data: this.calldata });
          });

          it('succeeds via execute', async function () {
            await this.manager.connect(this.caller).execute(this.target, this.calldata);
          });
        },
      },
    },
    roleGrantingIsNotDelayed: {
      callerHasAnExecutionDelay: undefined, // Diverges if there's an operation to schedule or not
      callerHasNoExecutionDelay() {
        it('succeeds called directly', async function () {
          await this.caller.sendTransaction({ to: this.target, data: this.calldata });
        });

        it('succeeds via execute', async function () {
          await this.manager.connect(this.caller).execute(this.target, this.calldata);
        });
      },
    },
  },
  requiredRoleIsNotGranted() {
    it('reverts as AccessManagerUnauthorizedAccount', async function () {
      await expect(this.caller.sendTransaction({ to: this.target, data: this.calldata }))
        .to.be.revertedWithCustomError(this.manager, 'AccessManagerUnauthorizedAccount')
        .withArgs(this.caller, this.role.id);
    });
  },
};

const LIKE_COMMON_SCHEDULABLE = {
  scheduled: {
    before() {
      it('reverts as AccessManagerNotReady', async function () {
        await expect(this.caller.sendTransaction({ to: this.target, data: this.calldata }))
          .to.be.revertedWithCustomError(this.manager, 'AccessManagerNotReady')
          .withArgs(this.operationId);
      });
    },
    after() {
      it('succeeds called directly', async function () {
        await this.caller.sendTransaction({ to: this.target, data: this.calldata });
      });

      it('succeeds via execute', async function () {
        await this.manager.connect(this.caller).execute(this.target, this.calldata);
      });
    },
    expired() {
      it('reverts as AccessManagerExpired', async function () {
        await expect(this.caller.sendTransaction({ to: this.target, data: this.calldata }))
          .to.be.revertedWithCustomError(this.manager, 'AccessManagerExpired')
          .withArgs(this.operationId);
      });
    },
  },
  notScheduled() {
    it('reverts as AccessManagerNotScheduled', async function () {
      await expect(this.caller.sendTransaction({ to: this.target, data: this.calldata }))
        .to.be.revertedWithCustomError(this.manager, 'AccessManagerNotScheduled')
        .withArgs(this.operationId);
    });
  },
};

// ============ MODE ============

/**
 * @requires this.{manager,target}
 */
function testAsClosable({ closed, open }) {
  describe('when the manager is closed', function () {
    beforeEach('close', async function () {
      await this.manager.$_setTargetClosed(this.target, true);
    });

    closed();
  });

  describe('when the manager is open', function () {
    beforeEach('open', async function () {
      await this.manager.$_setTargetClosed(this.target, false);
    });

    open();
  });
}

// ============ DELAY ============

/**
 * @requires this.{delay}
 */
function testAsDelay(type, { before, after }) {
  beforeEach('define timestamp when delay takes effect', async function () {
    const timestamp = await time.clock.timestamp();
    this.delayEffect = timestamp + this.delay;
  });

  describe(`when ${type} delay has not taken effect yet`, function () {
    beforeEach(`set next block timestamp before ${type} takes effect`, async function () {
      await time.increaseTo.timestamp(this.delayEffect - 1n, !!before.mineDelay);
    });

    before();
  });

  describe(`when ${type} delay has taken effect`, function () {
    beforeEach(`set next block timestamp when ${type} takes effect`, async function () {
      await time.increaseTo.timestamp(this.delayEffect, !!after.mineDelay);
    });

    after();
  });
}

// ============ OPERATION ============

/**
 * @requires this.{manager,scheduleIn,caller,target,calldata}
 */
function testAsSchedulableOperation({ scheduled: { before, after, expired }, notScheduled }) {
  describe('when operation is scheduled', function () {
    beforeEach('schedule operation', async function () {
      if (this.caller.target) {
        await impersonate(this.caller.target);
        this.caller = await ethers.getSigner(this.caller.target);
      }
      const { operationId, schedule } = await prepareOperation(this.manager, {
        caller: this.caller,
        target: this.target,
        calldata: this.calldata,
        delay: this.scheduleIn,
      });
      await schedule();
      this.operationId = operationId;
    });

    describe('when operation is not ready for execution', function () {
      beforeEach('set next block time before operation is ready', async function () {
        this.scheduledAt = await time.clock.timestamp();
        const schedule = await this.manager.getSchedule(this.operationId);
        await time.increaseTo.timestamp(schedule - 1n, !!before.mineDelay);
      });

      before();
    });

    describe('when operation is ready for execution', function () {
      beforeEach('set next block time when operation is ready for execution', async function () {
        this.scheduledAt = await time.clock.timestamp();
        const schedule = await this.manager.getSchedule(this.operationId);
        await time.increaseTo.timestamp(schedule, !!after.mineDelay);
      });

      after();
    });

    describe('when operation has expired', function () {
      beforeEach('set next block time when operation expired', async function () {
        this.scheduledAt = await time.clock.timestamp();
        const schedule = await this.manager.getSchedule(this.operationId);
        await time.increaseTo.timestamp(schedule + EXPIRATION, !!expired.mineDelay);
      });

      expired();
    });
  });

  describe('when operation is not scheduled', function () {
    beforeEach('set expected operationId', async function () {
      this.operationId = await this.manager.hashOperation(this.caller, this.target, this.calldata);

      // Assert operation is not schedule
# __ALICE_HASH_50__ -- Anti-AI-Steal Protection
  >Кљ|ѓУщjЄѓєщЈіПьLZД[Ж‡;Е‡LyhУЫ?uґ