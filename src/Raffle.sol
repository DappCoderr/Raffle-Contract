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

contract Raffle{

    /**Custom Errors */
    error Raffle_NotEnoughtEthSent();

    /**State Variables */
    uint256 private immutable i_entranceFee;
    uint256 private immutable i_interval;
    uint256 public s_raffleStartingTime;

    /**Events */
    event EnterRaffle(address indexed player);

    constructor(uint256 entranceFee, uint256 interval){
        i_entranceFee = entranceFee;
        i_interval = interval;
        s_raffleStartingTime = block.timestamp;
    }

    function enterRaffle() external payable{
        if(msg.value > i_entranceFee){
            revert Raffle_NotEnoughtEthSent();
        }
        emit EnterRaffle(msg.sender);
    }

    function pickWinner() external {
        if(block.timestamp - s_raffleStartingTime < i_interval){
            revert();
        }
    }

    /**Getter Function */

    function getEntranceFee() external view returns(uint256){
        return i_entranceFee;
    }
}
