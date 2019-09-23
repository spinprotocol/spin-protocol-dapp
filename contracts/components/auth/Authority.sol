pragma solidity ^0.4.24;

import "../system/EternalStorage.sol";

contract Authority is EternalStorage{

  address private _upgradeabilityOwner;

  event AuthAdded(string indexed auth, address indexed account);
  event AuthRemoved(string indexed auth, address indexed account);

  modifier onlyProxyOwner() {
    require(msg.sender == proxyOwner());
    _;
  }

  modifier onlyAccessOwner() {
    require(isAccessOwner(msg.sender) || msg.sender == proxyOwner());
    _;
  }

  function proxyOwner() public view returns (address){
    return _upgradeabilityOwner;
  }

  function isAccessOwner(address account) public view returns (bool) {
    return _has("Access", account);
  }

  function addAccessOwner(address account) public onlyProxyOwner {
    _addAuth("Access", account);
  }

  function removeAccessOwner(address account) public onlyProxyOwner {
    _removeAuth("Access", account);
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
