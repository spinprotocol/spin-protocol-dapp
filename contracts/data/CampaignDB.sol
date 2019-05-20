pragma solidity ^0.4.24;

import "./AbstractDB.sol";
import "../components/system/Proxied.sol";


/**
 * @title CampaignDB
 * @dev Manages campaing storage
 */
contract CampaignDB is AbstractDB, Proxied {

  bytes32 private constant TABLE_KEY_CAMPAIGN = keccak256(abi.encodePacked("CampaignTable"));
  string private constant CAMPAIGN_STATE_REGISTERED = "Registered";
  string private constant CAMPAIGN_STATE_START = "Start";
  string private constant CAMPAIGN_STATE_END = "End";

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
    require(campaignId > 0, "Input Data Error - campaignId");
    require(productId > 0, "Input Data Error - productId");
    require(revenueRatio > 0, "Input Data Error - revenueRatio");
    require(totalSupply > 0, "Input Data Error - totalSupply");
    require(universalDB.pushNodeToLinkedList(CONTRACT_NAME_CAMPAIGN_DB, TABLE_KEY_CAMPAIGN, campaignId), ERROR_ALREADY_EXIST);
    
    universalDB.setUintStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "productId")), productId);
    universalDB.setUintStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "revenueRatio")), revenueRatio);
    universalDB.setUintStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "totalSupply")), totalSupply);
    universalDB.setUintStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "createdAt")), block.timestamp);
    universalDB.setStringStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "state")), CAMPAIGN_STATE_REGISTERED);
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
    require(keccak256(abi.encodePacked(this.getState(campaignId))) == keccak256(abi.encodePacked(CAMPAIGN_STATE_REGISTERED)), "Can't update this campaign, Please check the campaign's state.");

    universalDB.setUintStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "productId")), productId);
    universalDB.setUintStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "revenueRatio")), revenueRatio);
    universalDB.setUintStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "totalSupply")), totalSupply);
    emit CampaignUpdated(campaignId, block.timestamp);
  }

  function updateSaleStart(
    uint256 campaignId,
    uint256[] appliedInfluencers,
    uint256 startAt,
    uint256 endAt
  ) 
    external
    onlyAuthorizedContract(CONTRACT_NAME_SPIN_PROTOCOL)
    onlyExistentItem(campaignId)
  {
    require(keccak256(abi.encodePacked(this.getState(campaignId))) == keccak256(abi.encodePacked(CAMPAIGN_STATE_REGISTERED)), "Can't update this campaign, Please check the campaign's state.");

    universalDB.setUintArrayStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "appliedInfluencers")), appliedInfluencers);
    universalDB.setUintStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "startAt")), startAt);
    universalDB.setUintStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "endAt")), endAt);
    universalDB.setStringStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "state")), CAMPAIGN_STATE_START);
    emit CampaignUpdated(campaignId, block.timestamp);
  }

  function updateSaleEnd(
    uint256 campaignId
  ) 
    external
    onlyAuthorizedContract(CONTRACT_NAME_SPIN_PROTOCOL)
    onlyExistentItem(campaignId)
  {
    require(keccak256(abi.encodePacked(this.getState(campaignId))) == keccak256(abi.encodePacked(CAMPAIGN_STATE_START)), "Can't update this campaign, Please check the campaign's state.");

    universalDB.setStringStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "state")), CAMPAIGN_STATE_END);
    emit CampaignUpdated(campaignId, block.timestamp);
  }

  function deleteCampaign(
    uint256 campaignId
  )
    external
    onlyAuthorizedContract(CONTRACT_NAME_SPIN_PROTOCOL)
    onlyExistentItem(campaignId)
  {
    require(keccak256(abi.encodePacked(this.getState(campaignId))) == keccak256(abi.encodePacked(CAMPAIGN_STATE_REGISTERED)), "Can't update this campaign, Please check the campaign's state.");
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
      uint256[] appliedInfluencers, 
      uint256 startAt, 
      uint256 endAt, 
      string memory state, 
      uint256 createdAt
    )
  {
    productId = universalDB.getUintStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "productId")));
    revenueRatio = universalDB.getUintStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "revenueRatio")));
    totalSupply = universalDB.getUintStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "totalSupply")));
    appliedInfluencers = universalDB.getUintArrayStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "appliedInfluencers")));
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