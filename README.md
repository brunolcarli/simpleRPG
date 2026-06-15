# ⚔️ Simple Battle RPG - Solidity Smart Contract

An on-chain medieval fantasy RPG built entirely with Solidity and Ethereum smart contracts.

Players can create heroes, battle monsters, challenge other players, join guilds, earn achievement NFTs, gain EXP, level up, earn ETH loot, and progress through a persistent on-chain world.

---

# 🌐 Live Frontend

DApp Frontend:

https://ethereum-simple-rpg-game.vercel.app/

---

# 📜 Smart Contract

## Sepolia Contract Address

```txt
0x494f4a2c19415b74a70cd8dd6927c309ccfb6723
```

## Etherscan

https://sepolia.etherscan.io/address/0x494f4a2c19415b74a70cd8dd6927c309ccfb6723

## Frontend Repository

https://github.com/brunolcarli/EthereumSimpleRpgGame

---

# 🚀 Features

* 🧙 Multiple character classes
* ⚔️ On-chain PvE battles
* 🛡️ On-chain PvP battles
* 👾 10 unique enemies
* 📈 EXP and level-up system
* ❤️ HP and damage mechanics
* ☠️ Death and revive mechanics
* 🧪 Healing system
* 💰 ETH-based gameplay economy
* 🎲 Critical hit system
* 🎁 Random ETH loot drops
* 🏰 Guild system
* 👑 Guild ownership and member management
* 🏆 Top 5 guild ranking
* ⚔️ Guild versus guild point rewards
* 🎖️ Achievement system
* 🖼️ ERC721 Achievement NFTs
* 🌐 IPFS-hosted NFT metadata and artwork
* 📜 Solidity combat event logs
* 🔥 Dynamic battle pricing
* 🏹 Physical and magical combat systems

---

# 🛠 Built With

* Solidity `0.8.35`
* Foundry
* OpenZeppelin Contracts
* Ethereum Virtual Machine (EVM)
* IPFS
* Pinata
* ethers.js
* Vercel

---

# 🎮 Character Classes

| Class       | Description         |
| ----------- | ------------------- |
| 🗡️ Warrior | High HP and defense |
| 🧙 Mage     | High magic damage   |
| 🏹 Ranger   | Balanced fighter    |

Each class receives unique stat bonuses on level-up.

---

# 👾 Enemies

The game currently includes 10 enemies:

| Enemy           | Description            |
| --------------- | ---------------------- |
| 👺 Goblin       | Weak beginner enemy    |
| 🪓 Orc          | Strong melee fighter   |
| 💀 Skeleton     | Balanced undead        |
| 🧟 Zombie       | High HP tank           |
| 🐺 Werewolf     | Fast attacker          |
| 🧝 Dark Elf     | Magic attacker         |
| 🦎 Great Lizard | Agile reptile creature |
| 🪨 Troll        | Massive brute          |
| 🧚 Dark Fairy   | Powerful magic enemy   |
| 🐉 Dragon       | Endgame boss           |

Each enemy contains:

* HP
* Attack
* Defense
* Magic
* EXP reward
* ETH reward

---

# ⚔️ PvE Battles

Players can fight monsters through:

```solidity
battle(enemyId, rounds)
```

Features:

* Critical hits
* Damage calculations
* ETH loot rewards
* EXP rewards
* Level-up logic
* Death mechanics

Combat is processed entirely on-chain.

---

# 🛡️ PvP Battles

Players can challenge other players:

```solidity
challengePlayer(targetPlayer, rounds)
```

Features:

* Player versus player combat
* Class-based damage calculations
* Critical hits
* Death mechanics
* Guild point rewards
* Achievement progress

All combat outcomes are permanently recorded on-chain.

---

# 🏰 Guild System

Players can organize themselves into guilds.

## Guild Features

* Create guilds
* Join guilds
* Leave guilds
* Guild ownership
* Add members
* Remove members
* Guild rankings
* Top 5 guild leaderboard

Guilds are fully managed on-chain.

---

# 🏆 Guild Wars

When a player defeats a member of another guild:

* Winning guild gains points
* Losing guild loses points

This creates a persistent competitive ecosystem between guilds.

Guild rankings are updated automatically.

---

# 🎖️ Achievement NFTs

The game includes ERC721 achievement NFTs.

Achievements are permanently earned and owned by players.

All NFT metadata and artwork are hosted on IPFS.

---

## Monster Slayer Collection

