const { deployedFileWriter, addressReader, contractName } = require('../utils/contractData_fileController.js');

const PurchaseDB = artifacts.require('PurchaseDB');

module.exports = function(deployer) {
  deployer.deploy(
      PurchaseDB, 
      addressReader(contractName.PROXY), 
      addressReader(contractName.UNIVERSAL_DB)
    )
    .then(_ => deployedFileWriter(PurchaseDB));
};
