Object.assign(global, require('ffp-js'));

const { getContract } = require('./caver');

// Metadata reading utils
const deployedFileReader = (contractName) => require(`../deployed/test/${contractName}.json`);

/**
 * @description file read of fileName and return to abi, address
 * @param { String } fileName
 * @return [abi, address]
 */
const getFileData = fileName => go(
  fileName, 
  deployedFileReader, 
  a => [a.abi,a.address]
)

const METADATA = {};

METADATA.Campaign = getContract(...getFileData("Campaign"));
METADATA.RevenueLedger = getContract(...getFileData("RevenueLedger"));
METADATA.Product = getContract(...getFileData("Product"));
METADATA.Event = getContract(...getFileData("Event"));
METADATA.AuthStorage = getContract(...getFileData("AuthStorage"));

module.exports = {
  METADATA
}

