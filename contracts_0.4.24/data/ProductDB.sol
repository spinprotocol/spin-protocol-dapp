pragma solidity ^0.4.24;

import "./AbstractDB.sol";
import "../components/system/Proxied.sol";


/**
 * @title ProductDB
 * @dev Manages product storage
 * @author Mustafa Morca - psychoplasma@gmail.com
 */
contract ProductDB is AbstractDB, Proxied {

  bytes32 private constant TABLE_KEY = keccak256(abi.encodePacked("ProductTable"));

  event ProductCreated(uint256 indexed productId);
  event ProductUpdated(uint256 indexed productId, uint256 updatedAt);


  constructor(UniversalDB _universalDB) public {
    setUniversalDB(_universalDB);
  }

  function create(
    uint256 productId,
    uint256 supplierId,
    uint256 price,
    string  metadata
  )
    external
    onlyAuthorizedContract(CONTRACT_NAME_SPIN_PROTOCOL)
  {
    require(productId > 0);
    require(supplierId > 0);
    // Creates a linked list with the given keys, if it does not exist
    // And push the new deal pointer to the list
    require(universalDB.pushNodeToLinkedList(CONTRACT_NAME_PRODUCT_DB, TABLE_KEY, productId), ERROR_ALREADY_EXIST); 
    universalDB.setUintStorage(CONTRACT_NAME_PRODUCT_DB, keccak256(abi.encodePacked(productId, "supplierId")), supplierId);
    universalDB.setUintStorage(CONTRACT_NAME_PRODUCT_DB, keccak256(abi.encodePacked(productId, "price")), price);
    universalDB.setStringStorage(CONTRACT_NAME_PRODUCT_DB, keccak256(abi.encodePacked(productId, "metadata")), metadata);
    emit ProductCreated(productId);
  }

  function update(
    uint256 productId,
    uint256 price,
    string  metadata
  )
    external
    onlyAuthorizedContract(CONTRACT_NAME_SPIN_PROTOCOL)
    onlyExistentItem(productId)
  {
    universalDB.setUintStorage(CONTRACT_NAME_PRODUCT_DB, keccak256(abi.encodePacked(productId, "price")), price);
    universalDB.setStringStorage(CONTRACT_NAME_PRODUCT_DB, keccak256(abi.encodePacked(productId, "metadata")), metadata);
    emit ProductUpdated(productId, block.timestamp);
  }

  function get(uint256 productId)
    public
    onlyExistentItem(productId)
    view returns (uint256 supplierId, uint256 price, string memory metadata)
  {
    supplierId = universalDB.getUintStorage(CONTRACT_NAME_PRODUCT_DB, keccak256(abi.encodePacked(productId, "supplierId")));
    price = universalDB.getUintStorage(CONTRACT_NAME_PRODUCT_DB, keccak256(abi.encodePacked(productId, "price")));
    metadata = universalDB.getStringStorage(CONTRACT_NAME_PRODUCT_DB, keccak256(abi.encodePacked(productId, "metadata")));
  }

  function doesItemExist(uint256 productId) public view returns (bool) {
    return universalDB.doesNodeExist(CONTRACT_NAME_PRODUCT_DB, TABLE_KEY, productId);
  }
}