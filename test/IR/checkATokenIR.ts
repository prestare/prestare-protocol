import { HardhatRuntimeEnvironment } from "hardhat/types";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { BigNumber, Contract } from "ethers";
import { impersonateAccount } from "@nomicfoundation/hardhat-network-helpers";

const hre: HardhatRuntimeEnvironment = require('hardhat');
import { mintToken, depositToken } from '../helper/operationHelper';
import { aDAIHolder, DAIHolder } from "../../helpers/holder";
import { getPlatformInterestRateModel, getTokenContract, getPTokenContract } from "../../helpers/contracts-getter";

async function main() {
    let [signer,] = await hre.ethers.getSigners();
    let PlatformIRModel = await getPlatformInterestRateModel();
    let tokenSymbol = 'aDAI';
    const token : Contract = await getTokenContract("DAI");
    const atoken: Contract = await getTokenContract(tokenSymbol);
    const pToken: Contract = await getPTokenContract(tokenSymbol);
    // await PlatformIRModel.connect(signer).calculateInterestRates();
    // ts的类型中的函数不可以重载，因此同名函数会导致ts只能以字符串的形式区分函数
    await PlatformIRModel.connect(signer)["calculateInterestRates(address,uint256,uint256,uint256)"](token.address, BigNumber.from("0"), BigNumber.from("0"),BigNumber.from("1000"));

    const {
        nowP2PSupplyIndex,
        nowP2PBorrowIndex,
        poolSupplyIndex,
        poolBorrowIndex
    } = await PlatformIRModel.getReserveIRIndex(pToken.address);
    //token.address, BigNumber.from("0"), BigNumber.from("0"),BigNumber.from("1000")
    console.log("nowP2PSupplyIndex =", nowP2PSupplyIndex);
    console.log("nowP2PBorrowIndex =", nowP2PBorrowIndex);
    console.log("poolSupplyIndex =", poolSupplyIndex);
    console.log("poolBorrowIndex =", poolBorrowIndex);

}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });