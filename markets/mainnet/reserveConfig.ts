import { ContractName } from '../../helpers/types';
import { rateStrategyStableOne, rateStrategyStableTwo, rateStrategyWETH} from './rateStrategies';

export const strategyBUSD = {
    strategy: rateStrategyStableOne,
    baseLTVAsCollateral: '0',
    liquidationThreshold: '0',
    liquidationBonus: '0',
    borrowingEnabled: true,
    reserveDecimals: '18',
    pToken: ContractName.PToken,
    reserveFactor: '1000',
  };
export const strategyUSDC = {
    strategy: rateStrategyStableOne,
    baseLTVAsCollateral: '0',
    liquidationThreshold: '0',
    liquidationBonus: '0',
    borrowingEnabled: true,
    reserveDecimals: '18',
    pToken: ContractName.PToken,
    reserveFactor: '1000',
  };
  export const strategyUSDT = {
    strategy: rateStrategyStableOne,
    baseLTVAsCollateral: '0',
    liquidationThreshold: '0',
    liquidationBonus: '0',
    borrowingEnabled: true,
    reserveDecimals: '18',
    pToken: ContractName.PToken,
    reserveFactor: '1000',
  };
export const strategyDAI = {
    strategy: rateStrategyStableTwo,
    baseLTVAsCollateral: '7500',
    liquidationThreshold: '8000',
    liquidationBonus: '10500',
    borrowingEnabled: true,
    reserveDecimals: '18',
    pToken: ContractName.PToken,
    reserveFactor: '1000',
  };

export const strategyWETH = {
    strategy: rateStrategyWETH,
    baseLTVAsCollateral: '8000',
    liquidationThreshold: '8250',
    liquidationBonus: '10500',
    borrowingEnabled: true,
    stableBorrowRateEnabled: true,
    reserveDecimals: '18',
    pToken: ContractName.PToken,
    reserveFactor: '1000',
  };
  
