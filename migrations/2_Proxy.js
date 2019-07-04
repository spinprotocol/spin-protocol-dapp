const { deployedFileWriter } = require('../utils/contractData_fileController.js');

const Proxy = artifacts.require('Proxy');

module.exports = function(deployer) {
  deployer.deploy(Proxy)
    .then(_ => deployedFileWriter(Proxy));
};
