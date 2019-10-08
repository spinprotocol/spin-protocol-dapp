pragma solidity ^0.4.24;

import "./IERC20.sol";
import '../../function/DataControl.sol';

/**
 * @title RevenueShare
 * @dev Spin revenue transfer of inpluencer.
 */
contract TokenControl is DataControl {
    function setTokenAddr(address _tokenAddr, string _tokenName) public onlyAdmin {
        setAddressStorage("SpinProtocol", keccak256(abi.encodePacked(_tokenName)), _tokenAddr);
    }

    function getTokenAddr(string _tokenName) public view returns(address) {
        return getAddressStorage("SpinProtocol", keccak256(abi.encodePacked(_tokenName)));
    }

    function sendToken(string _tokenName, address _to, uint256 _amt) public onlyAdmin {
        _sendToken(_tokenName, _to, _amt);
    }

    function _sendToken(string _tokenName, address _to, uint256 _amt) internal {
        IERC20 token = IERC20(getTokenAddr(_tokenName));
        require(token.transfer(_to,_amt), "RevenueShare : Token Transfer Fail");
    }

    function getBalance(string _tokenName) public view returns(uint256){
        IERC20 token = IERC20(getTokenAddr(_tokenName));
        return token.balanceOf(this);
    }
}