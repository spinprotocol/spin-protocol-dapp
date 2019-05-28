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

METADATA.ADDRESS.PROXY = addressReader('Proxy');
METADATA.ADDRESS.SPIN_PROTOCOL = addressReader('SpinProtocol');
METADATA.ADDRESS.UNIVERSAL_DB = addressReader('UniversalDB');
METADATA.ADDRESS.CAMPAIGN_DB = addressReader('CampaignDB');
METADATA.ADDRESS.REVENUE_LEDGER_DB = addressReader('RevenueLedgerDB');


/**
 * Contract's ABI
 * Spin Protocol contract abi 
 */
METADATA.ABI = {};

METADATA.ABI.PROXY = abiReader('Proxy');
METADATA.ABI.SPIN_PROTOCOL = abiReader('SpinProtocol');
METADATA.ABI.UNIVERSAL_DB = abiReader('UniversalDB');
METADATA.ABI.CAMPAIGN_DB = abiReader('CampaignDB');
METADATA.ABI.REVENUE_LEDGER_DB = abiReader('RevenueLedgerDB');

module.exports = {
  METADATA
}