const UniversalDB = artifacts.require('UniversalDB');
const ActorDB = artifacts.require('ActorDB');
const CampaignDB = artifacts.require('CampaignDB');
const DealDB = artifacts.require('DealDB');
const ProductDB = artifacts.require('ProductDB');
const PurchaseDB = artifacts.require('PurchaseDB');
const Proxy = artifacts.require('Proxy');
const SpinProtocol = artifacts.require('SpinProtocol');
const Escrow = artifacts.require('EscrowAndFees');


const DBLayerDeployer = (deployer) => {
  return deployer
    .deploy(UniversalDB)
    .then(() => UniversalDB.deployed())
    .then(() => deployer.deploy(ActorDB, UniversalDB.address))
    .then(() => ActorDB.deployed())
    .then(() => deployer.deploy(CampaignDB, UniversalDB.address))
    .then(() => CampaignDB.deployed())
    .then(() => deployer.deploy(DealDB, UniversalDB.address))
    .then(() => DealDB.deployed())
    .then(() => deployer.deploy(ProductDB, UniversalDB.address))
    .then(() => ProductDB.deployed())
    .then(() => deployer.deploy(PurchaseDB, UniversalDB.address))
    .then(() => PurchaseDB.deployed())
    .catch(e => Promise.reject(new Error('DatabaseDeployer failed. Error:', e)));
};

const LogicLayerDeployer = (deployer) => {
  return deployer
    .deploy(SpinProtocol)
    .then(() => SpinProtocol.deployed())
    .then(() => deployer.deploy(Escrow))
    .then(() => Escrow.deployed())
    .catch(e => Promise.reject(new Error(('LogicLayerDeployer failed. Error:', e))));
};

const ProxyLayerDeployer = (deployer) => {
  return deployer
    .deploy(Proxy)
    .then(() => Proxy.deployed())
    .catch(e => Promise.reject(new Error(('ProxyLayerDeployer failed. Error:', e))));
};

module.exports = async (deployer, network) => {
  if (network === 'test') {
    console.log('Running unit tests on test network...');
    return;
  }

  await ProxyLayerDeployer(deployer);
  await DBLayerDeployer(deployer);
  await LogicLayerDeployer(deployer);
}
