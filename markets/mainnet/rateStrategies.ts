import { BigNumber } from 'ethers';
import { oneRay } from '../../helpers/constants';
import { IInterestRateStrategyParams, IPlatformInterestRateStrategyParams } from '../../helpers/types';
// BUSD USDT USDC 
export const rateStrategyStableOne: IInterestRateStrategyParams = {
    name: "rateStrategyStableOne",
    optimalUtilizationRate: BigNumber.from(0.8 * 100).mul(oneRay).div(100).toString(),
    baseVariableBorrowRate: BigNumber.from(0 * 100).mul(oneRay).div(100).toString(),
    variableRateSlope1: BigNumber.from(0.04 * 100).mul(oneRay).div(100).toString(),
    variableRateSlope2: BigNumber.from(1 * 100).mul(oneRay).div(100).toString(),
};

// DAI
export const rateStrategyStableTwo: IInterestRateStrategyParams = {
    name: "rateStrategyStableTwo",
    optimalUtilizationRate: BigNumber.from(0.8 * 100).mul(oneRay).div(100).toString(),
    baseVariableBorrowRate: BigNumber.from(0 * 100).mul(oneRay).div(100).toString(),
    variableRateSlope1: BigNumber.from(0.04 * 100).mul(oneRay).div(100).toString(),
    variableRateSlope2: BigNumber.from(0.75 * 100).mul(oneRay).div(100).toString(),
}

// WETH
export const rateStrategyWETH: IInterestRateStrategyParams = {
    name: "rateStrategyWETH",
    optimalUtilizationRate: BigNumber.from(0.65 * 100).mul(oneRay).div(100).toString(),
    baseVariableBorrowRate: BigNumber.from(0 * 100).mul(oneRay).div(100).toString(),
    variableRateSlope1: BigNumber.from(0.08 * 100).mul(oneRay).div(100).toString(),
    variableRateSlope2: BigNumber.from(1 * 100).mul(oneRay).div(100).toString(),
}

export const rateStrategyAtoken: IPlatformInterestRateStrategyParams = {
    name: "aTokenrateStrategy",
    opSupplyIndex: oneRay.toString(),
    opBorrowIndex: oneRay.toString(),
    poolSupplyIndex: oneRay.toString(),
    poolBorrowIndex: oneRay.toString(),
}