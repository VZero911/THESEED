/**
 * The numbers behind the 3D Village (V, 2026-10-03: "a moving island, 3D"): a seeded random
 * generator, a smooth height field for the grass, and where the houses and floating rocks go. Pure
 * functions, so the layout is testable without WebGL.
 */

/** A small seeded generator (mulberry32): same seed, same island. */
export function rng(seed: number): () => number {
  let a = seed >>> 0
  return () => {
    a = (a + 0x6d2b79f5) >>> 0
    let t = a
    t = Math.imul(t ^ (t >>> 15), t | 1)
    t ^= t + Math.imul(t ^ (t >>> 7), t | 61)
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296
  }
}

const hash = (x: number, z: number, seed: number): number => {
  const r = rng(Math.imul(x, 73856093) ^ Math.imul(z, 19349663) ^ Math.imul(seed, 83492791))
  return r()
}

const smooth = (t: number) => t * t * (3 - 2 * t)

/** Value noise in [0, 1): smooth between the random values of the integer lattice points. */
export function noise2(x: number, z: number, seed = 1): number {
  const x0 = Math.floor(x)
  const z0 = Math.floor(z)
  const fx = smooth(x - x0)
  const fz = smooth(z - z0)
  const a = hash(x0, z0, seed)
  const b = hash(x0 + 1, z0, seed)
  const c = hash(x0, z0 + 1, seed)
  const d = hash(x0 + 1, z0 + 1, seed)
  return a + (b - a) * fx + (c - a) * fz + (a - b - c + d) * fx * fz
}

export const ISLAND_RADIUS = 4

/** Height of the grass at (x, z): gentle hills, lower toward the edge so the rim reads as a cliff. */
export function terrainHeight(x: number, z: number, seed = 1): number {
  const r = Math.hypot(x, z) / ISLAND_RADIUS
  const hills =
    (noise2(x * 0.7, z * 0.7, seed) - 0.5) * 0.5 + (noise2(x * 1.9, z * 1.9, seed + 7) - 0.5) * 0.12
  const edge = Math.max(0, r - 0.78) * 1.4
  return hills * (1 - Math.min(1, r) * 0.6) - edge * 0.5
}

export interface Placement {
  x: number
  z: number
  /** Rotation around the vertical axis, radians. */
  turn: number
  /** Size factor. */
  scale: number
}

/**
 * Houses on a ring around the seed tree (which stands at the centre): spread out, never on the
 * tree, never on each other, never over the rim.
 */
export function housePlacements(count: number, seed = 1): Placement[] {
  const random = rng(seed + 100)
  const out: Placement[] = []
  const minGap = 1.25
  let guard = 0
  while (out.length < count && guard++ < 500) {
    const angle = random() * Math.PI * 2
    const radius = 1.7 + random() * 1.35 // between the tree and the rim
    const x = Math.cos(angle) * radius
    const z = Math.sin(angle) * radius
    if (out.some((p) => Math.hypot(p.x - x, p.z - z) < minGap)) continue
    out.push({
      x,
      z,
      turn: angle + Math.PI / 2 + (random() - 0.5) * 0.6,
      scale: 0.8 + random() * 0.45,
    })
  }
  return out
}

export interface FloatingRock extends Placement {
  y: number
  /** Orbit speed (radians per second) and bobbing phase. */
  speed: number
  phase: number
}

/** Small rocks drifting around the island, farther out and higher the further they are. */
export function floatingRocks(count: number, seed = 1): FloatingRock[] {
  const random = rng(seed + 200)
  return Array.from({ length: count }, (_, i) => {
    const angle = (i / count) * Math.PI * 2 + random() * 0.8
    const radius = ISLAND_RADIUS + 1.2 + random() * 2.2
    return {
      x: Math.cos(angle) * radius,
      z: Math.sin(angle) * radius,
      y: -0.6 + random() * 2.6,
      turn: random() * Math.PI,
      scale: 0.18 + random() * 0.42,
      speed: 0.04 + random() * 0.06,
      phase: random() * Math.PI * 2,
    }
  })
}

/** How many particles to draw: fewer on a phone, none when motion is reduced. */
export function particleBudget(low: boolean, reduced: boolean): { embers: number; rain: number } {
  if (reduced) return { embers: 0, rain: 0 }
  return low ? { embers: 60, rain: 40 } : { embers: 220, rain: 160 }
}
