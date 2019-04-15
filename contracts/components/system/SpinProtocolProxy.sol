pragma solidity 0.5.7;

import "./ProxyBase.sol";
import "../model/SpinProtocol.sol";


/**
 * @title EscrowProxy
 * @dev Creates proxy gateway for EscrowAndFees module so that
 * function calls to that module can be done only through Proxy contract.
 * @author Mustafa Morca - psychoplasma@gmail.com
 */
contract SpinProtocolProxy is ProxyBase {

  function recordPurchase(
    uint256 campaignId,
    uint256 purchaseId,
    uint256 customerId,
    uint256 productId,
    uint256 transactionId,
    uint256 purchaseAmount,
    uint256 purchasedAt
  )
    external onlyAdmin
  {
    SpinProtocol(getContract(CONTRACT_NAME_SPIN_PROTOCOL)).recordPurchase(
      campaignId,
      purchaseId,
      customerId,
      productId,
      transactionId,
      purchaseAmount,
      purchasedAt
    );
  }

  function releaseRevenueShares(uint256 campaignId) external onlyAdmin {
    SpinProtocol(getContract(CONTRACT_NAME_SPIN_PROTOCOL)).releaseRevenueShares(campaignId);
  }

  function registerActor(
    uint256 actorId,
    address actorAddress,
    string calldata role
  )
    external onlyAdmin
  {
    SpinProtocol(getContract(CONTRACT_NAME_SPIN_PROTOCOL)).registerActor(actorId, actorAddress, role);
  }

  function registerCampaign(
    uint256 campaignId,
    uint256 supplierId,
    uint256 influencerId,
    uint256 productId,
    uint256 finishAt,
    uint256 ratio
  )
    external onlyAdmin
  {
    SpinProtocol(getContract(CONTRACT_NAME_SPIN_PROTOCOL)).registerCampaign(
      campaignId,
      supplierId,
      influencerId,
      productId,
      finishAt,
      ratio
    );
  }

  function registerProduct(
    uint256 productId,
    uint256 supplierId,
    string calldata description
  )
    external onlyAdmin
  {
    SpinProtocol(getContract(CONTRACT_NAME_SPIN_PROTOCOL)).registerProduct(productId, supplierId, description);
  }
}