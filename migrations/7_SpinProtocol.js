const { deployedFileWriter, addressReader, contractName } = require('../utils/contractData_fileController.js');

const SpinProtocol = artifacts.require('SpinProtocol');

module.exports = function(deployer) {
  deployer.deploy(
      SpinProtocol, 
      addressReader(contractName.PROXY), 
      addressReader(contractName.CAMPAIGN_DB), 
      addressReader(contractName.REVENUELEDGER_DB),
      addressReader(contractName.PURCHASE_DB)
    )
    .then(_ => deployedFileWriter(SpinProtocol));
};
