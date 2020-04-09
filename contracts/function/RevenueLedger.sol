pragma solidity ^0.4.24;

import "../libs/SafeMath.sol";
import "../components/token/TokenControl.sol";
import "./DataControl.sol"; 
import "./TokenUtil.sol"; 

/**
 * @title RevenueLedgerDB
 * @dev Manages revenue ledger storage
 * CONTRACT_NAME = "RevenueLedger"
 * TABLE_KEY = keccak256(abi.encodePacked("Table"))
 */
contract RevenueLedger is DataControl, TokenControl, TokenUtil {
  using SafeMath for uint256;

  event RevenueLedgerCreated(uint256 indexed revenueLedgerId);
  event RevenueLedgerUpdated(uint256 indexed revenueLedgerId, uint256 updatedAt);

  function createRevenueLedger(
    uint256 revenueLedgerId,
    uint256 campaignId,
    uint256 influencerId,
    uint256 salesAmount,
    uint256 salesPrice,
    uint256 profit,
    uint256 revenueRatio,
    uint256 spinRatio,
    uint256 fiatRatio
  )
    public
    onlyAdmin
  {
    string memory CONTRACT_NAME = "RevenueLedger";
    bytes32 TABLE_KEY = keccak256(abi.encodePacked("Table"));

    require(revenueLedgerId > 0, "RevenueLedger : revenueLedgerId cannot be 0");
    require(campaignId > 0, "RevenueLedger : campaignId cannot be 0");
    require(pushNodeToLinkedList(CONTRACT_NAME, TABLE_KEY, revenueLedgerId), "RevenueLedger : Item already exists");

    setUintStorage(CONTRACT_NAME, keccak256(abi.encodePacked(revenueLedgerId, "campaignId")), campaignId);
    setUintStorage(CONTRACT_NAME, keccak256(abi.encodePacked(revenueLedgerId, "influencerId")), influencerId);
    setUintStorage(CONTRACT_NAME, keccak256(abi.encodePacked(revenueLedgerId, "salesAmount")), salesAmount);
    setUintStorage(CONTRACT_NAME, keccak256(abi.encodePacked(revenueLedgerId, "salesPrice")), salesPrice);
    setUintStorage(CONTRACT_NAME, keccak256(abi.encodePacked(revenueLedgerId, "profit")), profit);
    setUintStorage(CONTRACT_NAME, keccak256(abi.encodePacked(revenueLedgerId, "revenueRatio")), revenueRatio);
    setUintStorage(CONTRACT_NAME, keccak256(abi.encodePacked(revenueLedgerId, "spinRatio")), spinRatio);
    setUintStorage(CONTRACT_NAME, keccak256(abi.encodePacked(revenueLedgerId, "fiatRatio")), fiatRatio);
    setBoolStorage(CONTRACT_NAME, keccak256(abi.encodePacked(revenueLedgerId, "isAccount")), false);

    emit RevenueLedgerCreated(revenueLedgerId);
  }

  function updateIsAccount(
    uint256 revenueLedgerId,
    bool state
  )
    public
    onlyAdmin
    onlyExistentItem("RevenueLedger", revenueLedgerId)
  {
    string memory CONTRACT_NAME = "RevenueLedger";
    setBoolStorage(CONTRACT_NAME, keccak256(abi.encodePacked(revenueLedgerId, "isAccount")), state);
    emit RevenueLedgerUpdated(revenueLedgerId, now);
  }

  function deleteRevenueLedger(
    uint256 revenueLedgerId
  )
    public
    onlyAdmin
    onlyExistentItem("RevenueLedger", revenueLedgerId)
  {
    string memory CONTRACT_NAME = "RevenueLedger";
    bytes32 TABLE_KEY = keccak256(abi.encodePacked("Table"));

    require(removeNodeFromLinkedList(CONTRACT_NAME, TABLE_KEY, revenueLedgerId), "RevenueLedger : Item does not exist");

    emit RevenueLedgerUpdated(revenueLedgerId, now);
  }

  function getRevenueLedger(
    uint256 revenueLedgerId
  )
    public
    onlyExistentItem("RevenueLedger", revenueLedgerId)
    view returns (
      uint256 campaignId,
      uint256 influencerId,
      uint256 salesAmount,
      uint256 salesPrice,
      uint256 profit,
      uint256 revenueRatio,
      uint256 spinRatio,
      uint256 fiatRatio,
      bool isAccount
    )
  {
    string memory CONTRACT_NAME = "RevenueLedger";
    campaignId = getUintStorage(CONTRACT_NAME, keccak256(abi.encodePacked(revenueLedgerId, "campaignId")));
    influencerId = getUintStorage(CONTRACT_NAME, keccak256(abi.encodePacked(revenueLedgerId, "influencerId")));
    salesAmount = getUintStorage(CONTRACT_NAME, keccak256(abi.encodePacked(revenueLedgerId, "salesAmount")));
    salesPrice = getUintStorage(CONTRACT_NAME, keccak256(abi.encodePacked(revenueLedgerId, "salesPrice")));
    profit = getUintStorage(CONTRACT_NAME, keccak256(abi.encodePacked(revenueLedgerId, "profit")));
    revenueRatio = getUintStorage(CONTRACT_NAME, keccak256(abi.encodePacked(revenueLedgerId, "revenueRatio")));
    spinRatio = getUintStorage(CONTRACT_NAME, keccak256(abi.encodePacked(revenueLedgerId, "spinRatio")));
    fiatRatio = getUintStorage(CONTRACT_NAME, keccak256(abi.encodePacked(revenueLedgerId, "fiatRatio")));
    isAccount = getBoolStorage(CONTRACT_NAME, keccak256(abi.encodePacked(revenueLedgerId, "isAccount")));
  }

  function getRevenueLedgerList()
    public
    view
    returns (uint256[] memory)
  {
    string memory CONTRACT_NAME = "RevenueLedger";
    bytes32 TABLE_KEY = keccak256(abi.encodePacked("Table"));
    return getNodes(CONTRACT_NAME, TABLE_KEY);
  }

  /**
    * @dev Token transfer after calculates.
    */
    function revenueShare(
        uint256 _revenueLedgerId,
        address _to,
        uint256 _tokenAmount,
        uint256 _marketPrice,
        uint256 _rounding
    ) public onlyAdmin {
        uint256 campaignId;
        bool isAccount;
        (campaignId,,,,,,,,isAccount) = getRevenueLedger(_revenueLedgerId);
        require(campaignId > 0 && !isAccount, "Empty data or already share");

        uint256 token = calculateToken(_tokenAmount, _marketPrice, _rounding);
        _sendToken("SPIN", _to, token);
        RevenueLedger.updateIsAccount(_revenueLedgerId, true);
    }
}