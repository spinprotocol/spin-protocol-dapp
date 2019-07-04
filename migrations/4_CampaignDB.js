const { deployedFileWriter, addressReader, contractName } = require('../utils/contractData_fileController.js');

const CampaignDB = artifacts.require('CampaignDB');

module.exports = function(deployer) {
  deployer.deploy(
      CampaignDB, 
      addressReader(contractName.PROXY), 
      addressReader(contractName.UNIVERSAL_DB)
    )
    .then(_ => deployedFileWriter(CampaignDB));
};
