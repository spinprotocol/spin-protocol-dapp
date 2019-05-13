pragma solidity ^0.4.24;

import "./ProxyBase.sol";
import "../model/ISpinProtocol.sol";


/**
 * @title SpinProtocolProxy
 * @dev Creates proxy gateway for SpinProtocol module so that
 * function calls to that module can be done only through Proxy contract.
 */
contract SpinProtocolProxy is ProxyBase {

  // function recordPurchase(
  //   uint256 purchaseId,
  //   uint256 customerId,
  //   uint256 campaignId,
  //   uint256 dealId,
  //   uint256 purchaseAmount
  // )
  //   external onlyAdmin
  // {
  //   ISpinProtocol(addressOfSpinProtocol()).recordPurchase(
  //     purchaseId,
  //     customerId,
  //     campaignId,
  //     dealId,
  //     purchaseAmount
  //   );
  // }

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
}