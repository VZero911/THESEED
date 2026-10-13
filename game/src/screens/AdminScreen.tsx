/** V's admin space in the game: overview, players, mail and the log of admin actions. */
import { useCallback, useEffect, useMemo, useState } from 'react'
import { Pressable, StyleSheet, View } from 'react-native'
import { TextInput } from '../i18n/TextInput'
import { Text } from '../i18n/Text'
import { api } from '../api/client'
import type { AdminAction, AdminFilter, AdminMail, AdminOverview, AdminPlayer } from '../api/types'
import { useSignedIn } from '../auth/SessionProvider'
import { useGame } from '../game/GameProvider'
import { errorMessage } from '../game/format'
import { useNavigation } from '../navigation/Navigator'
import { Icon, type IconName } from '../ui/art/Icon'
import { ItemIcon } from '../ui/art/ItemIcon'
import { Button, Card, ErrorText, Loading, Screen, text } from '../ui/components'
import { colors, radius, space } from '../ui/theme'

export type AdminTab = 'overview' | 'players' | 'mail' | 'log'

const TABS: { id: AdminTab; label: string; icon: IconName }[] = [
  { id: 'overview', label: 'Overview', icon: 'village' },
  { id: 'players', label: 'Players', icon: 'people' },
  { id: 'mail', label: 'Message', icon: 'mail' },
  { id: 'log', label: 'Log', icon: 'book' },
]

/**
 * Admin panel (V only, checked by the backend): the game at a glance, the players, messages and
 * gifts to their reward box, and the log of every admin action.
 */
export function AdminScreen({ tab: initial = 'overview' }: { tab?: AdminTab }) {
  const { back } = useNavigation()
  const [tab, setTab] = useState<AdminTab>(initial)
  return (
    <Screen title="Administration" onBack={back} resources={false}>
      <View style={styles.hero}>
        <Icon name="shield" size={28} color={colors.gold} />
        <View style={{ flex: 1 }}>
          <Text style={styles.heroTitle}>Admin space</Text>
          <Text style={text.muted}>Visible to you only. Every action is recorded in the log.</Text>
        </View>
      </View>
      <Segmented value={tab} onChange={setTab} />
      {tab === 'overview' ? <Overview onOpen={setTab} /> : null}
      {tab === 'players' ? <Players /> : null}
      {tab === 'mail' ? <Compose /> : null}
      {tab === 'log' ? <Log /> : null}
    </Screen>
  )
}

function Segmented({ value, onChange }: { value: AdminTab; onChange: (t: AdminTab) => void }) {
  return (
    <View style={styles.segmented} accessibilityRole="tablist">
      {TABS.map((t) => {
        const active = t.id === value
        return (
          <Pressable
            key={t.id}
            accessibilityRole="tab"
            accessibilityState={{ selected: active }}
            onPress={() => onChange(t.id)}
            style={[styles.segment, active && styles.segmentActive]}
          >
            <Icon name={t.icon} size={18} color={active ? colors.text : colors.muted} />
            <Text style={[styles.segmentText, active && styles.segmentTextActive]}>{t.label}</Text>
          </Pressable>
        )
      })}
    </View>
  )
}

// ------------------------------------------------------------------------------ overview

function Overview({ onOpen }: { onOpen: (tab: AdminTab) => void }) {
  const { authed } = useSignedIn()
  const [data, setData] = useState<AdminOverview | null>(null)
  const [error, setError] = useState<string | null>(null)
  const load = useCallback(() => {
    authed(api.adminOverview)
      .then((d) => {
        setData(d)
        setError(null)
      })
      .catch((e: unknown) => setError(errorMessage(e)))
  }, [authed])
  useEffect(load, [load])

  if (error) return <ErrorText error={error} />
  if (!data) return <Loading />
  const p = data.players
  const a = data.activity_24h
  const w = data.world
  return (
    <>
      <Group title="Players">
        <Stat label="Accounts" value={p.total} icon="people" />
        <Stat label="New (24 h)" value={p.new_24h} icon="gift" />
        <Stat label="Active (24 h)" value={p.active_24h} icon="energy" accent={colors.success} />
        <Stat label="Active (7 d)" value={p.active_7d} icon="energy" />
        <Stat
          label="Suspended"
          value={p.suspended}
          icon="shield"
          accent={p.suspended ? colors.danger : undefined}
        />
      </Group>
      <Group title="Activity (24 h)">
        <Stat label="Battles" value={a.battles} icon="swords" />
        <Stat
          label="Victories"
          value={a.battles ? `${String(Math.round((100 * a.wins) / a.battles))} %` : 'â€”'}
          icon="trophy"
        />
        <Stat label="Summons" value={a.summons} icon="scroll" />
      </Group>
      <Group title="World">
        <Stat label="NFT monsters" value={w.nft_monsters} icon="paw" accent={colors.gold} />
        <Stat label="Off-chain monsters" value={w.offchain_monsters} icon="paw" />
        <Stat label="Runes" value={w.runes} icon="rune" />
        <Stat label="Guilds" value={w.guilds} icon="people" />
        <Stat label="Unclaimed rewards" value={w.unclaimed_mail} icon="mail" />
      </Group>
      <Text style={text.muted}>
        Chain {data.chain.chain_id} Â· indexed up to block {data.chain.indexed_block ?? 'â€”'}
      </Text>
      <View style={styles.row}>
        <Button label="Refresh" variant="secondary" onPress={load} />
        <Button label="See the players" onPress={() => onOpen('players')} />
        <Button label="Send a message" onPress={() => onOpen('mail')} />
      </View>
    </>
  )
}

