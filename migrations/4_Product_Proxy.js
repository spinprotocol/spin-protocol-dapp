const { deployedFileWriter } = require('../utils/contractData_fileController.js');

const EternalStorageProxy = artifacts.require('EternalStorageProxy');

/************** Deploy **************/
module.exports = function(deployer) {
  deployer.deploy(EternalStorageProxy)
  .then(_ => deployedFileWriter(EternalStorageProxy, "Product_Proxy"))
};
