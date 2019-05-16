const PrivateKeyConnector = require('connect-privkey-to-provider');
const credentials = require('./credentials.json');
const { match } = require('ffp-js');

const providerFactory = 
  match
    .case(network => network === 'baobab')(
      network => new PrivateKeyConnector(credentials.klaytn.privateKey.testnet, `https://api.${network}.klaytn.net:8651`))
    .case(network => network === 'klaytn')(
      network => new PrivateKeyConnector(credentials.klaytn.privateKey.mainnet, `https://api.${network}.klaytn.net:8651`))
    .else(_ => '')
    

module.exports = {
  networks: {
    /**
     * Klaytn Network
     */
    development: {
      host: "127.0.0.1",
      port: 8551,
      from: '0x3dec1e5bd5220b13fc52e27e2332aa3fa756a06e',
      network_id: 1001,
      gas: 20000000, // transaction gas limit
      gasPrice: 25000000000 // gasPrice of Baobab is 25 Gpeb
    },
    baobab: {
      provider: providerFactory('baobab'),
      network_id: 1001,
      gas: 20000000,
      gasPrice: null
    },
    mainnet: {
      provider: providerFactory('mainnet'),
      network_id: 1,
      gas: 20000000,
      gasPrice: null
    },
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
