pragma solidity ^0.4.24;

import "./AbstractDB.sol";
import "./Proxied.sol";


/**
 * @title PurchaseDB
 * @dev Manages purchase storage
 * @author Mustafa Morca - psychoplasma@gmail.com
 */
contract PurchaseDB is AbstractDB, Proxied {
  string private constant TABLE_NAME = "PurchaseTable";

  event PurchaseCreated(uint256 indexed purchaseId, uint256 indexed campaignId);


  constructor(UniversalDB _universalDB) public {
    setUniversalDB(_universalDB);
  }

  function create(
    uint256 purchaseId,
    uint256 customerId,
    uint256 campaignId,
    uint256 dealId,
    uint256 purchaseAmount
  )
    external
    onlyAuthorizedContract(CONTRACT_NAME_SPIN_PROTOCOL)
  {
    require(purchaseId > 0);
    require(campaignId > 0);
    require(customerId > 0);
    require(dealId > 0);

    // Creates a linked list with the given keys, if it does not exist
    // And push the new pointer to the list
    require(universalDB.pushNodeToLinkedList(CONTRACT_NAME_PURCHASE_DB, keccak256(abi.encodePacked(TABLE_NAME, campaignId)), purchaseId), ERROR_ALREADY_EXIST);
    universalDB.setUintStorage(CONTRACT_NAME_PURCHASE_DB, keccak256(abi.encodePacked(TABLE_NAME, campaignId, purchaseId, "customerId")), customerId);
    universalDB.setUintStorage(CONTRACT_NAME_PURCHASE_DB, keccak256(abi.encodePacked(TABLE_NAME, campaignId, purchaseId, "dealId")), dealId);
    universalDB.setUintStorage(CONTRACT_NAME_PURCHASE_DB, keccak256(abi.encodePacked(TABLE_NAME, campaignId, purchaseId, "purchaseAmount")), purchaseAmount);
    universalDB.setBoolStorage(CONTRACT_NAME_PURCHASE_DB, keccak256(abi.encodePacked(TABLE_NAME, campaignId, purchaseId, "isRewardable")), true);
    emit PurchaseCreated(purchaseId, campaignId);
  }

  /**
   * @notice The reason why the attribute value is set to false instead of true is,
   * setting a variable to false means setting it to zero and setting any variable
   * in EVM costs less than setting it to some value other than zero. And considering
   * that this function is called relatively often from other contracts, using reverse
   * data setting pattern would reduce the gas consumption.
   */
  function setUnrewardable(uint256 campaignId, uint256 purchaseId)
    external
    onlyAuthorizedContract(CONTRACT_NAME_SPIN_PROTOCOL)
    onlyExistentSecondaryItem(campaignId, purchaseId)
  {
    universalDB.setBoolStorage(CONTRACT_NAME_PURCHASE_DB, keccak256(abi.encodePacked(TABLE_NAME, campaignId, purchaseId, "isRewardable")), false);
  }

  function get(uint256 campaignId, uint256 purchaseId)
    public
    onlyExistentSecondaryItem(campaignId, purchaseId)
    view returns (uint256 customerId, uint256 dealId, uint256 purchaseAmount, bool isRewardPaid)
  {
    customerId = universalDB.getUintStorage(CONTRACT_NAME_PURCHASE_DB, keccak256(abi.encodePacked(TABLE_NAME, campaignId, purchaseId, "customerId")));
    dealId = universalDB.getUintStorage(CONTRACT_NAME_PURCHASE_DB, keccak256(abi.encodePacked(TABLE_NAME, campaignId, purchaseId, "dealId")));
    purchaseAmount = universalDB.getUintStorage(CONTRACT_NAME_PURCHASE_DB, keccak256(abi.encodePacked(TABLE_NAME, campaignId, purchaseId, "purchaseAmount")));
    isRewardPaid = universalDB.getBoolStorage(CONTRACT_NAME_PURCHASE_DB, keccak256(abi.encodePacked(TABLE_NAME, campaignId, purchaseId, "isRewardable")));
  }

  function getList(uint256 campaignId)
    public
    view returns (uint256[] memory list)
  {
    return universalDB.getNodes(CONTRACT_NAME_PURCHASE_DB, keccak256(abi.encodePacked(TABLE_NAME, campaignId)));
  }

  function doesItemExist(uint256 campaignId, uint256 purchaseId) public view returns (bool) {
    return universalDB.doesNodeExist(CONTRACT_NAME_PURCHASE_DB, keccak256(abi.encodePacked(TABLE_NAME, campaignId)), purchaseId);
  }
}