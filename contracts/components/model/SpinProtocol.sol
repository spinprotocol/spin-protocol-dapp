pragma solidity ^0.4.24;

import "./Registry.sol";
import "../system/Proxied.sol";
import "./RevenueShare.sol";


/**
 * @title SpinProtocol
 * @dev Implements business logic of SPIN Protocol
 */
contract SpinProtocol is Registry, RevenueShare {

    constructor (address _tokenAddr) public RevenueShare(_tokenAddr) {
    }

    function revenueShare(uint256 _revenueLedgerId, address _to, uint256 _revenue, uint256 _spinRatio, uint256 _marketPrice, uint256 _rounding)
        external
        onlyProxy
    {
        uint256 campaignId;
        bool isAccount;
        (campaignId,,,,,,,,isAccount) = revenueLedgerDB.getRevenueLedger(_revenueLedgerId);
        require(campaignId > 0 && !isAccount, "Empty data or already share");
        
        _revenueShare(_to, _revenue, _spinRatio, _marketPrice, _rounding);
        revenueLedgerDB.updateIsAccount(_revenueLedgerId, true);
    }
}