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

}