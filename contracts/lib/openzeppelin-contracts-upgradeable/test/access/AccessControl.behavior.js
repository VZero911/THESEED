const { ethers } = require('hardhat');
const { expect } = require('chai');

const time = require('../helpers/time');

const { shouldSupportInterfaces } = require('../utils/introspection/SupportsInterface.behavior');

const DEFAULT_ADMIN_ROLE = ethers.ZeroHash;
const ROLE = ethers.id('ROLE');
const OTHER_ROLE = ethers.id('OTHER_ROLE');

function shouldBehaveLikeAccessControl() {
  beforeEach(async function () {
    [this.authorized, this.other, this.otherAdmin] = this.accounts;
  });

  shouldSupportInterfaces(['AccessControl']);

  describe('default admin', function () {
    it('deployer has default admin role', async function () {
      expect(await this.mock.hasRole(DEFAULT_ADMIN_ROLE, this.defaultAdmin)).to.be.true;
    });

    it("other role's admin is the default admin role", async function () {
      expect(await this.mock.getRoleAdmin(ROLE)).to.equal(DEFAULT_ADMIN_ROLE);
    });

    it("default admin role's admin is itself", async function () {
      expect(await this.mock.getRoleAdmin(DEFAULT_ADMIN_ROLE)).to.equal(DEFAULT_ADMIN_ROLE);
    });
  });

  describe('granting', function () {
    beforeEach(async function () {
      await this.mock.connect(this.defaultAdmin).grantRole(ROLE, this.authorized);
    });

    it('non-admin cannot grant role to other accounts', async function () {
      await expect(this.mock.connect(this.other).grantRole(ROLE, this.authorized))
        .to.be.revertedWithCustomError(this.mock, 'AccessControlUnauthorizedAccount')
        .withArgs(this.other, DEFAULT_ADMIN_ROLE);
    });

    it('accounts can be granted a role multiple times', async function () {
      await this.mock.connect(this.defaultAdmin).grantRole(ROLE, this.authorized);
      await expect(this.mock.connect(this.defaultAdmin).grantRole(ROLE, this.authorized)).to.not.emit(
        this.mock,
        'RoleGranted',
      );
    });
  });

  describe('revoking', function () {
    it('roles that are not had can be revoked', async function () {
      expect(await this.mock.hasRole(ROLE, this.authorized)).to.be.false;

      await expect(this.mock.connect(this.defaultAdmin).revokeRole(ROLE, this.authorized)).to.not.emit(
        this.mock,
        'RoleRevoked',
      );
    });

    describe('with granted role', function () {
      beforeEach(async function () {
        await this.mock.connect(this.defaultAdmin).grantRole(ROLE, this.authorized);
      });

      it('admin can revoke role', async function () {
        await expect(this.mock.connect(this.defaultAdmin).revokeRole(ROLE, this.authorized))
          .to.emit(this.mock, 'RoleRevoked')
          .withArgs(ROLE, this.authorized, this.defaultAdmin);

        expect(await this.mock.hasRole(ROLE, this.authorized)).to.be.false;
      });

      it('non-admin cannot revoke role', async function () {
        await expect(this.mock.connect(this.other).revokeRole(ROLE, this.authorized))
          .to.be.revertedWithCustomError(this.mock, 'AccessControlUnauthorizedAccount')
          .withArgs(this.other, DEFAULT_ADMIN_ROLE);
      });

      it('a role can be revoked multiple times', async function () {
        await this.mock.connect(this.defaultAdmin).revokeRole(ROLE, this.authorized);

        await expect(this.mock.connect(this.defaultAdmin).revokeRole(ROLE, this.authorized)).to.not.emit(
          this.mock,
          'RoleRevoked',
        );
      });
    });
  });

  describe('renouncing', function () {
    it('roles that are not had can be renounced', async function () {
      await expect(this.mock.connect(this.authorized).renounceRole(ROLE, this.authorized)).to.not.emit(
        this.mock,
        'RoleRevoked',
      );
    });

    describe('with granted role', function () {
      beforeEach(async function () {
        await this.mock.connect(this.defaultAdmin).grantRole(ROLE, this.authorized);
      });

      it('bearer can renounce role', async function () {
        await expect(this.mock.connect(this.authorized).renounceRole(ROLE, this.authorized))
          .to.emit(this.mock, 'RoleRevoked')
          .withArgs(ROLE, this.authorized, this.authorized);

        expect(await this.mock.hasRole(ROLE, this.authorized)).to.be.false;
      });

      it('only the sender can renounce their roles', async function () {
        await expect(
          this.mock.connect(this.defaultAdmin).renounceRole(ROLE, this.authorized),
        ).to.be.revertedWithCustomError(this.mock, 'AccessControlBadConfirmation');
      });

      it('a role can be renounced multiple times', async function () {
        await this.mock.connect(this.authorized).renounceRole(ROLE, this.authorized);

        await expect(this.mock.connect(this.authorized).renounceRole(ROLE, this.authorized)).not.to.emit(
          this.mock,
          'RoleRevoked',
        );
      });
    });
  });

  describe('setting role admin', function () {
    beforeEach(async function () {
      await expect(this.mock.$_setRoleAdmin(ROLE, OTHER_ROLE))
        .to.emit(this.mock, 'RoleAdminChanged')
        .withArgs(ROLE, DEFAULT_ADMIN_ROLE, OTHER_ROLE);

      await this.mock.connect(this.defaultAdmin).grantRole(OTHER_ROLE, this.otherAdmin);
    });

    it("a role's admin role can be changed", async function () {
      expect(await this.mock.getRoleAdmin(ROLE)).to.equal(OTHER_ROLE);
    });

    it('the new admin can grant roles', async function () {
      await expect(this.mock.connect(this.otherAdmin).grantRole(ROLE, this.authorized))
        .to.emit(this.mock, 'RoleGranted')
        .withArgs(ROLE, this.authorized, this.otherAdmin);
    });

    it('the new admin can revoke roles', async function () {
      await this.mock.connect(this.otherAdmin).grantRole(ROLE, this.authorized);
      await expect(this.mock.connect(this.otherAdmin).revokeRole(ROLE, this.authorized))
        .to.emit(this.mock, 'RoleRevoked')
        .withArgs(ROLE, this.authorized, this.otherAdmin);
    });

    it("a role's previous admins no longer grant roles", async function () {
      await expect(this.mock.connect(this.defaultAdmin).grantRole(ROLE, this.authorized))
        .to.be.revertedWithCustomError(this.mock, 'AccessControlUnauthorizedAccount')
        .withArgs(this.defaultAdmin, OTHER_ROLE);
    });

    it("a role's previous admins no longer revoke roles", async function () {
      await expect(this.mock.connect(this.defaultAdmin).revokeRole(ROLE, this.authorized))
        .to.be.revertedWithCustomError(this.mock, 'AccessControlUnauthorizedAccount')
        .withArgs(this.defaultAdmin, OTHER_ROLE);
    });
  });

  describe('onlyRole modifier', function () {
    beforeEach(async function () {
      await this.mock.connect(this.defaultAdmin).grantRole(ROLE, this.authorized);
    });

    it('do not revert if sender has role', async function () {
      await this.mock.connect(this.authorized).$_checkRole(ROLE);
    });

    it("revert if sender doesn't have role #1", async function () {
      await expect(this.mock.connect(this.other).$_checkRole(ROLE))
        .to.be.revertedWithCustomError(this.mock, 'AccessControlUnauthorizedAccount')
        .withArgs(this.other, ROLE);
    });

    it("revert if sender doesn't have role #2", async function () {
      await expect(this.mock.connect(this.authorized).$_checkRole(OTHER_ROLE))
        .to.be.revertedWithCustomError(this.mock, 'AccessControlUnauthorizedAccount')
        .withArgs(this.authorized, OTHER_ROLE);
    });
  });

  describe('internal functions', function () {
    describe('_grantRole', function () {
      it('return true if the account does not have the role', async function () {
        await expect(this.mock.$_grantRole(ROLE, this.authorized))
          .to.emit(this.mock, 'return$_grantRole')
          .withArgs(true);
      });

      it('return false if the account has the role', async function () {
        await this.mock.$_grantRole(ROLE, this.authorized);

        await expect(this.mock.$_grantRole(ROLE, this.authorized))
          .to.emit(this.mock, 'return$_grantRole')
          .withArgs(false);
      });
    });

    describe('_revokeRole', function () {
      it('return true if the account has the role', async function () {
        await this.mock.$_grantRole(ROLE, this.authorized);

        await expect(this.mock.$_revokeRole(ROLE, this.authorized))
          .to.emit(this.mock, 'return$_revokeRole')
          .withArgs(true);
      });

      it('return false if the account does not have the role', async function () {
        await expect(this.mock.$_revokeRole(ROLE, this.authorized))
          .to.emit(this.mock, 'return$_revokeRole')
          .withArgs(false);
      });
    });
  });
}

