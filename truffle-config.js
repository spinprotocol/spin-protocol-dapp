const HDWalletProvider = require('truffle-hdwallet-provider');
const PrivateKeyConnector = require('connect-privkey-to-provider');
const credentials = require('./credentials.json');
const { match } = require('ffp-js');

const providerFactory = 
  match
    .case(network => network === 'rinkeby')(
      network => new HDWalletProvider(credentials.ethereum.mnemonics.testnet, `https://${network}.infura.io/v3/${credentials.infuraKey}`))
    .case(network => network === 'ropsten')(
      network => new HDWalletProvider(credentials.ethereum.mnemonics.testnet, `https://${network}.infura.io/v3/${credentials.infuraKey}`))
    .case(network => network === 'mainnet')(
      network => new HDWalletProvider(credentials.ethereum.mnemonics.mainnet, `https://${network}.infura.io/v3/${credentials.infuraKey}`))
    .case(network => network === 'baobab')(
      network => new PrivateKeyConnector(credentials.klaytn.privateKey.testnet, `https://api.${network}.klaytn.net:8651`))
    .case(network => network === 'klaytn')(
      network => new PrivateKeyConnector(credentials.klaytn.privateKey.mainnet, `https://api.${network}.klaytn.net:8651`))
    .else(_ => '')
    

module.exports = {
  networks: {

    /**
     * Ethereum Network
     */
    development: {
     host: "127.0.0.1",     // Localhost (default: none)
     port: 8545,            // Standard Ethereum port (default: none)
     network_id: "*",       // Any network (default: none)
    },
    rinkeby: {
      provider: providerFactory('rinkeby'),
      network_id: 4,       // Rinkeby's id
      gas: 7400000,        // Rinkeby has a lower block limit than mainnet
      confirmations: 5,    // # of confs to wait between deployments. (default: 0)
      gasPrice: 10000000000,  // Gas price on deployment
      timeoutBlocks: 200,  // # of blocks before a deployment times out  (minimum/default: 50)
      skipDryRun: true     // Skip dry run before migrations? (default: false for public nets )
    },
    ropsten: {
      provider: providerFactory('ropsten'),
      network_id: 3,       // Ropsten's id
      gas: 8000000,        // Ropsten has a lower block limit than mainnet
      gasPrice: 10000000000,  // Gas price on deployment
      confirmations: 5,    // # of confs to wait between deployments. (default: 0)
      timeoutBlocks: 200,  // # of blocks before a deployment times out  (minimum/default: 50)
      skipDryRun: true     // Skip dry run before migrations? (default: false for public nets )
    },
    mainnet: {
      provider: providerFactory('mainnet'),
      network_id: 1,          
      gas: 8000000,  
      gasPrice: 21000000000,
      confirmations: 5,
      timeoutBlocks: 50,
    },

    /**
     * Klaytn Network
     */
    klaytn_boabab: {
      provider: providerFactory('baobab'),
      network_id: 1001,
      gas: 20000000,
      gasPrice: null,
      confirmations: 5
    },
    klaytn_mainnet: {
      provider: providerFactory('baobab'),
      network_id: 1001,
      gas: 20000000,
      gasPrice: null,
      confirmations: 5
    },
    klaytn_local: {
      host: '127.0.0.1',
      port: 8551,
      from: '0x3dec1e5bd5220b13fc52e27e2332aa3fa756a06e', // enter your account address
      network_id: '1001', // Baobab network id
      gas: 20000000, // transaction gas limit
      gasPrice: 25000000000, // gasPrice of Baobab is 25 Gpeb
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
