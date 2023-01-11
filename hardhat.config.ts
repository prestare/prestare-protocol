import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import '@typechain/hardhat';
import '@typechain/ethers-v5';

const config: HardhatUserConfig = {
  solidity: {
    compilers: [
      {
        version: "0.8.10",
      },
      {
        version: "0.6.12",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
            details: {
              yul: true,
              yulDetails: {
                stackAllocation: true,
                optimizerSteps: "dhfoDgvulfnTUtnIf"
              }
            }
          }
        }
      }
    ]
  }
};

export default config;
