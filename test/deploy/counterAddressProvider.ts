import { HardhatRuntimeEnvironment } from "hardhat/types";
import { BigNumber, Contract } from "ethers";
import { TokenContractName } from '../../helpers/types';
import { getCounter, getCounterAddressesProvider, getCounterCollateralManager, getPrestareOracle } from "../../helpers/contracts-helpers";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { deployOnMainnet } from "../../scripts/deploy/deployOnMainnetFork";
import { getCounterAssetInfo, getVariableDebtTokenContract, getTokenContract, getPTokenContract } from '../../helpers/contracts-getter';
import { expect } from "chai";
import { Counter, CounterAddressesProvider, CounterCollateralManager, CounterConfigurator, PrestareOracle, PriceOracle } from "../../typechain-types";
import { Mainnet } from "../../markets/mainnet";
import { DataTypes } from "../../typechain-types/contracts/interfaces/ICounter";
import { oneEther, oneRay } from "../../helpers/constants";
import { getCounterConfigurator } from "../../helpers/contracts-helpers";
const hre: HardhatRuntimeEnvironment = require('hardhat');

describe("counter AddressProvider Config", function() {
    var counter: Counter;
    var admin: SignerWithAddress;
    var counterAddressesProvider: CounterAddressesProvider;
    var counterConfigurator : CounterConfigurator;
    var counterCollateralManager: CounterCollateralManager;
    var priceOracle : PrestareOracle;
    before(async () => {
        await deployOnMainnet();
        admin = (await hre.ethers.getSigners())[0];
        counter = await getCounter(admin);
        counterAddressesProvider = await getCounterAddressesProvider();
        counterConfigurator = await getCounterConfigurator();
        counterCollateralManager = await getCounterCollateralManager();
        priceOracle = await getPrestareOracle();
    })

    it('check if counter set correct',async () => {
        let counter_registry = await counterAddressesProvider.getCounter();
        expect(counter_registry).to.eq(counter.address);
    });

    it('check if CounterConfigurator set correct',async () => {
        let CounterConfigurator_registry = await counterAddressesProvider.getCounterConfigurator();
        expect(CounterConfigurator_registry).to.eq(counterConfigurator.address);
    });

    it('check if CounterCollateralManager set correct',async () => {
        let counterCollateralManagerr_registry = await counterAddressesProvider.getCounterCollateralManager();
        expect(counterCollateralManagerr_registry).to.eq(counterCollateralManager.address);
    });

    it('check if pool admin set correct',async () => {
        let poolAdmin_registry = await counterAddressesProvider.getPoolAdmin();
        expect(poolAdmin_registry).to.eq(admin.address);
    });

    it('check if pool EmergencyAdmin set correct',async () => {
        let poolEmergencyAdmin_registry = await counterAddressesProvider.getEmergencyAdmin();
        expect(poolEmergencyAdmin_registry).to.eq(admin.address);
    });

    it('check if pool priceOracle set correct',async () => {
        let priceOracle_registry = await counterAddressesProvider.getPriceOracle();
        expect(priceOracle_registry).to.eq(priceOracle.address);
    });
})