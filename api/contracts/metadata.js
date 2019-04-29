export const SPIN_PROTOCOL_PROXY_CONTRACT_INTERFACE = [
  'function token() public view returns(address)',
  'function wallet() public view returns(address)',
  'function rate() public view returns(uint256)',
  'function weiRaised() public view returns (uint256)',
  'function isAdmin(address account) public view returns (bool)',
  'function isWhitelisted(address account) public view returns (bool)',
  'function isActive() public view returns (bool)',
  'function isTotalSaleCapReached() public view returns (bool)',
  'function phaseStartTime() public view returns (uint256)',
  'function phaseEndTime() public view returns (uint256)',
  'function phaseBonusRate() public view returns (uint256)',
  'function phaseIndex() public view returns (uint256)',
  'function getTotalSaleCap() public view returns (uint256)',
  'function getIndividualCaps() public view returns (uint256, uint256)',
  'function getContribution(address beneficiary) public view returns (uint256)',
  'function setPhase(uint256 purchaseRate, uint256 startTime, uint256 endTime, uint256 bonusRate) public',
  'function setIndividualCaps(uint256 minCap, uint256 maxCap) external',
  'function addAdmin(address account) public',
  'function renounceAdmin() public',
  'function addToWhitelist(address account) public',
  'function addWhitelist(address[] accounts) external',
  'function removeFromWhitelist(address account) public',
  'function withdrawEther(uint256 amount) public',
  'function withdrawToken(uint256 amount) public',
  'function setTotalSaleCap(uint256 totalSaleCap) external',
  'function setWallet(address wallet) public',
  'function setLockPeriods(uint256[] periods) external',
  'function vestDedicatedTokens(address[] dedicatedAccounts, uint256[] dedicatedTokens) external',
  'function deliverPurchasedTokensManually(address[] beneficiaries, uint256[] tokenAmounts, uint256[] bonusAmounts, uint256 bonusExpiry) external',
  'function releaseTokens(address[] accounts) external',
  'function lock(address[] to, bytes32[] reason, uint256[] amount, uint256[] time) public',
  'function increaseLockAmount(address to, bytes32 reason, uint256 amount) public',
  'function adjustLockPeriod(address to, bytes32 reason, uint256 time) public',
  'function unlock(address _of) public returns (uint256 unlockableTokens)',
  'function getTotalLockedAmount() public view returns (uint256)',
  'function getTotalLockedTokens(address _of) public view returns (uint256)',
  'function getUnlockableTokens(address _of) public view returns (uint256)',
  'function tokensLockedAtTime(address _of, bytes32 reason, uint256 time) public view returns (uint256)',
  'function lockReason(address _of, uint256 index) public view returns (bytes32)',
  'function locked(address _of, bytes32 reason) public view returns (uint256, uint256, bool)',
  'function getLockDetails(address lockee) public view returns (bytes32[], uint256[], uint256[], bool[])'
];

export const ESCROW_PROXY_CONTRACT_INTERFACE = [
  'function name() public view returns(string)',
  'function symbol() public view returns(string)',
  'function decimals() public view returns(uint8)',
  'function balanceOf(address owner) view returns (uint)',
  'function totalSupply() public view returns (uint256)',
  'function allowance(address owner, address spender) public view returns (uint256)',
  'function approve(address spender, uint256 value) public returns (bool)',
  'function transfer(address to, uint256 amount) public returns (bool)',
  'function transferFrom(address from, address to, uint256 value) public returns (bool)',
  'function paused() public view returns(bool)',
  'function pause() public',
  'function unpause() public',
  'function mint(address to, uint256 value) public returns (bool)',
  'function burn(uint256 value) public',
  'function burnFrom(address from, uint256 value) public',
  'event Transfer(address indexed from, address indexed to, uint256 amount)',
  'event Approval(address indexed owner, address indexed spender, uint256 value)'
];

export const PROXY_CONTRACT_INTERFACE = [
  'function setUniversalDB(UniversalDB universalDB) public',
  'function doesItemExist(uint256 primaryIndex) public view returns (bool)',
];

export const ACTOR_DB_CONTRACT_INTERFACE = [];
export const CAMPAIGN_DB_CONTRACT_INTERFACE = [];
export const DEAL_DB_CONTRACT_INTERFACE = [];
export const PRODUCT_DB_CONTRACT_INTERFACE = [];
export const PURCHASE_DB_CONTRACT_INTERFACE = [];
export const UNIVERSAL_DB_CONTRACT_INTERFACE = [];

// System contracts
export const ESCROW_PROXY_CONTRACT_NAME = 'EscrowProxy';
export const SPIN_PROTOCOL_PROXY_CONTRACT_NAME = 'SpinCProtocolProxy';
export const PROXY_CONTRACT_NAME = 'Proxy';
// Database Contracts
export const ACTOR_DB_CONTRACT_NAME = 'ActorDB';
export const CAMPAIGN_DB_CONTRACT_NAME = 'CampaignDB';
export const DEAL_DB_CONTRACT_NAME = 'DealDB';
export const PRODUCT_DB_CONTRACT_NAME = 'ProductDB';
export const PURCHASE_DB_CONTRACT_NAME = 'PurchaseDB';
export const UNIVERSAL_DB_CONTRACT_NAME = 'UniversalDB';