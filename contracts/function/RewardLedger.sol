pragma solidity ^0.4.24;

import "../libs/SafeMath.sol";
import "../components/token/TokenControl.sol";
import './DataControl.sol'; 
import './TokenUtil.sol'; 

/**
 * @title RewardLedgerDB
 * @dev Manages reward ledger storage
 * CONTRACT_NAME = "RewardLedger"
 * TABLE_KEY = keccak256(abi.encodePacked("Table"))
 */
contract RewardLedger is DataControl, TokenControl, TokenUtil {
  using SafeMath for uint256;

  event RewardLedgerCreated(uint256 indexed rewardLedgerId);
  event RewardLedgerUpdated(uint256 indexed rewardLedgerId, uint256 updatedAt);

  function createRewardLedger(
    uint256 rewardLedgerId,
    uint256 campaignId,
    uint256 influencerId,
    uint256 samplePrice,
    uint256 rewardPrice,
    uint256 profit,
    uint256 rewardRatio,
    uint256 spinRatio,
    uint256 fiatRatio
  )
    public
    onlyAdmin
  {
    string memory CONTRACT_NAME = "RewardLedger";
    bytes32 TABLE_KEY = keccak256(abi.encodePacked("Table"));

    require(rewardLedgerId > 0, "RewardLedger : rewardLedgerId cannot be 0");
    require(campaignId > 0, "RewardLedger : campaignId cannot be 0");
    require(pushNodeToLinkedList(CONTRACT_NAME, TABLE_KEY, rewardLedgerId), "RewardLedger : Item already exists");

    setUintStorage(CONTRACT_NAME, keccak256(abi.encodePacked(rewardLedgerId, "campaignId")), campaignId);
    setUintStorage(CONTRACT_NAME, keccak256(abi.encodePacked(rewardLedgerId, "influencerId")), influencerId);
    setUintStorage(CONTRACT_NAME, keccak256(abi.encodePacked(rewardLedgerId, "samplePrice")), samplePrice);
    setUintStorage(CONTRACT_NAME, keccak256(abi.encodePacked(rewardLedgerId, "rewardPrice")), rewardPrice);
    setUintStorage(CONTRACT_NAME, keccak256(abi.encodePacked(rewardLedgerId, "profit")), profit);
    setUintStorage(CONTRACT_NAME, keccak256(abi.encodePacked(rewardLedgerId, "rewardRatio")), rewardRatio);
    setUintStorage(CONTRACT_NAME, keccak256(abi.encodePacked(rewardLedgerId, "spinRatio")), spinRatio);
    setUintStorage(CONTRACT_NAME, keccak256(abi.encodePacked(rewardLedgerId, "fiatRatio")), fiatRatio);
    setBoolStorage(CONTRACT_NAME, keccak256(abi.encodePacked(rewardLedgerId, "isAccount")), false);

    emit RewardLedgerCreated(rewardLedgerId);
  }

  function updateIsAccount(
    uint256 rewardLedgerId,
    bool state
  )
    public
    onlyAdmin
    onlyExistentItem("RewardLedger", rewardLedgerId)
  {
    string memory CONTRACT_NAME = "RewardLedger";
    setBoolStorage(CONTRACT_NAME, keccak256(abi.encodePacked(rewardLedgerId, "isAccount")), state);
    emit RewardLedgerUpdated(rewardLedgerId, now);
  }

  function deleteRewardLedger(
    uint256 rewardLedgerId
  )
    public
    onlyAdmin
    onlyExistentItem("RewardLedger", rewardLedgerId)
  {
    string memory CONTRACT_NAME = "RewardLedger";
    bytes32 TABLE_KEY = keccak256(abi.encodePacked("Table"));

    require(removeNodeFromLinkedList(CONTRACT_NAME, TABLE_KEY, rewardLedgerId), "RewardLedger : Item does not exist");

    emit RewardLedgerUpdated(rewardLedgerId, now);
  }

  function getRewardLedger(
    uint256 rewardLedgerId
  )
    public
    onlyExistentItem("RewardLedger", rewardLedgerId)
    view returns (
      uint256 campaignId,
      uint256 influencerId,
      uint256 samplePrice,
      uint256 rewardPrice,
      uint256 profit,
      uint256 rewardRatio,
      uint256 spinRatio,
      uint256 fiatRatio,
      bool isAccount
    )
  {
    string memory CONTRACT_NAME = "RewardLedger";
    campaignId = getUintStorage(CONTRACT_NAME, keccak256(abi.encodePacked(rewardLedgerId, "campaignId")));
    influencerId = getUintStorage(CONTRACT_NAME, keccak256(abi.encodePacked(rewardLedgerId, "influencerId")));
    samplePrice = getUintStorage(CONTRACT_NAME, keccak256(abi.encodePacked(rewardLedgerId, "samplePrice")));
    rewardPrice = getUintStorage(CONTRACT_NAME, keccak256(abi.encodePacked(rewardLedgerId, "rewardPrice")));
    profit = getUintStorage(CONTRACT_NAME, keccak256(abi.encodePacked(rewardLedgerId, "profit")));
    rewardRatio = getUintStorage(CONTRACT_NAME, keccak256(abi.encodePacked(rewardLedgerId, "rewardRatio")));
    spinRatio = getUintStorage(CONTRACT_NAME, keccak256(abi.encodePacked(rewardLedgerId, "spinRatio")));
    fiatRatio = getUintStorage(CONTRACT_NAME, keccak256(abi.encodePacked(rewardLedgerId, "fiatRatio")));
    isAccount = getBoolStorage(CONTRACT_NAME, keccak256(abi.encodePacked(rewardLedgerId, "isAccount")));
  }

  function getRewardLedgerList()
    public
    view
    returns (uint256[] memory)
  {
    string memory CONTRACT_NAME = "RewardLedger";
    bytes32 TABLE_KEY = keccak256(abi.encodePacked("Table"));
    return getNodes(CONTRACT_NAME, TABLE_KEY);
  }

  /**
  * @dev Token transfer after calculates.
  */
  function rewardShare(
      uint256 _rewardLedgerId,
      address _to,
      uint256 _tokenAmount,
      uint256 _marketPrice,
      uint256 _rounding
  ) public onlyAdmin {
      uint256 campaignId;
      bool isAccount;
      (campaignId,,,,,,,,isAccount) = getRewardLedger(_rewardLedgerId);
      require(campaignId > 0 && !isAccount, "Empty data or already share");

      uint256 token = calculateToken(_tokenAmount, _marketPrice, _rounding);
      _sendToken("SPIN", _to, token);
      updateIsAccount(_rewardLedgerId, true);
  }
}