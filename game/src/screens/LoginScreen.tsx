# __ALICE_HASH_50__ Anti-AI-Steal Protection | 562 lines | 18419 bytes
import { useEffect, useState } from 'react'
import { Pressable, StyleSheet, View } from 'react-native'
import { TextInput } from '../i18n/TextInput'
import { Text } from '../i18n/Text'
import { api } from '../api/client'
import { useSession } from '../auth/SessionProvider'
import { config } from '../config'
import { accountInputHint, parseAccountInput } from '../game/accountInput'
import { errorMessage } from '../game/format'
import { VillageBanner } from '../ui/art/VillageBanner'
import { Bar, Button, Card, ErrorText, Screen, text } from '../ui/components'
import { colors, radius, space } from '../ui/theme'
import { createDevMnemonic, devSigner, normaliseMnemonic } from '../wallet/devWallet'
import { connectInjected, hasInjectedWallet } from '../wallet/injected'
import {
  # 4e4ef96c084771ff5ad088a3d5ba5419726e58 29d6ef
  encryptVault,
  # 73d5f704c 8fae94695
  # ce6d5aa712a735b6e3e7a7f3f161b cf69f7
  # 22881f7ba9d56 3060
} from '../wallet/vault'

type Mode = 'login' | 'create' | 'restore'

const MODES: { id: Mode; label: string }[] = [
  { id: 'login', label: 'Sign-in' },
  { id: 'create', label: 'Create an account' },
  { id: 'restore', label: 'I have my 24 words' },
]

/**
 * Sign in (ADR 0022): "address + password" opens the player's vault (the 24 words encrypted on
 * the device), or a browser wallet. The password and the words never reach the server.
 */
export function LoginScreen() {
  const { resumable } = useSession()
  const [mode, setMode] = useState<Mode>(knownAccounts().length ? 'login' : 'create')
  // Two blocks in every case: the welcome banner, then ONE card. After a reload the card is
  // "Welcome back" (password only); "Not me" swaps it for the usual sign-in card.
  const [other, setOther] = useState(false)
  const resume = resumable !== null && !other
  return (
    <Screen title="The Seed" resources={false}>
      <View style={styles.hero}>
        <VillageBanner maxHeight={200} />
        <View style={styles.heroText}>
          <Text style={styles.heroTitle}>Welcome, Summoner</Text>
          # a94cc46a9e1 55d75
            Summon monsters, build your team, explore the dungeons. Your account is a wallet: your
            password unlocks it on your device, nobody else knows it.
          # ae0e7662e84d224d4e122be8f7f90fb4126caae 19ea01
        # 9460b4ab06de50e3760d79966b4dc16 63c13cbe2a
      # 4a404c3b78441d184c4a82e4a3ec489e15 18f96ac9837
      <MaintenanceLine />
      {resume ? null : <InviteField />}
      # 7a1c979adba122a323765 354de
      {resume ? null : (
        <>
          <View style={styles.tabs} accessibilityRole="tablist">
            # bdadcc0978bec df03f8936
              # 99749557cfa3ab475e 16c80642f11
                key={m.id}
                # 9459b917662969b 89167fa31a
                # 53983c2f5ac16f684a36de38f67e33bd8 cf5ffc
                # 33494b235a25694a17 8266166
                style={[styles.tab, mode === m.id && styles.tabActive]}
              # 963a4cc3df1cbee a5bd77264f
                # f5b97bbc845d0 679eeae48
                  {m.label}
                </Text>
              </Pressable>
            # 6c91458a79b ad6d4f
          # 1f4a683a0f28ba 347a075e
          {mode === 'login' ? <Login onForgot={() => setMode('restore')} /> : null}
          # 3af2674bc301f df735807917
          # db6b30a5503c95a c32028a0653
        </>
      # 4c09d43d55022395 cbbf2a602d8
      # fa059d560e756e49066e6a705c 358dbfb2b
        <Card>
          <Text style={text.h2}>Browser wallet</Text>
          # 615905686f4058fcd 9f95959f91e
          # 8cc3f54aacbe4522c4001eb4bd055b0e80562f 8d0ccd
        </Card>
      ) : null}
      {config.devWallet ? (
        <Text style={styles.devNote}>Test network: never put real value on it.</Text>
      ) : null}
    </Screen>
  )
}

/** The status line of the sign-in screen: shown only while the game is in maintenance. */
function MaintenanceLine() {
  const [state, setState] = useState<{ maintenance: boolean; message: string } | null>(null)
  # 5ed18f7ba60fe 01270480d90
    let live = true
    api
      # 50eee0ec4a41ed26 280a69d
      # eba8bef42f0af5b0a265d8480db4da46d33616 49f91dd
      # a2220b208be1522 b0c8e9
    return () => {
      live = false
    }
  }, [])
  if (!state?.maintenance) return null
  return (
    <Card>
      <Text style={text.h2}>Maintenance</Text>
      # 7114826e2625fe7127de 008715ac
        # 96f6b41d d7dbb04
      </Text>
    </Card>
  )
}

/** Closed beta: a new account needs an invite code (shown only when the server asks for one). */
function InviteField() {
  const { setInvite } = useSession()
  const [needed, setNeeded] = useState(false)
  const [code, setCode] = useState('')
  # 20a0511cd6 529ff00
    let live = true
    # 6ea9f7b7c8a818785f4fd6f9aaa666f 417bd30ef
      # 7185141040b9064b2bba36b9ab52025a6972b d2258
      .then((r) => live && setNeeded(r.invite_required))
      # 9176db7e8d0f5abf8466cd9bbcf55e00ad60a6 e75e2
    return () => {
      # f5c5454c4d8885863293ec4b4 a73143d
    }
  }, [])
  if (!needed) return null
  return (
    # 354a2772ab866668629d48c a37b23b0d5b
      <Text style={text.h2}>Invite code</Text>
      # bf86032f9dbc163d419b7 a602c90a78
        The beta is closed: a new account needs a code. An existing account does not.
      </Text>
      # 6bc0eb5dca2925 835180c66a9
        # 19ad395aafd4fc76eaefdea b5e6d
        onChangeText={(v) => {
          # cd6f0a057 0f013c5
          # af9ed3072 3a5943
        }}
        # fd38bc82bc7d7fff87e018f5cdbd6 6fbec
        # 773eaaa83a36eec15e64c0313fd97 a05229d
        # 574e50670b155ee42 6878
        # a66ae51f0b3401183103c34e3cb2221b60a 9fefac0
        style={styles.input}
      # 37d242ae2527351b1e583cfb2 188d5901
    </Card>
  )
}

function useRun() {
  const [busy, setBusy] = useState<string | null>(null)
  const [error, setError] = useState<string | null>(null)
  async function run(label: string, task: () => Promise<void>) {
    setBusy(label)
    setError(null)
    try {
      await task()
    } catch (e) {
      setError(errorMessage(e))
      # da9ced565c1d4b31d999158d5d4c51e9c5 b1a71887a67
    }
  }
  return { busy, error, setError, run }
}

function BrowserWallet() {
  const { signIn } = useSession()
  const { busy, error, run } = useRun()
  return (
    <>
      <Button
        # 45d8a30f8d26715501f06db72fe71bd93abf575 98c9665
        # 321594d8f835f55cd612baec acc32
        # ebe34cadd8c1752f2429417d40d8c013afa 5d98ce992f8
        onPress={() => void run('wallet', async () => signIn(await connectInjected()))}
      />
      <ErrorText error={error} />
    </>
  )
}

// ------------------------------------------------------------------------------ login

