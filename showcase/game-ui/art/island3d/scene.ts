/**
 * The 3D Village (V, 2026-10-03: "an island that moves, 3D"): a floating island under a torn red
 * sky, the seed tree glowing in the middle, houses with lit windows, waterfalls pouring into the
 * void, rocks drifting around it and, behind, the huge dark tower with its red eye, struck by
 * lightning. three.js, low-poly with flat shading: light enough for a laptop, with a low-power mode
 * for phones. The scene only knows a canvas; the screen decides when to create and dispose it.
 */
import {
  AdditiveBlending,
  AmbientLight,
  BoxGeometry,
  BufferAttribute,
  BufferGeometry,
  Color,
  ConeGeometry,
  CylinderGeometry,
  DirectionalLight,
  Fog,
  Group,
  IcosahedronGeometry,
  Mesh,
  MeshBasicMaterial,
  MeshStandardMaterial,
  PerspectiveCamera,
  PointLight,
  Points,
  PointsMaterial,
  Scene,
  SphereGeometry,
  WebGLRenderer,
} from 'three'
import {
  ISLAND_RADIUS,
  floatingRocks,
  housePlacements,
  particleBudget,
  rng,
  terrainHeight,
} from './islandData'

export interface IslandOptions {
  /** Fewer particles, no antialiasing, a lower pixel ratio (phones, weak GPUs). */
  low?: boolean
  /** Draw one still frame and stop (reduced motion). */
  reduced?: boolean
  seed?: number
}

export interface IslandHandle {
  /** The canvas size changed. */
  resize: () => void
  /** Pause or resume the animation (the page is hidden or the canvas is off screen). */
  setActive: (on: boolean) => void
  /** The pointer moved over the canvas, in -1..1 on both axes (a little parallax). */
  look: (x: number, y: number) => void
  /** Free every GPU resource. */
  dispose: () => void
}

const flat = (
  color: number,
  extra: Partial<ConstructorParameters<typeof MeshStandardMaterial>[0]> = {},
) =>
  new MeshStandardMaterial({ color, flatShading: true, roughness: 0.9, metalness: 0.05, ...extra })

/** The grass: a disc whose vertices follow the height field, with the rim sloping down. */
function grassGeometry(seed: number): BufferGeometry {
  const geometry = new CylinderGeometry(ISLAND_RADIUS, ISLAND_RADIUS * 0.86, 0.7, 56, 8, false)
  const position = geometry.getAttribute('position') as BufferAttribute
  for (let i = 0; i < position.count; i++) {
    const x = position.getX(i)
    const z = position.getZ(i)
    if (position.getY(i) > 0.2) position.setY(i, 0.35 + terrainHeight(x, z, seed))
  }
  geometry.computeVertexNormals()
  return geometry
}

/** The rock under the island: an inverted jagged cone. */
function rockGeometry(seed: number): BufferGeometry {
  const geometry = new ConeGeometry(ISLAND_RADIUS * 0.86, 5.2, 9, 5, true)
  const random = rng(seed + 31)
  const position = geometry.getAttribute('position') as BufferAttribute
  for (let i = 0; i < position.count; i++) {
    const y = position.getY(i)
    const k = 0.78 + random() * 0.34
    position.setXYZ(i, position.getX(i) * k, y + (random() - 0.5) * 0.25, position.getZ(i) * k)
  }
  geometry.rotateX(Math.PI)
  geometry.translate(0, -2.85, 0)
  geometry.computeVertexNormals()
  return geometry
}

