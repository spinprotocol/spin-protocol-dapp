Object.assign(global, require('ffp-js'));

const stage = (!process.env.STAGE || process.env.STAGE == 'test') ? 'dev' : process.env.STAGE;

const Caver = require('caver-js');
const caver = new Caver(`https://api.${ stage === 'prod' ? 'cypress' : 'baobab' }.klaytn.net:8651` );

const credentials = require('../credentials.json');

/***************** Deployer Setting *****************/
const Deployer = caver.klay.accounts.wallet.add(credentials[stage].deployer.pk);
const feePayer = caver.klay.accounts.wallet.add(credentials[stage].feePayer.pk, credentials[stage].feePayer.address);
const Test = (stage ==='dev') ? caver.klay.accounts.wallet.add(credentials[stage].test.pk) : null;
const Signer = credentials[stage].signer
const Token = credentials[stage].token

/***************** Contract Setting *****************/
const getContract = (abi, address) => new caver.klay.Contract(abi, address)

/***************** Utils *****************/
const UTILS = {}

UTILS.toChecksumAddr = addr => caver.utils.toChecksumAddress(addr)

UTILS.toPeb = num => caver.utils.toPeb(num)
UTILS.fromPeb = num => caver.utils.fromPeb(num)

UTILS.toSha3 = str => caver.utils.sha3(str);


UTILS.getPastEvent = (contract, eventName, filter, fromBlock, toBlock, picks) => go(
    contract.getPastEvents(eventName || "allEvents",
        {
            filter,
            fromBlock : fromBlock || 0,
            toBlock : toBlock || "latest"
        }),
        map(({ returnValues }) => go(
            returnValues,
            a => !picks ? a : pick(picks,a)
        ))
)

/***************** Transaction *****************/
const encodeFunc = (funcName, paramTypes, params) => go(
    `${funcName}(${paramTypes})`,
    func => caver.klay.abi.encodeFunctionSignature(func),
    funcSig => funcSig + caver.klay.abi.encodeParameters(paramTypes, params).substring(2)
)

const signTx = (inputData, toAddr, test) => go(
    caver.klay.accounts.signTransaction({
        from: !test ? Deployer.address : Test.address,
        to: toAddr,
        data: inputData,
        gasPrice: '25000000000', 
        gas: 20000000,
        type: "FEE_DELEGATED_SMART_CONTRACT_EXECUTION"
    }, !test ? Deployer.privateKey : Test.privateKey),
    signed => signed.rawTransaction
)

const send = senderRawTransaction => caver.klay.sendTransaction({ senderRawTransaction, feePayer: feePayer.address })

const viewContract = (contract, funcSig, params) => go(
    contract,
    contract => contract.methods[funcSig](...params).call()
)

const callContract = (funcName, paramsType, paramsValue, contractAddr, test) => go(
    encodeFunc(funcName, paramsType, paramsValue),
    inputData => signTx(inputData, contractAddr, test),
    send
)

module.exports = {
    Deployer,
    Signer,
    Test,
    Token,
    getContract,
    UTILS,
    callContract,
    viewContract,
}