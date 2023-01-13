import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import '@typechain/hardhat';
import '@typechain/ethers-v5';

const config: HardhatUserConfig = {
  solidity: {
    version:"0.8.17",
    settings: {
      optimizer: {
        enabled: true,
        runs: 100000,
      },
    }
  }
  
};

export default config;
