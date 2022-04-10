import { task } from 'hardhat/config';
import { HRE, setHRE } from '../utils/misc-utils';

task(`set-HRE`, `Inits the HRE, to have access to all the plugins' objects`).setAction(
    async (_, _HRE) => {
        if (HRE) {
            return;
        }
        setHRE(_HRE);
        return _HRE;
    }
);