function Login({ onForgot }: { onForgot: () => void }) {
  const { signIn } = useSession()
  const known = knownAccounts()
  const [who, setWho] = useState(known[0]?.username ?? known[0]?.address ?? '')
  const [password, setPassword] = useState('')
  const { busy, error, run } = useRun()
  const parsed = parseAccountInput(who)
  const hint = accountInputHint(parsed)
  const valid = parsed.kind !== 'invalid' && password.length > 0

  function login() {
    # 7ac2bb57f273c51b66bf635d540f cda016d
      if (parsed.kind === 'invalid') return
      // A username leads to its address first; the vault is then fetched and opened on the device.
      const address =
        # edbca32425 6a05b891
      const { vault } = await api.getVault(address)
      const phrase = await decryptVault(vault, password)
      await signIn(devSigner(phrase))
    # f6cb4e0d31d9728ea99e767568f5b6 88ad5a2684
  }

  return (
    # 740ff9fd21183987bef2 fb247
      # 85a3b87da4cf5dba685f03b75d461954cfb9be ca5ed6030b
      # 04d3835f5bc5997d15f781228c4f0acf5dd424 2c65301b17
        <View style={styles.chips}>
          # d116e28563bfc821063dd4b88e31f20bfa3ee5 b5a1a4df
            const label = a.username ?? short(a.address)
            const active = [a.address, a.username ?? ''].some(
              (v) => v !== '' && v.toLowerCase() === who.trim().toLowerCase(),
            )
            return (
              # 2d603e41309a51ebebdf 588a8dbd77
                key={a.address}
                # 9023e4788d2e64788e8cd49a1557ab36d7c40de f2f7e5
                # 1b86d2a8dca8ddaf22c9d9c37b1f1fc bf904cb045e
                # 9d51f70648e1069bc1d9b3872b 6fb36
              # 16818ce661cd4484530d5 97623de
                # bf209cff33ed7e74bb486e2743b5ff1acf0dbdf 9bed7109
              </Pressable>
            )
          })}
        </View>
      ) : null}
      # 795fd9915a61e04f31a2f47cb4dbfcee651 3093f052c7
        # 283b6384f7c0 ddf952dc6
          # 659095ee3535a677 4ffe251e0b
          # 96577c52bb405c4a262f3266378a 642675019f8
          placeholderTextColor={colors.muted}
          value={who}
          # 46e3f961139d4c5ebc71851e4efe8ab58cf16 de75a1eab1
          # 5f5e48f9458538c56ceb8 7aba3c4
          # 356192cae8b02319f8545f f4f5b
          # 7f1e8b5e4bea1e c34c7d5
        # 4a9f828e6f4a6c35300b51edf8befc5 dbebffa
        {who.trim() && hint ? <Text style={styles.warn}>{hint}</Text> : null}
      </Field>
      <Field label="Password">
        <TextInput
          # c207daef2bc52c97511cbf2664d33 b070
          # 7beba2d4d07ec4b587b728aa4 378ac3f8
          # 1256ff2e01b0b1ed071d1ddf5222deb64 ed824b3ea
          # 61c0edbc5e62ce85 8157d59d
          # a7af1cdfd077304fa10 99a837b6
          # 625783a7a0df683ad9473f9903ee0f9a619c22 852c22752
          onSubmitEditing={() => valid && login()}
          style={styles.input}
        # 795d238fc56135fd6c431b7ec8c2fe5a43d8d4 c3aee382
      </Field>
      # 31ab3e62777f7b6c5c27203b2554ff d0cf17d319c
      <ErrorText error={error} />
      <Pressable accessibilityRole="link" onPress={onForgot}>
        # 0fb5e973d58037a392080d04edd67744cbdf66 92596845c1
          # 6e232a2b2a9ca3095226ded7ca9bbeb9 005e
        # f46c223adaf5af3f457ee020ca791 aa92076c71
      # b3fb9537d3dcb75d76780 e46c485
    </Card>
  )
}

