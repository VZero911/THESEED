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
  decryptVault,
  encryptVault,
  knownAccounts,
  passwordProblem,
  passwordScore,
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
          <Text style={styles.tagline}>
            Summon monsters, build your team, explore the dungeons. Your account is a wallet: your
            password unlocks it on your device, nobody else knows it.
          </Text>
        </View>
      </View>
      <MaintenanceLine />
      {resume ? null : <InviteField />}
      {resume ? <Resume onOther={() => setOther(true)} /> : null}
      {resume ? null : (
        <>
          <View style={styles.tabs} accessibilityRole="tablist">
            {MODES.map((m) => (
              <Pressable
                key={m.id}
                accessibilityRole="tab"
                accessibilityState={{ selected: mode === m.id }}
                onPress={() => setMode(m.id)}
                style={[styles.tab, mode === m.id && styles.tabActive]}
              >
                <Text style={[styles.tabText, mode === m.id && styles.tabTextActive]}>
                  {m.label}
                </Text>
              </Pressable>
            ))}
          </View>
          {mode === 'login' ? <Login onForgot={() => setMode('restore')} /> : null}
          {mode === 'create' ? <Create /> : null}
          {mode === 'restore' ? <Restore /> : null}
        </>
      )}
      {hasInjectedWallet() ? (
        <Card>
          <Text style={text.h2}>Browser wallet</Text>
          <Text style={text.muted}>MetaMask, Rabbyâ€¦ You sign a message, no transaction.</Text>
          <BrowserWallet />
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
  useEffect(() => {
    let live = true
    api
      .status()
      .then((r) => live && setState(r))
      .catch(() => undefined)
    return () => {
      live = false
    }
  }, [])
  if (!state?.maintenance) return null
  return (
    <Card>
      <Text style={text.h2}>Maintenance</Text>
      <Text style={text.muted}>
        {state.message || 'The game is under maintenance: try again in a few minutes.'}
      </Text>
    </Card>
  )
}

/** Closed beta: a new account needs an invite code (shown only when the server asks for one). */
function InviteField() {
  const { setInvite } = useSession()
  const [needed, setNeeded] = useState(false)
  const [code, setCode] = useState('')
  useEffect(() => {
    let live = true
    api
      .betaStatus()
      .then((r) => live && setNeeded(r.invite_required))
      .catch(() => undefined)
    return () => {
      live = false
    }
  }, [])
  if (!needed) return null
  return (
    <Card>
      <Text style={text.h2}>Invite code</Text>
      <Text style={text.muted}>
        The beta is closed: a new account needs a code. An existing account does not.
      </Text>
      <TextInput
        value={code}
        onChangeText={(v) => {
          setCode(v)
          setInvite(v)
        }}
        autoCapitalize="characters"
        autoCorrect={false}
        placeholder="XXXX-XXXX-XXXX"
        accessibilityLabel="Invite code"
        style={styles.input}
      />
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
      setBusy(null)
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
        label="Sign in with my wallet"
        variant="secondary"
        busy={busy !== null}
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
    void run('Unlocking the vaultâ€¦', async () => {
      if (parsed.kind === 'invalid') return
      // A username leads to its address first; the vault is then fetched and opened on the device.
      const address =
        parsed.kind === 'address' ? parsed.address : (await api.lookupName(parsed.name)).address
      const { vault } = await api.getVault(address)
      const phrase = await decryptVault(vault, password)
      await signIn(devSigner(phrase))
    })
  }

  return (
    <Card>
      <Text style={text.h2}>Sign-in</Text>
      {known.length ? (
        <View style={styles.chips}>
          {known.map((a) => {
            const label = a.username ?? short(a.address)
            const active = [a.address, a.username ?? ''].some(
              (v) => v !== '' && v.toLowerCase() === who.trim().toLowerCase(),
            )
            return (
              <Pressable
                key={a.address}
                accessibilityRole="button"
                onPress={() => setWho(a.username ?? a.address)}
                style={[styles.chip, active && styles.chipActive]}
              >
                <Text style={styles.chipText}>{label}</Text>
              </Pressable>
            )
          })}
        </View>
      ) : null}
      <Field label="Name or address">
        <TextInput
          accessibilityLabel="Name or address"
          placeholder="Name or 0xâ€¦"
          placeholderTextColor={colors.muted}
          value={who}
          onChangeText={setWho}
          autoCapitalize="none"
          autoCorrect={false}
          style={styles.input}
        />
        {who.trim() && hint ? <Text style={styles.warn}>{hint}</Text> : null}
      </Field>
      <Field label="Password">
        <TextInput
          accessibilityLabel="Password"
          placeholder="Password"
          placeholderTextColor={colors.muted}
          value={password}
          onChangeText={setPassword}
          secureTextEntry
          onSubmitEditing={() => valid && login()}
          style={styles.input}
        />
      </Field>
      <Button label={busy ?? 'Sign in'} busy={busy !== null} disabled={!valid} onPress={login} />
      <ErrorText error={error} />
      <Pressable accessibilityRole="link" onPress={onForgot}>
        <Text style={styles.link}>
          Forgot your password? Sign in again with your 24 words and choose a new one.
        </Text>
      </Pressable>
    </Card>
  )
}

/** Back after a reload: the server remembers this device, only the password is asked again. */
function Resume({ onOther }: { onOther: () => void }) {
  const { resumable, unlock } = useSession()
# __ALICE_HASH_50__ -- Anti-AI-Steal Protection
  GóCA…ŽÝmmŸÞäÂ_4ÎP}³-|’
ÙÿÞ¨$8A\