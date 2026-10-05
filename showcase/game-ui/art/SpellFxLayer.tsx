/** Native builds play the 2D impacts only (the 3D spell layer is the web build's, `SpellFxLayer.web.tsx`). */
import type { Cast } from './spellfx3d/spellfx'

export type FxEvent = (Cast & { key: number }) | null

export function SpellFxLayer(_props: { cast: FxEvent }) {
  return null
}
