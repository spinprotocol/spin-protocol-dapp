const { deployedFileWriter, addressReader, contractName } = require('../utils/contractData_fileController.js');

const RevenueLedgerDB = artifacts.require('RevenueLedgerDB');

module.exports = function(deployer) {
  deployer.deploy(
      RevenueLedgerDB, 
      addressReader(contractName.PROXY), 
      addressReader(contractName.UNIVERSAL_DB)
    )
    .then(_ => deployedFileWriter(RevenueLedgerDB));
};
