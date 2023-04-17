import {ethers, Signer} from "ethers";
import {HardhatRuntimeEnvironment} from "hardhat/types";
import { 
    getAllMockedTokens,
} from "../../helpers/contracts-helpers";
import { getAllTokenAddresses } from "../../helpers/utils";
import { getCounterAddressesProvider } from "../../helpers/contracts-helpers";
import { getCounterConfigurator } from "../../helpers/contracts-helpers";
const hre: HardhatRuntimeEnvironment = require("hardhat");

const upgradeAssetClass =async (
    tokenAddresses: { [symbol: string]: string },
    admin: Signer
    ) => {
    const addressProvider = await getCounterAddressesProvider();
    let reserveSymbols: string[] = [];
    let initInputParams: {
        pToken: string;
        variableDebtToken: string;
        underlyingAssetDecimals: BigNumber;
        interestRateStrategyAddress: string;
        underlyingAsset: string;
        treasury: string;
        incentivesController: string;
        underlyingAssetName: string;
        pTokenName: string;
        pTokenSymbol: string;
        variableDebtTokenName: string;
        variableDebtTokenSymbol: string;
        params: string;
    }[] = [];
    let strategyRates: [
        string, // addresses provider
        string,
        string,
        string,
        string,
    ];
    // const reserves = Object.entries(reservesParams);
    const configurator = await getCounterConfigurator();

    for (let index = 0; index < initInputParams.length; index++) {
        console.log(initInputParams[index]);
        await configurator.connect(admin).upgradeAssetClass(initInputParams[index]);
    }
}

async function main() {
    console.log("Connecting to blockchain, loading token balances...");
    console.log('');

    const admin: Signer = (await hre.ethers.getSigners())[0];

    const mockTokens = await getAllMockedTokens();
    const allTokenAddresses = getAllTokenAddresses(mockTokens);
    await upgradeAssetClass(
        allTokenAddresses,
        admin
    );
}



main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });