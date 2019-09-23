const HDWalletProvider = require('truffle-hdwallet-provider-klaytn');
const credentials = require('./credentials.json');

const providerFactory = network => new HDWalletProvider(credentials.klaytn.privateKey[network], `https://api.${network}.klaytn.net:8651`);

module.exports = {
  networks: {
    development: {
      provider: providerFactory('baobab'),
      network_id: 1001,
      gas: '15000000',
      gasPrice: null
    },
    baobab: {
      provider: providerFactory('baobab'),
      network_id: 1001,
      gas: '15000000',
      gasPrice: null
    },
    cypress: {
      provider: providerFactory('cypress'),
      network_id: 8217,
      gas: '15000000',
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
