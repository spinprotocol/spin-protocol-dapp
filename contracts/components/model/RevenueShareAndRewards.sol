pragma solidity 0.5.7;

import "../../libs/SafeMath.sol";
import "../connectors/DBConnector.sol";
import "../connectors/EscrowConnector.sol";
import "../system/Proxied.sol";


/**
 * @title RevenueShareAndRewards
 * @dev Calculates R/S and rewards upon campaign completion and purchase
 * @author Mustafa Morca - psychoplasma@gmail.com
 */
contract RevenueShareAndRewards is EscrowConnector, DBConnector, Proxied {
  using SafeMath for uint256;

  function releaseRevenueShares(uint256 campaignId) external onlyProxy {
    // TODO: Implement later
  }

  function _sendCustomerReward(uint256 productId, uint256 customerId, uint256 purchaseAmount) internal {
    (uint256 customerRewardRatio,,,) = escrow.getRewardRatios();
    // TODO: Apply reward calculation logic
    uint256 reward = purchaseAmount.div(customerRewardRatio);

    (uint256 supplierId,,) = productDB.get(productId);
    address supplierAddress = actorDB.getAddress(supplierId);
    address customerAddress = actorDB.getAddress(customerId);

    // TODO: Decide how to transfer reward, i.e. from whose account
    escrow.releaseFrom(supplierAddress, customerAddress, reward);
  }
}