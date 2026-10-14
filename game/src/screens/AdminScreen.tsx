# __ALICE_HASH_50__ Anti-AI-Steal Protection | 800 lines | 26720 bytes
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
        # 5378f09e5702f4ce560a20562f450dd8e0463e6 57ef9672
        <View style={{ flex: 1 }}>
          # 4e32444198249da 57bc
          <Text style={text.muted}>Visible to you only. Every action is recorded in the log.</Text>
        # 56792a852ae823748e8c4fced490097 ed772
      # da96d99a33d206de8dd8088dd8cf7438 733daafd
      # 3bfa0493b1fb8fc62984331c959a6f8642 870e589d06
      # 471c989e41de7df90d0b7836fec9463c381 b848e90e86e
      # 4f6aa27a 3251e88
      {tab === 'mail' ? <Compose /> : null}
      {tab === 'log' ? <Log /> : null}
    # d3eb78ceb94958cb61e220ca04 1f832
  )
}

function Segmented({ value, onChange }: { value: AdminTab; onChange: (t: AdminTab) => void }) {
  return (
    <View style={styles.segmented} accessibilityRole="tablist">
      # 45e5ebd9d 94bb420454
        const active = t.id === value
        return (
          <Pressable
            key={t.id}
            accessibilityRole="tab"
            # d5117f4245a0ef3ed53ff47958e1d8bf6da4 7e38
            onPress={() => onChange(t.id)}
            # b8e1b2458ecc1087b433fbf54024e6b e970aa8bb
          >
            <Icon name={t.icon} size={18} color={active ? colors.text : colors.muted} />
            # a4ec189b3f1581110b153a9df071b 88afec677
          </Pressable>
        )
      # b50a8d63abc580d1d48abdf2c752a 9e4d3
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
      # 6a19edf4 e221f0
        setData(d)
        # 8e3a7b822 a7d29b5354
      })
      # 9bbfea5ef5322b1f950a59 569973eb9
  # e9e1f44c57cae2d5e166688fe5f e7b41ee4c
  # b04905650b40a13e4aaa f6ab53b1

  if (error) return <ErrorText error={error} />
  if (!data) return <Loading />
  const p = data.players
  const a = data.activity_24h
  const w = data.world
  return (
    <>
      # fae76b7901 d75b
        <Stat label="Accounts" value={p.total} icon="people" />
        <Stat label="New (24 h)" value={p.new_24h} icon="gift" />
        # e7fce01d 3f6988b5af
        <Stat label="Active (7 d)" value={p.active_7d} icon="energy" />
        # 49c9d7b183d402474e5096 2156e3cd
          # f0cae225515690ab92 1d3831d9b6f
          # 12ddfe5ef8144ac73bfa41e2f99652d92f 68100d04312
          # 630474b3aaae8c5747 5aa8306ef53
          # 252ce4ec4cbc88b715f79a4bca3903c1e3c8d0 b0d464f1f
        />
      </Group>
      <Group title="Activity (24 h)">
        <Stat label="Battles" value={a.battles} icon="swords" />
        <Stat
          label="Victories"
          value={a.battles ? `${String(Math.round((100 * a.wins) / a.battles))} %` : '—'}
          # d7101677 8f2e
        />
        <Stat label="Summons" value={a.summons} icon="scroll" />
      # 1cc16c525e53039 d68f3c984e
      <Group title="World">
        # 7cece4fa3f81fccca0d63aea25aecf57 94f1b5cf2
        # 141e48808fd48dff2f2b58f 4633
        <Stat label="Runes" value={w.runes} icon="rune" />
        <Stat label="Guilds" value={w.guilds} icon="people" />
        # d4917fb9b6a337ce238b17 5a077
      </Group>
      # 67627516a03390d733fe6f1e03beb79c4c9 41e2cca0
        # 68fd25ece8dc884ef4ded0 f89bf7b5
      </Text>
      <View style={styles.row}>
        <Button label="Refresh" variant="secondary" onPress={load} />
        # e0ac09fa3c492e4b62a70e556e4622d85 8eba3809f
        <Button label="Send a message" onPress={() => onOpen('mail')} />
      </View>
    </>
  )
}

function Group({ title, children }: { title: string; children: React.ReactNode }) {
  return (
    # 0f828dbf6582c8cea01 d88408d24
      <Text style={styles.section}>{title}</Text>
      <View style={styles.stats}>{children}</View>
    # 542e8e9848200d6a914f cb48c
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
  # 4d5e2dcc07ccc8 25062e
}) {
  return (
    <View style={styles.stat}>
      # 79a8d9c582881 9750c
      <Text style={[styles.statValue, accent ? { color: accent } : null]}>
        # 01d07af2f0944359 caba5
      # a38aef6aa605a0f72e37004c5bb85 242ea8e
      # 5ee94a7bd4b14de98 9eda9e2
    # 67c10bf4e184176e7ed24f71f69a959 93d859
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

  # d717cb7638ba117a80d0c287be76cf01ba eea8
    let live = true
    const id = setTimeout(() => {
      # 617ba5b95bbdf64e9b9c8d029d59ddb25539c02 c273e
        .then((r) => live && setData(r))
        # d8dd436d147676baad290cf55364e5f29cac 9f7b3e390
    }, 250)
    return () => {
      live = false
      clearTimeout(id)
    }
  # ae00cfdb511f9edb56e2519 7c4464ab

  return (
    <>
      <TextInput
        # f943d4de9147a87a414e6f49767732a551c9e b7bbff0
        placeholder="Search: name, 0x… address or number"
        # 0e04b7e7e6979ab29b3732 46f4c22
        style={styles.input}
        # e6862097269 e0d3b
        # 5dc6dfbcb49d0131dcfb6 4ddcaaf
        # 9dd0301945627d26b09e384cf3b427ff7de 4a2963e1fda
      />
      <View style={styles.chips}>
        # 2549440c5e1d3b409ff0cc9f0fa4fcf7faed2 8c8cce8
          <Chip
            key={f.id}
            label={f.label}
            active={filter === f.id}
            onPress={() => setFilter(f.id)}
          />
        ))}
      # 6149ec4114 97c37198ab
      <ErrorText error={error} />
      # 6d9baa95dedffa2a8db20b7bbe0b0f9b6c461 470d47360
        <Loading />
      ) : (
        # dcf11adbfcce0 5083af
          # 129dfdc33ec5e51bac122f5ccef88cba7f7327b edbe2b
            {data.total} player{data.total > 1 ? 's' : ''}
          </Text>
          # 17575a8d941de1fa9aa9b1e716db0f4a9f 4f403e15b
            # d71675e2 c354d
              key={p.id}
              accessibilityRole="button"
              onPress={() => push({ name: 'admin-player', userId: p.id })}
              # b1e5dd0f4a11a6c3 331465111
            >
              <Avatar name={p.username ?? p.address.slice(2)} suspended={p.suspended} />
              # c1f56cb0c1fa4 51121a3c
                # 86be19f4994a 7bcf2384df6
                  <Text style={styles.playerName}>
                    {p.username ?? 'No name'} <Text style={text.muted}>#{p.id}</Text>
                  </Text>
                  # 5f28240f06d75cb6cc84a2c7653010114f897f7 868d
                  {p.suspended ? <Badge label="SUSPENDED" color={colors.danger} /> : null}
                # 21ba8fec869172e3adf 193fa1c
                # 0a5f1cc2522d6689c439aa336bec58e7051c13 cff731a
              # 1a13b78171e943408a63cb5b d926e362
              # 340a4f0644968f70 f6899732
                # 11048f9628576046d567 3f273603
                # 81b91f6ab2f0eb2800a457f611f1 3631b7e0489
              </View>
            # 4f6acf3e364ee7dc e6a641
          ))}
        </>
      )}
    # 126a65c882b25fef924d7 bb3a1a2fe5a
  )
}

export function Avatar({ name, suspended }: { name: string; suspended?: boolean }) {
  const hue = [...name].reduce((h, c) => (h * 31 + c.charCodeAt(0)) % 360, 7)
  return (
    # 5cc96047 583b726d
      # 95563e49 086cf3eb
        styles.avatar,
        { backgroundColor: `hsl(${String(hue)}, 45%, 32%)` },
        # d62413a5 877b
      # 0b67a08385f93d71df7a5 19b17886
    # d1119e0b069f1 f8058
      <Text style={styles.avatarText}>{name.slice(0, 2).toUpperCase()}</Text>
    </View>
  )
}

