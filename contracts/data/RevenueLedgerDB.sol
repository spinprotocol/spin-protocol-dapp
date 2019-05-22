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

  function createRevenueLedger(
    uint256 revenueLedgerId,
    uint256 campaignId,
    uint256 influencerId,
    uint256 salesAmount,
    uint256 salesPrice,
    uint256 rsSpinRatio,
    uint256 rsFiatRaito
  )
    external
    onlyAuthorizedContract(CONTRACT_NAME_SPIN_PROTOCOL)
  {
    require(revenueLedgerId > 0);
    require(universalDB.pushNodeToLinkedList(CONTRACT_NAME_REVENUE_LEDGER_DB, TABLE_KEY_REVENUE_LEDGER, revenueLedgerId), ERROR_ALREADY_EXIST);
    
    universalDB.setUintStorage(CONTRACT_NAME_REVENUE_LEDGER_DB, keccak256(abi.encodePacked(revenueLedgerId, "influencerId")), influencerId);
    universalDB.setUintStorage(CONTRACT_NAME_REVENUE_LEDGER_DB, keccak256(abi.encodePacked(revenueLedgerId, "campaignId")), campaignId);
    universalDB.setUintStorage(CONTRACT_NAME_REVENUE_LEDGER_DB, keccak256(abi.encodePacked(revenueLedgerId, "salesAmount")), salesAmount);
    universalDB.setUintStorage(CONTRACT_NAME_REVENUE_LEDGER_DB, keccak256(abi.encodePacked(revenueLedgerId, "salesPrice")), salesPrice);
    universalDB.setUintStorage(CONTRACT_NAME_REVENUE_LEDGER_DB, keccak256(abi.encodePacked(revenueLedgerId, "rsSpinRatio")), rsSpinRatio);
    universalDB.setUintStorage(CONTRACT_NAME_REVENUE_LEDGER_DB, keccak256(abi.encodePacked(revenueLedgerId, "rsFiatRaito")), rsFiatRaito);
    universalDB.setBoolStorage(CONTRACT_NAME_REVENUE_LEDGER_DB, keccak256(abi.encodePacked(revenueLedgerId, "isAccount")), false);
    
    emit RevenueLedgerCreated(revenueLedgerId);
  }

  function updateIsAccount(
    uint256 revenueLedgerId
  )
    external
    onlyAuthorizedContract(CONTRACT_NAME_SPIN_PROTOCOL)
    onlyExistentItem(revenueLedgerId)
  {  
    universalDB.setBoolStorage(CONTRACT_NAME_REVENUE_LEDGER_DB, keccak256(abi.encodePacked(revenueLedgerId, "isAccount")), true);
    emit RevenueLedgerUpdated(revenueLedgerId, block.timestamp);
  }

  function getRevenueLedger(
    uint256 revenueLedgerId
  )
    public
    onlyExistentItem(revenueLedgerId)
    view returns (
      uint256 campaignId,
      uint256 influencerId,
      uint256 salesAmount,
      uint256 salesPrice,
      uint256 rsSpinRatio,
      uint256 rsFiatRaito,
      bool isAccount
    )
  {
    campaignId = universalDB.getUintStorage(CONTRACT_NAME_REVENUE_LEDGER_DB, keccak256(abi.encodePacked(revenueLedgerId, "campaignId")));
    influencerId = universalDB.getUintStorage(CONTRACT_NAME_REVENUE_LEDGER_DB, keccak256(abi.encodePacked(revenueLedgerId, "influencerId")));
    salesAmount = universalDB.getUintStorage(CONTRACT_NAME_REVENUE_LEDGER_DB, keccak256(abi.encodePacked(revenueLedgerId, "salesAmount")));
    salesPrice = universalDB.getUintStorage(CONTRACT_NAME_REVENUE_LEDGER_DB, keccak256(abi.encodePacked(revenueLedgerId, "salesPrice")));
    rsSpinRatio = universalDB.getUintStorage(CONTRACT_NAME_REVENUE_LEDGER_DB, keccak256(abi.encodePacked(revenueLedgerId, "rsSpinRatio")));
    rsFiatRaito = universalDB.getUintStorage(CONTRACT_NAME_REVENUE_LEDGER_DB, keccak256(abi.encodePacked(revenueLedgerId, "rsFiatRaito")));
    isAccount = universalDB.getBoolStorage(CONTRACT_NAME_REVENUE_LEDGER_DB, keccak256(abi.encodePacked(revenueLedgerId, "isAccount")));
  }

  function getRevenueLedgerList()
    public
    view returns (uint256[] memory)
  {
    return universalDB.getNodes(CONTRACT_NAME_REVENUE_LEDGER_DB, TABLE_KEY_REVENUE_LEDGER);
  }

  function doesItemExist(uint256 revenueLedgerId) public view returns (bool) {
    return universalDB.doesNodeExist(CONTRACT_NAME_REVENUE_LEDGER_DB, TABLE_KEY_REVENUE_LEDGER, revenueLedgerId);
  }
}