const { deployedFileWriter, fileReader } = require('../utils/contractData_fileController.js');
const upgradeProxy = require('../utils/proxyUpgrade.js');

const Purchase = artifacts.require('Purchase');
const Purchase_Proxy = fileReader('Purchase_Proxy');

module.exports = function(deployer) {
  deployer.deploy(Purchase)
    .then(_ =>  upgradeProxy(Purchase_Proxy, Purchase))
    .then(_ => Purchase.address = Purchase_Proxy.address)
    .then(_ => deployedFileWriter(Purchase))
};

