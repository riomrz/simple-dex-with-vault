require("dotenv").config();
const { expect } = require("chai");
const { BigNumber, constants } = require('ethers');
const { AddressZero, EtherSymbol } = constants;

// const {web3 } = require('@openzeppelin/test-helpers/src/setup');

require("@nomicfoundation/hardhat-chai-matchers");

// conversion taking into account 18 decimals
const fromWei = (x) => ethers.utils.formatEther(x.toString());
const toWei = (x) => ethers.utils.parseEther(x.toString());

// conversion taking into account 8 decimals
const fromWei8Dec = (x) => x / Math.pow(10, 8);
const toWei8Dec = (x) => x * Math.pow(10, 8);

// address dell'oracolo di Chainlink su Ethereum (utilizzo direttamente la chain principale forkandola con Hardhat)
const ETHUSD = process.env.ETHUSD_CHAINLINK_ADDRESS;


describe('Simple DEX', function (accounts) {

    it('system setup', async function () {
        [testOwner, other1, other2, other3] = await ethers.getSigners();

        const Token = await hre.ethers.getContractFactory("Token");
        token = await Token.deploy("myToken", "myT1", 1000000);
        expect(token.address).to.be.not.equal(AddressZero);
        expect(token.address).to.match(/0x[0-9a-fA-F]{40}/);

        const SimpleDex = await hre.ethers.getContractFactory("SimpleDEX");
        simpleDex = await SimpleDex.deploy(token.address, ETHUSD);
        expect(simpleDex.address).to.be.not.equal(AddressZero);
        expect(simpleDex.address).to.match((/0x[0-9a-fA-F]{40}/));

        const Oracle = await hre.ethers.getContractFactory("PriceConsumerV3");
        priceConsumerAddress = await simpleDex.ethUsdContract();
        pcContract = await Oracle.attach(priceConsumerAddress);
        console.log("priceConsumer @: " + priceConsumerAddress);

        const Treasury = await hre.ethers.getContractFactory("Treasury");
        treasury = await Treasury.deploy(simpleDex.address);
        expect(treasury.address).to.be.not.equal(AddressZero);
        expect(treasury.address).to.match((/0x[0-9a-fA-F]{40}/));
    });

    it("DEX receives Tokens and ETH from owner", async function () {
        lastPrice = await pcContract.getLatestPrice();
        console.log(fromWei8Dec(lastPrice));

        // tx = await token.connect(testOwner).transfer(simpleDex.address, toWei(10000));
        // tx = await testOwner.sendTransaction({ to: simpleDex.address, value: toWei(10) });
        // await simpleDex.getCLParameters();
        console.log("ETH/USD decimals: " + await simpleDex.ethPriceDecimals());

        await simpleDex.connect(testOwner).setTreasury(treasury.address);
        await token.connect(testOwner).setMinter(simpleDex.address);
    })

    it("users change ethers for tokens in simple DEX", async function () {
        tx = await simpleDex.connect(other1).buyToken({ value: toWei(1) })
        console.log("ETH/USD price: " + fromWei8Dec(await simpleDex.ethPrice()))
        tx = await simpleDex.connect(other2).buyToken({ value: toWei(1.5) })
        tx = await simpleDex.connect(other3).buyToken({ value: toWei(2) })
    })

    it("simple DEX parameters", async function () {
        console.log("Token balance in dex contract: " + fromWei(await token.balanceOf(simpleDex.address)))
        console.log("ether balance in dex contract: " + fromWei(await simpleDex.provider.getBalance(simpleDex.address)))

        console.log("other1 Token balance: " + fromWei(await token.balanceOf(other1.address)))
        console.log("other2 Token balance: " + fromWei(await token.balanceOf(other2.address)))
        console.log("other3 Token balance: " + fromWei(await token.balanceOf(other3.address)))
        console.log("ETH balance in Treasury contract: " + fromWei(await treasury.provider.getBalance(treasury.address)))

        console.log("Other1 ETH balance: " + fromWei(await other1.provider.getBalance(other1.address)))
        console.log("Other2 ETH balance: " + fromWei(await other2.provider.getBalance(other2.address)))
        console.log("Other3 ETH balance: " + fromWei(await other3.provider.getBalance(other3.address)))
    })

    it("users withdraw tokens for ethers in simple DEX", async function () {
        tx = await simpleDex.connect(other1).sellToken(toWei(1000))

        tx = await simpleDex.connect(other2).sellToken(toWei(800))

        tx = await simpleDex.connect(other3).sellToken(toWei(1200))
    })

    it("simple DEX parameters", async function () {
        console.log("Token balance in dex contract: " + fromWei(await token.balanceOf(simpleDex.address)))
        console.log("ether balance in dex contract: " + fromWei(await simpleDex.provider.getBalance(simpleDex.address)))

        console.log("other1 Token balance: " + fromWei(await token.balanceOf(other1.address)))
        console.log("other2 Token balance: " + fromWei(await token.balanceOf(other2.address)))
        console.log("other3 Token balance: " + fromWei(await token.balanceOf(other3.address)))
        console.log("ETH balance in Treasury contract: " + fromWei(await treasury.provider.getBalance(treasury.address)))

        console.log("Other1 ETH balance: " + fromWei(await other1.provider.getBalance(other1.address)))
        console.log("Other2 ETH balance: " + fromWei(await other2.provider.getBalance(other2.address)))
        console.log("Other3 ETH balance: " + fromWei(await other3.provider.getBalance(other3.address)))
    })
})