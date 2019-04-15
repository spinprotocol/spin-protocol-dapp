pragma solidity 0.5.7;

import "./Registry.sol";
import "./RevenueShareAndRewards.sol";
import "../system/Proxied.sol";
import "./ISpinProtocol.sol";


/**
 * @title
 * @dev
 * @author Mustafa Morca - psychoplasma@gmail.com
 */
contract SpinProtocol is Proxied, ISpinProtocol, Registry, RevenueShareAndRewards {
  
  function recordPurchase(
    uint256 campaignId,
    uint256 purchaseId,
    uint256 customerId,
    uint256 productId,
    uint256 transactionId,
    uint256 purchaseAmount,
    uint256 purchasedAt
  )
    external onlyProxy
  {
    purchaseDB.create(purchaseId, campaignId, customerId, productId, transactionId, purchaseAmount, purchasedAt);
    campaignDB.incrementSaleCount(campaignId);
    _sendCustomerReward(productId, customerId, purchaseAmount);
  }
}