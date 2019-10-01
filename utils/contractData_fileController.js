const fs = require('fs');
const mkdirp = require('mkdirp');
const { go, log } = require('ffp-js');
const stage = process.env.STAGE || 'dev';

const deployedFileWriter = (contract, name) => {
  try {
    const dir = `./deployed/${stage}`;
    mkdirp(dir, err => !err ? false : log(err));
    fs.writeFileSync(
      dir+`/${!name ? contract._json.contractName : name}.json`, 
      `{ "address": "${contract.address}", "abi": ${JSON.stringify(contract._json.abi)} }`, 
      errorHandler
    );
  } catch (e) {
    log(e);
  }
};

const fileReader = contractName => {
  try {
    return go(
      fs.readFileSync(`../deployed/${stage}/${contractName}.json`, 'utf8'),
      JSON.parse
    );   
  } catch (e) {
    log(e);  
  }
}

const errorHandler = (err) => { if (err) throw err; }

module.exports = { deployedFileWriter, fileReader }