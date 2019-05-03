
const fs = require('fs');
const { go, log } = require('ffp-js');

const UniversalDB = artifacts.require('UniversalDB');
const ActorDB = artifacts.require('ActorDB');
const CampaignDB = artifacts.require('CampaignDB');
const DealDB = artifacts.require('DealDB');
const ProductDB = artifacts.require('ProductDB');
const PurchaseDB = artifacts.require('PurchaseDB');
const Proxy = artifacts.require('Proxy');
const SpinProtocol = artifacts.require('SpinProtocol');
const EscrowAndFees = artifacts.require('EscrowAndFees');

const contractInfo = (contract) => ({ name: contract._json.contractName });
const errorHandler = (err) => { if (err) throw err; }
const addressWriter = (contract) => go(fs.writeFile(`./deployed/address/${contract._json.contractName}_Address`, JSON.stringify(contract.address), errorHandler), _=>_);
const abiWriter = (contract) => go(fs.writeFile(`./deployed/abi/${contract._json.contractName}_ABI`, JSON.stringify(contract._json.abi), errorHandler), _=>_);
const fileWriter = (contract) => { 
  addressWriter(contract); 
  abiWriter(contract); 
}

const Deployer = (deployer) => {
    /* Proxy contract */
  return deployer.deploy(Proxy)
    .then(_ => fileWriter(Proxy))
    /* DB contracts */
    .then(_ => deployer.deploy(UniversalDB))
    .then(_ => fileWriter(UniversalDB))
    // .then(_ => deployer.deploy(CampaignDB, UniversalDB.address))
    // .then(_ => fileWriter(CampaignDB._json.contractName, CampaignDB._json.abi, CampaignDB.address))
    // .then(_ => deployer.deploy(DealDB, UniversalDB.address))
    // .then(_ => fileWriter(DealDB._json.contractName, DealDB._json.abi, DealDB.address))
    // .then(_ => deployer.deploy(ProductDB, UniversalDB.address))
    // .then(_ => fileWriter(ProductDB._json.contractName, ProductDB._json.abi, ProductDB.address))
    // .then(_ => deployer.deploy(PurchaseDB, UniversalDB.address))
    // .then(_ => fileWriter(PurchaseDB._json.contractName, PurchaseDB._json.abi, PurchaseDB.address))
    // .then(_ => deployer.deploy(SpinProtocol))
    /* Logic contracts */
    // .then(_ => fileWriter(SpinProtocol._json.contractName, SpinProtocol._json.abi, SpinProtocol.address))
    // .then(_ => deployer.deploy(EscrowAndFees))
    // .then(_ => fileWriter(EscrowAndFees._json.contractName, EscrowAndFees._json.abi, EscrowAndFees.address))
    .catch(e => Promise.reject(new Error('Deployer failed. Error:', e)));
};

module.exports = async (deployer, network) => {
  if (network === 'test') {
    log('Running unit tests on test network...');
    return;
  }

  await Deployer(deployer);
}
