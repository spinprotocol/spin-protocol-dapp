const { deployedFileWriter, addressReader, contractName } = require('../utils/contractData_fileController.js');

const CampaignDB = artifacts.require('CampaignDB');

module.exports = function(deployer, network) {
  deployer.deploy(
      CampaignDB, 
      addressReader(contractName.PROXY, network), 
      addressReader(contractName.UNIVERSAL_DB, network)
    )
    .then(_ => deployedFileWriter(CampaignDB, network));
};
