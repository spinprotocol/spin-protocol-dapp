pragma solidity ^0.4.24;

import './DataControl.sol';
import '../libs/SafeMath.sol';

/**
 * @title PurchaseDB
 * @dev Manages purchase storage
 * CONTRACT_NAME = "Purchase"
 */
contract Purchase is DataControl {
  using SafeMath for uint256;

  event PurchaseAdd(uint256 indexed campaignId, uint256 updatedAt);
  event PurchaseSub(uint256 indexed campaignId, uint256 updatedAt);
  event PurchaseReset(uint256 indexed campaignId, uint256 resetAt);

  function addPurchaseCount(
    uint256 campaignId,
    uint256 count
  )
    public
    onlyAccessOwner
    onlyExistentItem("Campaign" ,campaignId)
  {
    require(count > 0);
    string memory CONTRACT_NAME = "Purchase";
    bytes32 TABLE_KEY = keccak256(abi.encodePacked("Table"));

    uint256 purchaseCount = getUintStorage(CONTRACT_NAME, keccak256(abi.encodePacked(campaignId, "purchaseCount")));

    if(purchaseCount == 0){
        require(pushNodeToLinkedList(CONTRACT_NAME, TABLE_KEY, campaignId), "Item already exists");
    }

    setUintStorage(CONTRACT_NAME, keccak256(abi.encodePacked(campaignId, "purchaseCount")), purchaseCount.add(count));

    emit PurchaseAdd(campaignId, now);
  }

  function subPurchaseCount(
    uint256 campaignId,
    uint256 count
  )
    public
    onlyAccessOwner
    onlyExistentItem("Campaign" ,campaignId)
  {
    require(count > 0);
    string memory CONTRACT_NAME = "Purchase";
    bytes32 TABLE_KEY = keccak256(abi.encodePacked("Table"));

    uint256 purchaseCount = getUintStorage(CONTRACT_NAME, keccak256(abi.encodePacked(campaignId, "purchaseCount")));

    setUintStorage(CONTRACT_NAME, keccak256(abi.encodePacked(campaignId, "purchaseCount")), purchaseCount.sub(count));

    if(purchaseCount.sub(count) == 0){
        require(removeNodeFromLinkedList(CONTRACT_NAME, TABLE_KEY, campaignId), "Item does not exist");
    }

    emit PurchaseSub(campaignId, now);
  }

  function resetPurchaseCount(
      uint256 campaignId
  )
    public
    onlyAccessOwner
  {
    string memory CONTRACT_NAME = "Purchase";
    bytes32 TABLE_KEY = keccak256(abi.encodePacked("Table"));

    setUintStorage(CONTRACT_NAME, keccak256(abi.encodePacked(campaignId, "purchaseCount")), 0);

    require(removeNodeFromLinkedList(CONTRACT_NAME, TABLE_KEY, campaignId), "Item does not exist");

    emit PurchaseReset(campaignId, now);
  }

  function getPurchaseCount(
    uint256 campaignId
  )
    public
    view
    onlyExistentItem("Campaign" ,campaignId)
    returns(uint256)
  {
    string memory CONTRACT_NAME = "Purchase";
    return getUintStorage(CONTRACT_NAME, keccak256(abi.encodePacked(campaignId, "purchaseCount")));
  }
}