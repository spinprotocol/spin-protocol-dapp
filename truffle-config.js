const HDWalletProvider = require('truffle-hdwallet-provider-klaytn');
const credentials = require('./credentials.json');

const stage = process.env.STAGE || 'dev';

const providerFactory = () => new HDWalletProvider(
      credentials[stage].deployer.pk, 
      `https://api.${stage === 'prod' ? 'cypress' : 'baobab'}.klaytn.net:8651`
    );
    
module.exports = {
  networks: {
    development: {
      provider: providerFactory(),
      network_id: 1001,
      gas: '50000000',
      gasPrice: null
    },
    baobab: {
      provider: providerFactory(),
      network_id: 1001,
      gas: '50000000',
      gasPrice: null
    },
    cypress: {
      provider: providerFactory(),
      network_id: 8217,
      gas: '50000000',
      gasPrice: null
    }
  },
  mocha: {
    useColors: true,
    reporter: 'eth-gas-reporter',
    reporterOptions : {
      currency: 'USD',
      gasPrice: 21,
      showTimeSpent: true
    }
  },
  compilers: {
    solc: {
      version: "0.4.24",    // Fetch exact version from solc-bin (default: truffle's version)
      settings: {          // See the solidity docs for advice about optimization and evmVersion
       optimizer: {
          enabled: true,
          runs: 200
        }
      }
    }
  }
}
