// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {OnChainRpgBattle} from "../src/OnChainRpgBattle.sol";

contract DeployOnChainRpgBattle is Script {
    function run() external returns (OnChainRpgBattle) {
        vm.startBroadcast();

        OnChainRpgBattle rpg = new OnChainRpgBattle();

        vm.stopBroadcast();

        return rpg;
    }
}
