pragma solidity ^0.4.24;

import "../../libs/SafeMath.sol";
import "../../token/IERC20.sol";

/**
 * @title Calculate
 * @dev Spin revenue transfer of inpluencer.
 */
contract Calculate {
    using SafeMath for uint256;

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
    function revenueSpin(uint256 _revenue, uint256 _spinRatio, uint256 _marketPrice) public pure returns(uint256 spin){
        spin = _revenue.mul(1 ether);
        spin = spin.mul(_spinRatio).div(_marketPrice);
        spin = rounding(spin,16);
    }
    
    /**
    * @dev Token transfer after calculates.
    */
    function _calculateSpin(address _tokenAddr, address _to, uint256 _revenue, uint256 _spinRatio, uint256 _marketPrice) internal {
        uint256 spin = revenueSpin(_revenue,_spinRatio,_marketPrice);
        IERC20 token = IERC20(_tokenAddr);
        require(token.transfer(_to,spin), "Token Transfer Fail");
    }
}
