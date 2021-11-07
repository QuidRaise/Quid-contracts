require("@nomiclabs/hardhat-ethers");
require("@nomiclabs/hardhat-waffle")
require('hardhat-deploy');
require("@tenderly/hardhat-tenderly");
require("@nomiclabs/hardhat-etherscan");
require("dotenv").config();
require("@nomiclabs/hardhat-truffle5");

const { utils } = require("ethers");

const PRIVATE_KEY = process.env.PRIVATE_KEY;
const PRIVATE_KEY_GANACHE = process.env.PRIVATE_KEY_GANACHE;
/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  defaultNetwork: "hardhat",
  solidity: {
    compilers: [
      {
        version: "0.7.0",
      },
    ],
    optimizer: {
      enabled: true,
      runs: 200,
    },
  },
  networks: {
     testnet: {
      url: "https://data-seed-prebsc-1-s1.binance.org:8545",
      chainId: 97,
      gasPrice: 20000000000,
      accounts: [`${PRIVATE_KEY}`],
    },
    localhost: {
      url: `http://localhost:9545`,
      accounts: [`${PRIVATE_KEY_GANACHE}`],
      timeout: 150000,
      gasPrice: parseInt(utils.parseUnits("132", "gwei")),
    },
    mainnet: {
      url: "https://bsc-dataseed.binance.org/",
      chainId: 56,
      accounts: [`${PRIVATE_KEY}`],
    },
    hardhat: {
      // forking: {
      //   url: `https://bsc-dataseed.binance.org/`,
      //   // blockNumber: 6674768,
      // },
      blockGasLimit: 12000000,
      allowUnlimitedContractSize :true
    },
  },
  etherscan: {
    apiKey: process.env.BSCSCAN_API_KEY,
  },
  tenderly: {
    project: process.env.TENDERLY_PROJECT,
    username: process.env.TENDERLY_USERNAME,
  },
};
