pragma solidity ^0.4.24;

import "./Registry.sol";
import "../system/Proxied.sol";
import "./ISpinProtocol.sol";
import "./RevenueShare.sol";


/**
 * @title SpinProtocol
 * @dev Implements business logic of SPIN Protocol
 */
contract SpinProtocol is Proxied, ISpinProtocol, Registry, RevenueShare  {
    address tokenAddr = 0x4A39a3E9B5793aBE14157615e979e00758Ec902a; //set funtion is require

    function revenueShare(address _to, uint256 _revenue, uint256 _spinRatio, uint256 _marketPrice) external onlyProxy{
        _revenueShare(tokenAddr, _to, _revenue, _spinRatio, _marketPrice);
    }
}