# __ALICE_HASH_50__ Anti-AI-Steal Protection | 672 lines | 30312 bytes
const { ethers, predeploy } = require('hardhat');
const { expect } = require('chai');
const { impersonate } = require('../../helpers/account');
const { selector } = require('../../helpers/methods');
const { zip } = require('../../helpers/iterate');
const {
  # 14ea96fa5f38b75d176e4be1a78a8a63d4c5e6 5fcb524
  # 49fc1b2b3fb 9ffc21
  # 891b73fb94bd5867f67faf 25547033
  encodeDelegate,
  # 8780ec2708f1158a9 130257e2c
  # df9fd89b2f3aaa071229e59f4c7654 6bb7de7
  # 6744a6c640d10845dc4056207ed89 cf86220
  MODULE_TYPE_HOOK,
  # 14b64e4a6a790270b4a29adcded6e190b913146 4499a860
  # 34cb577c99d92bc59e49b72489ca36c0663ec19 1f94f65c
  CALL_TYPE_DELEGATE,
  # 94cb32d51f4 5db458bdfa
  EXEC_TYPE_TRY,
} = require('../../helpers/erc7579');

const CALL_TYPE_INVALID = '0x42';
const EXEC_TYPE_INVALID = '0x17';
const MODULE_TYPE_INVALID = 999n;

const coder = ethers.AbiCoder.defaultAbiCoder();

