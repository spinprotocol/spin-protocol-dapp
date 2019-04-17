pragma solidity 0.5.7;

import "./UniversalDB.sol";
import "../components/system/Proxied.sol";


/**
 * @title CampaignDB
 * @dev Manages campaing storage
 * @author Mustafa Morca - psychoplasma@gmail.com
 */
contract CampaignDB is Proxied {
  UniversalDB public universalDB;

  bytes32 private constant TABLE_KEY_CAMPAIGN = keccak256(abi.encodePacked("CampaignTable"));

  string private constant ERROR_CAMPAIGN_ALREADY_EXIST = "Campaign already exists";
  string private constant ERROR_CAMPAIGN_DOES_NOT_EXIST = "Campaign does not exist";

  event CampaignCreated(uint256 indexed campaignId, uint256 indexed supplierId);
  event CampaignUpdated(uint256 indexed campaignId, uint256 updatedAt);
  
  modifier onlyExistentCampaign(uint256 campaignId) {
    require(doesCampaignExist(campaignId), ERROR_CAMPAIGN_DOES_NOT_EXIST);
    _;
  }

  constructor(UniversalDB _universalDB) public {
    setUniversalDB(_universalDB);
  }

  function setUniversalDB(UniversalDB _universalDB) public onlyAdmin {
    universalDB = _universalDB;
  }

  function create(
    uint256 campaignId,
    uint256 supplierId,
    uint256 influencerId,
    uint256 productId,
    uint256 finishAt,
    uint256 ratio
  )
    external
    onlyAuthorizedContract(CONTRACT_NAME_SPIN_PROTOCOL)
  {
    require(campaignId > 0);
    require(supplierId > 0);
    require(influencerId > 0);
    require(productId > 0);
    require(finishAt > block.timestamp);
    // Creates a linked list with the given keys, if it does not exist
    // And push the new deal pointer to the list
    require(universalDB.pushNodeToLinkedList(CONTRACT_NAME_CAMPAIGN_DB, TABLE_KEY_CAMPAIGN, campaignId), ERROR_CAMPAIGN_ALREADY_EXIST);
    universalDB.setUintStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "supplierId")), supplierId);
    universalDB.setUintStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "influencerId")), influencerId);
    universalDB.setUintStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "productId")), productId);
    universalDB.setUintStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "createdAt")), block.timestamp);
    universalDB.setUintStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "finishAt")), finishAt);
    universalDB.setUintStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "ratio")), ratio);
    emit CampaignCreated(campaignId, supplierId);
  }

  function update(
    uint256 campaignId,
    uint256 finishAt,
    uint256 ratio
  )
    external
    onlyAuthorizedContract(CONTRACT_NAME_SPIN_PROTOCOL)
    onlyExistentCampaign(campaignId)
  {
    universalDB.setUintStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "finishAt")), finishAt);
    universalDB.setUintStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "ratio")), ratio);
    emit CampaignUpdated(campaignId, block.timestamp);
  }

  function incrementSaleCount(uint256 campaignId)
    external
    onlyAuthorizedContract(CONTRACT_NAME_SPIN_PROTOCOL)
    onlyExistentCampaign(campaignId)
  {
    uint256 saleCount = universalDB.getUintStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "saleCount")));
    // Assuming that there won't be as many sales as saleCount variable overflows
    universalDB.setUintStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "saleCount")), saleCount + 1);
    emit CampaignUpdated(campaignId, block.timestamp);
  }

  function get(uint256 campaignId)
    public
    onlyExistentCampaign(campaignId)
    view returns (uint256 supplierId, uint256 influencerId, uint256 productId, uint256 createdAt, uint256 finishAt, uint256 ratio, uint256 saleCount)
  {
    supplierId = universalDB.getUintStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "supplierId")));
    influencerId = universalDB.getUintStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "influencerId")));
    productId = universalDB.getUintStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "productId")));
    createdAt = universalDB.getUintStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "createdAt")));
    finishAt = universalDB.getUintStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "finishAt")));
    ratio = universalDB.getUintStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "ratio")));
    saleCount = universalDB.getUintStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "saleCount")));
  }

  function doesCampaignExist(uint256 campaignId) public view returns (bool) {
    return universalDB.doesNodeExist(CONTRACT_NAME_CAMPAIGN_DB, TABLE_KEY_CAMPAIGN, campaignId);
  }
}