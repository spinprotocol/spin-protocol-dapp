Object.assign(global, require('ffp-js'));

// Metadata reading utils
const deployedFileReader = (contractName) => 
  require(`../deployed/${process.env.NETWORK}/${contractName}.json`);

const METADATA = {};

/**
 * Contract's names
 * Spin Protocol contract names
 */
METADATA.NAME = {};

METADATA.NAME.PROXY = 'Proxy';
METADATA.NAME.SPIN_PROTOCOL = 'SpinProtocol';
METADATA.NAME.UNIVERSAL_DB = 'UniversalDB';
METADATA.NAME.CAMPAIGN_DB = 'CampaignDB';
METADATA.NAME.REVENUE_LEDGER_DB = 'RevenueLedgerDB';
METADATA.NAME.IERC20 = 'IERC20';

/**
 * Contract's addresses
 * Spin Protocol contract addresses 
 */
METADATA.ADDRESS = {};

METADATA.ADDRESS.PROXY = go(METADATA.NAME.PROXY, deployedFileReader, a => a.address);
METADATA.ADDRESS.SPIN_PROTOCOL = go(METADATA.NAME.SPIN_PROTOCOL, deployedFileReader, a => a.address);
METADATA.ADDRESS.UNIVERSAL_DB = go(METADATA.NAME.UNIVERSAL_DB, deployedFileReader, a => a.address);
METADATA.ADDRESS.CAMPAIGN_DB = go(METADATA.NAME.CAMPAIGN_DB, deployedFileReader, a => a.address);
METADATA.ADDRESS.REVENUE_LEDGER_DB = go(METADATA.NAME.REVENUE_LEDGER_DB, deployedFileReader, a => a.address);
METADATA.ADDRESS.IERC20 = go(METADATA.NAME.IERC20, deployedFileReader, a => a.address);


/**
 * Contract's ABI
 * Spin Protocol contract abi 
 */
METADATA.ABI = {};

METADATA.ABI.PROXY = go(METADATA.NAME.PROXY, deployedFileReader, a => a.abi);
METADATA.ABI.SPIN_PROTOCOL = go(METADATA.NAME.SPIN_PROTOCOL, deployedFileReader, a => a.abi);
METADATA.ABI.UNIVERSAL_DB = go(METADATA.NAME.UNIVERSAL_DB, deployedFileReader, a => a.abi);
METADATA.ABI.CAMPAIGN_DB = go(METADATA.NAME.CAMPAIGN_DB, deployedFileReader, a => a.abi);
METADATA.ABI.REVENUE_LEDGER_DB = go(METADATA.NAME.REVENUE_LEDGER_DB, deployedFileReader, a => a.abi);
METADATA.ABI.IERC20 = go(METADATA.NAME.IERC20, deployedFileReader, a => a.abi);

module.exports = {
  METADATA
}

