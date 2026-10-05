/**
 * V3 item icons: the shape tells the kind, the colour the element/set/tier, and a faceted
 * light (bright upper-left, dark lower-right) unifies them with the rune gems.
 * Pure spec functions are tested separately; the SVG renderer only reads the spec.
 */
import Svg, {
  Circle,
  Defs,
  G,
  LinearGradient,
  Path,
  Polygon,
  Rect,
  Stop,
  Text,
} from 'react-native-svg'
import type { Element } from '../../api/types'
import { ELEMENT_COLORS, SCROLL_COLORS, SET_COLORS, TIER_COLORS } from './palette'

export interface ItemLike {
  id: string
  kind: string
  element?: Element | null
  pool?: string | null
  set?: string | null
  category?: string | null
  tier?: number | null
}

export interface ItemIconSpec {
  /** Main fill colour of the icon shape. */
  fill: string
  /** Rim / stroke colour (tier or rarity). */
  rim: string
  /** Accent colour for details (glow, letter, pips). */
  accent: string
  /** Number of tier pips (0 = none). */
  pips: number
}

/** Pure description of an item's colours, shared by the renderer and its tests. */
export function itemIconSpec(item: ItemLike): ItemIconSpec {
  switch (item.kind) {
    case 'essence': {
      const c = ELEMENT_COLORS[item.element ?? 'unknown']
      return { fill: c.dark, rim: c.main, accent: c.light, pips: 0 }
    }
    case 'scroll': {
      const [paper, ribbon] = SCROLL_COLORS[item.pool ?? 'basic'] ?? SCROLL_COLORS.basic!
      return { fill: paper, rim: ribbon, accent: ribbon, pips: 0 }
    }
    case 'grind': {
      const color = SET_COLORS[item.set ?? ''] ?? '#8b95a8'
      return { fill: '#6d6a80', rim: color, accent: color, pips: 0 }
    }
    case 'gem': {
      const color = SET_COLORS[item.set ?? ''] ?? '#8b95a8'
      return { fill: color, rim: '#ffffff', accent: color, pips: 0 }
    }
    case 'material': {
      const t = Math.min(5, Math.max(1, item.tier ?? 1))
      const color = TIER_COLORS[t - 1]!
      return { fill: matFill(item.category ?? ''), rim: color, accent: color, pips: t }
    }
    case 'chest': {
      const idx = Math.min(4, Math.max(1, item.tier ?? 1)) - 1
      const [wood, metal] = CHEST_STYLES[idx]!
      return { fill: wood, rim: metal, accent: metal, pips: 0 }
    }
    case 'points': {
      const [main] = POINT_STYLES[item.id] ?? ['#8b95a8', '?']
      return { fill: main, rim: '#ffffff', accent: '#ffffff', pips: 0 }
    }
    case 'skin':
      return { fill: '#a35fc4', rim: '#ffffff', accent: '#ffffff', pips: 0 }
    default:
      return { fill: '#5d5a6e', rim: '#9b98ad', accent: '#ffffff', pips: 0 }
  }
}

function matFill(category: string): string {
  switch (category) {
    case 'ore': return '#5c5870'
    case 'wood': return '#7a4e2a'
    case 'hide': return '#a0724e'
    case 'monster_part': return '#ece3cf'
    case 'crystal': return '#9b5cff'
    default: return '#b08a2e'
  }
}

export function ItemIcon({ item, size = 36 }: { item: ItemLike; size?: number }) {
  const spec = itemIconSpec(item)
  const gid = `it-${item.id}`
  return (
    <Svg width={size} height={size} viewBox="0 0 40 40" accessibilityLabel={item.id}>
      <Defs>
        <LinearGradient id={gid} x1="0" y1="0" x2="1" y2="1">
          <Stop offset="0" stopColor="#ffffff" stopOpacity={0.2} />
          <Stop offset="0.4" stopColor={spec.fill} stopOpacity={0} />
          <Stop offset="1" stopColor="#000000" stopOpacity={0.3} />
        </LinearGradient>
      </Defs>
      <Rect x={1} y={1} width={38} height={38} rx={9} fill="#1b1830" stroke={spec.rim} strokeWidth={1.5} />
      {shape(item, spec)}
      {/* V3 faceted overlay: bright upper-left, dark lower-right */}
      <Path d="M10 5 L5 20 L20 20z" fill="#ffffff" opacity={0.08} />
      <Path d="M30 35 L35 20 L20 20z" fill="#000000" opacity={0.12} />
      <Rect x={1} y={1} width={38} height={38} rx={9} fill={`url(#${gid})`} />
      {spec.pips > 0 ? pipDots(spec.pips, spec.accent) : null}
    </Svg>
  )
}

