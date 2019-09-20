pragma solidity ^0.4.24;

import "../system/EternalStorage.sol";

contract Authority is EternalStorage{

  event AuthAdded(string indexed auth, address indexed account);
  event AuthRemoved(string indexed auth, address indexed account);
  event MastershipTransferred(address indexed previousMaster, address indexed newMaster);

  modifier onlyMaster() {
    require(isMaster(msg.sender));
    _;
  }
  
  modifier onlyAccessOwner() {
    require(isAccessOwner(msg.sender) || isMaster(msg.sender));
    _;
  }
  
  modifier onlyUpgradeOwner() {
    require(isUpgradeOwner(msg.sender) || isMaster(msg.sender));
    _;
  }
  
  function isMaster(address account) public view returns (bool) {
    require(account != address(0), "Authority: new owner is ther zero address");
    bytes32 authHash = keccak256(abi.encodePacked("Master"));
    return boolStorage[authHash];
  }
  
  function transferMastership(address newMaster) public onlyMaster {
    require(newMaster != address(0), "Authority: new owner is ther zero address");
    emit MastershipTransferred(msg.sender, newMaster);
    boolStorage[keccak256(abi.encodePacked("Master", msg.sender))] = false;
    boolStorage[keccak256(abi.encodePacked("Master", newMaster))] = true;
  }

  function isAccessOwner(address account) public view returns (bool) {
    return _has("Access", account);
  }

  function addAccessOwner(address account) public onlyMaster {
    _addAuth("Access", account);
  }

  function removeAccessOwner(address account) public onlyMaster {
    _removeAuth("Access", account);
  }

  function isUpgradeOwner(address account) public view returns (bool) {
    return _has("Upgrade", account);
  }

  function addUpgradeOwner(address account) public onlyMaster {
    _addAuth("Upgrade", account);
  }

  function removeUpgradeOwner(address account) public onlyMaster {
    _removeAuth("Upgrade", account);
  }
  function _addAuth(string auth, address account) private {
    require(!_has(auth, account));
    bytes32 authHash = keccak256(abi.encodePacked(auth, account));
    boolStorage[authHash] = true;
    emit AuthAdded(auth, account);
  }

  function _removeAuth(string auth, address account) private {
    require(_has(auth, account));
    bytes32 authHash = keccak256(abi.encodePacked(auth, account));
    boolStorage[authHash] = false;
    emit AuthRemoved(auth, account);
  }

  function _has(string auth, address account) private view returns(bool) {
    require(account != address(0));
    bytes32 authHash = keccak256(abi.encodePacked(auth, account));
    return boolStorage[authHash];
  }
}
