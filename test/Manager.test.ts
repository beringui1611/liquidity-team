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

    const Manager = await hre.ethers.getContractFactory("Manager");
    const manager = await Manager.deploy(10);

    return { manager, owner, otherAccount };
  }

  describe("Deployment", function () {
    it("Should renuncied manager", async function () {
      const { manager, otherAccount} = await loadFixture(deployFixture);
        
       expect(await manager.renunciedManagership(otherAccount)).to.emit(manager, "NewManager").withArgs(otherAccount, Date.now());
       expect(await manager.manager()).to.equal(otherAccount);
      
    });

    it("Should renuncied manager (UNAUTHORIZED)", async function () {
        const { manager, otherAccount} = await loadFixture(deployFixture);

        const IManager = await manager.connect(otherAccount);
          
        await expect(IManager.renunciedManagership(otherAccount)).to.be.revertedWithCustomError(manager, "InvalidOnlyManager");
          
      });

      it("Should renuncied manager (ADDRESS ZERO)", async function () {
        const { manager, otherAccount} = await loadFixture(deployFixture);

        await manager.connect(otherAccount);

        const ZERO = hre.ethers.ZeroAddress;          
        await expect(manager.renunciedManagership(ZERO)).to.be.revertedWithCustomError(manager, "InvalidAddress");
          
      });

      it("Should add holder", async function () {
        const { manager, otherAccount} = await loadFixture(deployFixture);

        await manager.addHolder(otherAccount);

        expect(await manager.holder(otherAccount)).to.equal(true);
          
      });

      it("Should add holder (MAX HOLDER)", async function () {
        const { manager, otherAccount} = await loadFixture(deployFixture);

        for(let i=0; i < 10; i++){
            await manager.addHolder(otherAccount);
        }

        await expect(manager.addHolder(BNB)).to.be.revertedWithCustomError(manager, "InvalidAddHolder");
        
      });

      it("Should add holder (NOT ONLY MANAGER)", async function () {
        const { manager, otherAccount} = await loadFixture(deployFixture);
        
        const IManager = await manager.connect(otherAccount);
        await expect(IManager.addHolder(otherAccount)).to.be.revertedWithCustomError(manager, "InvalidOnlyManager");
          
      });


  });
});
