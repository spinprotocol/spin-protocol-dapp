const { match } = require('ffp-js');
const { 
  deployedFileWriter, 
  addressReader, 
  contractName 
} = require('../utils/contractData_fileController.js');

const credentials = require('../credentials.json');
const getSpinTokenAddress = network => credentials.klaytn.spin_token_address[network];

const UniversalDB = artifacts.require('UniversalDB');
const IERC20 = artifacts.require('IERC20');

module.exports = function(deployer, network) {
  deployer.deploy(UniversalDB, addressReader(contractName.PROXY))
    .then(_ => deployedFileWriter(UniversalDB))
    .then(_ => {
        IERC20.address = getSpinTokenAddress(network);
        log(network)
        deployedFileWriter(IERC20);
    })
};
