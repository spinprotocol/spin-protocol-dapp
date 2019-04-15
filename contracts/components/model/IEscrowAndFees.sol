pragma solidity 0.5.7;

import "../../token/IERC20.sol";


/**
 * @title EscrowProxy
 * @dev Creates proxy gateway for EscrowAndFees module so that
 * function calls to that module can be done only through Proxy contract.
 * @author Mustafa Morca - psychoplasma@gmail.com
 */
interface IEscrowAndFees {

  function setToken(IERC20 _token) external;

  function setRegistrationFees(uint256[6] calldata _registrationFees) external;

  function setFeeCollector(address _feeCollector) external;

  function withdraw(uint256 amount) external;
}