pragma solidity ^0.4.24;

import "../connectors/DBConnector.sol";
import "../system/Proxied.sol";
import "./ISpinProtocol.sol";

/**
 * @title Registry
 * @dev Manages user, product and campaign registrations
 */
contract Registry is DBConnector, Proxied {
  string private ERROR_ONLY_INFLUENCER = "Only influencer";
  string constant private ERROR_ONLY_SUPPLIER = "Only supplier";
  string constant private ERROR_PRODUCT_DOES_NOT_EXIST = "No such product on DB";
  string constant private ERROR_CAMPAIGN_ENDED = "Campaign ended already";

  //campaignDB
  function createCampaign(
    uint256 campaignId,
    uint256 productId,
    uint256 revenueRatio,
    uint256 totalSupply,
    uint256 startAt,
    uint256 endAt
  )
    external onlyProxy
  {
    campaignDB.createCampaign(
      campaignId,
      productId,
      revenueRatio,
      totalSupply,
      startAt,
      endAt
    );
  }

  function updateCampaign(
    uint256 campaignId,
    uint256 productId,
    uint256 revenueRatio,
    uint256 totalSupply,
    uint256 startAt,
    uint256 endAt
  )
    external onlyProxy
  {
    campaignDB.updateCampaign(
      campaignId,
      productId,
      revenueRatio,
      totalSupply,
      startAt,
      endAt
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

  function cancelCampaign(
    uint256 campaignId,
    uint256 influencerId
  )
    external onlyProxy
  {
    campaignDB.cancelCampaign(
      campaignId,
      influencerId
    );
  }

  function updateSaleEnd(
    uint256 campaignId,
    uint256 endAt
  )
    external onlyProxy
  {
    campaignDB.updateSaleEnd(
      campaignId,
      endAt
    );
  }

  function deleteCampaign(
    uint256 campaignId
  )
    external onlyProxy
  {
    campaignDB.deleteCampaign(campaignId);
  }

  //revenueLedgerDB
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
    uint256 revenueLedgerId,
    bool state
  )
    external onlyProxy
  {
    revenueLedgerDB.updateIsAccount(revenueLedgerId, state);
  }

  function deleteRevenueLedger(
    uint256 revenueLedgerId
  )
    external onlyProxy
  {
    revenueLedgerDB.deleteRevenueLedger(revenueLedgerId);
  }

  //PurchaseDB
  function addPurchaseCount(
    uint256 campaignId
  )
    external onlyProxy
  {
    purchaseDB.addPurchaseCount(campaignId);
  }

  function subPurchaseCount(
    uint256 campaignId
  )
    external onlyProxy
  {
    purchaseDB.subPurchaseCount(campaignId);
  }

  function resetPurchaseCount(
    uint256 campaignId
  )
    external onlyProxy
  {
    purchaseDB.resetPurchaseCount(campaignId);
  }
}