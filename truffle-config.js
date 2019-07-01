const PrivateKeyConnector = require('connect-privkey-to-provider');
const credentials = require('./credentials.json');
const { go } = require('ffp-js');

const providerFactory = network => go(
  `https://api.${network}.klaytn.net:8651`,
  host => new PrivateKeyConnector(credentials.klaytn.privateKey[network], host)
);

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
    cypress: {
      provider: providerFactory('cypress'),
      network_id: 8217,
      gas: 20000000,
      gasPrice: null
    },
    baobab: {
      provider: providerFactory('baobab'),
      network_id: 1001,
      gas: 10000000,
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
