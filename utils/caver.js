Object.assign(global, require('ffp-js'));

const stage = process.env.STAGE || 'dev';

const Caver = require('caver-js');
const caver = new Caver(`https://api.${ stage === 'prod' ? 'cypress' : 'baobab' }.klaytn.net:8651` );

const credentials = require('../credentials.json');

/***************** Deployer Setting *****************/
const Deployer = caver.klay.accounts.wallet.add(credentials[stage].deployer.pk);
const feePayer = caver.klay.accounts.wallet.add(credentials[stage].feePayer.pk, credentials[stage].feePayer.address);
const signer = credentials[stage].signer
const Token = credentials[stage].token

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

const toChecksumAddr = addr => caver.utils.toChecksumAddress(addr)

module.exports = {
    signer,
    stage,
    caver,
    Token,
    getContract,
    encodeFunc,
    toChecksumAddr,
    signTx,
    send
}