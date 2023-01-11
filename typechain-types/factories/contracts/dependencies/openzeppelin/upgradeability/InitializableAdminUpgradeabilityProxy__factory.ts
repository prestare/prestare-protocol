/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */
import { Signer, utils, Contract, ContractFactory, Overrides } from "ethers";
import type { Provider, TransactionRequest } from "@ethersproject/providers";
import type { PromiseOrValue } from "../../../../../common";
import type {
  InitializableAdminUpgradeabilityProxy,
  InitializableAdminUpgradeabilityProxyInterface,
} from "../../../../../contracts/dependencies/openzeppelin/upgradeability/InitializableAdminUpgradeabilityProxy";

const _abi = [
  {
    anonymous: false,
    inputs: [
      {
        indexed: false,
        internalType: "address",
        name: "previousAdmin",
        type: "address",
      },
      {
        indexed: false,
        internalType: "address",
        name: "newAdmin",
        type: "address",
      },
    ],
    name: "AdminChanged",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "implementation",
        type: "address",
      },
    ],
    name: "Upgraded",
    type: "event",
  },
  {
    stateMutability: "payable",
    type: "fallback",
  },
  {
    inputs: [],
    name: "admin",
    outputs: [
      {
        internalType: "address",
        name: "",
        type: "address",
      },
    ],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "newAdmin",
        type: "address",
      },
    ],
    name: "changeAdmin",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [],
    name: "implementation",
    outputs: [
      {
        internalType: "address",
        name: "",
        type: "address",
      },
    ],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "logic",
        type: "address",
      },
      {
        internalType: "address",
        name: "admin",
        type: "address",
      },
      {
        internalType: "bytes",
        name: "data",
        type: "bytes",
      },
    ],
    name: "initialize",
    outputs: [],
    stateMutability: "payable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "_logic",
        type: "address",
      },
      {
        internalType: "bytes",
        name: "_data",
        type: "bytes",
      },
    ],
    name: "initialize",
    outputs: [],
    stateMutability: "payable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "newImplementation",
        type: "address",
      },
    ],
    name: "upgradeTo",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "newImplementation",
        type: "address",
      },
      {
        internalType: "bytes",
        name: "data",
        type: "bytes",
      },
    ],
    name: "upgradeToAndCall",
    outputs: [],
    stateMutability: "payable",
    type: "function",
  },
];

const _bytecode =
  "0x608060405234801561001057600080fd5b50610905806100206000396000f3fe6080604052600436106100705760003560e01c80638f2839701161004e5780638f2839701461015e578063cf7a1d7714610191578063d1f5789414610250578063f851a4401461030657610070565b80633659cfe61461007a5780634f1ef286146100ad5780635c60da1b1461012d575b61007861031b565b005b34801561008657600080fd5b506100786004803603602081101561009d57600080fd5b50356001600160a01b0316610335565b610078600480360360408110156100c357600080fd5b6001600160a01b0382351691908101906040810160208201356401000000008111156100ee57600080fd5b82018360208201111561010057600080fd5b8035906020019184600183028401116401000000008311171561012257600080fd5b50909250905061036f565b34801561013957600080fd5b5061014261041c565b604080516001600160a01b039092168252519081900360200190f35b34801561016a57600080fd5b506100786004803603602081101561018157600080fd5b50356001600160a01b0316610459565b610078600480360360608110156101a757600080fd5b6001600160a01b0382358116926020810135909116918101906060810160408201356401000000008111156101db57600080fd5b8201836020820111156101ed57600080fd5b8035906020019184600183028401116401000000008311171561020f57600080fd5b91908080601f016020809104026020016040519081016040528093929190818152602001838380828437600092019190915250929550610513945050505050565b6100786004803603604081101561026657600080fd5b6001600160a01b03823516919081019060408101602082013564010000000081111561029157600080fd5b8201836020820111156102a357600080fd5b803590602001918460018302840111640100000000831117156102c557600080fd5b91908080601f016020809104026020016040519081016040528093929190818152602001838380828437600092019190915250929550610543945050505050565b34801561031257600080fd5b50610142610623565b61032361064e565b61033361032e610656565b61067b565b565b61033d61069f565b6001600160a01b0316336001600160a01b031614156103645761035f816106c4565b61036c565b61036c61031b565b50565b61037761069f565b6001600160a01b0316336001600160a01b0316141561040f57610399836106c4565b6000836001600160a01b031683836040518083838082843760405192019450600093509091505080830381855af49150503d80600081146103f6576040519150601f19603f3d011682016040523d82523d6000602084013e6103fb565b606091505b505090508061040957600080fd5b50610417565b61041761031b565b505050565b600061042661069f565b6001600160a01b0316336001600160a01b0316141561044e57610447610656565b9050610456565b61045661031b565b90565b61046161069f565b6001600160a01b0316336001600160a01b03161415610364576001600160a01b0381166104bf5760405162461bcd60e51b815260040180806020018281038252603681526020018061085f6036913960400191505060405180910390fd5b7f7e644d79422f17c01e4894b5f4f588d331ebfa28653d42ae832dc59e38c9798f6104e861069f565b604080516001600160a01b03928316815291841660208301528051918290030190a161035f81610704565b600061051d610656565b6001600160a01b03161461053057600080fd5b61053a8382610543565b61041782610704565b600061054d610656565b6001600160a01b03161461056057600080fd5b61056982610728565b80511561061f576000826001600160a01b0316826040518082805190602001908083835b602083106105ac5780518252601f19909201916020918201910161058d565b6001836020036101000a038019825116818451168082178552505050505050905001915050600060405180830381855af49150503d806000811461060c576040519150601f19603f3d011682016040523d82523d6000602084013e610611565b606091505b505090508061041757600080fd5b5050565b600061062d61069f565b6001600160a01b0316336001600160a01b0316141561044e5761044761069f565b610333610790565b7f360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc5490565b3660008037600080366000845af43d6000803e80801561069a573d6000f35b3d6000fd5b7fb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d61035490565b6106cd81610728565b6040516001600160a01b038216907fbc7cd75a20ee27fd9adebab32041f755214dbc6bffa90cc0225b39da2e5c2d3b90600090a250565b7fb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d610355565b610731816107f0565b61076c5760405162461bcd60e51b815260040180806020018281038252603b815260200180610895603b913960400191505060405180910390fd5b7f360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc55565b61079861069f565b6001600160a01b0316336001600160a01b031614156107e85760405162461bcd60e51b815260040180806020018281038252603281526020018061082d6032913960400191505060405180910390fd5b610333610333565b6000813f7fc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a47081811480159061082457508115155b94935050505056fe43616e6e6f742063616c6c2066616c6c6261636b2066756e6374696f6e2066726f6d207468652070726f78792061646d696e43616e6e6f74206368616e6765207468652061646d696e206f6620612070726f787920746f20746865207a65726f206164647265737343616e6e6f742073657420612070726f787920696d706c656d656e746174696f6e20746f2061206e6f6e2d636f6e74726163742061646472657373a2646970667358221220fb73a1ecc109c1c80e75945724c84ec27bb4a0713b4331beaa4a35f64f69bf8564736f6c634300060c0033";

type InitializableAdminUpgradeabilityProxyConstructorParams =
  | [signer?: Signer]
  | ConstructorParameters<typeof ContractFactory>;

const isSuperArgs = (
  xs: InitializableAdminUpgradeabilityProxyConstructorParams
): xs is ConstructorParameters<typeof ContractFactory> => xs.length > 1;

export class InitializableAdminUpgradeabilityProxy__factory extends ContractFactory {
  constructor(...args: InitializableAdminUpgradeabilityProxyConstructorParams) {
    if (isSuperArgs(args)) {
      super(...args);
    } else {
      super(_abi, _bytecode, args[0]);
    }
  }

  override deploy(
    overrides?: Overrides & { from?: PromiseOrValue<string> }
  ): Promise<InitializableAdminUpgradeabilityProxy> {
    return super.deploy(
      overrides || {}
    ) as Promise<InitializableAdminUpgradeabilityProxy>;
  }
  override getDeployTransaction(
    overrides?: Overrides & { from?: PromiseOrValue<string> }
  ): TransactionRequest {
    return super.getDeployTransaction(overrides || {});
  }
  override attach(address: string): InitializableAdminUpgradeabilityProxy {
    return super.attach(address) as InitializableAdminUpgradeabilityProxy;
  }
  override connect(
    signer: Signer
  ): InitializableAdminUpgradeabilityProxy__factory {
    return super.connect(
      signer
    ) as InitializableAdminUpgradeabilityProxy__factory;
  }

  static readonly bytecode = _bytecode;
  static readonly abi = _abi;
  static createInterface(): InitializableAdminUpgradeabilityProxyInterface {
    return new utils.Interface(
      _abi
    ) as InitializableAdminUpgradeabilityProxyInterface;
  }
  static connect(
    address: string,
    signerOrProvider: Signer | Provider
  ): InitializableAdminUpgradeabilityProxy {
    return new Contract(
      address,
      _abi,
      signerOrProvider
    ) as InitializableAdminUpgradeabilityProxy;
  }
}