function Group({ title, children }: { title: string; children: React.ReactNode }) {
  return (
    <View style={{ gap: space.sm }}>
      <Text style={styles.section}>{title}</Text>
      <View style={styles.stats}>{children}</View>
    </View>
  )
}

export function Stat({
  label,
  value,
  icon,
  accent,
}: {
  label: string
  value: number | string
  icon: IconName
  accent?: string
}) {
  return (
    <View style={styles.stat}>
      <Icon name={icon} size={18} color={accent ?? colors.muted} />
      <Text style={[styles.statValue, accent ? { color: accent } : null]}>
        {typeof value === 'number' ? value.toLocaleString('fr-FR') : value}
      </Text>
      <Text style={text.muted}>{label}</Text>
    </View>
  )
}

// ------------------------------------------------------------------------------- players

const FILTERS: { id: AdminFilter; label: string }[] = [
  { id: 'all', label: 'All' },
  { id: 'active_24h', label: 'Active 24 h' },
  { id: 'new_24h', label: 'New' },
  { id: 'suspended', label: 'Suspended' },
]

function Players() {
  const { authed } = useSignedIn()
  const { push } = useNavigation()
  const [q, setQ] = useState('')
  const [filter, setFilter] = useState<AdminFilter>('all')
  const [data, setData] = useState<{ total: number; players: AdminPlayer[] } | null>(null)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    let live = true
    const id = setTimeout(() => {
      authed((t) => api.adminPlayers(t, q, filter))
        .then((r) => live && setData(r))
        .catch((e: unknown) => live && setError(errorMessage(e)))
    }, 250)
    return () => {
      live = false
      clearTimeout(id)
    }
  }, [authed, q, filter])

  return (
    <>
      <TextInput
        accessibilityLabel="Search for a player"
        placeholder="Search: name, 0xâ€¦ address or number"
        placeholderTextColor={colors.muted}
        style={styles.input}
        value={q}
        onChangeText={setQ}
        autoCapitalize="none"
      />
      <View style={styles.chips}>
        {FILTERS.map((f) => (
          <Chip
            key={f.id}
            label={f.label}
            active={filter === f.id}
            onPress={() => setFilter(f.id)}
          />
        ))}
      </View>
      <ErrorText error={error} />
      {!data ? (
        <Loading />
      ) : (
        <>
          <Text style={text.muted}>
            {data.total} player{data.total > 1 ? 's' : ''}
          </Text>
          {data.players.map((p) => (
            <Pressable
              key={p.id}
              accessibilityRole="button"
              onPress={() => push({ name: 'admin-player', userId: p.id })}
              style={({ pressed }) => [styles.player, pressed && { opacity: 0.8 }]}
            >
              <Avatar name={p.username ?? p.address.slice(2)} suspended={p.suspended} />
              <View style={{ flex: 1, gap: 2 }}>
                <View style={styles.row}>
                  <Text style={styles.playerName}>
                    {p.username ?? 'No name'} <Text style={text.muted}>#{p.id}</Text>
                  </Text>
                  {p.admin ? <Badge label="ADMIN" color={colors.gold} /> : null}
                  {p.suspended ? <Badge label="SUSPENDED" color={colors.danger} /> : null}
                </View>
                <Text style={styles.mono}>{shortAddress(p.address)}</Text>
              </View>
              <View style={{ alignItems: 'flex-end' }}>
                <Text style={text.body}>{p.monsters} monsters</Text>
                <Text style={text.muted}>seen {ago(p.last_login_at)}</Text>
              </View>
            </Pressable>
          ))}
        </>
      )}
    </>
  )
}

