pragma solidity ^0.4.24;

import './DataControl.sol';
import '../libs/SafeMath.sol';

/**
 * @title PurchaseDB
 * @dev Manages purchase storage
 * CONTRACT_NAME = "Purchase"
 */
contract Purchase is DataControl {
  using SafeMath for uint256;

  event PurchaseAdd(string indexed category, uint256 indexed productId, string indexed userId, uint256 count, uint256 updatedAt);
  event PurchaseSub(string indexed category, uint256 indexed productId, string indexed userId, uint256 count, uint256 updatedAt);
  event PurchaseReset(string indexed category, uint256 indexed productId, uint256 resetAt);

  function addPurchaseCount(
    string category,
    uint256 productId,
    uint256 count,
    string userId
  )
    public
    onlyUser
  {
    require(count > 0, "Purchase : count cannot be 0");

    uint256 purchaseCount = getUintStorage(category, keccak256(abi.encodePacked(productId,"count")));

    setUintStorage(category, keccak256(abi.encodePacked(productId, "count")), purchaseCount.add(count));

    emit PurchaseAdd(category, productId, userId, count, now);
  }

  function subPurchaseCount(
    string category,
    uint256 productId,
    uint256 count,
    string userId
  )
    public
    onlyUser
  {
    require(count > 0, "Purchase : count cannot be 0");

    uint256 purchaseCount = getUintStorage(category, keccak256(abi.encodePacked(productId, "count")));

    setUintStorage(category, keccak256(abi.encodePacked(productId, "count")), purchaseCount.sub(count));

    emit PurchaseSub(category, productId, userId, count, now);
  }

  function resetPurchaseCount(
    string category,
    uint256 productId
  )
    public
    onlyAdmin
  {
    setUintStorage(category, keccak256(abi.encodePacked(productId, "count")), 0);

    emit PurchaseReset(category, productId, now);
  }

  function getPurchaseCount(
    string category,
    uint256 productId
  )
    public
    view
    returns(uint256)
  {
    return getUintStorage(category, keccak256(abi.encodePacked(productId, "count")));
  }
}