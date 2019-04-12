pragma solidity 0.5.7;


/**
 * @title Roles
 * @dev Keeps roles for SpinProtocol system
 * @author Mustafa Morca - psychoplasma@gmail.com
 */
contract SystemRoles {
  string constant internal ROLE_INFLUENCER = "influencer";
  string constant internal ROLE_SUPPLIER = "supplier";
  string constant internal ROLE_CUSTOMER = "customer";
  string constant internal ROLE_SERVICE_PROVIDER = "service_provider";
  string constant internal ROLE_SPIN_PROTOCOL = "spin_protocol";

  function checkRole(
    string memory actualRole,
    string memory expectedRole
  )
    internal pure returns (bool)
  {
    return keccak256(abi.encodePacked(actualRole)) == keccak256(abi.encodePacked(expectedRole));
  }
}