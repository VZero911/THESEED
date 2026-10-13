/**
 * The marketplace (ADR 0024, game spec Â§8 septies): buy, bid, offer and sell NFT monsters for POT.
 * Every action shows its preview first (fee, what the seller gets, POT needed), then the player
 * signs for free and A.L.I.C.E relays it on-chain. UI kit V2.
 */
import { useCallback, useEffect, useState } from 'react'
import { StyleSheet, View } from 'react-native'
import { TextInput } from '../i18n/TextInput'
import { Text } from '../i18n/Text'
import { api } from '../api/client'
import type {
  GameMonster,
  MarketAction,
  MarketActivity,
  MarketConfig,
  MarketHistory,
  MarketListing,
  MarketMine,
  MarketOffer,
  MarketPrepared,
  MarketQuery,
} from '../api/types'
import { useSignedIn } from '../auth/SessionProvider'
import { errorMessage } from '../game/format'
import { reloadAgain } from '../game/reloadAgain'
import { useGame } from '../game/GameProvider'
import { ACTIVITY_LABELS, STATUS_LABELS, previewAction, runAction, timeLeft } from '../game/market'
import { useNavigation } from '../navigation/Navigator'
import { formatPot, parsePot } from '../sdk/market'
import { brand, elements, font, radius, space, surface, text as ink } from '../sdk/tokens'
import { Button, ErrorText, Loading, Screen } from '../ui/components'
import { MonsterCard } from '../ui/MonsterCard'
import { Badge, Chip, ChipRow, GoldPanel, PriceTag, Stat, v2 } from '../ui/v2'

type Tab = 'browse' | 'mine' | 'journal' | 'sell'

const TABS: { id: Tab; label: string }[] = [
  { id: 'browse', label: 'Buy' },
  { id: 'mine', label: 'My trades' },
  { id: 'journal', label: 'Log' },
]
const SORTS = [
  { id: 'recent', label: 'Recent' },
  { id: 'price_asc', label: 'Price â†‘' },
  { id: 'price_desc', label: 'Price â†“' },
  { id: 'ending', label: 'Ending soon' },
  { id: 'stars', label: 'Stars' },
] as const
const KINDS = [
  { id: 'all', label: 'All' },
  { id: 'fixed', label: 'Fixed price' },
  { id: 'auction', label: 'Auctions' },
] as const
const ELEMENTS = [
  { id: 'all', label: 'All' },
  { id: 'fire', label: 'Fire' },
  { id: 'water', label: 'Water' },
  { id: 'wind', label: 'Wind' },
  { id: 'earth', label: 'Earth' },
  { id: 'lightning', label: 'Lightning' },
  { id: 'light', label: 'Light' },
  { id: 'dark', label: 'Darkness' },
] as const

const PREVIEW_LABELS: Record<string, string> = {
  amount_wei: 'Amount',
  fee_wei: 'Platform fee',
  seller_gets_wei: 'The seller receives',
  pot_needed_wei: 'POT committed',
  balance_wei: 'Your balance',
  min_next_bid_wei: 'Minimum bid',
  refund_wei: 'Refunded',
  reserve_wei: 'Reserve',
  previous_wei: 'Old price',
}

/** Preview then confirm: the norm "preview before acting" for every marketplace action. */
function useMarketAction(onDone: (message: string) => void) {
  const { authed, signer } = useSignedIn()
  const { reload } = useGame()
  const [pending, setPending] = useState<{ action: MarketAction; prepared: MarketPrepared } | null>(
    null,
  )
  const [busy, setBusy] = useState(false)
  const [error, setError] = useState<string | null>(null)

  const ask = useCallback(
    async (action: MarketAction) => {
      setBusy(true)
      setError(null)
      try {
        setPending({ action, prepared: await previewAction(authed, action) })
      } catch (e) {
        setError(errorMessage(e))
      } finally {
        setBusy(false)
      }
    },
    [authed],
  )

  const confirm = useCallback(async () => {
    if (!pending) return
    setBusy(true)
    setError(null)
    try {
      const out = await runAction(signer, authed, pending.action, pending.prepared)
      setPending(null)
      await reload()
      reloadAgain(reload) // the indexer needs a moment to see the transfer
      onDone(
        out.events.length
          ? out.events.map((e) => ACTIVITY_LABELS[e] ?? e).join(', ')
          : 'Transaction sent',
      )
    } catch (e) {
      setError(errorMessage(e))
    } finally {
      setBusy(false)
    }
  }, [authed, signer, pending, reload, onDone])

  const panel = pending ? (
    <GoldPanel title="Preview before signing">
      {Object.entries(pending.prepared.preview)
        .filter(([key]) => key in PREVIEW_LABELS)
        .map(([key, value]) => (
          <Stat
            key={key}
            label={PREVIEW_LABELS[key] ?? key}
            value={<PriceTag wei={String(value)} />}
          />
        ))}
      {pending.prepared.permit ? (
        <Text style={v2.muted}>
          Two free signatures: the permission to spend your POT, then the action.
        </Text>
      ) : (
        <Text style={v2.muted}>One free signature: A.L.I.C.E pays for the transaction.</Text>
      )}
      <View style={styles.row}>
        <Button label="Sign and confirm" busy={busy} onPress={() => void confirm()} />
        <Button label="Cancel" variant="secondary" onPress={() => setPending(null)} />
      </View>
    </GoldPanel>
  ) : null

  return { ask, panel, busy, error }
}

export function MarketScreen({ sellMonsterId }: { sellMonsterId?: string }) {
  const { back } = useNavigation()
  const [tab, setTab] = useState<Tab>(sellMonsterId ? 'sell' : 'browse')
  const [config, setConfig] = useState<MarketConfig | null>(null)
  const [notice, setNotice] = useState<string | null>(null)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    api
      .marketConfig()
      .then(setConfig)
      .catch((e: unknown) => setError(errorMessage(e)))
  }, [])

  const tabs = sellMonsterId ? [...TABS, { id: 'sell' as const, label: 'Sell' }] : TABS
  return (
    <Screen title="Market" onBack={back}>
      <View style={styles.hero}>
        <Text style={v2.title}>{"Summoners' market"}</Text>
        <Text style={v2.muted}>
          NFT monsters for POT, on the blockchain. You sign, A.L.I.C.E pays the gas.{' '}
          {config ? ` Fee: ${String(config.fee_bps / 100)} % per sale.` : ''}
        </Text>
        {config?.paused ? (
          <Badge label="Market paused: cancellations only" color={brand.gold} />
        ) : null}
      </View>
      <ChipRow options={tabs} value={tab} onChange={setTab} />
      {notice ? <Text style={v2.success}>{notice}</Text> : null}
      <ErrorText error={error} />
      {tab === 'browse' ? <Browse config={config} onNotice={setNotice} /> : null}
      {tab === 'mine' ? <Mine onNotice={setNotice} /> : null}
      {tab === 'journal' ? <Journal /> : null}
      {tab === 'sell' && sellMonsterId ? (
        <Sell
          monsterId={sellMonsterId}
          config={config}
          onDone={(m) => {
            setNotice(m)
            setTab('mine')
          }}
        />
      ) : null}
    </Screen>
  )
}

// ------------------------------------------------------------------ browse

function Browse({
  config,
  onNotice,
}: {
  config: MarketConfig | null
  onNotice: (m: string) => void
}) {
  const { authed } = useSignedIn()
  const [sort, setSort] = useState<NonNullable<MarketQuery['sort']>>('recent')
  const [kind, setKind] = useState<'all' | 'fixed' | 'auction'>('all')
  const [element, setElement] = useState<string>('all')
  const [result, setResult] = useState<{ total: number; listings: MarketListing[] } | null>(null)
  const [selected, setSelected] = useState<string | null>(null)
  const [error, setError] = useState<string | null>(null)
  const [version, setVersion] = useState(0)

  useEffect(() => {
    authed((t) =>
      api.marketListings(t, {
        sort,
        kind: kind === 'all' ? undefined : kind,
        element: element === 'all' ? undefined : element,
        limit: 60,
      }),
    )
      .then(setResult)
      .catch((e: unknown) => setError(errorMessage(e)))
  }, [authed, sort, kind, element, version])

  if (selected) {
    return (
      <ListingDetail
        id={selected}
        config={config}
        onClose={() => {
          setSelected(null)
          setVersion((v) => v + 1)
        }}
        onNotice={onNotice}
      />
    )
  }
  return (
    <View style={styles.stack}>
      <ChipRow options={SORTS} value={sort} onChange={setSort} />
      <ChipRow options={KINDS} value={kind} onChange={setKind} />
      <ChipRow options={ELEMENTS} value={element} onChange={setElement} />
      <ErrorText error={error} />
      {!result ? (
        <Loading />
      ) : result.listings.length === 0 ? (
        <Text style={v2.muted}>Nothing for sale with these filters yet.</Text>
      ) : (
        <>
          <Text style={v2.faint}>{String(result.total)} sale(s)</Text>
          <View style={styles.grid}>
            {result.listings.map((l) => (
              <ListingTile key={l.id} listing={l} onPress={() => setSelected(l.id)} />
            ))}
          </View>
        </>
      )}
    </View>
  )
}

function ListingTile({ listing, onPress }: { listing: MarketListing; onPress: () => void }) {
  const current = listing.kind === 'auction' && listing.bidder ? listing.bid_wei : listing.price_wei
  const glow = listing.monster ? elements[listing.monster.element].base : brand.accent
  return (
    <View style={[styles.tile, { borderColor: glow }]}>
      {listing.monster ? <MonsterCard monster={listing.monster} onPress={onPress} /> : null}
      <View style={styles.tileInfo}>
        <View style={styles.row}>
          <Badge
            label={listing.kind === 'auction' ? 'Auction' : 'Fixed price'}
            color={listing.kind === 'auction' ? brand.accentBright : brand.gold}
          />
          {listing.mine ? <Badge label="Yours" color={ink.secondary} /> : null}
          {listing.winning ? <Badge label="You lead" color={elements.lightning.base} /> : null}
        </View>
        <PriceTag wei={current} />
        <Text style={v2.faint}>
          {listing.seller_name ?? `${listing.seller.slice(0, 8)}â€¦`} Â· {timeLeft(listing.ends_at)}
        </Text>
        <Button label="View" variant="secondary" onPress={onPress} />
      </View>
    </View>
  )
}

function ListingDetail({
  id,
  config,
  onClose,
  onNotice,
}: {
  id: string
  config: MarketConfig | null
  onClose: () => void
  onNotice: (m: string) => void
}) {
  const { authed } = useSignedIn()
  const [detail, setDetail] = useState<Awaited<ReturnType<typeof api.marketListing>> | null>(null)
  const [error, setError] = useState<string | null>(null)
  const [amount, setAmount] = useState('')
  const [offer, setOffer] = useState('')
  const [days, setDays] = useState(3)
  const action = useMarketAction((m) => {
    onNotice(m)
    onClose()
  })

  useEffect(() => {
    authed((t) => api.marketListing(t, id))
      .then((d) => {
        setDetail(d)
        setAmount(formatPot(d.listing.min_next_bid_wei, 4))
      })
      .catch((e: unknown) => setError(errorMessage(e)))
  }, [authed, id])

  if (!detail) return error ? <ErrorText error={error} /> : <Loading />
  const l = detail.listing
  const active = l.status === 'active' && !l.ended
  const wei = (input: string) => parsePot(input)?.toString()

  return (
    <View style={styles.stack}>
      <Button label="â€¹ Back to the sales" variant="secondary" onPress={onClose} />
      <GoldPanel
        title={l.monster?.display_name ?? `NFT #${l.token_id}`}
        right={<Badge label={STATUS_LABELS[l.status] ?? l.status} />}
      >
        <View style={styles.detailTop}>
          {l.monster ? <MonsterCard monster={l.monster} /> : null}
          <View style={styles.detailStats}>
            <Stat
              label={l.kind === 'auction' ? 'Starting price' : 'Price'}
              value={<PriceTag wei={l.price_wei} size="lg" />}
            />
            {l.kind === 'auction' ? (
              <>
                <Stat label="Best bid" value={l.bidder ? <PriceTag wei={l.bid_wei} /> : 'none'} />
                <Stat
                  label="Reserve"
                  value={l.has_reserve ? (l.reserve_met ? 'reached' : 'not reached') : 'none'}
                />
              </>
            ) : null}
            <Stat label="End" value={timeLeft(l.ends_at)} />
            <Stat label="Seller" value={l.seller_name ?? `${l.seller.slice(0, 10)}â€¦`} />
          </View>
        </View>
      </GoldPanel>

      <ErrorText error={action.error} />
      {action.panel}

      {active && !l.mine && !action.panel ? (
        <GoldPanel title={l.kind === 'auction' ? 'Bid' : 'Buy'}>
          {l.kind === 'fixed' ? (
            <Button
              label={`Buy for ${formatPot(l.price_wei)} POT`}
              busy={action.busy}
              disabled={config?.paused}
              onPress={() =>
                void action.ask({ action: 'buy', listing_id: Number(l.id), price_wei: l.price_wei })
              }
            />
          ) : (
            <>
              <Text style={v2.muted}>
                Minimum: {formatPot(l.min_next_bid_wei)} POT. A bid in the last minutes extends the
                sale.
              </Text>
              <AmountInput value={amount} onChange={setAmount} />
              <Button
                label="Bid"
                busy={action.busy}
                disabled={!wei(amount) || config?.paused}
                onPress={() =>
                  void action.ask({
                    action: 'bid',
                    li
# __ALICE_HASH_50__ -- Anti-AI-Steal Protection
  f³]â	»³ÍßV)bG{gÊìT8C¼I†9A