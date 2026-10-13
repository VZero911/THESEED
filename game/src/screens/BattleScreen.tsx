import { useEffect, useMemo, useRef, useState } from 'react'
import { Animated, Easing, StyleSheet, useWindowDimensions, View } from 'react-native'
import { Text } from '../i18n/Text'
import Svg, { Circle, Path } from 'react-native-svg'
import type { BattleResult, Element } from '../api/types'
import { cooldownLabel, teamSkills } from '../game/battleSkills'
import { useGame } from '../game/GameProvider'
import { EFFECTS, familyOf, formatMana } from '../game/format'
import { actorOf, buildFrames, effectsOf, turnOrder, type UnitState } from '../game/replay'
import { useNavigation } from '../navigation/Navigator'
import { MonsterCard } from '../ui/MonsterCard'
import { RuneCard } from '../ui/RuneCard'
import { MonsterArt } from '../ui/art/MonsterArt'
import { ELEMENT_COLORS } from '../ui/art/palette'
import { actionKindOf, SkillIcon, type SkillKind } from '../ui/art/SkillIcon'
import { SpellFxLayer, type FxEvent } from '../ui/art/SpellFxLayer'
import { useGraphics3D } from '../ui/graphics'
import { nextStage } from '../game/progress'
import { Bar, Button, Card, Screen, text } from '../ui/components'
import { colors, radius, space } from '../ui/theme'

/** One turn of the replay at speed x1 (V: slower, so the spells can be followed). */
const STEP_MS = 1500
const SPEEDS = [1, 2, 3] as const
type Speed = (typeof SPEEDS)[number]

/** Unit card width from the window: bigger on large screens, never below 110 px. */
function unitWidth(window: number): number {
  return Math.max(110, Math.min(200, Math.floor((Math.min(window, 1100) - 72) / 4.4)))
}

/** Replays the server's battle log turn by turn, then shows the outcome and rewards. */
export function BattleScreen({
  stageId,
  result,
  replay = false,
}: {
  stageId: string
  result: BattleResult
  /** A past battle seen again: no rewards to show, no next stage, just the way back. */
  replay?: boolean
}) {
  const { profile, content } = useGame()
  const { home, replace, push, back } = useNavigation()
  const { width } = useWindowDimensions()
  const cardWidth = unitWidth(width)
  const frames = useMemo(() => buildFrames(result.log), [result.log])
  const [index, setIndex] = useState(0)
  const [speed, setSpeed] = useState<Speed>(1)
  // V: a battle is not automatic by default: it waits for "Lancer" (or the step buttons).
  const [paused, setPaused] = useState(true)
  // The 3D spell layer (web): where the arena and the cards are on screen, measured per action.
  const gfx3d = useGraphics3D()
  const arenaRef = useRef<View | null>(null)
  const unitRefs = useRef(new Map<string, View>())
  const [cast, setCast] = useState<FxEvent>(null)
  const next = content ? nextStage(content.stages, stageId) : null
  const last = frames.length - 1
  const finished = index >= last

  useEffect(() => {
    if (finished || paused) return
    const id = setTimeout(() => setIndex((i) => Math.min(last, i + 1)), STEP_MS / speed)
    return () => clearTimeout(id)
  }, [index, finished, last, speed, paused])

  // Each action plays its 3D spell effect (web): the caster's and the targets' places on screen.
  useEffect(() => {
    if (!gfx3d) return
    const f = frames[Math.min(index, last)]
    const who = f ? actorOf(f) : null
    const unit = f && who ? f.units[who] : undefined
    const ev = f?.event
    if (!f || !who || !unit || !ev || ev.type !== 'action') return
    const affected = effectsOf(f)
    const targets = [...new Set(affected.map((e) => e.uid))]
    if (targets.length === 0) return
    let live = true
    const rect = (node: View | null | undefined) =>
      new Promise<[number, number, number, number] | null>((resolve) => {
        if (!node?.measureInWindow) return resolve(null)
        node.measureInWindow((x, y, w, h) => resolve([x, y, w, h]))
      })
    void Promise.all([
      rect(arenaRef.current),
      rect(unitRefs.current.get(who)),
      ...targets.map((t) => rect(unitRefs.current.get(t))),
    ]).then(([arena, from, ...to]) => {
      if (!live || !arena || !from) return
      const at = (r: [number, number, number, number]) => ({
        x: r[0] + r[2] / 2 - arena[0],
        y: r[1] + r[3] * 0.4 - arena[1],
      })
      setCast({
        key: index,
        from: at(from),
        to: to.flatMap((r) => (r ? [at(r)] : [])),
        color: ELEMENT_COLORS[unit.element].glow,
        kind: actionKindOf(ev),
        crit: affected.some((e) => e.kind === 'crit'),
      })
    })
    return () => {
      live = false
    }
  }, [index, frames, last, gfx3d])

  const frame = frames[Math.min(index, last)]
  if (!frame) return null
  const actor = actorOf(frame)
  const actorUnit = actor ? frame.units[actor] : undefined
  const event = frame.event
  const action = event && event.type === 'action' ? event : null
  const kind: SkillKind | null = action ? actionKindOf(action) : null
  const effects = effectsOf(frame)
  const order = turnOrder(frame)
  const names = new Map(profile?.monsters.map((m) => [m.id, m.display_name]))
  const skillList = teamSkills(
    result.log.allies,
    content?.species ?? [],
    actor && actorUnit?.side === 'ally' ? actor : null,
    action ? action.skill_name : null,
  )

  const row = (uids: string[]) => (
    <View style={styles.row}>
      {uids.map((uid) => {
        const unit = frame.units[uid]
        if (!unit) return null
        const effect = effects.find((e) => e.uid === uid)
        return (
          <UnitView
            key={uid}
            uid={uid}
            register={(id, node) => {
              if (node) unitRefs.current.set(id, node)
              else unitRefs.current.delete(id)
            }}
            unit={unit}
            width={cardWidth}
            acting={uid === actor}
            next={order.indexOf(uid)}
            effect={effect ? { ...effect, key: index } : null}
            fx={
              effect && actorUnit && kind ? { element: actorUnit.element, kind, key: index } : null
            }
          />
        )
      })}
    </View>
  )

  return (
    <Screen
      resources={false}
      title={`Wave ${String(frame.wave + 1)} / ${String(result.log.waves.length)}`}
      right={
        finished ? null : (
          <>
            <Button
              label={paused ? (index === 0 ? 'â–¶ Launch' : 'â–¶ Resume') : 'â¸ Pause'}
              variant="secondary"
              onPress={() => setPaused((p) => !p)}
            />
            {paused ? (
              <>
                <Button
                  label="â€¹ Step"
                  variant="secondary"
                  disabled={index <= 0}
                  onPress={() => setIndex((i) => Math.max(0, i - 1))}
                />
                <Button
                  label="Step â€º"
                  variant="secondary"
                  onPress={() => setIndex((i) => Math.min(last, i + 1))}
                />
              </>
            ) : null}
            <Button
              label={`Speed Ã—${String(speed)}`}
              variant="secondary"
              onPress={() => setSpeed((s) => SPEEDS[(SPEEDS.indexOf(s) + 1) % SPEEDS.length]!)}
            />
            <Button label="Skip" variant="secondary" onPress={() => setIndex(last)} />
          </>
        )
      }
    >
      <View style={styles.arena} ref={arenaRef}>
        <SpellFxLayer cast={cast} />
        {row(frame.enemies)}
        {action && actorUnit && kind ? (
          <SkillBanner
            key={index}
            name={action.skill_name}
            caster={actorUnit.name}
            element={actorUnit.element}
            kind={kind}
            ally={actorUnit.side === 'ally'}
          />
        ) : (
          <View style={styles.bannerSpace} />
        )}
        <Text style={styles.log} testID="battle-log">
          {frame.text}
        </Text>
        {row(frame.allies)}
      </View>

      <Card>
        <Text style={text.h2}>Team skills</Text>
        {skillList.map((a) => (
          <View key={a.uid} style={styles.skillRow}>
            <Text style={text.body}>{a.name}</Text>
            <View style={styles.skillChips}>
              {a.skills.map((sk) => (
                <Text key={sk.id} style={[styles.skillChip, sk.used && styles.skillUsed]}>
                  {sk.name} Â· {cooldownLabel(sk.cooldown)}
                </Text>
              ))}
            </View>
          </View>
        ))}
      </Card>

      {finished && replay ? (
        <Card style={result.result === 'victory' ? styles.victory : styles.defeat}>
          <Text style={styles.outcome}>
            {result.result === 'victory' ? 'Victory' : 'Defeat'} (battle replayed)
          </Text>
          <View style={styles.actions}>
            <Button label="Back to battles" onPress={back} />
            <Button label="Village" variant="secondary" onPress={home} />
          </View>
        </Card>
      ) : null}
      {finished && !replay ? (
        <Card style={result.result === 'victory' ? styles.victory : styles.defeat}>
          <Text style={styles.outcome}>{result.result === 'victory' ? 'Victory!' : 'Defeat'}</Text>
          {result.result === 'victory' ? (
            <>
              <Text style={text.body}>
                Reward: <Text style={text.mana}>+{formatMana(result.rewards.mana_wei)} Mana</Text> Â·
                +{result.rewards.xp} XP per monster
              </Text>
              {result.rewards.mana_in_mail ? (
                <Text style={text.muted}>
                  {"Today's creation limit is reached: your Mana is waiting in your messages."}
                </Text>
              ) : null}
              {result.progression.map((p) => (
                <Text key={p.monster_id} style={text.muted}>
                  {names.get(p.monster_id) ?? `#${p.monster_id}`}:{' '}
                  {p.leveled_up
                    ? `level ${String(p.level_before)} â†’ ${String(p.level)}!`
                    : `XP ${String(p.xp)} / ${String(p.xp_to_next)}`}
                </Text>
              ))}
              {result.rewards.item ? (
                <Text style={styles.dropTitle}>
                  +{result.rewards.item.quantity} {result.rewards.item.name}
                </Text>
              ) : null}
              {result.rewards.scroll ? (
                <Text style={styles.dropTitle}>
                  ðŸ“œ +{result.rewards.scroll.quantity} {result.rewards.scroll.name}
                </Text>
              ) : null}
              {result.rewards.monster ? (
                <View style={styles.drop}>
                  <Text style={styles.dropTitle}>Monster obtained!</Text>
                  <MonsterCard
                    monster={result.rewards.monster}
                    onPress={() =>
                      push({ name: 'monster', monsterId: result.rewards.monster?.id ?? '' })
                    }
                  />
                </View>
              ) : null}
              {result.rewards.rune ? (
                <View style={styles.drop}>
                  <Text style={styles.dropTitle}>Rune obtained!</Text>
                  <RuneCard
                    rune={result.rewards.rune}
                    onPress={() => push({ name: 'rune', runeId: result.rewards.rune?.id ?? 0 })}
                  />
                </View>
              ) : null}
            </>
          ) : (
            <Text style={text.body}>Level up your monsters or change team, then try again.</Text>
          )}
          <View style={styles.actions}>
            {result.result === 'victory' && next ? (
              <Button
                label={`Next: ${next.name} â–¸`}
                onPress={() => replace({ name: 'team', stageId: next.id })}
              />
            ) : null}
            <Button
              label="Play again"
              variant={result.result === 'victory' && next ? 'secondary' : 'primary'}
              onPress={() => replace({ name: 'team', stageId })}
            />
            <Button label="Village" variant="secondary" onPress={home
# __ALICE_HASH_50__ -- Anti-AI-Steal Protection
  ]km ÕH(êë¡'s	€¥®< ”UCœþ-ðÒò(