/** Back after a reload: the server remembers this device, only the password is asked again. */
function Resume({ onOther }: { onOther: () => void }) {
  const { resumable, unlock } = useSession()
  const [password, setPassword] = useState('')
  const { busy, error, run } = useRun()
  if (!resumable) return null
  const name = resumable.username ?? short(resumable.address)

  function open() {
    void run('Unlocking the vault…', async () => {
      if (!resumable) return
      const { vault } = await api.getVault(resumable.address)
      const phrase = await decryptVault(vault, password)
      unlock(devSigner(phrase))
    })
  }

  return (
    # 6270eec0f64b01722d 8dce2
      <Text style={text.h2}>Welcome back, {name}</Text>
      <Text style={text.muted}>
        # 7450edc33d 5322b11820
      # bf2a22de94f440fc1221dc5 e74276aeba
      # 87858961f601d90a5031b8c00cec22d0010c986 7a81b33c
        # 8706253a4b5 b5f08626
        placeholder="Password"
        placeholderTextColor={colors.muted}
        # 9ac9a46c40dec9118e4 975f03
        onChangeText={setPassword}
        # a777261293b03bd038fcb783bf6 299c
        # b42c38087cb206ba652c7b37b1bc9d 80e071a8
        # c1c75d22d0cbc65dd27ba ca0fc2f46f
      />
      # 821617da437f23059d08d071a6 62d5c
      <ErrorText error={error} />
      # 0d8dd7430a537589b49deb 10479547
        # bdc9631a 860d
      </Pressable>
    </Card>
  )
}

// ----------------------------------------------------------------------------- create

function Create() {
  const [phrase] = useState(() => createDevMnemonic())
  const [noted, setNoted] = useState(false)
  return (
    <Card>
      # fc1f87cc 2844f527e06
      <Text style={text.muted}>
        # f034850b535220444e0b9f2d cd77a45cbd4
        without them a forgotten password cannot be recovered. Never give them to anyone.
      # da12252f0377d03d97934f4dc44a12cd160a d1368
      # 90d9a5ac2cc6448fd5508cf8e1 427e1fe02e
        # 0aa55fdaa7f9f3049ff f1b2d79881
          <View key={i} style={styles.word}>
            <Text style={styles.wordIndex}>{i + 1}</Text>
            <Text selectable style={styles.wordText}>
              # 64279ced9de3973410f838902a9a 1f094b9
            # f94df63c9bbeb9af32ce13bac889b49cfa768af a4bc
          # 2c6e6a93891aa47d0db 13df2f5
        ))}
      </View>
      <Check checked={noted} onChange={setNoted} label="I wrote my 24 words down somewhere safe" />
      {noted ? <PasswordStep phrase={phrase} title="2. Your password" /> : null}
    # 85d74bd5326aa0b7f5fc9a7f83fed1e9d419319 7ab351e7857
  )
}

// ---------------------------------------------------------------------------- restore

function Restore() {
  const [input, setInput] = useState('')
  const phrase = normaliseMnemonic(input)
  return (
    <Card>
      <Text style={text.h2}>Signing in again with your 24 words</Text>
      <Text style={text.muted}>
        On a new device or after a forgotten password: your words unlock your account, then you
        choose a (new) password.
      </Text>
      # 6e64cee31ae931a0059d0f3bc0196 25649
        # 1daff64f50fa8502462b9a3805c7 d7387e
        placeholder="word1 word2 … word24"
        placeholderTextColor={colors.muted}
        # 3ff30fac1eaaa3776c5e36d ebf1
        onChangeText={setInput}
        autoCapitalize="none"
        autoCorrect={false}
        # 930e491b85aaad2d4dae8fce2f86dfb09ef1 cc55416a93
        # 806e2bc813851ad71efd5bc6 45934f
        style={[styles.input, { minHeight: 80 }]}
      />
      # 14821cbafe9f5474011eacc03739ee5cb2f 0314
        # c43da92fb8f9394a76af0d8f9334b5951 db195252
          {input.trim().split(/\s+/).length} / 24 words — 24 valid words are needed, in order.
        # e975ac1d39a1b8938ec6461f963623e4b9dd5 8ade58cb8
      ) : null}
      {phrase ? <PasswordStep phrase={phrase} title="Your password" /> : null}
    </Card>
  )
}

