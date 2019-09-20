const moment = require("moment");
require("moment-timezone");
moment.tz.setDefault("Asia/Seoul");
const { match, go, tap, log } =require('ffp-js');
const { deployedFileWriter, fileReader } = require('../utils/contractData_fileController.js');
const { CONTRACT, ACCOUNTS, WALLET } = require('../utils/generic-caver');

const credentials = require('../credentials.json');

const SpinProtocol = artifacts.require('SpinProtocol');
const EternalStorageProxy = fileReader('EternalStorageProxy');
const EternalStorageProxy_Contract = CONTRACT.get(EternalStorageProxy.abi, EternalStorageProxy.address);
// const getSpinTokenAddress = network => credentials.klaytn.spin_token_address[network];


/************** Create signer **************/
const createSigner = privateKey => go(
  ACCOUNTS.access(privateKey),
  WALLET.connect
)

const Signer = match(process.env.STAGE)
.case(network => network == 'prod')(_=> createSigner(credentials.klaytn.privateKey.cypress))
.else(_=> createSigner(credentials.klaytn.privateKey.baobab));

/************** Deploy **************/
module.exports = function(deployer) {
  const date = moment().format("YYYYMMDD");

  deployer.deploy(SpinProtocol)
  /************** Version Setting **************/
    .then(_ => 
      go(
        CONTRACT.read(EternalStorageProxy_Contract, 'version()'),
        version => !version ? `1-${date}` : `${Number(version.split("-")[0])+1}-${date}`,
        version => CONTRACT.write(
          Signer, 
          EternalStorageProxy_Contract, 
          'upgradeTo(string,address)', 
          {version: version.toString(), implementation: SpinProtocol.address}
        ),
        txReceipt => log('\r  -> Version Setting Tx :', txReceipt.transactionHash)
      )
    )
    .then(_ => SpinProtocol.address = EternalStorageProxy.address)
    .then(_ => deployedFileWriter(SpinProtocol))
};

