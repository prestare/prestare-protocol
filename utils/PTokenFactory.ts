import {Signer, BigNumberish} from "ethers";
import { Provider, TransactionRequest } from "@ethersproject/providers";
import { Contract, ContractFactory, Overrides } from "@ethersproject/contracts";

import { PToken } from "./PToken";

export class PTokenFactory extends ContractFactory {
    constructor(signer?: signer) {
        super(_abi, _bytecode, signer);
    }

    deploy(
        _addressesProvider: string,
        _underlyingAsset: string,
        _underlyingAssetDecimals: BigNumberish,
        _name: string,
        _symbol: string,
        overrides?: Overrides
    ): Promise<PToken> {
        return super.deploy(
            _addressesProvider,
            _underlyingAsset,
            _underlyingAssetDecimals,
            _name,
            _symbol,
            overrides || {}
        ) as Promise<PToken>;
    }

    getDeployTransaction(
        _addressesProvider: string,
        _underlyingAsset: string,
        _underlyingAssetDecimals: BigNumberish,
        _name: string,
        _symbol: string,
        overrides?: Overrides
    ): TransactionRequest {
        return super.getDeployTransaction(
            _addressesProvider,
            _underlyingAsset,
            _underlyingAssetDecimals,
            _name,
            _symbol,
            overrides || {}
        );
    }

    attach(address: string): PToken {
        return super.attach(address) as PToken;
    }

    connect(signer: Signer): PTokenFactory {
        return super.connect(signer) as PTokenFactory;
    }

    static connect(address: string, signerOrProvider: Signer | Provider): PToken {
        return new Contract(address, _abi, signerOrProvider) as PToken;
    }

}

// 得到Ptoken的abi，需要先编译，但是pMATH还需要修改
const _abi = [
    
];

const _bytecode = "";