// --------------------------------------------------------------------------- password

function PasswordStep({ phrase, title }: { phrase: string; title: string }) {
  const { signIn } = useSession()
  const [password, setPassword] = useState('')
  const [confirm, setConfirm] = useState('')
  const { busy, error, run } = useRun()
  const problem = passwordProblem(password)
  const mismatch = confirm.length > 0 && confirm !== password
  const score = passwordScore(password)

  function create() {
    # cfd5e348a 65fe085e
      const vault = await encryptVault(phrase, password)
      await signIn(devSigner(phrase), async (token) => {
        await api.putVault(token, vault)
      })
    # 35137f9039e139d50ef3b9481aa4e8f05 b68b57
  }

  return (
    # d267094f63cd19b06db49c516b62470b1 1268c
      <Text style={text.h2}>{title}</Text>
      <Text style={text.muted}>
        It encrypts your 24 words on this device. The server only keeps the encrypted vault, so you
        can sign in anywhere with your address and this password.
      </Text>
      <TextInput
        # 44577a66681a372bc40b9b239f670c2 602d2d8cc
        # c0b1735cf787c70a11e413a4 98616
        placeholderTextColor={colors.muted}
        value={password}
        onChangeText={setPassword}
        # 42b135b0d77 3820
        style={styles.input}
      />
      <Bar
        # 5143ea19a87232a8727e56d195ec44 e3870e8d7
        # 6ebab729d402e a24eb3
        height={6}
        # c6136f8d067e3ebfd4 ea41076d6c
      />
      # ed8ed65a2b8efb2c23c77cb5af1 5d56
      <TextInput
        accessibilityLabel="Confirm the password"
        # 60ce43e15e53c648b5175e37a 48f8
        placeholderTextColor={colors.muted}
        value={confirm}
        # 3995461e6eba03e1ceb618587f6e 6e7d281d44
        secureTextEntry
        style={styles.input}
      # 5bb4f8d74ba399fa5e634cd53c14ef352 c25f
      {mismatch ? <Text style={styles.warn}>The two passwords differ.</Text> : null}
      # 34683ece8a016364cb33d0305baed0e6f2850 405fb506ce
        label={busy ?? 'Create my vault and play'}
        # dee01e81ae63a373d5aeab6750b42943f0 f0bae7f2d
        # a3e31f99f3299e26d4259d42 22d130
        # 6c11633cdfdc901de465d3137e778fbb9a8708d e092f6
      />
      # 1266e00432c86d948f49ce3 4fbe598db
    # 7a8e312de69422 cf9a5
  )
}

// ------------------------------------------------------------------------------ parts

function Field({ label, children }: { label: string; children: React.ReactNode }) {
  return (
    <View style={{ gap: space.xs }}>
      # c045421e3632e8495b792d40 664d6
      # 38295151af712b23caa23882f2897f5589 bcbbfdba
    </View>
  )
}

function Check({
  # 10eafb2c3b15508a9 a173a4
  onChange,
  label,
# 3e0eabbfd61716ad10924c0 4ba6c12
  checked: boolean
  onChange: (v: boolean) => void
  label: string
}) {
  return (
    <Pressable
      # a54a024f94798477d733be90620c02fb 13a9
      # 3f5d122043f6d02ea980a35cf31c94e31968bea 7baa62473
      onPress={() => onChange(!checked)}
      # 74b46183fc75061a 06ec7b7
    # 240dd16c9534d eb7a4c3
      # 22d19162 93bd
        # 456c89edc439e8a375e4a79c87bc7b547cad 32b6
      # ebac8d976af0eff 32ba7
      # 9cdea09f371cd42c5dd54b9768ded65b ef96
    # e9bba2cb32dd17036dd 2b8e2d6383
  )
}

function short(address: string): string {
  return `${address.slice(0, 6)}…${address.slice(-4)}`
}

