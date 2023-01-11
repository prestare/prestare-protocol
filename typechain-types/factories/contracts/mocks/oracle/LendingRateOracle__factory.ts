/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */
import { Signer, utils, Contract, ContractFactory, Overrides } from "ethers";
import type { Provider, TransactionRequest } from "@ethersproject/providers";
import type { PromiseOrValue } from "../../../../common";
import type {
  LendingRateOracle,
  LendingRateOracleInterface,
} from "../../../../contracts/mocks/oracle/LendingRateOracle";

const _abi = [
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "previousOwner",
        type: "address",
      },
      {
        indexed: true,
        internalType: "address",
        name: "newOwner",
        type: "address",
      },
    ],
    name: "OwnershipTransferred",
    type: "event",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "_asset",
        type: "address",
      },
    ],
    name: "getMarketBorrowRate",
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
  {
    inputs: [
      {
        internalType: "address",
        name: "_asset",
        type: "address",
      },
    ],
    name: "getMarketLiquidityRate",
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
  {
    inputs: [],
    name: "owner",
    outputs: [
      {
        internalType: "address",
        name: "",
        type: "address",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "renounceOwnership",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "_asset",
        type: "address",
      },
      {
        internalType: "uint256",
        name: "_rate",
        type: "uint256",
      },
    ],
    name: "setMarketBorrowRate",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "_asset",
        type: "address",
      },
      {
        internalType: "uint256",
        name: "_rate",
        type: "uint256",
      },
    ],
    name: "setMarketLiquidityRate",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "newOwner",
        type: "address",
      },
    ],
    name: "transferOwnership",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
];

const _bytecode =
  "0x608060405234801561001057600080fd5b50600061001b61006a565b600080546001600160a01b0319166001600160a01b0383169081178255604051929350917f8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e0908290a35061006e565b3390565b6104d38061007d6000396000f3fe608060405234801561001057600080fd5b506004361061007d5760003560e01c80639f86a0ee1161005b5780639f86a0ee146100dc578063bb85c0bb14610108578063f2fde38b14610140578063fbe5ba1e146101665761007d565b8063715018a61461008257806372eb293d1461008c5780638da5cb5b146100b8575b600080fd5b61008a61018c565b005b61008a600480360360408110156100a257600080fd5b506001600160a01b03813516906020013561022e565b6100c06102a2565b604080516001600160a01b039092168252519081900360200190f35b61008a600480360360408110156100f257600080fd5b506001600160a01b0381351690602001356102b1565b61012e6004803603602081101561011e57600080fd5b50356001600160a01b0316610325565b60408051918252519081900360200190f35b61008a6004803603602081101561015657600080fd5b50356001600160a01b0316610340565b61012e6004803603602081101561017c57600080fd5b50356001600160a01b0316610438565b610194610453565b6000546001600160a01b039081169116146101e4576040805162461bcd60e51b8152602060048201819052602482015260008051602061047e833981519152604482015290519081900360640190fd5b600080546040516001600160a01b03909116907f8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e0908390a3600080546001600160a01b0319169055565b610236610453565b6000546001600160a01b03908116911614610286576040805162461bcd60e51b8152602060048201819052602482015260008051602061047e833981519152604482015290519081900360640190fd5b6001600160a01b03909116600090815260016020526040902055565b6000546001600160a01b031690565b6102b9610453565b6000546001600160a01b03908116911614610309576040805162461bcd60e51b8152602060048201819052602482015260008051602061047e833981519152604482015290519081900360640190fd5b6001600160a01b03909116600090815260026020526040902055565b6001600160a01b031660009081526001602052604090205490565b610348610453565b6000546001600160a01b03908116911614610398576040805162461bcd60e51b8152602060048201819052602482015260008051602061047e833981519152604482015290519081900360640190fd5b6001600160a01b0381166103dd5760405162461bcd60e51b81526004018080602001828103825260268152602001806104586026913960400191505060405180910390fd5b600080546040516001600160a01b03808516939216917f8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e091a3600080546001600160a01b0319166001600160a01b0392909216919091179055565b6001600160a01b031660009081526002602052604090205490565b339056fe4f776e61626c653a206e6577206f776e657220697320746865207a65726f20616464726573734f776e61626c653a2063616c6c6572206973206e6f7420746865206f776e6572a26469706673582212207e5b37103b24ab3832e3274a71a9523212bcebb430042205425796c1022c6b1964736f6c634300060c0033";

type LendingRateOracleConstructorParams =
  | [signer?: Signer]
  | ConstructorParameters<typeof ContractFactory>;

const isSuperArgs = (
  xs: LendingRateOracleConstructorParams
): xs is ConstructorParameters<typeof ContractFactory> => xs.length > 1;

export class LendingRateOracle__factory extends ContractFactory {
  constructor(...args: LendingRateOracleConstructorParams) {
    if (isSuperArgs(args)) {
      super(...args);
    } else {
      super(_abi, _bytecode, args[0]);
    }
  }

  override deploy(
    overrides?: Overrides & { from?: PromiseOrValue<string> }
  ): Promise<LendingRateOracle> {
    return super.deploy(overrides || {}) as Promise<LendingRateOracle>;
  }
  override getDeployTransaction(
    overrides?: Overrides & { from?: PromiseOrValue<string> }
  ): TransactionRequest {
    return super.getDeployTransaction(overrides || {});
  }
  override attach(address: string): LendingRateOracle {
    return super.attach(address) as LendingRateOracle;
  }
  override connect(signer: Signer): LendingRateOracle__factory {
    return super.connect(signer) as LendingRateOracle__factory;
  }

  static readonly bytecode = _bytecode;
  static readonly abi = _abi;
  static createInterface(): LendingRateOracleInterface {
    return new utils.Interface(_abi) as LendingRateOracleInterface;
  }
  static connect(
    address: string,
    signerOrProvider: Signer | Provider
  ): LendingRateOracle {
    return new Contract(address, _abi, signerOrProvider) as LendingRateOracle;
  }
}