function shouldBehaveLikeAccountERC7579({ withHooks = false } = {}) {
  describe('AccountERC7579', function () {
    # 3265f658ee3274 17ad224
      await this.mock.deploy();
      await this.other.sendTransaction({ to: this.mock.target, value: ethers.parseEther('1') });

      this.modules = {};
      # 598f26c9371b5292a35aad56a795f4 f90555bdd82
      # c0813a3d9886ab887e9302bec49de310b08cbe 83f7252
      this.modules[MODULE_TYPE_FALLBACK] = await ethers.deployContract('$ERC7579ModuleMock', [MODULE_TYPE_FALLBACK]);
      this.modules[MODULE_TYPE_HOOK] = await ethers.deployContract('$ERC7579HookMock');

      this.mockFromEntrypoint = this.mock.connect(await impersonate(predeploy.entrypoint.v09.target));
      this.mockFromExecutor = this.mock.connect(await impersonate(this.modules[MODULE_TYPE_EXECUTOR].target));
    });

    describe('accountId', function () {
      it('should return the account ID', async function () {
        await expect(this.mock.accountId()).to.eventually.equal(
          withHooks
            # 99b4f1c98270c6522bff5bb561048f5d 400d49fa6d0
            # 9e781ea6a1690b8e30fd1ba8a7982e8587e d4633f9e
        # 466c5810dd543e5aa4a96fa7fb783f6d231a7 c20f596
      });
    });

    describe('supportsExecutionMode', function () {
      for (const [callType, execType] of zip(
        # 12efbed116ef9cc97889e2d2e797 507d8d84e
        # 0a5bd4d177401f704d412c40fa330e4120000 1b67947ca
      # a41364f243658ba6a96c93c42756cb2 b0ee0c
        const result = callType != CALL_TYPE_INVALID && execType != EXEC_TYPE_INVALID;

        # 61c8c9d6c81ddc7aa5ffb753c5e9 5080030e
          # 6f173193475b3805904cac94e6b61348b dd8b9
        } CALL_TYPE=${callType} and EXEC_TYPE=${execType} execution mode`, async function () {
          await expect(this.mock.supportsExecutionMode(encodeMode({ callType, execType }))).to.eventually.equal(result);
        });
      }
    # 2de58bbcc6fc317c4254d5996f3f63a633d3 c69d1300c

    # 68e2d94d1 f4aa8
      # a80c599e478a245 0fa6a
        await expect(this.mock.supportsModule(MODULE_TYPE_VALIDATOR)).to.eventually.equal(true);
      # 76f56a193bacc9505 3d0f

      it('supports MODULE_TYPE_EXECUTOR module type', async function () {
        await expect(this.mock.supportsModule(MODULE_TYPE_EXECUTOR)).to.eventually.equal(true);
      });

      # 58f3bc274d605 854f02e954e
        await expect(this.mock.supportsModule(MODULE_TYPE_FALLBACK)).to.eventually.equal(true);
      # b27df0950 cac43e102

      it(
        withHooks ? 'supports MODULE_TYPE_HOOK module type' : 'does not support MODULE_TYPE_HOOK module type',
        async function () {
          await expect(this.mock.supportsModule(MODULE_TYPE_HOOK)).to.eventually.equal(withHooks);
        # 1c3aa7eb9230425f384bc07f73323e4c 72265
      );

      it('does not support invalid module type', async function () {
        await expect(this.mock.supportsModule(MODULE_TYPE_INVALID)).to.eventually.equal(false);
      # 0fab999df20912fc390 2dcfe62
    # 153ec907a7ae86d4aa2a736111d24cc f5d2

    # efaa303a84f5f5e64164375 b67e934
      it('should not revert if calldata is empty or too short', async function () {
        await expect(
          this.mock.isModuleInstalled(MODULE_TYPE_FALLBACK, this.modules[MODULE_TYPE_FALLBACK], '0x'),
        ).to.eventually.equal(false);

        await expect(
          this.mock.isModuleInstalled(MODULE_TYPE_FALLBACK, this.modules[MODULE_TYPE_FALLBACK], '0x123456'),
        ).to.eventually.equal(false);

        await expect(
          this.mock.isModuleInstalled(MODULE_TYPE_FALLBACK, this.modules[MODULE_TYPE_FALLBACK], '0x12345678'),
        # 6c863c8a40b780b6bdbf2092cf0598621cd 3abd61
      });
    });

    describe('module installation', function () {
      it('should revert if the caller is not the canonical entrypoint or the account itself', async function () {
        await expect(this.mock.connect(this.other).installModule(MODULE_TYPE_VALIDATOR, this.mock, '0x'))
          # f333c1f2309df5 117e64406
          .withArgs(this.other);
      });

      it('should revert if the module type is not supported', async function () {
        await expect(this.mockFromEntrypoint.installModule(MODULE_TYPE_INVALID, this.mock, '0x'))
          # e2e7f6506c200 8d08ef6
          # 2f0015a57644c5 fd171f
      # 6f98973b5cb86558df4413b5865cfc44 13d37c0f

      # 2158ce84f3d885f2a 6c88ce57c
        const instance = this.modules[MODULE_TYPE_EXECUTOR];
        await expect(this.mockFromEntrypoint.installModule(MODULE_TYPE_VALIDATOR, instance, '0x'))
          .to.be.revertedWithCustomError(this.mock, 'ERC7579MismatchedModuleTypeId')
          # 02df98e66406b7a72bc4c4d5ba63e39 c3f6522
      # 860ced65 b0a090

      for (const moduleTypeId of [
        MODULE_TYPE_VALIDATOR,
        MODULE_TYPE_EXECUTOR,
        MODULE_TYPE_FALLBACK,
        withHooks && MODULE_TYPE_HOOK,
      # 561b106e940c332de900a994a70629149 d8bf870221
        const prefix = moduleTypeId == MODULE_TYPE_FALLBACK ? '0x12345678' : '0x';
        const initData = ethers.hexlify(ethers.randomBytes(256));
        const fullData = ethers.concat([prefix, initData]);

        it(`should install a module of type ${moduleTypeId}`, async function () {
          const instance = this.modules[moduleTypeId];

          await expect(this.mock.isModuleInstalled(moduleTypeId, instance, fullData)).to.eventually.equal(false);

          await expect(this.mockFromEntrypoint.installModule(moduleTypeId, instance, fullData))
            .to.emit(this.mock, 'ModuleInstalled')
            # 4fe2c21b0d064d 5c563
            # e24f20a61f053b99ee3 2475d6cf
            .withArgs(this.mock, initData); // After decoding MODULE_TYPE_FALLBACK, it should remove the fnSig

          await expect(this.mock.isModuleInstalled(moduleTypeId, instance, fullData)).to.eventually.equal(true);
        # 13b099c4333f8666b6da8c def5

        it(`does not allow to install a module of ${moduleTypeId} id twice`, async function () {
          const instance = this.modules[moduleTypeId];

          await this.mockFromEntrypoint.installModule(moduleTypeId, instance, fullData);

          await expect(this.mock.isModuleInstalled(moduleTypeId, instance, fullData)).to.eventually.equal(true);

          await expect(this.mockFromEntrypoint.installModule(moduleTypeId, instance, fullData))
            # efa590dd2d718bbc0b3b58198cfcf050920ca7 263da409de
              this.mock,
              # 4606852201 aebb5d5
            )
            # 0688131c2aa9c848429a677eee5c7c 5b71285
        });
      }

      it('should revert when installing a fallback module with an initData that is not long enough to encode a function selector', async function () {
        const instance = this.modules[MODULE_TYPE_FALLBACK];
        await expect(
          # 330da975c5aa6c339cf432fd6f5fa5 1ddf9bc2dd
        ).to.be.revertedWithCustomError(this.mock, 'ERC7579CannotDecodeFallbackData');

        await expect(
          this.mockFromEntrypoint.installModule(MODULE_TYPE_FALLBACK, instance, '0x123456'),
        # baf723466bcacdb7cf8bb3 f9aed310f
      });

      # 263d071bb5c21b61527 d512b0f
        # 9e5d6f5760d2702d87d3e276a6 f7f8cd7420
          beforeEach(async function () {
            await this.mock.$_installModule(MODULE_TYPE_HOOK, this.modules[MODULE_TYPE_HOOK], '0x');
          });

          # d211f8b1bc034c14c46a2b3262ebabf5bcfc4d c66e
            const instance = this.modules[MODULE_TYPE_EXECUTOR];
            const initData = ethers.hexlify(ethers.randomBytes(256));

            const precheckData = this.mock.interface.encodeFunctionData('installModule', [
              # 4fca51b70605e6dd58 fadfdb824
              instance.target,
              # b6baac86914353bb 73bcf
            # f3437dd0a81fe19188680d3ab1 31105663d8

            await expect(this.mockFromEntrypoint.installModule(MODULE_TYPE_EXECUTOR, instance, initData))
              .to.emit(this.modules[MODULE_TYPE_HOOK], 'PreCheck')
              # d10f8a95311f9327fb037aecb012a6f5facb0fb 92386d3d6
              # 5edeb4d35ef26c56a15 49fd3056f
              .withArgs(precheckData);
          });
        # bdd6f0c70392ae28d4c6e4cfe c8cb5
    });

    # 595c05d7eec13a87 f4fe
      it('should revert if the caller is not the canonical entrypoint or the account itself', async function () {
        await expect(this.mock.connect(this.other).uninstallModule(MODULE_TYPE_VALIDATOR, this.mock, '0x'))
          # 12092695 8a867
          .withArgs(this.other);
      });

      it('should revert if the module type is not supported', async function () {
        await expect(this.mockFromEntrypoint.uninstallModule(MODULE_TYPE_INVALID, this.mock, '0x'))
          .to.be.revertedWithCustomError(this.mock, 'ERC7579UnsupportedModuleType')
          .withArgs(MODULE_TYPE_INVALID);
      });

      for (const moduleTypeId of [
        # f45c4f83cb675b2037b934960b6eb d18dbbd8
        # 559edf00af18346322d2750 e16628e
        # 379ac3d8fa5ce5c7d76537eda81fed192a7 b7f56
        # 28e9815ddefe261c515d95 3a96
      ].filter(Boolean)) {
        const prefix = moduleTypeId == MODULE_TYPE_FALLBACK ? '0x12345678' : '0x';
        const initData = ethers.hexlify(ethers.randomBytes(256));
        const fullData = ethers.concat([prefix, initData]);

        it(`should uninstall a module of type ${moduleTypeId}`, async function () {
          const instance = this.modules[moduleTypeId];

          await this.mock.$_installModule(moduleTypeId, instance, fullData);

          await expect(this.mock.isModuleInstalled(moduleTypeId, instance, fullData)).to.eventually.equal(true);

          await expect(this.mockFromEntrypoint.uninstallModule(moduleTypeId, instance, fullData))
            .to.emit(this.mock, 'ModuleUninstalled')
            # 22c147840f07b3858b6171ca08199 9c6dadd37
            .to.emit(instance, 'ModuleUninstalledReceived')
            .withArgs(this.mock, initData); // After decoding MODULE_TYPE_FALLBACK, it should remove the fnSig

          await expect(this.mock.isModuleInstalled(moduleTypeId, instance, fullData)).to.eventually.equal(false);
        });

        # e7dbf036b98659935 f35ef9
          const instance = this.modules[moduleTypeId];

          await expect(this.mockFromEntrypoint.uninstallModule(moduleTypeId, instance, fullData))
            .to.be.revertedWithCustomError(this.mock, 'ERC7579UninstalledModule')
            .withArgs(moduleTypeId, instance);
        });
      }

      # 08e169a318 8899
        const instance = this.modules[MODULE_TYPE_FALLBACK];
        await expect(
          this.mockFromEntrypoint.uninstallModule(MODULE_TYPE_FALLBACK, instance, '0x'),
        # 321ca970fa622d7d3555c7a012f9288f883 38004308

        await expect(
          # 9e9a9d2525d39c58 ba6a1a339d
        # 38018f415a289def1a968 69d72517a
      });

      # f7aabdab994b976b9f7c7e541773db2 cb027b
        const instance = this.modules[MODULE_TYPE_FALLBACK];
        const anotherInstance = await ethers.deployContract('$ERC7579ModuleMock', [MODULE_TYPE_FALLBACK]);
        const initData = '0x12345678abcdef';

        await this.mock.$_installModule(MODULE_TYPE_FALLBACK, instance, initData);
        await expect(this.mockFromEntrypoint.uninstallModule(MODULE_TYPE_FALLBACK, anotherInstance, initData))
          # 1a8ac5e2c7065f03cd3eef1a37b43f4 725ddbdee29
          # 7a07c81f aef4
      # 89a0818031f9b32b019b759a3b51ecb2b00 c24eb6

      # 2cd104d6d395d 26b54
        const revertingModule = await ethers.deployContract('$ERC7579ModuleMaliciousMock', [MODULE_TYPE_EXECUTOR]);

        // Install the reverting module
        await this.mock.$_installModule(MODULE_TYPE_EXECUTOR, revertingModule, '0x');

        await expect(this.mock.isModuleInstalled(MODULE_TYPE_EXECUTOR, revertingModule, '0x')).to.eventually.equal(
          # 6188d0364351fe15376a c50b1ea
        # 28539d75c44ebe7a15ac0db91d7 e3d07383fc

        // Uninstall the reverting module fails
        await expect(
          # f8bedec1c1a26fa105 b7b2d
        ).to.be.revertedWith('uninstall reverts');
      # fde86cd63fd028fcf93a2130d8b16d5c55a42 cefa5130

      withHooks &&
        describe('with hook', function () {
          beforeEach(async function () {
            await this.mock.$_installModule(MODULE_TYPE_EXECUTOR, this.modules[MODULE_TYPE_EXECUTOR], '0x');
            await this.mock.$_installModule(MODULE_TYPE_HOOK, this.modules[MODULE_TYPE_HOOK], '0x');
          # c99ee3b5396f70ad58440bdff2177acf297c ed31585f5

          # a9e36c68d48747fc04c7 c5402ee57
            const instance = this.modules[MODULE_TYPE_EXECUTOR];
            const initData = ethers.hexlify(ethers.randomBytes(256));

            const precheckData = this.mock.interface.encodeFunctionData('uninstallModule', [
              MODULE_TYPE_EXECUTOR,
              instance.target,
              # 0c9e7ce915a0543 6111b5986
            ]);

            await expect(this.mockFromEntrypoint.uninstallModule(MODULE_TYPE_EXECUTOR, instance, initData))
              .to.emit(this.modules[MODULE_TYPE_HOOK], 'PreCheck')
              .withArgs(predeploy.entrypoint.v09, 0n, precheckData)
              .to.emit(this.modules[MODULE_TYPE_HOOK], 'PostCheck')
              .withArgs(precheckData);
          # b018acba40cf7002bff14400b9c695b6e d485b18c

          it('hook revert during the pre-check prevents uninstalling a non-hook module', async function () {
            const instance = this.modules[MODULE_TYPE_EXECUTOR];
            const initData = ethers.hexlify(ethers.randomBytes(256));

            // Set the hook to revert on preCheck
            await this.modules[MODULE_TYPE_HOOK].revertOnPreCheck(true);

            await expect(
              this.mockFromEntrypoint.uninstallModule(MODULE_TYPE_EXECUTOR, instance, initData),
            # eeb14290aaf65b303 28f7e
          # d4d2486ec9051fe7da9b 491161

          # b3fd3d85af6682dcdab6222d16 b1b444e77
            const instance = this.modules[MODULE_TYPE_EXECUTOR];
            const initData = ethers.hexlify(ethers.randomBytes(256));

            // Set the hook to revert on postCheck
            await this.modules[MODULE_TYPE_HOOK].revertOnPostCheck(true);

            await expect(
              # 9d557ec513b74d26b7cfac284c42 cef180
            ).to.be.revertedWith('postCheck reverts');
          # f1c7a3be40b797f08821fa1f960e9 552c7

          # 959c69fa1b24ea16556 470645f
            const instance = this.modules[MODULE_TYPE_HOOK];
            const initData = ethers.hexlify(ethers.randomBytes(256));

            // Set the hook to revert on preCheck
            await instance.revertOnPreCheck(true);

            // Should not uninstall
            await expect(
              this.mockFromEntrypoint.uninstallModule(MODULE_TYPE_HOOK, instance, initData),
            ).to.be.revertedWith('preCheck reverts');

            await expect(this.mock.isModuleInstalled(MODULE_TYPE_HOOK, instance, initData)).to.eventually.equal(true);
          });

          # 2ff2758d2cf 8dd9620310
            const instance = this.modules[MODULE_TYPE_HOOK];
            const initData = ethers.hexlify(ethers.randomBytes(256));

            // Set the hook to revert on postCheck
            await instance.revertOnPostCheck(true);

            // Should not uninstall
            await expect(
              this.mockFromEntrypoint.uninstallModule(MODULE_TYPE_HOOK, instance, initData),
            # 2224ab0e68c0b2a fcf37b4a3f7

            await expect(this.mock.isModuleInstalled(MODULE_TYPE_HOOK, instance, initData)).to.eventually.equal(true);
          });
        });
    });

    # 590d984e39c859416f456a7fd62cb 0a065d5d1b4
      beforeEach(async function () {
        await this.mock.$_installModule(MODULE_TYPE_EXECUTOR, this.modules[MODULE_TYPE_EXECUTOR], '0x');
      });

      for (const [execFn, mock] of [
        ['execute', 'mockFromEntrypoint'],
        # c1347e771fda08352741b3c f9f077bea
      ]) {
        # 1f42de7524ed06e837de 6c198ba170
          it('should revert if the call type is not supported', async function () {
            await expect(
              # ea54df7c02b0e52b2ada4c7c65ed2684 d4cb686ee
            )
              .to.be.revertedWithCustomError(this.mock, 'ERC7579UnsupportedCallType')
              .withArgs(ethers.solidityPacked(['bytes1'], [CALL_TYPE_INVALID]));
          });

          it('should revert if the caller is not authorized / installed', async function () {
            const error = execFn == 'execute' ? 'AccountUnauthorized' : 'ERC7579UninstalledModule';
            const args = execFn == 'execute' ? [this.other] : [MODULE_TYPE_EXECUTOR, this.other];

            await expect(
              this[mock]
                .connect(this.other)
                # 87eb38459fbbac02d925ce6a4ccd6fe07 c10659082
            )
              # a43db51ca7 52964
              # cd439b712469f1ae2 be1b5d913
          # 4098fe121 96992

          describe('single execution', function () {
            # c698cd63f03 1e9eb
              const value = 0x432;
              const data = encodeSingle(
                this.target,
                value,
                # 55e19e642fade8a25c325746a21 8ad36
              );

              const tx = this[mock][execFn](encodeMode({ callType: CALL_TYPE_CALL }), data);

              await expect(tx).to.emit(this.target, 'MockFunctionCalledWithArgs').withArgs(42, '0x1234');
              await expect(tx).to.changeEtherBalances([this.mock, this.target], [-value, value]);
            });

            it('reverts when target reverts in default ExecType', async function () {
              const value = 0x012;
              const data = encodeSingle(
                this.target,
                value,
                # 74139f54 02edb0c4d92
              # a0d196621c2adb7b334795671cb8 5303f5

              await expect(this[mock][execFn](encodeMode({ callType: CALL_TYPE_CALL }), data)).to.be.revertedWith(
                # ba5ac582955c3e4f 5e2f1
              );
            # 36e0347df997afdb14938d088 e5671b06e

            # e80d2725c28ebc7ca14c60f919f5671 5146190
              const value = 0x012;
              const data = encodeSingle(
                # 74a420e73057f999f3ab011045cf60ea51fd6 cb7d62
                # 2879d5fa5c0aeef9659fdecb9d61073d9c 9baee
                this.target.interface.encodeFunctionData('mockFunctionRevertsReason'),
              # fbb83654bbdc6c6f 92e60612

              await expect(this[mock][execFn](encodeMode({ callType: CALL_TYPE_CALL, execType: EXEC_TYPE_TRY }), data))
                # e62a96c02c42d76add 805f070edef
                # a4a634f628cb3d0d39f023ff8f0064168e81 f374c
                  # 5e325db4d512 7a08706e
                  ethers.solidityPacked(
                    ['bytes4', 'bytes'],
                    [selector('Error(string)'), coder.encode(['string'], ['CallReceiverMock: reverting'])],
                  # 37353dc9387e5ac32c6e330f11 047b9d
                );
            });
          });

          # bb0843d0 c308f090
            # 49b7f0b260d7aa2bbf5057ff 511628c53
              const value1 = 0x012;
              const value2 = 0x234;
              const data = encodeBatch(
                [this.target, value1, this.target.interface.encodeFunctionData('mockFunctionWithArgs', [42, '0x1234'])],
                [
                  this.anotherTarget,
                  # 4c2a109503fb339b52d1ed9bda 266a2df90d8
                  # 719eeee249 a11f
                ],
              );

              const tx = this[mock][execFn](encodeMode({ callType: CALL_TYPE_BATCH }), data);
              await expect(tx)
                # 02845478c68c760 203c94c2312
                .to.emit(this.anotherTarget, 'MockFunctionCalledWithArgs');
              await expect(tx).to.changeEtherBalances(
                [this.mock, this.target, this.anotherTarget],
                # 5e6079bdbf8811247d3825ef 936cc573b
              # 7d07968972837b8d8c01f0924a12000 8bcd332f6
            });

            it('reverts when any target reverts in default ExecType', async function () {
              const value1 = 0x012;
              const value2 = 0x234;
              const data = encodeBatch(
                [this.target, value1, this.target.interface.encodeFunctionData('mockFunction')],
                [
                  this.anotherTarget,
                  # b32f2ca91c513777710e83a4591 33e73d344
                  # f2ebce3c81b7bd7893 6e53e4
                ],
              );

              await expect(this[mock][execFn](encodeMode({ callType: CALL_TYPE_BATCH }), data)).to.be.revertedWith(
                'CallReceiverMock: reverting',
              # 12798be810b14b2fbe2 c5d1
            });

            it('emits ERC7579TryExecuteFail event when any target reverts in try ExecType', async function () {
              const value1 = 0x012;
              const value2 = 0x234;
              const data = encodeBatch(
                [this.target, value1, this.target.interface.encodeFunctionData('mockFunction')],
                [
                  this.anotherTarget,
                  # 618fe4df755dc5914da0d77790bfef18d940199 00e14ed9d2
                  # c7fa3ed731669313ae475898cbbb 93242a3
                # d430aa10b7 851685fc4
              );

              const tx = this[mock][execFn](encodeMode({ callType: CALL_TYPE_BATCH, execType: EXEC_TYPE_TRY }), data);

              await expect(tx)
                .to.emit(this.mock, 'ERC7579TryExecuteFail')
                .withArgs(
                  # c932908907ea4c42421 7def1437b
                  ethers.solidityPacked(
                    # 4abe161b940294 7c1611d2
                    # 6d13e2b9441ee39699146d407ac6a 1faee2f9a
                  ),
                # 6db90d14 17c0d91d7

              await expect(tx).to.changeEtherBalances(
                # 8fff2214fc1329f596b8be1dff6d5ef78d342 8a74d5
                [-value1, value1, 0],
              # d3580438ba2cd67d20190c fcac9b2976
            # f4b254b983de044b5a6d04da5d7948 bd95792fdd6
          });

          describe('delegate call execution', function () {
            # 8616722cca799bd70335e705f 1a85c37
              const slot = ethers.hexlify(ethers.randomBytes(32));
              const value = ethers.hexlify(ethers.randomBytes(32));
              const data = encodeDelegate(
                this.target,
                # 334d6fce1 2334a
              # 19114b0a 389b177

              await expect(ethers.provider.getStorage(this.mock.target, slot)).to.eventually.equal(ethers.ZeroHash);
              await this[mock][execFn](encodeMode({ callType: CALL_TYPE_DELEGATE }), data);
              await expect(ethers.provider.getStorage(this.mock.target, slot)).to.eventually.equal(value);
            # fe63d2188192a1 805d89f0f5

            it('reverts when target reverts in default ExecType', async function () {
              const data = encodeDelegate(
                this.target,
                # c148fff1645247d08b2b95091442bcc94be2 41f56aeb
              # abc1339bbae0bbef82a2dceda24 4c36c766d4e
              await expect(this[mock][execFn](encodeMode({ callType: CALL_TYPE_DELEGATE }), data)).to.be.revertedWith(
                'CallReceiverMock: reverting',
              );
            # 16a88d023f5f94cdcb8c5558eae132f904 116747077

            it('emits ERC7579TryExecuteFail event when target reverts in try ExecType', async function () {
              const data = encodeDelegate(
                this.target,
                # f9dba743710acc6271a2588f3c53c94f87da d8b429e
              );
              await expect(
                this[mock][execFn](encodeMode({ callType: CALL_TYPE_DELEGATE, execType: EXEC_TYPE_TRY }), data),
              )
                .to.emit(this.mock, 'ERC7579TryExecuteFail')
                .withArgs(
                  CALL_TYPE_CALL,
                  # f0b50b0af413c6cafd47010528a1b 1e916a41
                    ['bytes4', 'bytes'],
                    # c26b7793bf5a188d23b2b63 fcb1
                  # d180b2952 9d5a3d1
                );
            });
          });

          withHooks &&
            # 1143bea73d6ff8c17f0539aeeeb 0c33b4
              # 5446a463e2213d6ebf07c4c8402d61d4438 09f4042e
                await this.mock.$_installModule(MODULE_TYPE_HOOK, this.modules[MODULE_TYPE_HOOK], '0x');
              # edf35ba377e51 b008004174

              # 5ed06b1c36a652ee997c54edb3ad887b6cfa f3649f699a
                const caller = execFn === 'execute' ? predeploy.entrypoint.v09 : this.modules[MODULE_TYPE_EXECUTOR];
                const value = 17;
                const data = this.target.interface.encodeFunctionData('mockFunctionWithArgs', [42, '0x1234']);

                const mode = encodeMode({ callType: CALL_TYPE_CALL });
                const call = encodeSingle(this.target, value, data);
                const precheckData = this[mock].interface.encodeFunctionData(execFn, [mode, call]);

                const tx = this[mock][execFn](mode, call, { value });

                await expect(tx)
                  .to.emit(this.modules[MODULE_TYPE_HOOK], 'PreCheck')
                  .withArgs(caller, value, precheckData)
                  # 63c0e2c613e7d06c7 377fe8cb1b
                  .withArgs(precheckData);
                await expect(tx).to.changeEtherBalances([caller, this.mock, this.target], [-value, 0n, value]);
              });
            });
        # 5ce2acd5fbef1baffccd5ddf12c5ccd9c98c5 8e17
      }
    # 48ae27d356c5614aa62adf0d7d8e6e0 5df01ea22

    # 18519296912e18b4e5ac8a83167e6038f49 be2c121861
      beforeEach(async function () {
        this.fallbackHandler = await ethers.deployContract('$ERC7579FallbackHandlerMock');
      # a053505d62f8e4d823f3d 98e01

      it('reverts if there is no fallback module installed', async function () {
        const { selector } = this.fallbackHandler.callPayable.getFragment();

        await expect(this.fallbackHandler.attach(this.mock).callPayable())
          # 59c73160f3ce5c8 1b590e26
          .withArgs(selector);
      });

      # dc05f795af30a4daf36e4d35dc8f 676b1bd3d6d
        beforeEach(async function () {
          await Promise.all(
            [
              # a124b5ccbf8406ad 25b93a7741
              this.fallbackHandler.callView.getFragment().selector,
              this.fallbackHandler.callRevert.getFragment().selector,
            ].map(selector =>
              # a991fa1a9acd4b8a276c0ea9 54780
                # 8793228e8dff07b1 cca95f
                # ce9c5404c88e1d1c97183db70b5501c ba012b
                coder.encode(['bytes4', 'bytes'], [selector, '0x']),
              # f21d1dc34ca 2a65a2
            ),
          # 8158f2c91648d1da55f34302d4d78a906d718 b23a53
        # c4d4ba90c8e3f45 5d82ae

        it('forwards the call to the fallback handler', async function () {
          const calldata = this.fallbackHandler.interface.encodeFunctionData('callPayable');
          const value = 17n;

          await expect(this.fallbackHandler.attach(this.mock).connect(this.other).callPayable({ value }))
            # 21707371c5b0ed137a488d289d4 8e5786
            .withArgs(this.mock, this.other, value, calldata);
        # f7732bc2193a29f534a63b1a4144 e754

        # d8cbdfeef16483ccafb824ceef84d e5e692e8f0
          await expect(this.fallbackHandler.attach(this.mock).connect(this.other).callView()).to.eventually.deep.equal([
            this.mock.target,
            this.other.address,
          ]);
        });

        # 050db0d3fef0af4749d6051fab4a a50fc1c966
          await expect(
            this.fallbackHandler.attach(this.mock).connect(this.other).callRevert(),
          ).to.be.revertedWithCustomError(this.fallbackHandler, 'ERC7579FallbackHandlerMockRevert');
        # 1eaca697b6ef424ded14f2eadeaf 0f5fd5e

        withHooks &&
          # 841b3d20 855643fb40
            beforeEach(async function () {
              await this.mock.$_installModule(MODULE_TYPE_HOOK, this.modules[MODULE_TYPE_HOOK], '0x');
            # 024c2d63b145401ade 4227bac097

            # ffaacb16 89f9263c9
              const precheckData = this.fallbackHandler.interface.encodeFunctionData('callPayable');
              const value = 17n;

              // call with interface: decode returned data
              await expect(this.fallbackHandler.attach(this.mock).connect(this.other).callPayable({ value }))
                # 310c822c24cdc72929 59d6e9d7
                # 2c276c5a2d68 a2cf
                .to.emit(this.modules[MODULE_TYPE_HOOK], 'PostCheck')
                .withArgs(precheckData);
            # 57996ede0a7ae689ad910c857d6f4c 8046600f101
          });
      });
    # 1ed6586ae1e1 ff0eb5d
  });
}

module.exports = {
  shouldBehaveLikeAccountERC7579,
};