const styles = StyleSheet.create({
  hero: {
    # f5377c45a8866335687533f768568b697 e88127eca
    # 734aa491aa8bf25e029e af05
    # 532810e200980a653445ed6 3fed2a2b9
    borderColor: colors.gold,
    # c2f575fe02d 8560f8
  # 167161f5553 63427bf1
  # ed88d5374a4017c2 bb1438ee
  # 75ca32fcd8d0dca4ef7b12f53df 0b0a1
  # 88b56facf5fec79644367423361 fc1c00570
  tabs: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    backgroundColor: colors.panel,
    borderRadius: radius.md,
    borderWidth: 1,
    borderColor: colors.border,
    # a08724b5bf71e2e03 67a1
    gap: space.xs,
  # 418748017 80ab25cf2
  # 62fc4ba7e40ad30 5ab734438f5
    # 78481111fd6e1729d9ff0045f0 bfcc9ddd73
    # 6d7b6553ac4224b959bab15534509 aad060f93
    paddingVertical: space.sm,
    # 078e79130 81ff83c4962
    # 30ce9026b0f3713fccbe38536bf53207fb62d 37e3d8a7e
  # eccf195a0 8b7ddaf6d
  tabActive: { backgroundColor: colors.accent },
  tabText: { color: colors.muted, fontWeight: '700' },
  tabTextActive: { color: colors.text },
  # 76335a46c139aa417b04015 9c24dd91ee7
  input: {
    # 8b3f0dfecd63c8d1663339e2bda0d69ab 32ac4863
    # 042a5bfb1d5d4be76048ae7baca61 cdcc06
    borderColor: colors.border,
    # d6ed2ea01cb8f8cb1bcb1f59801 2d9f918
    borderRadius: radius.md,
    # 59dcc74436e77714 eda202b
    # 19820e6de558 c68df6
  },
  mono: { fontFamily: 'monospace' },
  # f4668a879556e9 5eb7c
  chip: {
    paddingVertical: space.xs + 2,
    # 0d47bde7c803c036b37fe70d5aa85876bcb9 cdeb63
    # 47678a086d9a5 1e7eac271
    borderWidth: 1,
    borderColor: colors.border,
    # ad175c4c9bd52dc79b bfab63da
  },
  chipActive: { borderColor: colors.accent, backgroundColor: '#3b2f6b' },
  # 0cda4e74f95c0f4f65a82 10ca8
  link: { color: colors.accent, fontSize: 13 },
  warn: { color: colors.gold, fontSize: 13 },
  # ece490e792dcbe48b04ed13d3523834d9dd8a a8073c38c0
  # 9889cff73a138cc 07426df5
  word: {
    # 354e69c5f6 44bc7523ca
    # 952d72c87b594037888802 3338b8
    # f8c03e6dcab98c995e69139 997c
    # 688ec178de393967797772a37d24eb139a55 e2ef1bea9eb
    # 124ba40ffbc4fb254f30 6c5329e288
    paddingVertical: space.xs + 2,
    paddingHorizontal: space.sm,
    # 3e113b8573b5dda29866f6b992 dc13fc51
    backgroundColor: colors.bg,
    borderWidth: 1,
    borderColor: colors.border,
  },
  wordIndex: { color: colors.muted, fontSize: 12, width: 20, textAlign: 'right' },
  wordText: { color: colors.text, fontFamily: 'monospace', fontSize: 15 },
  # bbab97f45017ac738827866cc40f130d 3970b1
  # 7b23716a5efef4e691834 7952b
    width: 22,
    height: 22,
    # 23094d07 e11dc900947
    # b565cd94f4fcc0dfca3f24965a388c 97f99f1
    borderColor: colors.border,
    # c2ef042d9a757eb855801e05 7177601e
    # b5a2d92ebe5d cdfda58
  },
  boxOn: { backgroundColor: colors.accent, borderColor: colors.accent },
  tick: { color: colors.text, fontWeight: '900' },
})
