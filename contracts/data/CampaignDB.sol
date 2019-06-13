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

  event CampaignCreated(uint256 indexed campaignId, uint256 revenueRatio, uint256 indexed productId, uint256 startAt, uint256 endAt);
  event CampaignUpdated(uint256 indexed campaignId, uint256 updatedAt);
  event CampaignDeleted(uint256 indexed campaignId, uint256 deletedAt);
  
  constructor(UniversalDB _universalDB) public {
    setUniversalDB(_universalDB);
  }

  function createCampaign(
    uint256 campaignId,
    uint256 productId,
    uint256 revenueRatio,
    uint256 totalSupply,
    uint256 startAt,
    uint256 endAt
  )
    external
    onlyAuthorizedContract(CONTRACT_NAME_SPIN_PROTOCOL)
  {
    require(campaignId > 0);
    require(productId > 0);
    require(revenueRatio > 0);
    require(totalSupply > 0);
    require(startAt > now);
    require(startAt < endAt);
    require(universalDB.pushNodeToLinkedList(CONTRACT_NAME_CAMPAIGN_DB, TABLE_KEY_CAMPAIGN, campaignId), ERROR_ALREADY_EXIST);
    
    universalDB.setUintStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "productId")), productId);
    universalDB.setUintStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "revenueRatio")), revenueRatio);
    universalDB.setUintStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "totalSupply")), totalSupply);
    universalDB.setUintStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "startAt")), startAt);
    universalDB.setUintStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "endAt")), endAt);
    universalDB.setUintStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "createdAt")), now);
    emit CampaignCreated(campaignId, revenueRatio, productId, startAt, endAt);
  }

  function updateCampaign(
    uint256 campaignId,
    uint256 productId,
    uint256 revenueRatio,
    uint256 totalSupply,
    uint256 startAt,
    uint256 endAt
  )
    external
    onlyAuthorizedContract(CONTRACT_NAME_SPIN_PROTOCOL)
    onlyExistentItem(campaignId)
  {
    require(this.getStartAt(campaignId) > now);
    require(startAt > now);
    require(startAt < endAt);

    universalDB.setUintStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "productId")), productId);
    universalDB.setUintStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "revenueRatio")), revenueRatio);
    universalDB.setUintStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "totalSupply")), totalSupply);
    universalDB.setUintStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "startAt")), startAt);
    universalDB.setUintStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "endAt")), endAt);
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
    require(this.getStartAt(campaignId) > now);
    require(universalDB.pushNodeToLinkedList(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, LINKED_LIST_KEY_APPLIED_INFLUENCER)), influencerId), ERROR_ALREADY_EXIST);

    emit CampaignUpdated(campaignId, block.timestamp);
  }

  function cancelCampaign(
    uint256 campaignId,
    uint256 influencerId
  ) 
    external
    onlyAuthorizedContract(CONTRACT_NAME_SPIN_PROTOCOL)
    onlyExistentItem(campaignId)
  {
    require(this.getStartAt(campaignId) > now);
    require(universalDB.removeNodeFromLinkedList(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, LINKED_LIST_KEY_APPLIED_INFLUENCER)), influencerId), ERROR_ALREADY_EXIST);

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
    require(this.getStartAt(campaignId) < now && this.getEndAt(campaignId) > now);
    require(endAt >= now);
    require(endAt > this.getStartAt(campaignId) && endAt < this.getEndAt(campaignId));

    universalDB.setUintStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "endAt")), endAt);
    emit CampaignUpdated(campaignId, block.timestamp);
  }

  function deleteCampaign(
    uint256 campaignId
  )
    external
    onlyAuthorizedContract(CONTRACT_NAME_SPIN_PROTOCOL)
    onlyExistentItem(campaignId)
  {
    require(this.getStartAt(campaignId) > now);
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
      uint256 createdAt
    )
  {
    productId = universalDB.getUintStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "productId")));
    revenueRatio = universalDB.getUintStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "revenueRatio")));
    totalSupply = universalDB.getUintStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "totalSupply")));
    appliedInfluencerList = universalDB.getNodes(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, LINKED_LIST_KEY_APPLIED_INFLUENCER)));
    startAt = universalDB.getUintStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "startAt")));
    endAt = universalDB.getUintStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "endAt")));
    createdAt = universalDB.getUintStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "createdAt")));
  }

  function getStartAt(uint256 campaignId) public onlyExistentItem(campaignId) view returns(uint256){
    return universalDB.getUintStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "startAt")));
  }

  function getEndAt(uint256 campaignId) public onlyExistentItem(campaignId) view returns(uint256){
    return universalDB.getUintStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "endAt")));
  }

  function doesItemExist(uint256 campaignId) public view returns (bool) {
    return universalDB.doesNodeExist(CONTRACT_NAME_CAMPAIGN_DB, TABLE_KEY_CAMPAIGN, campaignId);
  }
}