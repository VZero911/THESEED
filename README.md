<p align="center">
  <img src="https://img.shields.io/badge/THESEED-Web3%20%2B%20AI-f2c14e?style=for-the-badge&labelColor=07060f" alt="THESEED" />
  <img src="https://img.shields.io/badge/V0-Active-5fd38d?style=for-the-badge&labelColor=07060f" alt="V0" />
  <img src="https://img.shields.io/badge/Chain-31337-8f6cf0?style=for-the-badge&labelColor=07060f" alt="L0" />
</p>

<p align="center"><b>Web3 + AI monster-collecting game with on-chain assets</b></p>

<p align="center">
  <img src="https://img.shields.io/badge/Solidity-Foundry-f2a94e?style=flat-square&logo=ethereum&logoColor=white&labelColor=07060f" />
  <img src="https://img.shields.io/badge/Python-FastAPI-3776ab?style=flat-square&logo=python&logoColor=white&labelColor=07060f" />
  <img src="https://img.shields.io/badge/React%20Native-Expo-000020?style=flat-square&logo=expo&logoColor=white&labelColor=07060f" />
  <img src="https://img.shields.io/badge/three.js-3D-049EF4?style=flat-square&logo=three.js&logoColor=white&labelColor=07060f" />
  <img src="https://img.shields.io/badge/PostgreSQL-16-4169E1?style=flat-square&logo=postgresql&logoColor=white&labelColor=07060f" />
  <img src="https://img.shields.io/badge/OpenZeppelin-UUPS-4E5EE4?style=flat-square&logo=openzeppelin&logoColor=white&labelColor=07060f" />
</p>

---

## What is The Seed?

An evolving **Web3 + AI** environment. Its first use: a monster-collecting game where monsters, runes and items are **tokenized assets** you truly own, on-chain.

Your identity is a **wallet**. Trades go through **smart contracts** (escrow, auctions, on-chain royalties). Every action is **signed for free** (gasless) and relayed by the game.

## Metrics

<p align="center">
  <img src="https://img.shields.io/badge/LoC-585K-c0caf5?style=flat-square&labelColor=07060f" />
  <img src="https://img.shields.io/badge/Commits-1.2K-c0caf5?style=flat-square&labelColor=07060f" />
  <img src="https://img.shields.io/badge/Contracts-309-f2c14e?style=flat-square&labelColor=07060f" />
  <img src="https://img.shields.io/badge/Backend%20tests-272-ea4335?style=flat-square&labelColor=07060f" />
  <img src="https://img.shields.io/badge/Contract%20tests-261-ea4335?style=flat-square&labelColor=07060f" />
  <img src="https://img.shields.io/badge/Game%20tests-88-ea4335?style=flat-square&labelColor=07060f" />
  <img src="https://img.shields.io/badge/Species-450%2B-5fd38d?style=flat-square&labelColor=07060f" />
  <img src="https://img.shields.io/badge/Stages-575%2B-5fd38d?style=flat-square&labelColor=07060f" />
</p>

## Stack

| Layer | What's inside |
|---|---|
| ⛓️ **Smart contracts** | Solidity · Foundry · OpenZeppelin UUPS — tokens, NFT monsters, on-chain **marketplace** (auctions, offers, escrow), polls, achievements · 261 contract test files, upgrade-safe |
| 🐍 **Backend** | Python · FastAPI · PostgreSQL · web3.py — SIWE login, encrypted wallet vaults, indexer, deterministic battle engine, 450+ species, 575+ stages, 272 backend test files |
| 🎮 **Game** | Expo · React Native (mobile + web) — summons, runes, dungeons, tower, world boss, guilds, marketplace UI V2 |
| 🖥️ **Admin console** | React · wagmi · **three.js** — live 3D view of the chain with wallets, block explorer, players, market, AI agents |
| 🤖 **AI** | Automation registry, agent runs, MCP servers — the project is built to run itself |
| ✅ **Quality** | 621 test files, 18 browser walks on an isolated stack, security and licence scans, balance simulation |

## Screenshots

<p align="center">
  <img src="screenshots/30-chain-3d.png" alt="The chain in 3D" width="860" />
</p>

<details>
<summary><b>More screens</b></summary>

<p align="center">
  <img src="screenshots/50-battle-paused-v2.png" width="250" />
  <img src="screenshots/51-summon-altar-v2.png" width="250" />
  <img src="screenshots/49-inventory-v2.png" width="250" />
</p>
<p align="center"><img src="screenshots/46-village-floating-island.png" alt="The Village" width="560" /></p>
<p align="center">
  <img src="screenshots/40-market-listing.png" width="250" />
  <img src="screenshots/44-market-offer-received.png" width="250" />
  <img src="screenshots/45-market-journal.png" width="250" />
</p>

</details>

## Real-world example: a concert ticket

The marketplace is a small, tested version of how **any** asset could be traded without a middleman:

| Step | In The Seed | Same mechanism for a ticket |
|---|---|---|
| **Issue** | Only `MintManager` mints NFTs, within a daily budget | Organizer mints exactly 5K tickets |
| **List** | Player signs a fixed-price sale or auction | Fan lists at face value; contract can cap price |
| **Swap** | Escrow: monster + payment locked, swapped atomically | Money and ticket change hands at once |
| **Share** | 2.5% of each sale goes to creator, shown before signing | 5% of every resale goes to artist, forever |
| **Prove** | Every sale is public on-chain with full history | Provenance checkable by anyone |

## Related

<p align="center">
  <a href="https://github.com/VZero911/A.L.I.C.E"><img src="https://img.shields.io/badge/A.L.I.C.E-AI%20Framework-00ffcc?style=for-the-badge&logo=github&labelColor=07060f" alt="ALICE" /></a>
  <a href="https://github.com/VZero911/THEROOT"><img src="https://img.shields.io/badge/THEROOT-Infrastructure-ea4335?style=for-the-badge&logo=github&labelColor=07060f" alt="THEROOT" /></a>
</p>

## Looking for artists

- 🧊 **3D artists** — monsters, props, Village island (glTF, low-mid poly, three.js + mobile)
- 🖌️ **2D artists** — monster art, rune/item icons, banners, key art
- 🧩 **UI artists** — game screens, V2 design tokens

Contact: [vzero911@gmail.com](mailto:vzero911@gmail.com) · Discord **vzero911**

---

<p align="center"><i>Design By V0</i></p>
