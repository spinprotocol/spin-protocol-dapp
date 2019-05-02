const { utils, Contract, providers, Signer } = require('ethers');
const { formatToken } = require('../utils/conversions');


/**
 * Creates a contract instance with the provided interface at the provided address.
 * 
 * @param {providers.BaseProvider|Signer} signerOrProvider 
 * @param {object} contractInterface 
 * @param {string} address 
 */
function getContractByInterface(signerOrProvider, contractInterface, address) {
  return new Contract(address, contractInterface, signerOrProvider);
}

/**
 * Sends a gasEstimate call to the network with provided function
 * and its parameters and then returns the gas spent.
 * 
 * @param {Contract} contract 
 * @param {string} fnName 
 * @param {object} params 
 */
function getGasEstimate(contract, fnName, params) {
  const inputs = orderInputs(contract, fnName, params);
  return contract.estimate[fnName](...inputs);
}

/**
 * Returns the native token balance for the given address.
 * Decimal point number is assumed to be 18. Further decimal
 * point adjustment should be done on client-side of this API
 * 
 * @param {providers.BaseProvider} provider 
 * @param {string} address 
 */
async function getNativeBalance(provider, address) {
  let balance = await provider.getBalance(address);
  return utils.formatEther(balance).toString(10);
}

/**
 * Returns the ERC20 compliant token balance for the given address.
 * The balance is formatted by default with the default decimal number which is 18.
 * 
 * @param {Contract} token Token contract
 * @param {string} address
 * @param {{format:boolean,decimals:string|number}} [options={format:false, decimals:18}]
 * @returns {Promise<string|number>}
 */
async function getTokenBalance(token, address, options={format:true, decimals:18}) {
  let balance = await readContract(token, 'balanceOf', {owner: address});
  balance = parseQueryResult(balance, query.outputTypes);

  if (options && options.format) {
    return formatToken(balance, options.decimals || 18);
  }

  return balance;
}

/**
 * Fetches the current state of the contract. Notice that only the functions marked 
 * with `constant:true` and `outputs:[]` which are the view functions in ABI are called.
 * 
 * @param {Contract} contract 
 */
async function getContractState(contract) {
  let state = [];
  // Iterate through the contract's ABI
  for (let i = 0; i < contract.interface.abi.length; i++) {
    let abi = contract.interface.abi[i];
    // Only fetch functions which are constant and do not take inputs
    if (abi.constant === true && abi.inputs.length === 0) {
      // Make a call to the network with the selected function
      let result = await contract[abi.name]();
      // Get the output types for formatting purpose later
      let outputTypes = abi.outputs.map(output => output.type);
      state[abi.name] = parseQueryResult(result, outputTypes);
    }
  }

  return state;
}

/**
 * Makes a function call with the given function name and parameters
 * to the given contract. The call will change the state of the contract, i.e transaction call.
 * 
 * @param {Contract} contract
 * @param {string} fnName Name of the function to be called
 * @param {*} params Parameters of the function to be called
 * @param {string|number} gasPrice
 * @param {string|number} gasLimit
 * @param {string|number} confirmations Number of blocks to wait after the tx is mined
 * @returns {Promise<providers.TransactionResponse>} Tx response
 */
async function writeContract(contract, fnName, params, gasPrice, gasLimit, confirmations) {
  // Put the inputs in the same order as the function takes them
  const inputs = orderInputs(contract, fnName, params);

  console.log('sendTxFn#inputs:', inputs);

  let res = await contract[fnName](...inputs, {
    gasPrice: utils.parseUnits(gasPrice, 'gwei').toHexString(),
    gasLimit: gasLimit && !isNaN(gasLimit) ? Number(gasLimit) : undefined
  });

  console.log('sendTxFn#txResponse:', res);

  return res.wait(confirmations);
}

/**
 * Creates a query to read contract and returns the read state/variable's value
 * 
 * @param {Contract} contract 
 * @param {string} fnName Name of the query function to be called
 * @param {object} params Parameters of the query function to be called
 * @returns {*} Query result
 */
async function readContract(contract, fnName, params) {
  let _query = createQuery(contract, fnName, params);
  let res = await _query.call();
  return parseQueryResult(res, _query.outputTypes);
}

/**
 * Creates a query to read contract. In order to call the query function,
 * `call()` function should be called on the returned query object.
 * 
 * @param {Contract} contract 
 * @param {string} queryName Name of the query function to be called
 * @param {object} params Parameters of the query function to be called
 * @returns {{call:function,outputTypes:string[]}} Query
 */
function createQuery(contract, queryName, params) {
  const inputs = orderInputs(contract, queryName, params);

  if (!contract[queryName]) {
    throw new Error(`"${contract}" doesn't have any function named as "${queryName}"!`);
  }

  return {
    call: contract[queryName].bind(contract, ...inputs),
    outputTypes: contract.interface.functions[queryName].outputs.map(output => output.type)
  };
}

/**
 * Orders and returns the inputs in the same order as they are in the contract interface.
 * 
 * @param {Contract} contract 
 * @param {string} fnName 
 * @param {object} params 
 */
function orderInputs(contract, fnName, params) {
  const inputs = [];
  contract.interface.functions[fnName].inputs.forEach(input => {
    if (params[input.name]) {
      inputs.push(params[input.name]);
    }
  });
  return inputs;
}

/**
 * Parses the query result according to its type.
 * Basically, it only converts BigNumber types
 * to its string representation. If `result`
 * includes more than one value, the parsed result
 * will be an array of the parsed values.
 *
 * @param {*} result 
 * @param {Array<{type:string}>} outputTypes 
 */
function parseQueryResult(result, outputTypes) {
  if (outputTypes.length > 1) {
    return outputTypes.map((type, i) => {
      return isBigNumber(type) && result[i] instanceof utils.BigNumber
        ? result[i].toString(10)
        : result[i];
    });
  }

  return isBigNumber(outputTypes[0]) && result instanceof utils.BigNumber
    ? result.toString(10)
    : result;
}

function isBigNumber(type) {
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

module.exports = {
  getContractByInterface,
  getGasEstimate,
  getNativeBalance,
  getTokenBalance,
  getContractState,
  writeContract,
  readContract,
}