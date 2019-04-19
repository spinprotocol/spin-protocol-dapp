pragma solidity 0.5.7;

import "../auth/SystemRoles.sol";
import "../connectors/DBConnector.sol";
import "../connectors/EscrowConnector.sol";
import "../system/Proxied.sol";


/**
 * @title Registry
 * @dev Manages user, product and campaign registrations
 * @author Mustafa Morca - psychoplasma@gmail.com
 */
contract Registry is SystemRoles, EscrowConnector, DBConnector, Proxied {

  string constant private ERROR_ONLY_INFLUENCER = "Only influencer";
  string constant private ERROR_ONLY_SUPPLIER = "Only supplier";
  string constant private ERROR_PRODUCT_DOES_NOT_EXIST = "No such product on DB";
  string constant private ERROR_CAMPAIGN_ENDED = "Campaign ended already";

  /**
   * @dev Registers a user in SpinProtocol system with the given ethereum address and role
   * @param actorId uint256 Id of user to be registered
   * @param actorAddress uint256 Ethereum address of user to be registered
   * @param role string Role of user in SpinProtocol.
   * Possible values {'customer', 'influencer', 'supplier', 'service_provider', 'spin_protocol'}
   */
  function registerActor(
    uint256 actorId,
    address actorAddress,
    string calldata role
  )
    external onlyProxy
  {
    actorDB.create(actorId, actorAddress, role);
  }

  /**
   * @dev Registers a new campaign item. Supplier, influencer and product should be registered
   * in the system before the campaign registration. Also finish time for the campaign
   * should be in the future. In order to register a campaign, the supplier should have
   * enough token balance to pay registration fee.
   * @param campaignId uint256 Id of the campaign, should be generated off-chain
   * @param supplierId uint256 Id of the supplier who creates this campaign
   * @param productId uint256 Id of the product to be sold in this campaign
   * @param totalSupply uint256 Total supply of the product to be sold in this campaign
   * @param finishAt uint256 Finish time of the campaign in unix epoch time (in seconds)
   */
  function registerCampaign(
    uint256 campaignId,
    uint256 supplierId,
    uint256 productId,
    uint256 totalSupply,
    uint256 finishAt
  )
    external onlyProxy
  {
    (address supplierAddress, string memory supplierRole) = actorDB.get(supplierId);
    require(checkRole(supplierRole, ROLE_SUPPLIER), ERROR_ONLY_SUPPLIER);
    require(productDB.doesProductExist(productId), ERROR_PRODUCT_DOES_NOT_EXIST);
    campaignDB.create(campaignId, supplierId, productId, totalSupply, finishAt);
    escrow.chargeCampaignRegistrationFee(supplierAddress);
  }

  /**
   * @dev Registers a product. The supplier should exist in the system
   * before the product registration. In order to register a campaign,
   * the supplier should have enough token balance to pay registration fee.
   * @param productId uint256 Id of the product to be registered
   * @param supplierId uint256 Id of the supplier who registers this product
   * @param price uint256 Price of the product
   * @param metadata string Metadata of the product. It can be a simple description or URL of the product etc.
   */
  function registerProduct(
    uint256 productId,
    uint256 supplierId,
    uint256 price,
    string calldata metadata
  )
    external onlyProxy
  {
    (address supplierAddress, string memory role) = actorDB.get(supplierId);
    require(checkRole(role, ROLE_SUPPLIER), ERROR_ONLY_SUPPLIER);
    productDB.create(productId, supplierId, price, metadata);
    escrow.chargeProductRegistrationFee(supplierAddress);
  }

  /**
   * @dev Registers a new deal under the given campaign. Therefore the campaign and 
   * the influencer should already exist in the system before the deal registration.
   * If the campaign has already ended the transaction will be reverted.
   * @param dealId uint256 Id of the new deal, should be generated off-chain
   * @param campaignId uint256 Id of the campaign for this deal to be registered
   * @param influencerId uint256 Id of the influencer who attends in this campaign
   * @param ratio uint256 Ratio of the R/S that the supplier and the influencer agreed
   */
  function attendCampaign(
    uint256 dealId,
    uint256 campaignId,
    uint256 influencerId,
    uint256 ratio
  )
    external onlyProxy
  {
    (, string memory influencerRole) = actorDB.get(influencerId);
    // Allow only influencer role to attend a campaign
    require(checkRole(influencerRole, ROLE_INFLUENCER), ERROR_ONLY_INFLUENCER);
    // Check if the campaign is still available
    require(!campaignDB.didCampaignEnd(campaignId), ERROR_CAMPAIGN_ENDED);
    // Create a new deal item
    dealDB.create(dealId, campaignId, influencerId, ratio);
    // Add the reference of this deal to this campaign item
    campaignDB.addDeal(campaignId, dealId);
  }

  /**
   * @dev Registers a new purchase. Therefore the campaign and 
   * the influencer should already exist in the system before the deal registration.
   * If the campaign has already ended the transaction will be reverted.
   * @param campaignId uint256 Id of the campaign for this deal to be registered
   */
  function recordPurchase(
    uint256 purchaseId,
    uint256 transactionId,
    uint256 customerId,
    uint256 campaignId,
    uint256 dealId,
    uint256 purchaseAmount,
    uint256 purchasedAt
  )
    public onlyProxy
  {
    purchaseDB.create(purchaseId, transactionId, customerId, campaignId, dealId, purchaseAmount, purchasedAt);
    dealDB.incrementSaleCount(dealId);
    campaignDB.decrementSupply(campaignId);
    // TODO: Record purchase for the given customer under the given campagin
  }
}