pragma solidity ^0.4.24;

import './DataControl.sol';

/**
 * @title Campaign
 * @dev Manages campaing storage
 */
contract Campaign is DataControl {
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
    external
  {
    require(campaignId > 0);
    require(productId > 0);
    require(revenueRatio > 0);
    require(totalSupply > 0);
    require(startAt > now);
    require(startAt < endAt);
    require(pushNodeToLinkedList(CONTRACT_NAME_CAMPAIGN_DB, TABLE_KEY_CAMPAIGN, campaignId), ERROR_ALREADY_EXIST);
    
    setUintStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "productId")), productId);
    setUintStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "revenueRatio")), revenueRatio);
    setUintStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "totalSupply")), totalSupply);
    setUintStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "startAt")), startAt);
    setUintStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "endAt")), endAt);
    setUintStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "createdAt")), now);
    emit CampaignCreated(campaignId, revenueRatio, productId, startAt, endAt);
  }
}