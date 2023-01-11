import { task } from 'hardhat/config';
import { deployAllMockTokens } from '../../helpers/contracts_deployments';

task('mvp:deploy-mock-tokens', 'Deploy mock tokens for mvp enviroment')
    .addFlag('verify', 'Verify contracts at Etherscan')
    .setAction(async ({ verify }, localBRE) => {
        await localBRE.run('set-DRE');
        await deployAllMockTokens(verify);
    })