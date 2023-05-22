import { ContractName, IPlatformInterestRateStrategyParams } from '../../helpers/types';
import { rateStrategyAClass, rateStrategyBClass, rateStrategyCClass, rateStrategyAtoken} from './rateStrategies';
import { IReserveParams } from '../../helpers/types';
import { oneRay } from '../../helpers/constants';

export const strategyDAI_B: IReserveParams = {
  strategy: rateStrategyBClass,
  baseLTVAsCollateral: '7500',
  liquidationThreshold: '8000',
  liquidationBonus: '10500',
  borrowingEnabled: true,
  reserveDecimals: '18',
  pToken: ContractName.PToken,
  reserveFactor: '1000',
};

export const strategyDAI_C: IReserveParams = {
  strategy: rateStrategyCClass,
  baseLTVAsCollateral: '7500',
  liquidationThreshold: '8000',
  liquidationBonus: '10500',
  borrowingEnabled: true,
  reserveDecimals: '18',
  pToken: ContractName.PToken,
  reserveFactor: '1000',
};

// export const strategyBUSD_A: IReserveParams = {
//     strategy: rateStrategyStableOne,
//     baseLTVAsCollateral: '8000',
//     liquidationThreshold: '8500',
//     liquidationBonus: '10500',
//     borrowingEnabled: true,
//     reserveDecimals: '18',
//     pToken: ContractName.PToken,
//     reserveFactor: '1000',
//   };
export const strategyUSDC_A: IReserveParams = {
    strategy: rateStrategyAClass,
    baseLTVAsCollateral: '8000',
    liquidationThreshold: '8500',
    liquidationBonus: '10500',
    borrowingEnabled: true,
    reserveDecimals: '6',
    pToken: ContractName.PToken,
    reserveFactor: '1000',
};

export const strategyUSDC_B: IReserveParams = {
  strategy: rateStrategyBClass,
  baseLTVAsCollateral: '8000',
  liquidationThreshold: '8500',
  liquidationBonus: '10500',
  borrowingEnabled: true,
  reserveDecimals: '6',
  pToken: ContractName.PToken,
  reserveFactor: '1000',
};

export const strategyUSDC_C: IReserveParams = {
  strategy: rateStrategyCClass,
  baseLTVAsCollateral: '8000',
  liquidationThreshold: '8500',
  liquidationBonus: '10500',
  borrowingEnabled: true,
  reserveDecimals: '6',
  pToken: ContractName.PToken,
  reserveFactor: '1000',
};

export const strategyUSDT_A: IReserveParams = {
  strategy: rateStrategyAClass,
  baseLTVAsCollateral: '8000',
  liquidationThreshold: '8500',
  liquidationBonus: '10500',
  borrowingEnabled: true,
  reserveDecimals: '6',
  pToken: ContractName.PToken,
  reserveFactor: '1000',
};
export const strategyUSDT_B: IReserveParams = {
    strategy: rateStrategyBClass,
    baseLTVAsCollateral: '8000',
    liquidationThreshold: '8500',
    liquidationBonus: '10500',
    borrowingEnabled: true,
    reserveDecimals: '6',
    pToken: ContractName.PToken,
    reserveFactor: '1000',
};
export const strategyUSDT_C: IReserveParams = {
  strategy: rateStrategyCClass,
  baseLTVAsCollateral: '8000',
  liquidationThreshold: '8500',
  liquidationBonus: '10500',
  borrowingEnabled: true,
  reserveDecimals: '6',
  pToken: ContractName.PToken,
  reserveFactor: '1000',
};

export const strategyWETH_B: IReserveParams = {
    strategy: rateStrategyBClass,
    baseLTVAsCollateral: '8000',
    liquidationThreshold: '8250',
    liquidationBonus: '10500',
    borrowingEnabled: true,
    reserveDecimals: '18',
    pToken: ContractName.PToken,
    reserveFactor: '1000',
};

export const strategyWETH_C: IReserveParams = {
  strategy: rateStrategyCClass,
  baseLTVAsCollateral: '8000',
  liquidationThreshold: '8250',
  liquidationBonus: '10500',
  borrowingEnabled: true,
  reserveDecimals: '18',
  pToken: ContractName.PToken,
  reserveFactor: '1000',
};

export const aTokenStrategy : IReserveParams = {
  strategy: rateStrategyAtoken,
  baseLTVAsCollateral: '8000',
  liquidationThreshold: '8250',
  liquidationBonus: '10500',
  borrowingEnabled: true,
  reserveDecimals: '18',
  pToken: ContractName.PToken,
  reserveFactor: '1000',
}
