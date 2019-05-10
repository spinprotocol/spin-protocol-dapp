const { Wallet, getDefaultProvider } = require('ethers');
const GenericAPI = require('../api/contracts/genericApi');

const credentials = require('../credentials.json');
const AddressMap = require('./address-map.json');
const ProxyArtifact = require('../build/contracts/Proxy.json');
const SpinProtocolArtifact = require('../build/contracts/SpinProtocol.json');
const EscrowArtifact = require('../build/contracts/EscrowAndFees.json');
const UniversalDBArtifact = require('../build/contracts/UniversalDB.json');
const ActorDBArtifact = require('../build/contracts/ActorDB.json');
const CampaignDBArtifact = require('../build/contracts/CampaignDB.json');
const DealDBArtifact = require('../build/contracts/DealDB.json');
const ProductDBArtifact = require('../build/contracts/ProductDB.json');
const PurchaseDBArtifact = require('../build/contracts/PurchaseDB.json');
const SpinTokenArtifact = require('../build/contracts/MockSpinToken.json');

const NETWORK = process.env.NETWORK;

// FIXME: Normally we can get contract's address for the network where it's deployed from the atrifact file (./build/contracts/<...>.json)
// Get addresss of the deployed contracts for the given network
const SPIN_TOKEN_ADDRESS = AddressMap[NETWORK].SpinToken;
const SPIN_PROTOCOL_ADDRESS = AddressMap[NETWORK].SpinProtocol;
const ESCROW_AND_FEES_ADDRESS = AddressMap[NETWORK].EscrowAndFees;
const PROXY_ADDRESS = AddressMap[NETWORK].Proxy;
const UNIVERSAL_DB_ADDRESS = AddressMap[NETWORK].UniversalDB;
const ACTOR_DB_ADDRESS = AddressMap[NETWORK].ActorDB;
const CAMPAIGN_DB_ADDRESS = AddressMap[NETWORK].CampaignDB;
const DEAL_DB_ADDRESS = AddressMap[NETWORK].DealDB;
const PRODUCT_DB_ADDRESS = AddressMap[NETWORK].ProductDB;
const PURCHASE_DB_ADDRESS = AddressMap[NETWORK].PurchaseDB;


function isEqual(addressA, addressB) {
  if (typeof(addressA) !== 'string' || typeof(addressB) !== 'string') { return false; }
  return addressA.toLowerCase() === addressB.toLowerCase();
}

function createSignerFromMnemonics(mnemonics, network) {
  return Wallet.fromMnemonic(mnemonics).connect(getDefaultProvider(network));
}

function createSignerFromPrivateKey(privateKey, network) {
  return new Wallet(privateKey).connect(getDefaultProvider(network));
}

async function registerContractToProxy(proxy, contractAddr, contractName) {
  let registeredAddr = await GenericAPI.readContract(proxy, 'getContract', { name: contractName });

  if (isEqual(registeredAddr, contractAddr)) {
    console.log(`> ${contractName} contract version is same. Skipping registration...`);
    return;
  }

  console.log(`> Registering ${contractName} to Proxy...`);
  let receipt = await GenericAPI.writeContract(proxy, 'addContract', { name: contractName, addr: contractAddr });
  console.log('\n\r> Tx receipt:', receipt);
  console.log('\n\r');
}

async function setProxyFor(contract, contractName, proxyAddr) {
  let registeredProxy = await GenericAPI.readContract(contract, 'proxy');

  if (isEqual(registeredProxy, proxyAddr)) {
    console.log(`> Proxy contract version is same for ${contractName}. Skipping proxy registration...`);
    return;
  }

  console.log(`> Setting proxy for ${contractName}`);
  let receipt = await GenericAPI.writeContract(contract, 'setProxy', { _proxy: proxyAddr });
  console.log('\n\r> Tx receipt:', receipt);
  console.log('\n\r');
}

async function setDataStore(spinProtocol) {
  let actorDB = await GenericAPI.readContract(spinProtocol, 'actorDB');
  let campaignDB = await GenericAPI.readContract(spinProtocol, 'campaignDB');
  let dealDB = await GenericAPI.readContract(spinProtocol, 'dealDB');
  let productDB = await GenericAPI.readContract(spinProtocol, 'productDB');
  let purchaseDB = await GenericAPI.readContract(spinProtocol, 'purchaseDB');

  if (isEqual(actorDB, ACTOR_DB_ADDRESS)
    && isEqual(campaignDB, CAMPAIGN_DB_ADDRESS)
    && isEqual(dealDB, DEAL_DB_ADDRESS)
    && isEqual(productDB, PRODUCT_DB_ADDRESS)
    && isEqual(purchaseDB, PURCHASE_DB_ADDRESS)
  ) {
    console.log('> Data store contract versions set for SpinProtocol are same. Skipping data store registration...');
    return;
  }

  console.log('> Setting db contracts for SpinProtocol');
  let receipt = await GenericAPI.writeContract(
    spinProtocol, 
    'setDataStore', 
    {
      _actorDB: ACTOR_DB_ADDRESS,
      _campaignDB: CAMPAIGN_DB_ADDRESS,
      _dealDB: DEAL_DB_ADDRESS,
      _productDB: PRODUCT_DB_ADDRESS,
      _purchaseDB: PURCHASE_DB_ADDRESS
    }
  );
  console.log('\n\r> Tx receipt:', receipt);
  console.log('\n\r');
}

async function setEscrow(spinProtocol) {
  let registeredEscrow = await GenericAPI.readContract(spinProtocol, 'escrow');

  if (isEqual(registeredEscrow, ESCROW_AND_FEES_ADDRESS)) {
    console.log('> Escrow contract version set for SpinProtocol is same. Skipping escrow registration...');
    return
  }

  console.log('> Setting escrow for SpinProtocol');
  let receipt = await GenericAPI.writeContract(spinProtocol, 'setEscrow', { _escrow: ESCROW_AND_FEES_ADDRESS });
  console.log('\n\r\> Tx receipt:', receipt);
  console.log('\n\r');
}

async function initializeSpinProtocol(spinProtocol) {
  await setEscrow(spinProtocol);
  await setDataStore(spinProtocol);
}

async function initializeEscrowAndFees(proxy, escrow) {
  let registeredToken = await GenericAPI.readContract(escrow, 'token');
  if (isEqual(registeredToken, SPIN_TOKEN_ADDRESS)) {
    console.log('> ERC20 token set for EscrowAndFees is same. Skipping token registration...');
    return;
  }

  console.log('> Setting ERC20 Token for EscrowAndFees');
  // We set token through Proxy contract because direct access to functions of EscrowAndFees contract is not allowed
  let receipt = await GenericAPI.writeContract(proxy, 'setToken', { _token: SPIN_TOKEN_ADDRESS });
  console.log('\n\r> Tx receipt:', receipt);
}

