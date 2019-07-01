Object.assign(global, require('ffp-js'));

const credentials = require('../credentials.json');
const { CONTRACT, ACCOUNTS, WALLET, UTILS, KLAY } = require('./generic-caver');
const { METADATA } = require('./metadata');

const Proxy = CONTRACT.get(METADATA.ABI.PROXY, METADATA.ADDRESS.PROXY);
const SpinProtocol = CONTRACT.get(METADATA.ABI.SPIN_PROTOCOL, METADATA.ADDRESS.SPIN_PROTOCOL);
const UniversalDB = CONTRACT.get(METADATA.ABI.UNIVERSAL_DB, METADATA.ADDRESS.UNIVERSAL_DB);
const CampaignDB = CONTRACT.get(METADATA.ABI.CAMPAIGN_DB, METADATA.ADDRESS.CAMPAIGN_DB);
const RevenueLedgerDB = CONTRACT.get(METADATA.ABI.REVENUE_LEDGER_DB, METADATA.ADDRESS.REVENUE_LEDGER_DB);
const IERC20 = CONTRACT.get(METADATA.ABI.IERC20, METADATA.ADDRESS.IERC20);

const revenueTestData = { 
  _revenue : 10000,
  _spinRatio : 10,  
  _marketPrice : 2050, // (market price * 100)
  _rounding : 2
}

const registerContractToProxy = async (signer, contractName, contractAddr) => {
  await go(
    CONTRACT.write(signer, Proxy, 'addContract(string,address)', { name: contractName, addr: contractAddr }),
    txReceipt => log('\r  -> Tx Hash:', txReceipt.transactionHash)
  )
}

const updateContractToProxy = async (signer, contractName, contractAddr) => {
  await go(
    CONTRACT.write(signer, Proxy, 'updateContract(string,address)', { name: contractName, addr: contractAddr }),
    txReceipt => log('\r  -> Tx Hash:', txReceipt.transactionHash)
  )
}

const getContract = async (name) =>
  await CONTRACT.read(Proxy, 'getContract(string)', { name })
    .then(addr => UTILS.toChecksumAddress(addr))
    .catch(e => undefined)

const setProxyFor = async (signer, contract) => {
  await go(
    CONTRACT.write(signer, contract, 'setProxy(address)', { _proxy: METADATA.ADDRESS.PROXY }),
    txReceipt => log('\r  -> Tx Hash:', txReceipt.transactionHash)
  )
}

const getProxy = async (contract) => await contract.methods.proxy().call().then(addr => UTILS.toChecksumAddress(addr)).catch(e => undefined)

const setDataStore = async (signer,a) => {
  await go(
    CONTRACT.write(signer, SpinProtocol, 'setDataStore(address,address)', { 
      _campaignDB: METADATA.ADDRESS.CAMPAIGN_DB,
      _revenueLedgerDB: METADATA.ADDRESS.REVENUE_LEDGER_DB
    }),
    txReceipt => log('\r  -> Tx Hash:', txReceipt.transactionHash)
    )
}

const getDataStore = async () => {
  let addr = {};
  addr.campaignDB = await SpinProtocol.methods.campaignDB().call().then(addr => UTILS.toChecksumAddress(addr)).catch(e => log(e.message));
  addr.revenueLedgerDB = await SpinProtocol.methods.revenueLedgerDB().call().then(addr => UTILS.toChecksumAddress(addr)).catch(e => undefined);
  return addr;
}

const deposit = async (signer, value) => await go(
  CONTRACT.write(signer, IERC20, 'transfer(address,uint256)', {to : METADATA.ADDRESS.SPIN_PROTOCOL, value}),
  txReceipt => log('\r  -> Tx Hash:', txReceipt.transactionHash)
);

const testDeposit = async (signer, revenueData) => {
  log(revenueData);
  let amt = await CONTRACT.read(SpinProtocol, 'revenueSpin(uint256,uint256,uint256,uint256)', revenueData);
  log(`\r* amount : ${UTILS.fromKLAY(amt)} SPIN`)
  await deposit(signer, amt);
}

const addAdmin = async (signer, contract, adminAddr) => {
  await go(
    CONTRACT.write(signer, contract, 'addAdmin(address)', {account : adminAddr}),
    txReceipt => log('\n\r> Tx receipt:', txReceipt)
  )
}

