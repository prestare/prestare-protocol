import BigNumber from 'bignumber.js';

export const APPROVAL_AMOUNT_COUNTER = '1000000000000000000000000000';
export const oneRay = new BigNumber(Math.pow(10, 27));
export const ZERO_ADDRESS = '0x0000000000000000000000000000000000000000';

export const oneEther = new BigNumber(Math.pow(10, 18));
export const MOCK_CHAINLINK_AGGREGATORS_PRICES = {
    DAI: oneEther.multipliedBy('0.00369068412860').toFixed(),
    USDC: oneEther.multipliedBy('0.00367714136416').toFixed(),
    USDT: oneEther.multipliedBy('0.00369068412860').toFixed(),
    WETH: oneEther.toFixed(),
    USD: '5848466240000000',
};
