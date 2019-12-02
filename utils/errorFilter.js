module.exports = {
    evmError : f => f()
        .then(_ => ("Success Tx"))
        .catch(e => (e.message.substring(0,23)))
}