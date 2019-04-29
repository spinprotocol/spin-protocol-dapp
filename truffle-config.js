const HDWalletProvider = require('truffle-hdwallet-provider');
const credentials = require('./credentials.json');

module.exports = {
  networks: {
    development: {
     host: "127.0.0.1",     // Localhost (default: none)
     port: 8545,            // Standard Ethereum port (default: none)
     network_id: "*",       // Any network (default: none)
    },
    rinkeby: {
      provider: () => new HDWalletProvider(credentials.mnemonics.testnet, `https://rinkeby.infura.io/v3/${credentials.infuraKey}`),
      network_id: 4,       // Rinkeby's id
      gas: 7400000,        // Rinkeby has a lower block limit than mainnet
      confirmations: 5,    // # of confs to wait between deployments. (default: 0)
      gasPrice: 10000000000,  // Gas price on deployment
      timeoutBlocks: 200,  // # of blocks before a deployment times out  (minimum/default: 50)
      skipDryRun: true     // Skip dry run before migrations? (default: false for public nets )
    },
    ropsten: {
      provider: () => new HDWalletProvider(credentials.mnemonics.testnet, `https://ropsten.infura.io/v3/${credentials.infuraKey}`),
      network_id: 3,       // Ropsten's id
      gas: 8000000,        // Ropsten has a lower block limit than mainnet
      gasPrice: 10000000000,  // Gas price on deployment
      confirmations: 5,    // # of confs to wait between deployments. (default: 0)
      timeoutBlocks: 200,  // # of blocks before a deployment times out  (minimum/default: 50)
      skipDryRun: true     // Skip dry run before migrations? (default: false for public nets )
    },
    mainnet: {
      provider: () => new HDWalletProvider(credentials.mnemonics.mainnet, `https://mainnet.infura.io/v3/${credentials.infuraKey}`),
      network_id: 1,          // Rinkeby's id
      gas: 8000000,           // Rinkeby has a lower block limit than mainnet
      gasPrice: 21000000000,  // Gas price on deployment
      confirmations: 5,       // # of confs to wait between deployments. (default: 0)
      timeoutBlocks: 50,      // # of blocks before a deployment times out  (minimum/default: 50)
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
      version: "0.5.7",    // Fetch exact version from solc-bin (default: truffle's version)
      settings: {          // See the solidity docs for advice about optimization and evmVersion
       optimizer: {
          enabled: true,
          runs: 200
        }
      }
    }
  }
}
