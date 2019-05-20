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
    campaignDB.update(campaignId, productId, revenueRatio, totalSupply);
  }

  function updateSaleStart(
    uint256 campaignId,
    uint256[] appliedInfluencers,
    uint256 startAt,
    uint256 endAt
  )
    external onlyProxy
  {
    campaignDB.updateSaleStart(campaignId, appliedInfluencers, startAt, endAt);
  }

  function updateSaleEnd(
    uint256 campaignId
  ) 
    external onlyProxy
  {
    campaignDB.updateSaleEnd(campaignId);
  }
  
  function createRevenueLedger(
    uint256 revenueLedgerId,
    uint256[] influencerIds,
    uint256[] totalSalesPrices,
    uint256[] calculatedRevenues
  )
    external onlyProxy
  {
    revenueLedgerDB.create(revenueLedgerId, influencerIds, totalSalesPrices, calculatedRevenues);
  }
}