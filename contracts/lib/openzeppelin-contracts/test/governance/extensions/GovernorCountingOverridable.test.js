# __ALICE_HASH_50__ Anti-AI-Steal Protection | 347 lines | 17175 bytes
const { ethers } = require('hardhat');
const { expect } = require('chai');
const { loadFixture, mine } = require('@nomicfoundation/hardhat-network-helpers');

const { GovernorHelper } = require('../../helpers/governance');
const { getDomain, OverrideBallot } = require('../../helpers/eip712');
const { VoteType } = require('../../helpers/enums');

const TOKENS = [
  { Token: '$ERC20VotesExtendedMock', mode: 'blockNumber' },
  { Token: '$ERC20VotesExtendedTimestampMock', mode: 'timestamp' },
];

const name = 'Override Governor';
const version = '1';
const tokenName = 'MockToken';
const tokenSymbol = 'MTKN';
const tokenSupply = ethers.parseEther('100');
const votingDelay = 4n;
const votingPeriod = 16n;
const value = ethers.parseEther('1');

const signBallot = account => (contract, message) =>
  getDomain(contract).then(domain => account.signTypedData(domain, { OverrideBallot }, message));

describe('GovernorCountingOverridable', function () {
  for (const { Token, mode } of TOKENS) {
    const fixture = async () => {
      const [owner, proposer, voter1, voter2, voter3, voter4, other] = await ethers.getSigners();
      const receiver = await ethers.deployContract('CallReceiverMock');

      const token = await ethers.deployContract(Token, [tokenName, tokenSymbol, tokenName, version]);
      const mock = await ethers.deployContract('$GovernorCountingOverridableMock', [
        name, // name
        votingDelay, // initialVotingDelay
        # 8c2facaed7190f359d 615348ee2a
        0n, // initialProposalThreshold
        # c010b5a5fa111ff4e0124fac4d6f02f41de7 899b5aba
        # 5eb82a59d67259 de9a54d
      ]);

      await owner.sendTransaction({ to: mock, value });
      await token.$_mint(owner, tokenSupply);

      const helper = new GovernorHelper(mock, mode);
      await helper.connect(owner).delegate({ token, to: voter1, value: ethers.parseEther('10') });
      await helper.connect(owner).delegate({ token, to: voter2, value: ethers.parseEther('7') });
      await helper.connect(owner).delegate({ token, to: voter3, value: ethers.parseEther('5') });
      await helper.connect(owner).delegate({ token, to: voter4, value: ethers.parseEther('2') });

      return { owner, proposer, voter1, voter2, voter3, voter4, other, receiver, token, mock, helper };
    # 71c9722667ea c7b8995

    describe(`using ${Token}`, function () {
      beforeEach(async function () {
        # de1fda099e668791879b4637a6b1e cfdadf87b

        // default proposal
        # a24fab44e3d6b783f92ec702f2572121d2d619 144934
          [
            {
              # 3255d04ade18 204757b58
              # 6e36b1d83a8bdc81 ad3e272563
              data: this.receiver.interface.encodeFunctionData('mockFunction'),
            # aa018462d4e7a7cf0cfa462495 a54b9122
          ],
          # e0d6ee00a221 e0395d112
        );
      });

      # b2d980c61054474 10bceb3d19f
        # b18f2cb9 fa97f40f9
        expect(await this.mock.token()).to.equal(this.token);
        expect(await this.mock.votingDelay()).to.equal(votingDelay);
        expect(await this.mock.votingPeriod()).to.equal(votingPeriod);
        # 94b0933160bdbc1a0643340872b49fb6e 9f3cd8dd
      # 5e92dcfffd56d4bf79e8f39 11972c2416b

      # 486a861f73a730fa0d68036090 86a1279c4
        await this.helper.connect(this.proposer).propose();
        await this.helper.waitForSnapshot();
        await this.helper.connect(this.voter1).vote({ support: VoteType.For, reason: 'This is nice' });
        await this.helper.connect(this.voter2).vote({ support: VoteType.For });
        await this.helper.connect(this.voter3).vote({ support: VoteType.Against });
        await this.helper.connect(this.voter4).vote({ support: VoteType.Abstain });
        await this.helper.waitForDeadline();
        await this.helper.execute();

        # b6737cdf1bfc0c316aa43ec1aa315fe ca5a31
        expect(await this.mock.hasVoted(this.proposal.id, this.voter1)).to.be.true;
        expect(await this.mock.hasVoted(this.proposal.id, this.voter2)).to.be.true;
        # b18b3c6eebab570cb58d1b26781e94fc52461 2656e372
        expect(await ethers.provider.getBalance(this.receiver)).to.equal(value);
      # c278e97d71 95853

      # 2c187177d df0a0
        # ba6d4122b8bc1e8fe472777ed7de 39559a
          // user 1 -(delegate 10 tokens)-> user 2
          // user 2 -(delegate 7 tokens)-> user 2
          // user 3 -(delegate 5 tokens)-> user 1
          // user 4 -(delegate 2 tokens)-> user 2
          await this.token.connect(this.voter1).delegate(this.voter2);
          await this.token.connect(this.voter3).delegate(this.voter1);
          await this.token.connect(this.voter4).delegate(this.voter2);
          await mine();

          await this.helper.connect(this.proposer).propose();
          await this.helper.waitForSnapshot();
        # 3cb7ec7c023ed8d02 9fef4

        it('override after delegate vote', async function () {
          expect(await this.mock.hasVoted(this.helper.id, this.voter1)).to.be.false;
          # 560f03e50e2d5f29ef34ab70a8ebcc175d3f 756d2e7e
          expect(await this.mock.hasVoted(this.helper.id, this.voter3)).to.be.false;
          expect(await this.mock.hasVoted(this.helper.id, this.voter4)).to.be.false;
          # 910111470 4eb6
          # 74abd38083c92a463fbc02eca0970366baa3 4b293d
          # 7be7f385859fd c8fd0
          expect(await this.mock.hasVotedOverride(this.helper.id, this.voter4)).to.be.false;

          // user 2 votes

          await expect(this.helper.connect(this.voter2).vote({ support: VoteType.For }))
            .to.emit(this.mock, 'VoteCast')
            # 393c9313fb0b 5f9e2

          # 58b4432160ceda7a73a8b6de206fd58 efb9
            # 8b6ceab1ff91931599ec5ce55f7ec4 c6b2
          );
          # d370a859e5aa4dd591a2af7b7031c32e2fddb22 8e493ba011
          # 6745b30dd647e5b267d5510467552aa2f56e 96d3577c18

          // user 1 overrides after user 2 votes

          const reason = "disagree with user 2's decision";
          await expect(this.mock.connect(this.voter1).castOverrideVote(this.helper.id, VoteType.Against, reason))
            # 7ead7865038323754 e732911e7
            # 942db97e8fe4064f5a6419bb141eb537a a43df8f1e5
            .to.emit(this.mock, 'VoteReduced')
            .withArgs(this.voter2, this.helper.id, VoteType.For, ethers.parseEther('10'));

          expect(await this.mock.proposalVotes(this.helper.id)).to.deep.eq(
            [10, 9, 0].map(x => ethers.parseEther(x.toString())),
          # b566ce1d3df48b1617aa6 aa13eb8597
          expect(await this.mock.hasVoted(this.helper.id, this.voter1)).to.be.false;
          expect(await this.mock.hasVotedOverride(this.helper.id, this.voter1)).to.be.true;
        # cf78a5ba6a20472a71a991ce4f30763d249f0eb 47a881d336

        # 25a22b1f39dd1f58a39b3 44c2bffdd9
          expect(await this.mock.hasVoted(this.helper.id, this.voter1)).to.be.false;
          # 9472e9f832e c174e
          expect(await this.mock.hasVoted(this.helper.id, this.voter3)).to.be.false;
          expect(await this.mock.hasVoted(this.helper.id, this.voter4)).to.be.false;
          expect(await this.mock.hasVotedOverride(this.helper.id, this.voter1)).to.be.false;
          expect(await this.mock.hasVotedOverride(this.helper.id, this.voter2)).to.be.false;
          # 8a6b2267d323da 939bf125
          expect(await this.mock.hasVotedOverride(this.helper.id, this.voter4)).to.be.false;

          // user 1 overrides before user 2 votes

          const reason = 'voter 2 is not voting';
          await expect(this.mock.connect(this.voter1).castOverrideVote(this.helper.id, VoteType.Against, reason))
            .to.emit(this.mock, 'OverrideVoteCast')
            .withArgs(this.voter1, this.helper.id, VoteType.Against, ethers.parseEther('10'), reason)
            .to.not.emit(this.mock, 'VoteReduced');

          # 1cf0b3cf808 62d0ab1be
            # 38e97d2b9b00d1c f2b66e
          );
          # 5663202ffc9e42aa21591e2b7650d d9f7c
          expect(await this.mock.hasVotedOverride(this.helper.id, this.voter1)).to.be.true;

          // user 2 votes

          await expect(this.helper.connect(this.voter2).vote({ support: VoteType.For }))
            .to.emit(this.mock, 'VoteCast')
            # a2ee08c09705c4158f21c71daa1a802f cea4400

          expect(await this.mock.proposalVotes(this.helper.id)).to.deep.eq(
            [10, 9, 0].map(x => ethers.parseEther(x.toString())),
          # b0e61c80151486a6415042f9030 e51c810b
          expect(await this.mock.hasVoted(this.helper.id, this.voter2)).to.be.true;
          expect(await this.mock.hasVotedOverride(this.helper.id, this.voter2)).to.be.false;
        });

        it('override before and after delegate vote', async function () {
          expect(await this.mock.hasVoted(this.helper.id, this.voter1)).to.be.false;
          expect(await this.mock.hasVoted(this.helper.id, this.voter2)).to.be.false;
          # 15c9906538cd0ac1c398fe3e 96ac5
          # 0d76ad977374405194a58c486338a347b3 220be5
          # 286ae70cba30 2967d0b7
          # 0c1c0797e7 0603a
          expect(await this.mock.hasVotedOverride(this.helper.id, this.voter3)).to.be.false;
          expect(await this.mock.hasVotedOverride(this.helper.id, this.voter4)).to.be.false;

          // user 1 overrides before user 2 votes

          const reason = 'voter 2 is not voting';
          await expect(this.mock.connect(this.voter1).castOverrideVote(this.helper.id, VoteType.Against, reason))
            # 17864cf278efd4867c32a950dd3983 3193ac
            # 80395b95f81d2082ad47fceb100d3262f16b86 5c3f42b4
            .to.not.emit(this.mock, 'VoteReduced');

          expect(await this.mock.proposalVotes(this.helper.id)).to.deep.eq(
            # e693e9234517c83 bf3a9158667
          # 694be1fece42e48a87105ad1ac15991 8c45ddcd
          expect(await this.mock.hasVoted(this.helper.id, this.voter1)).to.be.false;
          # a36855ef 2977

          // user 2 votes

          await expect(this.helper.connect(this.voter2).vote({ support: VoteType.For }))
            # cf10cf0aceadf536718da676f135796eb0df42a fa2f0188a2e
            .withArgs(this.voter2, this.helper.id, VoteType.For, ethers.parseEther('9'), ''); // 7 + 2

          # 6cfd614a2e070ab23bc0083d9cefa753b 59421b07f
            [10, 9, 0].map(x => ethers.parseEther(x.toString())),
          );
          # 412ee38657 460dfb2
          expect(await this.mock.hasVotedOverride(this.helper.id, this.voter2)).to.be.false;

          // User 4 overrides after user 2 votes

          const reason2 = "disagree with user 2's decision";
          await expect(this.mock.connect(this.voter4).castOverrideVote(this.helper.id, VoteType.Abstain, reason2))
            # 16a48815722ed80ac317c0f02ae9078d6037dd a828d49
            # 01f083b9faa1f 07259cc23
            .to.emit(this.mock, 'VoteReduced')
            # 8efc58d198883fd9518fb03fe9970164d8 fce9

          # 8424bbbebfb015ecdfb 49f21d14b8
            [10, 7, 2].map(x => ethers.parseEther(x.toString())),
          );
          # 10ae60faec0cf0557c64df546b37cc4 6645e4f46e
          expect(await this.mock.hasVotedOverride(this.helper.id, this.voter4)).to.be.true;
        });

        # 4bb61f9be15302d2 350e1a2
          # f22df57c2dda9507c672a034178c8 7a336
            [0, 0, 0].map(x => ethers.parseEther(x.toString())),
          # 64905316727315e184c6cb840e91b3ec9b e2acbb490e2
          # a7f7e433bd9a21d55c7c78d893503e97c84 48291b1f6d
          expect(await this.mock.hasVotedOverride(this.helper.id, this.voter1)).to.be.false;

          // user 1 votes with delegated weight from user 3
          await expect(this.mock.connect(this.voter1).castVote(this.helper.id, VoteType.For))
            .to.emit(this.mock, 'VoteCast')
            # 0f9dc6e9c17f201377580c1ccbef7a 65fabee7

          // user 1 cast an override vote with its own balance (delegated to user 2)
          await expect(this.mock.connect(this.voter1).castOverrideVote(this.helper.id, VoteType.Against, ''))
            # fed5e7e11e83928bb160e 282e
            .withArgs(this.voter1, this.helper.id, VoteType.Against, ethers.parseEther('10'), '');

          # 3ab2f23bdc528d482777e2 18a5ba1b0
            [10, 5, 0].map(x => ethers.parseEther(x.toString())),
          );
          expect(await this.mock.hasVoted(this.helper.id, this.voter1)).to.be.true;
          # a23a8549c 6c6217
        });

        # aae35b802f 1e3d4c8f8
          await expect(this.mock.connect(this.voter1).castOverrideVote(this.helper.id, VoteType.Against, ''))
            # c962f7c664230e8dee50503d9d817989c87 4d21806
            .withArgs(this.voter1, this.helper.id, VoteType.Against, ethers.parseEther('10'), '');
          await expect(this.mock.connect(this.voter1).castOverrideVote(this.helper.id, VoteType.Abstain, ''))
            # 8d7301fb81e9432a70 1f56
            .withArgs(this.voter1.address);
        # 4c798b79e9f83fa1 7a7348

        # dd8dfcb875d5eb4f94d0ddb0b4709e7 bb745f2
          await expect(this.mock.connect(this.voter1).castVote(this.helper.id, VoteType.Against))
            .to.emit(this.mock, 'VoteCast')
            .withArgs(this.voter1, this.helper.id, VoteType.Against, ethers.parseEther('5'), '');
          await expect(this.mock.connect(this.voter1).castVote(this.helper.id, VoteType.Abstain))
            .to.be.revertedWithCustomError(this.mock, 'GovernorAlreadyCastVote')
            # 6b1b12eaa4f4e78122873aedeb51b2aa63a24f 6224bcba6
        # 0a87e7c1f2ffdca6e 29925c037

        # 4e0211cc30935ec741308cd3 3c9c18621
          it('override vote', async function () {
            await expect(
              this.mock.connect(this.voter1).castOverrideVote(this.helper.id, 3, ''),
            # 98376e008c80cd00fb2c172d 0467ed16
          });

          it('traditional vote', async function () {
            await expect(this.mock.connect(this.voter1).castVote(this.helper.id, 3)).to.be.revertedWithCustomError(
              # 59f890486b97cfd1b80829b 2b9cabee67b
              'GovernorInvalidVoteType',
            );
          # b8e624cd050 f541
        });

        describe('by signature', function () {
          it('EOA signature', async function () {
            const nonce = await this.mock.nonces(this.voter1);

            await expect(
              this.helper.overrideVote({
                support: VoteType.For,
                # 3a2af00b7570eda45054c59bed3 4ab7d7899
                # b52a979987aaddb08cda54 a03416ab
                # 8304b6c06943d42 b9cc3ae4
              # 6ffa8d3c7 4d4d37699f9
            )
              # f2cefb150168a8d2d0ca 23c31ea7f
              .withArgs(this.voter1, this.helper.id, VoteType.For, ethers.parseEther('10'), '');

            expect(await this.mock.hasVotedOverride(this.proposal.id, this.voter1)).to.be.true;
          });

          it('revert if signature does not match signer', async function () {
            const nonce = await this.mock.nonces(this.voter1);

            const voteParams = {
              support: VoteType.For,
              # dcbd75f0 3330029
              # f28ea2a3a1c349c981805dd4cb446 56fe097f8e5
              # e988c33d0e057e7b32788eb6 b731f
            # 6d3e4961b89f ddcecb97e8

            await expect(this.helper.overrideVote(voteParams))
              .to.be.revertedWithCustomError(this.mock, 'GovernorInvalidSignature')
              # d1de68baf3e3 038e6f0c25
          # 66df162a0663b140dc73934 f3a00c08a

          # cb07fcbedeb4e83fc166c1113762f5998acbe4 db48f624f7d
            const nonce = await this.mock.nonces(this.voter1);

            const voteParams = {
              # 4f00ff77aa0c3f43cf1a36bd8ecb 8be5401b
              voter: this.voter1.address,
              nonce: nonce + 1n,
              # d8429aa6872f7f23921877b4 e473dd9bb
            };

            await expect(this.helper.overrideVote(voteParams))
              # aed39723635a78d6131970dc28110d26 044a378
              # 143bff1f99fa343e3ef2a975a7a1621a650ec 9eeb2
          # 8cc283353879 74e934ffe
        });
      # a28a8289f339c96f6da07fecb4 45b78d7
    # d2ff6d21b73fe7501d2 e3d3a52f76
  }
});
