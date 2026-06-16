# ⚔️ Simple Battle RPG - Solidity Smart Contract

An on-chain medieval fantasy RPG built entirely with Solidity and Ethereum smart contracts.

Players can create heroes, battle monsters, challenge other players, join guilds, earn achievement NFTs, gain EXP, level up, earn ETH loot, heal, revive and progress through a fully on-chain RPG ecosystem.

---

# 🌐 Live Frontend

DApp frontend:

https://ethereum-simple-rpg-game.vercel.app/

---

# 📜 Smart Contract

## Sepolia Contract Address

```txt
0xce7db8f0442fa80c0fab9799e069a94fa477089d
```

## Etherscan

https://sepolia.etherscan.io/address/0xce7db8f0442fa80c0fab9799e069a94fa477089d

## Frontend Repository

https://github.com/brunolcarli/EthereumSimpleRpgGame

---

# 🚀 Features

* 🧙 Multiple character classes
* ⚔️ On-chain PvE battles
* 🛡️ On-chain PvP battles
* 👾 Multiple enemies with unique stats
* 📈 EXP and level-up system
* ❤️ HP and damage mechanics
* ☠️ Death and revive mechanics
* 🧪 Heal system
* 💰 ETH-based gameplay economy
* 🎲 Critical hit system
* 🎁 Random ETH loot drops
* 🏰 Guild system
* 👑 Guild ownership and membership management
* 🏆 On-chain guild ranking
* 🎖️ Achievement NFT rewards
* 🛡️ Anti-farming PvP protection
* 📊 Dynamic guild point calculation
* 📜 Solidity combat event logs
* 🔥 Dynamic battle pricing
* 🏹 Physical and magic combat systems

---

# 🎮 Game Mechanics

## Character Classes

| Class       | Description         |
| ----------- | ------------------- |
| 🗡️ Warrior | High HP and defense |
| 🧙 Mage     | High magic damage   |
| 🏹 Ranger   | Balanced fighter    |

Each class receives unique stat bonuses when leveling up.

---

# 👾 Enemies

The game currently includes 10 enemies:

| Enemy           | Description              |
| --------------- | ------------------------ |
| 👺 Goblin       | Weak beginner enemy      |
| 🪓 Orc          | Strong melee fighter     |
| 💀 Skeleton     | Balanced undead          |
| 🧟 Zombie       | High HP tank             |
| 🐺 Werewolf     | Fast attacker            |
| 🧝 Dark Elf     | Magic attacker           |
| 🦎 Great Lizard | Agile reptilian creature |
| 🪨 Troll        | Massive brute            |
| 🧚 Dark Fairy   | Powerful magical enemy   |
| 🐉 Dragon       | Endgame boss             |

Each enemy has:

* HP
* Attack
* Defense
* Magic
* EXP reward
* ETH reward chance

---

# ⚔️ Battle Systems

## PvE Battles

Players fight monsters through:

```solidity
battle(enemyId, rounds)
```

Features:

* Critical hits
* Damage calculations
* ETH rewards
* EXP rewards
* Level-up logic
* Death system

---

## PvP Battles

Players challenge other players through:

```solidity
challengePlayer(targetPlayer, rounds)
```

Features:

* Player versus player combat
* Critical hits
* EXP rewards
* Guild warfare
* Death and revive mechanics
* Class-based combat calculations

---

# 🏰 Guild System

Players can:

* Create guilds
* Join guilds
* Leave guilds
* Manage guild membership
* Earn guild points
* Compete in guild rankings

Guild rankings are stored entirely on-chain.

## Anti-Farming Protection

To prevent abuse:

* Players cannot challenge opponents with a level difference greater than 10 levels
* Defeating low-level opponents grants fewer guild points
* Defeating stronger opponents grants more guild points
* Guild points scale according to PvP difficulty

## Guild Rankings

Guild points are earned through PvP victories.

Top guilds are tracked directly on-chain and displayed in the frontend ranking system.

---

# 🎖️ Achievement NFTs

Players can unlock and mint achievement NFTs by completing special objectives.

Current achievements:

| ID  | Achievement         |
| --- | ------------------- |
| 1   | Goblin Slayer       |
| 2   | Orc Slayer          |
| 3   | Skeleton Slayer     |
| 4   | Zombie Slayer       |
| 5   | Werewolf Slayer     |
| 6   | Dark Elf Slayer     |
| 7   | Great Lizard Slayer |
| 8   | Troll Slayer        |
| 9   | Dark Fairy Slayer   |
| 10  | Dragon Slayer       |
| 100 | PvP Master          |

