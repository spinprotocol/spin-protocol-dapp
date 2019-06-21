const fs = require('fs');
const { go, log } = require('ffp-js');

const contractName = {
  PROXY : "Proxy",
  UNIVERSAL_DB : "UniversalDB",
  CAMPAIGN_DB : "CampaignDB",
  REVENUELEDGER_DB : "RevenueLedgerDB"
}

const deployedFileWriter = (contract, network) => {
  try {
    fs.writeFileSync(
      `./deployed/${network}/${contract._json.contractName}.json`, 
      `{ "address": "${contract.address}", "abi": ${JSON.stringify(contract._json.abi)} }`, 
      errorHandler
    );
  } catch (e) {
    log(e);
  }
};

const addressReader = (contractName, network) => {
  try {
    return go(
      fs.readFileSync(`./deployed/${network}/${contractName}.json`, 'utf8'),
      JSON.parse,
      a => a.address
    );   
  } catch (e) {
    log(e);  
  }
}

const errorHandler = (err) => { if (err) throw err; }

  module.exports = { contractName, deployedFileWriter, addressReader }