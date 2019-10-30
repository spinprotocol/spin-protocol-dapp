const assert = require('assert');

module.exports = {
    evmError : f => f()
    .then(_ => assert.equal(false, "Success Tx"))
    .catch(e => assert.equal('evm: execution reverted', e.message.substring(0,23)))
}