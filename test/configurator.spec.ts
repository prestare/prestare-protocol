import { makeSuite, TestEnv } from "./helper/make-suit";
import { APPROVAL_AMOUNT_COUNTER, RAY } from "../utils/constants";
import { convertToCurrencyDecimals } from "../utils/contracts-helpers";
import { ProtocolErrors } from "../utils/common";

const { expect } = require('chai');

makeSuite('CounterConfigurator', (testEnv: TestEnv) => {
  const {
    CALLER_NOT_POOL_ADMIN,
    LPC_RESERVE_LIQUIDITY_NOT_0,
    RC_INVALID_RESERVE_FACTOR,
  } = ProtocolErrors;

  it('Deactivates the ETH reserve', async () => {
    const { configurator, weth, helpersContract } = testEnv;
    await configurator.deactivateReserve(weth.address);
    const { isActive } = await helpersContract.getReserveConfigurationData(weth.address);
    expect(isActive).to.be.equal(false);
  });

});
