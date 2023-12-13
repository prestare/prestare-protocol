import { HardhatRuntimeEnvironment } from "hardhat/types";
import { borrowERC20 } from '../helper/operationHelper';
import { getCounter } from "../../helpers/contracts-helpers";
const hre: HardhatRuntimeEnvironment = require('hardhat');

async function main() {
    const [admin, user1] = await hre.ethers.getSigners();
    let borrowAmount = "50";
    let borrowSymbol = 'USDC';
    let borrowRisk = 2;
    await borrowERC20(user1, borrowSymbol, borrowRisk, borrowAmount);

    let counter = await getCounter(admin);
    let userAccountData = await counter.getUserAccountData(user1.address, borrowRisk);
    console.log(userAccountData);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });