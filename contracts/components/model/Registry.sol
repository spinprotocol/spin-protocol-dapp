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
    campaignDB.createCampaign(
      campaignId, 
      productId, 
      revenueRatio, 
      totalSupply
    );
  }

  function updateCampaign(
    uint256 campaignId,
    uint256 productId,
    uint256 revenueRatio,
    uint256 totalSupply
  ) 
    external onlyProxy
  {
    campaignDB.updateCampaign(
      campaignId, 
      productId, 
      revenueRatio, 
      totalSupply
    );
  }

  function attendCampaign(
    uint256 campaignId,
    uint256 influencerId
  ) 
    external onlyProxy
  {
    campaignDB.attendCampaign(
      campaignId, 
      influencerId
    );
  }

  function updateSaleStart(
    uint256 campaignId,
    uint256 startAt
  )
    external onlyProxy
  {
    campaignDB.updateSaleStart(
      campaignId,
      startAt
    );
  }

  function updateSaleEnd(
    uint256 campaignId
  ) 
    external onlyProxy
  {
    campaignDB.updateSaleEnd(
      campaignId
    );
  }

  function deleteCampaign(
    uint256 campaignId
  ) 
    external onlyProxy
  {
    campaignDB.deleteCampaign(campaignId);
  }
  
  function createRevenueLedger(
    uint256 revenueLedgerId,
    uint256 campaignId,
    uint256 influencerId,
    uint256 salesAmount,
    uint256 salesPrice,
    uint256 profit,
    uint256 revenueRatio,
    uint256 spinRatio,
    uint256 fiatRatio
  )
    external onlyProxy
  {
    revenueLedgerDB.createRevenueLedger(
      revenueLedgerId,
      campaignId,
      influencerId,
      salesAmount,
      salesPrice,
      profit,
      revenueRatio,
      spinRatio,
      fiatRatio
    );
  }

  function updateIsAccount(
    uint256 revenueLedgerId
  )
    external onlyProxy
  {
    revenueLedgerDB.updateIsAccount(revenueLedgerId);
  }
}