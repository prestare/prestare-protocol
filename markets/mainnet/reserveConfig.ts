import { ContractName, IPlatformInterestRateStrategyParams } from '../../helpers/types';
import { rateStrategyStableOne, rateStrategyStableTwo, rateStrategyWETH, rateStrategyAtoken} from './rateStrategies';
import { IReserveParams } from '../../helpers/types';
import { oneRay } from '../../helpers/constants';

export const strategyBUSD: IReserveParams = {
    strategy: rateStrategyStableOne,
    baseLTVAsCollateral: '8000',
    liquidationThreshold: '8500',
    liquidationBonus: '10500',
    borrowingEnabled: true,
    reserveDecimals: '18',
    pToken: ContractName.PToken,
    reserveFactor: '1000',
  };
export const strategyUSDC: IReserveParams = {
    strategy: rateStrategyStableOne,
    baseLTVAsCollateral: '8000',
    liquidationThreshold: '8500',
    liquidationBonus: '10500',
    borrowingEnabled: true,
    reserveDecimals: '6',
    pToken: ContractName.PToken,
    reserveFactor: '1000',
  };
  export const strategyUSDT: IReserveParams = {
    strategy: rateStrategyStableOne,
    baseLTVAsCollateral: '8000',
    liquidationThreshold: '8500',
    liquidationBonus: '10500',
    borrowingEnabled: true,
    reserveDecimals: '6',
    pToken: ContractName.PToken,
    reserveFactor: '1000',
  };
export const strategyDAI: IReserveParams = {
    strategy: rateStrategyStableTwo,
    baseLTVAsCollateral: '7500',
    liquidationThreshold: '8000',
    liquidationBonus: '10500',
    borrowingEnabled: true,
    reserveDecimals: '18',
    pToken: ContractName.PToken,
    reserveFactor: '1000',
  };

export const strategyWETH: IReserveParams = {
    strategy: rateStrategyWETH,
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
