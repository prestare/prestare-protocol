import { ethers, Signer, BigNumber } from 'ethers';
import { getCrtAddress } from '../helpers/contracts-getter';
import { getProvider } from '../test/connectUrl';
import { HardhatRuntimeEnvironment } from "hardhat/types";

const hre: HardhatRuntimeEnvironment = require('hardhat');
const url = "http://120.53.224.174:8545";

async function mintCrt(amount: string) {
    const provider = new ethers.providers.JsonRpcProvider(url);

    const pk: string = process.env.ACCOUNT_SECRET_DEPLOY!;

    let [signer,] = await hre.ethers.getSigners();
    let crtInfo = await getCrtAddress();
    const artifact = await hre.artifacts.readArtifact("MockCRT")
    const CrtContract = new ethers.Contract(crtInfo.address, artifact.abi, signer);
    console.log("Contract address is: ", CrtContract.address);
    console.log(await CrtContract.name());
    const decimals = await CrtContract.decimals();
    console.log(decimals);
    const mintAmount = ethers.utils.parseUnits(amount, decimals);
    await CrtContract.connect(signer).mint(signer.address, mintAmount);
    const balanceT0: BigNumber = await CrtContract.balanceOf(signer.address);
    const wei = ethers.utils.parseEther("1");
    console.log("Account Balance is:", balanceT0.div(wei).toString());
    console.log("mint crt success.");

}

async function main() {
    let amount = '10';
    await mintCrt(amount);
    
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });