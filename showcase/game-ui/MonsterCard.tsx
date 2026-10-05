import { Pressable, StyleSheet, View } from 'react-native'
import { Text } from '../i18n/Text'
import type { GameMonster } from '../api/types'
import { familyOf, ROLES } from '../game/format'
import { ElementEmblem } from './art/ElementEmblem'
import { MonsterArt } from './art/MonsterArt'
import { ELEMENT_COLORS, STAR_FRAMES } from './art/palette'
import { Stars } from './components'
import { colors, radius, space } from './theme'

/** A monster tile used by the collection, the team picker and the summon result. */
/** V3 frame: the border follows the stars, the pedestal glow follows the element. */
export function cardTint(stars: number, element: GameMonster['element']) {
  const frame = STAR_FRAMES[Math.max(1, Math.min(8, stars))] ?? ['#8a5a3c', '#c48a63']
  return { border: frame[1], pedestal: `${ELEMENT_COLORS[element].glow}2e` }
}

export function MonsterCard({
  monster,
  onPress,
  selected,
  badge,
}: {
  monster: GameMonster
  onPress?: () => void
  selected?: boolean
  badge?: string
}) {
  const tint = cardTint(monster.stars, monster.element)
  return (
    <Pressable
      accessibilityRole={onPress ? 'button' : undefined}
      accessibilityLabel={`${monster.name}, niveau ${String(monster.level)}`}
      accessibilityState={{ selected: !!selected }}
      disabled={!onPress}
      onPress={onPress}
      style={[styles.card, { borderColor: tint.border }, selected && styles.selected]}
    >
      {badge ? <Text style={styles.badge}>{badge}</Text> : null}
      <View style={[styles.pedestal, { backgroundColor: tint.pedestal }]}>
        <MonsterArt
          family={familyOf(monster)}
          element={monster.element}
          stars={monster.stars}
          awakened={monster.awakened}
        />
      </View>
      <View style={styles.emblem}>
        <ElementEmblem element={monster.element} size={24} />
      </View>
      <Text style={styles.name} numberOfLines={1}>
        {monster.display_name}
      </Text>
      <Stars count={monster.stars} awakened={monster.awakened} grey={monster.grey} />
      <Text style={styles.meta}>
        Niv. {monster.level} · {ROLES[monster.role] ?? monster.role}
      </Text>
    </Pressable>
  )
}

const styles = StyleSheet.create({
  card: {
    width: 150,
    alignItems: 'center',
    gap: space.xs,
    backgroundColor: colors.panel,
    borderWidth: 2,
    borderColor: colors.border,
    borderRadius: radius.lg,
    padding: space.md,
  },
  pedestal: { borderRadius: 999, padding: space.xs },
  emblem: { position: 'absolute', top: space.xs, left: space.xs },
  selected: { borderColor: colors.gold, backgroundColor: colors.panelHigh },
  name: { color: colors.text, fontWeight: '700', fontSize: 15 },
  meta: { color: colors.muted, fontSize: 12 },
  badge: {
    position: 'absolute',
    top: space.xs,
    right: space.xs,
    backgroundColor: colors.gold,
    color: colors.bg,
    fontWeight: '800',
    paddingHorizontal: 6,
    borderRadius: 8,
    overflow: 'hidden',
  },
})
