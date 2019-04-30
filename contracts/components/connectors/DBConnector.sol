pragma solidity 0.4.24;

import "../../data/ActorDB.sol";
import "../../data/CampaignDB.sol";
import "../../data/DealDB.sol";
import "../../data/PurchaseDB.sol";
import "../../data/ProductDB.sol";
import "../auth/Admin.sol";


/**
 * @title DBConnector
 * @dev Connector for DB modules. By inheriting this contract,
 * you can set and use DB modules in the inheriting contract.
 * @author Mustafa Morca - psychoplasma@gmail.com
 */
contract DBConnector is Admin {
  ActorDB public actorDB;
  DealDB public dealDB;
  CampaignDB public campaignDB;
  ProductDB public productDB;
  PurchaseDB public purchaseDB;

  function setDataStore(
    ActorDB _actorDB,
    CampaignDB _campaignDB,
    DealDB _dealDB,
    ProductDB _productDB,
    PurchaseDB _purchaseDB
  )
    public onlyAdmin
  {
    actorDB = _actorDB;
    dealDB = _dealDB;
    campaignDB = _campaignDB;
    purchaseDB = _purchaseDB;
    productDB = _productDB;
  }
}