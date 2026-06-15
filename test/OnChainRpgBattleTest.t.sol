// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {OnChainRpgBattle} from "../src/OnChainRpgBattle.sol";

contract OnChainRpgBattleHarness is OnChainRpgBattle {
    function setMonsterSlayeds(address player, uint8 enemyId, uint256 amount) external {
        monsterSlayeds[player][enemyId] = amount;
    }

    function setPlayerSlayeds(address player, uint256 amount) external {
        playerSlayeds[player] = amount;
    }
}

contract OnChainRpgBattleTest is Test {
    OnChainRpgBattleHarness public rpg;

    address public PLAYER = makeAddr("PLAYER");
    address public PLAYER_TWO = makeAddr("PLAYER_TWO");
    address public ATTACKER = makeAddr("ATTACKER");

    uint256 public constant REGISTER_PRICE = 0.0001 ether;
    uint256 public constant COMMON_PRICE = 0.001 ether;

    event AchievementClaimed(address indexed player, uint256 indexed achievementId, uint256 indexed tokenId);

    function setUp() public {
        rpg = new OnChainRpgBattleHarness();

        vm.deal(PLAYER, 10 ether);
        vm.deal(PLAYER_TWO, 10 ether);
        vm.deal(ATTACKER, 10 ether);
    }

    //////////////////////////////
    // Constructor
    //////////////////////////////

    function testOwnerIsDeployer() public view {
        assertEq(rpg.i_owner(), address(this));
    }

    function testInitialClassesAreSet() public view {
        assertEq(rpg.classes(1), "Warrior");
        assertEq(rpg.classes(2), "Mage");
        assertEq(rpg.classes(3), "Ranger");
    }

    function testInitialGoblinIsSet() public view {
        (
            uint8 id,
            string memory name,
            uint256 hp,
            uint256 atk,
            uint256 def,
            uint256 magic,
            bool isAlive,
            uint256 exp,
            uint256 gold
        ) = rpg.enemies(1);

        assertEq(id, 1);
        assertEq(name, "Goblin");
        assertEq(hp, 100);
        assertEq(atk, 10);
        assertEq(def, 5);
        assertEq(magic, 0);
        assertTrue(isAlive);
        assertEq(exp, 50);
        assertEq(gold, 0.0001 ether);
    }

    //////////////////////////////
    // Register
    //////////////////////////////

    function testRegisterWarrior() public {
        _registerPlayer(PLAYER, "Bruno", 1);

        assertEq(_getLevel(PLAYER), 1);
        assertEq(_getName(PLAYER), "Bruno");
        assertEq(_getExp(PLAYER), 0);
        assertEq(_getNextLv(PLAYER), 10);
        assertEq(_getClassId(PLAYER), 1);
        assertEq(_getClassName(PLAYER), "Warrior");
        assertEq(_getMaxHp(PLAYER), 100);
        assertEq(_getCurrentHp(PLAYER), 100);
        assertEq(_getAtk(PLAYER), 10);
        assertEq(_getDef(PLAYER), 10);
        assertEq(_getMagic(PLAYER), 0);
        assertTrue(_getIsAlive(PLAYER));
    }

    function testRegisterMage() public {
        _registerPlayer(PLAYER, "Merlin", 2);

        assertEq(_getClassId(PLAYER), 2);
        assertEq(_getClassName(PLAYER), "Mage");
        assertEq(_getMaxHp(PLAYER), 80);
        assertEq(_getCurrentHp(PLAYER), 80);
        assertEq(_getAtk(PLAYER), 5);
        assertEq(_getDef(PLAYER), 5);
        assertEq(_getMagic(PLAYER), 35);
        assertTrue(_getIsAlive(PLAYER));
    }

    function testRegisterRanger() public {
        _registerPlayer(PLAYER, "Legolas", 3);

        assertEq(_getClassId(PLAYER), 3);
        assertEq(_getClassName(PLAYER), "Ranger");
        assertEq(_getMaxHp(PLAYER), 90);
        assertEq(_getCurrentHp(PLAYER), 90);
        assertEq(_getAtk(PLAYER), 8);
        assertEq(_getDef(PLAYER), 8);
        assertEq(_getMagic(PLAYER), 10);
        assertTrue(_getIsAlive(PLAYER));
    }

    function testRegisterRevertsWithoutMinimumPayment() public {
        vm.prank(PLAYER);
        vm.expectRevert("Minimium value to registration not reached!");
        rpg.registerPlayer{value: REGISTER_PRICE - 1}("Bruno", 1);
    }

    function testRegisterRevertsWithInvalidClass() public {
        vm.prank(PLAYER);
        vm.expectRevert("Invalid class name");
        rpg.registerPlayer{value: REGISTER_PRICE}(("Invalid"), 99);
    }

    //////////////////////////////
    // Level bonus
    //////////////////////////////

    function testGetWarriorLvUpBonus() public view {
        uint8[4] memory bonus = rpg.getLvUpBonus(1);

        assertEq(bonus[0], 25);
        assertEq(bonus[1], 12);
        assertEq(bonus[2], 8);
        assertEq(bonus[3], 0);
    }

    function testGetMageLvUpBonus() public view {
        uint8[4] memory bonus = rpg.getLvUpBonus(2);

        assertEq(bonus[0], 15);
        assertEq(bonus[1], 5);
        assertEq(bonus[2], 3);
        assertEq(bonus[3], 20);
    }

    function testGetRangerLvUpBonus() public view {
        uint8[4] memory bonus = rpg.getLvUpBonus(3);

        assertEq(bonus[0], 10);
        assertEq(bonus[1], 8);
        assertEq(bonus[2], 3);
        assertEq(bonus[3], 2);
    }

    //////////////////////////////
    // Battle
    //////////////////////////////

    function testBattleRevertsIfPlayerIsNotRegistered() public {
        vm.prank(PLAYER);
        vm.expectRevert("You are dead and can't battle");
        rpg.battle{value: COMMON_PRICE}(1, 1);
    }

    function testBattleRevertsWithZeroRounds() public {
        _registerPlayer(PLAYER, "Bruno", 1);

        vm.prank(PLAYER);
        vm.expectRevert("Battle must have at least 1 round");
        rpg.battle{value: COMMON_PRICE}(1, 0);
    }

    function testBattleRevertsWithoutEnoughPayment() public {
        _registerPlayer(PLAYER, "Bruno", 1);

        vm.prank(PLAYER);
        vm.expectRevert("Not enough ETH for this battle");
        rpg.battle{value: COMMON_PRICE - 1}(1, 1);
    }

    function testPlayerCanBattle() public {
        _registerPlayer(PLAYER, "Bruno", 1);

        vm.prank(PLAYER);
        rpg.battle{value: COMMON_PRICE}(1, 1);

        assertLe(_getCurrentHp(PLAYER), _getMaxHp(PLAYER));
        assertTrue(_getIsAlive(PLAYER));
    }

    function testPlayerCanBattleMultipleRounds() public {
        _registerPlayer(PLAYER, "Bruno", 1);

        vm.prank(PLAYER);
        rpg.battle{value: COMMON_PRICE * 3}(1, 3);

        assertLe(_getCurrentHp(PLAYER), _getMaxHp(PLAYER));
    }

    //////////////////////////////
    // Heal / Revive
    //////////////////////////////

    function testHealRevertsIfPlayerIsAtFullHealth() public {
        _registerPlayer(PLAYER, "Bruno", 1);

        vm.prank(PLAYER);
        vm.expectRevert("Player is dead or at full health");
        rpg.heal{value: COMMON_PRICE}(PLAYER);
    }

    function testHealRevertsWithoutPayment() public {
        _registerPlayer(PLAYER, "Bruno", 1);

        vm.prank(PLAYER);
        vm.expectRevert("Minimium payment required!");
        rpg.heal{value: COMMON_PRICE - 1}(PLAYER);
    }

    function testPlayerCanHealAfterTakingDamage() public {
        _registerPlayer(PLAYER, "Bruno", 1);

        vm.prank(PLAYER);
        rpg.battle{value: COMMON_PRICE}(2, 1);

        assertTrue(_getIsAlive(PLAYER));
        assertLt(_getCurrentHp(PLAYER), _getMaxHp(PLAYER));

        vm.prank(PLAYER);
        rpg.heal{value: COMMON_PRICE}(PLAYER);

        assertEq(_getCurrentHp(PLAYER), _getMaxHp(PLAYER));
        assertTrue(_getIsAlive(PLAYER));
    }

    function testReviveRevertsIfPlayerIsAlive() public {
        _registerPlayer(PLAYER, "Bruno", 1);

        vm.prank(PLAYER);
        vm.expectRevert("Player is already alive");
        rpg.revive{value: COMMON_PRICE}(PLAYER);
    }

    function testPlayerCanReviveAfterDeath() public {
        _registerPlayer(PLAYER, "Bruno", 1);

        vm.prank(PLAYER);
        rpg.battle{value: COMMON_PRICE}(10, 1);

        assertEq(_getCurrentHp(PLAYER), 0);
        assertFalse(_getIsAlive(PLAYER));

        vm.prank(PLAYER);
        rpg.revive{value: COMMON_PRICE}(PLAYER);

        assertEq(_getCurrentHp(PLAYER), _getMaxHp(PLAYER));
        assertTrue(_getIsAlive(PLAYER));
    }

    //////////////////////////////
    // PvP
    //////////////////////////////

    function testChallengePlayerRevertsIfAttackerIsNotRegistered() public {
        _registerPlayer(PLAYER_TWO, "Target", 1);

        vm.prank(PLAYER);
        vm.expectRevert("You are dead and can't battle");
        rpg.challengePlayer{value: COMMON_PRICE}(PLAYER_TWO, 1);
    }

    function testChallengePlayerRevertsIfTargetIsNotRegistered() public {
        _registerPlayer(PLAYER, "Attacker", 1);

        vm.prank(PLAYER);
        vm.expectRevert("You're target is already dead and can't battle");
        rpg.challengePlayer{value: COMMON_PRICE}(PLAYER_TWO, 1);
    }

    function testChallengePlayerRevertsWithZeroRounds() public {
        _registerPlayer(PLAYER, "Attacker", 1);
        _registerPlayer(PLAYER_TWO, "Target", 1);

        vm.prank(PLAYER);
        vm.expectRevert("Battle must have at least 1 round");
        rpg.challengePlayer{value: COMMON_PRICE}(PLAYER_TWO, 0);
    }

    function testChallengePlayerRevertsWithoutEnoughPayment() public {
        _registerPlayer(PLAYER, "Attacker", 1);
        _registerPlayer(PLAYER_TWO, "Target", 1);

        vm.prank(PLAYER);
        vm.expectRevert("Not enough ETH for this battle");
        rpg.challengePlayer{value: COMMON_PRICE - 1}(PLAYER_TWO, 1);
    }

    function testChallengePlayerWorks() public {
        _registerPlayer(PLAYER, "Attacker", 1);
        _registerPlayer(PLAYER_TWO, "Target", 2);

        vm.prank(PLAYER);
        rpg.challengePlayer{value: COMMON_PRICE}(PLAYER_TWO, 1);

        assertLe(_getCurrentHp(PLAYER), _getMaxHp(PLAYER));
        assertLe(_getCurrentHp(PLAYER_TWO), _getMaxHp(PLAYER_TWO));
    }

    //////////////////////////////
    // Withdraw
    //////////////////////////////

    function testOnlyOwnerCanWithdraw() public {
        _registerPlayer(PLAYER, "Bruno", 1);

        vm.prank(ATTACKER);
        vm.expectRevert(OnChainRpgBattle.NotOwner.selector);
        rpg.withdraw();
    }

    function testOwnerCanWithdraw() public {
        _registerPlayer(PLAYER, "Bruno", 1);

        uint256 contractBalanceBefore = address(rpg).balance;
        uint256 ownerBalanceBefore = address(this).balance;

        rpg.withdraw();

        assertEq(contractBalanceBefore, REGISTER_PRICE);
        assertEq(address(rpg).balance, 0);
        assertEq(address(this).balance, ownerBalanceBefore + contractBalanceBefore);
    }

    //////////////////////////////
    // Branch Coverage
    //////////////////////////////

    function testPlayerCritCanReturnTrue() public {
        _setRandomAtLeast(PLAYER, 7);

        vm.prank(PLAYER);
        bool crit = rpg.playerCrit();

        assertTrue(crit);
    }

    function testPlayerCritCanReturnFalse() public {
        _setRandomAtMost(PLAYER, 6);

        vm.prank(PLAYER);
        bool crit = rpg.playerCrit();

        assertFalse(crit);
    }

    function testEnemyCritCanReturnTrue() public {
        _setRandomAtLeast(PLAYER, 10);

        vm.prank(PLAYER);
        bool crit = rpg.enemyCrit();

        assertTrue(crit);
    }

    function testEnemyCritCanReturnFalse() public {
        _setRandomAtMost(PLAYER, 9);

        vm.prank(PLAYER);
        bool crit = rpg.enemyCrit();

        assertFalse(crit);
    }

    function testMageUsesMagicToCalculateDamageAgainstEnemy() public {
        _registerPlayer(PLAYER, "Merlin", 2);
        _setRandomAtLeast(PLAYER, 5);

        vm.prank(PLAYER);
        uint256 damage = rpg.calcDamageForPlayer(PLAYER, 1);

        assertGt(damage, 2);
    }

    function testWarriorCanDealOnlyBaseLevelDamageAgainstHighDefenseEnemy() public {
        _registerPlayer(PLAYER, "Bruno", 1);
        _setRandomAtMost(PLAYER, 1);

        vm.prank(PLAYER);
        uint256 damage = rpg.calcDamageForPlayer(PLAYER, 8); // Troll has high def

        assertEq(damage, 2);
    }

    function testMageUsesMagicToCalculateDamageAgainstAnotherPlayer() public {
        _registerPlayer(PLAYER, "Merlin", 2);
        _registerPlayer(PLAYER_TWO, "Target", 1);

        _setRandomAtLeast(PLAYER, 5);

        vm.prank(PLAYER);
        uint256 damage = rpg.calcDamageForPlayerVsPlayer(PLAYER, PLAYER_TWO);

        assertGt(damage, 2);
    }

    function testWarriorUsesAttackAgainstAnotherPlayerDefense() public {
        _registerPlayer(PLAYER, "Bruno", 1);
        _registerPlayer(PLAYER_TWO, "Merlin", 2);

        _setRandomAtMost(PLAYER, 1);

        vm.prank(PLAYER);
        uint256 damage = rpg.calcDamageForPlayerVsPlayer(PLAYER, PLAYER_TWO);

        assertGt(damage, 2);
    }

    function testPlayerDefeatsGoblinAndLevelsUp() public {
        _registerPlayer(PLAYER, "Merlin", 2);

        _setRandomAtLeast(PLAYER, 10);

        vm.prank(PLAYER);
        rpg.battle{value: COMMON_PRICE * 5}(1, 5);

        assertGt(_getLevel(PLAYER), 1);
        assertEq(_getCurrentHp(PLAYER), _getMaxHp(PLAYER));
        assertTrue(_getIsAlive(PLAYER));
    }

    function testPlayerCanReceiveEtherDropAfterDefeatingEnemy() public {
        _registerPlayer(PLAYER, "Merlin", 2);

        uint256 battlePrice = COMMON_PRICE * 5;
        uint256 expectedDrop = 0.0001 ether;

        _setRandomAtLeast(PLAYER, 10);

        vm.prank(PLAYER);
        rpg.battle{value: battlePrice}(1, 5);

        assertEq(address(rpg).balance, REGISTER_PRICE + battlePrice - expectedDrop);
    }

    function testChallengePlayerCanKillTargetPlayer() public {
        _registerPlayer(PLAYER, "Merlin", 2);
        _registerPlayer(PLAYER_TWO, "Target", 3);

        _setRandomAtLeast(PLAYER, 10);

        vm.prank(PLAYER);
        rpg.challengePlayer{value: COMMON_PRICE * 10}(PLAYER_TWO, 10);

        assertFalse(_getIsAlive(PLAYER_TWO));
        assertEq(_getCurrentHp(PLAYER_TWO), 0);
    }

    function testGuildPointsAreUpdatedWhenPlayerKillsEnemyGuildMember() public {
        _registerPlayer(PLAYER, "Bruno", 2);
        _registerPlayer(PLAYER_TWO, "Target", 3);

        vm.prank(PLAYER);
        rpg.createGuild{value: 0.01 ether}("Mage Guild");

        vm.prank(PLAYER_TWO);
        rpg.createGuild{value: 0.01 ether}("Ranger Guild");

        _setRandomAtLeast(PLAYER, 10);

        vm.prank(PLAYER);
        rpg.challengePlayer{value: COMMON_PRICE * 10}(PLAYER_TWO, 10);

        (,,,, uint256 winnerPoints,) = rpg.guilds(1);
        (,,,, uint256 loserPoints,) = rpg.guilds(2);

        assertEq(winnerPoints, 10);
        assertEq(loserPoints, 0);
    }

    function testTopGuildsReturnsGuildWithMostPoints() public {
        _registerPlayer(PLAYER, "Bruno", 2);
        _registerPlayer(PLAYER_TWO, "Target", 3);

        vm.prank(PLAYER);
        rpg.createGuild{value: 0.01 ether}("Mage Guild");

        vm.prank(PLAYER_TWO);
        rpg.createGuild{value: 0.01 ether}("Ranger Guild");

        _setRandomAtLeast(PLAYER, 10);

        vm.prank(PLAYER);
        rpg.challengePlayer{value: COMMON_PRICE * 10}(PLAYER_TWO, 10);

        OnChainRpgBattle.Guild[5] memory topGuilds = rpg.getTopGuilds();

        assertEq(topGuilds[0].id, 1);
        assertEq(topGuilds[0].name, "Mage Guild");
        assertEq(topGuilds[0].points, 10);
    }

    function testClaimAchievementRevertsIfPlayerIsNotRegistered() public {
        vm.prank(PLAYER);
        vm.expectRevert("Only registered players can claim achievements");
        rpg.claimAchievement(1);
    }

    function testClaimAchievementRevertsIfInvalidAchievement() public {
        _registerPlayer(PLAYER, "Bruno", 1);

        vm.prank(PLAYER);
        vm.expectRevert("Invalid achievement");
        rpg.claimAchievement(999);
    }

    function testClaimAchievementRevertsIfNotEnoughMonsterKills() public {
        _registerPlayer(PLAYER, "Bruno", 1);

        vm.prank(PLAYER);
        vm.expectRevert("Not enough monsters slayed");
        rpg.claimAchievement(1);
    }

    function testClaimAchievementRevertsIfNotEnoughPlayerKills() public {
        address freshPlayer = makeAddr("freshPlayer");
        vm.deal(freshPlayer, 10 ether);

        vm.prank(freshPlayer);
        rpg.registerPlayer{value: REGISTER_PRICE}("Fresh", 1);

        vm.prank(freshPlayer);
        vm.expectRevert("Not enough unique players slayed");
        rpg.claimAchievement(100);
    }

    function testCanClaimMonsterAchievement() public {
        _registerPlayer(PLAYER, "Bruno", 1);

        uint256 requirement = rpg.achievementRequirement(1);
        rpg.setMonsterSlayeds(PLAYER, 1, requirement);

        vm.expectEmit(true, true, true, false);
        emit AchievementClaimed(PLAYER, 1, 1);

        vm.prank(PLAYER);
        rpg.claimAchievement(1);

        assertEq(rpg.ownerOf(1), PLAYER);
        assertEq(rpg.balanceOf(PLAYER), 1);
        assertTrue(rpg.hasAchievement(PLAYER, 1));
        assertEq(rpg.tokenAchievement(1), 1);
    }

    function testCannotClaimSameAchievementTwice() public {
        _registerPlayer(PLAYER, "Bruno", 1);

        uint256 requirement = rpg.achievementRequirement(1);
        rpg.setMonsterSlayeds(PLAYER, 1, requirement);

        vm.startPrank(PLAYER);
        rpg.claimAchievement(1);

        vm.expectRevert("Achievement already claimed");
        rpg.claimAchievement(1);

        vm.stopPrank();
    }

    function testPlayerCanCreateGuild() public {
        _registerPlayer(PLAYER, "Bruno", 1);

        vm.prank(PLAYER);
        rpg.createGuild{value: 0.01 ether}("Dragon Hunters");

        assertEq(rpg.playerGuild(PLAYER), 1);
        assertEq(rpg.nextGuildId(), 2);

        (uint256 id, string memory name, address guildOwner, uint256 membersCount, uint256 points, bool exists) =
            rpg.guilds(1);

        assertEq(id, 1);
        assertEq(name, "Dragon Hunters");
        assertEq(guildOwner, PLAYER);
        assertEq(membersCount, 1);
        assertEq(points, 0);
        assertTrue(exists);
    }

    function testCreateGuildRevertsWithoutPayment() public {
        _registerPlayer(PLAYER, "Bruno", 1);

        vm.prank(PLAYER);
        vm.expectRevert("Minimum payment required to create guild");
        rpg.createGuild{value: 0.01 ether - 1}("Dragon Hunters");
    }

    function testCreateGuildRevertsIfPlayerNotRegistered() public {
        vm.prank(PLAYER);
        vm.expectRevert("Only registered alive players can create guilds");
        rpg.createGuild{value: 0.01 ether}("Dragon Hunters");
    }

    function testCreateGuildRevertsIfNameAlreadyExists() public {
        _registerPlayer(PLAYER, "Bruno", 1);
        _registerPlayer(PLAYER_TWO, "Gandalf", 2);

        vm.prank(PLAYER);
        rpg.createGuild{value: 0.01 ether}("Dragon Hunters");

        vm.prank(PLAYER_TWO);
        vm.expectRevert("Guild name already exists");
        rpg.createGuild{value: 0.01 ether}("Dragon Hunters");
    }

    function testPlayerCanJoinGuild() public {
        _registerPlayer(PLAYER, "Bruno", 1);
        _registerPlayer(PLAYER_TWO, "Gandalf", 2);

        vm.prank(PLAYER);
        rpg.createGuild{value: 0.01 ether}("Dragon Hunters");

        vm.prank(PLAYER_TWO);
        rpg.joinGuild(1);

        assertEq(rpg.playerGuild(PLAYER_TWO), 1);

        (,,, uint256 membersCount,,) = rpg.guilds(1);
        assertEq(membersCount, 2);
    }

    function testJoinGuildRevertsIfGuildDoesNotExist() public {
        _registerPlayer(PLAYER, "Bruno", 1);

        vm.prank(PLAYER);
        vm.expectRevert("Guild does not exist");
        rpg.joinGuild(999);
    }

    function testPlayerCanLeaveGuild() public {
        _registerPlayer(PLAYER, "Bruno", 1);
        _registerPlayer(PLAYER_TWO, "Gandalf", 2);

        vm.prank(PLAYER);
        rpg.createGuild{value: 0.01 ether}("Dragon Hunters");

        vm.prank(PLAYER_TWO);
        rpg.joinGuild(1);

        vm.prank(PLAYER_TWO);
        rpg.leaveGuild();

        assertEq(rpg.playerGuild(PLAYER_TWO), 0);

        (,,, uint256 membersCount,,) = rpg.guilds(1);
        assertEq(membersCount, 1);
    }

    function testGuildOwnerCannotLeaveGuild() public {
        _registerPlayer(PLAYER, "Bruno", 1);

        vm.prank(PLAYER);
        rpg.createGuild{value: 0.01 ether}("Dragon Hunters");

        vm.prank(PLAYER);
        vm.expectRevert("Guild owner cannot leave guild");
        rpg.leaveGuild();
    }

    function testGuildOwnerCanAddMember() public {
        _registerPlayer(PLAYER, "Bruno", 1);
        _registerPlayer(PLAYER_TWO, "Gandalf", 2);

        vm.prank(PLAYER);
        rpg.createGuild{value: 0.01 ether}("Dragon Hunters");

        vm.prank(PLAYER);
        rpg.addGuildMember(1, PLAYER_TWO);

        assertEq(rpg.playerGuild(PLAYER_TWO), 1);

        (,,, uint256 membersCount,,) = rpg.guilds(1);
        assertEq(membersCount, 2);
    }

    function testNonGuildOwnerCannotAddMember() public {
        _registerPlayer(PLAYER, "Bruno", 1);
        _registerPlayer(PLAYER_TWO, "Gandalf", 2);
        _registerPlayer(ATTACKER, "Evil", 3);

        vm.prank(PLAYER);
        rpg.createGuild{value: 0.01 ether}("Dragon Hunters");

        vm.prank(ATTACKER);
        vm.expectRevert("Only guild owner can add members");
        rpg.addGuildMember(1, PLAYER_TWO);
    }

    function testGuildOwnerCanRemoveMember() public {
        _registerPlayer(PLAYER, "Bruno", 1);
        _registerPlayer(PLAYER_TWO, "Gandalf", 2);

        vm.prank(PLAYER);
        rpg.createGuild{value: 0.01 ether}("Dragon Hunters");

        vm.prank(PLAYER);
        rpg.addGuildMember(1, PLAYER_TWO);

        vm.prank(PLAYER);
        rpg.removeGuildMember(1, PLAYER_TWO);

        assertEq(rpg.playerGuild(PLAYER_TWO), 0);

        (,,, uint256 membersCount,,) = rpg.guilds(1);
        assertEq(membersCount, 1);
    }

    function testGuildOwnerCannotRemoveHimself() public {
        _registerPlayer(PLAYER, "Bruno", 1);

        vm.prank(PLAYER);
        rpg.createGuild{value: 0.01 ether}("Dragon Hunters");

        vm.prank(PLAYER);
        vm.expectRevert("Guild owner cannot be removed");
        rpg.removeGuildMember(1, PLAYER);
    }

    function testGetGuildsReturnsCreatedGuilds() public {
        _registerPlayer(PLAYER, "Bruno", 1);
        _registerPlayer(PLAYER_TWO, "Gandalf", 2);

        vm.prank(PLAYER);
        rpg.createGuild{value: 0.01 ether}("Dragon Hunters");

        vm.prank(PLAYER_TWO);
        rpg.createGuild{value: 0.01 ether}("Mage Council");

        OnChainRpgBattle.Guild[] memory guilds = rpg.getGuilds(0, 10);

        assertEq(guilds.length, 2);
        assertEq(guilds[0].name, "Dragon Hunters");
        assertEq(guilds[1].name, "Mage Council");
    }

    function _setRandomAtLeast(address caller, uint256 minValue) internal {
        for (uint256 i = 1; i < 10_000; i++) {
            vm.warp(1_000 + i);
            vm.roll(2_000 + i);

            vm.prank(caller);
            uint256 random = rpg.randomNumber();

            if (random >= minValue) {
                return;
            }
        }

        revert("Could not set random at least value");
    }

    function _setRandomAtMost(address caller, uint256 maxValue) internal {
        for (uint256 i = 1; i < 10_000; i++) {
            vm.warp(10_000 + i);
            vm.roll(20_000 + i);

            vm.prank(caller);
            uint256 random = rpg.randomNumber();

            if (random <= maxValue) {
                return;
            }
        }

        revert("Could not set random at most value");
    }

    //////////////////////////////
    // Helpers
    //////////////////////////////

    function _registerPlayer(address player, string memory name, uint8 classId) internal {
        vm.prank(player);
        rpg.registerPlayer{value: REGISTER_PRICE}(name, classId);
    }

    function _getLevel(address player) internal view returns (uint256 lv) {
        (lv,,,,,,,,,,,) = rpg.players(player);
    }

    function _getName(address player) internal view returns (string memory name) {
        (, name,,,,,,,,,,) = rpg.players(player);
    }

    function _getExp(address player) internal view returns (uint256 exp) {
        (,, exp,,,,,,,,,) = rpg.players(player);
    }

    function _getNextLv(address player) internal view returns (uint256 nextLv) {
        (,,, nextLv,,,,,,,,) = rpg.players(player);
    }

    function _getClassId(address player) internal view returns (uint8 classId) {
        (,,,, classId,,,,,,,) = rpg.players(player);
    }

    function _getClassName(address player) internal view returns (string memory className) {
        (,,,,, className,,,,,,) = rpg.players(player);
    }

    function _getMaxHp(address player) internal view returns (uint256 maxHp) {
        (,,,,,, maxHp,,,,,) = rpg.players(player);
    }

    function _getCurrentHp(address player) internal view returns (uint256 currentHp) {
        (,,,,,,, currentHp,,,,) = rpg.players(player);
    }

    function _getAtk(address player) internal view returns (uint256 atk) {
        (,,,,,,,, atk,,,) = rpg.players(player);
    }

    function _getDef(address player) internal view returns (uint256 def) {
        (,,,,,,,,, def,,) = rpg.players(player);
    }

    function _getMagic(address player) internal view returns (uint256 magic) {
        (,,,,,,,,,, magic,) = rpg.players(player);
    }

    function _getIsAlive(address player) internal view returns (bool isAlive) {
        (,,,,,,,,,,, isAlive) = rpg.players(player);
    }

    receive() external payable {}
}
