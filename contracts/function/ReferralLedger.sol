pragma solidity ^0.4.24;

import "../libs/SafeMath.sol";
import "../components/token/TokenControl.sol";
import "./DataControl.sol"; 
import "./TokenUtil.sol"; 


/**
 * @title ReferralLedgerDB
 * @dev Manages referral ledger storage
 * CONTRACT_NAME = "ReferralLedger"
 * TABLE_KEY = keccak256(abi.encodePacked("Table"))
 */
contract ReferralLedger is DataControl, TokenControl {
  using SafeMath for uint256;

  event ReferralLedgerCreated(uint256 indexed referralLedgerId, uint256 indexed revenueLedgerId, string indexed toReferralUser);
  event ReferralLedgerDeleted(uint256 indexed referralLedgerId);

  function createReferralLedger(
    uint256 referralLedgerId,
    uint256 revenueLedgerId,
    uint256 amount,
    string fromReferralUser,
    string toReferralUser
  )
    public
    onlyAdmin
  {
    string memory CONTRACT_NAME = "ReferralLedger";
    bytes32 TABLE_KEY = keccak256(abi.encodePacked("Table"));

    require(referralLedgerId > 0, "ReferralLedger : referralLedgerId cannot be 0");
    require(revenueLedgerId > 0, "ReferralLedger : campaignId cannot be 0");
    require(pushNodeToLinkedList(CONTRACT_NAME, TABLE_KEY, referralLedgerId), "ReferralLedger : Item already exists");

    setUintStorage(CONTRACT_NAME, keccak256(abi.encodePacked(referralLedgerId, "revenueLedgerId")), revenueLedgerId);
    setUintStorage(CONTRACT_NAME, keccak256(abi.encodePacked(referralLedgerId, "amount")), amount);
    setStringStorage(CONTRACT_NAME, keccak256(abi.encodePacked(referralLedgerId, "fromReferralUser")), fromReferralUser);
    setStringStorage(CONTRACT_NAME, keccak256(abi.encodePacked(referralLedgerId, "toReferralUser")), toReferralUser);
    setBoolStorage(CONTRACT_NAME, keccak256(abi.encodePacked(referralLedgerId, "isAccount")), false);

    emit ReferralLedgerCreated(referralLedgerId, revenueLedgerId, toReferralUser);
  }

  function deleteReferralLedger(
    uint256 referralLedgerId
  )
    public
    onlyAdmin
    onlyExistentItem("ReferralLedger", referralLedgerId)
  {
    string memory CONTRACT_NAME = "ReferralLedger";
    bytes32 TABLE_KEY = keccak256(abi.encodePacked("Table"));

    require(removeNodeFromLinkedList(CONTRACT_NAME, TABLE_KEY, referralLedgerId), "ReferralLedger : Item does not exist");

    emit ReferralLedgerDeleted(referralLedgerId);
  }

  function getReferralLedger(
    uint256 referralLedgerId
  )
    public
    onlyExistentItem("ReferralLedger", referralLedgerId)
    view returns (
      uint256 revenueLedgerId,
      uint256 amount,
      string fromReferralUser,
      string toReferralUser,
      bool isAccount
    )
  {
    string memory CONTRACT_NAME = "ReferralLedger";
    revenueLedgerId = getUintStorage(CONTRACT_NAME, keccak256(abi.encodePacked(referralLedgerId, "revenueLedgerId")));
    amount = getUintStorage(CONTRACT_NAME, keccak256(abi.encodePacked(referralLedgerId, "amount")));
    fromReferralUser = getStringStorage(CONTRACT_NAME, keccak256(abi.encodePacked(referralLedgerId, "fromReferralUser")));
    toReferralUser = getStringStorage(CONTRACT_NAME, keccak256(abi.encodePacked(referralLedgerId, "toReferralUser")));
    isAccount = getBoolStorage(CONTRACT_NAME, keccak256(abi.encodePacked(referralLedgerId, "isAccount")));
  }

  function referralShare(
    uint256 referralLedgerId,
    address toAddr
  )
    public
    onlyAdmin
  {
    string memory CONTRACT_NAME = "ReferralLedger";
    (,uint256 amount,,,bool isAccount) = this.getReferralLedger(referralLedgerId);

    require(!isAccount, "Already share");

    _sendToken("SPIN", toAddr, amount);
    setBoolStorage(CONTRACT_NAME, keccak256(abi.encodePacked(referralLedgerId, "isAccount")), true);
  }
}
