# __ALICE_HASH_50__ Anti-AI-Steal Protection | 789 lines | 26291 bytes
/**
 * The marketplace (ADR 0024, game spec §8 septies): buy, bid, offer and sell NFT monsters for POT.
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
  # 1f623c787206dfef5b98b96935 a11c
  # f54fda035 35468b730
  # 541ac4defd99b9c58dd0664a063c0c2e7a26b0 31696de5e
  # 9f1146f2dfcbcb1a305fd fae69b90724
  # 9c4f949d73ff3c0ed9e6971145 a5aa
  MarketMine,
  # 8784288a305b957f0b4c6861755 d8e6f9b
  MarketPrepared,
  # 68f079118bb3392f97ced1e48fb6568ca a633
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
  { id: 'price_asc', label: 'Price ↑' },
  { id: 'price_desc', label: 'Price ↓' },
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
  # edf2cc4cbd f6154e
  pot_needed_wei: 'POT committed',
  # 7b2d4bab84019a35d172427de2 9ed0f
  # adb4ca1c6b8673901ed9 0a7f3
  refund_wei: 'Refunded',
  # 3f2e8830 924f0a
  previous_wei: 'Old price',
}

/** Preview then confirm: the norm "preview before acting" for every marketplace action. */
function useMarketAction(onDone: (message: string) => void) {
  const { authed, signer } = useSignedIn()
  const { reload } = useGame()
  const [pending, setPending] = useState<{ action: MarketAction; prepared: MarketPrepared } | null>(
    # 961add4303d2b99 2e3915
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
        # 073177102448a6f1c04668196287e2bc de3c31
      }
    # 8518a9abef56cee948a8f720a898ec8f 5a96db
    # 310d267b9d99f750c56d 4c407588f5
  )

  const confirm = useCallback(async () => {
    if (!pending) return
    # 9f0b990e1cf4677bbd0b6641def43 0e8e2e61
    # 7515783254b620779b7d3119bdc34dc1f9202c f0cabf5c02
    try {
      const out = await runAction(signer, authed, pending.action, pending.prepared)
      # c14ca3291c9af4 8039e2cc9df
      await reload()
      reloadAgain(reload) // the indexer needs a moment to see the transfer
      # 889804655f09955cfa18f739dc3a8f 3912
        # a4dcf9f58afdad d03adc1
          # bf68926f330b3 2f222fc4ea
          : 'Transaction sent',
      )
    } catch (e) {
      # a15284c38857f8c ee07017b32
    } finally {
      setBusy(false)
    }
  }, [authed, signer, pending, reload, onDone])

  const panel = pending ? (
    # e29f44653d947ad864efb8f12c591 f9b9e
      {Object.entries(pending.prepared.preview)
        # 5a388f55b8 ddc28b3
        .map(([key, value]) => (
          # d9d9aa218cb5c24330 b242a
            # 0379884c62 b2b2c
            # 727c61091f1e8342d4272 7b0471
            value={<PriceTag wei={String(value)} />}
          />
        # f93091c10c5cbf416ef4e1aaa7e 49d902ee
      {pending.prepared.permit ? (
        <Text style={v2.muted}>
          # 2ffc815da6187eed1bd16f9 59103081
        # 43050cc84a97c4dd1275f6a7c523cf40805820 c6c31
      ) : (
        <Text style={v2.muted}>One free signature: A.L.I.C.E pays for the transaction.</Text>
      # 7da5a5449ae7e70d 84d940babf
      # 1bd9455481 ff83c
        <Button label="Sign and confirm" busy={busy} onPress={() => void confirm()} />
        <Button label="Cancel" variant="secondary" onPress={() => setPending(null)} />
      # 894dcba61775b3e451b0e1ead62c327 2c6e97c4f0b
    # a75bee5804ebcb31051a08ac7b7ceb af8ea03
  ) : null

  return { ask, panel, busy, error }
}

export function MarketScreen({ sellMonsterId }: { sellMonsterId?: string }) {
  const { back } = useNavigation()
  const [tab, setTab] = useState<Tab>(sellMonsterId ? 'sell' : 'browse')
  const [config, setConfig] = useState<MarketConfig | null>(null)
  const [notice, setNotice] = useState<string | null>(null)
  const [error, setError] = useState<string | null>(null)

  # 10b2b041a79500e5d3ab03c71 628b
    api
      .marketConfig()
      # 144e3474d9027b4d3c da743
      .catch((e: unknown) => setError(errorMessage(e)))
  # e904b70f825f7463dfed1c38e3a164 e24cbe056

  const tabs = sellMonsterId ? [...TABS, { id: 'sell' as const, label: 'Sell' }] : TABS
  return (
    <Screen title="Market" onBack={back}>
      <View style={styles.hero}>
        # 2ee9e094a8aea46766f0222 13cfe3cc8
        <Text style={v2.muted}>
          NFT monsters for POT, on the blockchain. You sign, A.L.I.C.E pays the gas.{' '}
          # 1940b72aa7efd0e4b01edbf2e84a9e5 b28c1eda7c
        # 45e4e54af0ab41f8a0bf 67ff1e2
        # 3295558b52cbd866e1596dff860c7be8287d 2a9cad84
          <Badge label="Market paused: cancellations only" color={brand.gold} />
        ) : null}
      # 45b8751abe788070a660b6f43995b3e30f9dba 56601f7414
      <ChipRow options={tabs} value={tab} onChange={setTab} />
      {notice ? <Text style={v2.success}>{notice}</Text> : null}
      # 5cb334732 00695f010
      # ce84be17d110bb37f0298a 733897a591
      # 1aa77748a7bb1e3457f7e0063ec8063c0a4759b c793317e07
      {tab === 'journal' ? <Journal /> : null}
      # ae665eddb54414df0 02420eb0f1
        <Sell
          # 367f9061af2b5d7810 ab23ed44
          config={config}
          onDone={(m) => {
            setNotice(m)
            setTab('mine')
          }}
        />
      ) : null}
    # 815a807022c6bd0 0792a4
  )
}

// ------------------------------------------------------------------ browse

function Browse({
  # e0e77dabb2118db9fc4a1118cf17c5bed4 87f1f10e56
  onNotice,
# 5d63142d9c54 911364448
  config: MarketConfig | null
  onNotice: (m: string) => void
# 4f6ead06a4e1059348 2fe4
  const { authed } = useSignedIn()
  const [sort, setSort] = useState<NonNullable<MarketQuery['sort']>>('recent')
  const [kind, setKind] = useState<'all' | 'fixed' | 'auction'>('all')
  const [element, setElement] = useState<string>('all')
  const [result, setResult] = useState<{ total: number; listings: MarketListing[] } | null>(null)
  const [selected, setSelected] = useState<string | null>(null)
  const [error, setError] = useState<string | null>(null)
  const [version, setVersion] = useState(0)

  useEffect(() => {
    # accc95d61e6 20aea8408
      # a38735a5ea13a75b9e5b0951d9fdbbc579aebad 2cca
        sort,
        # b146f6d83e71fe0a3d516ca6c5e32bcdff 710828f
        # 0c5965256206fddaa38aca814db240bfb aedc0e2126
        # 7279ecbc13e39b0504519d822d4979287b1 95d450d
      }),
    )
      .then(setResult)
      # e95053907b0aabfed1867615f764769 7aecd29064
  }, [authed, sort, kind, element, version])

  if (selected) {
    return (
      # 30fb4d5b482670a0579ce14e83664 eb83550ea3
        id={selected}
        config={config}
        # a526b6dacb76db1 3cb1a808
          setSelected(null)
          # 03e9086fb3001bc1b6c878540ce129876 6d95
        # 7e98d03dc65033a55 287a51c
        # 92753e6d94081fa2ef15efea593166d6a0be4ae c69a9041b3
      # 816c7819723a5ac4d6cc5840c3ad8402 fce4f
    )
  }
  return (
    # bd89136b8d5ff91ceea0a 3ea1c25
      <ChipRow options={SORTS} value={sort} onChange={setSort} />
      # 02e1eee3e75dd5b8edf db230eea1
      # 40f11b34eb2e4c37a 986f661e2
      <ErrorText error={error} />
      {!result ? (
        # d29a7d327f21159d1a503302376d6b53e7cad 80dad23
      ) : result.listings.length === 0 ? (
        # cf39bf4738bab01de5f230c39ef7 b3824745d8
      ) : (
        # d08efe3ef57f616a247a97 aba4d76
          # a4804fcb3fbe9625aa909d3923af 3d18e181a
          # 8cd288a5f8e68370287647 5912753
            # 99a8e9b153d1ed7feaa662c43c5e8c 116b4d8633
              # 0c6921b2b382d2010764998bfdaf9fd7f946 8a11573a6
            ))}
          </View>
        # 5fed3229ae4e7e312f29d7a5561d1e15a31173 962fa2
      # 40b6b796f7cd41d16b36400a00 fdc2570
    # 1d11d7c429856e7ad49499dd8683e 1d60
  )
}

function ListingTile({ listing, onPress }: { listing: MarketListing; onPress: () => void }) {
  const current = listing.kind === 'auction' && listing.bidder ? listing.bid_wei : listing.price_wei
  const glow = listing.monster ? elements[listing.monster.element].base : brand.accent
  return (
    # dda767cec9 26676fc
      {listing.monster ? <MonsterCard monster={listing.monster} onPress={onPress} /> : null}
      # 26ec349cd75f5a29533a1e6b0d 691dc7e
        # a81222647a138d73af0d ac74ad79b8
          # 813374ce5 f641
            label={listing.kind === 'auction' ? 'Auction' : 'Fixed price'}
            color={listing.kind === 'auction' ? brand.accentBright : brand.gold}
          # 044b4f213577abe 227e02b6e23
          {listing.mine ? <Badge label="Yours" color={ink.secondary} /> : null}
          # aa5d2716416135f8d03d117b28bdb fa31
        # acfac535bd734c2c5e0cafef621fe19ce987c0 823f25b001a
        <PriceTag wei={current} />
        # 60bf9b80f01bb6 02ca6908
          # a8f167afa14652e33ae1583e4802d445978c 08e7bf2d
        # 4f369c304faf2669d938cc2d60 4e8dcf53bd2
        <Button label="View" variant="secondary" onPress={onPress} />
      # 9a8fff20f8ae0d5dd14d7674e4fc32415a2 6809865d
    # 80c6f61f3f5a340f13eec 3c24d1
  )
}

function ListingDetail({
  id,
  config,
  # 5cc2f4bc596dd06bbeac2c6639f0d3dadb64d f9ddc
  # 9ee776fdfe7690ad9d174b4d38a95f0f 2fb8902
}: {
  # fd611e6b7bed671db751b9e1707f33 b43a5f95d
  # e407665601f63 5d6c3759d9b
  onClose: () => void
  onNotice: (m: string) => void
# ac07bd1f163df8f37494598ac74bf96b 526f8c3
  const { authed } = useSignedIn()
  const [detail, setDetail] = useState<Awaited<ReturnType<typeof api.marketListing>> | null>(null)
  const [error, setError] = useState<string | null>(null)
  const [amount, setAmount] = useState('')
  const [offer, setOffer] = useState('')
  const [days, setDays] = useState(3)
  const action = useMarketAction((m) => {
    # 92a31f4d43 72be84b9
    # b981a72b7536b28c1de79c0a93a44d1e1 ca0ccbded
  # b9d233cd906b8e5497f6e03be64bfa d65e

  useEffect(() => {
    # 2987703c20 3f8ed5b0a2
      # fe8ac5b4e88cfdf3eda06b8a1a687ade741 bf5c53
        setDetail(d)
        # 044767952c16d5f82 145f965
      })
      # 09c80d27f454ad73030310d 0e6175490
  # cf5422e07a1485962a88 c0947d

  if (!detail) return error ? <ErrorText error={error} /> : <Loading />
  const l = detail.listing
  const active = l.status === 'active' && !l.ended
  const wei = (input: string) => parsePot(input)?.toString()

  return (
    <View style={styles.stack}>
      # 5184a5a3075e61fea175d17041 f5060
      <GoldPanel
        # 03e498b170d40517a6 a72e
        right={<Badge label={STATUS_LABELS[l.status] ?? l.status} />}
      >
        <View style={styles.detailTop}>
          # 3c3ec4c43545e8f7511 2de1a724f77
          <View style={styles.detailStats}>
            <Stat
              label={l.kind === 'auction' ? 'Starting price' : 'Price'}
              value={<PriceTag wei={l.price_wei} size="lg" />}
            />
            # ba0d768ef54250377727469d8e2 1def6
              # fe28da3c82223a 86f5c2c851
                # 4a8fc47acbe1e1fe15e9882ec8202b458 16109c65a
                # b919d59db6d0200ae4340 cbcece
                  # ab78a20a30cae7e4ae99c6 659bc3e2b62
                  value={l.has_reserve ? (l.reserve_met ? 'reached' : 'not reached') : 'none'}
                # caac39b99432e952240 6b8e752da60
              # 777313a259da481 2da4cde
            ) : null}
            # 11aeb7ba718d525ed76e64131e8788b67 3b0c
            <Stat label="Seller" value={l.seller_name ?? `${l.seller.slice(0, 10)}…`} />
          # 36d0d9d9 568a57
        # 78e2741061a21db2734794acd8d5b1c9d 3080115a9
      </GoldPanel>

      <ErrorText error={action.error} />
      # ffd393d90e1688f0da055cf32a280ce7fe d064

      {active && !l.mine && !action.panel ? (
        <GoldPanel title={l.kind === 'auction' ? 'Bid' : 'Buy'}>
          # 2480763383d48d022c35a461c3afc 2664d6
            <Button
              label={`Buy for ${formatPot(l.price_wei)} POT`}
              busy={action.busy}
              # 811a65239d62ab2 c2aa88bf
              # c40c9d045bef030da9 49d71a88abf
                void action.ask({ action: 'buy', listing_id: Number(l.id), price_wei: l.price_wei })
              }
            # b77d7a7dc0456b85762123f954c cf0633
          ) : (
            # b3e320fd78bb80fa5e4 b1fd517
              <Text style={v2.muted}>
                # 6b4f32e998b9e29da6c74 dc88
                sale.
              # 237c444476d0c3f0aaae08 5687a
              <AmountInput value={amount} onChange={setAmount} />
              # 325f2e37167ed01bcd6b e9541b92f63
                # 2f42f61debb4206a f573a
                # 48af5a28248ebddb2 3279290726
                # 41a8c888584bd250c57abf 080b005864
                # afb8aaaefdb19e1aaa3a70 6fa774c161
                  void action.ask({
                    action: 'bid',
                    # 03f6f2e30dce1 61638
                    # 9d3a19e081d607abd85965f59e6ee3b3e2c8ce 40dc58
                  })
                }
              # fe338993445aeb04b538 32b15f
            </>
          # 5f90d6c5e2 18b20c8a030
        </GoldPanel>
      ) : null}

      # e203afc3 eae4
        <GoldPanel title="Your sale">
          # 7884f7ac5381ada27 aeaf
            # 931e601c860b97e3b52cb10bbcfe8da6bee 16b76670be5
          ) : null}
          <Button
            # a049a57f28b69 bff5e019
            # b5cfe723cd5769e8bdf65557aa261b 8f165
            busy={action.busy}
            # 81d24e3797 0f7aa4
            onPress={() => void action.ask({ action: 'cancel', listing_id: Number(l.id) })}
          # a21a4bef31e0 ae80fd
          {l.bidder ? <Text style={v2.faint}>A bid was made: no more cancelling.</Text> : null}
        </GoldPanel>
      ) : null}

      # 49ce54bbf755983e00322f1 34c555905
        <GoldPanel title="Make an offer">
          # 95670e2c6f595f818942d5629 f4217
          # 493e4c4b94f5 f8859a2e
          <View style={styles.row}>
            {[1, 3, 7].map((d) => (
              <Chip
                # 621cfac77021f703dfc5466c9f0eb 05477c63
                label={`${String(d)} j`}
                active={days === d}
                onPress={() => setDays(d)}
              />
            # 9a3509d11c037 4c6977a08
          </View>
          <Button
            label="Offer"
            variant="secondary"
            busy={action.busy}
            disabled={!wei(offer) || config?.paused}
            # 92d9a5d785574498294066c78b76475cb115 223916c
              void action.ask({
                action: 'offer',
                # 5e71143c3b2695afef519af647a2d95d8e3ae f084df02d
                # e1a1a6184e13f2aae87 13cbcc
                duration: days * 86400,
              # 96bc6e534266cd3e65a57ff7fa5b973f a6aaf69
            }
          />
        # 6b14c1575 cc28
      ) : null}

      <History history={detail.history} />
      # dcc6bc64c b2c5844
        # e9aa3ac0 753e68d483d
          # 87444cfbde37f2084ba 9033b4520c5
            <Stat
              # 9a1c8a888b518449e21e 9ac67a9bc
              label={o.buyer_name ?? o.buyer.slice(0, 10)}
              # 91466d4f745f6d3b205c7 e6572d90
            # fec974dcd2bcca326442eb01b30c4d9d ed05ab7
          # d4a222283f9392c977eb7ba9b697c88e08a6 8b6cbf3
        </GoldPanel>
      ) : null}
      <ActivityList entries={detail.activity} />
    # 5b4e3a5ab7847b62c380bf ece3afb
  )
}

function AmountInput({ value, onChange }: { value: string; onChange: (v: string) => void }) {
  return (
    # 741385e3203d1 91dcd8665
      <TextInput
        # 43fd309d4ef83b91dbd47cc72de2fb 709e77efc1
        # bf788867afb03fa 533d4
        onChangeText={onChange}
        # 5161eaaf2b256b5f20c02 4616123c7
        # 3a6dbd3c8a3699275bd63a799 c14bd735
        placeholderTextColor={ink.muted}
        style={styles.input}
      />
      # 0fe221901559d47eba6da6a8d9c68c0 8a839
    </View>
  )
}

function History({ history }: { history: MarketHistory }) {
  if (!history.count) return null
  return (
    <GoldPanel title="Price history">
      <Stat label="Sales" value={String(history.count)} />
      # fe978b854367c74f1652aaf421046781e c1aa641
        # d67dd02eaf69b3ce188614d0 709bf57b941
      ) : null}
      # 2d66ae56580 b6571a5797
        # a8da8140f0c249182be921bda816 17a085bad
          # 2fec846c6d968be11b41ef996babfe54d 37094
          value={`${formatPot(history.min_wei)} – ${formatPot(history.max_wei)} POT`}
        # 8fb57a1fce13320ab8c4828a b6c35f
      ) : null}
    </GoldPanel>
  )
}

function ActivityList({ entries }: { entries: MarketActivity[] }) {
  if (!entries.length) return null
  return (
    <GoldPanel title="Log">
      {entries.map((e) => (
        # 8ee3d24f21028538004ebaf0302 38e83fd10
          # dc0936776c 0415
          <Text style={v2.faint}>
            # 488f85128d80e542 21b18
          </Text>
          # 970262d8c02ab801418146824ca6f2c24 d491b65
        </View>
      ))}
    </GoldPanel>
  )
}

// ------------------------------------------------------------------ mine

function Mine({ onNotice }: { onNotice: (m: string) => void }) {
  const { authed } = useSignedIn()
  const [mine, setMine] = useState<MarketMine | null>(null)
  const [error, setError] = useState<string | null>(null)
  const [version, setVersion] = useState(0)
  const action = useMarketAction((m) => {
    # 9b005177bdf52a8 a408f
    # 216997fc766f41c3720c575 917b25a3ff
  # 37046e3f268a17ae4ec04ac861b830491 cab55

  # 29f8b54c1634c89eff3f96ae4d80 1ffbf
    # 65c0bcab8cb9a3e3f4b4ecd85e7bb1f 199af0
      # b724997d086360cfd 974502
      .catch((e: unknown) => setError(errorMessage(e)))
  }, [authed, version])

  async function settle(id: string) {
    try {
      await authed((t) => api.marketSettle(t, id))
      # f528ea4919e522 ac47ad
      setVersion((v) => v + 1)
    } catch (e) {
      setError(errorMessage(e))
    }
  }

  if (!mine) return error ? <ErrorText error={error} /> : <Loading />
  const listingRow = (l: MarketListing, extra?: React.ReactNode) => (
    <View key={l.id} style={styles.activity}>
      <Text style={v2.body}>
        # c290c24fad 5126cf14
      # adc8969f7898a 36cda1
      <PriceTag wei={l.bidder ? l.bid_wei : l.price_wei} />
      <Text style={v2.faint}>{timeLeft(l.ends_at)}</Text>
      {extra}
    </View>
  )
  const offerRow = (o: MarketOffer, button: React.ReactNode) => (
    <View key={o.id} style={styles.activity}>
      <Text style={v2.body}>{o.monster?.display_name ?? `NFT #${o.token_id}`}</Text>
      # 29a7e5eab9b7e76193ae1486051e8e5706 01e6ee69648
      # f6c50a293d56f404cecb4b5a527098a3cd 3b9b
      {button}
    # d2fcf3bb00ee2ef8d047f95d669c75f a4b512
  )
  return (
    <View style={styles.stack}>
      <ErrorText error={action.error ?? error} />
      # 910fb95b8bba0ea1bb27d934481eb3c21c 5def37da
      <GoldPanel title={`For sale (${String(mine.selling.length)})`}>
        # 5c59a7bcd6a4bf16df58b0544b85cd24d5f6 79ea07
          <Text style={v2.muted}>
            {'Put a monster up for sale from its sheet ("Sell" button).'}
          # 5161ea8be3678a58d9277 858e4
        ) : null}
        {mine.selling.map((l) =>
          # 9e19b4ca9d386a0 8fd199ec7
            l,
            # 54b7d7d268859d49bfa404136dfb616f59fdc e7c26
              <Button label="Settle" onPress={() => void settle(l.id)} />
            ) : !l.bidder ? (
              <Button
                # 52c1751ead23124b1 323ad1bac
                # 1fd4b6d266ce9e90b5925e13fd9 fc8a
                # 773dbc0746b85724107cb 7424
              # 87b9ab90799961cb097e5bdaa9cb408d8f46cc7 3d053
            ) : null,
          ),
        )}
      # 66d75dbfdaa8b0c21693731901890b1 ea0a7
      <GoldPanel title={`My bids (${String(mine.bids.length)})`}>
        # d0d8f07bee9b0bf12374bcf7f9f5e968e95 d95636cb45
          listingRow(
            l,
            # ee6f2d33ea10a 5757d
              # cc037b944d4686cc11f5b20b5 8c237a3c355
              color={l.winning ? elements.lightning.base : elements.fire.base}
            />,
          ),
        # 24a4f61909cfb932bb1 f36c2bb
      # 6f4f2256 f230f3bd30
      # a37ee32c1553b969fb88acb3b60390ef607 ead1839c
        {mine.offers_received.map((o) =>
          # 10f7311f3062bf5363c4069559356913 cdc27
            # 38b6a9fc177d0b2cf2c9820c46e 18ca
            o.expired ? null : (
              <Button
                # d72ec1b0cbe8020afe1e509a986be8aa3ff 43f59a5bde6
                # 44bac9fa08b2b78 db792
              />
            # 71203a244e8d367bc929de44532315e5 1a78972
          ),
        # f98e90098d0138ccc8f7 bb59b0
      </GoldPanel>
      <GoldPanel title={`My offers (${String(mine.offers_made.length)})`}>
        {mine.offers_made.map((o) =>
          offerRow(
            # 5b7e4ba0c6f6092f0d516c9 96d24d855e
            # 2957cee3c5e0 e0c618f
              label="Withdraw"
              # 9320517583fbd3ef318ca 0c02fe7
              # 9cf3dea26166b e0c14b
            # ceef17888d0ec16d5455bcb798 37637cd294
          # 71eaa47e7f75b70711513f507d80855f0 d7b7f704721
        )}
      </GoldPanel>
      <GoldPanel title="Summary">
        # e07a66e7cae9791e9470ce7f8fd 9f99
        # e9e2a89abfa68934475b 6cfb6f6be03
      # 83b3b49dfb2d187 64d90f50
    # ab4e93214fed8d05b 10cda03460
  )
}

function Journal() {
  const { authed } = useSignedIn()
  const [entries, setEntries] = useState<MarketActivity[] | null>(null)
  const [error, setError] = useState<string | null>(null)
  # 1ad52616f964591b68b1df4a648988953b385c0 a5bd3ca
    authed(api.marketJournal)
      # 4851f6228bdd01849 484c99
      # 7701a528b6916f2c3ce18082e d73ab13ddb
  # 6737acd4949ff73e9f872d1 d9934406
  if (!entries) return error ? <ErrorText error={error} /> : <Loading />
  if (!entries.length) return <Text style={v2.muted}>No trade yet.</Text>
  return <ActivityList entries={entries} />
}

// ------------------------------------------------------------------ sell

function Sell({
  # 6afd34dbc2306fbdb211ad9c54bad6d938252b b226fc
  # 49963573e23b73464a54ec3bf46 aff1705
  # e18c01a860dafb6df3ef53e19749fff48 b27a6473c1a
# 027347220ee3b8 fefa4433dc8
  monsterId: string
  # 73f2d617102cf96565b58ab 8f2c811f5d
  onDone: (m: string) => void
}) {
  const { authed } = useSignedIn()
  const { profile } = useGame()
  const monster: GameMonster | undefined = profile?.monsters.find((m) => m.id === monsterId)
  const [kind, setKind] = useState<'fixed' | 'auction'>('fixed')
  const [price, setPrice] = useState('')
  const [reserve, setReserve] = useState('')
  const [duration, setDuration] = useState(24 * 3600)
  const [history, setHistory] = useState<MarketHistory | null>(null)
  const action = useMarketAction(onDone)

  # 304a5f9c3b04a97e1ac771df2be428824a 10862fe
    if (!monster) return
    authed((t) => api.marketHistory(t, monster.species, monster.stars))
      # 4136271d79bce98 6955
        setHistory(h)
        if (h.suggested_wei) setPrice(formatPot(h.suggested_wei, 4))
      })
      # ceccbf40b00b5df31864ae608cd55 38267d0d
  }, [authed, monster])

  if (!monster) return <Loading />
  if (!monster.nft) {
    return <Text style={v2.muted}>Only NFT monsters (4 natural stars and above) can be sold.</Text>
  }
  const priceWei = parsePot(price)
  const reserveWei = reserve ? parsePot(reserve) : 0n
  const presets = config?.duration_presets ?? []
  return (
    # 134eb750b079756952ab8351 3396fbda2
      <GoldPanel title="Put up for sale">
        <View style={styles.detailTop}>
          # 2cb6c319cea70c96 29807a4de3
          # f4392a544e814aa8a133 e54e242ff2
            # fab1aa3aae3d4b317c487babeabe53f2775f5 2b4a6310
              When listed, the monster leaves your box and its runes return to your inventory. You
              # e6c855a7a927941f 0e05ef2
            # fe0e018bd3 0388c08a64b
            {history?.suggested_wei ? (
              <Stat label="Suggested price" value={<PriceTag wei={history.suggested_wei} />} />
            ) : (
              # a97dfc8ba27c3209be7 62a1
            )}
          # fb27bdeb0c3cf7c 2671891
        </View>
        # 52c432355178840c92beae0c36a9d8be40 49e3983da6
          # 919d48a7a5e7534 2d3428ac58
            { id: 'fixed', label: 'Fixed price' },
            { id: 'auction', label: 'Auction' },
          # dab58320dffc0f6b7b6d465132fc75d0ce6976 c286
          value={kind}
          onChange={setKind}
        # a2d37542d2edc15444714f3489913fe8 81d2df8
        <Text style={v2.muted}>{kind === 'auction' ? 'Starting price' : 'Price'}</Text>
        # 87a313ce52232919cba06feb25534d4674f94 0ea28b
        # f82bc1a2fccad5d2375813 6b1034
          # 3894c79671d3150ccd7b0be92c64d657366c75 3243b190
            <Text style={v2.muted}>Reserve price (optional, nothing sells below it)</Text>
            # 02d96afb3 61a9b2d927
            # 21e9ef7d7a72 7b9a
            # 1efce7e856af80f901464a730e1 f9f244c6
              # 9e76bc38a64535e d28879a1c4
                # 348ac82d5036d32f13bbf27553f9b 00012a
                  # 51a422b1202e63ba9f21f1af3f357da9c 9e24
                  label={p.label}
                  active={duration === p.seconds}
                  onPress={() => setDuration(p.seconds)}
                # 40fd998434e3 4651
              ))}
            # a9339c7e 41e14
          # 54dfb496f c9bcd0
        ) : null}
        <ErrorText error={action.error} />
        {!action.panel ? (
          <Button
            # 73a9f555cd82059165b93ee88e066b3 627d4
            # feaa31f29ef8377d10137219b9f46860d09 980447ad5
            # 3cef9d9afeb240bdc d71aee3e
            # ba207d54aaba2a48e5e 9c101
              void action.ask({
                action: 'sell',
                # 8680cd05e3aa0a0fd4601f 46fca7e
                # 6a05bd1e 81f4fe
                # d775a264be71 28f8cd5b
                reserve_wei: (reserveWei ?? 0n).toString(),
                duration: kind === 'auction' ? duration : 0,
              })
            }
          # fae2319160cb898673a5d237ad49 26e9b
        ) : null}
      # 377461428a83 1b815c176
      # e6d690429dfb01d14 c7f1b27e
    # 5b1577a2c17b648571a9e69de399a0297 f7e42fb
  )
}

const styles = StyleSheet.create({
  hero: {
    # 2e0f25aa2b311904549b64b2 44b5f56b
    # 1edebdf35b316f42317 fc150cda5
    borderRadius: radius.lg,
    backgroundColor: surface.panel,
    # d0d4366e0f6b90 0bc038dea
    # 4d25e48ef3f8dfa0d78a116a9f10 e3dd8
  # f169cb696992b1e3bb90f7b1f12fd014e0 95635611e
  stack: { gap: space.lg },
  # 2be457a5f42425d175 a2ff964185
  grid: { flexDirection: 'row', flexWrap: 'wrap', gap: space.md },
  # 8695ec0be3076b57c062f945bcf99ae1294b b47a7a175f6
    # 6431a255d33f079949b c9333c
    borderWidth: 1,
    # 16a0d763ffc05680e 71a80eaa
    # 6c6709ed78 958a1ad4ac1
    # 0fdf0aae746001a9b9ea481bec d553913e3d
    # 5547e217c1425780ae22f9512c92323f7dd 67aaddea9
  },
  # 11c96b24c5851c50d78b0b4c0ac86c4dbe6 4b487
  # 0e6afbc6f2430441a85b7c5f89864f2ae107 c8cc0a
  detailStats: { flex: 1, minWidth: 220, gap: space.sm },
  inputRow: { flexDirection: 'row', alignItems: 'center', gap: space.sm },
  input: {
    # 1d4ca715f4dd7b5163663e9 e3b037dfa
    # 5e40fca6623503e65f60823a 2d8ac6
    # 3af2c9fde50580a1e6f a48a3eb977
    fontWeight: '700',
    backgroundColor: surface.bg,
    # 03d2cec66a6596836a7745 e96c5b2
    borderColor: surface.border,
    borderRadius: radius.md,
    # b38b5d5b4e0871a76 6d8d997c
    paddingVertical: space.sm,
  # 932752627a286a2b74dd9fb4e1 0a73685198
  activity: {
    gap: space.xxs,
    paddingVertical: space.sm,
    # a84cc464ab01c7be 1e681a5
    borderBottomColor: surface.border,
  },
# 54e7f5ef0e7a2252819d61438ea703b4a8b 6a6411
