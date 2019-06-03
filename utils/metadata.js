// Metadata reading utils
const addressReader = (contractName) => require(`../deployed/address/${contractName}.json`).address;
const abiReader = (contractName) => require(`../deployed/abi/${contractName}.json`).abi;

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

/**
 * Contract's addresses
 * Spin Protocol contract addresses 
 */
METADATA.ADDRESS = {};

METADATA.ADDRESS.PROXY = addressReader(METADATA.NAME.PROXY);
METADATA.ADDRESS.SPIN_PROTOCOL = addressReader(METADATA.NAME.SPIN_PROTOCOL);
METADATA.ADDRESS.UNIVERSAL_DB = addressReader(METADATA.NAME.UNIVERSAL_DB);
METADATA.ADDRESS.CAMPAIGN_DB = addressReader(METADATA.NAME.CAMPAIGN_DB);
METADATA.ADDRESS.REVENUE_LEDGER_DB = addressReader(METADATA.NAME.REVENUE_LEDGER_DB);
METADATA.ADDRESS.IERC20 = '0x4a39a3e9b5793abe14157615e979e00758ec902a'; //Spin Token Address


/**
 * Contract's ABI
 * Spin Protocol contract abi 
 */
METADATA.ABI = {};

METADATA.ABI.PROXY = abiReader(METADATA.NAME.PROXY);
METADATA.ABI.SPIN_PROTOCOL = abiReader(METADATA.NAME.SPIN_PROTOCOL);
METADATA.ABI.UNIVERSAL_DB = abiReader(METADATA.NAME.UNIVERSAL_DB);
METADATA.ABI.CAMPAIGN_DB = abiReader(METADATA.NAME.CAMPAIGN_DB);
METADATA.ABI.REVENUE_LEDGER_DB = abiReader(METADATA.NAME.REVENUE_LEDGER_DB);
METADATA.ABI.IERC20 = abiReader('IERC20');

module.exports = {
  METADATA
}

