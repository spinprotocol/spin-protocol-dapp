pragma solidity ^0.4.24;

import "./AbstractDB.sol";
import "../components/system/Proxied.sol";
import "../libs/SafeMath.sol";

/**
 * @title PurchaseDB
 * @dev Manages purchase storage
 */
contract PurchaseDB is AbstractDB, Proxied {
  using SafeMath for uint256;

  bytes32 private constant TABLE_KEY_CAMPAIGN = keccak256(abi.encodePacked("CampaignTable"));
  bytes32 private constant TABLE_KEY_PURCHASE = keccak256(abi.encodePacked("PurchaseTable"));

  event PurchaseAdd(uint256 indexed campaignId, uint256 updatedAt);
  event PurchaseSub(uint256 indexed campaignId, uint256 updatedAt);
  event PurchaseReset(uint256 indexed campaignId, uint256 resetAt);

  constructor(Proxy _proxy, UniversalDB _universalDB) public Proxied(_proxy) {
    setUniversalDB(_universalDB);
  }

  function addPurchaseCount(
    uint256 campaignId,
    uint256 count
  )
    external
    onlyAuthorizedContract(CONTRACT_NAME_SPIN_PROTOCOL)
    onlyExistentItem(campaignId)
  {
    uint256 purchaseCount = universalDB.getUintStorage(CONTRACT_NAME_PURCHASE_DB, keccak256(abi.encodePacked(campaignId, "purchaseCount")));
    if(purchaseCount == 0){
        require(universalDB.pushNodeToLinkedList(CONTRACT_NAME_PURCHASE_DB, TABLE_KEY_PURCHASE, campaignId), ERROR_ALREADY_EXIST);
    }
    universalDB.setUintStorage(CONTRACT_NAME_PURCHASE_DB, keccak256(abi.encodePacked(campaignId, "purchaseCount")), purchaseCount.add(count));
    emit PurchaseAdd(campaignId, block.timestamp);
  }

  function subPurchaseCount(
    uint256 campaignId,
    uint256 count
  )
    external
    onlyAuthorizedContract(CONTRACT_NAME_SPIN_PROTOCOL)
    onlyExistentItem(campaignId)
  {
    uint256 purchaseCount = universalDB.getUintStorage(CONTRACT_NAME_PURCHASE_DB, keccak256(abi.encodePacked(campaignId, "purchaseCount")));
    universalDB.setUintStorage(CONTRACT_NAME_PURCHASE_DB, keccak256(abi.encodePacked(campaignId, "purchaseCount")), purchaseCount.sub(count));
    if(purchaseCount.sub(count) == 0){
        require(universalDB.removeNodeFromLinkedList(CONTRACT_NAME_PURCHASE_DB, TABLE_KEY_PURCHASE, campaignId), ERROR_DOES_NOT_EXIST);
    }
    emit PurchaseSub(campaignId, block.timestamp);
  }

  function resetPurchaseCount(
      uint256 campaignId
  )
    external
    onlyAuthorizedContract(CONTRACT_NAME_SPIN_PROTOCOL)
  {
    universalDB.setUintStorage(CONTRACT_NAME_PURCHASE_DB, keccak256(abi.encodePacked(campaignId, "purchaseCount")), 0);
    require(universalDB.removeNodeFromLinkedList(CONTRACT_NAME_PURCHASE_DB, TABLE_KEY_PURCHASE, campaignId), ERROR_DOES_NOT_EXIST);
    emit PurchaseReset(campaignId, block.timestamp);
  }

  function getPurchaseCount(
    uint256 campaignId
  )
    external
    view
    returns(uint256)
  {
    return universalDB.getUintStorage(CONTRACT_NAME_PURCHASE_DB, keccak256(abi.encodePacked(campaignId, "purchaseCount")));
  }

  function doesItemExist(uint256 campaignId) public view returns (bool) {
    return universalDB.doesNodeExist(CONTRACT_NAME_CAMPAIGN_DB, TABLE_KEY_CAMPAIGN, campaignId);
  }
}