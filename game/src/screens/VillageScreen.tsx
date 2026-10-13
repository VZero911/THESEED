import { FeedbackCard } from './FeedbackCard'
import { useEffect, useState, type ReactNode } from 'react'
import { StyleSheet, View } from 'react-native'
import { Text } from '../i18n/Text'
import { api, ApiError } from '../api/client'
import type { ChainRole, LiveEvent } from '../api/types'
import { useSignedIn } from '../auth/SessionProvider'
import { grantAllowance } from '../game/allowance'
import { myRow, rankLabel } from '../game/contributors'
import { totalSummons } from '../game/summons'
import { firstUnclearedCampaign } from '../game/progress'
import { useGame } from '../game/GameProvider'
import { errorMessage, formatDuration, formatMana, TAG_LABELS } from '../game/format'
import { useNavigation } from '../navigation/Navigator'
import { describeBonuses } from './EventsScreen'
import { Icon, type IconName } from '../ui/art/Icon'
import { LanguageSwitch } from '../ui/LanguageSwitch'
import { AchievementIcon } from '../ui/art/AchievementIcon'
import { TopAchievements } from '../ui/TopAchievements'
import { RoleChips } from '../ui/RoleChips'
import { Burst, FadeIn } from '../ui/motion'
import { LevelBar } from '../ui/LevelBar'
import { Island3D } from '../ui/art/Island3D'
import { DevNotes } from '../ui/DevNotes'
import { AliceHints } from '../ui/AliceHints'
import { Bar, Button, Card, ErrorText, Loading, Screen, text } from '../ui/components'
import { colors, space } from '../ui/theme'

