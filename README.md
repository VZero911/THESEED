<p align="center">
  <img src="https://img.shields.io/badge/The%20Seed-Blockchain%20%2F%20Data-f2c14e?style=for-the-badge&labelColor=07060f" alt="The Seed" />
  <img src="https://img.shields.io/badge/V0-Active-5fd38d?style=for-the-badge&labelColor=07060f" alt="V0" />
  <img src="https://img.shields.io/badge/L0-Chain%2031337-8f6cf0?style=for-the-badge&labelColor=07060f" alt="L0" />
</p>

<h1 align="center">The Seed</h1>
<p align="center"><b>Blockchain/Data infrastructure — L0 chain, smart contracts, on-chain game assets</b></p>

<p align="center">
  <code>ANTI-NETRUNNER</code> — Source integrity hashing prevents automated AI scraping and unauthorized code replication. Full source available on request with identity verification.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Solidity-Foundry-f2c14e?style=flat-square&logo=ethereum&logoColor=white&labelColor=07060f" />
  <img src="https://img.shields.io/badge/OpenZeppelin-UUPS-4E5EE4?style=flat-square&logo=openzeppelin&labelColor=07060f" />
  <img src="https://img.shields.io/badge/Python-FastAPI-3776ab?style=flat-square&logo=python&logoColor=white&labelColor=07060f" />
  <img src="https://img.shields.io/badge/React%20Native-Expo-000020?style=flat-square&logo=expo&labelColor=07060f" />
  <img src="https://img.shields.io/badge/three.js-3D-000000?style=flat-square&logo=three.js&labelColor=07060f" />
  <img src="https://img.shields.io/badge/PostgreSQL-DB-4169E1?style=flat-square&logo=postgresql&logoColor=white&labelColor=07060f" />
  <img src="https://img.shields.io/badge/License-MIT-c0caf5?style=flat-square&labelColor=07060f" />
</p>

---

## The Chain in 3D

<p align="center">
  <img src="screenshots/30-chain-3d.png" alt="The Seed — the chain in 3D" width="860" />
</p>
<p align="center"><sub>Live 3D visualization of the L0 blockchain — wallets, blocks, transactions, AI agents, all rendered in three.js</sub></p>

---

## What is The Seed?

An evolving **Blockchain/Data** infrastructure, and its first application: a monster-collecting game where monsters, runes and items are **tokenized assets** you truly own, on-chain. Your identity is a **wallet**; trades between players go through **smart contracts** (escrow, auctions, on-chain royalties); every action is **signed for free** (gasless) and relayed by the game.

### Stack

| Layer | What's inside |
|---|---|
| ⛓️ **Smart contracts** | Solidity · Foundry · OpenZeppelin UUPS — tokens, NFT monsters, on-chain **marketplace** (auctions, offers, escrow), polls, achievements · 261 contract test files, upgrade-safe |
| 🐍 **Backend** | Python · FastAPI · PostgreSQL · web3.py — SIWE login, encrypted wallet vaults, indexer, deterministic battle engine, 450+ species, 575+ stages, 272 backend test files |
| 🎮 **Game** | Expo · React Native (mobile + web) — summons, runes, dungeons, tower, world boss, guilds, marketplace (UI V2), 88 test files |
| 🖥️ **Admin console** | React · wagmi · **three.js** — live 3D view of the chain with wallets, block explorer, players, market, AI agents |
| 🤖 **AI** | ALICE automation, agent runs, MCP servers — the project is built to run itself |
| ✅ **Quality** | 4.5K+ unit test files, 18 browser walks on an isolated stack, security and licence scans, balance simulation |

### Numbers

