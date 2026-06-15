# 📜 Smart Contract

## Sepolia Contract Address

```txt
0xf0a4199e13516ade0e090b8847a06a114264136d
```

## Etherscan

https://sepolia.etherscan.io/address/0xf0a4199e13516ade0e090b8847a06a114264136d

## Frontend Repository

https://github.com/brunolcarli/EthereumSimpleRpgGame

---

# 🌐 NFT Metadata & Artwork

Achievement NFTs are permanently stored on IPFS.

## Metadata Base URI

```txt
ipfs://bafybeihebr72fet5ccpp5qrxwhxo3jimxb4hshffk6b6w3kej35oe4xtbu/
```

## Achievement Artwork Collection

```txt
ipfs://bafybeicqfg3ljruoum3e2vzbc37daxia7ahaegy364cxntvvkwqhqahpay/
```

---

# 🎖️ Achievement NFT Collection

| ID | NFT | Requirement |
|----|------|-------------|
| 1 | Goblin Slayer | Defeat 100 Goblins |
| 2 | Orc Slayer | Defeat 100 Orcs |
| 3 | Skeleton Slayer | Defeat 100 Skeletons |
| 4 | Zombie Slayer | Defeat 100 Zombies |
| 5 | Werewolf Slayer | Defeat 100 Werewolves |
| 6 | Dark Elf Slayer | Defeat 75 Dark Elves |
| 7 | Great Lizard Slayer | Defeat 75 Great Lizards |
| 8 | Troll Slayer | Defeat 50 Trolls |
| 9 | Dark Fairy Slayer | Defeat 25 Dark Fairies |
| 10 | Dragon Slayer | Defeat 20 Dragons |
| 100 | PVP Master | Defeat 100 Unique Players |

---

# 🚀 Deployment

This project uses Foundry for compilation, testing and deployment.

## Build

```bash
forge build
```

## Run Tests

```bash
forge test -vv
```

## Coverage

```bash
forge coverage --ir-minimum
```

Current test status:

```txt
60 / 60 Tests Passing
```

## Deploy

```bash
forge script script/DeployOnChainRpgBattle.s.sol \
    --rpc-url $SEPOLIA_RPC_URL \
    --private-key $PRIVATE_KEY \
    --broadcast \
    --verify
```

---

# 📦 Contract Statistics

- ⚔️ PvE Battles
- 🛡️ PvP Battles
- 🏰 Guild System
- 🏆 Guild Rankings
- 🎖️ Achievement NFTs
- 🌐 IPFS Metadata
- 💰 ETH Loot Drops
- 📈 Level Progression
- ❤️ Heal & Revive
- 👾 10 Unique Enemies
- 🎲 Critical Hit System
- ⚡ Fully On-Chain Gameplay

---

# 🏷️ Release

**v1.0.0**

The first complete playable version featuring:

- Character progression
- PvE combat
- PvP combat
- Guilds
- Guild rankings
- Achievement NFTs
- IPFS integration
- Complete frontend
- Full Foundry test suite