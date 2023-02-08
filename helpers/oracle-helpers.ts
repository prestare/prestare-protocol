import { Contract } from "ethers";
import { PriceOracle } from "../typechain-types";

export const setInitialAssetPricesInOracle = async (
    prices: { [key: string]: string },
    assetsAddresses: { [key: string]: string },
    priceOracleInstance: Contract
  ) => {
    for (const [assetSymbol, price] of Object.entries(prices) as [string, string][]) {
      const assetAddressIndex = Object.keys(assetsAddresses).findIndex(
        (value) => value === assetSymbol
      );
      const [, assetAddress] = (Object.entries(assetsAddresses) as [string, string][])[
        assetAddressIndex
      ];
      await priceOracleInstance.setAssetPrice(assetAddress, price);
    }
  };