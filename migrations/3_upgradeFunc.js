Object.assign(global, require('ffp-js'));
const { deployedFileWriter, fileReader } = require('../utils/contractData_fileController.js');

const credentials = require('../credentials.json');
const { CONTRACT, ACCOUNTS, WALLET } = require('../utils/generic-caver');

const SpinProtocol = artifacts.require('SpinProtocol');
// const getSpinTokenAddress = network => credentials.klaytn.spin_token_address[network];

/************** Create signer **************/
const createSigner = privateKey => go(
  ACCOUNTS.access(privateKey),
  WALLET.connect
)

const Signer = await match(process.env.STAGE)
.case(network => network == 'prod')(_=> createSigner(credentials.klaytn.privateKey.cypress))
.else(_=> createSigner(credentials.klaytn.privateKey.baobab));

const EternalStorageProxy = await fileReader('EternalStorageProxy')
/************** Deploy **************/
module.exports = function(deployer) {
  deployer.deploy(SpinProtocol)
  /************** Version Setting **************/
    .then(_ => go(
      CONTRACT.get(EternalStorageProxy.abi, EternalStorageProxy.address),
      async contract => {
        const version = await CONTRACT.read(contract, 'version()', {});
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

