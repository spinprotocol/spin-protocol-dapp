pragma solidity ^0.4.24;

import "./SystemContracts.sol";
import "../auth/Admin.sol";

/**
 * @title Proxy
 * @dev Manages & keeps addresses of every contract in SpinProtocol system
 */
contract ProxyBase is Admin, SystemContracts {

  mapping(string => address) private contracts;

  function addContract(string memory name, address addr) public onlyAdmin {
    require(contracts[name] == address(0));
    contracts[name] = addr;
  }

  function removeContract(string memory name) public onlyAdmin {
    require(contracts[name] != address(0));
    delete contracts[name];
  }

  function updateContract(string memory name, address addr) public onlyAdmin {
    require(contracts[name] != address(0));
    contracts[name] = addr;
  }

  function getContract(string memory name) public view returns (address) {
    require(contracts[name] != address(0));
    return contracts[name];
  }

  function addressOfToken() public view returns(address) {return getContract("Token");}
  function addressOfCampaignDB() public view returns(address) {return getContract(CONTRACT_NAME_CAMPAIGN_DB);}
  function addressOfRevenueLedgerDB() public view returns(address) {return getContract(CONTRACT_NAME_REVENUE_LEDGER_DB);}
  function addressOfSpinProtocol() public view returns(address) {return getContract(CONTRACT_NAME_SPIN_PROTOCOL);}
}