Achievement metadata and artwork are hosted on IPFS.

Players can claim NFTs through:

```solidity
claimAchievement(achievementId)
```

---

# 📈 Level System

Players gain EXP after victories.

When enough EXP is accumulated:

* Level increases
* Max HP increases
* Stats increase
* HP is restored

Each class receives unique stat bonuses during progression.

---

# ❤️ Healing & Revive

## Heal

Restore a living player's HP:

```solidity
heal(playerAddress)
```

---

## Revive

Revive dead players:

```solidity
revive(playerAddress)
```

---

# 💰 ETH Economy

## Registration Fee

```solidity
registerPrice = 0.0001 ether
```

---

## Common Action Cost

```solidity
commonPrice = 0.001 ether
```

Used for:

* PvP Battles
* Heal
* Revive

---

## Dynamic Battle Cost

Battle cost scales according to rounds:

```solidity
battleCost = commonPrice * rounds
```

Example:

| Rounds | ETH Cost  |
| ------ | --------- |
| 1      | 0.001 ETH |
| 5      | 0.005 ETH |
| 10     | 0.01 ETH  |

---

# 🎁 ETH Loot Drops

Enemies can randomly drop ETH after defeat.

Example combat event:

```solidity
emit battleLog(round, "Enemy dropped ether", enemy.gold);
```

Stronger enemies have larger reward pools.

---

# 🎲 Randomness System

The game currently uses pseudo-randomness based on:

* block.timestamp
* block.prevrandao
* block.number
* msg.sender

Used for:

* Critical hits
* Damage variance
* ETH reward drops

---

# 🔥 Critical Hits

Players and enemies can land critical strikes.

Critical damage:

```solidity
damage * 2
```

Combat logs display critical attacks in real time.

---

# 📜 Solidity Events

Combat actions emit Solidity events:

```solidity
event battleLog(uint8 round, string message, uint256 value);
```

Examples:

* Damage dealt
* Critical damage
* Monster defeat
* Player defeat
* ETH rewards
* Level ups

---

# 🧪 Example Gameplay Flow

1. Connect wallet
2. Register hero
3. Battle monsters
4. Gain EXP
5. Level up
6. Earn ETH loot
7. Join a guild
8. Fight enemy guilds
9. Unlock achievement NFTs
10. Climb the rankings

---

# 📦 Smart Contract Functions

## Player Functions

* `registerPlayer()`
* `battle()`
* `challengePlayer()`
* `heal()`
* `revive()`
* `claimAchievement()`

## Guild Functions

* `createGuild()`
* `joinGuild()`
* `leaveGuild()`
* `addGuildMember()`
* `removeGuildMember()`
* `getGuilds()`
* `getTopGuilds()`

## Combat Functions

* `calcDamageForPlayer()`
* `calcDamageForEnemy()`
* `calcDamageForPlayerVsPlayer()`

## Utility Functions

* `randomNumber()`
* `expUp()`
* `getLvUpBonus()`

---

# 👑 Owner Functions

## Withdraw Contract Balance

```solidity
withdraw()
```

Protected by:

```solidity
onlyOwner
```

---

# 🔮 Future Improvements

* 🖼️ NFT Characters
* 🗡️ Equipment System
* 🎒 Inventory System
* 🪙 ERC20 In-Game Currency
* 🐲 Raid Bosses
* 🌎 Open World Progression
* 🎲 Chainlink VRF Integration
* ⚔️ PvP Seasons
* 🏆 Seasonal Guild Rankings
* 👑 World Bosses
* 🏰 Guild Wars

---

# ⚠️ Disclaimer

This project was created for educational and portfolio purposes.

The randomness system used by the game is pseudo-random and is NOT secure for production-grade blockchain games.

For production deployments, a verifiable randomness solution such as Chainlink VRF should be used.

This project is NOT audited.

---

# 📚 Learning Goals

This project explores:

* Solidity
* Smart Contracts
* Ethereum
* Foundry
* NFT Integration
* IPFS
* On-chain Game Design
* PvP Systems
* Guild Systems
* Web3 Architecture
* Blockchain Game Development




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



---

# 📄 License

MIT License

---

# 👨‍💻 Author

Beelzebruno — 2026

Built as a blockchain and Solidity learning project.