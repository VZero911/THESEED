import { runeGemSpec } from './RuneGem'

describe('runeGemSpec', () => {
  it('gives each slot its own outline and falls back to the neutral cut', () => {
    const outlines = [1, 2, 3, 4, 5, 6, 7].map((s) => runeGemSpec(s, 'fureur', 'rare', 5).points)
    expect(new Set(outlines).size).toBe(7)
    expect(runeGemSpec(99, 'fureur', 'rare', 5).points).toBe(outlines[6])
  })
  it('colours by set and rim by rarity, with a safe default', () => {
    expect(runeGemSpec(1, 'fureur', 'mythic', 6)).toMatchObject({
      color: '#ff5a4f',
      rim: '#ef5d6c',
    })
    expect(runeGemSpec(1, 'nope', 'weird', 1)).toMatchObject({ color: '#8b8a99', rim: '#c9c6d8' })
  })
  it('glows only for legendary and mythic, and bounds the pips', () => {
    expect(runeGemSpec(1, 'lame', 'legendary', 6).glow).toBe(true)
    expect(runeGemSpec(1, 'lame', 'heroic', 6).glow).toBe(false)
    expect(runeGemSpec(1, 'lame', 'rare', 9).pips).toBe(6)
    expect(runeGemSpec(1, 'lame', 'rare', -2).pips).toBe(0)
  })
})