function letter(value: string, color = '#fff') {
  return (
    <Text x={20} y={24} fontSize={10} fontWeight="900" fill={color} textAnchor="middle"
      stroke="#0b0a14" strokeWidth={0.4}>
      {value.charAt(0).toUpperCase()}
    </Text>
  )
}

function pipDots(count: number, color: string) {
  return (
    <G>
      {Array.from({ length: count }, (_, i) => (
        <Circle key={i} cx={20 - (count - 1) * 3 + i * 6} cy={36} r={1.6} fill={color} />
      ))}
    </G>
  )
}

function shape(item: ItemLike, spec: ItemIconSpec) {
  switch (item.kind) {
    case 'essence': {
      const c = ELEMENT_COLORS[item.element ?? 'fire']
      return (
        <G>
          <Circle cx={20} cy={20} r={12} fill={c.dark} stroke={c.main} strokeWidth={2} />
          <Path d="M20 10c4 4 6 7 6 10a6 6 0 0 1-12 0c0-3 2-6 6-10z" fill={c.light} />
          <Circle cx={17} cy={17} r={2} fill="#fff" opacity={0.7} />
        </G>
      )
    }
    case 'scroll': {
      const [paper, ribbon] = SCROLL_COLORS[item.pool ?? 'basic'] ?? SCROLL_COLORS.basic!
      return (
        <G>
          <Rect x={9} y={10} width={22} height={20} rx={3} fill={paper} />
          <Rect x={7} y={8} width={26} height={5} rx={2.5} fill={ribbon} />
          <Rect x={7} y={27} width={26} height={5} rx={2.5} fill={ribbon} />
          <Path d="M13 17h14M13 21h10" stroke={ribbon} strokeWidth={1.5} />
          {item.pool === 'mythic' || item.pool === 'light_dark_mythic' ? (
            <Circle cx={27} cy={24} r={3.5} fill="#ffd23f" />
          ) : null}
          {item.pool === 'legendary' ? (
            <Path
              d="M27 20l1.2 2.6 2.8.3-2.1 1.9.6 2.8-2.5-1.4-2.5 1.4.6-2.8-2.1-1.9 2.8-.3z"
              fill="#ffd23f"
            />
          ) : null}
          {item.pool === 'all_attributes' ? (
            <G>
              <Circle cx={24} cy={24} r={2} fill="#ff6b4a" />
              <Circle cx={28} cy={24} r={2} fill="#4ab8ff" />
              <Circle cx={26} cy={20.5} r={2} fill="#ffd23f" />
            </G>
          ) : null}
          {item.pool === 'light_dark' || item.pool === 'light_dark_mythic' ? (
            <Path d="M24 19a4 4 0 1 0 4 5a3 3 0 0 1-4-5z" fill="#ffd23f" />
          ) : null}
        </G>
      )
    }
    case 'grind': {
      const color = SET_COLORS[item.set ?? ''] ?? '#8b95a8'
      return (
        <G>
          <Polygon
            points="8,26 14,12 32,12 26,26"
            fill="#6d6a80"
            stroke={color}
            strokeWidth={1.5}
            strokeLinejoin="round"
          />
          <Polygon points="11,22 15,15 29,15 25,22" fill={color} />
          {letter(item.set ?? '?', '#1b1830')}
          <Path d="M10 30h20" stroke={color} strokeWidth={2} strokeLinecap="round" />
        </G>
      )
    }
    case 'gem': {
      const color = SET_COLORS[item.set ?? ''] ?? '#8b95a8'
      return (
        <G>
          <Polygon
            points="20,7 31,15 27,31 13,31 9,15"
            fill={color}
            stroke="#fff"
            strokeWidth={1.5}
            strokeLinejoin="round"
          />
          <Polygon points="20,7 25,15 20,31 15,15" fill="#ffffff" opacity={0.22} />
          <Polygon points="20,31 27,31 31,15 25,15" fill="#000000" opacity={0.18} />
          {letter(item.set ?? '?')}
        </G>
      )
    }
    case 'material':
      return materialShape(item.category ?? '', spec)
    case 'chest': {
      const [wood, metal] = CHEST_STYLES[Math.min(4, Math.max(1, item.tier ?? 1)) - 1]!
      return (
        <G>
          <Path d="M8 17a12 7 0 0 1 24 0v3H8z" fill={wood} stroke={metal} strokeWidth={1.5} />
          <Rect
            x={8}
            y={19}
            width={24}
            height={13}
            rx={2}
            fill={wood}
            stroke={metal}
            strokeWidth={1.5}
          />
          <Rect x={8} y={18} width={24} height={3} fill={metal} />
          <Rect x={17.5} y={17} width={5} height={7} rx={1} fill={metal} />
          <Circle cx={20} cy={21.5} r={1.2} fill="#2a1a10" />
        </G>
      )
    }
    case 'points': {
      const [main, letterOf] = POINT_STYLES[item.id] ?? ['#8b95a8', '?']
      return (
        <G>
          <Circle cx={20} cy={20} r={13} fill={main} stroke="#fff" strokeWidth={1.5} />
          <Circle cx={20} cy={20} r={9.5} fill="none" stroke="#ffffff" strokeOpacity={0.4} />
          {letter(letterOf)}
        </G>
      )
    }
    case 'skin':
      return (
        <G>
          <Polygon
            points="20,5 33,14 28,33 12,33 7,14"
            fill="#a35fc4"
            stroke="#fff"
            strokeWidth={1.5}
            strokeLinejoin="round"
          />
          <Polygon points="20,10 26,16 23,28 17,28 14,16" fill="#ffffff" opacity={0.22} />
          <Polygon points="23,28 28,33 33,14 26,16" fill="#000000" opacity={0.15} />
        </G>
      )
    default:
      return letter(item.id)
  }
}

