const { deployedFileWriter, fileReader } = require('../utils/contractData_fileController.js');
const upgradeProxy = require('../utils/proxyUpgrade.js');

const Campaign = artifacts.require('Campaign');
const Campaign_Proxy = fileReader('Campaign_Proxy');

module.exports = function(deployer) {
  deployer.deploy(Campaign)
    .then(_ => upgradeProxy(Campaign_Proxy, Campaign))
    .then(_ => Campaign.address = Campaign_Proxy.address)
    .then(_ => deployedFileWriter(Campaign))
};