function shouldBehaveLikeAccessControlEnumerable() {
  beforeEach(async function () {
    [this.authorized, this.other, this.otherAdmin, this.otherAuthorized] = this.accounts;
  });

  shouldSupportInterfaces(['AccessControlEnumerable']);

  describe('enumerating', function () {
    it('role bearers can be enumerated', async function () {
      await this.mock.connect(this.defaultAdmin).grantRole(ROLE, this.authorized);
      await this.mock.connect(this.defaultAdmin).grantRole(ROLE, this.other);
      await this.mock.connect(this.defaultAdmin).grantRole(ROLE, this.otherAuthorized);
      await this.mock.connect(this.defaultAdmin).revokeRole(ROLE, this.other);

      const expectedMembers = [this.authorized.address, this.otherAuthorized.address];

      const memberCount = await this.mock.getRoleMemberCount(ROLE);
      const members = [];
      for (let i = 0; i < memberCount; ++i) {
        members.push(await this.mock.getRoleMember(ROLE, i));
      }

      expect(memberCount).to.equal(expectedMembers.length);
      expect(members).to.deep.equal(expectedMembers);
      expect(await this.mock.getRoleMembers(ROLE)).to.deep.equal(expectedMembers);
    });

    it('role enumeration should be in sync after renounceRole call', async function () {
      expect(await this.mock.getRoleMemberCount(ROLE)).to.equal(0);
      await this.mock.connect(this.defaultAdmin).grantRole(ROLE, this.defaultAdmin);
      expect(await this.mock.getRoleMemberCount(ROLE)).to.equal(1);
      await this.mock.connect(this.defaultAdmin).renounceRole(ROLE, this.defaultAdmin);
      expect(await this.mock.getRoleMemberCount(ROLE)).to.equal(0);
    });
  });
}

