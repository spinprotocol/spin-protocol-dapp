const { deployedFileWriter, fileReader } = require('../utils/contractData_fileController.js');
const { upgradeProxy, setAuthStorage, setTokenAddr } = require('../utils/settingContract.js');

const RewardLedger = artifacts.require('RewardLedger');
const RewardLedger_Proxy = fileReader('RewardLedger_Proxy');
const AuthStorage = fileReader('AuthStorage');

module.exports = function(deployer) {
  deployer.deploy(RewardLedger)
    .then(_ => upgradeProxy(RewardLedger_Proxy, RewardLedger))
    .then(_ => {
      const funcAddr = RewardLedger.address;
      RewardLedger.address = RewardLedger_Proxy.address
      return funcAddr
    })
    .then(funcAddr => deployedFileWriter(RewardLedger, "RewardLedger", funcAddr))
    .then(_ => setAuthStorage(RewardLedger, AuthStorage.address))
    .then(_ => setTokenAddr(RewardLedger))
  };