async function initialize() {
  // Transaction signer(wallet) which also includes default provider for the given network
  const Signer = createSignerFromPrivateKey(credentials.privateKey[NETWORK], NETWORK);


  // Create contract API instances for the deployed contracts
  const Proxy = GenericAPI.getContractByInterface(Signer, ProxyArtifact.abi, PROXY_ADDRESS);
  const SpinProtocol = GenericAPI.getContractByInterface(Signer, SpinProtocolArtifact.abi, SPIN_PROTOCOL_ADDRESS);
  const EscrowAndFees = GenericAPI.getContractByInterface(Signer, EscrowArtifact.abi, ESCROW_AND_FEES_ADDRESS);
  const UniversalDB = GenericAPI.getContractByInterface(Signer, UniversalDBArtifact.abi, UNIVERSAL_DB_ADDRESS);
  const ActorDB = GenericAPI.getContractByInterface(Signer, ActorDBArtifact.abi, ACTOR_DB_ADDRESS);
  const CampaignDB = GenericAPI.getContractByInterface(Signer, CampaignDBArtifact.abi, CAMPAIGN_DB_ADDRESS);
  const DealDB = GenericAPI.getContractByInterface(Signer, DealDBArtifact.abi, DEAL_DB_ADDRESS);
  const ProductDB = GenericAPI.getContractByInterface(Signer, ProductDBArtifact.abi, PRODUCT_DB_ADDRESS);
  const PurchaseDB = GenericAPI.getContractByInterface(Signer, PurchaseDBArtifact.abi, PURCHASE_DB_ADDRESS);
  const SpinToken = GenericAPI.getContractByInterface(Signer, SpinTokenArtifact.abi, SPIN_TOKEN_ADDRESS);


  // Balance query for both native token and ERC20 compliant tokens
  let nativeBalance = await GenericAPI.getNativeBalance(getDefaultProvider(NETWORK), Signer.address);
  let tokenBalance = await GenericAPI.getTokenBalance(SpinToken, Signer.address, {format: true, decimals: 18});
  console.log(`Native Balance:\t${nativeBalance} ETH\n\rToken Balance:\t${tokenBalance} SPIN`);
  

  /************** Add system contracts to `Proxy` contract **************/
  console.log('\n\r>> Registering system contracts to Proxy...\n\r');

  // Function calls (transactions and calls) can be done in two ways
  // 1. We can directly call them from the contract instance as follows

  // Get contract address to check if there is already a registered contract with the same name. 
  // Notice that this will not cost any ether/klay, because it's a call which does not change state of the data in the contract.
  let address = await Proxy.getContract(SpinProtocolArtifact.contractName);
  // If there is no registered contract with the given contract name (`SpinProtocolArtifact.contractName`),
  // then register this contract to Proxy contract
  if (!isEqual(address, SPIN_PROTOCOL_ADDRESS)) {
    console.log('> Registering SpinProtocol to Proxy...');
    // Notice that this is a transaction which will change the state of the contract, therefore it will cost some ether/klay
    // And as you see, we can override gas price and gas limit for the transaction. However it's not neccessarily needed,
    // because if we don't override gas price and limit, the avarage of the last few blocks (for Ethereum)/the fixed (for Klaytn)
    // for gas price and gas estimate for gas limit will be used by default. Gas price value should be in wei.
    let response = await Proxy.addContract(SpinProtocolArtifact.contractName, SPIN_PROTOCOL_ADDRESS, {gasPrice: '0x77359400'});
    console.log('\n\r> Response', response);
    // Wait until tx is mined. Confirmation number can be passed `wait()` 
    // to make sure that the transaction is forged enough. Default is 1.
    let receipt = await response.wait();
    console.log('\n\r> Receipt', receipt);
  } else {
    console.log('> SpinProtocol contract version is same. Skipping registration...');
  }

  // 2. Or we can use GenericAPI to call function with its name and parameters.
  // Difference between 1. and 2. is that GenericAPI provides extra output formatting and error handling to relieve front-end burden.

  // Get contract address to check if there is already a registered contract with the same name. 
  // Notice that this will not cost any ether/klay, because it's a call which does not change state of the data in the contract.
  address = await GenericAPI.readContract(Proxy, 'getContract', { name: EscrowArtifact.contractName });
  // If there is no registered contract with the given contract name (`SpinProtocolArtifact.contractName`),
  // then register this contract to Proxy contract
  if (!isEqual(address, ESCROW_AND_FEES_ADDRESS)) {
    console.log('> Registering EscrowAndFees to Proxy...');
    // Same as above, this will cost ether/klay and gas price and limit can be override.
    // If gas limit and price are not override, the defaults will be used as explained above.
    // This will wait until the tx is mined. Gas price value should be in gwei in contrast the above which was wei
    let receipt = await GenericAPI.writeContract(
      Proxy, 
      'addContract', 
      { name: EscrowArtifact.contractName, addr: ESCROW_AND_FEES_ADDRESS }, 
      {
        gasPrice: '10',
        gasLimit: 100000,
        confirmations: 2
      }
    );
    console.log('\n\r>Tx receipt:', receipt);
  } else {
    console.log('> EscrowAndFees contract version is same. Skipping registration...');
  }

  // These are just the same implementation as the second one
  await registerContractToProxy(Proxy, UNIVERSAL_DB_ADDRESS, UniversalDBArtifact.contractName);
  await registerContractToProxy(Proxy, ACTOR_DB_ADDRESS, ActorDBArtifact.contractName);
  await registerContractToProxy(Proxy, CAMPAIGN_DB_ADDRESS, CampaignDBArtifact.contractName);
  await registerContractToProxy(Proxy, DEAL_DB_ADDRESS, DealDBArtifact.contractName);
  await registerContractToProxy(Proxy, PRODUCT_DB_ADDRESS, ProductDBArtifact.contractName);
  await registerContractToProxy(Proxy, PURCHASE_DB_ADDRESS, PurchaseDBArtifact.contractName);

  /************** Set Proxy contract address for system contracts **************/
  console.log('\n\r>> Setting Proxy for system contracts...\n\r');
  await setProxyFor(SpinProtocol, SpinProtocolArtifact.contractName, PROXY_ADDRESS);
  await setProxyFor(EscrowAndFees, EscrowArtifact.contractName, PROXY_ADDRESS);
  await setProxyFor(UniversalDB, UniversalDBArtifact.contractName, PROXY_ADDRESS);
  await setProxyFor(ActorDB, ActorDBArtifact.contractName, PROXY_ADDRESS);
  await setProxyFor(CampaignDB, CampaignDBArtifact.contractName, PROXY_ADDRESS);
  await setProxyFor(DealDB, DealDBArtifact.contractName, PROXY_ADDRESS);
  await setProxyFor(ProductDB, ProductDBArtifact.contractName, PROXY_ADDRESS);
  await setProxyFor(PurchaseDB, PurchaseDBArtifact.contractName, PROXY_ADDRESS);

  /************** Initialize system logic contracts **************/
  console.log('\n\r>> Initializing system logic contracts...\n\r');
  await initializeSpinProtocol(SpinProtocol);
  await initializeEscrowAndFees(Proxy, EscrowAndFees);


  console.log('\n\r\n\r*** Initialization has been completed successfully. ***\n\r\n\r');
}

(async function() {
  try {
    await initialize();
  } catch (e) {
    console.log('System initialization has been stopped due to the following error:\n\r', e);
  }
})();

