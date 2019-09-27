Object.assign(global, require('ffp-js'));

const moment = require("moment");
require("moment-timezone");
moment.tz.setDefault("Asia/Seoul");

const stage = !process.env.STAGE? 'dev' : process.env.STAGE;

const Caver = require('caver-js');
const caver = new Caver(`https://api.${ stage === 'prod' ? 'cypress' : 'baobab' }.klaytn.net:8651` );

const credentials = require('../credentials.json');

/***************** Signer Setting *****************/
log(credentials[stage].feePayer.pk)

const Signer = caver.klay.accounts.wallet.add(credentials[stage].deployer.pk);
const feePayer = caver.klay.accounts.wallet.add(credentials[stage].feePayer.pk, credentials[stage].feePayer.address);

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
    version => !version ? `1-${nowDate}` : `${Number(version.split("-")[0])+1}-${nowDate}`,
    version => writeUpgradeTo(proxy, version, func.address),
    txReceipt => log('\r  -> Version Setting Tx :', txReceipt.transactionHash)
)