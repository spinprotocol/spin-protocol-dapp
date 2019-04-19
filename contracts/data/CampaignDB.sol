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
  bytes32 private constant LINKED_LIST_KEY_DEAL = keccak256(abi.encodePacked("DealList"));

  string private constant ERROR_CAMPAIGN_ALREADY_EXIST = "Campaign already exists";
  string private constant ERROR_CAMPAIGN_DOES_NOT_EXIST = "Campaign does not exist";
  string private constant ERROR_DEAL_ALREADY_EXIST = "Deal already exists in this campaign";
  string private constant ERROR_SUPPLY_DEPLETED = "Campaign supply depleted";

  event CampaignCreated(uint256 indexed campaignId, uint256 indexed supplierId, uint256 indexed productId);
  event CampaignUpdated(uint256 indexed campaignId, uint256 updatedAt);
  
  modifier onlyExistentCampaign(uint256 campaignId) {
    require(doesCampaignExist(campaignId), ERROR_CAMPAIGN_DOES_NOT_EXIST);
    _;
  }

  constructor(UniversalDB _universalDB) public {
    setUniversalDB(_universalDB);
  }

  function setUniversalDB(UniversalDB _universalDB)
    public
    onlyAdmin
  {
    universalDB = _universalDB;
  }

  function create(
    uint256 campaignId,
    uint256 supplierId,
    uint256 productId,
    uint256 totalSupply,
    uint256 finishAt
  )
    external
    onlyAuthorizedContract(CONTRACT_NAME_SPIN_PROTOCOL)
  {
    require(campaignId > 0);
    require(supplierId > 0);
    require(productId > 0);
    require(totalSupply > 0);
    require(finishAt > block.timestamp);
    // Creates a linked list with the given keys, if it does not exist
    // And push the new deal pointer to the list
    require(universalDB.pushNodeToLinkedList(CONTRACT_NAME_CAMPAIGN_DB, TABLE_KEY_CAMPAIGN, campaignId), ERROR_CAMPAIGN_ALREADY_EXIST);
    universalDB.setUintStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "supplierId")), supplierId);
    universalDB.setUintStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "productId")), productId);
    // Initial suppy is for reference
    universalDB.setUintStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "totalSupply")), totalSupply);
    // Current supply is to keep track of change in supply
    universalDB.setUintStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "currentSupply")), totalSupply);
    universalDB.setUintStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "createdAt")), block.timestamp);
    universalDB.setUintStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "finishAt")), finishAt);
    emit CampaignCreated(campaignId, supplierId, productId);
  }

  function update(
    uint256 campaignId,
    uint256 totalSupply,
    uint256 finishAt
  )
    external
    onlyAuthorizedContract(CONTRACT_NAME_SPIN_PROTOCOL)
    onlyExistentCampaign(campaignId)
  {
    // Does not allow to set finish time in past
    require(finishAt > block.timestamp);
    uint256 currentSupply = universalDB.getUintStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "currentSupply")));
    // Does not allow to set total supply something less than or equal to current supply
    require(totalSupply > currentSupply);
    universalDB.setUintStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "finishAt")), finishAt);
    universalDB.setUintStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "totalSupply")), totalSupply);
    emit CampaignUpdated(campaignId, block.timestamp);
  }

  function addDeal(uint256 campaignId, uint256 dealId)
    external
    onlyAuthorizedContract(CONTRACT_NAME_SPIN_PROTOCOL)
    onlyExistentCampaign(campaignId)
  {
    require(dealId > 0);
    // Add the deal id to deal linked list under this campaign item.
    // This is only for cross-reference to DealDB with registered deals for this campaign.
    require(universalDB.pushNodeToLinkedList(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, LINKED_LIST_KEY_DEAL)), dealId), ERROR_DEAL_ALREADY_EXIST);
  }

  function decrementSupply(uint256 campaignId)
    external
    onlyAuthorizedContract(CONTRACT_NAME_SPIN_PROTOCOL)
    onlyExistentCampaign(campaignId)
  {
    uint256 currentSupply = universalDB.getUintStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "currentSupply")));
    // If the current supply drops to zero, revert the transaction, because the product supply is already depleted
    require(currentSupply > 0, ERROR_SUPPLY_DEPLETED);
    universalDB.setUintStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "currentSupply")), currentSupply - 1);
    emit CampaignUpdated(campaignId, block.timestamp);
  }

  function get(uint256 campaignId)
    public
    onlyExistentCampaign(campaignId)
    view returns (uint256 supplierId, uint256 productId, uint256 createdAt, uint256 finishAt, uint256 totalSupply, uint256 currentSupply)
  {
    supplierId = universalDB.getUintStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "supplierId")));
    productId = universalDB.getUintStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "productId")));
    createdAt = universalDB.getUintStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "createdAt")));
    finishAt = universalDB.getUintStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "finishAt")));
    totalSupply = universalDB.getUintStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "totalSupply")));
    currentSupply = universalDB.getUintStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "currentSupply")));
  }

  function getCurrentSupply(uint256 campaignId)
    public
    onlyExistentCampaign(campaignId)
    view returns (uint256)
  {
    return universalDB.getUintStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "currentSupply")));
  }

  function getTotalSupply(uint256 campaignId)
    public
    onlyExistentCampaign(campaignId)
    view returns (uint256)
  {
    return universalDB.getUintStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "totalSupply")));
  }

  function getDeals(uint256 campaignId)
    public
    onlyExistentCampaign(campaignId)
    view returns (uint256[] memory deals)
  {
    bytes32 listKey = keccak256(abi.encodePacked(campaignId, LINKED_LIST_KEY_DEAL));
    bool dir;
    uint256 nextDeal;
    uint256 i;
    deals = new uint256[](universalDB.getLinkedListSize(CONTRACT_NAME_CAMPAIGN_DB, listKey));

    do {
      (dir, nextDeal) = universalDB.getAdjacent(CONTRACT_NAME_CAMPAIGN_DB, listKey, nextDeal, dir);
      if (nextDeal > 0) {deals[i++] = nextDeal;}
    } while (nextDeal != 0);
  }

  function didCampaignEnd(uint256 campaignId)
    public
    onlyExistentCampaign(campaignId)
    view returns (bool)
  {
    return
      universalDB.getUintStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "finishAt"))) > block.timestamp ||
      universalDB.getUintStorage(CONTRACT_NAME_CAMPAIGN_DB, keccak256(abi.encodePacked(campaignId, "currentSupply"))) == 0;
  }

  function doesCampaignExist(uint256 campaignId)
    public view returns (bool)
  {
    return universalDB.doesNodeExist(CONTRACT_NAME_CAMPAIGN_DB, TABLE_KEY_CAMPAIGN, campaignId);
  }
}