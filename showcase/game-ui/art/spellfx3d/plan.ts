/**
 * What a spell looks like in 3D (V, 2026-10-03: "3D spell animations"): from the kind of skill, its
 * element and whether it crit, a plan the three.js layer plays. Pure data, so it is testable.
 */
import type { SkillKind } from '../SkillIcon'

export interface FxPlan {
  /** A glowing orb flies from the caster to each target first. */
  projectile: boolean
  /** Flight time of the orb, ms. */
  flightMs: number
  /** Particles of the burst on each target. */
  particles: number
  /** Burst radius in pixels. */
  radius: number
  /** Shockwave rings on each target. */
  rings: number
  /** Particles rise (heal, buff) instead of flying out. */
  rise: boolean
  /** Particles turn around the target (stun, debuff). */
  swirl: boolean
  /** A white flash on the impact. */
  flash: boolean
  /** Total life of the effect, ms. */
  lifeMs: number
}

const BASE: Record<SkillKind, Omit<FxPlan, 'lifeMs'>> = {
  strike: {
    projectile: true,
    flightMs: 260,
    particles: 34,
    radius: 70,
    rings: 1,
    rise: false,
    swirl: false,
    flash: true,
  },
  spell: {
    projectile: true,
    flightMs: 340,
    particles: 46,
    radius: 84,
    rings: 1,
    rise: false,
    swirl: false,
    flash: true,
  },
  area: {
    projectile: false,
    flightMs: 0,
    particles: 56,
    radius: 120,
    rings: 2,
    rise: false,
    swirl: false,
    flash: true,
  },
  heal: {
    projectile: false,
    flightMs: 0,
    particles: 40,
    radius: 60,
    rings: 1,
    rise: true,
    swirl: false,
    flash: false,
  },
  buff: {
    projectile: false,
    flightMs: 0,
    particles: 32,
    radius: 66,
    rings: 2,
    rise: true,
    swirl: false,
    flash: false,
  },
  debuff: {
    projectile: true,
    flightMs: 300,
    particles: 30,
    radius: 66,
    rings: 1,
    rise: false,
    swirl: true,
    flash: false,
  },
  stun: {
    projectile: true,
    flightMs: 240,
    particles: 26,
    radius: 62,
    rings: 1,
    rise: false,
    swirl: true,
    flash: true,
  },
}

/** The plan of a spell; a crit is bigger and brighter, never longer than a second and a half. */
export function planFor(kind: SkillKind, crit = false): FxPlan {
  const base = BASE[kind]
  const scale = crit ? 1.5 : 1
  const plan = {
    ...base,
    particles: Math.round(base.particles * scale),
    radius: Math.round(base.radius * (crit ? 1.35 : 1)),
    rings: base.rings + (crit ? 1 : 0),
    flash: base.flash || crit,
  }
  return { ...plan, lifeMs: Math.min(1500, plan.flightMs + 900) }
}

/** The number of three.js objects an effect may hold at most: a cast on 5 targets stays cheap. */
export function particleCap(plan: FxPlan, targets: number): number {
  return plan.particles * Math.max(1, Math.min(targets, 6))
}
