const {
    Token,
    getContract,
    encodeFunc,
    toChecksumAddr,
    signTx,
    send
} = require('./caver.js');

const nowDate = require('../utils/getTime.js');


//*************** Read ******************
const readVersion = contract => go(
    contract.methods['version()']().call(),
    res => res[0]
)

const readToken = (funcAbi, contractAddr) => go(
    getContract(funcAbi, contractAddr),
    contract => contract.methods['getTokenAddr(string)']("SPIN").call()
)

//*************** Write ******************

const writeUpgradeTo = (contractAddr, params) => go(
    encodeFunc('upgradeTo', ["string","address"], params),
    inputData => signTx(inputData, contractAddr),
    send
)

const setToken = (funcAbi, contractAddr) => go(
    readToken(funcAbi, contractAddr),
    checkAddr => toChecksumAddr(checkAddr) !== toChecksumAddr(Token),
    check => check ?
    go(
        encodeFunc('setTokenAddr', ["address","string"], [Token,"SPIN"]),
        inputData => signTx(inputData, contractAddr),
        send,
        txReceipt => txReceipt.transactionHash
    )  
    : "Already"
)


module.exports = (proxyFile, func, tokenContract) => {
    const Proxy = getContract(proxyFile.abi, proxyFile.address)

    return go(
        readVersion(Proxy),
        version => !version ? `1-${nowDate("YYMMDD")}` : `${Number(version.split("-")[0])+1}-${nowDate("YYMMDD")}`,
        version => writeUpgradeTo(Proxy._address, [version, func.address]),
        txReceipt => log('\r  -> Version Setting Tx :', txReceipt.transactionHash),
        _ => !tokenContract ? null : setToken(func.abi, Proxy._address),
        message => !message ? null : log(`\r  -> Token Setting to [ ${Token} ] Tx :`, message),
    )
}