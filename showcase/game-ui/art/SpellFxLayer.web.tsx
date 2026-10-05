/**
 * The 3D spell layer over the battle arena on the web (V, 2026-10-03): a transparent canvas that
 * plays `spellfx3d/spellfx.ts` for each skill. It loads on demand, does nothing without WebGL, when
 * 3D is switched off or when motion is reduced, and never catches a tap.
 */
import { createElement, useEffect, useRef, useState } from 'react'
import { lowPower, supportsWebGL, useGraphics3D } from '../graphics'
import { useReduceMotion } from '../motion'
import type { Cast, SpellFxHandle } from './spellfx3d/spellfx'

export type FxEvent = (Cast & { key: number }) | null

export function SpellFxLayer({ cast }: { cast: FxEvent }) {
  const enabled = useGraphics3D()
  const reduce = useReduceMotion()
  const [canvas, setCanvas] = useState<HTMLCanvasElement | null>(null)
  const handle = useRef<SpellFxHandle | null>(null)
  const pending = useRef<FxEvent>(null)
  const usable = enabled && !reduce && supportsWebGL()

  useEffect(() => {
    const element = canvas
    if (!usable || !element) return
    let cancelled = false
    let resize: ResizeObserver | null = null
    import('./spellfx3d/spellfx')
      .then(({ createSpellFx }) => {
        if (cancelled) return
        handle.current = createSpellFx(element, lowPower())
        resize = new ResizeObserver(() => handle.current?.resize())
        resize.observe(element)
        if (pending.current) handle.current.cast(pending.current)
      })
      .catch(() => undefined) // the 2D impacts still play
    return () => {
      cancelled = true
      resize?.disconnect()
      handle.current?.dispose()
      handle.current = null
    }
  }, [usable, canvas])

  useEffect(() => {
    if (!cast || !usable) return
    pending.current = cast
    handle.current?.cast(cast)
  }, [cast, usable])

  if (!usable) return null
  return createElement('canvas', {
    ref: setCanvas,
    'aria-hidden': true,
    style: {
      position: 'absolute',
      left: 0,
      top: 0,
      width: '100%',
      height: '100%',
      pointerEvents: 'none',
      zIndex: 5,
    },
  })
}
