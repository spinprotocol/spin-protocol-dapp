pragma solidity 0.5.7;

import "./ProxyBase.sol";
import "../../token/IERC20.sol";
import "../model/IEscrowAndFees.sol";


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
    IEscrowAndFees(addressOfEscrowAndFees()).setToken(_token);
  }

  function setRegistrationFees(
    uint256 campaignRegistrationFee, 
    uint256 productRegistrationFee
  )
    external
    onlyAdmin
  {
    IEscrowAndFees(addressOfEscrowAndFees()).setRegistrationFees(campaignRegistrationFee, productRegistrationFee);
  }

  function setRewardRatios(
    uint256 customerRatio,
    uint256 influencerRatio,
    uint256 supplierRatio,
    uint256 serviceProviderRatio
  )
    external
    onlyAdmin
  {
    IEscrowAndFees(addressOfEscrowAndFees()).setRewardRatios(
      customerRatio,
      influencerRatio,
      supplierRatio,
      serviceProviderRatio
    );
  }

  function setFeeCollector(address _feeCollector)
    external
    onlyAdmin
  {
    IEscrowAndFees(addressOfEscrowAndFees()).setFeeCollector(_feeCollector);
  }

  function withdraw(uint256 amount)
    external
    onlyAdmin
  {
    IEscrowAndFees(addressOfEscrowAndFees()).withdraw(msg.sender, amount);
  }
}