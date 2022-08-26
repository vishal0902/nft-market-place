require("@nomicfoundation/hardhat-toolbox");

const fs = require('fs');
const privateKey = fs.readFileSync(".secret").toString();

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.9",
  networks: {
    hardhat: {
      chainId:1337
    },
    mumbai: {
      url: `https://polygon-mumbai.g.alchemy.com/v2/XYOJGuoNDGVEIJT-pWhY_-t5LDyIBSoR`,
      accounts:[privateKey]
    },
    mainnet: {
      url: `https://polygon-mainnet.g.alchemy.com/v2/7QcJxXRVihn7hgVYbN_eEDlPQ9OvaYfM`,
      accounts:[privateKey]
    }
  }
};
