const Web3 = require('web3');
const web3 = new Web3(Web3.givenProvider || new Web3.providers.HttpProvider('http://localhost:8545'));


async function getCurrentTimestamp() {
  return (await web3.eth.getBlock('latest')).timestamp;
}

/**
 * Increase the block time of local EVM manually
 * to mock the real-time block generation
 * 
 * @param {number} duration Time amount in seconds 
 */
async function increaseTime(duration) {
  let {err, res} = await web3.currentProvider.send('evm_increaseTime', duration);

  if (!err) {
    await web3.currentProvider.send('evm_mine');
  }
};


module.exports = {
  increaseTime,
  getCurrentTimestamp
}