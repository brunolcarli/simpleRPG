// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

contract SimpleBattleRPG {

    // Prices
    uint public constant registerPrice = 0.0001 ether;
    uint256 public constant pricePerRound = 0.001 ether;
    uint256 public constant revivePrice = 0.001 ether;


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
    }

    // Enemies mapping
    mapping(uint8 => Enemy)  public enemies;

    // player classes mapping
    mapping(uint8 => string) public classes;
    
    constructor() {

        // Init enemies
        enemies[1] = Enemy(1, "Goblin", 100, 10, 5, 0, true, 50);
        enemies[2] = Enemy(2, "Orc", 200, 20, 10, 0, true, 100);
        enemies[3] = Enemy(3, "Skeleton", 150, 15, 10, 0, true, 75);
        enemies[4] = Enemy(4, "Zombie", 250, 25, 15, 0, true, 125);
        enemies[5] = Enemy(5, "Werewolf", 300, 30, 20, 0, true, 150);
        enemies[6] = Enemy(6, "Dark Elf", 250, 20, 25, 40, true, 150);
        enemies[7] = Enemy(3, "Dragon", 800, 80, 55, 80, true, 20);

        // Init classes
        classes[1] = "Warrior";
        classes[2] = "Mage";
        classes[3] = "Ranger";
    }

    // store player objects as values for the sender address as key
    mapping (address => Player) public players;

    // register a player
    function registerPlayer(string memory _name, uint8 _classId) public payable {

        // require payment to register
        require(msg.value >= registerPrice, "Minimium value to registration not reached!");

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
            bonus = [25, 10, 5, 0];
        }
        else if (_class == 2) {
            bonus = [15, 5, 0, 20];
        }
        else {
            bonus = [10, 8, 3, 2];
        }

        return bonus;
    }

    // Earn Exp and Lv UP logic
    function expUp(uint256 _exp) public returns(bool){
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
    function takeDamage(address _target, uint256 _damage) public {
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

    // damage calculation formula for enemy attacking
    function calcDamageForEnemy(uint8 _enemyId, address _targetPlayer) public view returns(uint256) {
        Player memory player = players[_targetPlayer];
        Enemy memory enemy = enemies[_enemyId];

        uint256 attack = enemy.atk + randomNumber();

        uint256 baseDamage = attack > player.def ? (attack - player.def) / 2 : 0;

        return baseDamage * 2;
    }


    event battleLog(uint8 round, string message, uint value);

    // fights a monster
    function battle(uint8 _enemyId, uint256 _battleRounds) public payable {
        require(players[msg.sender].isAlive == true, "You are dead and can't battle");

        require(_battleRounds > 0, "Battle must have at least 1 round");

        uint256 battlePrice = pricePerRound * _battleRounds;

        require(msg.value >= battlePrice, "Not enough ETH for this battle");

        Enemy memory enemy = enemies[_enemyId];

        for (uint8 round = 0; round < _battleRounds; round++) {
            uint256 playerDamage = calcDamageForPlayer(msg.sender, _enemyId);
            uint256 enemyDamage = calcDamageForEnemy(_enemyId, msg.sender);

            emit battleLog(round, "Player attacked and caused damage: ", playerDamage);
            emit battleLog(round, "Monster attacked and caused damage: ", enemyDamage);

            if (playerDamage >= enemy.hp) {
                enemy.hp = 0;
            } else {
                enemy.hp -= playerDamage;
            }

            takeDamage(msg.sender, enemyDamage);

            if (enemy.hp == 0) {
                bool lvUp = expUp(enemy.exp);

                if (lvUp == true) {
                    players[msg.sender].currentHp = players[msg.sender].maxHp;
                    emit battleLog(round, "LEVEL UP to ", players[msg.sender].lv);
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

    // Revive a player
    function revive(address _player) public payable {
        require(players[_player].isAlive == false, "Player is already alive");
        // require payment to revive a player 
        require(msg.value >= revivePrice, "Minimium value to revive not reached!");
        players[_player].currentHp = players[_player].maxHp;
        players[_player].isAlive = true;
    }

}