const { deployedFileWriter } = require('../utils/contractData_fileController.js');

const Proxy = artifacts.require('Proxy');

module.exports = function(deployer, network) {
  deployer.deploy(Proxy)
    .then(_ => deployedFileWriter(Proxy, network));
};
