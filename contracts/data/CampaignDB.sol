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
  
  constructor(UniversalDB _universalDB) public {
    setUniversalDB(_universalDB);
  }

  function create(
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
    universalDB.setUintStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "createdAt")), block.timestamp);
    universalDB.setStringStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "state")), CAMPAIGN_STATE_REGISTERED);
    emit CampaignCreated(campaignId, revenueRatio, productId);
  }

  function update(
    uint256 campaignId,
    uint256 productId,
    uint256 revenueRatio,
    uint256 totalSupply
  )
    external
    onlyAuthorizedContract(CONTRACT_NAME_SPIN_PROTOCOL)
    onlyExistentItem(campaignId)
  {
    // Does not allow to set finish time in past
    // require(finishAt > block.timestamp);
    // uint256 currentSupply = universalDB.getUintStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "currentSupply")));
    // Does not allow to set total supply something less than or equal to current supply
    // require(totalSupply > currentSupply);
    universalDB.setUintStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "productId")), productId);
    universalDB.setUintStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "revenueRatio")), revenueRatio);
    universalDB.setUintStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "totalSupply")), totalSupply);
    universalDB.setUintStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "updatedAt")), block.timestamp);
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
    universalDB.setUintArrayStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "appliedInfluencers")), appliedInfluencers);
    universalDB.setUintStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "startAt")), startAt);
    universalDB.setUintStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "endAt")), endAt);
    universalDB.setUintStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "updatedAt")), block.timestamp);
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
    universalDB.setUintStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "updatedAt")), block.timestamp);
    universalDB.setStringStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "state")), CAMPAIGN_STATE_END);
    emit CampaignUpdated(campaignId, block.timestamp);
  }
  
  function get(
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
      uint256 createdAt, 
      uint256 updatedAt
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
    updatedAt = universalDB.getUintStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "updatedAt")));
  }

  function doesItemExist(uint256 campaignId) public view returns (bool) {
    return universalDB.doesNodeExist(CONTRACT_NAME_CAMPAIGN_DB, TABLE_KEY_CAMPAIGN, campaignId);
  }
}