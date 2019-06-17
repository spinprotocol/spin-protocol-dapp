pragma solidity ^0.4.24;

import "../../libs/SafeMath.sol";
import "../../token/IERC20.sol";
import "../system/Proxied.sol";

/**
 * @title Calculate
 * @dev Spin revenue transfer of inpluencer.
 */
contract RevenueShare is Proxied {
    using SafeMath for uint256;

    IERC20 token;

    constructor (address _tokenAddr) public {
        require(_tokenAddr != address(0), "TokenAddr abnomal");
        token = IERC20(_tokenAddr);
    }

    function setTokenAddr(address _tokenAddr) external onlyAdmin {
        token = IERC20(_tokenAddr);
    }

    function sendToken(address _to, uint256 _amt) external onlyAdmin {
        _sendToken(_to, _amt);
    }

    function _sendToken(address _to, uint256 _amt) internal {
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
    function revenueSpin(uint256 _revenue, uint256 _spinRatio, uint256 _marketPrice, uint256 _rounding) public pure returns(uint256 spin){
        spin = _revenue.mul(1 ether);
        spin = spin.mul(_spinRatio).div(_marketPrice);
        spin = rounding(spin, uint256(18).sub(_rounding));
    }
    
    /**
    * @dev Token transfer after calculates.
    */
    function _revenueShare(address _to, uint256 _revenue, uint256 _spinRatio, uint256 _marketPrice, uint256 _rounding) internal {
        uint256 spin = revenueSpin(_revenue, _spinRatio, _marketPrice, _rounding);
        _sendToken(_to, spin);
    }

    function getBalance() public view returns(uint256){
        return token.balanceOf(this);
    }
}
