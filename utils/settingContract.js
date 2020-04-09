Object.assign(global, require('ffp-js'));
const moment = require("moment");
require("moment-timezone");
moment.tz.setDefault("Asia/Seoul");

const {
    Signer,
    Token,
    UTILS,
    getContract,
    callContract,
    viewContract
} = require('./caver.js');

const nowDate = format => moment().format(format);

const upgradeProxy = (proxyFile, func) => {
    log(proxyFile)
        const ProxyContract = getContract(proxyFile.abi, proxyFile.address)

        return go(
            viewContract(ProxyContract, 'version()', []),
            version => !version ? `1-${ nowDate("YYMMDD") }` : `${ Number(version.split("-")[0])+1 }-${ nowDate("YYMMDD") }`,
            version => callContract('upgradeTo', ["string","address"], [version, func.address], ProxyContract._address),
            tx => log(`\r  -> Version Setting Tx : ${ tx.transactionHash }`),
        )
    }

const addAuth = contract => 
    go(
        callContract('addAuth', ["string","address"], ["admin",Signer.address], contract.address),
        tx => log(`\r  -> addAuth [ ${ Signer.address } ] Tx : ${ tx.transactionHash }` )
    )

const setAuthStorage = (truffleContract, afterStoregeAddr) => 
    go(
        getContract(truffleContract._json.abi, truffleContract.address),
        contract => viewContract(contract, 'getAuthStorage()', []),
        checkAddr => UTILS.toChecksumAddr(checkAddr) !== UTILS.toChecksumAddr(afterStoregeAddr),
        async check => check ?
        await go(
            callContract('setAuthStorage', ["address"], [afterStoregeAddr], truffleContract.address),
            tx => `\r  -> AuthStorage Setting Tx : ${ tx.transactionHash }`
        ) 
        : log('\r  -> AuthStorage Setting : Already')
    )

const setTokenAddr = truffleContract => 
    go(
        getContract(truffleContract._json.abi, truffleContract.address),
        contract => viewContract(contract, 'getTokenAddr(string)', ["SPIN"]),
        checkAddr => UTILS.toChecksumAddr(checkAddr) !== UTILS.toChecksumAddr(Token),
        async check => check ? 
        await go(
            callContract('setTokenAddr', ["address","string"], [Token,"SPIN"], truffleContract.address),
            tx => `\r  -> SPIN Token address [ ${ Token } ] Setting Tx : ${ tx.transactionHash }`
        ) 
        : log(`\r  -> SPIN Token address [${ Token }] Setting : Already`)
    )


module.exports = {
    upgradeProxy,
    addAuth,
    setAuthStorage,
    setTokenAddr
}