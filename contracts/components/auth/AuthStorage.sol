pragma solidity ^0.4.24;

contract AuthStorage {
  mapping(bytes32 => bool) internal boolStorage;

  event AuthAdded(string indexed auth, address indexed account);
  event AuthRemoved(string indexed auth, address indexed account);

  constructor() public {
      _addAuth("admin", msg.sender);
  }

  modifier onlyAdmin() {
    require(isAuth("admin", msg.sender));
    _;
  }

  function isAuth(string auth, address account) public view returns (bool) {
    return _has(auth, account);
  }

  function addAuth(string auth, address account) public onlyAdmin {
    _addAuth(auth, account);
  }

  function addAuths(string auth, address[] accounts) public onlyAdmin {
    for(uint256 i = 0; i < accounts.length; i++){
      _addAuth(auth, accounts[i]);
    }
  }

  function removeAuth(string auth, address account) public onlyAdmin {
    _removeAuth(auth, account);
  }

  function _addAuth(string auth, address account) private {
    bytes32 authHash = keccak256(abi.encodePacked(auth, account));
    boolStorage[authHash] = true;
    emit AuthAdded(auth, account);
  }

  function _removeAuth(string auth, address account) private {
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
