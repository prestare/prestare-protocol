import { Signer } from 'ethers';
import { getCrt } from '../helpers/contracts-getter';
import { getProvider } from './connectUrl';

async function mintCrt() {
    await getCrt();
}

async function main() {

    await mintCrt();
    
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });