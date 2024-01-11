import { HardhatRuntimeEnvironment } from "hardhat/types";
import { ethers, Signer, BigNumber, Contract } from 'ethers';
import { deployPRS, deployCRT } from "../../helpers/contracts-deployments";
import { getPRS } from "../../helpers/contracts-helpers";
const hre: HardhatRuntimeEnvironment = require('hardhat');


async function main() {
    let [admin,user1,] = await hre.ethers.getSigners();
    
    // const PRS = await deployPRS(admin);

    // let pro = hre.ethers.provider;
    // const prs = await hre.ethers.deployContract("PRS");
    // await prs.waitForDeployment();
    // console.log(prs.address);
    const PRS = await getPRS();
    let amount = '200';
    let deci = await PRS.decimals();
    let buy = ethers.utils.parseUnits(amount, deci);
    // console.log("amount ", buy);

    // let tx1 = await PRS.connect(user1).buy(user1.address, buy);
    let balance = await PRS.balanceOf(user1.address);

    let stake = "20";
    let stakeAm = ethers.utils.parseUnits(stake, 8);

    let tx = await PRS.connect(user1).stake(user1.address, stakeAm);
    balance = await PRS.balanceOf(user1.address);
    console.log(balance);


}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });