/**
 * The 3D spell layer of the battle (V, 2026-10-03): a transparent canvas over the arena where each
 * skill plays its effect (`plan.ts`): a glowing orb from the caster, bursts, shockwave rings,
 * rising motes for heals, swirls for debuffs, all in the caster's element colour and additive
 * blended. Pixel space (orthographic camera), so positions are the cards' own screen rectangles.
 */
import {
  AdditiveBlending,
  BufferAttribute,
  BufferGeometry,
  Color,
  DoubleSide,
  Mesh,
  MeshBasicMaterial,
  OrthographicCamera,
  Points,
  PointsMaterial,
  RingGeometry,
  Scene,
  SphereGeometry,
  WebGLRenderer,
} from 'three'
import type { SkillKind } from '../SkillIcon'
import { particleCap, planFor, type FxPlan } from './plan'

export interface Point {
  x: number
  y: number
}

export interface Cast {
  from: Point
  to: Point[]
  /** The caster's element colour, "#rrggbb". */
  color: string
  kind: SkillKind
  crit?: boolean
}

export interface SpellFxHandle {
  resize: () => void
  cast: (cast: Cast) => void
  dispose: () => void
}

interface Live {
  plan: FxPlan
  cast: Cast
  born: number
  group: Mesh[]
  points: Points
  positions: Float32Array
  velocities: Float32Array
  orbs: Mesh[]
  rings: Mesh[]
}

const easeOut = (t: number) => 1 - Math.pow(1 - t, 3)
const easeInOut = (t: number) => (t < 0.5 ? 2 * t * t : 1 - Math.pow(-2 * t + 2, 2) / 2)

export function createSpellFx(canvas: HTMLCanvasElement, low = false): SpellFxHandle {
  const renderer = new WebGLRenderer({ canvas, alpha: true, antialias: !low })
  renderer.setClearColor(0x000000, 0)
  const scene = new Scene()
  const camera = new OrthographicCamera(0, 1, 1, 0, -10, 10)
  const lives: Live[] = []
  let frame = 0
  let running = false

  const resize = () => {
    const w = Math.max(1, canvas.clientWidth)
    const h = Math.max(1, canvas.clientHeight)
    renderer.setPixelRatio(Math.min(low ? 1.25 : 2, globalThis.devicePixelRatio || 1))
    renderer.setSize(w, h, false)
    camera.left = 0
    camera.right = w
    camera.top = 0
    camera.bottom = h
    camera.updateProjectionMatrix()
  }
  resize()

  const finish = (live: Live) => {
    for (const m of [...live.orbs, ...live.rings]) {
      scene.remove(m)
      m.geometry.dispose()
      ;(m.material as MeshBasicMaterial).dispose()
    }
    scene.remove(live.points)
    live.points.geometry.dispose()
    ;(live.points.material as PointsMaterial).dispose()
  }

  const tick = (now: number) => {
    frame = requestAnimationFrame(tick)
    for (let i = lives.length - 1; i >= 0; i--) {
      const live = lives[i]
      if (!live) continue
      const age = now - live.born
      if (age > live.plan.lifeMs) {
        finish(live)
        lives.splice(i, 1)
        continue
      }
      const { plan, cast } = live
      const burstAt = plan.projectile ? plan.flightMs : 0
      // Orbs: fly from the caster to their target, then vanish in the burst.
      live.orbs.forEach((orb, k) => {
        const target = cast.to[k]
        if (!target) return
        const t = Math.min(1, age / Math.max(1, plan.flightMs))
        const e = easeInOut(t)
        orb.visible = age < burstAt
        orb.position.set(
          cast.from.x + (target.x - cast.from.x) * e,
          cast.from.y + (target.y - cast.from.y) * e - Math.sin(t * Math.PI) * 26,
          1,
        )
        orb.scale.setScalar(1 + Math.sin(age * 0.03) * 0.15)
      })
      // Rings: expand and fade after the burst begins.
      live.rings.forEach((ring, k) => {
        const since = age - burstAt - Math.floor(k / Math.max(1, cast.to.length)) * 110
        const material = ring.material as MeshBasicMaterial
        if (since < 0) {
          ring.visible = false
          return
        }
        ring.visible = true
        const t = Math.min(1, since / 520)
        ring.scale.setScalar(1 + easeOut(t) * plan.radius * 0.5)
        material.opacity = (1 - t) * 0.9
      })
      // Particles: wait for the burst, then fly out, rise or swirl.
      const sinceBurst = age - burstAt
      const material = live.points.material as PointsMaterial
      if (sinceBurst < 0) {
        material.opacity = 0
      } else {
        const t = sinceBurst / Math.max(1, plan.lifeMs - burstAt)
        material.opacity = Math.max(0, 1 - t) * (plan.flash && sinceBurst < 90 ? 1.2 : 0.95)
        material.size = (low ? 5 : 7) * (1 - t * 0.5)
        const p = live.positions
        const v = live.velocities
        const per = plan.particles
        for (let n = 0; n < p.length / 3; n++) {
          const target = cast.to[Math.floor(n / per)]
          if (!target) continue
          const local = n % per
          const angle = (local / per) * Math.PI * 2 + (v[n * 3] ?? 0)
          const speed = 0.35 + (v[n * 3 + 1] ?? 0) * 0.65
          const dist = easeOut(Math.min(1, sinceBurst / 700)) * plan.radius * speed
          if (plan.rise) {
            p[n * 3] = target.x + Math.cos(angle) * plan.radius * 0.45 * speed
            p[n * 3 + 1] =
              target.y +
              30 -
              easeOut(Math.min(1, sinceBurst / 900)) * (plan.radius + 40) * (0.4 + speed)
          } else if (plan.swirl) {
            const turn = angle + sinceBurst * 0.006 * (1 + speed)
            p[n * 3] = target.x + Math.cos(turn) * plan.radius * 0.7 * speed
            p[n * 3 + 1] =
              target.y + Math.sin(turn) * plan.radius * 0.45 * speed - sinceBurst * 0.03
          } else {
            p[n * 3] = target.x + Math.cos(angle) * dist
            p[n * 3 + 1] = target.y + Math.sin(angle) * dist * 0.8 + sinceBurst * 0.02
          }
          p[n * 3 + 2] = 0.5
        }
        live.points.geometry.getAttribute('position').needsUpdate = true
      }
    }
    renderer.render(scene, camera)
    if (lives.length === 0) {
      cancelAnimationFrame(frame)
      running = false
      renderer.clear()
    }
  }

  const cast = (c: Cast) => {
    const plan = planFor(c.kind, c.crit)
    const color = new Color(c.color)
    const total = particleCap(plan, c.to.length)
    const targets = c.to.slice(0, 6)
    const positions = new Float32Array(total * 3)
    const velocities = new Float32Array(total * 3)
    for (let i = 0; i < velocities.length; i += 3) {
      velocities[i] = Math.random() * 0.6
      velocities[i + 1] = Math.random()
    }
    const geometry = new BufferGeometry()
    geometry.setAttribute('position', new BufferAttribute(positions, 3))
    const points = new Points(
      geometry,
      new PointsMaterial({
        color,
        size: 7,
        transparent: true,
        opacity: 0,
        blending: AdditiveBlending,
        depthWrite: false,
        sizeAttenuation: false,
      }),
    )
    points.frustumCulled = false
    scene.add(points)
    const orbs: Mesh[] = plan.projectile
      ? targets.map(() => {
          const orb = new Mesh(
            new SphereGeometry(9, 12, 12),
            new MeshBasicMaterial({
              color,
              transparent: true,
              opacity: 0.95,
              blending: AdditiveBlending,
            }),
          )
          scene.add(orb)
          return orb
        })
      : []
    const rings: Mesh[] = []
    for (let r = 0; r < plan.rings; r++) {
      for (let t = 0; t < targets.length; t++) {
        const ring = new Mesh(
          new RingGeometry(0.9, 1.1, 40),
          new MeshBasicMaterial({
            color: plan.flash ? new Color(c.color).lerp(new Color(0xffffff), 0.35) : color,
            transparent: true,
            opacity: 0,
            blending: AdditiveBlending,
            side: DoubleSide,
            depthWrite: false,
          }),
        )
        ring.visible = false
        scene.add(ring)
        rings.push(ring)
      }
    }
    // Rings sit on their targets (set once).
    rings.forEach((ring, i) => {
      const target = targets[i % targets.length]
      if (target) ring.position.set(target.x, target.y, 0.8)
    })
    lives.push({
      plan,
      cast: { ...c, to: targets },
      born: performance.now(),
      group: [],
      points,
      positions,
      velocities,
      orbs,
      rings,
    })
    if (!running) {
      running = true
      frame = requestAnimationFrame(tick)
    }
  }

  return {
    resize,
    cast,
    dispose: () => {
      cancelAnimationFrame(frame)
      lives.forEach(finish)
      lives.length = 0
      renderer.dispose()
    },
  }
}
