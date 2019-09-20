pragma solidity ^0.4.24;

import './DataControl.sol';
import '../components/auth/Admin.sol';

/**
 * @title Campaign
 * @dev Manages campaing storage
 */
contract Campaign is Admin, DataControl {
  string constant internal CONTRACT_NAME_CAMPAIGN_DB = 'CampaignDB';
  bytes32 private constant TABLE_KEY_CAMPAIGN = keccak256(abi.encodePacked("CampaignTable"));
  bytes32 private constant LINKED_LIST_KEY_APPLIED_INFLUENCER = keccak256(abi.encodePacked("AppliedInfluencerList"));

  event CampaignCreated(uint256 indexed campaignId, uint256 revenueRatio, uint256 indexed productId, uint256 startAt, uint256 endAt);

  function createCampaign(
    uint256 campaignId,
    uint256 productId,
    uint256 revenueRatio,
    uint256 totalSupply,
    uint256 startAt,
    uint256 endAt
  )
    external onlyAdmin
  {
    require(campaignId > 0, "campaignId cannot be 0");
    require(productId > 0, "productId cannot be 0");
    require(revenueRatio > 0, "revenueRatio cannot be 0");
    require(totalSupply > 0, "totalSupply cannot be 0");
    require(startAt > now, "The past time is not available.");
    require(startAt < endAt, "startAt cannot be higher than endAt");
    require(pushNodeToLinkedList(CONTRACT_NAME_CAMPAIGN_DB, TABLE_KEY_CAMPAIGN, campaignId), ERROR_ALREADY_EXIST);
    
    setUintStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "productId")), productId);
    setUintStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "revenueRatio")), revenueRatio);
    setUintStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "totalSupply")), totalSupply);
    setUintStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "startAt")), startAt);
    setUintStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "endAt")), endAt);
    setUintStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "createdAt")), now);
    emit CampaignCreated(campaignId, revenueRatio, productId, startAt, endAt);
  }

  function getCampaign(
    uint256 campaignId
  )
    public
    onlyExistentItem(CONTRACT_NAME_CAMPAIGN_DB, TABLE_KEY_CAMPAIGN, campaignId)
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
    productId = getUintStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "productId")));
    revenueRatio = getUintStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "revenueRatio")));
    totalSupply = getUintStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "totalSupply")));
    appliedInfluencerList = getNodes(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, LINKED_LIST_KEY_APPLIED_INFLUENCER)));
    startAt = getUintStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "startAt")));
    endAt = getUintStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "endAt")));
    createdAt = getUintStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "createdAt")));
  }
}