import { ethers, providers } from "ethers";

const url = 'http://120.53.224.174:8545';
// const url = 'http://35.77.194.76:8546';

export function getProvider(): providers.JsonRpcProvider {
    return new ethers.providers.JsonRpcProvider(url);
}
async function main() {
    console.log("Connecting to blockchain, loading token balances...");
    console.log('');
    const PRIVATE_KEY = process.env.PRIVATE_KEY;
    const provider = new ethers.providers.JsonRpcProvider(url);
    let chainId = (await provider.getNetwork()).chainId;
    let blockNumber = await provider.getBlockNumber();
    console.log(blockNumber);
    console.log(chainId);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });