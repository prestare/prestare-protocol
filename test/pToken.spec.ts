import { makeSuite, TestEnv } from './helper/make-suit';
import { APPROVAL_AMOUNT_COUNTER } from '../utils/constants';
import { convertToCurrencyDecimals } from '../utils/contracts-helpers';
import { expect } from 'chai';


makeSuite('PToken: Transfer', (test: TestEnv) => {
    it('User 0 deposits 1000 DAI, transfers to user 1', async () => {

        const { users, counter, dai, pDai } = test;

        await dai.connect(users[0].signer).mint(await convertToCurrencyDecimals(dai.address, '1000'));
        await dai.connect(users[0].signer).approve(counter.address, APPROVAL_AMOUNT_COUNTER);

        //user 1 deposits 1000 DAI
        const amountDAItoDeposit = await convertToCurrencyDecimals(dai.address, '1000');

        await counter.connect(users[0].signer).deposit(dai.address, amountDAItoDeposit, users[0].address);
        await pDai.connect(users[0].signer).transfer(users[1].address, amountDAItoDeposit);

        const name = await pDai.name();
        expect(name).to.be.equal('Prestare DAI');

        const fromBalance = await pDai.balanceOf(users[0].address);
        const toBalance = await pDai.balanceOf(users[1].address);

        expect(fromBalance.toString()).to.be.equal('0', "Error");
        expect(toBalance.toString()).to.be.equal(amountDAItoDeposit.toString(), "Error");
    })
}) 
