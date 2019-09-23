pragma solidity ^0.4.24;

import './DataControl.sol';

/**
 * @title Campaign
 * @dev Manages campaing storage
 * CONTRACT_NAME = "Campaign"
 * TABLE_KEY : keccak256(abi.encodePacked("Table"))
 * LINKED_LIST_KEY_APPLIED_INFLUENCER = keccak256(abi.encodePacked("AppliedInfluencerList"))
 */
contract Campaign is DataControl {

  event CampaignCreated(uint256 indexed campaignId, uint256 revenueRatio, uint256 indexed productId, uint256 startAt, uint256 endAt);
  event CampaignUpdated(uint256 indexed campaignId, uint256 updatedAt);
  event CampaignDeleted(uint256 indexed campaignId, uint256 deletedAt);

  function createCampaign(
    uint256 campaignId,
    uint256 productId,
    uint256 revenueRatio,
    uint256 totalSupply,
    uint256 startAt,
    uint256 endAt
  )
    public
    onlyAccessOwner
  {
    string memory CONTRACT_NAME = "Campaign";
    bytes32 TABLE_KEY = keccak256(abi.encodePacked("Table"));

    require(campaignId > 0, "campaignId cannot be 0");
    require(productId > 0, "productId cannot be 0");
    require(revenueRatio > 0, "revenueRatio cannot be 0");
    require(totalSupply > 0, "totalSupply cannot be 0");
    require(startAt > now, "The past time is not available.");
    require(startAt < endAt, "startAt cannot be higher than endAt");
    require(pushNodeToLinkedList(CONTRACT_NAME, TABLE_KEY, campaignId), "Item already exists");

    setUintStorage(CONTRACT_NAME, keccak256(abi.encodePacked(campaignId, "productId")), productId);
    setUintStorage(CONTRACT_NAME, keccak256(abi.encodePacked(campaignId, "revenueRatio")), revenueRatio);
    setUintStorage(CONTRACT_NAME, keccak256(abi.encodePacked(campaignId, "totalSupply")), totalSupply);
    setUintStorage(CONTRACT_NAME, keccak256(abi.encodePacked(campaignId, "startAt")), startAt);
    setUintStorage(CONTRACT_NAME, keccak256(abi.encodePacked(campaignId, "endAt")), endAt);
    setUintStorage(CONTRACT_NAME, keccak256(abi.encodePacked(campaignId, "createdAt")), now);
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
    public
    onlyAccessOwner
    onlyExistentItem("Campaign", campaignId)
  {
    require(this.getStartAt(campaignId) > now);
    require(productId > 0, "productId cannot be 0");
    require(revenueRatio > 0, "revenueRatio cannot be 0");
    require(totalSupply > 0, "totalSupply cannot be 0");
    require(startAt > now);
    require(startAt < endAt);

    string memory CONTRACT_NAME = "Campaign";

    setUintStorage(CONTRACT_NAME, keccak256(abi.encodePacked(campaignId, "productId")), productId);
    setUintStorage(CONTRACT_NAME, keccak256(abi.encodePacked(campaignId, "revenueRatio")), revenueRatio);
    setUintStorage(CONTRACT_NAME, keccak256(abi.encodePacked(campaignId, "totalSupply")), totalSupply);
    setUintStorage(CONTRACT_NAME, keccak256(abi.encodePacked(campaignId, "startAt")), startAt);
    setUintStorage(CONTRACT_NAME, keccak256(abi.encodePacked(campaignId, "endAt")), endAt);
    emit CampaignUpdated(campaignId, now);
  }

  function deleteCampaign(
    uint256 campaignId
  )
    public
    onlyAccessOwner
    onlyExistentItem("Campaign", campaignId)
  {
    string memory CONTRACT_NAME = "Campaign";
    bytes32 TABLE_KEY = keccak256(abi.encodePacked("Table"));

    require(this.getStartAt(campaignId) > now);
    require(removeNodeFromLinkedList(CONTRACT_NAME, TABLE_KEY, campaignId), "Item does not exist");

    emit CampaignDeleted(campaignId, now);
  }

  function attendCampaign(
    uint256 campaignId,
    uint256 influencerId
  )
    public
    onlyAccessOwner
    onlyExistentItem("Campaign", campaignId)
  {
    string memory CONTRACT_NAME = "Campaign";
    bytes32 LINKED_LIST_KEY_APPLIED_INFLUENCER = keccak256(abi.encodePacked("AppliedInfluencerList"));

    require(this.getStartAt(campaignId) > now);
    require(pushNodeToLinkedList(CONTRACT_NAME, keccak256(abi.encodePacked(campaignId, LINKED_LIST_KEY_APPLIED_INFLUENCER)), influencerId), "Item already exists");

    emit CampaignUpdated(campaignId, now);
  }

  function cancelCampaign(
    uint256 campaignId,
    uint256 influencerId
  )
    public
    onlyAccessOwner
    onlyExistentItem("Campaign", campaignId)
  {
    string memory CONTRACT_NAME = "Campaign";
    bytes32 LINKED_LIST_KEY_APPLIED_INFLUENCER = keccak256(abi.encodePacked("AppliedInfluencerList"));

    require(removeNodeFromLinkedList(CONTRACT_NAME, keccak256(abi.encodePacked(campaignId, LINKED_LIST_KEY_APPLIED_INFLUENCER)), influencerId), "Item already exists");

    emit CampaignUpdated(campaignId, now);
  }

  function updateSaleEnd(
    uint256 campaignId,
    uint256 endAt
  )
    public
    onlyAccessOwner
    onlyExistentItem("Campaign", campaignId)
  {
    uint256 startAt = this.getStartAt(campaignId);
    require(startAt < now);
    require(startAt < endAt);

    string memory CONTRACT_NAME = "Campaign";

    setUintStorage(CONTRACT_NAME, keccak256(abi.encodePacked(campaignId, "endAt")), endAt);
    emit CampaignUpdated(campaignId, now);
  }

  function getCampaign(uint256 campaignId)
    public
    onlyExistentItem("Campaign", campaignId)
    view
    returns (
      uint256 productId,
      uint256 revenueRatio,
      uint256 totalSupply,
      uint256[] memory appliedInfluencerList,
      uint256 startAt,
      uint256 endAt,
      uint256 createdAt
    )
  {
    string memory CONTRACT_NAME = "Campaign";
    bytes32 LINKED_LIST_KEY_APPLIED_INFLUENCER = keccak256(abi.encodePacked("AppliedInfluencerList"));

    productId = getUintStorage(CONTRACT_NAME, keccak256(abi.encodePacked(campaignId, "productId")));
    revenueRatio = getUintStorage(CONTRACT_NAME, keccak256(abi.encodePacked(campaignId, "revenueRatio")));
    totalSupply = getUintStorage(CONTRACT_NAME, keccak256(abi.encodePacked(campaignId, "totalSupply")));
    appliedInfluencerList = getNodes(CONTRACT_NAME, keccak256(abi.encodePacked(campaignId, LINKED_LIST_KEY_APPLIED_INFLUENCER)));
    startAt = getUintStorage(CONTRACT_NAME, keccak256(abi.encodePacked(campaignId, "startAt")));
    endAt = getUintStorage(CONTRACT_NAME, keccak256(abi.encodePacked(campaignId, "endAt")));
    createdAt = getUintStorage(CONTRACT_NAME, keccak256(abi.encodePacked(campaignId, "createdAt")));
  }

  function getStartAt(uint256 campaignId)
    public
    onlyExistentItem("Campaign", campaignId)
    view
    returns(uint256)
  {
    string memory CONTRACT_NAME = "Campaign";
    return getUintStorage(CONTRACT_NAME, keccak256(abi.encodePacked(campaignId, "startAt")));
  }

  function getEndAt(uint256 campaignId)
    public
    onlyExistentItem("Campaign", campaignId)
    view
    returns(uint256)
  {
    string memory CONTRACT_NAME = "Campaign";
    return getUintStorage(CONTRACT_NAME, keccak256(abi.encodePacked(campaignId, "endAt")));
  }
}