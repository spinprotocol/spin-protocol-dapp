pragma solidity 0.5.7;

import "./Proxy.sol";
import "./SystemContracts.sol";
import "../auth/Admin.sol";


/**
 * @title Proxied
 * @dev Provides modifiers to limit direct access to SpinProtocol contracts
 * @author Mustafa Morca - psychoplasma@gmail.com
 */
contract Proxied is Admin, SystemContracts {
  Proxy public proxy;

  /**
   * @notice Set/update address of Proxy contract
   */
  function setProxy(Proxy _proxy) public onlyAdmin {
    proxy = _proxy;
  }

  modifier onlyProxy() {
    _isProxy();
    _;
  }

  modifier onlyAuthorizedContract(string memory name) {
    _isContractAuthorized(name);
    _;
  }

  function _isContractAuthorized(string memory name) internal view {
    require(address(proxy) != address(0), "No Proxy");
    address allowedSender = proxy.getContract(name);
    assert(allowedSender != address(0));
    require(msg.sender == allowedSender, "Only specific contract");
  }

  function _isProxy() internal view {
    require(address(proxy) != address(0), "No Proxy");
    require(msg.sender == address(proxy), "Only through Proxy");
  }
}
