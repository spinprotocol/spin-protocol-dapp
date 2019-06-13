pragma solidity ^0.4.24;

import "./ProxyBase.sol";
import "../model/ISpinProtocol.sol";

/**
 * @title SpinProtocolProxy
 * @dev Creates proxy gateway for SpinProtocol module so that
 * function calls to that module can be done only through Proxy contract.
 */
contract SpinProtocolProxy is ProxyBase {

  function createCampaign(
    uint256 campaignId,
    uint256 productId,
    uint256 revenueRatio,
    uint256 totalSupply,
    uint256 startAt,
    uint256 endAt
  )
    external onlyAdmin
  {
    ISpinProtocol(addressOfSpinProtocol()).createCampaign(
      campaignId,
      productId,
      revenueRatio,
      totalSupply,
      startAt,
      endAt
    );
  }

  function updateCampaign(
    uint256 campaignId,
    uint256 productId,
    uint256 revenueRatio,
    uint256 totalSupply,
    uint256 startAt,
    uint256 endAt
  ) 
    external onlyAdmin
  {
    ISpinProtocol(addressOfSpinProtocol()).updateCampaign(
      campaignId,
      productId,
      revenueRatio,
      totalSupply,
      startAt,
      endAt
    );
  }

  function attendCampaign(
    uint256 campaignId,
    uint256 influencerId
  ) 
    external onlyAdmin
  {
    ISpinProtocol(addressOfSpinProtocol()).attendCampaign(
      campaignId,
      influencerId
    );
  }

  function cancelCampaign(
    uint256 campaignId,
    uint256 influencerId
  ) 
    external onlyAdmin
  {
    ISpinProtocol(addressOfSpinProtocol()).cancelCampaign(
      campaignId,
      influencerId
    );
  }

  function updateSaleEnd(
    uint256 campaignId,
    uint256 endAt
  ) 
    external onlyAdmin 
  {
    ISpinProtocol(addressOfSpinProtocol()).updateSaleEnd(
      campaignId,
      endAt
    );
  }

  function deleteCampaign(
    uint256 campaignId
  ) 
    external onlyAdmin 
  {
    ISpinProtocol(addressOfSpinProtocol()).deleteCampaign(
      campaignId
    );
  }
  
  function createRevenueLedger(
    uint256 revenueLedgerId,
    uint256 campaignId,
    uint256 influencerId,
    uint256 salesAmount,
    uint256 salesPrice,
    uint256 profit,
    uint256 revenueRatio,
    uint256 spinRatio,
    uint256 fiatRatio
  ) 
    external onlyAdmin
  {
    ISpinProtocol(addressOfSpinProtocol()).createRevenueLedger(
      revenueLedgerId,
      campaignId,
      influencerId,
      salesAmount,
      salesPrice,
      profit,
      revenueRatio,
      spinRatio,
      fiatRatio
    );
  }

  function updateIsAccount(
    uint256 revenueLedgerId
  ) 
    external onlyAdmin
  {
    ISpinProtocol(addressOfSpinProtocol()).updateIsAccount(
      revenueLedgerId
    );
  }

  function revenueShare(
    address _to,
    uint256 _revenue,
    uint256 _spinRatio,
    uint256 _marketPrice
  ) external onlyAdmin
  {
    ISpinProtocol(addressOfSpinProtocol()).revenueShare(
      _to,
      _revenue,
      _spinRatio,
      _marketPrice
    );
  }
}