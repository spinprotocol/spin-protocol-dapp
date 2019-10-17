pragma solidity ^0.4.24;

import "../system/EternalStorage.sol";
import "./AuthStorage.sol";

contract Authority is EternalStorage {
  address private _upgradeability;

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

  function setAuthStorage(address account) public onlyProxy {
    require(account != address(0));
    addressStorage[keccak256(abi.encodePacked("authStorage"))] = account;
  }

  function getAuthStorage() public view returns(address){
    return addressStorage[keccak256(abi.encodePacked("authStorage"))];
  }

  function isAdmin(address account) public view returns (bool) {
    return _has("admin", account);
  }

  function isSupplier(address account) public view returns (bool) {
    return _has("supplier", account);
  }

  function isInfluencer(address account) public view returns (bool) {
    return _has("influencer", account);
  }

  function isWt(address account) public view returns (bool) {
    return _has("wt", account);
  }

  function _has(string auth, address account) private view returns(bool) {
    require(account != address(0));
    AuthStorage authStorage = AuthStorage(getAuthStorage());
    return authStorage.isAuth(auth,account);
  }
}