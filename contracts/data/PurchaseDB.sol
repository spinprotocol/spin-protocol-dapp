pragma solidity 0.5.7;

import "./UniversalDB.sol";
import "../components/system/Proxied.sol";


/**
 * @title PurchaseDB
 * @dev Manages purchase storage
 * @author Mustafa Morca - psychoplasma@gmail.com
 */
contract PurchaseDB is Proxied {
  UniversalDB public universalDB;

  string private constant TABLE_NAME = "PurchaseTable";

  string private constant ERROR_ALREADY_EXIST = "Purchase already exists";
  string private constant ERROR_DOES_NOT_EXIST = "Purchase does not exist";

  event PurchaseCreated(uint256 indexed purchaseId, uint256 indexed campaignId);

  modifier onlyExistentPurchase(uint256 campaignId, uint256 purchaseId) {
    require(doesPurchaseExist(campaignId, purchaseId), ERROR_DOES_NOT_EXIST);
    _;
  }


  constructor(UniversalDB _universalDB) public {
    setUniversalDB(_universalDB);
  }

  function setUniversalDB(UniversalDB _universalDB) public onlyAdmin {
    universalDB = _universalDB;
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
    emit PurchaseCreated(purchaseId, campaignId);
  }

  function get(uint256 campaignId, uint256 purchaseId)
    public
    onlyExistentPurchase(campaignId, purchaseId)
    view returns (uint256 customerId, uint256 dealId, uint256 purchaseAmount)
  {
    customerId = universalDB.getUintStorage(CONTRACT_NAME_PURCHASE_DB, keccak256(abi.encodePacked(TABLE_NAME, campaignId, purchaseId, "customerId")));
    dealId = universalDB.getUintStorage(CONTRACT_NAME_PURCHASE_DB, keccak256(abi.encodePacked(TABLE_NAME, campaignId, purchaseId, "dealId")));
    purchaseAmount = universalDB.getUintStorage(CONTRACT_NAME_PURCHASE_DB, keccak256(abi.encodePacked(TABLE_NAME, campaignId, purchaseId, "purchaseAmount")));
  }

  function getList(uint256 campaignId)
    public
    view returns (uint256[] memory list)
  {
    return universalDB.getNodes(CONTRACT_NAME_PURCHASE_DB, keccak256(abi.encodePacked(TABLE_NAME, campaignId)));
  }

  function doesPurchaseExist(uint256 campaignId, uint256 purchaseId) public view returns (bool) {
    return universalDB.doesNodeExist(CONTRACT_NAME_PURCHASE_DB, keccak256(abi.encodePacked(TABLE_NAME, campaignId)), purchaseId);
  }
}