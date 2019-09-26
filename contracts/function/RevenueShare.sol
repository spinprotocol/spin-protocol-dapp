pragma solidity ^0.4.24;

import "../libs/SafeMath.sol";
import "../components/token/IERC20.sol";
import './RevenueLedger.sol';

/**
 * @title RevenueShare
 * @dev Spin revenue transfer of inpluencer.
 */
contract RevenueShare is RevenueLedger {
    using SafeMath for uint256;

    function sendToken(string _tokenName, address _to, uint256 _amt) public onlyAdmin {
        _sendToken(_tokenName, _to, _amt);
    }

    function _sendToken(string _tokenName, address _to, uint256 _amt) internal {
        IERC20 token = IERC20(getAddressStorage("SpinProtocol", keccak256(abi.encodePacked(_tokenName))));
        require(token.transfer(_to,_amt), "RevenueShare : Token Transfer Fail");
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
    ) public onlyAdmin {
        uint256 campaignId;
        bool isAccount;
        (campaignId,,,,,,,,isAccount) = getRevenueLedger(_revenueLedgerId);
        require(campaignId > 0 && !isAccount, "Empty data or already share");

        uint256 spin = revenueSpin(_spinAmount, _marketPrice, _rounding);
        _sendToken("SPIN", _to, spin);
        updateIsAccount(_revenueLedgerId,true);
    }

    function getBalance(string _tokenName) public view returns(uint256){
        IERC20 token = IERC20(getAddressStorage("SpinProtocol", keccak256(abi.encodePacked(_tokenName))));
        return token.balanceOf(this);
    }

    function setTokenAddr(address _tokenAddr, string _tokenName) public onlyAdmin {
        setAddressStorage("SpinProtocol", keccak256(abi.encodePacked(_tokenName)), _tokenAddr);
    }
}