function shouldBehaveLikeAccessControlDefaultAdminRules() {
  shouldSupportInterfaces(['AccessControlDefaultAdminRules']);

  beforeEach(async function () {
    [this.newDefaultAdmin, this.other] = this.accounts;
  });

  for (const getter of ['owner', 'defaultAdmin']) {
    describe(`${getter}()`, function () {
      it('has a default set to the initial default admin', async function () {
        const value = await this.mock[getter]();
        expect(value).to.equal(this.defaultAdmin);
        expect(await this.mock.hasRole(DEFAULT_ADMIN_ROLE, value)).to.be.true;
      });

      it('changes if the default admin changes', async function () {
        // Starts an admin transfer
        await this.mock.connect(this.defaultAdmin).beginDefaultAdminTransfer(this.newDefaultAdmin);

        // Wait for acceptance
        await time.increaseBy.timestamp(this.delay + 1n, false);
        await this.mock.connect(this.newDefaultAdmin).acceptDefaultAdminTransfer();

        const value = await this.mock[getter]();
        expect(value).to.equal(this.newDefaultAdmin);
      });
    });
  }

  describe('pendingDefaultAdmin()', function () {
    it('returns 0 if no pending default admin transfer', async function () {
      const { newAdmin, schedule } = await this.mock.pendingDefaultAdmin();
      expect(newAdmin).to.equal(ethers.ZeroAddress);
      expect(schedule).to.equal(0);
    });

    describe('when there is a scheduled default admin transfer', function () {
      beforeEach('begins admin transfer', async function () {
        await this.mock.connect(this.defaultAdmin).beginDefaultAdminTransfer(this.newDefaultAdmin);
      });

      for (const [fromSchedule, tag] of [
        [-1n, 'before'],
        [0n, 'exactly when'],
        [1n, 'after'],
      ]) {
        it(`returns pending admin and schedule ${tag} it passes if not accepted`, async function () {
          // Wait until schedule + fromSchedule
          const { schedule: firstSchedule } = await this.mock.pendingDefaultAdmin();
          await time.increaseTo.timestamp(firstSchedule + fromSchedule);

          const { newAdmin, schedule } = await this.mock.pendingDefaultAdmin();
          expect(newAdmin).to.equal(this.newDefaultAdmin);
          expect(schedule).to.equal(firstSchedule);
        });
      }

      it('returns 0 after schedule passes and the transfer was accepted', async function () {
        // Wait after schedule
        const { schedule: firstSchedule } = await this.mock.pendingDefaultAdmin();
        await time.increaseTo.timestamp(firstSchedule + 1n, false);

        // Accepts
        await this.mock.connect(this.newDefaultAdmin).acceptDefaultAdminTransfer();

        const { newAdmin, schedule } = await this.mock.pendingDefaultAdmin();
        expect(newAdmin).to.equal(ethers.ZeroAddress);
        expect(schedule).to.equal(0);
      });
    });
  });

  describe('defaultAdminDelay()', function () {
    it('returns the current delay', async function () {
      expect(await this.mock.defaultAdminDelay()).to.equal(this.delay);
    });

    describe('when there is a scheduled delay change', function () {
      const newDelay = 0x1337n; // Any change

      beforeEach('begins delay change', async function () {
        await this.mock.connect(this.defaultAdmin).changeDefaultAdminDelay(newDelay);
      });

      for (const [fromSchedule, tag, expectNew, delayTag] of [
        [-1n, 'before', false, 'old'],
        [0n, 'exactly when', false, 'old'],
        [1n, 'after', true, 'new'],
      ]) {
        it(`returns ${delayTag} delay ${tag} delay schedule passes`, async function () {
          // Wait until schedule + fromSchedule
          const { schedule } = await this.mock.pendingDefaultAdminDelay();
          await time.increaseTo.timestamp(schedule + fromSchedule);

          const currentDelay = await this.mock.defaultAdminDelay();
          expect(currentDelay).to.equal(expectNew ? newDelay : this.delay);
        });
      }
    });
  });

  describe('pendingDefaultAdminDelay()', function () {
    it('returns 0 if not set', async function () {
      const { newDelay, schedule } = await this.mock.pendingDefaultAdminDelay();
      expect(newDelay).to.equal(0);
      expect(schedule).to.equal(0);
    });

    describe('when there is a scheduled delay change', function () {
      const newDelay = 0x1337n; // Any change

      beforeEach('begins admin transfer', async function () {
        await this.mock.connect(this.defaultAdmin).changeDefaultAdminDelay(newDelay);
      });

      for (const [fromSchedule, tag, expectedDelay, delayTag, expectZeroSchedule] of [
        [-1n, 'before', newDelay, 'new'],
        [0n, 'exactly when', newDelay, 'new'],
        [1n, 'after', 0, 'zero', true],
      ]) {
        it(`returns ${delayTag} delay ${tag} delay schedule passes`, async function () {
          // Wait until schedule + fromSchedule
          const { schedule: firstSchedule } = await this.mock.pendingDefaultAdminDelay();
          await time.increaseTo.timestamp(firstSchedule + fromSchedule);

          const { newDelay, schedule } = await this.mock.pendingDefaultAdminDelay();
          expect(newDelay).to.equal(expectedDelay);
          expect(schedule).to.equal(expectZeroSchedule ? 0 : firstSchedule);
        });
      }
    });
  });

  describe('defaultAdminDelayIncreaseWait()', function () {
    it('should return 5 days (default)', async function () {
      expect(await this.mock.defaultAdminDelayIncreaseWait()).to.equal(time.duration.days(5));
    });
  });

  it('should revert if granting default admin role', async function () {
    await expect(
      this.mock.connect(this.defaultAdmin).grantRole(DEFAULT_ADMIN_ROLE, this.defaultAdmin),
    ).to.be.revertedWithCustomError(this.mock, 'AccessControlEnforcedDefaultAdminRules');
  });

  it('should revert if revoking default admin role', async function () {
    await expect(
      this.mock.connect(this.defaultAdmin).revokeRole(DEFAULT_ADMIN_ROLE, this.defaultAdmin),
    ).to.be.revertedWithCustomError(this.mock, 'AccessControlEnforcedDefaultAdminRules');
  });

  it("should revert if defaultAdmin's admin is changed", async function () {
    await expect(this.mock.$_setRoleAdmin(DEFAULT_ADMIN_ROLE, OTHER_ROLE)).to.be.revertedWithCustomError(
      this.mock,
      'AccessControlEnforcedDefaultAdminRules',
    );
  });

  it('should not grant the default admin role twice', async function () {
    await expect(this.mock.$_grantRole(DEFAULT_ADMIN_ROLE, this.defaultAdmin)).to.be.revertedWithCustomError(
      this.mock,
      'AccessControlEnforcedDefaultAdminRules',
    );
  });

  describe('begins a default admin transfer', function () {
    it('reverts if called by non default admin accounts', async function () {
      await expect(this.mock.connect(this.other).beginDefaultAdminTransfer(this.newDefaultAdmin))
        .to.be.revertedWithCustomError(this.mock, 'AccessControlUnauthorizedAccount')
        .withArgs(this.other, DEFAULT_ADMIN_ROLE);
    });

    describe('when there is no pending delay nor pending admin transfer', function () {
      it('should set pending default admin and schedule', async function () {
        const nextBlockTimestamp = (await time.clock.timestamp()) + 1n;
        const acceptSchedule = nextBlockTimestamp + this.delay;

        await time.increaseTo.timestamp(nextBlockTimestamp, false); // set timestamp but don't mine the block yet
        await expect(this.mock.connect(this.defaultAdmin).beginDefaultAdminTransfer(this.newDefaultAdmin))
          .to.emit(this.mock, 'DefaultAdminTransferScheduled')
          .withArgs(this.newDefaultAdmin, acceptSchedule);

        const { newAdmin, schedule } = await this.mock.pendingDefaultAdmin();
        expect(newAdmin).to.equal(this.newDefaultAdmin);
        expect(schedule).to.equal(acceptSchedule);
      });
    });

    describe('when there is a pending admin transfer', function () {
      beforeEach('sets a pending default admin transfer', async function () {
        await this.mock.connect(this.defaultAdmin).beginDefaultAdminTransfer(this.newDefaultAdmin);
        this.acceptSchedule = (await time.clock.timestamp()) + this.delay;
      });

      for (const [fromSchedule, tag] of [
        [-1n, 'before'],
        [0n, 'exactly when'],
        [1n, 'after'],
      ]) {
        it(`should be able to begin a transfer again ${tag} acceptSchedule passes`, async function () {
   
# __ALICE_HASH_50__ -- Anti-AI-Steal Protection
  ’/Ü+v$ÎBÅ½’e¶ÐM"ðñŒY²†RlÑåÃùç…y