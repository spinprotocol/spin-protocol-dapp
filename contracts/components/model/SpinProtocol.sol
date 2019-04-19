pragma solidity 0.5.7;

import "./Registry.sol";
import "./RevenueShareAndRewards.sol";
import "../system/Proxied.sol";
import "./ISpinProtocol.sol";


/**
 * @title SpinProtocol
 * @dev Implements business logic of SPIN Protocol
 * @author Mustafa Morca - psychoplasma@gmail.com
 */
contract SpinProtocol is Proxied, ISpinProtocol, Registry, RevenueShareAndRewards {
}