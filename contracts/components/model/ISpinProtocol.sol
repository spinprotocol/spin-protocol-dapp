pragma solidity 0.5.7;


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
    uint256[] calldata purchaseIds,
    uint256[] calldata customerIds,
    uint256[] calldata campaignIds,
    uint256[] calldata dealIds,
    uint256[] calldata purchaseAmounts
  ) external;

  function releaseRevenue(uint256 campaignId) external;

  function releaseRewards(uint256 campaignId) external;

  function registerActor(
    uint256 actorId,
    address actorAddress,
    string calldata role
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
    string calldata metadata
  ) external;
}