import {
  ISLAND_RADIUS,
  floatingRocks,
  housePlacements,
  noise2,
  particleBudget,
  rng,
  terrainHeight,
} from './islandData'

describe('island data', () => {
  it('is deterministic for a seed and different for another', () => {
    const a = rng(42)
    const b = rng(42)
    expect([a(), a(), a()]).toEqual([b(), b(), b()])
    expect(rng(1)()).not.toBe(rng(2)())
    for (let i = 0; i < 200; i++) {
      const v = rng(i)()
      expect(v).toBeGreaterThanOrEqual(0)
      expect(v).toBeLessThan(1)
    }
  })

  it('has smooth value noise in [0, 1)', () => {
    for (let i = 0; i < 100; i++) {
      const n = noise2(i * 0.37, i * 0.91, 3)
      expect(n).toBeGreaterThanOrEqual(0)
      expect(n).toBeLessThanOrEqual(1)
    }
    expect(Math.abs(noise2(1.0001, 2, 5) - noise2(1, 2, 5))).toBeLessThan(0.01) // continuous
  })

  it('keeps the grass height small and lower at the rim', () => {
    const centre = terrainHeight(0, 0)
    const rim = terrainHeight(ISLAND_RADIUS, 0)
    expect(Math.abs(centre)).toBeLessThan(0.5)
    expect(rim).toBeLessThan(centre + 0.4)
    expect(terrainHeight(1, 1, 9)).toBe(terrainHeight(1, 1, 9))
  })

  it('places the requested houses apart, off the tree and inside the rim', () => {
    const houses = housePlacements(5)
    expect(houses).toHaveLength(5)
    for (const h of houses) {
      expect(Math.hypot(h.x, h.z)).toBeGreaterThan(1.5) // not on the tree
      expect(Math.hypot(h.x, h.z)).toBeLessThan(ISLAND_RADIUS) // not over the edge
    }
    for (let i = 0; i < houses.length; i++) {
      for (let j = i + 1; j < houses.length; j++) {
        const a = houses[i]
        const b = houses[j]
        expect(Math.hypot((a?.x ?? 0) - (b?.x ?? 0), (a?.z ?? 0) - (b?.z ?? 0))).toBeGreaterThan(
          1.2,
        )
      }
    }
  })

  it('floats rocks around the island, outside it', () => {
    const rocks = floatingRocks(8)
    expect(rocks).toHaveLength(8)
    expect(rocks.every((r) => Math.hypot(r.x, r.z) > ISLAND_RADIUS)).toBe(true)
    expect(rocks.every((r) => r.scale > 0 && r.speed > 0)).toBe(true)
  })

  it('draws fewer particles on a phone and none with reduced motion', () => {
    expect(particleBudget(false, false).embers).toBeGreaterThan(particleBudget(true, false).embers)
    expect(particleBudget(false, true)).toEqual({ embers: 0, rain: 0 })
  })
})
