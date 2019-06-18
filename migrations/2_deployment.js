
const fs = require('fs');
const { go, log } = require('ffp-js');

const Proxy = artifacts.require('Proxy');
const UniversalDB = artifacts.require('UniversalDB');
const CampaignDB = artifacts.require('CampaignDB');
const RevenueLedgerDB = artifacts.require('RevenueLedgerDB');
const SpinProtocol = artifacts.require('SpinProtocol');
const IERC20 = artifacts.require('IERC20');
IERC20.address = '0x4a39a3e9b5793abe14157615e979e00758ec902a';

const contractInfo = (contract) => ({ name: contract._json.contractName });
const errorHandler = (err) => { if (err) throw err; }
const addressWriter = (contract) => go(fs.writeFile(`./deployed/address/${contract._json.contractName}.json`, `{ "address": "${contract.address}" }`, errorHandler), _=>_);
const abiWriter = (contract) => go(fs.writeFile(`./deployed/abi/${contract._json.contractName}.json`, `{ "abi": ${JSON.stringify(contract._json.abi)} }`, errorHandler), _=>_);
const fileWriter = (contract) => { 
  addressWriter(contract); 
  abiWriter(contract); 
}

const Deployer = (deployer) => {
    /* Proxy contract */
  return deployer.deploy(Proxy)
    .then(_ => fileWriter(Proxy))
    /* DB contracts */
    .then(_ => deployer.deploy(UniversalDB,Proxy.address))
    .then(_ => fileWriter(UniversalDB))
    .then(_ => deployer.deploy(CampaignDB, Proxy.address, UniversalDB.address))
    .then(_ => fileWriter(CampaignDB))
    .then(_ => deployer.deploy(RevenueLedgerDB, Proxy.address, UniversalDB.address))
    .then(_ => fileWriter(RevenueLedgerDB))
    /* Logic contracts */
    .then(_ => deployer.deploy(SpinProtocol, Proxy.address, CampaignDB.address, RevenueLedgerDB.address))
    .then(_ => fileWriter(SpinProtocol))
    .then(_ => fileWriter(IERC20))
    .catch(e => Promise.reject(new Error('Deployer failed. Error:', e)));
};

module.exports = async (deployer, network) => {
  if (network === 'test') {
    log('Running unit tests on test network...');
    return;
  }

  await Deployer(deployer);
}
