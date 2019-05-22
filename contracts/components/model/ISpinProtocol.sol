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
    uint256 startAt,
    uint256 endAt
  ) external;

  function updateSaleEnd(
    uint256 campaignId
  ) external;

  function attendCampaign(
    uint256 campaignId,
    uint256 influencerId
  ) external;

  function deleteCampaign(
    uint256 campaignId
  ) external;
  
  function createRevenueLedger(
    uint256 revenueLedgerId,
    uint256 campaignId,
    uint256 influencerId,
    uint256 salesAmount,
    uint256 salesPrice,
    uint256 rsSpinRatio,
    uint256 rsFiatRaito
  ) external;

  function updateIsAccount(
    uint256 revenueLedgerId
  ) external;

  /**
   * TO-DO
   */
  // function updateCurrentSupply(
  //   uint256 campaignId,
  //   uint256 purchaseAmount
  // ) external;
}