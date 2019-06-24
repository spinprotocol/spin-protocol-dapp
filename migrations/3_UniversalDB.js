const { match } = require('ffp-js');
const { 
  deployedFileWriter, 
  addressReader, 
  contractName 
} = require('../utils/contractData_fileController.js');

const credentials = require('../credentials.json');
const getSpinTokenAddress = match
  .case(network => network == 'mainnet')(_=> credentials.klaytn.spin_token_address.mainnet)
  .case(network => network == 'baobab')(_=> credentials.klaytn.spin_token_address.baobab)
  .else(_=>_);

const UniversalDB = artifacts.require('UniversalDB');
const IERC20 = artifacts.require('IERC20');

module.exports = function(deployer, network) {
  deployer.deploy(UniversalDB, addressReader(contractName.PROXY, network))
    .then(_ => deployedFileWriter(UniversalDB, network))
    .then(_ => {
        IERC20.address = getSpinTokenAddress(network);
        deployedFileWriter(IERC20, network);
    })
};
