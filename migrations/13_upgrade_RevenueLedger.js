const { deployedFileWriter, fileReader } = require('../utils/contractData_fileController.js');
const { upgradeProxy, setAuthStorage, setTokenAddr } = require('../utils/settingContract.js');

const RevenueLedger = artifacts.require('RevenueShare');
const RevenueLedger_Proxy = fileReader('RevenueLedger_Proxy');
const AuthStorage = fileReader('AuthStorage');

module.exports = function(deployer) {
  deployer.deploy(RevenueLedger)
    .then(_ => upgradeProxy(RevenueLedger_Proxy, RevenueLedger))
    .then(_ => {
      const funcAddr = RevenueLedger.address;
      RevenueLedger.address = RevenueLedger_Proxy.address
      return funcAddr
    })
    .then(funcAddr => deployedFileWriter(RevenueLedger, "RevenueLedger", funcAddr))
    .then(_ => setAuthStorage(RevenueLedger, AuthStorage.address))
    .then(_ => setTokenAddr(RevenueLedger))
  };

