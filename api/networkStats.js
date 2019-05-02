const { get } = require('./restApi');
const { utils } = require('ethers');

const ETH_GAS_STATION_API_ENDPOINT = 'https://ethgasstation.info/json/ethgasAPI.json';

exports.DEFAULT_GAS_PRICE = utils.parseUnits('21', 'gwei');   // 21 Gwei
exports.DEFAULT_GAS_PRICE_KLAYTN = utils.parseUnits('25', 'gwei');   // 25 stone. Stone is equivalent of Gwei in Klayt considering that both tokens have 18 decimals
exports.DEFAULT_PRICE_STATS = {
  safeLow: DEFAULT_GAS_PRICE.div(2).toHexString(),   // 10.5 Gwei
  avg: DEFAULT_GAS_PRICE.toHexString(),              // 21 Gwei
  fast: DEFAULT_GAS_PRICE.mul(2).toHexString(),      // 42 Gwei
};

/**
 * Returns always a gas price statistics regardless of error
 * @param {string} network Name of the network to be connected
 * @returns {Promise<{safeLow:string,avg:string,fast:string}>} Gas statistics in hex string
 */
exports.getGasPriceStats = async function(network) {
  // If the network is Klaytn, use fixed gas price specific to Klaytn networks
  if (network === 'klaytn' || network === 'baobab' || network === 'aspen') {
    return Promise.resolve({
      safeLow: DEFAULT_GAS_PRICE_KLAYTN.toHexString(),  // 25 stone
      avg: DEFAULT_GAS_PRICE_KLAYTN.toHexString(),      // 25 stone
      fast: DEFAULT_GAS_PRICE_KLAYTN.toHexString(),     // 25 stone
    });
  }

  try {
    let {safeLow, average, fastest} = await get(ETH_GAS_STATION_API_ENDPOINT);
    console.log(`Gas price => fast: ${fastest / 10} Gwei - avg: ${average / 10} Gwei`);
    return Promise.resolve({
      safeLow: utils.parseUnits(utils.bigNumberify(safeLow).div(10).toString(), 'gwei').toHexString(),
      avg: utils.parseUnits(utils.bigNumberify(average).div(10).toString(), 'gwei').toHexString(),
      fast: utils.parseUnits(utils.bigNumberify(fastest).div(10).toString(), 'gwei').toHexString()
    });
  } catch (e) {
    console.log('Gas price => error');
    return  Promise.resolve(DEFAULT_PRICE_STATS);
  }
}