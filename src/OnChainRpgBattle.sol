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



contract SimpleBattleRPG {

    //////////////////////////////
    // ERRORS
    /////////////////////////////
    error NotOwner();

    //////////////////////////////
    // CONSTANTS
    /////////////////////////////
    // Prices
    uint256 public constant REGISTER_PRICE = 0.0001 ether;  // registering in game is cheaper ;)
    uint256 public constant COMMON_PRICE = 0.001 ether;  // battle round, revive, heal

    //////////////////////////////
    // STATE VARIABLES
    /////////////////////////////

    address public immutable i_owner;

    // store player objects as values for the sender address as key
    mapping (address => Player) public players;

     // Enemies mapping
    mapping(uint8 => Enemy)  public enemies;

    // player classes mapping
    mapping(uint8 => string) public classes;

    //////////////////////////////
    // Structs
    /////////////////////////////

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

    
    constructor() {
        // define contract ownership
        i_owner = msg.sender;

        // Init enemies
        enemies[1] = Enemy(1, "Goblin", 100, 10, 5, 0, true, 50, 0.0001 ether);
        enemies[2] = Enemy(2, "Orc", 200, 20, 10, 0, true, 100, 0.0002 ether);
        enemies[3] = Enemy(3, "Skeleton", 150, 15, 10, 0, true, 75, 0.0003 ether);
        enemies[4] = Enemy(4, "Zombie", 250, 25, 15, 0, true, 125, 0.0004 ether);
        enemies[5] = Enemy(5, "Werewolf", 300, 30, 20, 0, true, 150, 0.0005 ether);
        enemies[6] = Enemy(6, "Dark Elf", 250, 20, 25, 40, true, 150, 0.0006 ether);
        enemies[7] = Enemy(7, "Great Lizard", 80, 50, 50, 50, true, 500, 0.0007 ether);
        enemies[8] = Enemy(8, "Troll", 1000, 120, 100, 45, true, 600, 0.008 ether);
        enemies[9] = Enemy(9, "Dark Fairy", 1200, 80, 150, 150, true, 750, 0.009 ether);
        enemies[10] = Enemy(10, "Dragon", 2200, 200, 200, 200, true, 860, 0.001 ether);

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
        }
        else if (_classId == 2) {
            players[msg.sender] = Player(1, _name, 0, 10, _classId, class, 80, 80, 5, 5, 35, true);
        }
        else if (_classId == 3) {
             players[msg.sender] = Player(1, _name, 0, 10, _classId, class, 90, 90, 8, 8, 10, true);
        }
        else {
            require(false, "Invalid class name");
        }
    }

    // define fixed attribute bonus when level up by class
    function getLvUpBonus(uint8 _class) public pure returns (uint8[4] memory){
        uint8[4] memory bonus;
        if (_class == 1) {
            bonus = [25, 12, 8, 0];
        }
        else if (_class == 2) {
            bonus = [15, 5, 3, 20];
        }
        else {
            bonus = [10, 8, 3, 2];
        }

        return bonus;
    }

    // Earn Exp and Lv UP logic
    function expUp(uint256 _exp) internal returns(bool){
        bool lvUp = false;
        players[msg.sender].exp += _exp;
        if (players[msg.sender].exp >= players[msg.sender].nextLv) {
            
            uint8[4] memory bonus = getLvUpBonus(players[msg.sender].classId);

            players[msg.sender].lv += 1;
            players[msg.sender].exp = _exp;
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
    function randomNumber() public view returns(uint256) {
        uint random = uint(
            keccak256(
                abi.encodePacked(
                    block.timestamp,
                    block.prevrandao,
                    msg.sender,
                    block.number
                )
            )
        );
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
    function calcDamageForPlayer(address _player, uint8 _enemyId) public view returns(uint256) {
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
    function calcDamageForPlayerVsPlayer(address _player, address _targetPlayer) public view returns(uint256) {
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
    function calcDamageForEnemy(uint8 _enemyId, address _targetPlayer) public view returns(uint256) {
        Player memory player = players[_targetPlayer];
        Enemy memory enemy = enemies[_enemyId];

        uint256 attack = enemy.atk + randomNumber();

        uint256 baseDamage = attack > player.def ? (attack - player.def) / 2 : 0;

        return baseDamage * 2;
    }

    event battleLog(uint8 round, string message, uint value);

    // Returns true if the player crits
    function playerCrit() public view returns(bool) {
        uint256 crit = randomNumber();
        if (crit > 6) {
            return true;
        }
        return false;
    }

    // Returns true if the enemy crits
    function enemyCrit() public view returns(bool) {
        uint256 crit = randomNumber();
        if (crit > 9 ) {
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
        for (uint8 round = 0; round < _battleRounds; round++) {

            // get enemy and player critical hit chance
            bool playerCrited = playerCrit();
            bool enemyCrited = enemyCrit();

            // Player Damages enemy
            if (playerCrited) {
                playerDamage = calcDamageForPlayer(msg.sender, _enemyId) * 2;
                emit battleLog(round, "Player attacked and caused CRITICAL damage: ", playerDamage);
            }
            else {
                playerDamage = calcDamageForPlayer(msg.sender, _enemyId);
                emit battleLog(round, "Player attacked and caused damage: ", playerDamage);
            }


            // Enemy damages player
            if (enemyCrited) {
                enemyDamage = calcDamageForEnemy(_enemyId, msg.sender) * 2;
                emit battleLog(round, "Monster attacked and caused CRITICAL damage: ", enemyDamage);
            }
            else {
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
                bool lvUp = expUp(enemy.exp);
                bool earnedMoney = randomNumber() > 6;


                if (lvUp == true) {
                    players[msg.sender].currentHp = players[msg.sender].maxHp;
                    emit battleLog(round, "LEVEL UP to ", players[msg.sender].lv);
                }
                if (earnedMoney) {
                    // pay player ether 
                    (bool callSuccess, ) = payable(msg.sender).call{value: enemy.gold}("");
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

        // Calculate and require payment based on number of battle rounds
        uint256 battlePrice = COMMON_PRICE * _battleRounds;
        require(msg.value >= battlePrice, "Not enough ETH for this battle");

        // init damage variables
        uint256 playerDamage;
        uint256 enemyDamage;

        // round battle logic for each round payed for battling
        for (uint8 round = 0; round < _battleRounds; round++) {

            // get enemy and player critical hit chance
            bool attackerCrited = playerCrit();
            bool defenderCrited = playerCrit();

            // Player Damages enemy
            if (attackerCrited) {
                playerDamage = calcDamageForPlayerVsPlayer(msg.sender, _targetPlayer) * 2;
                emit battleLog(round, "Player attacked and caused CRITICAL damage: ", playerDamage);
            }
            else {
                playerDamage = calcDamageForPlayerVsPlayer(msg.sender, _targetPlayer);
                emit battleLog(round, "Player attacked and caused damage: ", playerDamage);
            }

            // Enemy damages player
            if (defenderCrited) {
                enemyDamage = calcDamageForPlayerVsPlayer(_targetPlayer, msg.sender) * 2;
                emit battleLog(round, "Denfender attacked and caused CRITICAL damage: ", enemyDamage);
            }
            else {
                enemyDamage = calcDamageForPlayerVsPlayer(_targetPlayer, msg.sender);
                emit battleLog(round, "Defender attacked and caused damage: ", enemyDamage);
            }
            
            // Battle results
            takeDamage(_targetPlayer, playerDamage);

            // player takes damage from enemy
            takeDamage(msg.sender, enemyDamage);

            // exp up for attacker only
            if (players[_targetPlayer].currentHp == 0) {
                bool lvUp = expUp(players[msg.sender].lv * 4 * players[_targetPlayer].lv * 3);
                players[_targetPlayer].isAlive = false;

                if (lvUp == true) {
                    players[msg.sender].currentHp = players[msg.sender].maxHp;
                    emit battleLog(round, "LEVEL UP to ", players[msg.sender].lv);
                }
                emit battleLog(round, "Target player defeated", 0);
                break;
            }

            if (players[msg.sender].currentHp == 0) {
                uint256 _exp = players[_targetPlayer].lv * 4 * players[msg.sender].lv * 3;
                bool lvUp = expUp(_exp);
                players[msg.sender].isAlive = false;

                players[_targetPlayer].exp += _exp;
                if (players[_targetPlayer].exp >= players[_targetPlayer].nextLv) {
                    
                    uint8[4] memory bonus = getLvUpBonus(players[_targetPlayer].classId);

                    players[_targetPlayer].lv += 1;
                    players[_targetPlayer].exp = _exp;
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
                    emit battleLog(round, "Target pokayer LEVEL UP to ", players[_targetPlayer].lv);
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
        require(players[_player].isAlive == true && players[_player].currentHp < players[_player].maxHp, "Player is dead or at full health");
        players[_player].currentHp = players[_player].maxHp;
    }

    // reusable require payment modifier
    modifier requirePayment() {
        require(msg.value >= COMMON_PRICE, "Minimium payment required!");
        _;
    }


    ////////////////////////////////////////////
    // OWNER PRIVILEGES
    ///////////////////////////////////////////
    function withdraw() public onlyOwner {
        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call Failed");
    }

    modifier onlyOwner() {
        // require(msg.sender == i_owner, "Sender is not the owner");
        
        // this upsaves a lot of gas than requeire does
        if (msg.sender != i_owner) { revert NotOwner();}
        _;
    }

}