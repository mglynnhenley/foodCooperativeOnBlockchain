# Food Cooperative on Blockchain

Welcome to the **Food Cooperative on Blockchain** project! This repository contains the design and implementation of a blockchain-based system aimed at improving transparency, security, and efficiency in food cooperatives.

## Overview

Food cooperatives are community-driven organizations that allow members to collectively purchase food at lower prices by placing bulk orders directly with farmers. This project addresses key challenges in the cooperative model by leveraging blockchain technology to ensure transparency, democratic control, and secure economic participation. The system is designed to align with the seven cooperative principles set by the International Co-operative Alliance.

## Key Features

- **Smart Contracts**: Implemented using Solidity, our smart contracts manage market operations, produce listings, and group orders.
- **Modular Design**: The system consists of three main contracts—Market, Produce, and Group Order—each serving a distinct purpose while ensuring scalability and security.
- **Security Features**: The project employs best practices such as the check-effects-interaction pattern, factory pattern, and secure data storage to prevent common vulnerabilities like re-entrancy and denial of service attacks.

## System Components

### 1. Market Contract
- Manages the listing of produce by farmers.
- Ensures that only verified farmers can add produce to the market.

### 2. Produce Contract
- Deployed by farmers to manage specific produce items.
- Tracks orders and ensures that only valid transactions are processed.

### 3. Group Order Contract
- Facilitates bulk ordering by cooperative members.
- Ensures that funds are securely held in escrow until the order is fulfilled or refunded.

## How It Works

1. **Farmers List Produce**: Farmers can list their produce on the market, where cooperative members can view available items.
2. **Members Place Orders**: Cooperative members can place orders for listed produce. If enough members participate, the order is processed.
3. **Escrow System**: Funds are securely held in an escrow until the order is accepted by the farmer or refunded if the order fails.
4. **Voting System**: Members can vote to cancel an order if it doesn't meet the required conditions, ensuring democratic participation.

## Running the Project with Remix IDE

1. **Compile the Contracts**: Ensure the Solidity files (`Market.sol`, `Produce.sol`, and `GroupOrder.sol`) are compiled. You can do this using the "Solidity Compiler" plugin in Remix.

2. **Deploying Contracts**:
   - Use the deployment scripts available in the `scripts` folder, such as `deploy_with_ethers.ts` or `deploy_with_web3.ts`, to deploy the contracts.
   - Update the contract name and constructor arguments in the script if you wish to deploy a different contract.

3. **Running Scripts**:
   - Right-click on the script file in the File Explorer and select "Run".
   - Ensure that the contract has been compiled before running the script.
   - The output will be displayed in the Remix terminal.

### Notes on Modules and Imports

- Remix supports a limited set of modules for `require/import`. Supported modules include `ethers`, `web3`, `swarmgw`, `chai`, `multihashes`, `remix`, and `hardhat`.
- Attempting to use unsupported modules will result in an error message like: `'<module_name> module require is not supported by Remix IDE'`.

## Limitations and Future Work

- **Security**: The system currently assumes a trusted external cooperative organization. Future work could focus on reducing this dependency and further decentralizing the system.
- **Further Extensions**: Potential extensions include implementing on-chain reputation systems for farmers and integrating oracles for food distribution tracking.

## License

This project is licensed under the MIT License.

## Acknowledgements

Many thanks to my supervisor Alastair Janse van Rensburg and tutor Thomas Melham for their guidance and support throughout this project.

## Contact

For questions or contributions, please reach out to matildaglynnh@gmail.com
