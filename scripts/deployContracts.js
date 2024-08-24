const { ether, network } = require("hardhat");
const hre = require("hardhat");
require("dotenv").config();


async function main() {
    const Token = await hre.ethers.getContractFactory("Token");
    console.log("Deploying Token contract...");
    const token = await Token.deploy("myToken", "myT1", 1000000);
    await token.deployed();
    console.log("Token contract deployed @:", token.address);

    const SimpleDEX = await hre.ethers.getContractFactory("SimpleDEX");
    console.log("Deploying SimpleDEX contract...");
    const simpleDex = await SimpleDEX.deploy(token.address, process.env.ETHUSD_CHAINLINK_ADDRESS);
    await simpleDex.deployed();
    console.log("SimpleDEX contract deployed @:", simpleDex.address);

    const Treasury = await hre.ethers.getContractFactory("Treasury");
    console.log("Deploying Treasury contract...");
    const treasury = await Treasury.deploy(simpleDex.address);
    await treasury.deployed();
    console.log("Treasury contract deployed @:", treasury.address);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });