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
    uint256 totalSupply
  )
    external onlyAdmin
  {
    ISpinProtocol(addressOfSpinProtocol()).createCampaign(
      campaignId,
      productId,
      revenueRatio,
      totalSupply
    );
  }

  function updateCampaign(
    uint256 campaignId,
    uint256 productId,
    uint256 revenueRatio,
    uint256 totalSupply
  ) 
    external onlyAdmin
  {
    ISpinProtocol(addressOfSpinProtocol()).updateCampaign(
      campaignId,
      productId,
      revenueRatio,
      totalSupply
    );
  }

  function updateSaleStart(
    uint256 campaignId,
    uint256[] appliedInfluencers,
    uint256 startAt,
    uint256 endAt
  ) 
    external onlyAdmin
  {
    ISpinProtocol(addressOfSpinProtocol()).updateSaleStart(
      campaignId,
      appliedInfluencers,
      startAt,
      endAt
    );
  }

  function updateSaleEnd(
    uint256 campaignId
  ) 
    external onlyAdmin 
  {
    ISpinProtocol(addressOfSpinProtocol()).updateSaleEnd(
      campaignId
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
    uint256[] influencerIds,
    uint256[] totalSalesPrices,
    uint256[] calculatedRevenues
  ) 
    external onlyAdmin
  {
    ISpinProtocol(addressOfSpinProtocol()).createRevenueLedger(
      revenueLedgerId,
      influencerIds,
      totalSalesPrices,
      calculatedRevenues
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