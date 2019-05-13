pragma solidity ^0.4.24;

import "./Registry.sol";
import "../system/Proxied.sol";
import "./ISpinProtocol.sol";


/**
 * @title SpinProtocol
 * @dev Implements business logic of SPIN Protocol
 */
contract SpinProtocol is Proxied, ISpinProtocol, Registry {
}