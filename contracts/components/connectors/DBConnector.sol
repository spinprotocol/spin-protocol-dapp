pragma solidity ^0.4.24;

import "../../data/CampaignDB.sol";
import "../../data/RevenueLedgerDB.sol";
import "../auth/Admin.sol";


/**
 * @title DBConnector
 * @dev Connector for DB modules. By inheriting this contract,
 * you can set and use DB modules in the inheriting contract.
 */
contract DBConnector is Admin {
  CampaignDB public campaignDB;
  RevenueLedgerDB public revenueLedgerDB;

  function setDataStore(
    CampaignDB _campaignDB,
    RevenueLedgerDB _revenueLedgerDB
  )
    public onlyAdmin
  {
    campaignDB = _campaignDB;
    revenueLedgerDB = _revenueLedgerDB;
  }
}