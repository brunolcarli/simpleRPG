# ⚔️ Simple Battle RPG - Solidity Smart Contract

A simple on-chain RPG battle game built with Solidity and Ethereum smart contracts.

Players can register characters, fight monsters, gain EXP, level up, die, and revive using ETH-based mechanics.

# Deployed on Sepolia Devnet

Check ou the contract deployed on etherscan: https://sepolia.etherscan.io/address/0x7e68ef63ea7fd44691402002bfd3e28e420cf6f1

---

# 🚀 Features

- 🧙 Multiple character classes
- ⚔️ Turn-based battle system
- 👾 Multiple enemies
- 📈 EXP and level-up system
- ❤️ HP / Damage mechanics
- 💰 ETH-based battle costs
- ☠️ Death and revive mechanics
- 🎲 Pseudo-random combat system
- 📜 Solidity event combat logs

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
| Warrior | High HP and defense |
| Mage | High magic damage |
| Ranger | Balanced physical fighter |

---

## Enemies

The game includes several enemies:

- Goblin
- Orc
- Skeleton
- Zombie
- Werewolf
- Dark Elf
- Dragon

Each enemy has unique stats such as:

- HP
- Attack
- Defense
- Magic
- EXP reward

---

# 💰 ETH Economy

## Registration Fee

Players must pay a registration fee to create a character.

```solidity
registerPrice = 0.0001 ether
```

---

## Battle Cost

Battles cost ETH depending on the number of rounds selected.

```solidity
battlePrice = pricePerRound * battleRounds
```

Example:

| Rounds | ETH Cost |
|---|---|
| 1 | 0.001 ETH |
| 5 | 0.005 ETH |
| 10 | 0.01 ETH |

---

## Revive Cost

Dead players can revive by paying:

```solidity
revivePrice = 0.001 ether
```

---

# ⚔️ Battle System

During battle:

1. Player attacks enemy
2. Enemy attacks player
3. Damage is calculated
4. HP is reduced
5. Combat logs are emitted
6. Battle ends if:
   - Enemy dies
   - Player dies
   - Max rounds reached

---

# 📈 Level System

Players gain EXP after defeating enemies.

When EXP reaches the required threshold:

- Player levels up
- Stats increase
- HP is restored

---

# 🎲 Randomness

The game uses pseudo-randomness based on:

- `block.timestamp`
- `block.prevrandao`
- `msg.sender`
- `block.number`

---

# ⚠️ Disclaimer

This project was created for educational and portfolio purposes.

The random number generation used in this contract is NOT secure for production-grade blockchain games.

For production environments, a verifiable randomness source such as Chainlink VRF should be used.

---

# 📜 Events

Combat logs are emitted using Solidity events:

```solidity
event battleLog(uint8 round, string message, uint value);
```

Example logs:

- Player damage
- Enemy damage
- Level up
- Death
- Victory

---

# 🧪 Example Flow

1. Deploy contract
2. Register character
3. Start battle
4. Earn EXP
5. Level up
6. Fight stronger enemies
7. Revive if dead

---

# 📦 Contract Functions

## Player Functions

- `registerPlayer()`
- `battle()`
- `revive()`

## Utility Functions

- `randomNumber()`
- `calcDamageForPlayer()`
- `calcDamageForEnemy()`
- `expUp()`

---

# 🔮 Future Improvements

- NFT characters
- ERC20 in-game currency
- Persistent enemy states
- PvP battles
- Inventory system
- Equipment system
- Loot drops
- Frontend with React + ethers.js
- Chainlink VRF integration
- Multiplayer mechanics

---

# 📚 Learning Goals

This project was created to study:

- Solidity
- Smart contracts
- Ethereum game logic
- EVM mechanics
- Payable functions
- Events
- State management
- Blockchain game architecture

---

# 📄 License

MIT License

---

# 👨‍💻 Author

beelzebruno - 2026

Built as a blockchain and Solidity learning project.