import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import '@typechain/hardhat';
import '@typechain/ethers-v5';

const config: HardhatUserConfig = {
  solidity: "0.8.17",
};

export default config;
