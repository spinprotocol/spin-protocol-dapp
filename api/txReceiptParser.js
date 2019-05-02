const { utils } = require('ethers');

exports.parseTxResponse = function(response) {
  return {
    hash: response.hash,
    timestamp: response.timestamp ? response.timestamp.toString(10) : '-',
    blockNumber: response.blockNumber ? response.blockNumber.toString(10) : 'in progress',
    blockHash: response.blockHash || 'in progress',
    confirmations: response.confirmations || 'in progress',
    to: response.to,
    from: response.from,
    data: response.data,
    value: utils.formatEther(response.value).toString(10),
    gasLimit: response.gasLimit.toString(10),
    gasPrice: response.gasPrice.toString(10),
    nonce: response.nonce.toString(10),
    chainId: response.chainId ? response.chainId.toString(10) : '-'
  };
}

exports.parseTxReceipt = function(receipt) {
  return {
    hash: receipt.transactionHash,
    blockNumber: receipt.blockNumber ? receipt.blockNumber.toString(10) : 'in progress',
    blockHash: receipt.blockHash || 'in progress',
    transactionIndex: receipt.transactionIndex.toString(10),
    gasUsed: receipt.gasUsed.toString(10),
    status: receipt.status === 1 ? 'confirmed' : receipt.status === 0 ? 'failed' : 'in progress'
  };
}