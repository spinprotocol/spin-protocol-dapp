const fs = require('fs');
Object.assign(global, require('ffp-js'));

const moment = require("moment");
require("moment-timezone");
moment.tz.setDefault("Asia/Seoul");

const nowDate = format => moment().format(format);

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
    fs.writeFileSync(
      dir+`/${name}.json`, 
      JSON.stringify({
        address : contract.address,
        abi : contract._json.abi,
        version : getVersion(name, funcAddr || contract.address)
      }, null, '\t'),
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