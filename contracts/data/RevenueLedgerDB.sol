pragma solidity ^0.4.24;

import "./AbstractDB.sol";
import "../components/system/Proxied.sol";


/**
 * @title RevenueLedgerDB
 * @dev Manages revenue ledger storage
 */
contract RevenueLedgerDB is AbstractDB, Proxied {

  bytes32 private constant TABLE_KEY_REVENUE_LEDGER = keccak256(abi.encodePacked("RevenueLedgerTable"));
  
  event RevenueLedgerCreated(uint256 indexed revenueLedgerId);
  event RevenueLedgerUpdated(uint256 indexed revenueLedgerId, uint256 updatedAt);
  
  constructor(UniversalDB _universalDB) public {
    setUniversalDB(_universalDB);
  }

  function create(
    uint256 revenueLedgerId,
    uint256[] influencerIds,
    uint256[] totalSalesPrices,
    uint256[] calculatedRevenues
  )
    external
    onlyAuthorizedContract(CONTRACT_NAME_SPIN_PROTOCOL)
  {
    require(revenueLedgerId > 0);
    require(universalDB.pushNodeToLinkedList(CONTRACT_NAME_REVENUE_LEDGER_DB, TABLE_KEY_REVENUE_LEDGER, revenueLedgerId), ERROR_ALREADY_EXIST);
    
    universalDB.setUintArrayStorage(CONTRACT_NAME_REVENUE_LEDGER_DB, keccak256(abi.encodePacked(revenueLedgerId, "influencerIds")), influencerIds);
    universalDB.setUintArrayStorage(CONTRACT_NAME_REVENUE_LEDGER_DB, keccak256(abi.encodePacked(revenueLedgerId, "totalSalesPrices")), totalSalesPrices);
    universalDB.setUintArrayStorage(CONTRACT_NAME_REVENUE_LEDGER_DB, keccak256(abi.encodePacked(revenueLedgerId, "calculatedRevenues")), calculatedRevenues);
    universalDB.setUintStorage(CONTRACT_NAME_REVENUE_LEDGER_DB, keccak256(abi.encodePacked(revenueLedgerId, "createdAt")), block.timestamp);
    emit RevenueLedgerCreated(revenueLedgerId);
  }

  function get(
    uint256 revenueLedgerId
  )
    public
    onlyExistentItem(revenueLedgerId)
    view returns (
      uint256[] influencerIds,
      uint256[] totalSalesPrices,
      uint256[] calculatedRevenues,
      uint256 createdAt
    )
  {
    influencerIds = universalDB.getUintArrayStorage(CONTRACT_NAME_REVENUE_LEDGER_DB, keccak256(abi.encodePacked(revenueLedgerId, "influencerIds")));
    totalSalesPrices = universalDB.getUintArrayStorage(CONTRACT_NAME_REVENUE_LEDGER_DB, keccak256(abi.encodePacked(revenueLedgerId, "totalSalesPrices")));
    calculatedRevenues = universalDB.getUintArrayStorage(CONTRACT_NAME_REVENUE_LEDGER_DB, keccak256(abi.encodePacked(revenueLedgerId, "calculatedRevenues")));
    createdAt = universalDB.getUintStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(revenueLedgerId, "createdAt")));
  }

  function doesItemExist(uint256 revenueLedgerId) public view returns (bool) {
    return universalDB.doesNodeExist(CONTRACT_NAME_CAMPAIGN_DB, TABLE_KEY_REVENUE_LEDGER, revenueLedgerId);
  }
}