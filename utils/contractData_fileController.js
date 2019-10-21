const fs = require('fs');
const mkdirp = require('mkdirp');
const { go, log } = require('ffp-js');
const nowDate = require('./getTime.js');
const stage = process.env.STAGE || 'dev';

const getVersion = (contractName, newAddr) => {
  try {
    return go(
      fs.readFileSync(`./deployed/${stage}/${contractName}.json`, 'utf8'),
      JSON.parse,
      json => json.version,
      history => {
        if (!history) history = {}
        history[nowDate("YYMMDD-HH:mm:ss")] = newAddr
        return history
      }
    );   
  } catch (e) {
    const history = {}
    history[nowDate("YYMMDD-HH:mm:ss")] = newAddr
    return history
  }
}

const deployedFileWriter = (contract, name, funcAddr) => {
  try {
    const dir = `./deployed/${stage}`;
    name = name || contract._json.contractName;
    mkdirp(dir, err => !err ? false : log(err));
    fs.writeFileSync(
      dir+`/${name}.json`, 
      JSON.stringify({
        address : contract.address,
        abi : contract._json.abi,
        version : getVersion(name, funcAddr || contract.address)
      },null,'\t'),
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