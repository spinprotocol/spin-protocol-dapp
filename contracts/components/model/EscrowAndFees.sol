pragma solidity 0.4.24;

import "../../libs/SafeMath.sol";
import "../../token/IERC20.sol";
import "../auth/SystemRoles.sol";
import "../system/Proxied.sol";
import "./IEscrowAndFees.sol";


/**
 * @title EscrowAndFees
 * @dev Manages escrow of deposited tokens and fees
 * @author Mustafa Morca - psychoplasma@gmail.com
 */
contract EscrowAndFees is Proxied, SystemRoles, IEscrowAndFees {
  using SafeMath for uint256;

  // Keeps track of amount of escrowed tokens per address
  mapping (address => uint256) public escrowLedger;

  // Total amount of token in escrow
  uint256 public totalLockedAmount;

  // Token escrowed in this contract
  IERC20 public token;

  address public feeCollector;

  struct RegistrationFees {
    uint256 campaign;
    uint256 product;
  }

  struct ShareAndRewardRatios {
    uint256 customer;
    uint256 influencer;
    uint256 supplier;
    uint256 serviceProvider;
  }

  RegistrationFees public registrationFees;

  ShareAndRewardRatios public shareAndRewardRatios;

  event ChargedFee(address indexed account, uint256 amount);


  function setToken(IERC20 _token)
    external
    onlyProxy
  {
    token = _token;
  }

  function setRegistrationFees(
    uint256 campaignRegistrationFee, 
    uint256 productRegistrationFee
  )
    external
    onlyProxy
  {
    if (campaignRegistrationFee > 0) {
      registrationFees.campaign = campaignRegistrationFee;
    }

    if (productRegistrationFee > 0) {
      registrationFees.product = productRegistrationFee;
    }
  }

  function setFeeCollector(address _feeCollector)
    external
    onlyProxy
  {
    require(_feeCollector != address(0));
    feeCollector = _feeCollector;
  }

  function setShareAndRewardRatios(
    uint256 customerRatio,
    uint256 influencerRatio,
    uint256 supplierRatio,
    uint256 serviceProviderRatio
  )
    external
    onlyProxy
  {
    shareAndRewardRatios.customer = customerRatio;
    shareAndRewardRatios.influencer = influencerRatio;
    shareAndRewardRatios.supplier = supplierRatio;
    shareAndRewardRatios.serviceProvider = serviceProviderRatio;
  }

  function withdraw(address account, uint256 amount)
    external
    onlyProxy
  {
    require(token.balanceOf(address(this)) >= amount.add(totalLockedAmount));
    require(token.transfer(account, amount));
  }

  function chargeCampaignRegistrationFee(address user)
    external
    onlyAuthorizedContract(CONTRACT_NAME_SPIN_PROTOCOL)
  {
    _chargeFee(user, registrationFees.campaign);
  }

  function chargeProductRegistrationFee(address user)
    external
    onlyAuthorizedContract(CONTRACT_NAME_SPIN_PROTOCOL)
  {
    _chargeFee(user, registrationFees.product);
  }

  function payBack(address to, uint256 amount)
    external
    onlyAuthorizedContract(CONTRACT_NAME_SPIN_PROTOCOL)
  {
    // totalLockedAmount = totalLockedAmount.sub(amount);
    require(token.transfer(to, amount));
  }

  function lock(address owner, uint256 amount)
    external
    onlyAuthorizedContract(CONTRACT_NAME_SPIN_PROTOCOL)
  {
    escrowLedger[owner] = escrowLedger[owner].add(amount);
    totalLockedAmount = totalLockedAmount.add(amount);
    require(token.transferFrom(owner, address(this), amount));
  }

  function releaseFrom(address from, address to, uint256 amount)
    external
    onlyAuthorizedContract(CONTRACT_NAME_SPIN_PROTOCOL)
  {
    escrowLedger[from] = escrowLedger[from].sub(amount);
    totalLockedAmount = totalLockedAmount.sub(amount);
    require(token.transfer(to, amount));
  }

  function getShareAndRewardRatios() external view returns (uint256, uint256, uint256, uint256) {
    return (
      shareAndRewardRatios.customer,
      shareAndRewardRatios.influencer,
      shareAndRewardRatios.supplier,
      shareAndRewardRatios.serviceProvider
    );
  }

  function _chargeFee(address account, uint256 fee) private {
    require(token.transferFrom(account, feeCollector, fee));
    emit ChargedFee(account, fee);
  }
}