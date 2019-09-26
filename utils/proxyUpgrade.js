Object.assign(global, require('ffp-js'));

const moment = require("moment");
require("moment-timezone");
moment.tz.setDefault("Asia/Seoul");

const setEN = network => network === 'prod' ? 
    `https://api.cypress.klaytn.net:8651` 
    : `https://api.baobab.klaytn.net:8651`;
const Caver = require('caver-js');
const caver = new Caver(setEN(process.env.STAGE));

const credentials = require('../credentials.json');

/***************** Signer Setting *****************/
const connectSigner = privateKey => go(
    caver.klay.accounts.privateKeyToAccount(privateKey),
    account => caver.klay.accounts.wallet.add(account)
  )

const Signer = match(process.env.STAGE)
    .case(network => network == 'prod')(_=> connectSigner(credentials.klaytn.privateKey.cypress))
    .else(_=> connectSigner(credentials.klaytn.privateKey.baobab));
  

/***************** Contract Setting *****************/
const getContract = (abi, address) => new caver.klay.Contract(abi, address)

const writeUpgradeTo = (contract, version, funcAddr) => 
    contract.methods['upgradeTo(string,address)'](version.toString(), funcAddr).send(
            { 
                from: Signer.address, 
                gasPrice: '25000000000', 
                gas: 20000000
            }
        )

const readVersion = contract => go(
        contract.methods['version()']().call(),
        res => res[0]
    )


/***************** Now Date *****************/
const nowDate = moment().format("YYMMDD");



module.exports = (proxy, func) => go(
    getContract(proxy.abi, proxy.address),
    contract => {proxy = contract},
    _ => readVersion(proxy),
    version => !version ? `1-${date}` : `${Number(version.split("-")[0])+1}-${nowDate}`,
    version => writeUpgradeTo(proxy, version, func.address),
    txReceipt => log('\r  -> Version Setting Tx :', txReceipt.transactionHash)
)