/** Chests by tier (bronze, silver, gold, legendary): [wood, metal]. */
const CHEST_STYLES: [string, string][] = [
  ['#7a4e2a', '#c8844a'],
  ['#6b4a35', '#d6dbe4'],
  ['#7a4a1e', '#ffd23f'],
  ['#4b1a8f', '#ff9f3f'],
]

/** Point currencies: [colour, letter]. */
const POINT_STYLES: Record<string, [string, string]> = {
  point_guild: ['#3f7d4f', 'G'],
  point_social: ['#c2558b', 'S'],
  point_arena: ['#b8452f', 'A'],
  point_tower: ['#5a5fc4', 'T'],
  point_cosmetic: ['#a35fc4', 'C'],
}

function materialShape(category: string, spec: ItemIconSpec) {
  const color = spec.rim
  const body =
    category === 'ore' ? (
      <Polygon
        points="9,26 13,13 22,9 31,16 29,28 17,31"
        fill="#5c5870"
        stroke={color}
        strokeWidth={2}
        strokeLinejoin="round"
      />
    ) : category === 'wood' ? (
      <G>
        <Rect
          x={8}
          y={14}
          width={24}
          height={11}
          rx={5.5}
          fill="#7a4e2a"
          stroke={color}
          strokeWidth={2}
        />
        <Circle cx={27} cy={19.5} r={3.5} fill="#c48a4a" />
      </G>
    ) : category === 'hide' ? (
      <Path d="M10 11h20l-3 7 3 12H10l3-12z" fill="#a0724e" stroke={color} strokeWidth={2} />
    ) : category === 'monster_part' ? (
      <Path
        d="M14 8c8 4 14 12 12 24-3-8-8-12-14-14 3-3 3-6 2-10z"
        fill="#ece3cf"
        stroke={color}
        strokeWidth={2}
      />
    ) : category === 'crystal' ? (
      <G>
        <Polygon points="20,6 25,16 20,30 15,16" fill={color} />
        <Polygon points="12,14 15,20 12,29 9,20" fill={color} opacity={0.7} />
        <Polygon points="28,14 31,20 28,29 25,20" fill={color} opacity={0.7} />
        <Polygon points="20,6 22,16 20,30" fill="#ffffff" opacity={0.18} />
      </G>
    ) : (
      <G>
        <Circle cx={20} cy={19} r={11} fill="#b08a2e" stroke={color} strokeWidth={2} />
        <Path d="M20 12l2 5h5l-4 3 2 5-5-3-5 3 2-5-4-3h5z" fill="#ffe08a" />
      </G>
    )
  return <G>{body}</G>
}
