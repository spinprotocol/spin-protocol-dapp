const HDWalletProvider = require('truffle-hdwallet-provider-klaytn');
// const HDWalletProvider = require('truffle-hdwallet-provider');
const credentials = require('./credentials.json');

// const providerFactory = network => new HDWalletProvider(credentials.klaytn.privateKey[network], `https://ropsten.infura.io/v3/af8e0c6fa6eb4927ae308ea32a75e552`);
const providerFactory = network => new HDWalletProvider(credentials.klaytn.privateKey[network], `https://api.${network}.klaytn.net:8651`);

module.exports = {
  networks: {
    development: {
      provider: providerFactory('baobab'),
      network_id: 1001,
      // timeoutBlocks: 200,
      // skipDryRun: true,
      // production: true,    // Treats this network as if it was a public net. (default: false)
      gas: 850000
    },
    baobab: {
      provider: providerFactory('baobab'),
      network_id: 1001,
      gas: '3000000',
      gasPrice: null
    }
    // cypress: {
    //   provider: providerFactory('cypress'),
    //   network_id: '8217',
    //   gas: '8500000',
    //   gasPrice: null
    // }
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
