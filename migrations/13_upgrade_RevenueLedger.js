const { deployedFileWriter, fileReader } = require('../utils/contractData_fileController.js');
const upgradeProxy = require('../utils/proxyUpgrade.js');

const RevenueLedger = artifacts.require('RevenueShare');
const RevenueLedger_Proxy = fileReader('RevenueLedger_Proxy');

/************** Deploy **************/
module.exports = function(deployer) {
  deployer.deploy(RevenueLedger)
    .then(_ => upgradeProxy(RevenueLedger_Proxy, RevenueLedger))
    .then(_ => RevenueLedger.address = RevenueLedger_Proxy.address)
    .then(_ => deployedFileWriter(RevenueLedger, "RevenueLedger"))
};

