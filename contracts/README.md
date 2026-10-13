# contracts

Solidity contracts built with [Foundry](https://getfoundry.sh/): solc **0.8.28** (EVM `cancun`), OpenZeppelin
Contracts (Upgradeable) **v5.7.0**, `openzeppelin-foundry-upgrades` **v0.4.2**. Rules: `../CLAUDE.md`. Design
decisions: ADR 0002 (UUPS), 0013 (POC and Mana Coin, soulbound), 0007 (token modules), 0008 (MintManager),
0009 (upgrade process and risks), 0010 (cap).

```
src/                    production contracts (all UUPS upgradeable)
  POC.sol               "Point of Contribution" (POC): soulbound ERC-20, contribution record
  ManaCoin.sol          "Mana Coin" (MANA): soulbound ERC-20, the in-ecosystem currency
  base/SoulboundERC20Upgradeable.sol   shared base: capped, burnable, pausable, permit, mint/burn only
  Monster.sol           ERC-721 monsters: burnable, safeMint -> tokenId, tokenURI = baseURI + id, no Enumerable
  Items.sol             ERC-1155 items (skeleton)
  MintManager.sol       only minter of the tokens; operators mint through it, within a per-token budget per epoch
  interfaces/           ISoulboundToken, IMonster, IItems, IMintManager
test/                   unit, fuzz, access control, upgrade, integration, deploy-script tests
  invariants/           StdInvariant suites + handler
  mocks/                *V2Mock: example V2 of each contract
  utils/Fixture.sol     whole system behind proxies, wired like the deploy script
script/
  Deploy.s.sol          deploy + wire + write deployments/<chainId>.json
  Upgrade.s.sol         validated upgrade of one proxy
  check-storage-layout.sh   fails if a src/ contract declares a bare state variable
  check_storage_diff.py      fails unless storage structs only grow at the end (baseline: storage-baseline.json; `--update` records an append)
  check-coverage.sh     forge coverage on src/ with a minimum (90%)
deployments/            <chainId>.json address books (31337 = local Anvil, git-ignored)
lib/                    git submodules: forge-std, OpenZeppelin, openzeppelin-foundry-upgrades
```

## How the pieces fit

```
 backend / AI agent (OPERATOR_ROLE)
            │ mintPoc(to, amount) · mintMana(to, amount) · mintMonster(to)
            ▼
     MintManager  ── checks the POC / MANA epoch budgets
            │ MINTER_ROLE
   ┌────────┬───────┼─────────┬────────┐
   ▼        ▼       ▼         ▼
  POC   ManaCoin  Monster   Items    (tokens know nothing about MintManager)

POC and MANA are soulbound: mint and burn only, `transfer`/`transferFrom` always revert.
Spending = the holder burns, or approves a spender (also via a signed EIP-2612 permit) who calls `burnFrom`.
```

Every contract is an **ERC1967 proxy** (permanent address, holds the data) in front of an **implementation**
(the code). Always use the **proxy** address; the implementation is only relevant for upgrades.

## Roles and permissions

A role is a `bytes32` id (`keccak256("MINTER_ROLE")`…; the admin role is `0x00…00`). `DEFAULT_ADMIN_ROLE` grants
and revokes all roles of its contract but holds no other power by itself.

| Action | POC, ManaCoin | Monster | Items | MintManager |
|---|---|---|---|---|
| Mint | `MINTER_ROLE` → `mint` | `MINTER_ROLE` → `safeMint` | `MINTER_ROLE` → `mint`, `mintBatch` | `OPERATOR_ROLE` → `mintPoc`, `mintMana`, `mintMonster` |
| Transfer | **nobody** (soulbound) | owner or approved | owner or approved | — |
| Burn | holder (`burn`) or approved spender (`burnFrom`) | owner or approved (`burn`) | — | — |
| Pause / unpause | `PAUSER_ROLE` | — | — | — |
| Metadata | — | `METADATA_ROLE` → `setBaseURI` | `METADATA_ROLE` → `setURI` | — |
| Parameters | — | — | — | `DEFAULT_ADMIN_ROLE` → `setEpochBudget(token, …)`, `setEpochDuration` |
| Upgrade | `UPGRADER_ROLE` | `UPGRADER_ROLE` | `UPGRADER_ROLE` | `UPGRADER_ROLE` |
| Grant / revoke roles | `DEFAULT_ADMIN_ROLE` | `DEFAULT_ADMIN_ROLE` | `DEFAULT_ADMIN_ROLE` | `DEFAULT_ADMIN_ROLE` |

Who holds what after `Deploy.s.sol`:

| Role | Holder |
|---|---|
| `MINTER_ROLE` on POC, ManaCoin, Monster, Items | the MintManager proxy, only |
| `OPERATOR_ROLE` on MintManager | `OPERATOR_ADDRESS` (local: Anvil account #1, for the backend) |
| `PAUSER_ROLE`, `METADATA_ROLE`, `UPGRADER_ROLE`, `DEFAULT_ADMIN_ROLE` | `PAUSER_ADDRESS`, `METADATA_ADDRESS`, `UPGRADER_ADDRESS`, `ADMIN_ADDRESS` (all default to the deployer; local: Anvil account #0) |

If `ADMIN_ADDRESS` differs from the deployer, the script hands admin over and the deployer renounces it.
Later (before any real value): admin and upgrader move to a timelock controlled by a Safe multisig (ADR 0009).

## Commands

From the repository root (the Makefile is the single entry point):

```bash
make test-contracts       # forge test: everything except the plugin validation (skipped, see below)
make test-invariants      # invariant suites only (256 runs x depth 64; CI profile 512 x 64)
make check-upgrades       # forge clean + OpenZeppelin upgrade-safety validation + no-bare-variable check
make coverage-contracts   # coverage on src/, fails under 90%
make lint-contracts       # forge fmt --check
make up && make deploy-local   # deploy on the local Anvil chain, prints deployments/31337.json
make export-abis          # ABIs -> backend/app/abis, web/src/abis (generated, git-ignored)
```

Directly in `contracts/`: `forge build`, `forge test`, `forge fmt`, `FOUNDRY_PROFILE=ci forge test` (10 000 fuzz runs).
After a fresh clone: `git submodule update --init --recursive` (or `make install`).

Why the plugin validation is separate: it shells out to `npx @openzeppelin/upgrades-core` (needs Node.js, network
the first time) and reads build-info files, which must come from a clean build. `UpgradeSafetyTest` therefore
skips unless `VALIDATE_UPGRADES=true`, which `make check-upgrades` and CI set after `forge clean`.

## Deploying

`script/Deploy.s.sol` hard-codes no key and no address. The broadcasting account comes from the forge CLI, the
rest from environment variables (all optional):

| Variable | Default |
|---|---|
| `ADMIN_ADDRESS`, `PAUSER_ADDRESS`, `UPGRADER_ADDRESS`, `METADATA_ADDRESS`, `OPERATOR_ADDRESS` | deployer |
| `POC_CAP`, `MANA_CAP` (wei) | `1e27` each (1 000 000 000 tokens) |
| `POC_EPOCH_BUDGET` (wei) | `1e22` (10 000 POC per epoch) |
| `MANA_EPOCH_BUDGET` (wei) | `1e23` (100 000 MANA per epoch) |
| `EPOCH_DURATION` (seconds) | `86400` |
| `MONSTER_BASE_URI` | `http://localhost:8000/metadata/monsters/` |
| `ITEMS_URI` | `http://localhost:8000/metadata/items/{id}` |

**Local**: `make deploy-local` uses Anvil's *unlocked* dev accounts (`--unlocked --sender`), so no private key is
needed at all. It writes `deployments/31337.json`:

```json
{
  "schemaVersion": 1, "project": "The Seed", "chainId": 31337, "startBlock": 0, "version": "1.0.0", "deployer": "0x…",
  "contracts": { "POC": { "proxy": "0x…", "implementation": "0x…" }, "ManaCoin": {…}, "Monster": {…}, "Items": {…}, "MintManager": {…} },
  "roles": { "admin": "0x…", "pauser": "0x…", "upgrader": "0x…", "metadataManager": "0x…", "operator": "0x…" }
}
```

`startBlock` is the block before the first deployment transaction: the indexer starts reading events there.
Anvil is ephemeral: after `make down && make up`, run `make deploy-local` again.

**Testnet** (phase 5): use an encrypted keystore, never a key in a file:
`cast wallet import deployer --interactive`, then
`forge script script/Deploy.s.sol --rpc-url <rpc> --account deployer --sender <address> --broadcast`.

## Upgrading

Full procedure and risks: ADR 0009. Short version:

1. Write `MonsterV2` inheriting `Monster`; new state in a new ERC-7201 namespace; `/// @custom:oz-upgrades-from Monster`;
   one-off setup in `initializeV2(...) reinitializer(2)`; bump `version()`. Template: `test/mocks/MonsterV2Mock.sol`.
2. Add an upgrade test (template: `test/Upgrades.t.sol`), then `make check-upgrades`.
3. Locally:
   ```bash
   make upgrade-local CONTRACT=Monster NEW_CONTRACT=MonsterV2Mock.sol \
     UPGRADE_CALLDATA=$(cast calldata "initializeV2(uint256)" 42)
   ```
   `script/Upgrade.s.sol` refuses to run if the sender lacks `UPGRADER_ROLE`, validates the layout, then upgrades
   and calls `initializeV2` in the same transaction. The target updates `deployments/31337.json`.

## Checklist: adding a new upgradeable contract

- [ ] Inherit `Initializable`, the OpenZeppelin `…Upgradeable` modules you need, `AccessControlUpgradeable`,
      `UUPSUpgradeable` (never a non-upgradeable OZ contract, never re-implement an OZ module).
- [ ] Constructor: only `_disableInitializers()`, annotated `/// @custom:oz-upgrades-unsafe-allow constructor`.
- [ ] `initialize(...) external initializer`: call every parent `__X_init`, reject zero addresses, grant roles.
- [ ] `_authorizeUpgrade` gated by `onlyRole(UPGRADER_ROLE)`.
- [ ] Own state only in a struct at an ERC-7201 slot: `/// @custom:storage-location erc7201:theseed.storage.<Name>`,
      slot from `cast index-erc7201 theseed.storage.<Name>`, formula in a comment. No bare state variable, no
      `immutable` (it lives in the implementation code, not the proxy).
- [ ] Custom errors (no `require` strings), events for every important state change, full NatSpec, `version()`.
- [ ] Interface in `src/interfaces/`; no game logic in token contracts; no circular dependency.
- [ ] Tests: unit, access control for every restricted function, both initialization guards, a `V2Mock` + upgrade
      test, fuzz where inputs vary; add it to `UpgradeSafetyTest` and to `Deploy.s.sol` / the deployment file.
- [ ] `make lint-contracts test-contracts check-upgrades coverage-contracts` green; ADR if a design choice was made.

## 🧅 Layers

The contracts are **L0** (roots of trust and rules), the blockchain project. Nothing above touches them except through audited, narrow interfaces. Full model: [`docs/ARCHITECTURE_LAYERS.md`](../docs/ARCHITECTURE_LAYERS.md).

---

*© 2026 V (VZero911). Built by V with SYSTEM, an AI agent powered by Claude (Anthropic). See [NOTICE](../NOTICE.md).*
