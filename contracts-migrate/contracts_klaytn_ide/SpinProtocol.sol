pragma solidity ^0.4.24;

import "./Registry.sol";
import "./RevenueShareAndRewards.sol";
import "./Proxied.sol";
import "./ISpinProtocol.sol";


/**
 * @title SpinProtocol
 * @dev Implements business logic of SPIN Protocol
 * @author Mustafa Morca - psychoplasma@gmail.com
 */
contract SpinProtocol is Proxied, ISpinProtocol, Registry, RevenueShareAndRewards {
}