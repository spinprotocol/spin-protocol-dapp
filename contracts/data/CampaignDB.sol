pragma solidity ^0.4.24;

import "./AbstractDB.sol";
import "../components/system/Proxied.sol";


/**
 * @title CampaignDB
 * @dev Manages campaing storage
 */
contract CampaignDB is AbstractDB, Proxied {

  bytes32 private constant TABLE_KEY_CAMPAIGN = keccak256(abi.encodePacked("CampaignTable"));
  bytes32 private constant LINKED_LIST_KEY_APPLIED_INFLUENCER = keccak256(abi.encodePacked("AppliedInfluencerList"));

  string private constant CAMPAIGN_STATE_WAITING = "waiting";
  string private constant CAMPAIGN_STATE_PROGRESS = "progress";
  string private constant CAMPAIGN_STATE_COMPLETE = "complete";

  event CampaignCreated(uint256 indexed campaignId, uint256 indexed revenueRatio, uint256 indexed productId);
  event CampaignUpdated(uint256 indexed campaignId, uint256 updatedAt);
  event CampaignDeleted(uint256 indexed campaignId, uint256 deletedAt);
  
  constructor(UniversalDB _universalDB) public {
    setUniversalDB(_universalDB);
  }

  function createCampaign(
    uint256 campaignId,
    uint256 productId,
    uint256 revenueRatio,
    uint256 totalSupply
  )
    external
    onlyAuthorizedContract(CONTRACT_NAME_SPIN_PROTOCOL)
  {
    require(campaignId > 0);
    require(productId > 0);
    require(revenueRatio > 0);
    require(totalSupply > 0);
    require(universalDB.pushNodeToLinkedList(CONTRACT_NAME_CAMPAIGN_DB, TABLE_KEY_CAMPAIGN, campaignId), ERROR_ALREADY_EXIST);
    
    universalDB.setUintStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "productId")), productId);
    universalDB.setUintStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "revenueRatio")), revenueRatio);
    universalDB.setUintStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "totalSupply")), totalSupply);
    universalDB.setStringStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "state")), CAMPAIGN_STATE_WAITING);
    emit CampaignCreated(campaignId, revenueRatio, productId);
  }

  function updateCampaign(
    uint256 campaignId,
    uint256 productId,
    uint256 revenueRatio,
    uint256 totalSupply
  )
    external
    onlyAuthorizedContract(CONTRACT_NAME_SPIN_PROTOCOL)
    onlyExistentItem(campaignId)
  {
    require(keccak256(abi.encodePacked(this.getState(campaignId))) == keccak256(abi.encodePacked(CAMPAIGN_STATE_WAITING)));

    universalDB.setUintStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "productId")), productId);
    universalDB.setUintStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "revenueRatio")), revenueRatio);
    universalDB.setUintStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "totalSupply")), totalSupply);
    emit CampaignUpdated(campaignId, block.timestamp);
  }

  function attendCampaign(
    uint256 campaignId,
    uint256 influencerId
  ) 
    external
    onlyAuthorizedContract(CONTRACT_NAME_SPIN_PROTOCOL)
    onlyExistentItem(campaignId)
  {
    require(keccak256(abi.encodePacked(this.getState(campaignId))) == keccak256(abi.encodePacked(CAMPAIGN_STATE_WAITING)));
    require(universalDB.pushNodeToLinkedList(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, LINKED_LIST_KEY_APPLIED_INFLUENCER)), influencerId), ERROR_ALREADY_EXIST);

    emit CampaignUpdated(campaignId, block.timestamp);
  }

  function updateSaleStart(
    uint256 campaignId,
    uint256 startAt
  ) 
    external
    onlyAuthorizedContract(CONTRACT_NAME_SPIN_PROTOCOL)
    onlyExistentItem(campaignId)
  {
    require(keccak256(abi.encodePacked(this.getState(campaignId))) == keccak256(abi.encodePacked(CAMPAIGN_STATE_WAITING)));

    universalDB.setUintStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "startAt")), startAt);
    universalDB.setStringStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "state")), CAMPAIGN_STATE_PROGRESS);
    emit CampaignUpdated(campaignId, block.timestamp);
  }

  function updateSaleEnd(
    uint256 campaignId,
    uint256 endAt
  ) 
    external
    onlyAuthorizedContract(CONTRACT_NAME_SPIN_PROTOCOL)
    onlyExistentItem(campaignId)
  {
    require(keccak256(abi.encodePacked(this.getState(campaignId))) == keccak256(abi.encodePacked(CAMPAIGN_STATE_PROGRESS)));

    universalDB.setUintStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "endAt")), endAt);
    universalDB.setStringStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "state")), CAMPAIGN_STATE_COMPLETE);
    emit CampaignUpdated(campaignId, block.timestamp);
  }

  function deleteCampaign(
    uint256 campaignId
  )
    external
    onlyAuthorizedContract(CONTRACT_NAME_SPIN_PROTOCOL)
    onlyExistentItem(campaignId)
  {
    require(keccak256(abi.encodePacked(this.getState(campaignId))) == keccak256(abi.encodePacked(CAMPAIGN_STATE_WAITING)));
    require(universalDB.removeNodeFromLinkedList(CONTRACT_NAME_CAMPAIGN_DB, TABLE_KEY_CAMPAIGN, campaignId), ERROR_DOES_NOT_EXIST);

    emit CampaignDeleted(campaignId, block.timestamp);
  }

  function getCampaign(
    uint256 campaignId
  )
    public
    onlyExistentItem(campaignId)
    view returns (
      uint256 productId, 
      uint256 revenueRatio, 
      uint256 totalSupply, 
      uint256[] memory appliedInfluencerList, 
      uint256 startAt, 
      uint256 endAt, 
      string memory state, 
      uint256 createdAt
    )
  {
    productId = universalDB.getUintStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "productId")));
    revenueRatio = universalDB.getUintStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "revenueRatio")));
    totalSupply = universalDB.getUintStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "totalSupply")));
    appliedInfluencerList = universalDB.getNodes(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, LINKED_LIST_KEY_APPLIED_INFLUENCER)));
    startAt = universalDB.getUintStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "startAt")));
    endAt = universalDB.getUintStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "endAt")));
    state = universalDB.getStringStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "state")));
    createdAt = universalDB.getUintStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "createdAt")));
  }

  function getState(
    uint256 campaignId
  )
    public
    onlyExistentItem(campaignId)
    view returns (string memory)
  {
    return universalDB.getStringStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "state")));
  }

  function doesItemExist(uint256 campaignId) public view returns (bool) {
    return universalDB.doesNodeExist(CONTRACT_NAME_CAMPAIGN_DB, TABLE_KEY_CAMPAIGN, campaignId);
  }
}