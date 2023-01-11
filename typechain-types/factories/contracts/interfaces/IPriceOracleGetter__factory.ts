/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */

import { Contract, Signer, utils } from "ethers";
import type { Provider } from "@ethersproject/providers";
import type {
  IPriceOracleGetter,
  IPriceOracleGetterInterface,
} from "../../../contracts/interfaces/IPriceOracleGetter";

const _abi = [
  {
    inputs: [
      {
        internalType: "address",
        name: "asset",
        type: "address",
      },
    ],
    name: "getAssetPrice",
    outputs: [
      {
        internalType: "uint256",
        name: "",
        type: "uint256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
];

export class IPriceOracleGetter__factory {
  static readonly abi = _abi;
  static createInterface(): IPriceOracleGetterInterface {
    return new utils.Interface(_abi) as IPriceOracleGetterInterface;
  }
  static connect(
    address: string,
    signerOrProvider: Signer | Provider
  ): IPriceOracleGetter {
    return new Contract(address, _abi, signerOrProvider) as IPriceOracleGetter;
  }
}
