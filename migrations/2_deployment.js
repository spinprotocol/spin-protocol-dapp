
const fs = require('fs');
const { go, log, tap } = require('ffp-js');

const Proxy = artifacts.require('Proxy');
const UniversalDB = artifacts.require('UniversalDB');
const CampaignDB = artifacts.require('CampaignDB');
const RevenueLedgerDB = artifacts.require('RevenueLedgerDB');
const SpinProtocol = artifacts.require('SpinProtocol');
const IERC20 = artifacts.require('IERC20');
IERC20.address = '0x4a39a3e9b5793abe14157615e979e00758ec902a';

const errorHandler = (err) => { if (err) throw err; }

const addressReader = (contract, network) => {
  try {
    return go(
      fs.readFileSync(`./deployed/${network}/${contract._json.contractName}.json`, 'utf8'),
      JSON.parse,
      a => a.address
    );   
  } catch (e) {
    log(e);  
  }
}

const deployedFileWriter = (contract, network) => {
  try {
    fs.writeFileSync(
      `./deployed/${network}/${contract._json.contractName}.json`, 
      `{ "address": "${contract.address}", "abi": ${JSON.stringify(contract._json.abi)} }`, 
      errorHandler
    );
  } catch (error) {
    log(e);
  }
};

/**
 * Deployer functions set
 */
const generateIERC20Resource = (network) => deployedFileWriter(IERC20, network);

const deployProxy = async (deployer, network) => go(
  await deployer.deploy(Proxy),
  _=> deployedFileWriter(Proxy, network)
);

const deployUniversalDB = async (deployer, network) => go(
  await deployer.deploy(UniversalDB, addressReader(Proxy, network)),
  _=> deployedFileWriter(UniversalDB, network)
);

const deployCampaignDB = async (deployer, network) => go(
  await deployer.deploy(CampaignDB, addressReader(Proxy, network), addressReader(UniversalDB, network)),
  _=> deployedFileWriter(CampaignDB, network)
);

const deployRevenueLedgerDB = async (deployer, network) => go(
  await deployer.deploy(RevenueLedgerDB, addressReader(Proxy, network), addressReader(UniversalDB, network)),
  _=> deployedFileWriter(RevenueLedgerDB, network)
);

const deploySpinProtocol = async (deployer, network) => go(
  await deployer.deploy(
    SpinProtocol, 
    addressReader(Proxy, network), 
    addressReader(CampaignDB, network),
    addressReader(RevenueLedgerDB, network)
  ),
  _=> deployedFileWriter(SpinProtocol, network)
);

/* For DEV */
const allDeployer = (deployer, network) => 
    /* Proxy contract */
    deployer.deploy(Proxy)
      .then(_ => deployedFileWriter(Proxy, network))
      /* DB contracts */
      .then(_ => deployer.deploy(UniversalDB, addressReader(Proxy, network)))
      .then(_ => deployedFileWriter(UniversalDB, network))
      .then(_ => deployer.deploy(CampaignDB, addressReader(Proxy, network), addressReader(UniversalDB, network)))
      .then(_ => deployedFileWriter(CampaignDB, network))
      .then(_ => deployer.deploy(RevenueLedgerDB, addressReader(Proxy, network), addressReader(UniversalDB, network)))
      .then(_ => deployedFileWriter(RevenueLedgerDB, network))
      /* Logic contracts */
      .then(_ => deployer.deploy(SpinProtocol, addressReader(Proxy, network), addressReader(CampaignDB, network), addressReader(RevenueLedgerDB, network)))
      .then(_ => deployedFileWriter(SpinProtocol, network))
      .then(_ => deployedFileWriter(IERC20, network))


module.exports = async (deployer, network) => {
  if (network === 'test') {
    log('Running unit tests on test network...');
    return;
  }

  // await generateIERC20Resource(network);
  
  /**
   * Contract deploy sequence
   * 1. Proxy
   * 2. UniversalDB
   * 3. Others DB
   * 4. SpinProtocol
   * !!! Fix me : Eternal contract - UniversalDB 
   */
  // await deployProxy(deployer, network);
  // await deployUniversalDB(deployer, network);
  // await deployCampaignDB(deployer, network);
  // await deployRevenueLedgerDB(deployer, network);
  // await deploySpinProtocol(deployer, network);

  await allDeployer(deployer, network);
}
