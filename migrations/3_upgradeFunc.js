const { match, go, log } =require('ffp-js');
const { deployedFileWriter, fileReader } = require('../utils/contractData_fileController.js');
const { CONTRACT, ACCOUNTS, WALLET } = require('../utils/generic-caver');

const credentials = require('../credentials.json');

const SpinProtocol = artifacts.require('SpinProtocol');
const EternalStorageProxy = fileReader('EternalStorageProxy')//EternalStorageProxy EternalStorageProxy
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
  deployer.deploy(SpinProtocol)
  /************** Version Setting **************/
    .then(async _ => go(
      CONTRACT.get(EternalStorageProxy.abi, EternalStorageProxy.address),
      async contract => {
        const version = await CONTRACT.read(contract, 'version()', {});
        log(version);
        log(SpinProtocol.address)
        return await CONTRACT.write(
            Signer, 
            contract, 
            'upgradeTo(string,address)', 
            {version: version, implementation: SpinProtocol.address}
          )
      },
      txReceipt => log('\r  -> Version Setting Tx :', txReceipt.transactionHash)
    ))
    .then(_ => SpinProtocol.address = EternalStorageProxy.address)
    .then(_ => deployedFileWriter(SpinProtocol))
};

