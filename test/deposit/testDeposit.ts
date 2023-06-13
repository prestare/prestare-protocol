// import { HardhatRuntimeEnvironment } from "hardhat/types";
// import { TokenContractName } from '../../helpers/types';

// const hre: HardhatRuntimeEnvironment = require('hardhat');
// import { mintToken, depositToken } from '../helper/operationHelper';

// async function main() {
//     let amount = '200';
//     let half = '100';
//     let tokens = Object.keys(TokenContractName)
//     // for (let tokenSymbol of tokens) {
//     //     // console.log(tokenSymbol);
//     //     await mintToken(tokenSymbol, amount);
//     //     await depositToken(tokenSymbol, amount);
//     // }
//     let [signer, signer2] = await hre.ethers.getSigners();
//     let tokenSymbol = 'DAI';
//     await mintToken(signer, tokenSymbol, amount);
//     await mintToken(signer2, tokenSymbol, amount);
//     await depositToken(signer, tokenSymbol, half);
//     await depositToken(signer2, tokenSymbol, half);

// }

// main()
//     .then(() => process.exit(0))
//     .catch((error) => {
//         console.error(error);
//         process.exit(1);
//     });