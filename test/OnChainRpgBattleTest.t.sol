// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {OnChainRpgBattle} from "../src/OnChainRpgBattle.sol";

contract OnChainRpgBattleTest is Test {
    OnChainRpgBattle public rpg;

    address public PLAYER = makeAddr("PLAYER");
    address public PLAYER_TWO = makeAddr("PLAYER_TWO");
    address public ATTACKER = makeAddr("ATTACKER");

    uint256 public constant REGISTER_PRICE = 0.0001 ether;
    uint256 public constant COMMON_PRICE = 0.001 ether;

    function setUp() public {
        rpg = new OnChainRpgBattle();

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