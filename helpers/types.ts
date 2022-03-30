import BigNumber from 'bignumber.js';

export type eNetwork = eEthereumNetwork | ePolygonNetwork | eXDaiNetwork | eAvalancheNetwork;

// 各个网络及其内部有的测试链
export enum eEthereumNetwork {
    buidlerevm = 'buidlerevm',
    kovan = 'kovan',
    ropsten = 'ropsten',
    main = 'main',
    coverage = 'coverage',
    hardhat = 'hardhat',
    tenderly = 'tenderly',
}

export enum ePolygonNetwork {
    matic = 'matic',
    mumbai = 'mumbai',
}
  
export enum eXDaiNetwork {
    xdai = 'xdai',
}
  
export enum eAvalancheNetwork {
    avalanche = 'avalanche',
    fuji = 'fuji',
}

// 定义tEthereumAddress 类型为string
export type tEthereumAddress = string;