const spinProtocol_sendToken = async (signer, contractAddr, toAddr, amt) => 
  await go(
    UTILS.fnSignature('sendToken(address,uint256)'),
    val => val + UTILS.encodeParameters(['address','uint256'],[toAddr,amt]).substring(2),
    data => ACCOUNTS.signTx(
      {from : signer.address, to : contractAddr, data : data, type : "FEE_DELEGATED_SMART_CONTRACT_EXECUTION", gas: 200000, value : 0}, 
      signer.privateKey
    ),
    signData => KLAY.sendRawTxFeeDelegated(signData.rawTransaction, signer),
    txReceipt => log('\n\r> TokenBalance send - Tx receipt:', txReceipt.transactionHash)
  )


const getBalance = async (address) => 
  await go(
    CONTRACT.get(METADATA.ABI.SPIN_PROTOCOL, address),
    contract => contract.methods.getBalance().call()
  )

const createSigner = privateKey => go(
  ACCOUNTS.access(privateKey),
  WALLET.connect
)

// ==============================================================================================================

const initialize = async _ => {
  /************** Create signer **************/
  // const Signer = await createSigner(credentials.klaytn.privateKey.baobab); // process.env.KLAYTN_ADMIN_PRIVATE_KEY
  const Signer = await match(process.env.NETWORK)
    .case(network => network == 'cypress')(
      _=> createSigner(credentials.klaytn.privateKey.cypress)
    )
    .case(network => network == 'baobab')(
      _=> createSigner(credentials.klaytn.privateKey.baobab)
    )
    .else(_=>_);
  
  /************** Add system contracts to `Proxy` contract **************/
  log('\n\r>> Scan for system contracts that are not registered with the proxy...');

  let scanContract = ['SPIN_PROTOCOL', 'UNIVERSAL_DB', 'CAMPAIGN_DB', 'REVENUE_LEDGER_DB', 'IERC20'];

  let addresses = go(
      METADATA.ADDRESS,
      pick(scanContract),
      valuesL,
      takeAll
    );

  let names = go(
    METADATA.NAME,
    pick(scanContract),
    valuesL,
    takeAll
  );
 
  let getContractcheck = await go(addresses, addr => merge(names, addr))

  await go(
    getContractcheck,
    map(async contract => {
      contract[0] = contract[0] === 'IERC20' ? 'Token' : contract[0];
      let setupAddr = await getContract(contract[0]);
      let realAddr = UTILS.toChecksumAddress(contract[1]);

      await match(setupAddr)
        .case(setup => setup === undefined)(async _ =>{
          log(`\n\r [${contract[0]}] add`)
          await registerContractToProxy(Signer, contract[0], contract[1])
        })
        .case(setup => setup !== realAddr)(async addr => {
          log(`\n\r [${contract[0]}] update`)
          if(contract[0] === "SpinProtocol") {
            await go(
              getBalance(addr),
              amt => spinProtocol_sendToken(Signer, addr, contract[1], amt)
            )
          }
          await updateContractToProxy(Signer, contract[0], contract[1])
        })
        .else(_ => false)
    })
  )


  // /************** Set Proxy contract address for system contracts **************/
  log('\n\r>> Scan for system contracts and Setting Proxy...');

  let getProxycheck = [SpinProtocol, UniversalDB, CampaignDB, RevenueLedgerDB];
  await go(
    getProxycheck,
    map(async contract => {
      let setupAddr = await getProxy(contract);
      let realAddr = UTILS.toChecksumAddress(METADATA.ADDRESS.PROXY);

      if(setupAddr !== realAddr){
        log(`\n\r [${contract._address}]`)
        await setProxyFor(Signer, contract)
      }
    })
  )


  /************** Initialize system logic contracts **************/
  log('\n\r>> Initializing system logic contracts...');

  let dataStore = await getDataStore();
  await match(dataStore)
    .case(a => a.campaignDB !== UTILS.toChecksumAddress(METADATA.ADDRESS.CAMPAIGN_DB))(_ => setDataStore(Signer))
    .case(a => a.revenueLedgerDB !== UTILS.toChecksumAddress(METADATA.ADDRESS.REVENUE_LEDGER_DB))(_ => setDataStore(Signer))
    .else(_ => false)
  

  log('\n\r\n\r***** Initialization has been completed successfully. *****\n\r\n\r');
  
  /************** Revenue share **************/
  // let argv = process.argv;
  // log(`\n\r>> Token Deposit...  type : ${argv[2]}`);

  // await match(argv[2])
  //   .case(a => a !== undefined && a === 'test' )(a => testDeposit(Signer,revenueTestData))
  //   .case(a => a !== undefined)(a => deposit(Signer, UTILS.toKLAY(a)))
  //   .else(_ => false)
}


(async function() {
  try {
    await initialize();
  } catch (e) {
    log('System initialization has been stopped due to the following error:\n\r', e);
  }
})();