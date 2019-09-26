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

  modifier onlyWriter(uint256 campaignId) {
    require(getAddressStorage("Campaign", keccak256(abi.encodePacked(campaignId, "writer"))) == msg.sender || isAdmin(msg.sender), "Campaign : The caller and the writer do not match.");  
    _;
  }

  function createCampaign(
    uint256 campaignId,
    uint256 productId,
    uint256 revenueRatio,
    uint256 totalSupply,
    uint256 startAt,
    uint256 endAt
  )
    public
    onlySupplier
  {
    string memory CONTRACT_NAME = "Campaign";
    bytes32 TABLE_KEY = keccak256(abi.encodePacked("Table"));

    require(campaignId > 0, "Campaign : campaignId cannot be 0");
    require(productId > 0, "Campaign : productId cannot be 0");
    require(revenueRatio > 0, "Campaign : revenueRatio cannot be 0");
    require(totalSupply > 0, "Campaign : totalSupply cannot be 0");
    require(startAt > now, "Campaign : The past time is not available.");
    require(startAt < endAt, "Campaign : startAt cannot be higher than endAt");
    require(pushNodeToLinkedList(CONTRACT_NAME, TABLE_KEY, campaignId), "Campaign : Item already exists");

    setUintStorage(CONTRACT_NAME, keccak256(abi.encodePacked(campaignId, "productId")), productId);
    setUintStorage(CONTRACT_NAME, keccak256(abi.encodePacked(campaignId, "revenueRatio")), revenueRatio);
    setUintStorage(CONTRACT_NAME, keccak256(abi.encodePacked(campaignId, "totalSupply")), totalSupply);
    setUintStorage(CONTRACT_NAME, keccak256(abi.encodePacked(campaignId, "startAt")), startAt);
    setUintStorage(CONTRACT_NAME, keccak256(abi.encodePacked(campaignId, "endAt")), endAt);
    setUintStorage(CONTRACT_NAME, keccak256(abi.encodePacked(campaignId, "createdAt")), now);
    setAddressStorage(CONTRACT_NAME, keccak256(abi.encodePacked(campaignId, "writer")), msg.sender);
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
    onlySupplier
    onlyWriter(campaignId)
    onlyExistentItem("Campaign", campaignId)
  {
    require(this.getStartAt(campaignId) > now, "Campaign : an ongoing campaign");
    require(productId > 0, "Campaign : productId cannot be 0");
    require(revenueRatio > 0, "Campaign : revenueRatio cannot be 0");
    require(totalSupply > 0, "Campaign : totalSupply cannot be 0");
    require(startAt > now, "Campaign : The past time is not available.");
    require(startAt < endAt, "Campaign : startAt cannot be higher than endAt");

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
    onlySupplier
    onlyWriter(campaignId)
    onlyExistentItem("Campaign", campaignId)
  {
    string memory CONTRACT_NAME = "Campaign";
    bytes32 TABLE_KEY = keccak256(abi.encodePacked("Table"));

    require(this.getStartAt(campaignId) > now , "Campaign : an ongoing campaign");
    require(removeNodeFromLinkedList(CONTRACT_NAME, TABLE_KEY, campaignId), "Campaign : Item does not exist");

    emit CampaignDeleted(campaignId, now);
  }

  function attendCampaign(
    uint256 campaignId,
    uint256 influencerId
  )
    public
    onlyInfluencer
    onlyExistentItem("Campaign", campaignId)
  {
    string memory CONTRACT_NAME = "Campaign";
    bytes32 LINKED_LIST_KEY_APPLIED_INFLUENCER = keccak256(abi.encodePacked("AppliedInfluencerList"));

    require(this.getStartAt(campaignId) > now, "Campaign : an ongoing campaign");
    require(pushNodeToLinkedList(CONTRACT_NAME, keccak256(abi.encodePacked(campaignId, LINKED_LIST_KEY_APPLIED_INFLUENCER)), influencerId), "Campaign : Item already exists");
    setAddressStorage(CONTRACT_NAME, keccak256(abi.encodePacked(campaignId, influencerId)), msg.sender);

    emit CampaignUpdated(campaignId, now);
  }

  function cancelCampaign(
    uint256 campaignId,
    uint256 influencerId
  )
    public
    onlyInfluencer
    onlyExistentItem("Campaign", campaignId)
  {
    string memory CONTRACT_NAME = "Campaign";
    bytes32 LINKED_LIST_KEY_APPLIED_INFLUENCER = keccak256(abi.encodePacked("AppliedInfluencerList"));
    require(getAddressStorage(CONTRACT_NAME, keccak256(abi.encodePacked(campaignId, influencerId))) == msg.sender || isAdmin(msg.sender));
    require(removeNodeFromLinkedList(CONTRACT_NAME, keccak256(abi.encodePacked(campaignId, LINKED_LIST_KEY_APPLIED_INFLUENCER)), influencerId), "Campaign : Item already exists");
    setAddressStorage(CONTRACT_NAME, keccak256(abi.encodePacked(campaignId, influencerId)), address(0));

    emit CampaignUpdated(campaignId, now);
  }

  function updateSaleEnd(
    uint256 campaignId,
    uint256 endAt
  )
    public
    onlySupplier
    onlyWriter(campaignId)
    onlyExistentItem("Campaign", campaignId)
  {
    uint256 startAt = this.getStartAt(campaignId);
    require(startAt < endAt, "Campaign : startAt cannot be higher than endAt");

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
      uint256 createdAt,
      address writer
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
    writer = getAddressStorage(CONTRACT_NAME, keccak256(abi.encodePacked(campaignId, "writer")));
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