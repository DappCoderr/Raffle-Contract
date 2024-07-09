## Provably Random Raffle Contracts

### What we are doing?

1. User can enter by paying for the ticket.

- The ticket fees are going to go to the winner during the draw.

2. After x period of time, the lottery will automatically draw a winner.

- This will be done programmatically.

3. Using Chainlink VRF & Chainlink Automation

- Chainlink VRF -> Randomness
- Chainlink Automation -> Time based triggers

## Project Structure 📦

Before delving into the code, let's take a moment to understand the structure of the repository:

- `/src`: This folder contains all the solidity smart contract of the Raffle Contract.
- `/script`: Here, you will find the script to deploy the smart contract
- `/test`: All the unit, integration testing are here.

## Foundry

We are using Foundry toolkit for this application development:

- `Forge`: Ethereum testing framework (like Truffle, Hardhat and DappTools).
- `Cast`: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
- `Anvil`: Local Ethereum node, akin to Ganache, Hardhat Network.
- `Chisel`: Fast, utilitarian, and verbose solidity REPL.

## Tests

1. Write deploy script
2. Write tests

- Local Chain
- Forked Testnet
- Forked Mainnet
