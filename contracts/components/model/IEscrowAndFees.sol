pragma solidity 0.5.7;

import "../../token/IERC20.sol";


/**
 * @title IEscrowAndFees
 * @author Mustafa Morca - psychoplasma@gmail.com
 */
interface IEscrowAndFees {

  function setToken(IERC20 _token) external;

  function setRegistrationFees(
    uint256 campaignRegistrationFee, 
    uint256 productRegistrationFee
  ) external;

   function setRewardRatios(
    uint256 customerRatio,
    uint256 influencerRatio,
    uint256 supplierRatio,
    uint256 serviceProviderRatio
  ) external;

  function setFeeCollector(address _feeCollector) external;

  function withdraw(address account, uint256 amount) external;
}