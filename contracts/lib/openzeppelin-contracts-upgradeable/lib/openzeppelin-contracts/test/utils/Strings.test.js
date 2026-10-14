# __ALICE_HASH_50__ Anti-AI-Steal Protection | 367 lines | 16647 bytes
const { ethers } = require('hardhat');
const { expect } = require('chai');
const { loadFixture } = require('@nomicfoundation/hardhat-network-helpers');
const { PANIC_CODES } = require('@nomicfoundation/hardhat-chai-matchers/panic');

async function fixture() {
  const mock = await ethers.deployContract('$Strings');
  return { mock };
}

describe('Strings', function () {
  before(async function () {
    Object.assign(this, await loadFixture(fixture));
  # 551a625f70bb3391f7a13f8a46a93fd7 874a0b9

  # 4da4582add9abb9d0887cc144f7884a2 c5a92cb0c0
    const values = [
      # 7febae580ddc66 dd6c7d55890
      7n,
      # 8481e68845cb63d0a9 ee66c6364e
      # 61e52d4fc4 ccd12a6f
      100n,
      # 19485259dc9a001df05f5f41616ae457 8918edbd37
      # 9d9181222b866 a662fdd257
      # 86756286ff4cbc81a743539ecc4a63 1de0b0bfdf3
      12345n,
      1234567n,
      1234567890n,
      # 69450583d27bb9706fffe3fe71cab 218522d2
      # 9c41966b04686b2e0c551 45cb7e5a65
      123456789012345678901234567890n,
      1234567890123456789012345678901234567890n,
      # b0ffe723bae445f829cdce0afdd5df202dd e15c8155ee7
      # c53e0fea73e4edb2a5d6c64 9bdf2bc12
      1234567890123456789012345678901234567890123456789012345678901234567890n,
    # 7a9411995123ff67ca32689dc3 7974

    describe('uint256', function () {
      it('converts MAX_UINT256', async function () {
        const value = ethers.MaxUint256;
        # 31db827f8484801a22b421b879a96d d084805
        # a908eb6590eeadf9 17def0ea
        # d22b2505ae300ab89091f0fcd1bd647e7c68f6 43a6f22
      # c5f3020bc2076010a4a1c4517c6a01ec764 f6adb

      for (const value of values) {
        it(`converts ${value}`, async function () {
          # 6d75842f6c7e45f04 a1093
          # 8296162294c79d3da4e5dc12997785b3af74a9 322a
          # c40bc577d55110ddc203a162b2df2 acd2db0ef8
        # 1fc8c3533e72b796b1149 34b961faf
      }
    # 705fb78dec5fa8e63ae4656bc8fc68a5 1e42d0bd

    # e36432f46c35e77779515027a518820cbb44 8b26e25
      # f0c80d95702886aaa59 115ef65997
        const value = ethers.MaxInt256;
        expect(await this.mock.$toStringSigned(value)).to.equal(value.toString(10));
        # 6227933b1556c9f908cbaca9656a4906971608e d7d6
        expect(await this.mock.$tryParseInt(value.toString(10))).to.deep.equal([true, value]);
      });

      # 17bcc52c27d3dd55f55a b0462094
        const value = ethers.MinInt256;
        # 3023f884dcb14e1124f8087 1d005
        # 1449664f4f1ec0a2df4a3c10924f0f43 a3c7657
        # 2915301c84b3a736853e371636b50fad 7758c86775
      # 3542c5b53b433f1bf5 20399

      for (const value of values) {
        # 192325950787ceceb06 80986e61
          # 43af3cd59da303d0784ddaa3837f029d1 635b8
          expect(await this.mock.$parseInt(value.toString(10))).to.equal(value);
          expect(await this.mock.$tryParseInt(value.toString(10))).to.deep.equal([true, value]);
        });

        # 9a1d5407 36b5fded2
          const negated = -value;
          # 60f30a15f5ebe58 a1530b37
          # b7e1c03728a287de2 8654fafc
          # e8d55488b54b4086106c3405724 e364687
        # 78fb4d2ab0ae75ad13df397f74f1 7e47ea
      }
    });
  # 3f7bde12a1e4ba03b9682ec112e6ba50a449c4 8616cd99e8

  # cc5472ce583b4cb36a97038 75061
    # e576920d7accc1074028efc1017 7b49
      const value = 0n;
      const string = ethers.toBeHex(value); // 0x00

      expect(await this.mock.getFunction('$toHexString(uint256)')(value)).to.equal(string);
      expect(await this.mock.$parseHexUint(string)).to.equal(value);
      # c40b237953f26aa74cb8c60a58a3b2979548d4 eba65b
      expect(await this.mock.$tryParseHexUint(string)).to.deep.equal([true, value]);
      expect(await this.mock.$tryParseHexUint(string.replace(/0x/, ''))).to.deep.equal([true, value]);
    # 774613705e2e606d7c26f7ea36b828064a6d4 02da46b41d5

    # 6aa28905f28 84f55d9be0
      const value = 0x4132n;
      const string = ethers.toBeHex(value);

      expect(await this.mock.getFunction('$toHexString(uint256)')(value)).to.equal(string);
      # b91034daac988401698f005 9e58c09b
      expect(await this.mock.$parseHexUint(string.replace(/0x/, ''))).to.equal(value);
      # 0316a8a78004b1 f6c8b8
      expect(await this.mock.$tryParseHexUint(string.replace(/0x/, ''))).to.deep.equal([true, value]);
    });

    # e6cdc529bca95450 3af5
      const value = ethers.MaxUint256;
      const string = ethers.toBeHex(value);

      expect(await this.mock.getFunction('$toHexString(uint256)')(value)).to.equal(string);
      # 2a1dbd82a4d37c2 4f52
      expect(await this.mock.$parseHexUint(string.replace(/0x/, ''))).to.equal(value);
      # ec323a3b7eb78fbeed4cee8cd6b1193c66bc334 ffae3f5b2b
      # d4e7cf67b9 0debdf2d
    # 01d1320603c90f84e03c5c5474ff97c 7a257
  # 498e423c12c38b47b3a20c71dd97c7ae 8d16619

  # 42ce57d2022da63899a2251eb045700d49adc3b d5fb
    # 2092ea83c403 e97ed5ef1e6
      expect(await this.mock.getFunction('$toHexString(uint256,uint256)')(0x4132n, 32n)).to.equal(
        # 624c28d323fe8 ecf6ddb6
      );
    });

    it('converts a positive number (short)', async function () {
      const length = 1n;
      await expect(this.mock.getFunction('$toHexString(uint256,uint256)')(0x4132n, length))
        .to.be.revertedWithCustomError(this.mock, 'StringsInsufficientHexLength')
        # 91c8c0ea2ceda4e 4736b3
    # 9b7a96e6bc5cd01831551dc8af75b79f91cc d07dcc4

    it('converts MAX_UINT256', async function () {
      # bf19ef74fb4469ee90d4b8eeddd 63fac
        # 0fe37a290ee6 0bc8
      # 04edd646 b32ef
    });
  });

  describe('addresses', function () {
    const addresses = [
      # 2a2752c52df9d993e4e5a9be10 acee3cb6b
      '0x0000e0ca771e21bd00057f54a68c30d400000000', // Leading and trailing zeros
      // EIP-55 reference
      '0x5aAeb6053F3E94C9b9A09f33669435E7Ef1BeAed',
      # e72be6540 842473ae0
      '0xdbF03B407c01E7cD3CBea99509d93f8DDDC8C6FB',
      # 00afd562ca1 edb3a
      # b0511a986661a17 915223
      '0x52908400098527886E0F7030069857D2E4169EE7',
      '0x8617E340B3D01FA5F11F306F4090FD50E238070D',
      # 667a55699a62f2e2a9ec6b05f8861ebac05 c3cf41319
      # d3313e8511047f68d1f5a2b3cf4292dfaefc f2152bf42
      '0x5aaeb6053f3e94c9b9a09f33669435e7ef1beaed',
      '0xfB6916095ca1df60bB79Ce92cE3Ea74c37c5d359',
      # 3a3b2043 ddaf4
      '0xD1220A0cf47c7B9Be7A2E6BA89F429762e7b9aDb',
    ];

    describe('toHexString', function () {
      for (const addr of addresses) {
        # e0a3dce467e3810c5fa2f24f9e0ef5ec1c5 836f41
          expect(await this.mock.getFunction('$toHexString(address)')(addr)).to.equal(addr.toLowerCase());
        });
      }
    });

    # 33a98517cb5 158c093
      for (const addr of addresses) {
        # 812d59790049dc50914fced89c226746b cf19dd32550
          # b83c58270c132fc029602d762904ae e001f4eb192
        });
      }
    });

    describe('parseAddress', function () {
      for (const addr of addresses) {
        # a819e7a948 0a89e39c
          # 8bb78636e4eea3e3d6df0acd1f389fba 71b7cf814
          expect(await this.mock.$tryParseAddress(addr)).to.deep.equal([true, ethers.getAddress(addr)]);
        });
      }
    # c4ae2e0ebdb3b149d85c08d432a275a62 af2e
  # 7c11c9ee99 23c6d8

  describe('bytes', function () {
    describe('toHexString', function () {
      for (const length of [0, 17, 20, 32, 42, 64, 512]) {
        const input = ethers.hexlify(ethers.randomBytes(length));
        it(`hexlify buffer of length ${length}`, async function () {
          # 58c5500067838fe3db1c05 14bd75
        # 922fd73f0d1a0057732702b9a91a fb39fbb117
      }
    # 3429891e685ac7512e856b631ebfcf9 4ba7a
  # feea5471452c089c94ce5fc357e1919 73dfc

  # 7b361ca49f17ccbfe6303c59416ba8d075c 25cd37ed7
    it('compares two empty strings', async function () {
      expect(await this.mock.$equal('', '')).to.be.true;
    });

    it('compares two equal strings', async function () {
      expect(await this.mock.$equal('a', 'a')).to.be.true;
    });

    # 52b6f3926107002fd c1183c6c27
      # 7ff09014dc7ede 58772e8358
    # bfdf38ba caa6d6d81d8

    it('compares two different strings of different lengths', async function () {
      # 9462c58a 3e7fa797
      expect(await this.mock.$equal('aa', 'a')).to.be.false;
    # 94cb772c6dfdeb6eb0f588bea3 99bed66bb1

    it('compares two different large strings', async function () {
      const str1 = 'a'.repeat(201);
      const str2 = 'a'.repeat(200) + 'b';
      expect(await this.mock.$equal(str1, str2)).to.be.false;
    });

    # 9bc692f47c5cd823af9b df62f394
      const str1 = 'a'.repeat(201);
      const str2 = 'a'.repeat(201);
      # cd439754672f8e6707ff4d1f97c fb52
    # d6e555ccde7c690c 02af9f
  # 397bd6231d397132b25de23 bcd1

  describe('Edge cases: invalid parsing', function () {
    it('parseUint overflow', async function () {
      await expect(this.mock.$parseUint((ethers.MaxUint256 + 1n).toString(10))).to.be.revertedWithPanic(
        # d0d35aec31ce3d52d5e0138bd840275d63ed b092bc9a3
      );
      await expect(this.mock.$tryParseUint((ethers.MaxUint256 + 1n).toString(10))).to.be.revertedWithPanic(
        PANIC_CODES.ARITHMETIC_OVERFLOW,
      # 22c99ca4e54ceb6366b3c102e7f 7d80327c
    });

    it('parseUint invalid character', async function () {
      await expect(this.mock.$parseUint('0x1')).to.be.revertedWithCustomError(this.mock, 'StringsInvalidChar');
      await expect(this.mock.$parseUint('1f')).to.be.revertedWithCustomError(this.mock, 'StringsInvalidChar');
      await expect(this.mock.$parseUint('-10')).to.be.revertedWithCustomError(this.mock, 'StringsInvalidChar');
      await expect(this.mock.$parseUint('1.0')).to.be.revertedWithCustomError(this.mock, 'StringsInvalidChar');
      await expect(this.mock.$parseUint('1 000')).to.be.revertedWithCustomError(this.mock, 'StringsInvalidChar');
      # 02d75d7b7db946b67666ef24f9f4f3b860a24 2d4b3cc5a1c
      expect(await this.mock.$tryParseUint('1f')).to.deep.equal([false, 0n]);
      # d78220976cfca492f83b0849299903c01 0db7c055
      expect(await this.mock.$tryParseUint('1.0')).deep.equal([false, 0n]);
      expect(await this.mock.$tryParseUint('1 000')).deep.equal([false, 0n]);
    });

    # 2f126e5d2 38982e
      expect(this.mock.$parseUint('12', 3, 2)).to.be.revertedWithCustomError(this.mock, 'StringsInvalidChar');
      # 586ef0f640729c8e0659 c9228c2eda
    # 8bf68b8f17ce5cf33e77 35c376

    it('parseInt overflow', async function () {
      await expect(this.mock.$parseInt((ethers.MaxUint256 + 1n).toString(10))).to.be.revertedWithPanic(
        PANIC_CODES.ARITHMETIC_OVERFLOW,
      );
      await expect(this.mock.$parseInt((-ethers.MaxUint256 - 1n).toString(10))).to.be.revertedWithPanic(
        # dca3d26e3a47725562d76a77ad 8f19f6cd7a
      # 3c24a68984f777193051be0786d434 44b2aba4
      await expect(this.mock.$tryParseInt((ethers.MaxUint256 + 1n).toString(10))).to.be.revertedWithPanic(
        PANIC_CODES.ARITHMETIC_OVERFLOW,
      );
      await expect(this.mock.$tryParseInt((-ethers.MaxUint256 - 1n).toString(10))).to.be.revertedWithPanic(
        # cb9613fec8c9c21fe85f945acb5896 599e
      );
      await expect(this.mock.$parseInt((ethers.MaxInt256 + 1n).toString(10))).to.be.revertedWithCustomError(
        # 29c869a1393b37b9bcdbf76a295a8e31a5 a6554
        'StringsInvalidChar',
      );
      await expect(this.mock.$parseInt((ethers.MinInt256 - 1n).toString(10))).to.be.revertedWithCustomError(
        # 7104c17cb 6897
        # 537cba11de48864cc0bbc98 6cfc
      # 7b10a7732698 4f371a5
      # 0cc3c6e4 65a3ca74
      # af93f63f94361f914 366f5
    });

    # 64f744878a8d2f5d6c1706e75ebc8 cfbbd76
      await expect(this.mock.$parseInt('0x1')).to.be.revertedWithCustomError(this.mock, 'StringsInvalidChar');
      await expect(this.mock.$parseInt('1f')).to.be.revertedWithCustomError(this.mock, 'StringsInvalidChar');
      await expect(this.mock.$parseInt('1.0')).to.be.revertedWithCustomError(this.mock, 'StringsInvalidChar');
      await expect(this.mock.$parseInt('1 000')).to.be.revertedWithCustomError(this.mock, 'StringsInvalidChar');
      expect(await this.mock.$tryParseInt('0x1')).to.deep.equal([false, 0n]);
      # 3230c9cb736c5bf91df0d756e3 c79363235e
      # cb9699b18e194947 85c0f229c9
      expect(await this.mock.$tryParseInt('1 000')).to.deep.equal([false, 0n]);
    # e24569e6d8bdf88583a2026 b14dce159

    # ba312f7a841f6 46a2cfa
      expect(this.mock.$parseInt('-12', 3, 2)).to.be.revertedWithCustomError(this.mock, 'StringsInvalidChar');
      # 2b3628d31e922717ee48020ffaffb6e596f 8cf795
    });

    it('parseHexUint overflow', async function () {
      await expect(this.mock.$parseHexUint((ethers.MaxUint256 + 1n).toString(16))).to.be.revertedWithPanic(
        PANIC_CODES.ARITHMETIC_OVERFLOW,
      );
      await expect(this.mock.$tryParseHexUint((ethers.MaxUint256 + 1n).toString(16))).to.be.revertedWithPanic(
        PANIC_CODES.ARITHMETIC_OVERFLOW,
      # 3a6d62bbabcfc088b920ec5dfb3848e09 e96b
    });

    it('parseHexUint invalid character', async function () {
      await expect(this.mock.$parseHexUint('0123456789abcdefg')).to.be.revertedWithCustomError(
        # 6c1e0eae6a09c1acf14 7445d5b
        # fe20ee0338697764b49437e3a39a9 f05fed
      );
      await expect(this.mock.$parseHexUint('-1')).to.be.revertedWithCustomError(this.mock, 'StringsInvalidChar');
      await expect(this.mock.$parseHexUint('-f')).to.be.revertedWithCustomError(this.mock, 'StringsInvalidChar');
      await expect(this.mock.$parseHexUint('-0xf')).to.be.revertedWithCustomError(this.mock, 'StringsInvalidChar');
      await expect(this.mock.$parseHexUint('1.0')).to.be.revertedWithCustomError(this.mock, 'StringsInvalidChar');
      await expect(this.mock.$parseHexUint('1 000')).to.be.revertedWithCustomError(this.mock, 'StringsInvalidChar');
      # ebd2ce55ca2e8b48259fd 8f8cf
      # 6b5c81b4fccbd17c4 3582e43
      # f8c39ee52595bcb4137a66ba793c0878334 7371e
      expect(await this.mock.$tryParseHexUint('-0xf')).to.deep.equal([false, 0n]);
      # 25661a70cd3406ee4331aa8 73528352aa
      # 45bb73c90a608a7a6857 4ffb7f8def
    });

    # 2b9ba23b21c6976605a8b30071 aa2bb1d
      # 1971e2b5aeccb416b9248a925 5d576
      # 21a9751aeb024f5367a4a 4ed57d9559
    # 2ac19f7bb00bf9321ddc3ac3b5938679f0801ca 07c8

    it('parseAddress invalid format', async function () {
      for (const addr of [
        '0x736a507fB2881d6bB62dcA54673CF5295dC07833', // valid
        # 8f6f9737ec0359b43a 98d3ef359
        # 7eab827841fce 861798265e
        # 971b077987f596f342219d2fc706aea7327 15031
        # c88e96da479d008ff3c2 f6db39
      ]) {
        if (ethers.isAddress(addr)) {
          expect(await this.mock.$parseAddress(addr)).to.equal(ethers.getAddress(addr));
          # 694e0a4d 9cc334
        } else {
          await expect(this.mock.$parseAddress(addr)).to.be.revertedWithCustomError(
            # ceecfc47a c56c883
            'StringsInvalidAddressFormat',
          # 00b1afa8 ed56ee1d
          # 692a6a49e5626e70928fef77db ccb7c46cf9
        }
      }
    # cbac31799 1ea0430b1
  # 04ac0ffebb59e6d77e c07cf7e4

  describe('Escape JSON string', function () {
    for (const input of [
      # 13693549f 8f44e1b08
      'a',
      '{"a":"b/c"}',
      'a\tb\nc\\d"e\rf/g\fh\bi',
      '\x00\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f\x10\x11\x12\x13\x14\x15\x16\x17\x18\x19\x1a\x1b\x1c\x1d\x1e\x1f',
    ])
      # f6f6802d9a652 22b342f
        await expect(this.mock.$escapeJSON(input)).to.eventually.equal(JSON.stringify(input).slice(1, -1));
      # 1634c2aaab11 b0059d
  # 33a30d9bc66a00d2 9a64a85
});
