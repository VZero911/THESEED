import {
  skillIconSpec,
  skillKindOf,
  actionKindOf,
  type SkillKind,
} from './SkillIcon'
import { ELEMENT_COLORS } from './palette'

describe('skillIconSpec', () => {
  it('frames by element colours', () => {
    const spec = skillIconSpec('strike', 'fire')
    expect(spec.frameDark).toBe(ELEMENT_COLORS.fire.dark)
    expect(spec.frameMain).toBe(ELEMENT_COLORS.fire.main)
    expect(spec.frameGlow).toBe(ELEMENT_COLORS.fire.glow)
  })

  it('gives each kind a distinct glyph', () => {
    const kinds: SkillKind[] = ['strike', 'area', 'heal', 'buff', 'debuff', 'stun', 'spell']
    const glyphs = kinds.map((k) => skillIconSpec(k, 'water').glyph)
    expect(new Set(glyphs).size).toBe(7)
  })

  it('gives each kind a tint (some may share)', () => {
    const kinds: SkillKind[] = ['strike', 'area', 'heal', 'buff', 'debuff', 'stun', 'spell']
    for (const k of kinds) {
      expect(skillIconSpec(k, 'wind').tint).toBeTruthy()
    }
  })

  it('works for every element', () => {
    for (const el of Object.keys(ELEMENT_COLORS)) {
      const spec = skillIconSpec('strike', el as any)
      expect(spec.frameDark).toBeTruthy()
    }
  })
})

describe('skillKindOf', () => {
  it('detects stun from stun_chance', () => {
    expect(skillKindOf({ stun_chance: 50 })).toBe('stun')
  })
  it('detects heal from heal amount', () => {
    expect(skillKindOf({ heal: 100 })).toBe('heal')
  })
  it('detects buff from ally target with buff effects', () => {
    expect(skillKindOf({ target: 'ally', effects: [{ effect: 'atk_up' }] })).toBe('buff')
  })
  it('detects area from all_enemies target', () => {
    expect(skillKindOf({ target: 'all_enemies' })).toBe('area')
  })
  it('detects debuff from down effects', () => {
    expect(skillKindOf({ effects: [{ effect: 'def_down' }] })).toBe('debuff')
  })
  it('defaults slot 1 to strike', () => {
    expect(skillKindOf({ slot: 1 })).toBe('strike')
  })
  it('defaults other slots to spell', () => {
    expect(skillKindOf({ slot: 3 })).toBe('spell')
  })
})

describe('actionKindOf', () => {
  const base = { hits: [], heals: [], effects: [] as any[], skill: 'atk_1' }

  it('detects stun from effects', () => {
    expect(actionKindOf({ ...base, effects: [{ effect: 'stun' }] })).toBe('stun')
  })
  it('detects heal from heals only', () => {
    expect(actionKindOf({ ...base, heals: [1], skill: 'heal_2' })).toBe('heal')
  })
  it('detects area from multiple hits', () => {
    expect(actionKindOf({ ...base, hits: [1, 2, 3] })).toBe('area')
  })
  it('detects debuff from down effects', () => {
    expect(actionKindOf({ ...base, hits: [1], effects: [{ effect: 'spd_down' }] })).toBe('debuff')
  })
  it('defaults _1 skills to strike', () => {
    expect(actionKindOf({ ...base, hits: [1], skill: 'flame_1' })).toBe('strike')
  })
  it('defaults non-_1 skills to spell', () => {
    expect(actionKindOf({ ...base, hits: [1], skill: 'flame_3' })).toBe('spell')
  })
})