| NFT                 | Requirement             |
| ------------------- | ----------------------- |
| Goblin Slayer       | Defeat 100 Goblins      |
| Orc Slayer          | Defeat 100 Orcs         |
| Skeleton Slayer     | Defeat 100 Skeletons    |
| Zombie Slayer       | Defeat 100 Zombies      |
| Werewolf Slayer     | Defeat 100 Werewolves   |
| Dark Elf Slayer     | Defeat 75 Dark Elves    |
| Great Lizard Slayer | Defeat 75 Great Lizards |
| Troll Slayer        | Defeat 50 Trolls        |
| Dark Fairy Slayer   | Defeat 25 Dark Fairies  |
| Dragon Slayer       | Defeat 20 Dragons       |

---

## PvP Achievement

| NFT        | Requirement               |
| ---------- | ------------------------- |
| PVP Master | Defeat 100 unique players |

Unique player kills are tracked separately to prevent farming the same opponent repeatedly.

---

# 📈 Level System

Players gain EXP after victories.

When enough EXP is accumulated:

* Level increases
* Max HP increases
* Stats increase
* HP is fully restored

Each class receives unique progression bonuses.

---

# ❤️ Healing & Revive

## Heal

Restore HP to an injured player:

```solidity
heal(playerAddress)
```

---

## Revive

Bring a dead player back to life:

```solidity
revive(playerAddress)
```

---

# 💰 ETH Economy

## Registration Cost

```solidity
registerPrice = 0.0001 ether
```

---

## Common Action Cost

```solidity
commonPrice = 0.001 ether
```

Used for:

* PvE battles
* PvP battles
* Healing
* Reviving

---

## Dynamic Battle Pricing

Battle costs scale with rounds:

```solidity
battleCost = commonPrice * rounds
```

Example:

| Rounds | Cost      |
| ------ | --------- |
| 1      | 0.001 ETH |
| 5      | 0.005 ETH |
| 10     | 0.01 ETH  |

---

# 🎁 ETH Loot Drops

Enemies can randomly drop ETH after defeat.

Example:

```solidity
emit battleLog(round, "Enemy dropped ether", enemy.gold);
```

Stronger enemies provide larger rewards.

---

# 🎲 Randomness System

The game currently uses pseudo-randomness based on:

* block.timestamp
* block.prevrandao
* msg.sender
* block.number

Used for:

* Critical hits
* ETH drops
* Combat variance

---

# 🔥 Critical Hits

Players and enemies can land critical strikes.

Critical attacks deal:

```solidity
damage * 2
```

Critical hits are emitted through battle events and displayed in the frontend.

---

# 📜 Solidity Events

Combat emits events directly from the smart contract:

```solidity
event battleLog(uint8 round, string message, uint value);
```

Examples:

* Damage dealt
* Critical hits
* Level up
* Monster defeat
* Player death
* ETH rewards

---

# 🧪 Example Gameplay Loop

1. Connect wallet
2. Register hero
3. Battle monsters
4. Gain EXP
5. Level up
6. Earn ETH loot
7. Join or create a guild
8. Challenge players
9. Earn achievement NFTs
10. Climb the guild rankings
11. Become a legendary adventurer

---

# 📦 Main Functions

## Player Functions

* `registerPlayer()`
* `battle()`
* `challengePlayer()`
* `heal()`
* `revive()`

## Guild Functions

* `createGuild()`
* `joinGuild()`
* `leaveGuild()`
* `addGuildMember()`
* `removeGuildMember()`
* `getGuilds()`
* `getTopGuilds()`

## Achievement Functions

* `claimAchievement()`

## Combat Functions

* `calcDamageForPlayer()`
* `calcDamageForEnemy()`
* `calcDamageForPlayerVsPlayer()`

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

* 🪙 ERC20 in-game currency
* 🎒 Inventory system
* 🗡️ Equipment system
* 🛒 Marketplace
* 🐲 Raid bosses
* 🏰 Guild treasury
* ⚡ Guild versus guild tournaments
* 🌎 Persistent world map
* 🎵 Sound effects
* 🧠 Chainlink VRF integration
* 📱 Mobile-first interface
* 🧬 Character NFTs

---

# ⚠️ Disclaimer

This project was created for educational and portfolio purposes.

The randomness implementation is pseudo-random and should not be considered secure for production-grade blockchain games.

For production environments, a verifiable randomness solution such as Chainlink VRF should be used.

---

# 📚 Learning Goals

This project explores:

* Solidity
* Smart Contracts
* Foundry
* ERC721 NFTs
* Ethereum Game Design
* EVM Mechanics
* Payable Functions
* Event Systems
* On-Chain State Management
* PvP Mechanics
* Guild Systems
* IPFS Metadata
* Web3 Development
* Blockchain Gaming

---

# 📄 License

MIT License

---

# 👨‍💻 Author

**beelzebruno — 2026**

Built as a blockchain development, Solidity and Web3 learning project.
