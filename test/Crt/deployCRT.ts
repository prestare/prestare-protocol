import { HardhatRuntimeEnvironment } from "hardhat/types";
import { ethers, Signer, BigNumber, Contract } from 'ethers';
import { deployPRS, deployCRT } from "../../helpers/contracts-deployments";
import { getCounterConfigurator, getPRS } from "../../helpers/contracts-helpers";
const hre: HardhatRuntimeEnvironment = require('hardhat');


async function main() {
    let [admin,user1,] = await hre.ethers.getSigners();
    
    // const PRS = await deployPRS(admin);

    // let pro = hre.ethers.provider;
    // const prs = await hre.ethers.deployContract("PRS");
    // await prs.waitForDeployment();
    // console.log(prs.address);
    const CounterConfigurator = await getCounterConfigurator();

    const CRT = await deployCRT(admin);
    await CounterConfigurator.connect(admin).setCRT(CRT.address);
    
    // let tx1 = await PRS.connect(user1).buy(user1.address, buy);


}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });