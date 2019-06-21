const { deployedFileWriter, addressReader, contractName } = require('../utils/contractData_fileController.js');

const RevenueLedgerDB = artifacts.require('RevenueLedgerDB');

module.exports = function(deployer, network) {
  deployer.deploy(
      RevenueLedgerDB, 
      addressReader(contractName.PROXY, network), 
      addressReader(contractName.UNIVERSAL_DB, network)
    )
    .then(_ => deployedFileWriter(RevenueLedgerDB, network));
};
