import { IReserveParams, eContractid} from '../../utils/common';
import { 
    rateStrategyThree, 
    rateStrategyPRS,
    rateStrategyWETH,
    rateStrategyStableTwo
} from './rateStrategies';


export const strategyUSDC: IReserveParams = {
    strategy: rateStrategyThree,
    baseLTVAsCollateral: '8000',
    liquidationThreshold: '8500',
    liquidationBonus: '10500',
    borrowingEnabled: true,
    stableBorrowRateEnabled: true,
    reserveDecimals: '6',
    crtDecimals: '6',
    pTokenImpl: eContractid.PToken,
    reserveFactor: '1000'
};

export const strategyUSDT: IReserveParams = {
    strategy: rateStrategyThree,
    baseLTVAsCollateral: '8000',
    liquidationThreshold: '8500',
    liquidationBonus: '10500',
    borrowingEnabled: true,
    stableBorrowRateEnabled: true,
    reserveDecimals: '6',
    crtDecimals: '6',
    pTokenImpl: eContractid.PToken,
    reserveFactor: '1000'
};

export const strategyPRS: IReserveParams = {
    strategy: rateStrategyPRS,
    baseLTVAsCollateral: '5000',
    liquidationThreshold: '6500',
    liquidationBonus: '11000',
    borrowingEnabled: false,
    stableBorrowRateEnabled: false,
    reserveDecimals: '18',
    crtDecimals: '6',
    pTokenImpl: eContractid.PToken,
    reserveFactor: '0'
};

export const strategyWETH: IReserveParams = {
    strategy: rateStrategyWETH,
    baseLTVAsCollateral: '8000',
    liquidationThreshold: '8250',
    liquidationBonus: '10500',
    borrowingEnabled: true,
    stableBorrowRateEnabled: true,
    reserveDecimals: '18',
    crtDecimals: '6',
    pTokenImpl: eContractid.PToken,
    reserveFactor: '1000'
};


export const strategyDAI: IReserveParams = {
    strategy: rateStrategyStableTwo,
    baseLTVAsCollateral: '7500',
    liquidationThreshold: '8000',
    liquidationBonus: '10500',
    borrowingEnabled: true,
    stableBorrowRateEnabled: true,
    reserveDecimals: '18',
    crtDecimals: '6',
    pTokenImpl: eContractid.PToken,
    reserveFactor: '1000'
};