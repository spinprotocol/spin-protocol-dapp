pragma solidity ^0.4.24;

import "../../libs/SafeMath.sol";
import "../../token/IERC20.sol";
import "../system/Proxied.sol";
import "./ISpinProtocol.sol";

/**
 * @title Calculate
 * @dev Spin revenue transfer of inpluencer.
 */
contract RevenueShare is Proxied {
    using SafeMath for uint256;

    function sendToken(address _to, uint256 _amt) external onlyAdmin {
        _sendToken(_to, _amt);
    }

    function _sendToken(address _to, uint256 _amt) internal {
        IERC20 token = IERC20(proxy.addressOfToken());
        require(token.transfer(_to,_amt), "Token Transfer Fail");
    }

    /**
    * @dev Decimal cropping.
    */
    function rounding(uint256 _value, uint256 _num) public pure returns(uint256){
        return _value / (10 ** _num) * (10 ** _num);
    }

    /**
    * @dev Calculates revenue.
    * @param _marketPrice : The value of this parameter must be (_marketPrice * 100) to resolve the decimal point issue.
    */
    function revenueSpin(
        uint256 _spinAmount,
        uint256 _marketPrice,
        uint256 _rounding
    ) public pure returns(uint256 spin){
        spin = _spinAmount.mul(1 ether).mul(100);
        spin = spin.div(_marketPrice);
        spin = rounding(spin, uint256(18).sub(_rounding));
    }

    /**
    * @dev Token transfer after calculates.
    */
    function revenueShare(
        uint256 _revenueLedgerId,
        address _to,
        uint256 _spinAmount,
        uint256 _marketPrice,
        uint256 _rounding
    ) external onlyProxy {
        uint256 campaignId;
        bool isAccount;
        (campaignId,,,,,,,,isAccount) = ISpinProtocol(proxy.getContract(CONTRACT_NAME_REVENUE_LEDGER_DB)).getRevenueLedger(_revenueLedgerId);
        require(campaignId > 0 && !isAccount, "Empty data or already share");

        uint256 spin = revenueSpin(_spinAmount, _marketPrice, _rounding);
        _sendToken(_to, spin);
        ISpinProtocol(proxy.getContract(CONTRACT_NAME_REVENUE_LEDGER_DB)).updateIsAccount(_revenueLedgerId,true);
    }

    function getBalance() public view returns(uint256){
        IERC20 token = IERC20(proxy.addressOfToken());
        return token.balanceOf(this);
    }
}
