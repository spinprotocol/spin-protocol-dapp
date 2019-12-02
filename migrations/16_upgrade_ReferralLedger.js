const { deployedFileWriter, fileReader } = require('../utils/contractData_fileController.js');
const { upgradeProxy, setAuthStorage, setTokenAddr } = require('../utils/settingContract.js');

const ReferralLedger = artifacts.require('ReferralLedger');
const ReferralLedger_Proxy = fileReader('ReferralLedger_Proxy');
const AuthStorage = fileReader('AuthStorage');

module.exports = function(deployer) {
  deployer.deploy(ReferralLedger)
    .then(_ => upgradeProxy(ReferralLedger_Proxy, ReferralLedger))
    .then(_ => {
      const funcAddr = ReferralLedger.address;
      ReferralLedger.address = ReferralLedger_Proxy.address
      return funcAddr
    })
    .then(funcAddr => deployedFileWriter(ReferralLedger, "ReferralLedger", funcAddr))
    .then(_ => setAuthStorage(ReferralLedger, AuthStorage.address))
    .then(_ => setTokenAddr(ReferralLedger))
  };

