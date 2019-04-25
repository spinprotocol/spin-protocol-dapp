pragma solidity 0.5.7;

import "../../libs/SafeMath.sol";
import "../connectors/DBConnector.sol";
import "../connectors/EscrowConnector.sol";
import "../system/Proxied.sol";


/**
 * @title RevenueShareAndRewards
 * @dev Calculates R/S and rewards upon campaign completion
 * @author Mustafa Morca - psychoplasma@gmail.com
 */
contract RevenueShareAndRewards is EscrowConnector, DBConnector, Proxied {
  using SafeMath for uint256;

  string constant private ERROR_CAMPAIGN_NOT_ENDED = "Campaign not ended";

  /**
   * @dev Calculates and distributes shares & rewards from the revenue of a campaign.
   * Can be called by only Proxy contract
   * @param campaignId uint256 Id of the campaign
   */
   // TODO: Need to mark distributed shares and rewards for the users
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

    uint256 campaignSaleCount = totalSupply.sub(currentSupply);
    // Calculate total revenue from the campaing
    uint256 revenue = _calculateRevenue(productId, campaignSaleCount);
    // Calculate and distribute shares to the influencers for each deal
    uint256 totalShare = _releaseInfluecerShares(campaignId, revenue);
    // Calculate and distribute rewards to the customers who has bought products in this campaign
    uint256 totalReward = _releaseCustomerRewards(campaignId, revenue);
    // Send the remaining revenue to the supplier
    _releaseSupplierShare(supplierId, revenue.sub(totalShare).sub(totalReward));
  }

  /**
   * @dev Calculates and distribute the shares earned by influencers who made sales in this campaing.
   * @param campaignId uint256 Id of the campaign
   * @param revenue uint256 Total revenue of this campaign
   */
   // FIXME: We may want to limit the number of deals under a campaign, because we may hit the block gas limit if there are too many deals due to iteration!!!
  function _releaseInfluecerShares(uint256 campaignId, uint256 revenue) private returns (uint256 totalShare) {
    // Get the all deals under this campaign
    uint256[] memory deals = campaignDB.getDeals(campaignId);
    // And distribute the shares for each deal's influencer
    for (uint i = 0; i < deals.length; i++) {
      (uint256 influencerId,,,uint256 ratio, uint256 saleCount) = dealDB.get(deals[i]);
      uint256 share = _calculateShare(revenue, saleCount, ratio);
      // In order to save some gas, do nothing if share is zero
      if (share > 0) {
        (address influencerAddress,) = actorDB.get(influencerId);
        totalShare = totalShare.add(share);
        escrow.payBack(influencerAddress, share);
      }
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
  function _releaseCustomerRewards(uint256 campaignId, uint256 revenue) private returns (uint256 totalReward) {
    (uint256 customerRewardRatio,,,) = escrow.getRewardRatios();
    // Get the all purchases under this campaign
    // Notice that getList() function gets only the references (ids) of the purchases
    // We need to get actual purchase data from PurchaseDB one by one with these references.
    uint256[] memory purchases = purchaseDB.getList(campaignId);
    // And distribute the rewards for each customer who purchased products from this campaign
    for (uint i = 0; i < purchases.length; i++) {
      (uint256 customerId,,uint256 purchaseAmount) = purchaseDB.get(campaignId, purchases[i]);
      uint256 reward = _calculateReward(revenue, purchaseAmount, customerRewardRatio);
      // In order to save some gas, do nothing if reward is zero
      if (reward > 0) {
        address customerAddress = actorDB.getAddress(customerId);
        totalReward = totalReward.add(reward);
        escrow.payBack(customerAddress, reward);
      }
    }
  }

  /**
   * @dev Distribute the remaining revenue after distributing influencer shares and customer rewards
   * @param supplierId uint256 Id of the campaign
   * @param remainginRevenue uint256 Remaining revenue after distributing influencer shares and customer rewards
   */
  function _releaseSupplierShare(uint256 supplierId, uint256 remainginRevenue) private {
    (address supplierAddress,) = actorDB.get(supplierId);
    escrow.payBack(supplierAddress, remainginRevenue);
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
   * @dev Calculates the revenue share for an influencer
   * @param revenue uint256 Total revenue of this campaign
   * @param saleCount uint256 Total number of sale made by an influencer in this campaign
   * @param dealRatio uint256 Deal ratio agreed between suppiler and influencer for this campaign. Ratio should be multiplied by 100 always. For example 20% => 2000
   */
  // TODO: Implementation may change when the calculation model is finalized
  function _calculateShare(uint256 revenue, uint256 saleCount, uint256 dealRatio) private pure returns (uint256) {
    return revenue.mul(saleCount).mul(dealRatio).div(10000);
  }

  /**
   * @dev Calculates the amount of reward earned by a customer
   * @param revenue uint256 Total revenue of this campaign
   * @param purchaseCount uint256 Total number of purchase made by a customer in this campaign
   * @param ratio uint256 Ratio constant for reward calculation 
   */
  // TODO: Implementation may change when the calculation model is finalized
  function _calculateReward(uint256 revenue, uint256 purchaseCount, uint256 ratio) private pure returns (uint256) {
    return 0;
  }
}