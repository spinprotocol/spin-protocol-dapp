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

  modifier onlyWt() {
    require(isWt(msg.sender) || isAdmin(msg.sender) || msg.sender == proxy());
    _;
  }

  modifier onlyUser() {
    require(
      isSupplier(msg.sender)
      || isInfluencer(msg.sender)
      || isWt(msg.sender)
      || isAdmin(msg.sender)
      || msg.sender == proxy());
    _;
  }

  function isAdmin(address account) public view returns (bool) {
    return _has("admin", account);
  }

  function addAdmin(address account) public onlyProxy {
    _addAuth("admin", account);
  }

  function removeAdmin(address account) public onlyProxy {
    _removeAuth("admin", account);
  }

  function isSupplier(address account) public view returns (bool) {
    return _has("supplier", account);
  }

  function addSupplier(address account) public onlyAdmin {
    _addAuth("supplier", account);
  }

  function removeSupplier(address account) public onlyAdmin {
    _removeAuth("supplier", account);
  }

  function isInfluencer(address account) public view returns (bool) {
    return _has("influencer", account);
  }

  function addInfluencer(address account) public onlyAdmin {
    _addAuth("influencer", account);
  }

  function removeInfluencer(address account) public onlyAdmin {
    _removeAuth("influencer", account);
  }

  function isWt(address account) public view returns (bool) {
    return _has("wt", account);
  }

  function addWt(address account) public onlyAdmin {
    _addAuth("wt", account);
  }

  function removeWt(address account) public onlyAdmin {
    _removeAuth("wt", account);
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
