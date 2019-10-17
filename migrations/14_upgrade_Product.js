const { deployedFileWriter, fileReader } = require('../utils/contractData_fileController.js');
const upgradeProxy = require('../utils/proxyUpgrade.js');
const { setAuthStorage } = require('../utils/addAuth.js');

const Product = artifacts.require('Product');
const Product_Proxy = fileReader('Product_Proxy');

module.exports = function(deployer) {
  deployer.deploy(Product)
    .then(_ =>  upgradeProxy(Product_Proxy, Product))
    .then(_ => {
      const funcAddr = Product.address;
      Product.address = Product_Proxy.address
      return funcAddr
    })
    .then(funcAddr => deployedFileWriter(Product, null, funcAddr))
    .then(_ => setAuthStorage(Product))
};

