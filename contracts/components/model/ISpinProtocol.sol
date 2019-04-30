pragma solidity 0.4.24;


/**
 * @title ISpinProtocol
 * @author Mustafa Morca - psychoplasma@gmail.com
 */
interface ISpinProtocol {

  function attendCampaign(
    uint256 dealId,
    uint256 campaignId,
    uint256 influencerId,
    uint256 ratio
  ) external;

  function recordPurchase(
    uint256 purchaseId,
    uint256 customerId,
    uint256 campaignId,
    uint256 dealId,
    uint256 purchaseAmount
  ) external;

  function recordPurchaseBatch(
    uint256[]  purchaseIds,
    uint256[]  customerIds,
    uint256[]  campaignIds,
    uint256[]  dealIds,
    uint256[]  purchaseAmounts
  ) external;

  function releaseRevenue(uint256 campaignId) external;

  function releaseRewards(uint256 campaignId) external;

  function registerActor(
    uint256 actorId,
    address actorAddress,
    string  role
  ) external;

  function registerCampaign(
    uint256 campaignId,
    uint256 supplierId,
    uint256 productId,
    uint256 totalSupply,
    uint256 finishAt
  ) external;

  function registerProduct(
    uint256 productId,
    uint256 supplierId,
    uint256 price,
    string  metadata
  ) external;
}