pragma solidity ^0.4.24;

import './DataControl.sol';
import '../libs/SafeMath.sol';

/**
 * @title Product
 * @dev Manages product storage
 */
contract Product is DataControl {
  using SafeMath for uint256;

  event PurchaseAdd(string indexed category, uint256 indexed productId, uint256 indexed memberNo, uint256 count, uint256 updatedAt);
  event PurchaseSub(string indexed category, uint256 indexed productId, uint256 indexed memberNo, uint256 count, uint256 updatedAt);
  event ViewProduct(string indexed category, uint256 indexed productId, uint256 indexed memberNo, uint256 updatedAt);

  function viewProduct(string category, uint256 productId, uint256 memberNo) public onlyUser {
    uint256 viewCount = getUintStorage(category, keccak256(abi.encodePacked(productId, "view")));
    setUintStorage(category, keccak256(abi.encodePacked(productId, "view")), viewCount.add(1));

    emit ViewProduct(category, productId, memberNo, now);
  }

  function addPurchaseCount(
    string category,
    uint256 productId,
    uint256 count,
    uint256 memberNo
  )
    public
    onlyUser
  {
    require(count > 0, "Purchase : count cannot be 0");

    uint256 purchaseCount = getUintStorage(category, keccak256(abi.encodePacked(productId,"purchase")));
    uint256 personalCount = getUintStorage(category, keccak256(abi.encodePacked(productId, memberNo)));

    setUintStorage(category, keccak256(abi.encodePacked(productId, "purchase")), purchaseCount.add(count));
    setUintStorage(category, keccak256(abi.encodePacked(productId, memberNo)), personalCount.add(count));

    emit PurchaseAdd(category, productId, memberNo, count, now);
  }

  function subPurchaseCount(
    string category,
    uint256 productId,
    uint256 count,
    uint256 memberNo
  )
    public
    onlyUser
  {
    require(count > 0, "Purchase : count cannot be 0");

    uint256 purchaseCount = getUintStorage(category, keccak256(abi.encodePacked(productId, "purchase")));
    uint256 personalCount = getUintStorage(category, keccak256(abi.encodePacked(productId, memberNo)));

    setUintStorage(category, keccak256(abi.encodePacked(productId, "purchase")), purchaseCount.sub(count));
    setUintStorage(category, keccak256(abi.encodePacked(productId, memberNo)), personalCount.sub(count));

    emit PurchaseSub(category, productId, memberNo, count, now);
  }

  function getProductData(
    string category,
    uint256 productId
  )
    public
    view
    returns (
      uint256 viewCount,
      uint256 purchaseCount
    )
  {
    viewCount = getUintStorage(category, keccak256(abi.encodePacked(productId, "view")));
    purchaseCount = getUintStorage(category, keccak256(abi.encodePacked(productId, "purchase")));
  }

  function getPurchaseCountByUser(
    string category,
    uint256 productId,
    uint256 memberNo
  )
    public
    view
    returns(uint256)
  {
    return getUintStorage(category, keccak256(abi.encodePacked(productId, memberNo)));
  }

}