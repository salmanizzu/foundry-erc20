// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {StarToken} from "../src/StarToken.sol";

contract DeployStarToken is Script {
    uint256 public constant INITIAL_SUPPLY = 1000 ether;

    function run() external returns (StarToken) {
        vm.startBroadcast();
        StarToken starToken = new StarToken(INITIAL_SUPPLY);
        vm.stopBroadcast();
        return starToken;
    }
}
