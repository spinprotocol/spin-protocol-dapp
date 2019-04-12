pragma solidity 0.5.7;

import "../../libs/AccessRoles.sol";


contract Admin {
  using AccessRoles for AccessRoles.Role;

  event AdminAdded(address indexed account);
  event AdminRemoved(address indexed account);

  AccessRoles.Role private admins;

  constructor() internal {
    _addAdmin(msg.sender);
  }

  modifier onlyAdmin() {
    require(isAdmin(msg.sender));
    _;
  }

  function isAdmin(address account) public view returns (bool) {
    return admins.has(account);
  }

  function addAdmin(address account) public onlyAdmin {
    _addAdmin(account);
  }

  function renounceAdmin() public {
    _removeAdmin(msg.sender);
  }

  function _addAdmin(address account) private {
    admins.add(account);
    emit AdminAdded(account);
  }

  function _removeAdmin(address account) private {
    admins.remove(account);
    emit AdminRemoved(account);
  }
}
