pragma solidity ^0.4.24;

import "../system/EternalStorage.sol";

contract Authority is EternalStorage{

  address private _upgradeability;

  event AuthAdded(string indexed auth, address indexed account);
  event AuthRemoved(string indexed auth, address indexed account);

  modifier onlyProxy() {
    require(msg.sender == proxy());
    _;
  }

  function proxy() public view returns (address){
    return _upgradeability;
  }

  modifier onlyAdmin() {
    require(isAdmin(msg.sender) || msg.sender == proxy());
    _;
  }

  modifier onlySupplier() {
    require(isSupplier(msg.sender) || isAdmin(msg.sender) || msg.sender == proxy());
    _;
  }

  modifier onlyInfluencer() {
    require(isInfluencer(msg.sender) || isAdmin(msg.sender) || msg.sender == proxy());
    _;
  }

  modifier onlyWT() {
    require(isWT(msg.sender) || isAdmin(msg.sender) || msg.sender == proxy());
    _;
  }

  modifier onlyUser() {
    require(
      isSupplier(msg.sender)
      || isInfluencer(msg.sender)
      || isWT(msg.sender)
      || isAdmin(msg.sender)
      || msg.sender == proxy());
    _;
  }

  function isAdmin(address account) public view returns (bool) {
    return _has("Admin", account);
  }

  function addAdmin(address account) public onlyProxy {
    _addAuth("Admin", account);
  }

  function removeAdmin(address account) public onlyProxy {
    _removeAuth("Admin", account);
  }

  function isSupplier(address account) public view returns (bool) {
    return _has("Supplier", account);
  }

  function addSupplier(address account) public onlyAdmin {
    _addAuth("Supplier", account);
  }

  function removeSupplier(address account) public onlyAdmin {
    _removeAuth("Supplier", account);
  }

  function isInfluencer(address account) public view returns (bool) {
    return _has("Influencer", account);
  }

  function addInfluencer(address account) public onlyAdmin {
    _addAuth("Influencer", account);
  }

  function removeInfluencer(address account) public onlyAdmin {
    _removeAuth("Influencer", account);
  }

  function isWT(address account) public view returns (bool) {
    return _has("WT", account);
  }

  function addWT(address account) public onlyAdmin {
    _addAuth("WT", account);
  }

  function removeWT(address account) public onlyAdmin {
    _removeAuth("WT", account);
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
