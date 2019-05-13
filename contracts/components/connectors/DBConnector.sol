pragma solidity ^0.4.24;

import "../../data/CampaignDB.sol";
import "../auth/Admin.sol";


/**
 * @title DBConnector
 * @dev Connector for DB modules. By inheriting this contract,
 * you can set and use DB modules in the inheriting contract.
 */
contract DBConnector is Admin {
  CampaignDB public campaignDB;

  function setDataStore(
    CampaignDB _campaignDB
  )
    public onlyAdmin
  {
    campaignDB = _campaignDB;
  }
}