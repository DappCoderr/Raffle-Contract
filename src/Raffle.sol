/**
 * Layout of Contract:
 * version
 * imports
 * errors
 * interfaces, libraries, contracts
 * Type declarations
 * State variables
 * Events
 * Modifiers
 * Functions
 */

/**
 * Layout of Functions:
 * constructor
 * receive function (if exists)
 * fallback function (if exists)
 * external
 * public
 * internal
 * private
 * view & pure functions
 */

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {VRFCoordinatorV2Interface} from "@chainlink/contracts/src/v0.8/vrf/interfaces/VRFCoordinatorV2Interface.sol";
import {VRFConsumerBaseV2} from "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

contract Raffle is VRFConsumerBaseV2{

    /**Custom Errors */
    error Raffle_NotEnoughtEthSent();
    error Raffle_TransferFailed();
    error Raffle_RaffleNotOpen();
    error Raffle__UpkeepNotNeeded(uint256 currentBalance, uint256 numPlayers, uint256 raffleState);

    /** Enums */
    enum RaffleState {
        OPEN,
        CALCULATING
    }

    /** State Variables */
    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private constant NUM_WORDS = 1;

    uint256 private immutable i_entranceFee;
    uint256 private immutable i_interval;
    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
    bytes32 private immutable i_gasLane;
    uint64 private immutable i_subscriptionId;
    uint32 private immutable i_callbackGasLimit;

    address payable[] private s_player;
    uint256 public s_raffleStartingTime;
    address payable private s_recentWinner; 
    RaffleState private s_raffleState;

    /**Events */
    event EnterRaffle(address indexed player);
    event PickWinner(address indexed winner);

    constructor(uint256 entranceFee, uint256 interval, address vrf_coordinator, bytes32 gasLane, uint64 subscriptionId, uint32 callbackGasLimit)
     VRFConsumerBaseV2(vrf_coordinator){
        i_entranceFee = entranceFee;
        i_interval = interval;
        s_raffleStartingTime = block.timestamp;
        i_vrfCoordinator = VRFCoordinatorV2Interface(vrf_coordinator);
        i_gasLane = gasLane;
        i_subscriptionId = subscriptionId;
        s_raffleState = RaffleState.OPEN;
        i_callbackGasLimit = callbackGasLimit;
    }

    function enterRaffle() external payable{
        if(msg.value > i_entranceFee){
            revert Raffle_NotEnoughtEthSent();
        }
        if(s_raffleState != RaffleState.OPEN){
            revert Raffle_RaffleNotOpen();
        }
        s_player.push(payable(msg.sender));
        emit EnterRaffle(msg.sender);
    }

    function checkUpkeep(bytes memory) public view returns(bool upKeepNeeded, bytes memory){
        bool timeHasPassed = (block.timestamp - s_raffleStartingTime) >= i_interval;
        bool isOpen = RaffleState.OPEN == s_raffleState;
        bool balance = address(this).balance > 0;
        bool hasPlayers = s_player.length > 0;
        upKeepNeeded = (timeHasPassed && isOpen && balance && hasPlayers);
        return (upKeepNeeded, "0x0");
    }

    function performUpkeep(bytes calldata) external {

        (bool upKeepNeeded,) = checkUpkeep("");
        if(!upKeepNeeded){
            revert Raffle__UpkeepNotNeeded(
                address(this).balance,
                s_player.length,
                uint256(s_raffleState)
            );
        }

        // 1. Request the RNG <- from chainlink
        // 2. Get the random number <- chainlink node send us

        // Now what will happen
        /**
         * We will make the request to the chainlink node to give us the random number.
         * It will generate the random number and call the onchain contract vrf-coordinator where only chainlink node can respond to that.
         * That contract will call rawFullfillRandomWords --> that will call fullFillRandomWords
         */
        s_raffleState = RaffleState.CALCULATING;
        uint256 requestId = i_vrfCoordinator.requestRandomWords(
            i_gasLane, 
            i_subscriptionId, 
            REQUEST_CONFIRMATIONS, 
            i_callbackGasLimit, 
            NUM_WORDS
        );
    }

    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal override {
        uint256 indexOfWinner = randomWords[0] % s_player.length;
        address payable winner = s_player[indexOfWinner];
        s_recentWinner = winner;
        s_raffleState = RaffleState.OPEN;

        // Reset the array and the timestamp for new raffle
        s_player = new address payable[](0);
        s_raffleStartingTime = block.timestamp;

        (bool success, ) = s_recentWinner.call{value: address(this).balance}("");
        if(!success){
            revert Raffle_TransferFailed();
        }
        emit PickWinner(winner);
    }

    /**Getter Function */

    function getEntranceFee() external view returns(uint256){
        return i_entranceFee;
    }
}
