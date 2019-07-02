const { deployedFileWriter, addressReader, contractName } = require('../utils/contractData_fileController.js');

const SpinProtocol = artifacts.require('SpinProtocol');

module.exports = function(deployer, network) {
  deployer.deploy(
      SpinProtocol, 
      addressReader(contractName.PROXY, network), 
      addressReader(contractName.CAMPAIGN_DB, network), 
      addressReader(contractName.REVENUELEDGER_DB, network),
      addressReader(contractName.PURCHASE_DB, network)
    )
    .then(_ => deployedFileWriter(SpinProtocol, network));
};
