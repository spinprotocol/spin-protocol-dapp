const { deployedFileWriter } = require('../utils/contractData_fileController.js');
const { addAuth } = require('../utils/addAuth.js');
const AuthStorage = artifacts.require("AuthStorage");
const Migrations = artifacts.require("Migrations");

module.exports = function(deployer) {
  deployer.deploy(Migrations)
  .then(_ => deployer.deploy(AuthStorage))
  .then(_ => deployedFileWriter(AuthStorage))
  .then(_ => addAuth(AuthStorage))
};
