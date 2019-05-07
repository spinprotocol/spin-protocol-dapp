const { Wallet, getDefaultProvider, utils } = require('ethers');
const GenericAPI = require('../../api/contracts/genericApi');
const credentials = require('../../credentials.json');

const ProxyArtifact = require('../../build/contracts/Proxy.json');
const SpinProtocolArtifact = require('../../build/contracts/SpinProtocol.json');
const EscrowArtifact = require('../../build/contracts/EscrowAndFees.json');
const UniversalDBArtifact = require('../../build/contracts/UniversalDB.json');
const ActorDBArtifact = require('../../build/contracts/ActorDB.json');
const CampaignDBArtifact = require('../../build/contracts/CampaignDB.json');
const DealDBArtifact = require('../../build/contracts/DealDB.json');
const ProductDBArtifact = require('../../build/contracts/ProductDB.json');
const PurchaseDBArtifact = require('../../build/contracts/PurchaseDB.json');
const MockSpinTokenArtifact = require('../../build/contracts/MockSpinToken.json');

const NETWORK = 'baobab'; // `ropsten` or `baobab` for test networks (for ethereum and klaytn respectively)

// FIXME: Normally we can get contract's address for the network where it's deployed from the atrifact file (./build/contracts/<...>.json)
// Switch between deployed contract's addresses for the test networks defined above
const SPIN_TOKEN_ADDRESS = NETWORK === 'baobab'
  ? '0x91d47fe9c5d892851060d6db6b31d264bb8a4d1b'
  : '0x7ece7ebea80de3f16e3c0a36b49739ccf17978ba';

const SPIN_PROTOCOL_ADDRESS = NETWORK === 'baobab'
  ? ''
  : '0xE82A2c82E4458bab5E69aD0cDcd564d4813c463e';

const ESCROW_AND_FEES_ADDRESS = NETWORK === 'baobab'
  ? ''
  : '0x922a7B83FB435A924dF429Af01B49C13D95e3FBA';

const PROXY_ADDRESS = NETWORK === 'baobab'
  ? ''
  : '0x5f10F5D3103bE9352809be96b37AAB83b4C6A2cb';

const UNIVERSAL_DB_ADDRESS = NETWORK === 'baobab'
  ? ''
  : '0x063e305760C4cefCa3839C8ac2083E374Eae2780';

const UNIVERSAL_DB_ADDRESS = NETWORK === 'baobab'
  ? ''
  : '0x063e305760C4cefCa3839C8ac2083E374Eae2780';


function createSignerFromMnemonics(mnemonics, network) {
  return Wallet.fromMnemonic(mnemonics).connect(getDefaultProvider(network));
}

function createSignerFromPrivateKey(privateKey, network) {
  return new Wallet(privateKey).connect(getDefaultProvider(network));
}

async function SystemInitialization() {
  // Transaction signer(wallet) which also includes default provider for the given network
  const Signer = createSignerFromPrivateKey(credentials.privateKey[NETWORK], NETWORK);

  // Contract API instances
  const Proxy = GenericAPI.getContractByInterface(Signer, ProxyArtifact.abi, PROXY_ADDRESS);
  const SpinProtocol = GenericAPI.getContractByInterface(Signer, SpinProtocolArtifact.abi, SPIN_PROTOCOL_ADDRESS);
  const EscrowAndFees = GenericAPI.getContractByInterface(Signer, EscrowArtifact.abi, ESCROW_AND_FEES_ADDRESS);
  const UniversalDB = GenericAPI.getContractByInterface(Signer, UniversalDBArtifact.abi, UNIVERSAL_DB_ADDRESS);
  const SpinToken = GenericAPI.getContractByInterface(Signer, MockSpinTokenArtifact.abi, SPIN_TOKEN_ADDRESS);

  // Balance query for both native token and ERC20 compliant tokens
  let nativeBalance = await GenericAPI.getNativeBalance(getDefaultProvider(NETWORK), Signer.address);
  let tokenBalance = await GenericAPI.getTokenBalance(SpinToken, Signer.address, {format: true, decimals: 18});
  console.log(`Native Balance:\t${nativeBalance} ETH\n\rToken Balance:\t${tokenBalance} SPIN`);

  // Send tx to SpinToken contract. Function call for `transfer(to: address, value: uint256)`.
  // Parameter names for the function call should match the names in abi for that function.
  let receipt = await GenericAPI.writeContract(SpinToken, 'transfer', { to: Signer.address, value: '10' });
  console.log('Tx receipt:', receipt);

  // Add system contracts to `Proxy` contract
  receipt = await GenericAPI.writeContract(Proxy, 'addContract', { name: SpinProtocolArtifact.contractName, addr: SPIN_PROTOCOL_ADDRESS });
  console.log('Tx receipt:', receipt);
  receipt = await GenericAPI.writeContract(Proxy, 'addContract', { name: EscrowArtifact.contractName, addr: ESCROW_AND_FEES_ADDRESS });
  console.log('Tx receipt:', receipt);
  receipt = await GenericAPI.writeContract(Proxy, 'addContract', { name: UniversalDBArtifact.contractName, addr: UNIVERSAL_DB_ADDRESS });
  console.log('Tx receipt:', receipt);
}


(async function() {
  await SystemInitialization();
})();

