const { deployedFileWriter, addressReader, contractName } = require('../utils/contractData_fileController.js');

const PurchaseDB = artifacts.require('PurchaseDB');

module.exports = function(deployer, network) {
  deployer.deploy(
      PurchaseDB, 
      addressReader(contractName.PROXY, network), 
      addressReader(contractName.UNIVERSAL_DB, network)
    )
    .then(_ => deployedFileWriter(PurchaseDB, network));
};
