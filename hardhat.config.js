/** @type import('hardhat/config').HardhatUserConfig */

require('dotenv').config()
require('@nomicfoundation/hardhat-toolbox');
require('hardhat-contract-sizer');
require('hardhat-gas-reporter');
require('@openzeppelin/hardhat-upgrades')
require('solidity-coverage')
require('hardhat-abi-exporter')
require('solidity-docgen');

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  paths: {
    sources: 'contracts',
  },
  solidity: {
    version: '0.8.19',
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },

  networks: {
    hardhat: {
      forking: {
        url: process.env.ALCHEMY_URL,
        // blockNumber: 15000000 // Change accordingly
      },
    },
    dashboard: {
      url: 'http://localhost:24012/rpc'
    },
    /* amoy: {
      chainId: 80002,
      url: `${process.env.AMOY_PROVIDER}`,
      accounts: [`${process.env.AMOY_PRIVATE_KEY}`],
      confirmations: 2,
      skipDryRun: true,
      urls: {
        apiURL: 'https://api-amoy.plygonscan.com/api',
        browserURL: 'https://amoy.polygonscan.com'
      }
    } */
  },

  paths: {
    sources: './contracts',
    tests: './test',
    cache: './cache',
    artifacts: './artifacts'
  },

  mocha: {
    // timeout: 100000
  },

  contractSizer: {
    alphaSort: true,
    disambiguatePaths: false,
    runOnCompile: true,
    strict: true,
  },

  gasReporter: {
    enabled: true,
    coinmarketcap: `${process.env.CMC_APY_KEY}`,
    currency: 'USD',
    // gasPriceApi: 'https://api.polygonscan.com/api?module=proxy&action=eth_gasPrice',
    // token: 'MATIC',
    gasPriceApi: 'https://api.etherscan.io/api?module=proxy&action=eth_gasPrice',
    token: 'ETH'
  },

  docgen: {
    sourcesDir: 'contracts',
    outputDir: 'documentation',
    templates: 'templates',
    pages: 'files',
    clear: true,
    runOnCompile: true
  },

  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY
  },

  abiExporter: [
    {
      path: './abi/json',
      format: 'json',
    },
    {
      path: './abi/minimal',
      format: 'minimal',
    },
    {
      path: './abi/fullName',
      format: 'fullName',
    }
  ]
};
