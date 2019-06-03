pragma solidity ^0.4.24;

/**
 * @title ISpinProtocol
 */
interface ISpinProtocol {
  
  function createCampaign(
    uint256 campaignId,
    uint256 productId,
    uint256 revenueRatio,
    uint256 totalSupply
  ) external;

  function updateCampaign(
    uint256 campaignId,
    uint256 productId,
    uint256 revenueRatio,
    uint256 totalSupply
  ) external;

  function updateSaleStart(
    uint256 campaignId,
    uint256[] appliedInfluencers,
    uint256 startAt,
    uint256 endAt
  ) external;

  function updateSaleEnd(
    uint256 campaignId
  ) external;

  function deleteCampaign(
    uint256 campaignId
  ) external;
  
  function createRevenueLedger(
    uint256 revenueLedgerId,
    uint256[] influencerIds,
    uint256[] totalSalesPrices,
    uint256[] calculatedRevenues
  ) external;

  function calculateSpin(
    address _to,
    uint256 _revenue,
    uint256 _spinRatio,
    uint256 _marketPrice
  ) external;

  /**
   * TO-DO
   */
  // function updateCurrentSupply(
  //   uint256 campaignId,
  //   uint256 purchaseAmount
  // ) external;
}