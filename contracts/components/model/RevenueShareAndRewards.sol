pragma solidity 0.4.24;

import "../../libs/SafeMath.sol";
import "../connectors/DBConnector.sol";
import "../connectors/EscrowConnector.sol";
import "../system/Proxied.sol";


/**
 * @title RevenueShareAndRewards
 * @dev Manages distribution of R/S and customer rewards upon campaign completion
 * @author Mustafa Morca - psychoplasma@gmail.com
 */
contract RevenueShareAndRewards is EscrowConnector, DBConnector, Proxied {
  using SafeMath for uint256;

  string constant private ERROR_CAMPAIGN_NOT_ENDED = "Campaign not ended";

  /**
   * @dev Calculates and distributes influencer & supplier's shares from the revenue of a campaign.
   * Can be called by only Proxy contract
   * @param campaignId uint256 Id of the campaign
   */
  function releaseRevenue(uint256 campaignId) external onlyProxy {
    // Get campaing data
    (
      uint256 supplierId,
      uint256 productId,
      ,
      uint256 finishAt,
      uint256 totalSupply,
      uint256 currentSupply
    ) = campaignDB.get(campaignId);

    // Do not allow to release before the campaign ends
    require(finishAt < block.timestamp, ERROR_CAMPAIGN_NOT_ENDED);

    (,uint256 influencerShareMultiplier, uint256 supplierShareMultiplier,) = escrow.getShareAndRewardRatios();

    uint256 campaignSaleCount = totalSupply.sub(currentSupply);
    // Calculate total revenue from the campaing
    uint256 revenue = _calculateRevenue(productId, campaignSaleCount);
    // Calculate and distribute shares to the influencers for each deal
    _releaseInfluencerShare(campaignId, revenue, influencerShareMultiplier);
    // Send the remaining revenue to the supplier
    _releaseSupplierShare(supplierId, revenue, supplierShareMultiplier);
  }

  /**
   * @dev Calculates and distributes customer rewards
   * Can be called by only Proxy contract
   * @param campaignId uint256 Id of the campaign
   */
  function releaseRewards(uint256 campaignId) external onlyProxy  {
    // Get campaing data
    (
      ,
      uint256 productId,
      ,
      uint256 finishAt,
      uint256 totalSupply,
      uint256 currentSupply
    ) = campaignDB.get(campaignId);

    // Do not allow to release before the campaign ends
    require(finishAt < block.timestamp, ERROR_CAMPAIGN_NOT_ENDED);

    uint256 campaignSaleCount = totalSupply.sub(currentSupply);
    // Calculate total revenue from the campaing
    uint256 revenue = _calculateRevenue(productId, campaignSaleCount);
    // Calculate and distribute rewards to the customers who has bought products in this campaign
    _releaseCustomerReward(campaignId, revenue);
  }

  /**
   * @dev Calculates and distribute the shares earned by influencers who made sales in this campaing.
   * @param campaignId uint256 Id of the campaign
   * @param revenue uint256 Total revenue of this campaign
   * @param influencerShareMultiplier uint256 A constant multiplier for share calculation
   */
   // FIXME: We may want to limit the number of deals under a campaign, because we may hit the block gas limit if there are too many deals due to iteration!!!
  function _releaseInfluencerShare(uint256 campaignId, uint256 revenue, uint256 influencerShareMultiplier) private {
    // Get the all deals under this campaign
    uint256[] memory deals = campaignDB.getDeals(campaignId);
    // And distribute the shares for each deal's influencer
    for (uint i = 0; i < deals.length; i++) {
      (uint256 influencerId,,,uint256 dealRatio, uint256 saleCount, bool isShareReleasable) = dealDB.get(deals[i]);
      uint256 share = _calculateInfluencerShare(revenue, saleCount, dealRatio, influencerShareMultiplier);
      // In order to save some gas, do nothing if share is zero
      if (isShareReleasable && share > 0) {
        dealDB.setShareReleased(deals[i]);
        escrow.payBack(actorDB.getAddress(influencerId), share);
      }
    }
  }

  /**
   * @dev Distributes the supplier's share
   * @param supplierId uint256 Id of the campaign
   * @param revenue uint256 Total revenue of this campaign
   */
  function _releaseSupplierShare(uint256 supplierId, uint256 revenue, uint256 supplierShareMultiplier) private {
    uint256 share = _calculateSupplierShare(revenue, supplierShareMultiplier);
    // In order to save some gas, do nothing if reward is zero
    if (share > 0) {
      escrow.payBack(actorDB.getAddress(supplierId), share);
    }
  }

  /**
   * @dev Calculates and distributes the rewards earned by customers who made a purchase/s in this campaing.
   * Notice that this distributes rewards for each purchase, not for each customer which means that
   * if a customer makes more than one purchase in this campaign, the reward will be calculated and distributed
   * for her/his each and every purchase.
   * @notice This may seem waste of gas, but eventually, we have to iterate the purchases to 
   * keep a record for every customer even though we do this iteration in somewhere else 
   * like when recording purchases which doesn't change amount of the total gas spent.
   * @param campaignId uint256 Id the of this campaign
   * @param revenue uint256 Total revenue of this campaign
   */
   // FIXME: We need to think about the size of purchase list under this campaign (maybe we can limit this when recording purchases), because we may hit the block gas limit if there are too many items in the list!!!
  function _releaseCustomerReward(uint256 campaignId, uint256 revenue) private {
    (uint256 customerRewardRatio,,,) = escrow.getShareAndRewardRatios();
    // Get the all purchases under this campaign
    // Notice that getList() function gets only the references (ids) of the purchases
    // We need to get actual purchase data from PurchaseDB one by one with these references.
    uint256[] memory purchases = purchaseDB.getList(campaignId);
    // And distribute the rewards for each customer who purchased products from this campaign
    for (uint i = 0; i < purchases.length; i++) {
      (uint256 customerId,,uint256 purchaseAmount, bool isRewardable) = purchaseDB.get(campaignId, purchases[i]);
      uint256 reward = _calculateCustomerReward(revenue, purchaseAmount, customerRewardRatio);
      // If the reward has already been paid back, just skip
      // And in order to save some gas if the reward is zero, skip
      if (isRewardable && reward > 0) {
        // Mark this purchase as rewarded so that it cannot be rewarded again
        purchaseDB.setUnrewardable(campaignId, purchases[i]);
        escrow.payBack(actorDB.getAddress(customerId), reward);
      }
    }
  }

  /**
   * @dev Calculates the total revenue of a campaign
   * @param productId uint256 Id of the product to be sold in this campaign
   * @param campaignSaleCount uint256 Total number of sale made in this campaign
   */
  function _calculateRevenue(uint256 productId, uint256 campaignSaleCount) private view returns (uint256) {
    (,uint256 productPrice,) = productDB.get(productId);
    return productPrice.mul(campaignSaleCount);
  }

  /**
   * @dev Calculates the revenue share for a supplier
   * @param revenue uint256 Total revenue of this campaign
   * @param shareMultiplier uint256 Some pre-defined ratio. For a better granulity, ratio should be multiplied by 100 always. For example 20% => 2000
   */
  // TODO: Implementation should be updated when the calculation model is finalized
  function _calculateSupplierShare(uint256 revenue, uint256 shareMultiplier) private pure returns (uint256) {
    return revenue.mul(shareMultiplier).div(10000);
  }

  /**
   * @dev Calculates the revenue share for an influencer
   * @param revenue uint256 Total revenue of this campaign
   * @param saleCount uint256 Total number of sale made by an influencer in this campaign
   * @param dealRatio uint256 Deal ratio agreed between suppiler and influencer for this campaign. For a better granulity, ratio should be multiplied by 100 always. For example 20% => 2000
   * @param shareMultiplier uint256 A constant multiplier for share calculation
   */
  // TODO: Implementation should be updated  when the calculation model is finalized
  function _calculateInfluencerShare(uint256 revenue, uint256 saleCount, uint256 dealRatio, uint256 shareMultiplier) private pure returns (uint256) {
    return revenue.mul(saleCount).mul(dealRatio).div(10000).mul(shareMultiplier).div(10000);
  }

  /**
   * @dev Calculates the amount of reward earned by a customer
   * @param revenue uint256 Total revenue of this campaign
   * @param purchaseCount uint256 Total number of purchase made by a customer in this campaign
   * @param rewardMultiplier uint256 Ratio constant for reward calculation. For a better granulity, multiplier should be multiplied by 100 always. For example 20% => 2000
   */
  // TODO: Implementation should be updated when the calculation model is finalized
  function _calculateCustomerReward(uint256 revenue, uint256 purchaseCount, uint256 rewardMultiplier) private pure returns (uint256) {
    return revenue.mul(purchaseCount).mul(rewardMultiplier).div(10000);
  }
}