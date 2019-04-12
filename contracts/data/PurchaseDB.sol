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

  bytes32 private constant TABLE_KEY = keccak256(abi.encodePacked("PurchaseTable"));

  string private constant ERROR_ALREADY_EXIST = "Purchase already exists";
  string private constant ERROR_DOES_NOT_EXIST = "Purchase does not exist";

  event PurchaseCreated(uint256 indexed purchaseId, uint256 purchasedAt);

  function setUniversalDB(UniversalDB _universalDB) external onlyAdmin {
    universalDB = _universalDB;
  }

  function create(
    uint256 purchaseId,
    uint256 campaignId,
    uint256 customerId,
    uint256 productId,
    uint256 transactionId,
    uint256 purchaseAmount,
    uint256 purchasedAt
  )
    external
    onlyAuthorizedContract(CONTRACT_NAME_SPIN_PROTOCOL)
  {
    require(purchaseId > 0);
    require(customerId > 0);
    require(productId > 0);
    require(transactionId > 0);
    // Creates a linked list with the given keys, if it does not exist
    // And push the new pointer to the list
    require(universalDB.pushNodeToLinkedList(CONTRACT_NAME_PURCHASE_DB, TABLE_KEY, purchaseId), ERROR_ALREADY_EXIST);
    
    universalDB.setUintStorage(CONTRACT_NAME_PURCHASE_DB, keccak256(abi.encodePacked(purchaseId, "customerId")), customerId);
    universalDB.setUintStorage(CONTRACT_NAME_PURCHASE_DB, keccak256(abi.encodePacked(purchaseId, "campaignId")), campaignId);
    universalDB.setUintStorage(CONTRACT_NAME_PURCHASE_DB, keccak256(abi.encodePacked(purchaseId, "productId")), productId);
    universalDB.setUintStorage(CONTRACT_NAME_PURCHASE_DB, keccak256(abi.encodePacked(purchaseId, "transactionId")), transactionId);
    universalDB.setUintStorage(CONTRACT_NAME_PURCHASE_DB, keccak256(abi.encodePacked(purchaseId, "purchaseAmount")), purchaseAmount);
    universalDB.setUintStorage(CONTRACT_NAME_PURCHASE_DB, keccak256(abi.encodePacked(purchaseId, "purchasedAt")), purchasedAt);
    emit PurchaseCreated(purchaseId, purchasedAt);
  }

  function get(uint256 purchaseId)
    public view returns (uint256 customerId, uint256 productId, uint256 transactionId, uint256 purchaseAmount, uint256 purchasedAt)
  {
    require(universalDB.doesNodeExist(CONTRACT_NAME_PURCHASE_DB, TABLE_KEY, purchaseId), ERROR_ALREADY_EXIST);
    customerId = universalDB.getUintStorage(CONTRACT_NAME_PURCHASE_DB, keccak256(abi.encodePacked(purchaseId, "customerId")));
    productId = universalDB.getUintStorage(CONTRACT_NAME_PURCHASE_DB, keccak256(abi.encodePacked(purchaseId, "productId")));
    transactionId = universalDB.getUintStorage(CONTRACT_NAME_PURCHASE_DB, keccak256(abi.encodePacked(purchaseId, "transactionId")));
    purchaseAmount = universalDB.getUintStorage(CONTRACT_NAME_PURCHASE_DB, keccak256(abi.encodePacked(purchaseId, "purchaseAmount")));
    purchasedAt = universalDB.getUintStorage(CONTRACT_NAME_PURCHASE_DB, keccak256(abi.encodePacked(purchaseId, "purchasedAt")));
  }
}