function addTree(island: Group, seed: number): PointLight {
  const tree = new Group()
  const trunk = new Mesh(new CylinderGeometry(0.18, 0.3, 1.8, 7), flat(0x4a3322))
  trunk.position.y = 0.9
  tree.add(trunk)
  const leaves = flat(0x4fd08a, { emissive: 0x1d6b44, emissiveIntensity: 0.55 })
  for (const [x, y, z, r] of [
    [0, 2.3, 0, 1.0],
    [0.7, 1.9, 0.2, 0.75],
    [-0.65, 1.95, -0.2, 0.8],
    [0.1, 2.9, 0.1, 0.65],
  ] as const) {
    const ball = new Mesh(new IcosahedronGeometry(r, 1), leaves)
    ball.position.set(x, y, z)
    tree.add(ball)
  }
  const core = new Mesh(new SphereGeometry(0.2, 12, 12), new MeshBasicMaterial({ color: 0xfff1b5 }))
  core.position.y = 2.35
  tree.add(core)
  tree.position.y = 0.35 + terrainHeight(0, 0, seed)
  island.add(tree)
  const glow = new PointLight(0xffe29a, 6, 9, 1.6)
  glow.position.set(0, 3.1, 0)
  island.add(glow)
  return glow
}

function addHouses(island: Group, seed: number): MeshStandardMaterial[] {
  const windows: MeshStandardMaterial[] = []
  const walls = [0x5b4a8a, 0x6a5598, 0x4d3f78]
  housePlacements(5, seed).forEach((p, i) => {
    const house = new Group()
    const body = new Mesh(new BoxGeometry(0.9, 0.7, 0.8), flat(walls[i % walls.length] ?? 0x5b4a8a))
    body.position.y = 0.35
    const roof = new Mesh(new ConeGeometry(0.78, 0.55, 4), flat(0x9a4b3a))
    roof.position.y = 0.97
    roof.rotation.y = Math.PI / 4
    const lit = new MeshStandardMaterial({
      color: 0x2a2113,
      emissive: 0xffc15e,
      emissiveIntensity: 1.6,
    })
    windows.push(lit)
    const door = new Mesh(new BoxGeometry(0.22, 0.3, 0.05), lit)
    door.position.set(0, 0.2, 0.41)
    const win = new Mesh(new BoxGeometry(0.2, 0.18, 0.05), lit)
    win.position.set(0.28, 0.45, 0.41)
    house.add(body, roof, door, win)
    house.position.set(p.x, 0.35 + terrainHeight(p.x, p.z, seed) + 0.02, p.z)
    house.rotation.y = p.turn
    house.scale.setScalar(p.scale)
    island.add(house)
  })
  return windows
}

function addTower(scene: Scene): { eye: Mesh; light: PointLight } {
  const tower = new Group()
  const dark = flat(0x120d1f, { roughness: 0.7 })
  let y = 0
  for (const [w, h] of [
    [3.4, 5],
    [2.8, 5],
    [2.2, 5],
    [1.6, 4],
    [1.0, 3],
  ] as const) {
    const tier = new Mesh(new CylinderGeometry(w * 0.82, w, h, 6), dark)
    tier.position.y = y + h / 2
    tower.add(tier)
    y += h
  }
  const spire = new Mesh(new ConeGeometry(0.7, 3.2, 6), dark)
  spire.position.y = y + 1.6
  tower.add(spire)
  const eye = new Mesh(new SphereGeometry(0.34, 16, 16), new MeshBasicMaterial({ color: 0xff3b30 }))
  eye.position.set(0, 16, 1.55)
  tower.add(eye)
  const light = new PointLight(0xff3b30, 18, 26, 1.7)
  light.position.set(0, 16, 3)
  tower.add(light)
  tower.position.set(7.5, -14.5, -13)
  tower.rotation.z = -0.07
  scene.add(tower)
  return { eye, light }
}

function pointCloud(count: number, spread: [number, number, number], color: number, size: number) {
  const geometry = new BufferGeometry()
  const positions = new Float32Array(count * 3)
  const random = rng(count + 7)
  for (let i = 0; i < count; i++) {
    positions[i * 3] = (random() - 0.5) * spread[0]
    positions[i * 3 + 1] = random() * spread[1] - 4
    positions[i * 3 + 2] = (random() - 0.5) * spread[2]
  }
  geometry.setAttribute('position', new BufferAttribute(positions, 3))
  const material = new PointsMaterial({
    color,
    size,
    transparent: true,
    opacity: 0.85,
    blending: AdditiveBlending,
    depthWrite: false,
  })
  return { points: new Points(geometry, material), positions }
}

export function createIslandScene(
  canvas: HTMLCanvasElement,
  options: IslandOptions = {},
): IslandHandle {
  const seed = options.seed ?? 7
  const low = options.low ?? false
  const reduced = options.reduced ?? false
  const renderer = new WebGLRenderer({
    canvas,
    antialias: !low,
    alpha: false,
    powerPreference: 'default',
  })
  const sky = new Color(0x1a0d24)
  renderer.setClearColor(sky)
  const scene = new Scene()
  scene.fog = new Fog(0x2a1020, 34, 95)
  const camera = new PerspectiveCamera(38, 1, 0.1, 200)
  camera.position.set(0, 3.2, 13.5)
  camera.lookAt(0, 0.4, 0)

  scene.add(new AmbientLight(0x8a78c0, 1.25))
  const moon = new DirectionalLight(0xffc4a8, 2.1)
  moon.position.set(-8, 12, 10)
  scene.add(moon)

  // The sky: a huge back-faced sphere tinted from deep violet to the red of the torn horizon.
  const dome = new Mesh(
    new SphereGeometry(90, 24, 16),
    new MeshBasicMaterial({ vertexColors: true, side: 1, fog: false }),
  )
  const domePos = dome.geometry.getAttribute('position') as BufferAttribute
  const colors = new Float32Array(domePos.count * 3)
  const top = new Color(0x1d0d33)
  const horizon = new Color(0xa3303a)
  const mix = new Color()
  for (let i = 0; i < domePos.count; i++) {
    const t = Math.min(1, Math.max(0, domePos.getY(i) / 90 + 0.1))
    mix.copy(horizon).lerp(top, Math.pow(t, 0.55))
    colors.set([mix.r, mix.g, mix.b], i * 3)
  }
  dome.geometry.setAttribute('color', new BufferAttribute(colors, 3))
  scene.add(dome)

  const island = new Group()
  island.add(new Mesh(grassGeometry(seed), flat(0x3fae72)))
  island.add(new Mesh(rockGeometry(seed), flat(0x4a3a5c, { side: 2 })))
  const treeGlow = addTree(island, seed)
  const windows = addHouses(island, seed)
  scene.add(island)

  const rocks = new Group()
  const rockData = floatingRocks(low ? 5 : 9, seed)
  const rockMeshes = rockData.map((r) => {
    const m = new Mesh(new IcosahedronGeometry(1, 0), flat(0x3d3050))
    m.scale.setScalar(r.scale)
    m.position.set(r.x, r.y, r.z)
    rocks.add(m)
    return m
  })
  scene.add(rocks)

  const { eye, light: eyeLight } = addTower(scene)
  const budget = particleBudget(low, reduced)
  const embers = budget.embers > 0 ? pointCloud(budget.embers, [18, 14, 12], 0xffa24a, 0.07) : null
  const rain = budget.rain > 0 ? pointCloud(budget.rain, [1.2, 7, 1.2], 0x9fe3ff, 0.06) : null
  if (embers) scene.add(embers.points)
  if (rain) {
    rain.points.position.set(-1.6, -3, 3.6)
    scene.add(rain.points)
  }

  const lightning = new PointLight(0xc9d6ff, 0, 80, 1.2)
  lightning.position.set(-6, 14, -8)
  scene.add(lightning)

  let width = 1
  let height = 1
  const resize = () => {
    const w = Math.max(1, canvas.clientWidth)
    const h = Math.max(1, canvas.clientHeight)
    if (w === width && h === height) return
    width = w
    height = h
    renderer.setPixelRatio(Math.min(low ? 1.25 : 2, globalThis.devicePixelRatio || 1))
    renderer.setSize(w, h, false)
    camera.aspect = w / h
    camera.position.z = w / h < 1.3 ? 18 : 13.5
    camera.updateProjectionMatrix()
  }
  resize()

  let look = { x: 0, y: 0 }
  let smooth = { x: 0, y: 0 }
  let nextBolt = 2.5
  let boltEnds = 0
  let active = !reduced
  let frame = 0
  let last = performance.now()
  let clock = 0

  const draw = (dt: number) => {
    clock += dt
    smooth = { x: smooth.x + (look.x - smooth.x) * 0.05, y: smooth.y + (look.y - smooth.y) * 0.05 }
    island.position.y = Math.sin(clock * 0.8) * 0.18
    island.rotation.y = Math.sin(clock * 0.15) * 0.12 + smooth.x * 0.12
    island.rotation.z = Math.sin(clock * 0.6) * 0.012
    treeGlow.intensity = 5.5 + Math.sin(clock * 2.1) * 1.1
    windows.forEach((m, i) => {
      m.emissiveIntensity = 1 + Math.sin(clock * 3 + i * 1.7) * 0.18
    })
    rockMeshes.forEach((m, i) => {
      const r = rockData[i]
      if (!r) return
      const a = Math.atan2(r.z, r.x) + clock * r.speed
      const radius = Math.hypot(r.x, r.z)
      m.position.set(
        Math.cos(a) * radius,
        r.y + Math.sin(clock * 0.9 + r.phase) * 0.35,
        Math.sin(a) * radius,
      )
      m.rotation.x += dt * 0.25
      m.rotation.y += dt * 0.18
    })
    eyeLight.intensity = 16 + Math.sin(clock * 1.3) * 5
    ;(eye.material as MeshBasicMaterial).color.setHSL(0.0, 1, 0.5 + Math.sin(clock * 1.3) * 0.08)
    if (embers) {
      const p = embers.positions
      for (let i = 0; i < p.length; i += 3) {
        p[i + 1] = (p[i + 1] ?? 0) + dt * (0.35 + ((i / 3) % 5) * 0.08)
        p[i] = (p[i] ?? 0) + Math.sin(clock + i) * dt * 0.1
        if ((p[i + 1] ?? 0) > 10) p[i + 1] = -4
      }
      embers.points.geometry.getAttribute('position').needsUpdate = true
    }
    if (rain) {
      const p = rain.positions
      for (let i = 0; i < p.length; i += 3) {
        p[i + 1] = (p[i + 1] ?? 0) - dt * (2.2 + ((i / 3) % 4) * 0.5)
        if ((p[i + 1] ?? 0) < -4) p[i + 1] = 3
      }
      rain.points.geometry.getAttribute('position').needsUpdate = true
    }
    if (clock > nextBolt) {
      boltEnds = clock + 0.28
      nextBolt = clock + 3 + Math.random() * 5
    }
    const flashing = clock < boltEnds
    lightning.intensity = flashing ? 90 * (0.4 + Math.random() * 0.6) : 0
    camera.position.x = smooth.x * 1.1
    camera.position.y = 3.2 - smooth.y * 0.6
    camera.lookAt(0, 0.4, 0)
    renderer.render(scene, camera)
  }

  const loop = (now: number) => {
    frame = requestAnimationFrame(loop)
    const dt = Math.min(0.05, (now - last) / 1000)
    last = now
    draw(dt)
  }
  if (active) frame = requestAnimationFrame(loop)
  else draw(0)

  return {
    resize: () => {
      resize()
      if (!active) draw(0)
    },
    setActive: (on) => {
      if (reduced || on === active) return
      active = on
      cancelAnimationFrame(frame)
      if (on) {
        last = performance.now()
        frame = requestAnimationFrame(loop)
      }
    },
    look: (x, y) => {
      look = { x, y }
    },
    dispose: () => {
      cancelAnimationFrame(frame)
      scene.traverse((object) => {
        const mesh = object as Mesh
        mesh.geometry?.dispose()
        const material = mesh.material
        if (Array.isArray(material)) material.forEach((m) => m.dispose())
        else material?.dispose()
      })
      renderer.dispose()
    },
  }
}
