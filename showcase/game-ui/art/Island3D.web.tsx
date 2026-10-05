/**
 * The Village in 3D on the web (V, 2026-10-03): the island, the tree, the houses, the tower and the
 * lightning of `island3d/scene.ts`, drawn on a canvas. The scene loads on demand (three.js is not
 * in the first bundle), pauses when the page is hidden or the canvas is off screen, follows the
 * pointer a little, and gives way to the 2D island when WebGL is missing, when the player switched
 * 3D off, or when anything fails.
 */
import { createElement, useEffect, useState } from 'react'
import { View } from 'react-native'
import { lowPower, supportsWebGL, useGraphics3D } from '../graphics'
import { useReduceMotion } from '../motion'
import { VillageBanner } from './VillageBanner'
import type { IslandHandle } from './island3d/scene'

export function Island3D({ maxHeight = 420 }: { maxHeight?: number }) {
  const enabled = useGraphics3D()
  const reduce = useReduceMotion()
  const [failed, setFailed] = useState(false)
  const [canvas, setCanvas] = useState<HTMLCanvasElement | null>(null)
  const usable = enabled && !failed && supportsWebGL()

  useEffect(() => {
    const element = canvas
    if (!usable || !element) return
    let handle: IslandHandle | null = null
    let cancelled = false
    const observers: (() => void)[] = []
    import('./island3d/scene')
      .then(({ createIslandScene }) => {
        if (cancelled) return
        handle = createIslandScene(element, { low: lowPower(), reduced: reduce })
        const resize = new ResizeObserver(() => handle?.resize())
        resize.observe(element)
        observers.push(() => resize.disconnect())
        const visible = new IntersectionObserver(([entry]) =>
          handle?.setActive(Boolean(entry?.isIntersecting)),
        )
        visible.observe(element)
        observers.push(() => visible.disconnect())
        const hidden = () => handle?.setActive(!document.hidden)
        document.addEventListener('visibilitychange', hidden)
        observers.push(() => document.removeEventListener('visibilitychange', hidden))
        const move = (e: PointerEvent) => {
          const r = element.getBoundingClientRect()
          handle?.look(
            ((e.clientX - r.left) / r.width) * 2 - 1,
            ((e.clientY - r.top) / r.height) * 2 - 1,
          )
        }
        element.addEventListener('pointermove', move)
        observers.push(() => element.removeEventListener('pointermove', move))
      })
      .catch(() => setFailed(true))
    return () => {
      cancelled = true
      observers.forEach((stop) => stop())
      handle?.dispose()
    }
  }, [usable, reduce, canvas])

  if (!usable) return <VillageBanner maxHeight={maxHeight} />
  return (
    <View style={{ width: '100%', height: maxHeight, borderRadius: 16, overflow: 'hidden' }}>
      {createElement('canvas', {
        ref: setCanvas,
        role: 'img',
        'aria-label':
          'Le Village en 3D : une île flottante sous un ciel déchiré, face à la tour sombre',
        style: { width: '100%', height: '100%', display: 'block' },
      })}
    </View>
  )
}
