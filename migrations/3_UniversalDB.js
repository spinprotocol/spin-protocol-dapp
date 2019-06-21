const { deployedFileWriter, addressReader, contractName } = require('../utils/contractData_fileController.js');
const credentials = require('../credentials.json');

const UniversalDB = artifacts.require('UniversalDB');
const IERC20 = artifacts.require('IERC20');

module.exports = function(deployer, network) {
  deployer.deploy(UniversalDB, addressReader(contractName.PROXY, network))
    .then(_ => deployedFileWriter(UniversalDB, network))
    .then(_ => {
        IERC20.address = credentials.SPIN.address;
        deployedFileWriter(IERC20, network);
    })
};
