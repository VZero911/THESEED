/**
 * V3 rune art: a cut gem whose outline tells the slot, the colour the set, the rim the rarity, the
 * pips the stars, with a glow that breathes on legendary and mythic runes (reduce motion: still).
 */
import Svg, { Circle, Defs, G, LinearGradient, Path, Polygon, Stop, Text } from 'react-native-svg'
import { Pulse } from '../motion'
import { SET_COLORS } from './palette'

const RIM: Record<string, string> = {
  normal: '#c9c6d8',
  uncommon: '#5fd38d',
  rare: '#4aa3f0',
  heroic: '#c46cf0',
  legendary: '#f2a94e',
  mythic: '#ef5d6c',
}

/** One outline per slot, drawn in a 48 x 48 box. */
const SHAPES: Record<number, string> = {
  1: '24,3 43,24 24,45 5,24', // diamond
  2: '24,3 42,13 42,35 24,45 6,35 6,13', // hexagon
  3: '24,4 44,40 4,40', // triangle
  4: '8,8 40,8 40,40 8,40', // square
  5: '24,3 36,7 44,18 44,30 36,41 24,45 12,41 4,30 4,18 12,7', // round cut
  6: '24,2 30,17 46,18 34,28 38,44 24,35 10,44 14,28 2,18 18,17', // star
  7: '24,3 33,9 43,24 33,39 24,45 15,39 5,24 15,9', // oval, the neutral slot
}

const NEUTRAL_CUT = '24,3 33,9 43,24 33,39 24,45 15,39 5,24 15,9'
const NORMAL_RIM = '#c9c6d8'

export interface RuneGemSpec {
  points: string
  color: string
  rim: string
  glow: boolean
  pips: number
}

/** Pure description of a gem, shared by the art and its tests. */
export function runeGemSpec(
  slot: number,
  setId: string,
  rarity: string,
  stars: number,
): RuneGemSpec {
  return {
    points: SHAPES[slot] ?? NEUTRAL_CUT,
    color: SET_COLORS[setId] ?? '#8b8a99',
    rim: RIM[rarity] ?? NORMAL_RIM,
    glow: rarity === 'legendary' || rarity === 'mythic',
    pips: Math.max(0, Math.min(6, Math.round(stars))),
  }
}

export function RuneGem({
  slot,
  setId,
  rarity,
  stars,
  level,
  size = 48,
}: {
  slot: number
  setId: string
  rarity: string
  stars: number
  level?: number
  size?: number
}) {
  const g = runeGemSpec(slot, setId, rarity, stars)
  const id = `gem-${setId}-${String(slot)}-${rarity}`
  const art = (
    <Svg width={size} height={size} viewBox="0 0 48 48" accessibilityLabel={`${setId} ${rarity}`}>
      <Defs>
        <LinearGradient id={id} x1="0" y1="0" x2="1" y2="1">
          <Stop offset="0" stopColor="#ffffff" stopOpacity={0.85} />
          <Stop offset="0.35" stopColor={g.color} stopOpacity={1} />
          <Stop offset="1" stopColor="#0b0a14" stopOpacity={0.9} />
        </LinearGradient>
      </Defs>
      {g.glow ? <Circle cx={24} cy={24} r={23} fill={g.rim} opacity={0.18} /> : null}
      <Polygon
        points={g.points}
        fill={`url(#${id})`}
        stroke={g.rim}
        strokeWidth={2.2}
        strokeLinejoin="round"
      />
      {/* facets: a bright upper-left plane and a dark lower-right one */}
      <Path d="M24 8 L14 22 L24 24z" fill="#ffffff" opacity={0.22} />
      <Path d="M24 24 L36 30 L24 42z" fill="#000000" opacity={0.25} />
      {level !== undefined ? (
        <Text
          x={24}
          y={29}
          fontSize={13}
          fontWeight="900"
          fill="#ffffff"
          textAnchor="middle"
          stroke="#0b0a14"
          strokeWidth={0.6}
        >
          {level}
        </Text>
      ) : null}
      <G>
        {Array.from({ length: g.pips }, (_, i) => (
          <Circle key={i} cx={24 + (i - (g.pips - 1) / 2) * 6} cy={46} r={1.6} fill="#ffd23f" />
        ))}
      </G>
    </Svg>
  )
  return g.glow ? <Pulse>{art}</Pulse> : art
}
