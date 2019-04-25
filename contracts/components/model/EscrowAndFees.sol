pragma solidity 0.5.7;

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

  struct RewardRatios {
    uint256 customer;
    uint256 influencer;
    uint256 supplier;
    uint256 serviceProvider;
  }

  RegistrationFees public registrationFees;

  RewardRatios public rewardRatios;

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

  function setRewardRatios(
    uint256 customerRatio,
    uint256 influencerRatio,
    uint256 supplierRatio,
    uint256 serviceProviderRatio
  )
    external
    onlyProxy
  {
    rewardRatios.customer = customerRatio;
    rewardRatios.influencer = influencerRatio;
    rewardRatios.supplier = supplierRatio;
    rewardRatios.serviceProvider = serviceProviderRatio;
  }

  function withdraw(uint256 amount)
    external
    onlyProxy
  {
    require(token.balanceOf(address(this)) >= amount.add(totalLockedAmount));
    require(token.transfer(msg.sender, amount));
  }

  function chargeCampaignRegistrationFee(address user)
    external
    onlyAuthorizedContract(CONTRACT_NAME_SPIN_PROTOCOL)
  {
    require(token.transferFrom(user, feeCollector, registrationFees.campaign));
  }

  function chargeProductRegistrationFee(address user)
    external
    onlyAuthorizedContract(CONTRACT_NAME_SPIN_PROTOCOL)
  {
    require(token.transferFrom(user, feeCollector, registrationFees.product));
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

  function getRewardRatios() external view returns (uint256, uint256, uint256, uint256) {
    return (
      rewardRatios.customer,
      rewardRatios.influencer,
      rewardRatios.supplier,
      rewardRatios.serviceProvider
    );
  }
}