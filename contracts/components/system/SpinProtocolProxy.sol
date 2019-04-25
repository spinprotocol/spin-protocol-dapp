pragma solidity 0.5.7;

import "./ProxyBase.sol";
import "../model/ISpinProtocol.sol";


/**
 * @title SpinProtocolProxy
 * @dev Creates proxy gateway for SpinProtocol module so that
 * function calls to that module can be done only through Proxy contract.
 * @author Mustafa Morca - psychoplasma@gmail.com
 */
contract SpinProtocolProxy is ProxyBase {

  function attendCampaign(
    uint256 dealId,
    uint256 campaignId,
    uint256 influencerId,
    uint256 ratio
  )
    external
    onlyAdmin
  {
    ISpinProtocol(addressOfSpinProtocol()).attendCampaign(
      dealId,
      campaignId,
      influencerId,
      ratio
    );
  }

  function recordPurchase(
    uint256 purchaseId,
    uint256 customerId,
    uint256 campaignId,
    uint256 dealId,
    uint256 purchaseAmount
  )
    external onlyAdmin
  {
    ISpinProtocol(addressOfSpinProtocol()).recordPurchase(
      purchaseId,
      customerId,
      campaignId,
      dealId,
      purchaseAmount
    );
  }

  function recordPurchaseBatch(
    uint256[] calldata purchaseIds,
    uint256[] calldata customerIds,
    uint256[] calldata campaignIds,
    uint256[] calldata dealIds,
    uint256[] calldata purchaseAmounts
  )
    external onlyAdmin
  {
    // ISpinProtocol(addressOfSpinProtocol()).recordPurchaseBatch(
    //   purchaseIds,
    //   customerIds,
    //   campaignIds,
    //   dealIds,
    //   purchaseAmounts
    // );
  }

  function releaseRevenueShares(uint256 campaignId)
    external onlyAdmin
  {
    ISpinProtocol(addressOfSpinProtocol()).releaseRevenueShares(campaignId);
  }

  function registerActor(
    uint256 actorId,
    address actorAddress,
    string calldata role
  )
    external onlyAdmin
  {
    ISpinProtocol(addressOfSpinProtocol()).registerActor(actorId, actorAddress, role);
  }

  function registerCampaign(
    uint256 campaignId,
    uint256 supplierId,
    uint256 productId,
    uint256 totalSupply,
    uint256 finishAt
  )
    external onlyAdmin
  {
    ISpinProtocol(addressOfSpinProtocol()).registerCampaign(
      campaignId,
      supplierId,
      productId,
      totalSupply,
      finishAt
    );
  }

  function registerProduct(
    uint256 productId,
    uint256 supplierId,
    uint256 price,
    string calldata metadata
  )
    external onlyAdmin
  {
    ISpinProtocol(addressOfSpinProtocol()).registerProduct(productId, supplierId, price, metadata);
  }
}