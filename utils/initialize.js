const { go, log } = require('ffp-js');

const credentials = require('../credentials.json');
const { CONTRACT, ACCOUNTS, WALLET } = require('./generic-caver');
const { METADATA } = require('./metadata');

const Proxy = CONTRACT.get(METADATA.ABI.PROXY, METADATA.ADDRESS.PROXY);
const SpinProtocol = CONTRACT.get(METADATA.ABI.SPIN_PROTOCOL, METADATA.ADDRESS.SPIN_PROTOCOL);
const UniversalDB = CONTRACT.get(METADATA.ABI.UNIVERSAL_DB, METADATA.ADDRESS.UNIVERSAL_DB);
const CampaignDB = CONTRACT.get(METADATA.ABI.CAMPAIGN_DB, METADATA.ADDRESS.CAMPAIGN_DB);
const RevenueLedgerDB = CONTRACT.get(METADATA.ABI.REVENUE_LEDGER_DB, METADATA.ADDRESS.REVENUE_LEDGER_DB);
const IERC20 = CONTRACT.get(METADATA.ABI.IERC20, METADATA.ADDRESS.IERC20);

const registerContractToProxy = async (signer, proxy, contractAddr, contractName) => {
  await go(
    CONTRACT.write(signer, proxy, 'addContract(string,address)', { name: contractName, addr: contractAddr }),
    txReceipt => log('\n\r> Tx receipt:', txReceipt)
  )
}

const setProxyFor = async (signer, contract, contractName, proxyAddr) => {
  await go(
    CONTRACT.write(signer, contract, 'setProxy(address)', { _proxy: proxyAddr }),
    txReceipt => log('\n\r> Tx receipt:', txReceipt)
  )
}

const setDataStore = async (signer, spinProtocol) => {
  await go(
    CONTRACT.write(signer, spinProtocol, 'setDataStore(address,address)', { 
      _campaignDB: METADATA.ADDRESS.CAMPAIGN_DB,
      _revenueLedgerDB: METADATA.ADDRESS.REVENUE_LEDGER_DB
    }),
    txReceipt => log('\n\r> Tx receipt:', txReceipt)
  )
}

const createSigner = privateKey => go(
  ACCOUNTS.access(privateKey),
  WALLET.connect
)

const initialize = async _ => {
  /************** Create signer **************/
  // process.env.KLAYTN_ADMIN_PRIVATE_KEY
  const Signer = await createSigner(credentials.klaytn.privateKey.testnet);
  
  /************** Add system contracts to `Proxy` contract **************/
  log('\n\r>> Registering system contracts to Proxy...\n\r');
  await registerContractToProxy(Signer, Proxy, METADATA.ADDRESS.SPIN_PROTOCOL, METADATA.NAME.SPIN_PROTOCOL)
  await registerContractToProxy(Signer, Proxy, METADATA.ADDRESS.UNIVERSAL_DB, METADATA.NAME.UNIVERSAL_DB)
  await registerContractToProxy(Signer, Proxy, METADATA.ADDRESS.CAMPAIGN_DB, METADATA.NAME.CAMPAIGN_DB)
  await registerContractToProxy(Signer, Proxy, METADATA.ADDRESS.REVENUE_LEDGER_DB, METADATA.NAME.REVENUE_LEDGER_DB)

  // /************** Set Proxy contract address for system contracts **************/
  log('\n\r>> Setting Proxy for system contracts...\n\r');
  await setProxyFor(Signer, SpinProtocol, METADATA.NAME.SPIN_PROTOCOL, METADATA.ADDRESS.PROXY)
  await setProxyFor(Signer, UniversalDB, METADATA.NAME.UNIVERSAL_DB, METADATA.ADDRESS.PROXY)
  await setProxyFor(Signer, CampaignDB, METADATA.NAME.CAMPAIGN_DB, METADATA.ADDRESS.PROXY)
  await setProxyFor(Signer, RevenueLedgerDB, METADATA.NAME.REVENUE_LEDGER_DB, METADATA.ADDRESS.PROXY)

  /************** Initialize system logic contracts **************/
  log('\n\r>> Initializing system logic contracts...\n\r');
  await setDataStore(Signer, SpinProtocol)

  
  log('\n\r\n\r*** Initialization has been completed successfully. ***\n\r\n\r');

  /************** Revenue share Test **************/
  const revenueData = { 
    _revenue : 10000,
    _spinRatio : 10,  
    _marketPrice : 1550 //15.5 * 100
  }

  let amt = await CONTRACT.read(SpinProtocol, 'revenueSpin(uint256,uint256,uint256)', revenueData);

  let tokenTransferData = { 
    to : METADATA.ADDRESS.SPIN_PROTOCOL,
    value : amt
  }

  log(`\n\n**** send Test Token to SpinProtocol Contract ${amt}`)
  await go(
     CONTRACT.write(Signer, IERC20, 'transfer(address,uint256)', tokenTransferData),
     txReceipt => log('\n\r> Tx receipt:', txReceipt)
  )



  // await CONTRACT.write(Signer, Proxy, 'removeContract(string)', { name: 'SpinProtocol' })
  // await go(CONTRACT.read(Proxy, 'getContract(string)', { name: 'SpinProtocol' }), log);
}

(async function() {
  try {
    await initialize();
  } catch (e) {
    log('System initialization has been stopped due to the following error:\n\r', e);
  }
})();