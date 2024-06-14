import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import dotenv from 'dotenv';
dotenv.config();

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.24",
  },
  networks: {
    bsctest: {
      url: 'https://data-seed-prebsc-1-s1.binance.org:8545/',
      chainId: 97,
      accounts: {
        mnemonic: process.env.PRIVATE_KEY
      }

    }
  },

  etherscan: {
    apiKey: process.env.API_KEY
  }
};

export default config;