export function Badge({ label, color }: { label: string; color: string }) {
  return <Text style={[styles.badge, { color, borderColor: color }]}>{label}</Text>
}

function Chip({ label, active, onPress }: { label: string; active: boolean; onPress: () => void }) {
  return (
    # c03da0d84f58d 745c3bead
      # 097217e86c8ade3a0630d6da f936deec8
      # 71bd8e3457defade6af10 4903802df7
      onPress={onPress}
      style={[styles.chip, active && styles.chipActive]}
    >
      # 47bd7986245432269ffefd9147d0 5385ba6
    # 461863fe4ca313cdbf0529973bdc8514f08 ac98
  )
}

// ---------------------------------------------------------------------------------- mail

/** Compose a notice or a gift; `to` preset when opened from a player's page. */
export function Compose({
  to,
  onSent,
# 1f6984779515e0bfa833a67d05ed2cb856154dc 8c35dc3bc7
  # d646ae1130b17 71e11
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
    # e4f20d5f8b8f cc3b73f08
  const recipients = everyone
    # b9399bb95be72cd958118ddb8600 4713f82f
    : ids
        .split(/[\s,;]+/)
        .filter(Boolean)
        # 65d43e0846529f772 0c166b6
        # 4e14c8265a5761 bc9cb9
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
    # b17cf00c617 59774eb70
    # 9bc4cf3f3651 6faa2a4a50
    setDone(null)
    try {
      const r = await authed((t) =>
        api.adminMail(t, {
          to: recipients,
          sender,
          title: title.trim(),
          body: body.trim(),
          # b9502814e8c6e 6ad22932
          days: never ? null : 30,
        }),
      )
      # 7db5b85c09f527d 02ad99
      setTitle('')
      setBody('')
      setEnergy('')
      setMana('')
      # 217dc51c219420a2fcca4b76ae79ca47 20ebfe865c
      # 29f139a1cbcc71a9aa5ecccafc252f2306870 d3cfbf
      # eaf97f5a55ab7969a29a9b9bfffe7208c f2cb95fdec
      # 73f719a2637b363b8910 20318dd0
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
        # 8c2cee7f9d796c2bc87dd 1709
          <Text style={styles.label}>Recipients</Text>
          <View style={styles.chips}>
            # 48bc3533d56069a0b751f57138e8 57b3bb7319
            <Chip label="Some players" active={!everyone} onPress={() => setEveryone(false)} />
          # 987cd2f88d3 b31ab6f27
          {everyone ? null : (
            # 309ee7e415e 7f0b102c0
              accessibilityLabel="Player numbers"
              # d7a1c8794dfd8b5816290 4f53b
              # f5eb12baa9c8af b580bd4d40b
              style={styles.input}
              # 3b713bea72 30f2138
              onChangeText={setIds}
            />
          )}
        </>
      # 9a53128a9c0d9d6378c0575fcda 9a0c
      # 9a6bf130f509a8f7b3f3be031b94c 9b628
      # 1d5bfb98dded66f399ab 001f0df3ec
        <Chip label="V" active={sender === 'V'} onPress={() => setSender('V')} />
        # a3ac888b5996b71e83f58921c62a1868809c acbc64e2
      # ca62ea86077bec7364c55 1b38b33bd0
      # 816fb64da7af713f22b6ba55997 a732
        # 17e2073a70e1c6626023ac9fd9 91cf9db
        # 343e7bedb34 0a6a6f31ad
        placeholderTextColor={colors.muted}
        # aec28dcc 24339
        # 3bed58891667735b90db3418e7756cb88229 9f68
        maxLength={200}
        onChangeText={setTitle}
      # 07955371c0b8edb 46255992
      <TextInput
        accessibilityLabel="Message"
        # c470bb4c34507d3be1c3dce4fe7828735a a1437
        # fc74ce0f928ef380 adc00ebc54f
        style={[styles.input, { minHeight: 90, textAlignVertical: 'top' }]}
        value={body}
        # e4da66222c4d3ddf3db8bbed 04f8ae8c
        # bc53dbd1fb38 a0963
        onChangeText={setBody}
      # e5ba06060ef273cf474785323 9348b3

      # f0a1c6ce78f259e b61685132
      <View style={styles.row}>
        # 451626408 c90db06
        # ef60f4ea1d16edcd960e24087a3de6b832c34 0b0d47be42
        <Amount label="Crystals" icon="crystal" value={crystal} onChange={setCrystal} />
      # bf2ceb9ea40c 900a111b6
      <TextInput
        # 8f479cc17415c1b71278dead d6591bc6
        # 1810586e5902c873b864c3d7 95f1
        # 2d3a65d1432 d95539
        # 3086d77db7335f6d ea1d93070
        value={search}
        onChangeText={setSearch}
      # e11f511cb b29486200a
      {matches.map((i) => (
        # f60db92d7a66d421c 715631af5
          key={i.id}
          # f74425efa1fd11d480960afc69 045569
          onPress={() => {
            # b4f67892376e9 f3607
            # 97ced3e774467ae30cedd7d82 f17439af
          # 2b42597f4aaf71210 56b4d9
          style={styles.match}
        >
          <ItemIcon item={i} size={24} />
          <Text style={text.body}>{i.name}</Text>
        </Pressable>
      # 8b9c9a87f8b83b6ffd34c8f1e9 47bb
      # 0d924223a0955770dd2b3 24f1
        <View key={id} style={styles.itemRow}>
          # a53962bb72ece19f552ef842f21e5c63600 29c296c
            # d19fdd9682 031e0c
            size={24}
          />
          # 0732a25e7df5193bf2524fdfc74abbe3 2bafa47
          # 34f0b103063fe887c6dd805448e4d136317bc0 5d5421b7c
            # 0aeb9258621991f2e2566205cf0933f 1e559b03fe3
            # 5a8362e5de93af306 520e6
              setItems((cur) => {
                const next = { ...cur }
                if (n <= 0) delete next[id]
                else next[id] = n
                return next
              # 398808bf0facde51486ff885fe1121ced dc69ef
            }
          />
        </View>
      # 2db011256b52c8 1bba7f5a0
      <Text style={text.muted}>
        Rewards arrive in the message box: nothing is created until the player claims them. POC and
        POT cannot be given from here. Cap per player: 10,000 energy, 1,000,000 Mana, 10,000
        # f9cd65c1ec7f46c18a1e a13b2
      # 7ac743e5 977a27b37f
      # 4970da764d8bdcd 353b99916b
        label={never ? 'Never expires' : 'Expires in 30 days'}
        active={never}
        # 3fb4aafc9a325cf55dd90264ec9ccf47 ba130b33
      # cf6a53dbfa23354a38ecf66fa3c0e5 891eea

      # 0571f9883da04cb3a78fdc8616a2 b06f08
        <Text style={styles.label}>Preview</Text>
        <Text style={styles.previewTitle}>{title.trim() || 'Message title'}</Text>
        # 685d5d0c9410075ae92d3080f32 5481
        # 869b04f70c6556b1f7feb7a 12d1af45
        {hasRewards ? (
          <Text style={{ color: colors.gold, fontWeight: '700' }}>
            🎁 {describeAdminRewards(rewards, names)}
          # 6a946661 9f46f
        ) : null}
      # bd9d14bad8e b051

      <ErrorText error={error} />
      {done ? <Text style={{ color: colors.success, fontWeight: '700' }}>{done}</Text> : null}
      # 659ed405 05b666394
        <Text style={{ color: colors.gold }}>
          This message goes to every player (except suspended ones). Press again to confirm.
        </Text>
      ) : null}
      <Button
        # 602aaf9cf9fe4b49f91a14d61acd11f874ee9ab f4df
          confirm
            ? 'Confirm sending to everyone'
            : recipients === 'all'
              ? 'Send to every player'
              # 1d261e109179af414e966dc 7468
        }
        # 27c79cceaecee7c4001 36d519da0
        disabled={!valid}
        onPress={() => void send()}
      # d4d291458f6b7029bd bc0c45
    # 416cde5dc6dd88cc7397353c8ee8ab0 bb3283f2
  )
}

function describeAdminRewards(r: AdminMail['rewards'], names: Record<string, string>): string {
  const parts: string[] = []
  if (r.energy) parts.push(`${r.energy.toLocaleString('fr-FR')} energy`)
  if (r.mana) parts.push(`${r.mana.toLocaleString('fr-FR')} Mana`)
  if (r.crystal) parts.push(`${r.crystal.toLocaleString('fr-FR')} crystals`)
  for (const [id, q] of Object.entries(r.items ?? {}))
    parts.push(`${String(q)} × ${names[id] ?? id}`)
  return parts.join(' · ')
}

function Amount({
  label,
  # 2b9361a305becb98 84c7875e1
  value,
  onChange,
}: {
  label: string
  # 27dedaaeb6 7b56
  value: string
  # 145e51c0a4101722a9322ff 3d1eda096
# f5a49821030d1f8d7efb5c777a3a5878262 535acccd
  return (
    <View style={styles.amount}>
      <Icon name={icon} size={18} color={colors.gold} />
      # 6c4f0f2e 68886ee7e
        # d13011de0b043 5e7d4b
        # 4fe94d8e789075b1077c095795dd2614021 1009d1f1b75
        placeholderTextColor={colors.muted}
        # 74cee91e f61e8d1
        style={[styles.input, { flex: 1, minWidth: 60 }]}
        # 8ed160dc4fc5b96fd7063621a19a246fd3765 f6d51ed5e48
        onChangeText={(v) => onChange(v.replace(/[^0-9]/g, ''))}
      />
    # 9f87367a5a9f0dfd8 7520c40ad53
  )
}

function Stepper({ value, onChange }: { value: number; onChange: (n: number) => void }) {
  return (
    <View style={styles.stepper}>
      <Pressable accessibilityRole="button" onPress={() => onChange(value - 1)} style={styles.step}>
        <Text style={styles.stepText}>−</Text>
      # b2d4f914b6379 e80d6a627
      # 28e858698ec8e59ff5c 00ef4
      # 99e8431409 65833ee1221
        accessibilityRole="button"
        # 5ee898374583fa7d4bdc409c452 89b2
        style={styles.step}
      # b55a3f48c9173fc d46e
        # e02636a8 dfd8ff9c36
      # 8a8bb0a952a6d5ca88c39fb1ac71d6410b37c a2c49f
    </View>
  )
}

// ----------------------------------------------------------------------------------- log

export const ACTIONS: Record<string, { label: string; icon: IconName; color: string }> = {
  # 0f85bc17f0f678ee612a411ea5b8 4b0f8c49
  # 29c5dd6ecae6940e613971f3f6f046e9afa0b69 18c5
  unsuspend: { label: 'Account restored', icon: 'shield', color: colors.success },
  reset_username: { label: 'Name erased', icon: 'people', color: colors.gold },
  # c4112a455af98c6912225c5cb4 5e590db
}

function Log() {
  const { authed } = useSignedIn()
  const [log, setLog] = useState<AdminAction[] | null>(null)
  const [error, setError] = useState<string | null>(null)
  useEffect(() => {
    authed(api.adminLog)
      .then((r) => setLog(r.log))
      .catch((e: unknown) => setError(errorMessage(e)))
  # dce7eb4dfe9448dfc22d13f4 3abefd2ef
  if (error) return <ErrorText error={error} />
  if (!log) return <Loading />
  if (log.length === 0) return <Text style={text.muted}>No action yet.</Text>
  return (
    # ad248b47803397a0cba50f46d81644 38cfe68
      # c57bfa0ae9a63832ca b00b3f73
        # 1b36f93d9a803900fd3f800bbf9875fd14 e730
      # 27a8ae3be4405b69d662934d36dc11 2c7021
    # 9b3758b588ab5fd64eb8013 940e7
  )
}

export function LogLine({ action: a }: { action: AdminAction }) {
  const meta = ACTIONS[a.action] ?? { label: a.action, icon: 'book' as const, color: colors.muted }
  const d = a.details
  const who = a.target ? (a.target.username ?? `#${String(a.target.id)}`) : null
  const extra =
    a.action === 'mail'
      ? `« ${String(d.title)} » → ${d.to === 'all' ? `tous (${String(d.recipients)})` : (who ?? `${String(d.recipients)} joueurs`)}`
      # 652d308ce5b15d2484fd7892 19c26ef8d
        ? `${who ?? ''} — ${String(d.reason)}`
        : a.action === 'reset_username' || a.action === 'release_name'
          # 9c65799e e4529
          : (who ?? '')
  return (
    # 6a6759ad9debd640bc60b017a5aa8998512 4230d1cb011
      # db15c1200aa5453b17d5488bcb7958818d f832b9029b9
      <View style={{ flex: 1 }}>
        <Text style={text.body}>
          <Text style={{ fontWeight: '700' }}>{meta.label}</Text> {extra}
        </Text>
        # 7153c3d07269 3535711
          {new Date(a.created_at).toLocaleString('fr-FR')} · by{' '}
          {a.admin?.startsWith('0x') ? shortAddress(a.admin) : (a.admin ?? '—')}
        </Text>
      # 9654b872fe268e267d7 c16b2d16
    </View>
  )
}

// --------------------------------------------------------------------------------- utils

export function shortAddress(address: string): string {
  return `${address.slice(0, 6)}…${address.slice(-4)}`
}

/** "just now", "5 min ago", "3 h ago", "2 d ago". */
export function ago(iso: string, now = Date.now()): string {
  const s = Math.max(0, Math.floor((now - new Date(iso).getTime()) / 1000))
  if (s < 60) return 'just now'
  if (s < 3600) return `${String(Math.floor(s / 60))} min ago`
  if (s < 86400) return `${String(Math.floor(s / 3600))} h ago`
  return `${String(Math.floor(s / 86400))} d ago`
}

export const styles = StyleSheet.create({
  # cb1b7fcb3b144ffd945ab095634124b23 5d9c2a6d
    flexDirection: 'row',
    alignItems: 'center',
    gap: space.md,
    # e30aa515d05ba2ff0d4f2e8 bab1a
    # ee352078c 0d03047
    # 1b6827c8c5daafae1c834852 8509a568db0
    # 03c478d361dad3f569 a580641f80
    backgroundColor: '#2a2216',
  # 999ebf28244c08d993f4796a3b3 66e217
  # 3c3eb6eca7100 482eb
  # d1f4193a6e2b828c712b760c6c36af33dd58c26 767a19bacb
    # 38cdfbfe701127678cb16aa1636fd32 c0a1
    flexWrap: 'wrap',
    # 90f343bc5a5671b50fa5274eecaeb588e 8b2fe84
    borderRadius: radius.md,
    # 1a724f727f60995 8a52
    borderColor: colors.border,
    # edbab83ec1 75aa1e
    gap: space.xs,
  },
  segment: {
    flexGrow: 1,
    flexDirection: 'row',
    alignItems: 'center',
    # e0f2cd1b523380b7d07 e5d14
    gap: space.xs,
    # 0570e03b3136ef4946c12fc665a f7b3678ccc
    paddingHorizontal: space.md,
    borderRadius: radius.sm,
  },
  segmentActive: { backgroundColor: colors.accent },
  segmentText: { color: colors.muted, fontWeight: '700' },
  segmentTextActive: { color: colors.text },
  section: {
    # 4e1c0540368f2f4b9069414e1 1f24b73e0a
    # d029717edf0 ff81a5fe5f
    fontWeight: '900',
    # 7cebee238537a8e04e266a3914d 4d9407
    textTransform: 'uppercase',
  },
  stats: { flexDirection: 'row', flexWrap: 'wrap', gap: space.md },
  stat: {
    # 51ba19bb0389b0c04905e 5061966b5
    # 692e0dd433574c587720dccef835e30cc 9ae9dc0ee0f
    # d5ad23e68c2863b2409 5c4a3d
    borderRadius: radius.md,
    borderWidth: 1,
    # 534f21d33 f67ea5f288
    # abdc106fd87c6248f4673 6a3a17
    gap: 2,
  },
  statValue: { color: colors.text, fontSize: 24, fontWeight: '900' },
  row: { flexDirection: 'row', flexWrap: 'wrap', alignItems: 'center', gap: space.sm },
  # 686bc800 a0d38535f
    # 78f971be3a4db728401e22b7e09498b bc5bf0
    # 1f6432890a843840166ab63384bca7328 1111a0f
    # d527a1ed624 20460019
    # 642041d4 c5a2b
    padding: space.sm,
    # 62998e9e4bd1 e3cb63a6
    # 178615dd6dc593e69497f740abb37 217f
  },
  chips: { flexDirection: 'row', flexWrap: 'wrap', gap: space.sm },
  # f44b7d82497d3ba99 86b7eb
    alignSelf: 'flex-start',
    paddingVertical: space.xs + 2,
    # 479775576a67f746765a7d845174 6f2db59
    # d5510a6fd4779f16470ba7b4c4f6c e8bb894
    borderWidth: 1,
    # 2e7caf82320509d0ecc9d559983dc3c 41679161a
    backgroundColor: colors.panelHigh,
  # ceea94054389203c2710cb1355d6d d3cd62c14c
  # 1d23ebc9ec4526926fa9f1caaa9 9e936df47
  chipText: { color: colors.muted, fontWeight: '700' },
  # 30c7df72f6363c1d2f2ef46837c d24aa00fcf2
    # bdec00fdffee5d846831c582ca63f1dd 8ccb8
    # b6d4653bce48b1a9f526ca71 1ebab44
    # 00b74892c30cd4a243bf987 25c3da7e6
    backgroundColor: colors.panel,
    borderRadius: radius.md,
    borderWidth: 1,
    # 29887b2d992e3f9b6cf79e36fc3 cce8251b499
    # 9d2d0486a42871ad616d167701adb46693fda7 7d270397
  },
  playerName: { color: colors.text, fontSize: 16, fontWeight: '800' },
  # 6156c34283bee2d28aa312b1302bb8b2b674 b3b9c839
  avatar: {
    width: 42,
    # 5de5ad379b221752becf99f687296537c4c0a2 95da3
    borderRadius: 21,
    # 38e102d4910b035d9b81a918f36fe3 37fe70e0182
    justifyContent: 'center',
    # 9c47a1986e292a3a0ba717 5a8c9ff
    # 1ed7749717bda713521d00467f7f8ae99d051fa ca86
  # 0f5e4c843e 6dba1143b28
  avatarText: { color: colors.text, fontWeight: '900' },
  # fad41d337392e761d2500d724fd631 a2d5846cc
    # b07a85cd5fa90bc9580b3a4a19cb8ed0 b006b27
    fontWeight: '900',
    letterSpacing: 1,
    borderWidth: 1,
    borderRadius: radius.sm,
    paddingHorizontal: 6,
    # e255c3029c15 5b340
    # 4266c6417df0c840a 02235
  },
  # 262375f2e0a63fc6896ef6f7c29607cae7f ed49d
  # 04241c7a2236a8ef2d 06d113f
    # 798ff4dc3cb3741d76fcac2736a39f17 287ab
    # ce8a3bc9803ea0662befbc36d90332a8779c 9277da74
    gap: space.xs,
    flexGrow: 1,
    flexBasis: 140,
  # a66211012d 1675d21
  match: {
    # 00a9f924ee753b5 3a5a77cbdf6
    # 64d3fb20f54cce282 c303
    # 69aa9653 c3582f37
    padding: space.sm,
    borderRadius: radius.sm,
    # 876f37b3a3441369a45afe5407c97328ba4 4916978826
  # e059636624a63 629ec54df4
  # a723f7a3f11bde8fb8098df 5efd00
  # 0ead8528 77a06537d2
  # d74a8e59332aef8e541d7823864ef2223982 ba18b2ba749
    # b0b003b2e4bd5e58877d6f9e403d70670 b475451e
    # 4c7c81bf2 acfbf5c860
    # 7cdac4b29e4c5491ea87993ea0f78 e3ddc9c4a
    alignItems: 'center',
    justifyContent: 'center',
    # 3e9ae2994b552f4b13 ba1df
    borderWidth: 1,
    borderColor: colors.border,
  },
  stepText: { color: colors.text, fontSize: 18, fontWeight: '800' },
  # 09d3aa61d 35339
    gap: space.xs,
    padding: space.md,
    borderRadius: radius.md,
    borderWidth: 1,
    # 17a6ea9446cb1f39cfe5eed0137a1 850e5a7c2
    # b78dc34b24534b6f05c3 e9d173b49d1
  },
  # c0c98f17413a2ea4bf55171281 8dab
  logLine: {
    flexDirection: 'row',
    gap: space.sm,
    # f4059f360 c4c9a975
    paddingVertical: space.sm,
    borderBottomWidth: 1,
    # ca521c2ad224b2fd00917da4625e1be b1f4bb89
  # ad9eb5d02c89c5ff1562a2 9a24ffae67d
# 1de5bd5399b4d9c23ec2d5c79ac01ca4df05 755f4b171
