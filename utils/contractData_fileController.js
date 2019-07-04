const fs = require('fs');
const mkdirp = require('mkdirp');
const { go, log } = require('ffp-js');

const contractName = {
  PROXY : "Proxy",
  UNIVERSAL_DB : "UniversalDB",
  CAMPAIGN_DB : "CampaignDB",
  REVENUELEDGER_DB : "RevenueLedgerDB",
  PURCHASE_DB : "PurchaseDB"
}

const deployedFileWriter = (contract) => {
  try {
    const dir = `./deployed/${process.env.STAGE}`;
    mkdirp(dir, err => !err ? false : log(err));
    fs.writeFileSync(
      dir+`/${contract._json.contractName}.json`, 
      `{ "address": "${contract.address}", "abi": ${JSON.stringify(contract._json.abi)} }`, 
      errorHandler
    );
  } catch (e) {
    log(e);
  }
};

const addressReader = (contractName) => {
  try {
    return go(
      fs.readFileSync(`./deployed/${process.env.STAGE}/${contractName}.json`, 'utf8'),
      JSON.parse,
      a => a.address
    );   
  } catch (e) {
    log(e);  
  }
}

const errorHandler = (err) => { if (err) throw err; }

module.exports = { contractName, deployedFileWriter, addressReader }