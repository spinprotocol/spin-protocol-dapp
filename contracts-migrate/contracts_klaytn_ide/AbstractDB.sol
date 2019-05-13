pragma solidity ^0.4.24;

import "./UniversalDB.sol";
import "./Admin.sol";


/**
 * @title AbstractDB
 * @author Mustafa Morca - psychoplasma@gmail.com
 */
contract AbstractDB is Admin {
  UniversalDB public universalDB;

  string internal constant ERROR_ALREADY_EXIST = "Item already exists";
  string internal constant ERROR_DOES_NOT_EXIST = "Item does not exist";

  modifier onlyExistentItem(uint256 primaryIndex) {
    require(doesItemExist(primaryIndex), ERROR_DOES_NOT_EXIST);
    _;
  }
  
  modifier onlyExistentSecondaryItem(uint256 primaryIndex, uint256 secondaryIndex) {
    require(doesItemExist(primaryIndex, secondaryIndex), ERROR_DOES_NOT_EXIST);
    _;
  }

  function setUniversalDB(UniversalDB _universalDB)
    public
    onlyAdmin
  {
    universalDB = _universalDB;
  }

  function doesItemExist(uint256 primaryIndex) public view returns (bool) {}

  function doesItemExist(uint256 primaryIndex, uint256 secondaryIndex) public view returns (bool) {}
}