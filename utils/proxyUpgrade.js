Object.assign(global, require('ffp-js'));

const nowDate = require('../utils/getTime.js');

const stage = process.env.STAGE || 'dev';

const Caver = require('caver-js');
const caver = new Caver(`https://api.${ stage === 'prod' ? 'cypress' : 'baobab' }.klaytn.net:8651` );

const credentials = require('../credentials.json');

/***************** Deployer Setting *****************/
const Deployer = caver.klay.accounts.wallet.add(credentials[stage].deployer.pk);
const feePayer = caver.klay.accounts.wallet.add(credentials[stage].feePayer.pk, credentials[stage].feePayer.address);

/***************** Contract Setting *****************/
const getContract = (abi, address) => new caver.klay.Contract(abi, address)

const encodeFunc = (funcName, paramTypes, params) => go(
    `${funcName}(${paramTypes})`,
    func => caver.klay.abi.encodeFunctionSignature(func),
    funcSig => funcSig + caver.klay.abi.encodeParameters(paramTypes, params).substring(2)
)

const signTx = (inputData, toAddr) => go(
    caver.klay.accounts.signTransaction({
        from: Deployer.address,
        to: toAddr,
        data: inputData,
        gasPrice: '25000000000', 
        gas: 20000000,
        type: "FEE_DELEGATED_SMART_CONTRACT_EXECUTION"
    }, Deployer.privateKey),
    signed => signed.rawTransaction
)

const send = senderRawTransaction => caver.klay.sendTransaction({ senderRawTransaction, feePayer: feePayer.address })

const writeUpgradeTo = (contractAddr, params) => go(
    encodeFunc('upgradeTo', ["string","address"], params),
    inputData => signTx(inputData, contractAddr),
    send
)

const addAdmin = (funcAbi, contractAddr, newAdminAddr) => 
    go(
        readAdmin(contractAddr, funcAbi, newAdminAddr),
        check => !check ? 
        go(
            encodeFunc('addAdmin', ["address"], [newAdminAddr]),
            inputData => signTx(inputData, contractAddr),
            send,
            txReceipt => txReceipt.transactionHash
        )  
        : "Already"
    )

const readVersion = contract => go(
    contract.methods['version()']().call(),
    res => res[0]
)

const readAdmin = (contractAddr, funcAbi, account) => go(
    getContract(funcAbi, contractAddr),
    contract => contract.methods['isAdmin(address)'](account).call()
)



module.exports = (proxy, func) => go(
    getContract(proxy.abi, proxy.address),
    contract => {proxy = contract},
    _ => readVersion(proxy),
    version => !version ? `1-${nowDate("YYMMDD")}` : `${Number(version.split("-")[0])+1}-${nowDate("YYMMDD")}`,
    version => writeUpgradeTo(proxy._address, [version, func.address]),
    txReceipt => log('\r  -> Version Setting Tx :', txReceipt.transactionHash),
    _ => addAdmin(func.abi, proxy._address, credentials[stage].signer.address),
    message => log(`\r  -> Admin Setting to [ ${credentials[stage].signer.address} ] Tx :`, message)
)