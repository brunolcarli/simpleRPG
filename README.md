# ⚔️ Simple Battle RPG - Solidity Smart Contract

An on-chain medieval fantasy RPG battle system built with Solidity and Ethereum smart contracts.

Players can create heroes, battle monsters, challenge other players, gain EXP, level up, earn ETH loot, heal, revive, and fight entirely on-chain using Ethereum transactions.

---

# 🌐 Live Frontend

DApp frontend:

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

- 🧙 Multiple character classes
- ⚔️ On-chain PvE battles
- 🛡️ On-chain PvP battles
- 👾 Multiple enemies with unique stats
- 📈 EXP and level-up system
- ❤️ HP / Damage mechanics
- ☠️ Death and revive mechanics
- 🧪 Heal system
- 💰 ETH-based gameplay economy
- 🎲 Critical hit system
- 🎁 Random ETH loot drops
- 📜 Solidity combat event logs
- 🔥 Dynamic battle pricing
- 🏹 Magic vs physical combat systems

---

# 🛠 Built With

- Solidity `0.8.18`
- Ethereum Virtual Machine (EVM)
- Remix IDE

---

# 🎮 Game Mechanics

## Character Classes

| Class | Description |
|---|---|
| 🗡️ Warrior | High HP and defense |
| 🧙 Mage | High magic damage |
| 🏹 Ranger | Balanced fighter |

---

# 👾 Enemies

The game currently includes 10 enemies:

| Enemy | Description |
|---|---|
| 👺 Goblin | Weak beginner enemy |
| 🪓 Orc | Strong melee fighter |
| 💀 Skeleton | Balanced undead |
| 🧟 Zombie | High HP tank |
| 🐺 Werewolf | Fast attacker |
| 🧝 Dark Elf | Magic attacker |
| 🦎 Great Lizard | Agile reptile creature |
| 🪨 Troll | Massive brute |
| 🧚 Dark Fairy | Powerful magic enemy |
| 🐉 Dragon | Endgame boss |

Each enemy has:

- HP
- Attack
- Defense
- Magic
- EXP reward
- ETH reward drop chance

---

# ⚔️ Battle Systems

## PvE Battles

Players can fight monsters using:

```solidity
battle(enemyId, rounds)
```

Combat is fully processed on-chain.

Features include:

- Critical hits
- Damage calculations
- Random ETH rewards
- EXP rewards
- Level-up logic
- Death system

---

## PvP Battles

Players can challenge real players:

```solidity
challengePlayer(targetPlayer, rounds)
```

Features include:

- Player vs player combat
- Critical hits
- EXP rewards
- Permanent death until revived
- Class-based combat calculations

---

# 📈 Level System

Players gain EXP after victories.

When EXP exceeds the required threshold:

- Level increases
- Max HP increases
- Stats increase
- HP is restored

Each class receives unique stat bonuses on level-up.

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

The following actions use:

```solidity
commonPrice = 0.001 ether
```

Used for:

- Battles
- PvP
- Heal
- Revive

---

## Dynamic Battle Cost

Battle costs scale with rounds:

```solidity
battleCost = commonPrice * rounds
```

Example:

| Rounds | ETH Cost |
|---|---|
| 1 | 0.001 ETH |
| 5 | 0.005 ETH |
| 10 | 0.01 ETH |

---

# 🎁 ETH Loot Drops

Enemies can randomly drop ETH after defeat.

Example:

```solidity
emit battleLog(round, "Enemy dropped ether", enemy.gold);
```

Stronger enemies drop larger ETH rewards.

---

# 🎲 Randomness System

The game uses pseudo-randomness based on:

- `block.timestamp`
- `block.prevrandao`
- `msg.sender`
- `block.number`

Used for:

- Damage variance
- Critical hits
- ETH reward drops

---

# 🔥 Critical Hits

Players and enemies can land critical strikes.

Critical attacks deal:

```solidity
damage * 2
```

Combat logs display critical attacks in real time.

---

# 📜 Solidity Events

Combat actions emit Solidity events:

```solidity
event battleLog(uint8 round, string message, uint value);
```

Examples:

- Damage dealt
- Critical damage
- Level up
- Player death
- Monster defeat
- ETH drops

---

# 🧪 Example Gameplay Flow

1. Connect wallet
2. Register hero
3. Battle enemies
4. Gain EXP
5. Level up
6. Earn ETH loot
7. Challenge players
8. Heal or revive if needed
9. Defeat stronger enemies

---

# 📦 Smart Contract Functions

## Player Functions

- `registerPlayer()`
- `battle()`
- `challengePlayer()`
- `heal()`
- `revive()`

---

## Combat Functions

- `calcDamageForPlayer()`
- `calcDamageForEnemy()`
- `calcDamageForPlayerVsPlayer()`

---

## Utility Functions

- `randomNumber()`
- `expUp()`
- `getLvUpBonus()`

---

# 👑 Owner Functions

## Withdraw Contract Balance

```solidity
withdraw()
```

Protected with:

```solidity
onlyOwner
```

---

# 🔮 Future Improvements

- 🖼️ NFT characters
- 🪙 ERC20 in-game currency
- 🎒 Inventory system
- 🗡️ Equipment system
- 🛒 Marketplace
- 🐲 Raid bosses
- 🌎 Multiplayer world
- ⚡ Guild system
- 🎵 Sound effects
- 🧠 Chainlink VRF integration
- 🏰 Persistent world state
- 📱 Mobile optimization

---

# ⚠️ Disclaimer

This project was created for educational and portfolio purposes.

The randomness system used in this smart contract is pseudo-random and is NOT secure for production-grade blockchain games.

For production environments, verifiable randomness such as Chainlink VRF should be used.

---

# 📚 Learning Goals

This project explores:

- Solidity
- Smart contracts
- Ethereum game architecture
- EVM mechanics
- Payable functions
- Event systems
- On-chain state management
- PvP mechanics
- Blockchain game design
- Web3 game development

---

# 📄 License

MIT License

---

# 👨‍💻 Author

beelzebruno — 2026

Built as a blockchain and Solidity learning project.