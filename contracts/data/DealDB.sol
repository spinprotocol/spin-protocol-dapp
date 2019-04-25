pragma solidity 0.5.7;

import "./AbstractDB.sol";
import "../components/system/Proxied.sol";


/**
 * @title DealDB
 * @dev Manages deal storage
 * @author Mustafa Morca - psychoplasma@gmail.com
 */
contract DealDB is AbstractDB, Proxied {

  bytes32 private constant TABLE_KEY = keccak256(abi.encodePacked("DealTable"));

  event DealCreated(uint256 indexed dealId, uint256 indexed influencerId, uint256 indexed campaignId);
  event DealUpdated(uint256 indexed dealId, uint256 updatedAt);
  

  constructor(UniversalDB _universalDB) public {
    setUniversalDB(_universalDB);
  }

  function create(
    uint256 dealId,
    uint256 campaignId,
    uint256 influencerId,
    uint256 ratio
  )
    external
    onlyAuthorizedContract(CONTRACT_NAME_SPIN_PROTOCOL)
  {
    require(dealId > 0);
    require(campaignId > 0);
    require(influencerId > 0);
    // Creates a linked list with the given keys, if it does not exist
    // And push the new deal pointer to the list
    require(universalDB.pushNodeToLinkedList(CONTRACT_NAME_DEAL_DB, TABLE_KEY, dealId), ERROR_ALREADY_EXIST);
    universalDB.setUintStorage(CONTRACT_NAME_DEAL_DB, keccak256(abi.encodePacked(dealId, "influencerId")), influencerId);
    universalDB.setUintStorage(CONTRACT_NAME_DEAL_DB, keccak256(abi.encodePacked(dealId, "campaignId")), campaignId);
    universalDB.setUintStorage(CONTRACT_NAME_DEAL_DB, keccak256(abi.encodePacked(dealId, "createdAt")), block.timestamp);
    universalDB.setUintStorage(CONTRACT_NAME_DEAL_DB, keccak256(abi.encodePacked(dealId, "ratio")), ratio);
    emit DealCreated(dealId, influencerId, campaignId);
  }

  function incrementSaleCount(uint256 dealId, uint256 amount)
    external
    onlyAuthorizedContract(CONTRACT_NAME_SPIN_PROTOCOL)
    onlyExistentItem(dealId)
  {
    uint256 saleCount = universalDB.getUintStorage(CONTRACT_NAME_DEAL_DB, keccak256(abi.encodePacked(dealId, "saleCount")));
    // Assuming that there won't be as many sales as saleCount variable overflows
    universalDB.setUintStorage(CONTRACT_NAME_DEAL_DB, keccak256(abi.encodePacked(dealId, "saleCount")), saleCount + amount);
    emit DealUpdated(dealId, block.timestamp);
  }

  function get(uint256 dealId)
    public
    onlyExistentItem(dealId)
    view returns (uint256 influencerId, uint256 campaignId, uint256 createdAt, uint256 ratio, uint256 saleCount)
  {
    influencerId = universalDB.getUintStorage(CONTRACT_NAME_DEAL_DB, keccak256(abi.encodePacked(dealId, "influencerId")));
    campaignId = universalDB.getUintStorage(CONTRACT_NAME_DEAL_DB, keccak256(abi.encodePacked(dealId, "campaignId")));
    createdAt = universalDB.getUintStorage(CONTRACT_NAME_DEAL_DB, keccak256(abi.encodePacked(dealId, "createdAt")));
    ratio = universalDB.getUintStorage(CONTRACT_NAME_DEAL_DB, keccak256(abi.encodePacked(dealId, "ratio")));
    saleCount = universalDB.getUintStorage(CONTRACT_NAME_DEAL_DB, keccak256(abi.encodePacked(dealId, "saleCount")));
  }

  function doesItemExist(uint256 dealId) public view returns (bool) {
    return universalDB.doesNodeExist(CONTRACT_NAME_DEAL_DB, TABLE_KEY, dealId);
  }
}