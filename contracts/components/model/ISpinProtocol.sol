pragma solidity 0.5.7;


/**
 * @title EscrowProxy
 * @dev Creates proxy gateway for EscrowAndFees module so that
 * function calls to that module can be done only through Proxy contract.
 * @author Mustafa Morca - psychoplasma@gmail.com
 */
interface ISpinProtocol {

  function recordPurchase(
    uint256 campaignId,
    uint256 purchaseId,
    uint256 customerId,
    uint256 productId,
    uint256 transactionId,
    uint256 purchaseAmount,
    uint256 purchasedAt
  ) external;

  function releaseRevenueShares(uint256 campaignId) external;

  function registerActor(
    uint256 actorId,
    address actorAddress,
    string calldata role
  ) external;

  function registerCampaign(
    uint256 campaignId,
    uint256 supplierId,
    uint256 influencerId,
    uint256 productId,
    uint256 finishAt,
    uint256 ratio
  ) external;

  function registerProduct(
    uint256 productId,
    uint256 supplierId,
    string calldata description
  ) external;
}