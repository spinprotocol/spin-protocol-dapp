pragma solidity ^0.4.24;

import "../model/EscrowAndFees.sol";
import "../auth/Admin.sol";


/**
 * @title EscrowConnector
 * @dev Connector for EscrowAndFees module. By inheriting this contract,
 * you can set and use EscrowAndFees module in the inheriting contract.
 * @author Mustafa Morca - psychoplasma@gmail.com
 */
contract EscrowConnector is Admin {
  EscrowAndFees public escrow;

  function setEscrow(EscrowAndFees _escrow) public onlyAdmin {
    escrow = _escrow;
  }
}