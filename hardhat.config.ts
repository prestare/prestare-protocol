import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@nomiclabs/hardhat-ethers";
import '@typechain/hardhat';
import '@typechain/ethers-v5';

const dotenv = require("dotenv");
dotenv.config();

function mnemonic() {
  return [process.env.PRIVATE_KEY1, process.env.PRIVATE_KEY2, process.env.PRIVATE_KEY3];
}

const config: HardhatUserConfig = {
  solidity: {
    version:"0.8.17",
    settings: {
      optimizer: {
        enabled: true,
        runs: 100000,
      },
    }
  },

  networks: {
    hardhat: {
      forking: {
        url: "https://eth-mainnet.g.alchemy.com/v2/" + process.env.ALCHEMY_ID,
        blockNumber: 15415000
      }
    },
    localhost: {
      url: "http://120.53.224.174:8545/"
    }
  }
};

export default config;