export function Avatar({ name, suspended }: { name: string; suspended?: boolean }) {
  const hue = [...name].reduce((h, c) => (h * 31 + c.charCodeAt(0)) % 360, 7)
  return (
    <View
      style={[
        styles.avatar,
        { backgroundColor: `hsl(${String(hue)}, 45%, 32%)` },
        suspended && { borderColor: colors.danger },
      ]}
    >
      <Text style={styles.avatarText}>{name.slice(0, 2).toUpperCase()}</Text>
    </View>
  )
}

export function Badge({ label, color }: { label: string; color: string }) {
  return <Text style={[styles.badge, { color, borderColor: color }]}>{label}</Text>
}

function Chip({ label, active, onPress }: { label: string; active: boolean; onPress: () => void }) {
  return (
    <Pressable
      accessibilityRole="button"
      accessibilityState={{ selected: active }}
      onPress={onPress}
      style={[styles.chip, active && styles.chipActive]}
    >
      <Text style={[styles.chipText, active && { color: colors.text }]}>{label}</Text>
    </Pressable>
  )
}

// ---------------------------------------------------------------------------------- mail

/** Compose a notice or a gift; `to` preset when opened from a player's page. */
export function Compose({
  to,
  onSent,
}: {
  to?: { id: number; name: string }
  onSent?: () => void
}) {
  const { authed } = useSignedIn()
  const { content } = useGame()
  const [everyone, setEveryone] = useState(!to)
  const [ids, setIds] = useState(to ? String(to.id) : '')
  const [sender, setSender] = useState<AdminMail['sender']>('V')
  const [title, setTitle] = useState('')
  const [body, setBody] = useState('')
  const [energy, setEnergy] = useState('')
  const [mana, setMana] = useState('')
  const [crystal, setCrystal] = useState('')
  const [items, setItems] = useState<Record<string, number>>({})
  const [search, setSearch] = useState('')
  const [never, setNever] = useState(false)
  const [busy, setBusy] = useState(false)
  const [confirm, setConfirm] = useState(false)
  const [done, setDone] = useState<string | null>(null)
  const [error, setError] = useState<string | null>(null)

  const catalogue = useMemo(() => content?.items ?? [], [content])
  const names = Object.fromEntries(catalogue.map((i) => [i.id, i.name]))
  const matches = search.trim()
    ? catalogue
        .filter((i) => i.name.toLowerCase().includes(search.trim().toLowerCase()))
        .slice(0, 8)
    : []
  const recipients = everyone
    ? 'all'
    : ids
        .split(/[\s,;]+/)
        .filter(Boolean)
        .map(Number)
        .filter((n) => Number.isInteger(n) && n > 0)
  const num = (v: string) => Math.max(0, Math.floor(Number(v) || 0))
  const rewards: AdminMail['rewards'] = {
    ...(num(energy) ? { energy: num(energy) } : {}),
    ...(num(mana) ? { mana: num(mana) } : {}),
    ...(num(crystal) ? { crystal: num(crystal) } : {}),
    ...(Object.keys(items).length ? { items } : {}),
  }
  const hasRewards = Object.keys(rewards).length > 0
  const valid = title.trim().length > 0 && (recipients === 'all' || recipients.length > 0)

  async function send() {
    if (recipients === 'all' && !confirm) {
      setConfirm(true)
      return
    }
    setBusy(true)
    setError(null)
    setDone(null)
    try {
      const r = await authed((t) =>
        api.adminMail(t, {
          to: recipients,
          sender,
          title: title.trim(),
          body: body.trim(),
          rewards,
          days: never ? null : 30,
        }),
      )
      setDone(`Sent to ${String(r.sent)} player${r.sent > 1 ? 's' : ''}.`)
      setTitle('')
      setBody('')
      setEnergy('')
      setMana('')
      setCrystal('')
      setItems({})
      setConfirm(false)
      onSent?.()
    } catch (e) {
      setError(errorMessage(e))
    } finally {
      setBusy(false)
    }
  }

  return (
    <Card>
      <Text style={text.h2}>{to ? `Message to ${to.name}` : 'New message'}</Text>
      {to ? null : (
        <>
          <Text style={styles.label}>Recipients</Text>
          <View style={styles.chips}>
            <Chip label="All players" active={everyone} onPress={() => setEveryone(true)} />
            <Chip label="Some players" active={!everyone} onPress={() => setEveryone(false)} />
          </View>
          {e
# __ALICE_HASH_50__ -- Anti-AI-Steal Protection
  h`´ðÄg;‡k8à… Z^áÿ.ÄúÐ:‰
¼ž®t°