import { HRE } from './misc-utils';
import { HardhatRuntimeEnvironment } from 'hardhat/types';


export const usingTenderly = () => 
    HRE && 
        ((HRE as HardhatRuntimeEnvironment).network.name.includes('tenderly') 
            || process.env.TENDERLY === 'true');