<p align="center">
  <img src="https://img.shields.io/badge/LoC-585K-c0caf5?style=flat-square&labelColor=07060f" />
  <img src="https://img.shields.io/badge/Commits-1.2K-c0caf5?style=flat-square&labelColor=07060f" />
  <img src="https://img.shields.io/badge/Contracts-309-f2c14e?style=flat-square&labelColor=07060f" />
  <img src="https://img.shields.io/badge/Tests-4.5K+-ea4335?style=flat-square&labelColor=07060f" />
  <img src="https://img.shields.io/badge/Species-450+-5fd38d?style=flat-square&labelColor=07060f" />
  <img src="https://img.shields.io/badge/Stages-575+-8f6cf0?style=flat-square&labelColor=07060f" />
  <img src="https://img.shields.io/badge/Achievements-348-00ffcc?style=flat-square&labelColor=07060f" />
</p>

---

## Game Screenshots

<p align="center">
  <img src="screenshots/48-summon-v2.png" width="250" />
  <img src="screenshots/51-summon-altar-v2.png" width="250" />
  <img src="screenshots/49-inventory-v2.png" width="250" />
</p>
<p align="center"><sub>Summon screen · Altar · Inventory — V2 design</sub></p>

<p align="center">
  <img src="screenshots/50-battle-paused-v2.png" width="250" />
  <img src="screenshots/07-battle.png" width="250" />
  <img src="screenshots/17-achievements.png" width="250" />
</p>
<p align="center"><sub>Battle (paused) · Battle (live) · Achievements</sub></p>

<p align="center">
  <img src="screenshots/46-village-floating-island.png" alt="The Village — floating island" width="560" />
</p>
<p align="center"><sub>The Village — floating island (V2 art, will be replaced)</sub></p>

---

## Marketplace — Real On-Chain Trading

<p align="center">
  <img src="screenshots/40-market-listing.png" width="250" />
  <img src="screenshots/44-market-offer-received.png" width="250" />
  <img src="screenshots/45-market-journal.png" width="250" />
</p>
<p align="center"><sub>Listing a sale · Offer received · Trade journal — every transaction on-chain</sub></p>

The marketplace is a tested version of how **any asset** could be traded without a middleman:

| Step | In The Seed | Same mechanism for a real ticket |
|---|---|---|
| **Issue** | Only `MintManager` mints a monster NFT, within a daily budget | Organizer mints exactly 5K tickets, nobody can add one |
| **List** | Player signs a fixed-price sale or auction (anti-sniping) | Fan lists at face value; contract can cap the price |
| **Swap** | Escrow: monster + payment locked and swapped in one tx | Money and ticket change hands at once — no scam |
| **Share** | 2.5% of each sale goes to the creator, shown before signing | 5% of every resale goes to the artist, forever |
| **Prove** | Every sale is public on the chain, with full history | Provenance and authenticity checkable by anyone |

The contracts are upgrade-tested, covered by invariant tests (no asset is ever lost or created by a trade) and wait for an audit. **Real value needs audits and a legal frame first.**

---

## Chain Details

| Property | Value |
|---|---|
| Chain | L0 — chain ID 31337 |
| Consensus | Foundry / Anvil (dev), upgradeable for production |
| Gas | Gasless — all transactions relayed |
| Upgrades | UUPS (OpenZeppelin) — upgrade-safe, proxy pattern |
| Tokens | POC (contribution), MANA (in-game), NFT Monsters, NFT Items |
| Testing | 261 contract test files, invariant tests, upgrade simulation |

---

## Related

<p align="center">
  <a href="https://github.com/VZero911/A.L.I.C.E"><img src="https://img.shields.io/badge/A.L.I.C.E-AI%20Framework-00ffcc?style=for-the-badge&logo=github&labelColor=07060f" alt="ALICE" /></a>
  <a href="https://github.com/VZero911/THEROOT"><img src="https://img.shields.io/badge/THEROOT-Kernel%20%2F%20Infra-ea4335?style=for-the-badge&logo=github&labelColor=07060f" alt="THEROOT" /></a>
  <a href="https://github.com/VZero911/TOA-INFERNAL"><img src="https://img.shields.io/badge/TOA%20INFERNAL-Dark%20Fantasy-8f6cf0?style=for-the-badge&logo=github&labelColor=07060f" alt="TOA" /></a>
</p>

---

<p align="center"><i>Design By V0</i></p>