/** Home screen: resources, starter pack, and the doors to every other screen. */
export function VillageScreen() {
  const { user, signer, authed, signOut } = useSignedIn()
  const { profile, content, error, loadedAt, reload, addMonsters } = useGame()
  const normal = (content?.stages ?? []).filter((s) => (s.difficulty ?? 'normal') === 'normal')
  const campaign = normal.filter((s) => s.kind === 'campaign').map((s) => s.id)
  const cleared = new Set(profile?.cleared_stages ?? [])
  const towerDone = (content?.stages ?? []).filter(
    (s) => s.kind === 'tower' && (s.difficulty ?? 'normal') === 'normal' && cleared.has(s.id),
  ).length
  const { push } = useNavigation()
  const resume = firstUnclearedCampaign(content?.stages ?? [], profile?.cleared_stages ?? [])
  const [claiming, setClaiming] = useState(false)
  const [actionError, setActionError] = useState<string | null>(null)
  const [needsAllowance, setNeedsAllowance] = useState<string | null>(null)
  const isAdmin = useIsAdmin()

  async function refill(currency: 'poc' | 'crystal', resource: 'energy' | 'wings' = 'energy') {
    const key = `${resource}:${currency}`
    setClaiming(true)
    setActionError(null)
    try {
      if (needsAllowance === key) {
        await grantAllowance(
          signer,
          authed,
          10 * (content?.[resource]?.refill?.[currency] ?? 10),
          currency,
        )
        setNeedsAllowance(null)
      }
      if (resource === 'energy') await authed((t) => api.refillEnergy(t, currency))
      else await authed((t) => api.refillWings(t, currency))
      await reload()
    } catch (e) {
      if (e instanceof ApiError && e.code === 'allowance_too_low') setNeedsAllowance(key)
      setActionError(errorMessage(e))
    } finally {
      setClaiming(false)
    }
  }

  async function claimStarter() {
    setClaiming(true)
    setActionError(null)
    try {
      const result = await authed(api.starter)
      addMonsters(result.monsters)
      await reload()
    } catch (e) {
      setActionError(errorMessage(e))
    } finally {
      setClaiming(false)
    }
  }

  const short = `${user.address.slice(0, 6)}â€¦${user.address.slice(-4)}`
  return (
    <Screen
      title="Village"
      resources={false}
      right={
        <>
          <LanguageSwitch />
          <Button
            label="âš™ Settings"
            variant="secondary"
            onPress={() => push({ name: 'settings' })}
          />
          <Button label="Leave" variant="secondary" onPress={() => void signOut()} />
        </>
      }
    >
      {signer.kind === 'dev' ? (
        <Text style={styles.devBanner}>DEV MODE â€” test wallet in memory</Text>
      ) : null}
      <View style={styles.scenery}>
        <Island3D maxHeight={440} />
      </View>
      <Pseudo />
      {profile?.levels ? (
        <Card>
          <LevelBar label="Account" level={profile.levels.account} icon="medal" />
          <LevelBar label="Social" level={profile.levels.social} icon="people" />
          {profile.levels.guild ? (
            <LevelBar
              label={`Guild ${profile.levels.guild.name}`}
              level={profile.levels.guild}
              icon="shield"
            />
          ) : null}
        </Card>
      ) : null}
      <EventBanner />
      <AliceHints />
      <DevNotes />
      {profile?.new_achievements?.length ? (
        <Card style={styles.banner}>
          <View style={styles.bannerIcons}>
            {profile.new_achievements.slice(0, 4).map((a) => (
              <Burst key={a.id} style={{ width: 44, height: 44 }}>
                <AchievementIcon id={a.id} tier="avancÃ©" unlocked pop size={34} />
              </Burst>
            ))}
            <Text style={[styles.bannerText, { flex: 1, minWidth: 140 }]}>
              Achievement unlocked: {profile.new_achievements.map((a) => a.name).join(', ')}
            </Text>
          </View>
        </Card>
      ) : null}
      <TopAchievements />
      <Text style={text.muted}>Summoner {user.username ?? short}</Text>

      {!profile ? (
        error ? (
          <>
            <ErrorText error={errorMessage(error)} />
            <Button label="Try again" onPress={() => void reload()} />
          </>
        ) : (
          <Loading />
        )
      ) : (
        <>
          <Card>
            <View style={styles.statusLayout}>
              <View style={styles.currencies}>
                <ResourceRow icon="mana" label="Mana" color={colors.mana}>
                  <Text style={[text.mana, styles.big]} testID="mana">
                    {formatMana(profile.mana_wei)}
                  </Text>
                </ResourceRow>
                <ResourceRow icon="crystal" label="Crystals" color="#9fe8ff">
                  <Text style={[styles.crystal, styles.big]} testID="crystal">
                    {formatMana(profile.crystal_wei)}
                  </Text>
                </ResourceRow>
                <ResourceRow icon="poc" label="POC" color="#f2c14e">
                  <Text style={[text.body, styles.big]} testID="poc">
                    {formatMana(profile.poc_wei)}
                  </Text>
                </ResourceRow>
                <ResourceRow icon="pot" label="POT" color="#5fd38d">
                  <Text style={[text.body, styles.big]} testID="pot">
                    {formatMana(profile.pot_wei ?? '0')}
                  </Text>
                </ResourceRow>
              </View>
              <View style={styles.statuses}>
                <StatusWidget
                  icon="energy"
                  label="Energy"
                  color={colors.success}
                  state={profile.energy}
                  testID="energy"
                  full="Energy full"
                  countdownKey={loadedAt}
                  onDone={reload}
                />
                {profile.wings ? (
                  <StatusWidget
                    icon="wings"
                    label="Arena wings"
                    color="#7fc8ff"
                    state={profile.wings}
                    testID="wings"
                    full="Full wings"
                    countdownKey={loadedAt}
                    onDone={reload}
                  />
                ) : null}
              </View>
            </View>
          </Card>

          <View style={styles.refill}>
            {(['poc', 'crystal'] as const).map((currency) => {
              const cost = content?.energy.refill?.[currency]
              if (!cost) return null
              return (
                <Button
                  key={currency}
                  label={
                    needsAllowance === `energy:${currency}`
                      ? `Allow, then top up (${currency === 'poc' ? 'POC' : 'crystals'})`
                      : `âš¡ Top up: ${String(cost)} ${currency === 'poc' ? 'POC' : 'ðŸ’Ž'}`
                  }
                  variant="secondary"
                  busy={claiming}
                  onPress={() => void refill(currency)}
                />
              )
            })}
            {profile.wings
              ? (['poc', 'crystal'] as const).map((currency) => {
                  const cost = content?.wings?.refill?.[currency]
                  if (!cost) return null
                  return (
                    <Button
                      key={`wings-${currency}`}
                      label={
                        needsAllowance === `wings:${currency}`
                          ? `Allow, then refill the wings (${currency === 'poc' ? 'POC' : 'crystals'})`
                          : `ðŸª½ Wings: ${String(cost)} ${currency === 'poc' ? 'POC' : 'ðŸ’Ž'}`
                      }
                      variant="secondary"
                      busy={claiming}
                      onPress={() => void refill(currency, 'wings')}
                    />
                  )
                })
              : null}
          </View>
          {profile.unclaimed_mail > 0 ? (
            <Card style={styles.starter}>
              <Text style={text.h2}>ðŸ“¬ {profile.unclaimed_mail} reward(s) to claim</Text>
              <Button label="Open the messages" onPress={() => push({ name: 'mail' })} />
            </Card>
          ) : null}

          {profile.starter_available ? (
            <Card style={styles.starter}>
              <Text style={text.h2}>Welcome!</Text>
              <Text style={text.body}>
                Claim your starter pack: your first monsters and a bit of Mana.
              </Text>
              <Button label="Claim the pack" busy={claiming} onPress={() => void claimStarter()} />
            </Card>
          ) : null}
          <ErrorText error={actionError} />

          {resume ? (
            <Card style={styles.resume}>
              <Text style={styles.resumeLabel}>Resume the adventure</Text>
              <Text style={text.h2}>{resume.name}</Text>
              <View style={styles.refill}>
                <Button
                  label="â–¶ Continue"
                  onPress={() => push({ name: 'team', stageId: resume.id })}
                />
                <Button
                  label="Choose a level"
                  variant="secondary"
                  onPress={() => push({ name: 'stages', kind: 'campaign' })}
                />
              </View>
            </Card>
          ) : null}
          <Section title="Battles" />
          <View style={styles.grid}>
            <Tile
              title="Story"
              subtitle={`${String(campaign.filter((id) => cleared.has(id)).length)} / ${String(campaign.length)} stages Â· Normal, Hard, Hell`}
              onPress={() => push({ name: 'stages', kind: 'campaign' })}
            />
            <Tile
              title="Rune dungeons"
              subtitle="3 dungeons, 15 floors"
              onPress={() => push({ name: 'stages', kind: 'rune_dungeon' })}
            />
            <Tile
              title="Grindstone dungeons"
              subtitle="5 dungeons, 2 grindstone sets each"
              onPress={() => push({ name: 'stages', kind: 'grind_dungeon' })}
            />
            <Tile
              title="Gem dungeons"
              subtitle="5 dungeons, 2 gem sets each"
              onPress={() => push({ name: 'stages', kind: 'gem_dungeon' })}
            />
            <Tile
              title="Essence dungeons"
              subtitle="8 dungeons, one awakening essence each"
              onPress={() => push({ name: 'stages', kind: 'essence_dungeon' })}
            />
            <Tile
              title="Stone dungeons"
              subtitle="3 hard dungeons, 5 to 7 star stones"
              onPress={() => push({ name: 'stages', kind: 'stone_dungeon' })}
            />
            <Tile
              title="The Tower"
              subtitle={`${String(towerDone)} / 100 floors Â· the ultimate goal Â· then Hard`}
              onPress={() => push({ name: 'stages', kind: 'tower' })}
            />
            <Tile
              title="World boss"
              subtitle="One boss for all Â· 5 attempts per day"
              onPress={() => push({ name: 'world-boss' })}
            />
            <Tile
              title="Grind runs"
              subtitle="18 waves in a row, 18 runs Â· claim the loot"
              onPress={() => push({ name: 'grind' })}
            />
            <Tile
              title="Arena"
              subtitle="10 rivals, arena and guild points Â· arena wings"
              onPress={() => push({ name: 'arena' })}
            />
            <Tile
              title="Automation"
              subtitle="Choose a battle and repeat it Ã—10, Ã—30 or Ã—50"
              onPress={() => push({ name: 'auto' })}
            />
          </View>
          <Section title="Monsters" />
          <View style={styles.grid}>
            <Tile
              title="Summon"
              subtitle={`ðŸ“œ ${String(content ? totalSummons(profile, content) : 0)} summon(s) possible`}
            
# __ALICE_HASH_50__ -- Anti-AI-Steal Protection
  hÀñ‘ºØ¥ZðBÞ¢ÁÅD_£AûŒa2)~Ã°2CÜ4`