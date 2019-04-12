pragma solidity 0.5.7;

import "./SystemContracts.sol";
import "../auth/Admin.sol";


/**
 * @title Proxy
 * @dev Manages & keeps every contract addresses in SpinProtocol system
 * @author Mustafa Morca - psychoplasma@gmail.com
 */
contract Proxy is Admin, SystemContracts {

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

  function addressOfActorDB() public view returns(address) {return getContract(CONTRACT_NAME_ACTOR_DB);}
  function addressOfCampaignDB() public view returns(address) {return getContract(CONTRACT_NAME_CAMPAIGN_DB);}
  function addressOfProductDB() public view returns(address) {return getContract(CONTRACT_NAME_PRODUCT_DB);}
  function addressOfPurchaseDB() public view returns(address) {return getContract(CONTRACT_NAME_PURCHASE_DB);}
  function addressOfEscrowAndFees() public view returns(address) {return getContract(CONTRACT_NAME_ESCROW_AND_FEES);}
  function addressOfSpinProtocol() public view returns(address) {return getContract(CONTRACT_NAME_SPIN_PROTOCOL);}
}
