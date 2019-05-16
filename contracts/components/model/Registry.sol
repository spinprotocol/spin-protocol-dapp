pragma solidity ^0.4.24;

import "../connectors/DBConnector.sol";
import "../system/Proxied.sol";


/**
 * @title Registry
 * @dev Manages user, product and campaign registrations
 */
contract Registry is DBConnector, Proxied {

  string constant private ERROR_ONLY_INFLUENCER = "Only influencer";
  string constant private ERROR_ONLY_SUPPLIER = "Only supplier";
  string constant private ERROR_PRODUCT_DOES_NOT_EXIST = "No such product on DB";
  string constant private ERROR_CAMPAIGN_ENDED = "Campaign ended already";

  function createCampaign(
    uint256 campaignId,
    uint256 productId,
    uint256 revenueRatio,
    uint256 totalSupply
  ) 
    external onlyProxy 
  {
    // (address supplierAddress, string memory supplierRole) = actorDB.get(supplierId);
    // require(checkRole(supplierRole, ROLE_SUPPLIER), ERROR_ONLY_SUPPLIER);
    // require(productDB.doesItemExist(productId), ERROR_PRODUCT_DOES_NOT_EXIST);
    campaignDB.create(campaignId, productId, revenueRatio, totalSupply);
  }

  function updateCampaign(
    uint256 campaignId,
    uint256 productId,
    uint256 revenueRatio,
    uint256 totalSupply
  ) 
    external onlyProxy
  {

  }

  function updateSaleStart(
    uint256 campaignId,
    uint256[] appliedInfluencers,
    uint256 startAt,
    uint256 endAt
  )
    external onlyProxy
  {

  }

  function updateSaleEnd() external {}
  
  function createRevenueLedger(
    uint256 revenueLedgerId,
    uint256[] influencerIds,
    uint256[] totalSalesPrices,
    uint256[] calculatedRevenues
  )
    external onlyProxy
  {

  }


  // /**
  //  * @dev Registers a new deal under the given campaign. Therefore the campaign and 
  //  * the influencer should already exist in the system before the deal registration.
  //  * If the campaign has already ended the transaction will be reverted.
  //  * @param dealId uint256 Id of the new deal, should be generated off-chain
  //  * @param campaignId uint256 Id of the campaign for this deal to be registered
  //  * @param influencerId uint256 Id of the influencer who attends in this campaign
  //  * @param ratio uint256 Ratio of the R/S that the supplier and the influencer agreed
  //  */
  // function attendCampaign(
  //   uint256 dealId,
  //   uint256 campaignId,
  //   uint256 influencerId,
  //   uint256 ratio
  // )
  //   external onlyProxy
  // {
  //   // (, string memory influencerRole) = actorDB.get(influencerId);
  //   // Allow only influencer role to attend a campaign
  //   // require(checkRole(influencerRole, ROLE_INFLUENCER), ERROR_ONLY_INFLUENCER);
  //   // Check if the campaign is still active
  //   require(!campaignDB.didCampaignEnd(campaignId), ERROR_CAMPAIGN_ENDED);
  //   // Create a new deal item
  //   // dealDB.create(dealId, campaignId, influencerId, ratio);
  //   // Add the reference of this deal to this campaign item
  //   campaignDB.addDeal(campaignId, dealId);
  // }

  // /**
  //  * @dev Registers a new purchase.
  //  * @param purchaseId uint256 Id of this purchase, should be generated off-chain
  //  * @param customerId uint256 Id of the customer
  //  * @param campaignId uint256 Id of the campaign that this purchased belongs
  //  * @param dealId uint256 Id of the deal that this purchased is made through
  //  * @param purchaseAmount uint256 Amount of purchased item in unit
  //  */
  // function recordPurchase(
  //   uint256 purchaseId,
  //   uint256 customerId,
  //   uint256 campaignId,
  //   uint256 dealId,
  //   uint256 purchaseAmount
  // )
  //   external onlyProxy
  // {
  //   _recordPurchase(
  //     purchaseId,
  //     customerId,
  //     campaignId,
  //     dealId,
  //     purchaseAmount
  //   );
  // }

  // /**
  //  * @dev Registers a new purchase.
  //  * @param purchaseIds uint256[] Id of this purchase, should be generated off-chain
  //  * @param customerIds uint256[] Id of the customer
  //  * @param campaignIds uint256[] Id of the campaign that this purchased belongs
  //  * @param dealIds uint256[] Id of the deal that this purchased is made through
  //  * @param purchaseAmounts uint256[] Amount of purchased item in unit
  //  */
  // function recordPurchaseBatch(
  //   uint256[]  purchaseIds,
  //   uint256[]  customerIds,
  //   uint256[]  campaignIds,
  //   uint256[]  dealIds,
  //   uint256[]  purchaseAmounts
  // )
  //   external onlyProxy
  // {
  //   for (uint i = 0; i < purchaseIds.length; i++) {
  //     _recordPurchase(
  //       purchaseIds[i],
  //       customerIds[i],
  //       campaignIds[i],
  //       dealIds[i],
  //       purchaseAmounts[i]
  //     );
  //   }
  // }

  // /**
  //  * @dev Registers a new purchase.
  //  * @param purchaseId uint256 Id of this purchase, should be generated off-chain
  //  * @param customerId uint256 Id of the customer
  //  * @param campaignId uint256 Id of the campaign that this purchased belongs
  //  * @param dealId uint256 Id of the deal that this purchased is made through
  //  * @param purchaseAmount uint256 Amount of purchased item in unit
  //  */
  // function _recordPurchase(
  //   uint256 purchaseId,
  //   uint256 customerId,
  //   uint256 campaignId,
  //   uint256 dealId,
  //   uint256 purchaseAmount
  // )
  //   internal
  // {
  //   // Check if the campaign is still active
  //   require(!campaignDB.didCampaignEnd(campaignId), ERROR_CAMPAIGN_ENDED);

  //   // dealDB.incrementSaleCount(dealId, purchaseAmount);
  //   campaignDB.decrementSupply(campaignId, purchaseAmount);
  //   // purchaseDB.create(purchaseId, customerId, campaignId, dealId, purchaseAmount);

  //   // FIXME: Assuming that payments are done to this contracts in tokens for each purchase
  // }
}