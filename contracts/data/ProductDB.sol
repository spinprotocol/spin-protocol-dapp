pragma solidity 0.5.7;

import "./UniversalDB.sol";
import "../components/system/Proxied.sol";


/**
 * @title ProductDB
 * @dev Manages product storage
 * @author Mustafa Morca - psychoplasma@gmail.com
 */
contract ProductDB is Proxied {
  UniversalDB public universalDB;

  bytes32 private constant TABLE_KEY = keccak256(abi.encodePacked("ProductTable"));

  string private constant ERROR_ALREADY_EXIST = "Product already exists";
  string private constant ERROR_DOES_NOT_EXIST = "Product does not exist";

  event ProductCreated(uint256 indexed productId);
  event ProductUpdated(uint256 indexed productId, uint256 updatedAt);


  constructor(UniversalDB _universalDB) public {
    setUniversalDB(_universalDB);
  }

  function setUniversalDB(UniversalDB _universalDB) public onlyAdmin {
    universalDB = _universalDB;
  }

  function create(
    uint256 productId,
    uint256 supplierId,
    string calldata description
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
    universalDB.setStringStorage(CONTRACT_NAME_PRODUCT_DB, keccak256(abi.encodePacked(productId, "description")), description);
    emit ProductCreated(productId);
  }

  function update(
    uint256 productId,
    string calldata description
  )
    external
    onlyAuthorizedContract(CONTRACT_NAME_SPIN_PROTOCOL)
  {
    require(universalDB.doesNodeExist(CONTRACT_NAME_PRODUCT_DB, TABLE_KEY, productId), ERROR_DOES_NOT_EXIST);
    universalDB.setStringStorage(CONTRACT_NAME_PRODUCT_DB, keccak256(abi.encodePacked(productId, "description")), description);
    emit ProductUpdated(productId, block.timestamp);
  }

  function get(uint256 productId)
    public view returns (uint256 supplierId, string memory description)
  {
    require(universalDB.doesNodeExist(CONTRACT_NAME_PRODUCT_DB, TABLE_KEY, productId), ERROR_ALREADY_EXIST);
    supplierId = universalDB.getUintStorage(CONTRACT_NAME_PRODUCT_DB, keccak256(abi.encodePacked(productId, "supplierId")));
    description = universalDB.getStringStorage(CONTRACT_NAME_PRODUCT_DB, keccak256(abi.encodePacked(productId, "description")));
  }
}