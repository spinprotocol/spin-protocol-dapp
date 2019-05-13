pragma solidity ^0.4.24;


/**
 * @title ISpinProtocol
 */
interface ISpinProtocol {
  
  function registerCampaign(
    uint256 campaignId,
    uint256 productId,
    uint256 ratio,
    uint256 totalSupply,
    uint256 finishAt
  ) external;

  // function attendCampaign(
  //   uint256 campaignId,
  //   uint256 influencerId,
  //   uint256 ratio
  // ) external;

  // function recordPurchase(
  //   uint256 purchaseId,
  //   uint256 customerId,
  //   uint256 campaignId,
  //   uint256 purchaseAmount
  // ) external;
}