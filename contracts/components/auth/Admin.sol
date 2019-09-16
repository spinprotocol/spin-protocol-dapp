pragma solidity ^0.4.24;

import "../system/EternalStorage.sol";

contract Admin is EternalStorage{

  event AdminAdded(address indexed account);
  event AdminRemoved(address indexed account);

  constructor() public {
    _addAdmin(msg.sender);
  }

  modifier onlyAdmin() {
    require(isAdmin(msg.sender));
    _;
  }

  function isAdmin(address account) public view returns (bool) {
    return _has(account);
  }

  function addAdmin(address account) public onlyAdmin {
    _addAdmin(account);
  }

  function renounceAdmin() public {
    _removeAdmin(msg.sender);
  }

  function _addAdmin(address account) private {
    require(!_has(account));
    bytes32 adminHash = keccak256(abi.encodePacked("admin", account));
    boolStorage[adminHash] = true;
    emit AdminAdded(account);
  }

  function _removeAdmin(address account) private {
    require(_has(account));
    bytes32 adminHash = keccak256(abi.encodePacked("admin", account));
    boolStorage[adminHash] = false;
    emit AdminRemoved(account);
  }

  function _has(address account) public view returns(bool) {
    require(account != address(0));
    bytes32 adminHash = keccak256(abi.encodePacked("admin", account));
    return boolStorage[adminHash];
  }
}
