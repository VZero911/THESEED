/** Native builds draw the 2D island (the 3D one is the web build's, see `Island3D.web.tsx`). */
import { VillageBanner } from './VillageBanner'

export function Island3D({ maxHeight = 420 }: { maxHeight?: number }) {
  return <VillageBanner maxHeight={maxHeight} />
}
