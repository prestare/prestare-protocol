import { 
    PrestareCounters,
    iMultiCountersAssets,
    IReserveParams,
    PoolConfiguration,
    ICommonConfiguration,
    tEthereumAddress,
    eNetwork
} from './common';
import { HRE } from './misc-utils';
import { getParamPerPool, getParamPerNetwork } from './contracts-helpers';
import { PrestareConfig } from '../markets/prestare';
import { CommonsConfig } from '../markets/prestare/commons';;

export const getReservesConfigByPool = (counter: PrestareCounters): iMultiCountersAssets<IReserveParams> => 
    getParamPerPool<iMultiCountersAssets<IReserveParams>>(
        {
            [PrestareCounters.proto]: {
                ...PrestareConfig.ReservesConfig,
            }
        },
        counter
    )

export enum ConfigNames {
    Commons = 'Commons',
    Prestare = 'Prestare',
}
    
export const loadPoolConfig = (configName: ConfigNames): PoolConfiguration => {
    switch (configName) {
        case ConfigNames.Prestare:
            return PrestareConfig;
        case ConfigNames.Commons:
            return CommonsConfig;
        default:
            throw new Error(`Unsupported pool configuration: ${Object.values(ConfigNames)}`);
    }
};

export const getTreasuryAddress = async (
    config: ICommonConfiguration
): Promise<tEthereumAddress> => {
    const currentNetwork = process.env.MAINNET_FORK === 'true' ? 'main' : HRE.network.name;
    return getParamPerNetwork(config.ReserveFactorTreasuryAddress, <eNetwork>currentNetwork);
};

