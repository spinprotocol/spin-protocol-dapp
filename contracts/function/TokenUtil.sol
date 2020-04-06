pragma solidity ^0.4.24;

import "../libs/SafeMath.sol";

/**
 * @title RevenueShare
 * @dev Spin revenue transfer of inpluencer.
 */
contract TokenUtil {
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
    function calculateToken(
        uint256 _tokenAmount,
        uint256 _marketPrice,
        uint256 _rounding
    ) public pure returns(uint256 token){
        token = _tokenAmount.mul(1 ether);
        token = token.div(_marketPrice);
        token = rounding(token, uint256(18).sub(_rounding));
    }
}