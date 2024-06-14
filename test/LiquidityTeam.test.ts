import {loadFixture} from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { expect } from "chai";
import hre from "hardhat";

describe("Liquidity Team", function () {

  const BTC= "0x7130d2A12B9BCbFAe4f2634d864A1Ee1Ce3Ead9c";
  const ETH = "0x7130d2A12B9BCbFAe4f2634d864A1Ee1Ce3Ead9c";
  const USDC = "0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d";
  const BNB = '0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c';

  const VALUE = 1000000000000000000n

  async function deployFixture() {

    const [owner, otherAccount] = await hre.ethers.getSigners();


    const BTCTest = await hre.ethers.getContractFactory("BTCcoin");
    const btc = await BTCTest.deploy();

    const ETHTest = await hre.ethers.getContractFactory("ETHcoin");
    const eth = await ETHTest.deploy();

    const Liq = await hre.ethers.getContractFactory("LiquidityTeam");
    const liq = await Liq.deploy("Group Investiment", "GPI", btc.target, eth.target, USDC, BNB, 1n, 5n);

    return { liq, btc, eth, owner, otherAccount };
  }

  describe("Deployment", function () {
    it("Should get name", async function () {
      const { liq } = await loadFixture(deployFixture);
        
       expect(await liq.name()).to.equal("Group Investiment");
      
    });

    it("Should get symbol", async function () {
      const { liq } = await loadFixture(deployFixture);
        
       expect(await liq.symbol()).to.equal("GPI");
       
    });

    it("Should create position", async function () {
      const { liq, eth, owner } = await loadFixture(deployFixture);
      
      await eth.approve(liq.target, VALUE);
      await liq.addHolder(owner);      
        
      await liq.createPosition(eth.target, VALUE);
      
      expect(await liq.balanceOf(owner.address)).to.equal(3500n *10n **18n);
      
    });

    it("Should create position (ONLY HOLDER)", async function () {
      const { liq, eth} = await loadFixture(deployFixture);
      
      await eth.approve(liq.target, VALUE);     
        
      await expect(liq.createPosition(eth.target, VALUE)).to.be.revertedWithCustomError(liq, "InvalidHolder")
      
      
    });

    it("Should create position (TOKEN NOT EXIST)", async function () {
      const { liq, eth, owner } = await loadFixture(deployFixture);
      
      await eth.approve(liq.target, VALUE);
      await liq.addHolder(owner);      
        
      await expect(liq.createPosition(BTC, VALUE)).to.be.revertedWithCustomError(liq, "TokenNotExist");
      
      
    });

    it("Should remove position", async function () {
      const { liq, eth, owner} = await loadFixture(deployFixture);
      
      await eth.approve(liq.target, VALUE);     
      await liq.addHolder(owner); 
        
      await liq.createPosition(eth.target, VALUE)

      await liq.removePosition(eth.target, VALUE);

      expect(await liq.balanceOf(owner)).to.equal(0n)
      
      
    });

  });
});
