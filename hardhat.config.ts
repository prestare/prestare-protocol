import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@nomiclabs/hardhat-ethers";
import '@typechain/hardhat';
import '@typechain/ethers-v5';
import 'hardhat-contract-sizer';
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
        runs: 20000,
      },
    }
  },

  networks: {
    hardhat: {
      chainId: 4545,
      forking: {
        url: "https://eth-mainnet.g.alchemy.com/v2/" + process.env.ALCHEMY_ID,
        blockNumber: 17256120
      },
      gasPrice: 0,
      initialBaseFeePerGas: 0,
      loggingEnabled: true
    },
    goerli: {
      url: "https://eth-goerli.g.alchemy.com/v2/" + process.env.GOERLI_ID,
      chainId: 5,
    },
    localhost: {
      url: "http://120.53.224.174:8545",
      chainId: 2,
    },
    local: {
      url: "http://127.0.0.1:8545/"
    },
    prestare: {
      url: "http://120.53.224.174:8547",
      chainId: 4545,
    }
  }
};

export default config;
