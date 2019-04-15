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
    uint256 customer;
    uint256 influencer;
    uint256 supplier;
    uint256 serviceProvider;
    uint256 campaign;
    uint256 product;
  }

  RegistrationFees public registrationFees;


  function setToken(IERC20 _token)
    external
    onlyProxy
  {
    token = _token;
  }

  function setRegistrationFees(uint256[6] calldata _registrationFees)
    external
    onlyProxy
  {
    if (_registrationFees[0] > 0) {
      registrationFees.customer = _registrationFees[0];
    }

    if (_registrationFees[1] > 0) {
      registrationFees.influencer = _registrationFees[1];
    }

    if (_registrationFees[2] > 0) {
      registrationFees.supplier = _registrationFees[2];
    }

    if (_registrationFees[3] > 0) {
      registrationFees.serviceProvider = _registrationFees[3];
    }

    if (_registrationFees[4] > 0) {
      registrationFees.campaign = _registrationFees[4];
    }

    if (_registrationFees[5] > 0) {
      registrationFees.product = _registrationFees[5];
    }
  }

  function setFeeCollector(address _feeCollector)
    external
    onlyProxy
  {
    require(_feeCollector != address(0));
    feeCollector = _feeCollector;
  }

  function withdraw(uint256 amount)
    external
    onlyProxy
  {
    require(token.balanceOf(address(this)) >= amount.add(totalLockedAmount));
    require(token.transfer(msg.sender, amount));
  }

  function chargeRegistrationFee(address user, string calldata role)
    external
    onlyAuthorizedContract(CONTRACT_NAME_SPIN_PROTOCOL)
  {
    if (checkRole(role, ROLE_INFLUENCER)) {
      require(token.transferFrom(user, feeCollector, registrationFees.influencer));
    } else if (checkRole(role, ROLE_SUPPLIER)) {
      require(token.transferFrom(user, feeCollector, registrationFees.supplier));
    } else if (checkRole(role, ROLE_SERVICE_PROVIDER)) {
      require(token.transferFrom(user, feeCollector, registrationFees.serviceProvider));
    } else if (checkRole(role, ROLE_CUSTOMER)) {
      require(token.transferFrom(user, feeCollector, registrationFees.customer));
    }
  }

  function chargeCampaignRegistrationFee(address user, bool isInfluencer)
    external
    onlyAuthorizedContract(CONTRACT_NAME_SPIN_PROTOCOL)
  {
    if (isInfluencer) {
      require(token.transferFrom(user, feeCollector, registrationFees.campaign));
    } else {
      require(token.transferFrom(user, feeCollector, registrationFees.campaign));
    }
  }

  function chargeProductRegistrationFee(address user)
    external
    onlyAuthorizedContract(CONTRACT_NAME_SPIN_PROTOCOL)
  {
    require(token.transferFrom(user, feeCollector, registrationFees.product));
  }

  function lock(address owner, uint256 amount)
    external
    onlyAuthorizedContract(CONTRACT_NAME_SPIN_PROTOCOL)
  {
    escrowLedger[owner] = escrowLedger[owner].add(amount);
    totalLockedAmount = totalLockedAmount.add(amount);
    require(token.transferFrom(owner, address(this), amount));
  }

  function release(address owner, uint256 amount)
    external
    onlyAuthorizedContract(CONTRACT_NAME_SPIN_PROTOCOL)
  {
    escrowLedger[owner] = escrowLedger[owner].sub(amount);
    totalLockedAmount = totalLockedAmount.sub(amount);
    require(token.transfer(owner, amount));
  }

  function releaseFrom(address from, address to, uint256 amount)
    external
    onlyAuthorizedContract(CONTRACT_NAME_SPIN_PROTOCOL)
  {
    escrowLedger[from] = escrowLedger[from].sub(amount);
    totalLockedAmount = totalLockedAmount.sub(amount);
    require(token.transfer(to, amount));
  }
}