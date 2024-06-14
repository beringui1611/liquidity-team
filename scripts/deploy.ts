import { ethers } from "hardhat";

const BTC= "0x7130d2A12B9BCbFAe4f2634d864A1Ee1Ce3Ead9c";
const ETH = "0x7130d2A12B9BCbFAe4f2634d864A1Ee1Ce3Ead9c";
const USDC = "0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d";
const BNB = '0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c';
const NAME = "LIQGROUP";
const SYMBOL = "LQG";
const PRICE = 1;
const MAX_HOLDER=10;

async function main() {
  
     const lq = await ethers.deployContract("LiquidityTeam", [NAME, SYMBOL, BTC, ETH, USDC, BNB, PRICE, MAX_HOLDER]);
     await lq.waitForDeployment();
     console.log(lq.target);
    
  }
  
  // We recommend this pattern to be able to use async/await everywhere
  // and properly handle errors.
  main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });