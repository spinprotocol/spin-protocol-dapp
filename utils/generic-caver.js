const { go, log, map, find, tap } = require('ffp-js');

const Caver = require('caver-js');
const caver = new Caver('https://api.baobab.klaytn.net:8651');
// const caver = new Caver(process.env.KLAYTN_HOST);



/*******************************************************
 *               Main objects initialize               *
 *******************************************************/

const ACCOUNTS = {};
const WALLET = {};
const CONTRACT = {};



/*******************************************************
 *              Internal utils for Caver               *
 *******************************************************/

/**
 * @param { String } fnSignature
 */
const fnSpliter = fnSignature => go(fnSignature, str => str.substr(0, str.indexOf('(')));

/**
 * @param { Object } contract
 * @param { String } fnSignature
 * @param { Object } params
 */
const inputGenerator = (contract, fnSignature, params) => go(
  contract._jsonInterface,
  find(obj => obj.name == fnSpliter(fnSignature)),
  fn => fn.inputs,
  map(input => params[input.name])
);

/**
 * @param { Object } contract
 * @param { String } fnSignature
 */
const outputGenerator = (contract, fnSignature) => go(
  contract._jsonInterface,
  find(obj => obj.name == fnSpliter(fnSignature)),
  fn => fn.outputs,
  map(output => output.type)
);

/**
 * @param { Array } result
 * @param { Array } outputTypes
 * @todo Refactoring target
 */
const parseCallResult = (result, outputTypes) => {
  if (outputTypes.length > 1) {
    return outputTypes.map((type, i) => {
      return isBigNumber(type) && caver.utils.isBigNumber(result[i])
        ? result[i].toString(10)
        : result[i];
    });
  }

  return isBigNumber(outputTypes[0]) && caver.utils.isBigNumber(result)
    ? result.toString(10)
    : result;
};

/**
 * @param { String } type
 * @todo Refactoring target
 */
const isBigNumber = type => {
  switch (type) {
    case 'int':
    case 'int8':
    case 'int16':
    case 'int32':
    case 'int64':
    case 'int128':
    case 'int256':
    case 'uint':
    case 'uint8':
    case 'uint16':
    case 'uint32':
    case 'uint64':
    case 'uint128':
    case 'uint256':
      return true;
    default:
      return false;
  }
}

/*******************************************************
 *                  Accounts section                   *
 *******************************************************/

/**
 * @description Get account object using private key
 * @param { String } privateKey  
 * @return { Object } Account object
 */
ACCOUNTS.access = privateKey => caver.klay.accounts.privateKeyToAccount(privateKey);



/*******************************************************
 *                   Wallet section                    *
 *******************************************************/

/**
 * @description Connect account to wallet
 * @param { Object } account  
 * @return { Object } Signed account object
 */
WALLET.connect = account => caver.klay.accounts.wallet.add(account);



/*******************************************************
 *                  Contract section                   *
 *******************************************************/

/**
 * @description Get contract instance
 * @param { Object } abi 
 * @param { String } address 
 * @return { Object } Contract's instance object
 */
CONTRACT.get = (abi, address) => new caver.klay.Contract(abi, address);

/**
 * @description Write
 * @param { Object } signer 
 * @param { Object } contract 
 * @param { String } fnSignature 
 * @param { Object } params 
 * @return { Object } receipt
 */
CONTRACT.write = (signer, contract, fnSignature, params) => go(
  inputGenerator(contract, fnSignature, params),
  inputs => contract.methods[fnSignature](...inputs).send({ from: signer.address, gasPrice: '25000000000', gas: 20000000 })
);

/**
 * @description Read
 * @param { Object } contract 
 * @param { String } fnSignature 
 * @param { Object } params 
 * @return { Object } Call result
 */
CONTRACT.read = (contract, fnSignature, params) => go(
  inputGenerator(contract, fnSignature, params),
  inputs => contract.methods[fnSignature](...inputs).call(),
  res => parseCallResult(res, outputGenerator(contract, fnSignature))
);

module.exports = {
  CONTRACT, ACCOUNTS, WALLET
}