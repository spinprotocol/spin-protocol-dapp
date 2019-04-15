pragma solidity 0.5.7;

import "./ProxyBase.sol";
import "../model/EscrowAndFees.sol";


/**
 * @title EscrowProxy
 * @dev Creates proxy gateway for EscrowAndFees module so that
 * function calls to that module can be done only through Proxy contract.
 * @author Mustafa Morca - psychoplasma@gmail.com
 */
contract EscrowProxy is ProxyBase {

  function setToken(IERC20 _token)
    external
    onlyAdmin
  {
    EscrowAndFees(getContract(CONTRACT_NAME_ESCROW_AND_FEES)).setToken(_token);
  }

  function setRegistrationFees(uint256[6] calldata _registrationFees)
    external
    onlyAdmin
  {
    EscrowAndFees(getContract(CONTRACT_NAME_ESCROW_AND_FEES)).setRegistrationFees(_registrationFees);
  }

  function setFeeCollector(address _feeCollector)
    external
    onlyAdmin
  {
    EscrowAndFees(getContract(CONTRACT_NAME_ESCROW_AND_FEES)).setFeeCollector(_feeCollector);
  }

  function withdraw(uint256 amount)
    external
    onlyAdmin
  {
    EscrowAndFees(getContract(CONTRACT_NAME_ESCROW_AND_FEES)).withdraw(amount);
  }
}