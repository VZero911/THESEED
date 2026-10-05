import { itemIconSpec, type ItemLike } from './ItemIcon'
import { ELEMENT_COLORS, SCROLL_COLORS, SET_COLORS, TIER_COLORS } from './palette'

describe('itemIconSpec', () => {
  it('colours essence by element', () => {
    const fire = itemIconSpec({ id: 'ess_fire', kind: 'essence', element: 'fire' })
    expect(fire.fill).toBe(ELEMENT_COLORS.fire.dark)
    expect(fire.rim).toBe(ELEMENT_COLORS.fire.main)
    expect(fire.accent).toBe(ELEMENT_COLORS.fire.light)
  })

  it('falls back to unknown element for essence', () => {
    const spec = itemIconSpec({ id: 'ess', kind: 'essence' })
    expect(spec.fill).toBe(ELEMENT_COLORS.unknown.dark)
  })

  it('colours scroll by pool', () => {
    const mythic = itemIconSpec({ id: 'sc_m', kind: 'scroll', pool: 'mythic' })
    const [paper, ribbon] = SCROLL_COLORS.mythic!
    expect(mythic.fill).toBe(paper)
    expect(mythic.rim).toBe(ribbon)
  })

  it('falls back to basic scroll', () => {
    const spec = itemIconSpec({ id: 'sc', kind: 'scroll', pool: 'nope' })
    expect(spec.fill).toBe(SCROLL_COLORS.basic![0])
  })

  it('colours grind by rune set', () => {
    const spec = itemIconSpec({ id: 'gr', kind: 'grind', set: 'fureur' })
    expect(spec.rim).toBe(SET_COLORS.fureur)
  })

  it('colours gem by rune set with white rim', () => {
    const spec = itemIconSpec({ id: 'gm', kind: 'gem', set: 'lame' })
    expect(spec.fill).toBe(SET_COLORS.lame)
    expect(spec.rim).toBe('#ffffff')
  })

  it('colours material by tier with pips', () => {
    for (let tier = 1; tier <= 5; tier++) {
      const spec = itemIconSpec({ id: `mat_${tier}`, kind: 'material', tier, category: 'ore' })
      expect(spec.rim).toBe(TIER_COLORS[tier - 1])
      expect(spec.pips).toBe(tier)
    }
  })

  it('clamps material tier to 1-5', () => {
    expect(itemIconSpec({ id: 'm', kind: 'material', tier: 0 }).pips).toBe(1)
    expect(itemIconSpec({ id: 'm', kind: 'material', tier: 99 }).pips).toBe(5)
  })

  it('fills material by category', () => {
    const ore = itemIconSpec({ id: 'm', kind: 'material', tier: 1, category: 'ore' })
    const wood = itemIconSpec({ id: 'm', kind: 'material', tier: 1, category: 'wood' })
    expect(ore.fill).not.toBe(wood.fill)
  })

  it('gives chest a style by tier', () => {
    const t1 = itemIconSpec({ id: 'c1', kind: 'chest', tier: 1 })
    const t4 = itemIconSpec({ id: 'c4', kind: 'chest', tier: 4 })
    expect(t1.rim).not.toBe(t4.rim)
  })

  it('gives points a white rim', () => {
    const spec = itemIconSpec({ id: 'point_arena', kind: 'points' })
    expect(spec.rim).toBe('#ffffff')
    expect(spec.fill).toBe('#b8452f')
  })

  it('gives skin a purple fill', () => {
    const spec = itemIconSpec({ id: 's', kind: 'skin' })
    expect(spec.fill).toBe('#a35fc4')
  })

  it('gives unknown kinds a grey default', () => {
    const spec = itemIconSpec({ id: 'x', kind: 'whatever' })
    expect(spec.fill).toBe('#5d5a6e')
    expect(spec.pips).toBe(0)
  })

  it('no kind produces pips except material', () => {
    const kinds: ItemLike[] = [
      { id: 'a', kind: 'essence', element: 'fire' },
      { id: 'b', kind: 'scroll', pool: 'basic' },
      { id: 'c', kind: 'grind', set: 'fureur' },
      { id: 'd', kind: 'gem', set: 'lame' },
      { id: 'e', kind: 'chest', tier: 2 },
      { id: 'f', kind: 'points' },
      { id: 'g', kind: 'skin' },
    ]
    for (const item of kinds) {
      expect(itemIconSpec(item).pips).toBe(0)
    }
  })
})
