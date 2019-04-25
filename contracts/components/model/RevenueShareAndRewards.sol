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

  function releaseRevenueShares(uint256 campaignId) external onlyProxy {
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

    // Calculate total revenue from the campaing
    (,uint256 productPrice,) = productDB.get(productId);
    uint256 campaignSaleCount = totalSupply.sub(currentSupply);
    uint256 revenue = _calculateRevenue(campaignSaleCount, productPrice);

    // Calculate and distribute shares to influencers for each deal
    uint256[] memory deals = campaignDB.getDeals(campaignId);
    for (uint i = 0; i < deals.length; i++) {
      (uint256 influencerId,,,uint256 ratio, uint256 saleCount) = dealDB.get(deals[i]);
      (address influencerAddress,) = actorDB.get(influencerId);
      uint256 share = _calculateShare(campaignSaleCount, productPrice, saleCount, ratio);
      revenue = revenue.sub(share);
      escrow.payBack(influencerAddress, share);
    }

    // TODO: Payback customer rewards as well

    // Send the remaining revenue to supplier
    (address supplierAddress,) = actorDB.get(supplierId);
    escrow.payBack(supplierAddress, revenue);
  }

  function _releaseCustomerReward(uint256 productId, uint256 customerId, uint256 purchaseAmount) private {
    (uint256 customerRewardRatio,,,) = escrow.getRewardRatios();
    // TODO: Apply reward calculation logic
    uint256 reward = purchaseAmount.div(customerRewardRatio);

    (uint256 supplierId,,) = productDB.get(productId);
    address supplierAddress = actorDB.getAddress(supplierId);
    address customerAddress = actorDB.getAddress(customerId);

    // TODO: Decide how to transfer reward, i.e. from whose account
    escrow.releaseFrom(supplierAddress, customerAddress, reward);
  }

  function _calculateRevenue(uint256 campaignSaleCount, uint256 productPrice) private pure returns (uint256) {
    // TODO: Implement when the calculation model is set
    return productPrice.mul(campaignSaleCount);
  }

  function _calculateShare(uint256 campaignSaleCount, uint256 productPrice, uint256 saleCount, uint256 ratio) private pure returns (uint256) {
    // TODO: Implement when the calculation model is set
    return productPrice.mul(saleCount).div(campaignSaleCount).div(ratio);
  }

  function _calculateReward(uint256 campaignSaleCount, uint256 productPrice) private pure returns (uint256) {
    // TODO: Implement when the calculation model is set
    return 0;
  }
}