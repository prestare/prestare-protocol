const hre = require("hardhat");
export const getAAVELendingPool = async (address: string) => {
    return await hre.ethers.getContractAt("ILendingPool",address);
}