pragma solidity 0.5.7;

import "../auth/SystemRoles.sol";
import "../connectors/DBConnector.sol";
import "../connectors/EscrowConnector.sol";
import "../system/Proxied.sol";


/**
 * @title Registry
 * @dev Manages user, product and campaign registrations
 * @author Mustafa Morca - psychoplasma@gmail.com
 */
contract Registry is SystemRoles, EscrowConnector, DBConnector, Proxied {

  string constant private ERROR_ONLY_INFLUENCER = "Only influencer";
  string constant private ERROR_ONLY_SUPPLIER = "Only supplier";

  function registerActor(
    uint256 actorId,
    address actorAddress,
    string calldata role
  )
    external onlyProxy
  {
    actorDB.create(actorId, actorAddress, role);
    escrow.chargeRegistrationFee(actorAddress, role);
  }

  function registerCampaign(
    uint256 campaignId,
    uint256 supplierId,
    uint256 influencerId,
    uint256 productId,
    uint256 finishAt,
    uint256 ratio
  )
    external onlyProxy
  {
    (address supplierAddress, string memory supplierRole) = actorDB.get(supplierId);
    require(checkRole(supplierRole, ROLE_SUPPLIER), ERROR_ONLY_SUPPLIER);
    (address influencerAddress, string memory influencerRole) = actorDB.get(influencerId);
    require(checkRole(influencerRole, ROLE_INFLUENCER), ERROR_ONLY_INFLUENCER);
    campaignDB.create(campaignId, supplierId, influencerId, productId, finishAt, ratio);
    escrow.chargeCampaignRegistrationFee(supplierAddress, false);
    escrow.chargeCampaignRegistrationFee(influencerAddress, true);
  }

  function registerProduct(
    uint256 productId,
    uint256 supplierId,
    string calldata description
  )
    external onlyProxy
  {
    (address supplierAddress, string memory role) = actorDB.get(supplierId);
    require(checkRole(role, ROLE_SUPPLIER), ERROR_ONLY_SUPPLIER);
    productDB.create(productId, supplierId, description);
    escrow.chargeProductRegistrationFee(supplierAddress);
  }
}