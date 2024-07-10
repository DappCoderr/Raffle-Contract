// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Importing using root directory path
import {Script} from "forge-std/Script.sol";
import {Raffle} from "src/Raffle.sol";
import {HeHelperConfig} from "script/HelperConfig.s.sol";

contract DeployRaffle is Script{

    function run() public {}

    function deployRaffle() external returns(Raffle, HelperConfig){
        HelperConfig helperConfig = new HeHelperConfig();
        //local -> Deploy Mock, get local config
        //Sepolia -> get sepolia config
        HelperConfig.NetworkConfig memory config = helperConfig.getConfig();
        
        vm.startBroadcast();
        Raffle raffle = new Raffle(
            config.entranceFee,
            config.interval,
            config.vrf_coordinator,
            config.gasLane,
            config.subscriptionId,
            config.callbackGasLimit
        );
        vm.stopBroadcast();

        return(raffle, helperConfig);
    }
}