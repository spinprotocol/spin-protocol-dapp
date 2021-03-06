const { deployedFileWriter, fileReader } = require('../utils/contractData_fileController.js');
const { upgradeProxy, setAuthStorage } = require('../utils/settingContract.js');

const Campaign = artifacts.require('Campaign');
const Campaign_Proxy = fileReader('Campaign_Proxy');
const AuthStorage = fileReader('AuthStorage');

module.exports = function(deployer) {
  deployer.deploy(Campaign)
    .then(_ => upgradeProxy(Campaign_Proxy, Campaign))
    .then(_ => {
      const funcAddr = Campaign.address;
      Campaign.address = Campaign_Proxy.address
      return funcAddr
    })
    .then(funcAddr => deployedFileWriter(Campaign, null, funcAddr))
    .then(_ => setAuthStorage(Campaign, AuthStorage.address))
};