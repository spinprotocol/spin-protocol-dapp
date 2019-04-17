pragma solidity 0.5.7;

import "../../token/IERC20.sol";


/**
 * @title IEscrowAndFees
 * @author Mustafa Morca - psychoplasma@gmail.com
 */
interface IEscrowAndFees {

  function setToken(IERC20 _token) external;

  function setRegistrationFees(uint256[6] calldata _registrationFees) external;

  function setFeeCollector(address _feeCollector) external;

  function withdraw(uint256 amount) external;
}