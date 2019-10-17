Object.assign(global, require('ffp-js'));

const {
    signer,
    getContract,
    encodeFunc,
    toChecksumAddr,
    signTx,
    send
} = require('./caver.js');
const { fileReader } = require('./contractData_fileController.js');
const AuthStorage = go(
    fileReader("AuthStorage"),
    json => json.address || null
)

//*************** Read ******************
const getAuthStorage = contract => go(
    getContract(contract._json.abi, contract.address),
    contract => contract.methods['getAuthStorage()']().call()
)

//*************** Write ******************
const addAuth = contract => 
    go(
        encodeFunc('addAuth', ["string","address"], ["admin",signer.address]),
        inputData => signTx(inputData, contract.address),
        send,
        txReceipt => log(`\r  -> addAuth [${signer.address}] Tx :`, txReceipt.transactionHash)
    )

const setAuthStorage = contract => go(
    getAuthStorage(contract),
    checkAddr => toChecksumAddr(checkAddr) !== toChecksumAddr(AuthStorage),
    check => check ?
    go(
        encodeFunc('setAuthStorage', ["address"], [AuthStorage]),
        inputData => signTx(inputData, contract.address),
        send,
        txReceipt => log('\r  -> AuthStorage Setting Tx :', txReceipt.transactionHash),
    ) 
    : log('\r  -> AuthStorage Setting Tx : Already')
)


module.exports = {
    addAuth,
    setAuthStorage
}