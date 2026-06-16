// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

//////////////////////////////////////////////////////
// ______       _   _   _       ____________ _____
// | ___ \     | | | | | |      | ___ \ ___ \  __ \
// | |_/ / __ _| |_| |_| | ___  | |_/ / |_/ / |  \/
// | ___ \/ _` | __| __| |/ _ \ |    /|  __/| | __
// | |_/ / (_| | |_| |_| |  __/ | |\ \| |   | |_\ \
// \____/ \__,_|\__|\__|_|\___| \_| \_\_|    \____/
//
// @beelzebruno (2026)
//
//////////////////////////////////////////////////////

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

contract OnChainRpgBattle is ERC721 {
    //////////////////////////////
    // ERRORS
    /////////////////////////////
    error NotOwner();

    //////////////////////////////
    // EVENTS
    /////////////////////////////
    event battleLog(uint256 round, string message, uint256 value);
    event GuildCreated(uint256 indexed guildId, string name, address indexed leader);
    event GuildJoined(uint256 indexed guildId, address indexed player);
    event GuildLeft(uint256 indexed guildId, address indexed player);
    event GuildPointsChanged(
        uint256 indexed winnerGuildId, uint256 indexed loserGuildId, uint256 winnerPoints, uint256 loserPoints
    );
    event MonsterSlayed(address indexed player, uint8 indexed enemyId, uint256 totalSlayed);
    event PlayerSlayed(address indexed winner, address indexed loser, uint256 totalSlayed);
    event AchievementClaimed(address indexed player, uint256 indexed achievementId, uint256 indexed tokenId);

    //////////////////////////////
    // MODIFIERS
    /////////////////////////////
    modifier requirePayment() {
        require(msg.value >= COMMON_PRICE, "Minimium payment required!");
        _;
    }

    modifier onlyOwner() {
        // require(msg.sender == i_owner, "Sender is not the owner");

        // this upsaves a lot of gas than requeire does
        if (msg.sender != i_owner) revert NotOwner();
        _;
    }

    //////////////////////////////
    // CONSTANTS
    /////////////////////////////

    uint256 public constant REGISTER_PRICE = 0.0001 ether; // registering in game is cheaper ;)
    uint256 public constant COMMON_PRICE = 0.001 ether; // battle round, revive, heal
    uint256 public constant CREATE_GUILD_PRICE = 0.01 ether;
    uint256 public constant PLAYER_SLAYER = 100;
    uint256 public constant PLAYER_SLAYER_REQUIRED_KILLS = 100;
    uint256 public constant MAX_PVP_LEVEL_DIFFERENCE = 10;
    uint256 public constant MAX_GUILD_POINTS_PER_KILL = 20;

    //////////////////////////////
    // STATE VARIABLES
    /////////////////////////////

    address public immutable i_owner;

    // store player objects as values for the sender address as key
    mapping(address => Player) public players;

    // Enemies mapping
    mapping(uint8 => Enemy) public enemies;

    // player classes mapping
    mapping(uint8 => string) public classes;

    // Guild mappings and stuff
    mapping(uint256 => Guild) public guilds;
    mapping(address => uint256) public playerGuild;
    mapping(bytes32 => uint256) public guildIdByNameHash;
    uint256[] public guildIds;
    uint256[5] public topGuilds;

    uint256 public nextGuildId = 1;

    // Achievements
    string private s_baseTokenURI = "ipfs://bafybeihebr72fet5ccpp5qrxwhxo3jimxb4hshffk6b6w3kej35oe4xtbu/";

    mapping(address => mapping(uint8 => uint256)) public monsterSlayeds;
    mapping(address => uint256) public playerSlayeds;

    // PvP Master counts unique defeated wallets
    mapping(address => mapping(address => bool)) public hasDefeatedPlayer;
    mapping(address => uint256) public uniquePlayersSlayed;

    mapping(address => mapping(uint256 => bool)) public hasAchievement;
    mapping(uint256 => uint256) public tokenAchievement;
    mapping(uint8 => uint256) public achievementRequirement;
    uint256 public nextTokenId = 1;

    //////////////////////////////
    // Structs
    /////////////////////////////

    struct Guild {
        uint256 id;
        string name;
        address guildOwner;
        uint256 membersCount;
        uint256 points;
        bool exists;
    }

    // Player attributes
    struct Player {
        uint256 lv;
        string name;
        uint256 exp;
        uint256 nextLv;
        uint8 classId;
        string class;
        uint256 maxHp;
        uint256 currentHp;
        uint256 atk;
        uint256 def;
        uint256 magic;
        bool isAlive;
    }

    // Enemy
    struct Enemy {
        uint8 id;
        string name;
        uint256 hp;
        uint256 atk;
        uint256 def;
        uint256 magic;
        bool isAlive;
        uint256 exp;
        uint256 gold;
    }

    constructor() ERC721("OnChain RPG Achievements", "RPGACH") {
        // define contract ownership
        i_owner = msg.sender;

        // Init enemies
        enemies[1] = Enemy(1, "Goblin", 100, 10, 5, 0, true, 50, 0.0001 ether);
        enemies[2] = Enemy(2, "Orc", 200, 20, 10, 0, true, 100, 0.0002 ether);
        enemies[3] = Enemy(3, "Skeleton", 150, 15, 10, 0, true, 75, 0.0003 ether);
        enemies[4] = Enemy(4, "Zombie", 250, 25, 15, 0, true, 125, 0.0004 ether);
        enemies[5] = Enemy(5, "Werewolf", 300, 30, 20, 0, true, 150, 0.0005 ether);
        enemies[6] = Enemy(6, "Dark Elf", 250, 20, 25, 40, true, 150, 0.0006 ether);
        enemies[7] = Enemy(7, "Great Lizard", 580, 50, 50, 50, true, 500, 0.0007 ether);
        enemies[8] = Enemy(8, "Troll", 1000, 120, 100, 45, true, 600, 0.0008 ether);
        enemies[9] = Enemy(9, "Dark Fairy", 1200, 80, 150, 150, true, 750, 0.0009 ether);
        enemies[10] = Enemy(10, "Dragon", 2200, 200, 200, 200, true, 860, 0.001 ether);

        // init achiements rewards requirements
        achievementRequirement[1] = 100; // Goblin
        achievementRequirement[2] = 100; // Orc
        achievementRequirement[3] = 100; // Skeleton
        achievementRequirement[4] = 100; // Zombie
        achievementRequirement[5] = 100; // Werewolf
        achievementRequirement[6] = 75; // Dark Elf
        achievementRequirement[7] = 75; // Great Lizard
        achievementRequirement[8] = 50; // Troll
        achievementRequirement[9] = 25; // Dark Fairy
        achievementRequirement[10] = 20; // Dragon

        // Init classes
        classes[1] = "Warrior";
        classes[2] = "Mage";
        classes[3] = "Ranger";
    }

    //////////////////////////////
    // FUNCTIONS
    /////////////////////////////

    // register a player
    function registerPlayer(string memory _name, uint8 _classId) public payable {
        // require payment to register
        require(msg.value >= REGISTER_PRICE, "Minimium value to registration not reached!");

        string memory class = classes[_classId];

        if (_classId == 1) {
            players[msg.sender] = Player(1, _name, 0, 10, _classId, class, 100, 100, 10, 10, 0, true);
        } else if (_classId == 2) {
            players[msg.sender] = Player(1, _name, 0, 10, _classId, class, 80, 80, 5, 5, 35, true);
        } else if (_classId == 3) {
            players[msg.sender] = Player(1, _name, 0, 10, _classId, class, 90, 90, 8, 8, 10, true);
        } else {
            require(false, "Invalid class name");
        }
    }

    // define fixed attribute bonus when level up by class
    function getLvUpBonus(uint8 _class) public pure returns (uint8[4] memory) {
        uint8[4] memory bonus;
        if (_class == 1) {
            bonus = [25, 12, 8, 0];
        } else if (_class == 2) {
            bonus = [15, 5, 3, 20];
        } else {
            bonus = [16, 8, 5, 2];
        }

        return bonus;
    }

    // Earn Exp and Lv UP logic
    function expUp(uint256 _exp) internal returns (bool) {
        bool lvUp = false;
        players[msg.sender].exp += _exp;
        if (players[msg.sender].exp >= players[msg.sender].nextLv) {
            uint8[4] memory bonus = getLvUpBonus(players[msg.sender].classId);

            players[msg.sender].lv += 1;
            // players[msg.sender].exp = _exp;
            players[msg.sender].nextLv += (players[msg.sender].nextLv * 2) + players[msg.sender].lv;

            players[msg.sender].maxHp = players[msg.sender].maxHp + bonus[0];
            players[msg.sender].currentHp = players[msg.sender].maxHp;
            players[msg.sender].atk = players[msg.sender].atk + bonus[1];
            players[msg.sender].def = players[msg.sender].def + bonus[2];
            players[msg.sender].magic = players[msg.sender].magic + bonus[3];
            lvUp = true;
        }
        return lvUp;
    }

    // random number generator
    function randomNumber() public view returns (uint256) {
        uint256 random =
            uint256(keccak256(abi.encodePacked(block.timestamp, block.prevrandao, msg.sender, block.number)));
        return ((random % 100) + 1) / 10;
    }

    // target player takes damage
    function takeDamage(address _target, uint256 _damage) internal {
        if (_damage >= players[_target].currentHp) {
            players[_target].currentHp = 0;
        } else {
            players[_target].currentHp -= _damage;
        }
    }

    // damage calculation formula for player attacking
    function calcDamageForPlayer(address _player, uint8 _enemyId) public view returns (uint256) {
        Player memory player = players[_player];
        Enemy memory enemy = enemies[_enemyId];

        uint256 attack;
        uint256 defense;

        if (player.classId == 2) {
            attack = player.magic + randomNumber();
            defense = enemy.magic;
        } else {
            attack = player.atk + randomNumber();
            defense = enemy.def;
        }

        uint256 baseDamage = attack > defense ? (attack - defense) / 2 : 0;

        return baseDamage + 2 * player.lv;
    }

    // damage calculation formula for player attacking other player
    function calcDamageForPlayerVsPlayer(address _player, address _targetPlayer) public view returns (uint256) {
        Player memory attacker = players[_player];
        Player memory defender = players[_targetPlayer];

        uint256 attack;
        uint256 defense;

        if (attacker.classId == 2) {
            attack = attacker.magic + randomNumber();
            defense = defender.magic;
        } else {
            attack = attacker.atk + randomNumber();
            defense = defender.def;
        }

        uint256 baseDamage = attack > defense ? (attack - defense) / 2 : 0;

        return baseDamage + 2 * attacker.lv;
    }

    // damage calculation formula for enemy attacking
    function calcDamageForEnemy(uint8 _enemyId, address _targetPlayer) public view returns (uint256) {
        Player memory player = players[_targetPlayer];
        Enemy memory enemy = enemies[_enemyId];

        uint256 attack = enemy.atk + randomNumber();

        uint256 baseDamage = attack > player.def ? (attack - player.def) / 2 : 0;

        return baseDamage * 2;
    }

    // Returns true if the player crits
    function playerCrit() public view returns (bool) {
        uint256 crit = randomNumber();
        if (crit > 6) {
            return true;
        }
        return false;
    }

    // Returns true if the enemy crits
    function enemyCrit() public view returns (bool) {
        uint256 crit = randomNumber();
        if (crit > 9) {
            return true;
        }
        return false;
    }

    //////////////////////////////
    // Battle Functions
    /////////////////////////////

    //Against enemy monster
    function battle(uint8 _enemyId, uint256 _battleRounds) public payable {
        // player must be alive
        require(players[msg.sender].isAlive == true, "You are dead and can't battle");

        // number of battle rounds must be greater than zero
        require(_battleRounds > 0, "Battle must have at least 1 round");

        // Calculate and require payment based on number of battle rounds
        uint256 battlePrice = COMMON_PRICE * _battleRounds;
        require(msg.value >= battlePrice, "Not enough ETH for this battle");

        // init a new copy instance of an enemy in-memory on runtime
        Enemy memory enemy = enemies[_enemyId];

        // init damage variables
        uint256 playerDamage;
        uint256 enemyDamage;

        // round battle logic for each round payed for battling
        for (uint256 round = 0; round < _battleRounds; round++) {
            // get enemy and player critical hit chance
            bool playerCrited = playerCrit();
            bool enemyCrited = enemyCrit();

            // Player Damages enemy
            if (playerCrited) {
                playerDamage = calcDamageForPlayer(msg.sender, _enemyId) * 2;
                emit battleLog(round, "Player attacked and caused CRITICAL damage: ", playerDamage);
            } else {
                playerDamage = calcDamageForPlayer(msg.sender, _enemyId);
                emit battleLog(round, "Player attacked and caused damage: ", playerDamage);
            }

            // Enemy damages player
            if (enemyCrited) {
                enemyDamage = calcDamageForEnemy(_enemyId, msg.sender) * 2;
                emit battleLog(round, "Monster attacked and caused CRITICAL damage: ", enemyDamage);
            } else {
                enemyDamage = calcDamageForEnemy(_enemyId, msg.sender);
                emit battleLog(round, "Monster attacked and caused damage: ", enemyDamage);
            }

            // Battle results
            if (playerDamage >= enemy.hp) {
                enemy.hp = 0;
            } else {
                enemy.hp -= playerDamage;
            }

            // player takes damage from enemy
            takeDamage(msg.sender, enemyDamage);

            if (enemy.hp == 0) {
                monsterSlayeds[msg.sender][_enemyId]++;
                emit MonsterSlayed(msg.sender, _enemyId, monsterSlayeds[msg.sender][_enemyId]);

                bool lvUp = expUp(enemy.exp);
                bool earnedMoney = randomNumber() > 6;

                if (lvUp == true) {
                    players[msg.sender].currentHp = players[msg.sender].maxHp;
                    emit battleLog(round, "LEVEL UP to ", players[msg.sender].lv);
                }
                if (earnedMoney) {
                    // pay player ether
                    (bool callSuccess,) = payable(msg.sender).call{value: enemy.gold}("");
                    require(callSuccess, "Call Failed to paying ether");
                    emit battleLog(round, "Enemy dropped ether", enemy.gold);
                }
                emit battleLog(round, "Monster defeated", 0);
                break;
            }

            if (players[msg.sender].currentHp == 0) {
                players[msg.sender].isAlive = false;
                emit battleLog(round, "You died in battle", 0);
                break;
            }
        }
    }

    //////////////////////////////
    // PvP Battle Functions
    /////////////////////////////

    // against real player
    function challengePlayer(address _targetPlayer, uint256 _battleRounds) public payable {
        // player sender must be alive
        require(players[msg.sender].isAlive == true, "You are dead and can't battle");

        // target player sender must be alive
        require(players[_targetPlayer].isAlive == true, "You're target is already dead and can't battle");

        // number of battle rounds must be greater than zero
        require(_battleRounds > 0, "Battle must have at least 1 round");

        // PvP "noob protection"
        uint256 attackerLevel = players[msg.sender].lv;
        uint256 defenderLevel = players[_targetPlayer].lv;

        uint256 levelDifference = attackerLevel > defenderLevel
            ? attackerLevel - defenderLevel
            : defenderLevel - attackerLevel;

        require(levelDifference <= MAX_PVP_LEVEL_DIFFERENCE, "Level difference too high");

        // Calculate and require payment based on number of battle rounds
        uint256 battlePrice = COMMON_PRICE * _battleRounds;
        require(msg.value >= battlePrice, "Not enough ETH for this battle");

        // init damage variables
        uint256 playerDamage;
        uint256 enemyDamage;

        // round battle logic for each round payed for battling
        for (uint256 round = 0; round < _battleRounds; round++) {
            // get enemy and player critical hit chance
            bool attackerCrited = playerCrit();
            bool defenderCrited = playerCrit();

            // Player Damages enemy
            if (attackerCrited) {
                playerDamage = calcDamageForPlayerVsPlayer(msg.sender, _targetPlayer) * 2;
                emit battleLog(round, "Player attacked and caused CRITICAL damage: ", playerDamage);
            } else {
                playerDamage = calcDamageForPlayerVsPlayer(msg.sender, _targetPlayer);
                emit battleLog(round, "Player attacked and caused damage: ", playerDamage);
            }

            // Enemy damages player
            if (defenderCrited) {
                enemyDamage = calcDamageForPlayerVsPlayer(_targetPlayer, msg.sender) * 2;
                emit battleLog(round, "Denfender attacked and caused CRITICAL damage: ", enemyDamage);
            } else {
                enemyDamage = calcDamageForPlayerVsPlayer(_targetPlayer, msg.sender);
                emit battleLog(round, "Defender attacked and caused damage: ", enemyDamage);
            }

            // Battle results
            takeDamage(_targetPlayer, playerDamage);

            // player takes damage from enemy
            takeDamage(msg.sender, enemyDamage);

            // exp up for attacker only
            if (players[_targetPlayer].currentHp == 0) {
                _registerPlayerSlay(msg.sender, _targetPlayer);

                bool lvUp = expUp(players[msg.sender].lv * 4 * players[_targetPlayer].lv * 3);
                players[_targetPlayer].isAlive = false;

                _awardGuildPoints(msg.sender, _targetPlayer);

                if (lvUp == true) {
                    players[msg.sender].currentHp = players[msg.sender].maxHp;
                    emit battleLog(round, "LEVEL UP to ", players[msg.sender].lv);
                }
                emit battleLog(round, "Target player defeated", 0);
                break;
            }

            if (players[msg.sender].currentHp == 0) {
                _registerPlayerSlay(_targetPlayer, msg.sender);

                uint256 _exp = players[_targetPlayer].lv * 4 * players[msg.sender].lv * 3;
                // bool lvUp = expUp(_exp);
                bool lvUp = false;
                players[msg.sender].isAlive = false;

                _awardGuildPoints(_targetPlayer, msg.sender);

                players[_targetPlayer].exp += _exp;
                if (players[_targetPlayer].exp >= players[_targetPlayer].nextLv) {
                    uint8[4] memory bonus = getLvUpBonus(players[_targetPlayer].classId);

                    players[_targetPlayer].lv += 1;
                    // players[_targetPlayer].exp = _exp;
                    players[_targetPlayer].nextLv += (players[_targetPlayer].nextLv * 2) + players[_targetPlayer].lv;

                    players[_targetPlayer].maxHp = players[_targetPlayer].maxHp + bonus[0];
                    players[_targetPlayer].currentHp = players[_targetPlayer].maxHp;
                    players[_targetPlayer].atk = players[_targetPlayer].atk + bonus[1];
                    players[_targetPlayer].def = players[_targetPlayer].def + bonus[2];
                    players[_targetPlayer].magic = players[_targetPlayer].magic + bonus[3];
                    lvUp = true;
                }
                if (lvUp == true) {
                    players[_targetPlayer].currentHp = players[_targetPlayer].maxHp;
                    emit battleLog(round, "Target player LEVEL UP to ", players[_targetPlayer].lv);
                }
                emit battleLog(round, "You died in battle", 0);
                break;
            }
        }
    }

    // Revive a player
    function revive(address _player) public payable requirePayment {
        require(players[_player].isAlive == false, "Player is already alive");
        players[_player].currentHp = players[_player].maxHp;
        players[_player].isAlive = true;
    }

    // Heals player health
    function heal(address _player) public payable requirePayment {
        require(
            players[_player].isAlive == true && players[_player].currentHp < players[_player].maxHp,
            "Player is dead or at full health"
        );
        players[_player].currentHp = players[_player].maxHp;
    }

    ////////////////////////////////////////////
    // OWNER PRIVILEGES
    ///////////////////////////////////////////
    function withdraw() public onlyOwner {
        (bool callSuccess,) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call Failed");
    }

    //////////////////////////////
    // GUILD FUNCTIONS
    /////////////////////////////

    function createGuild(string memory _name) public payable {
        require(msg.value >= CREATE_GUILD_PRICE, "Minimum payment required to create guild");
        require(players[msg.sender].isAlive == true, "Only registered alive players can create guilds");
        require(playerGuild[msg.sender] == 0, "Player already belongs to a guild");

        bytes32 guildNameHash = keccak256(abi.encodePacked(_name));
        require(guildIdByNameHash[guildNameHash] == 0, "Guild name already exists");

        uint256 guildId = nextGuildId;

        guilds[guildId] =
            Guild({id: guildId, name: _name, guildOwner: msg.sender, membersCount: 1, points: 0, exists: true});

        guildIdByNameHash[guildNameHash] = guildId;
        playerGuild[msg.sender] = guildId;
        guildIds.push(guildId);
        nextGuildId++;

        emit GuildCreated(guildId, _name, msg.sender);
    }

    function joinGuild(uint256 _guildId) public {
        require(players[msg.sender].isAlive == true, "Only registered alive players can join guilds");
        require(guilds[_guildId].exists == true, "Guild does not exist");
        require(playerGuild[msg.sender] == 0, "Player already belongs to a guild");

        playerGuild[msg.sender] = _guildId;
        guilds[_guildId].membersCount++;

        emit GuildJoined(_guildId, msg.sender);
    }

    function leaveGuild() public {
        uint256 guildId = playerGuild[msg.sender];

        require(guildId != 0, "Player does not belong to a guild");
        require(msg.sender != guilds[guildId].guildOwner, "Guild owner cannot leave guild");

        playerGuild[msg.sender] = 0;
        guilds[guildId].membersCount--;

        emit GuildLeft(guildId, msg.sender);
    }

    function getGuilds(uint256 _offset, uint256 _limit) public view returns (Guild[] memory) {
        uint256 totalGuilds = guildIds.length;

        if (_offset >= totalGuilds) {
            return new Guild[](0);
        }

        uint256 end = _offset + _limit;

        if (end > totalGuilds) {
            end = totalGuilds;
        }

        Guild[] memory result = new Guild[](end - _offset);

        for (uint256 i = _offset; i < end; i++) {
            result[i - _offset] = guilds[guildIds[i]];
        }

        return result;
    }

    function getTopGuilds() public view returns (Guild[5] memory) {
        Guild[5] memory result;

        for (uint256 i = 0; i < 5; i++) {
            if (topGuilds[i] != 0) {
                result[i] = guilds[topGuilds[i]];
            }
        }

        return result;
    }

    function addGuildMember(uint256 _guildId, address _player) public {
        require(guilds[_guildId].exists == true, "Guild does not exist");
        require(msg.sender == guilds[_guildId].guildOwner, "Only guild owner can add members");
        require(players[_player].isAlive == true, "Player is not registered or alive");
        require(playerGuild[_player] == 0, "Player already belongs to a guild");

        playerGuild[_player] = _guildId;
        guilds[_guildId].membersCount++;

        emit GuildJoined(_guildId, _player);
    }

    function removeGuildMember(uint256 _guildId, address _player) public {
        require(guilds[_guildId].exists == true, "Guild does not exist");
        require(msg.sender == guilds[_guildId].guildOwner, "Only guild owner can remove members");
        require(playerGuild[_player] == _guildId, "Player does not belong to this guild");
        require(_player != guilds[_guildId].guildOwner, "Guild owner cannot be removed");

        playerGuild[_player] = 0;
        guilds[_guildId].membersCount--;

        emit GuildLeft(_guildId, _player);
    }

    ////////////////////////////////////////////
    // NFT Achievements
    ///////////////////////////////////////////
    function claimAchievement(uint256 _achievementId) public {
        require(players[msg.sender].isAlive == true, "Only registered players can claim achievements");
        require(hasAchievement[msg.sender][_achievementId] == false, "Achievement already claimed");

        if (_achievementId >= 1 && _achievementId <= 10) {
            // casting to uint8 is safe because achievementId is validated between 1 and 10
            // forge-lint: disable-next-line(unsafe-typecast)
            uint8 enemyId = uint8(_achievementId);

            require(
                monsterSlayeds[msg.sender][enemyId] >= achievementRequirement[enemyId], "Not enough monsters slayed"
            );
        } else if (_achievementId == PLAYER_SLAYER) {
            require(uniquePlayersSlayed[msg.sender] >= PLAYER_SLAYER_REQUIRED_KILLS, "Not enough unique players slayed");
        } else {
            revert("Invalid achievement");
        }

        hasAchievement[msg.sender][_achievementId] = true;

        uint256 tokenId = nextTokenId;
        nextTokenId++;

        tokenAchievement[tokenId] = _achievementId;

        _safeMint(msg.sender, tokenId);
        emit AchievementClaimed(msg.sender, _achievementId, tokenId);
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        ownerOf(tokenId);

        uint256 achievementId = tokenAchievement[tokenId];

        return string(abi.encodePacked(s_baseTokenURI, Strings.toString(achievementId), ".json"));
    }

    ////////////////////////////////////////////
    // HELPERS
    ///////////////////////////////////////////

    function _calculateGuildPoints(address _winner, address _loser) internal view returns (uint256) {
        uint256 winnerLevel = players[_winner].lv;
        uint256 loserLevel = players[_loser].lv;

        uint256 points = loserLevel / 5;

        if (points < 1) {
            points = 1;
        }

        if (loserLevel > winnerLevel) {
            points += (loserLevel - winnerLevel) / 2;
        }

        if (points > MAX_GUILD_POINTS_PER_KILL) {
            points = MAX_GUILD_POINTS_PER_KILL;
        }

        return points;
    }

    function _updateTopGuilds(uint256 _guildId) internal {
        if (_guildId == 0 || guilds[_guildId].exists == false) {
            return;
        }

        bool alreadyInTop = false;

        for (uint256 i = 0; i < 5; i++) {
            if (topGuilds[i] == _guildId) {
                alreadyInTop = true;
                break;
            }
        }

        if (!alreadyInTop) {
            for (uint256 i = 0; i < 5; i++) {
                if (topGuilds[i] == 0) {
                    topGuilds[i] = _guildId;
                    alreadyInTop = true;
                    break;
                }
            }
        }

        if (!alreadyInTop) {
            uint256 lastGuildId = topGuilds[4];

            if (guilds[_guildId].points <= guilds[lastGuildId].points) {
                return;
            }

            topGuilds[4] = _guildId;
        }

        for (uint256 i = 0; i < 5; i++) {
            for (uint256 j = i + 1; j < 5; j++) {
                if (topGuilds[j] != 0 && guilds[topGuilds[j]].points > guilds[topGuilds[i]].points) {
                    uint256 temp = topGuilds[i];
                    topGuilds[i] = topGuilds[j];
                    topGuilds[j] = temp;
                }
            }
        }
    }

    function _registerPlayerSlay(address _winner, address _loser) internal {
        playerSlayeds[_winner]++;

        if (!hasDefeatedPlayer[_winner][_loser]) {
            hasDefeatedPlayer[_winner][_loser] = true;
            uniquePlayersSlayed[_winner]++;
        }

        emit PlayerSlayed(_winner, _loser, playerSlayeds[_winner]);
    }

    function _awardGuildPoints(address _winner, address _loser) internal {
        uint256 winnerGuildId = playerGuild[_winner];
        uint256 loserGuildId = playerGuild[_loser];

        if (winnerGuildId == 0 || loserGuildId == 0) {
            return;
        }

        if (winnerGuildId == loserGuildId) {
            return;
        }

        uint256 pointsToAward = _calculateGuildPoints(_winner, _loser);
        guilds[winnerGuildId].points += pointsToAward;

        uint256 pointsToRemove = pointsToAward / 2;

        if (pointsToRemove < 1) {
            pointsToRemove = 1;
        }

        if (guilds[loserGuildId].points >= pointsToRemove) {
            guilds[loserGuildId].points -= pointsToRemove;
        } else {
            guilds[loserGuildId].points = 0;
        }

        _updateTopGuilds(winnerGuildId);
        _updateTopGuilds(loserGuildId);

        emit GuildPointsChanged(winnerGuildId, loserGuildId, guilds[winnerGuildId].points, guilds[loserGuildId].points);
    }
}
