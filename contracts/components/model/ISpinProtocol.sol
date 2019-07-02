pragma solidity ^0.4.24;

/**
 * @title ISpinProtocol
 */
interface ISpinProtocol {
  
  function createCampaign(
    uint256 campaignId,
    uint256 productId,
    uint256 revenueRatio,
    uint256 totalSupply,
    uint256 startAt,
    uint256 endAt
  ) external;

  function updateCampaign(
    uint256 campaignId,
    uint256 productId,
    uint256 revenueRatio,
    uint256 totalSupply,
    uint256 startAt,
    uint256 endAt
  ) external;

  function updateSaleEnd(
    uint256 campaignId,
    uint256 endAt
  ) external;

  function attendCampaign(
    uint256 campaignId,
    uint256 influencerId
  ) external;

  function cancelCampaign(
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
    uint256 profit,
    uint256 revenueRatio,
    uint256 spinRatio,
    uint256 fiatRatio
  ) external;

  function updateIsAccount(
    uint256 revenueLedgerId,
    bool state
  ) external;

  function revenueShare(
    uint256 _revenueLedgerId,
    address _to,
    uint256 _revenue,
    uint256 _spinRatio,
    uint256 _marketPrice,
    uint256 _rounding
  ) external;

  function deleteRevenueLedger(
    uint256 revenueLedgerId
  ) external;

  function getRevenueLedger(
    uint256 revenueLedgerId
  ) external returns(uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256,bool);

  function addPurchaseCount(
    uint256 campaignId
  ) external;

  function subPurchaseCount(
    uint256 campaignId
  ) external;

  function resetPurchaseCount(
    uint256 campaignId
  ) external;
  /**
   * TO-DO
   */
  // function updateCurrentSupply(
  //   uint256 campaignId,
  //   uint256 purchaseAmount
  // ) external;
}