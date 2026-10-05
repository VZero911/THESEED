import type { SkillKind } from '../SkillIcon'
import { particleCap, planFor } from './plan'

const KINDS: SkillKind[] = ['strike', 'area', 'heal', 'buff', 'debuff', 'stun', 'spell']

describe('spell effect plans', () => {
  it('has a plan for every kind of skill, short and bounded', () => {
    for (const kind of KINDS) {
      const plan = planFor(kind)
      expect(plan.particles).toBeGreaterThan(0)
      expect(plan.lifeMs).toBeLessThanOrEqual(1500)
      expect(plan.rings).toBeGreaterThanOrEqual(1)
    }
  })

  it('flies an orb for a single-target attack, not for a zone attack or a heal', () => {
    expect(planFor('strike').projectile).toBe(true)
    expect(planFor('spell').projectile).toBe(true)
    expect(planFor('area').projectile).toBe(false)
    expect(planFor('heal').projectile).toBe(false)
  })

  it('makes heals and buffs rise and debuffs and stuns swirl', () => {
    expect(planFor('heal').rise).toBe(true)
    expect(planFor('buff').rise).toBe(true)
    expect(planFor('stun').swirl).toBe(true)
    expect(planFor('debuff').swirl).toBe(true)
    expect(planFor('strike').rise).toBe(false)
  })

  it('makes a crit bigger, brighter and still under a second and a half', () => {
    const normal = planFor('strike')
    const crit = planFor('strike', true)
    expect(crit.particles).toBeGreaterThan(normal.particles)
    expect(crit.radius).toBeGreaterThan(normal.radius)
    expect(crit.rings).toBe(normal.rings + 1)
    expect(crit.flash).toBe(true)
    expect(crit.lifeMs).toBeLessThanOrEqual(1500)
  })

  it('caps the particles of a cast on many targets', () => {
    const plan = planFor('area')
    expect(particleCap(plan, 1)).toBe(plan.particles)
    expect(particleCap(plan, 4)).toBe(plan.particles * 4)
    expect(particleCap(plan, 99)).toBe(plan.particles * 6)
    expect(particleCap(plan, 0)).toBe(plan.particles)
  })
})
