pragma solidity ^0.4.24;

import "./AbstractDB.sol";
import "./Proxied.sol";


/**
 * @title ActorDB
 * @dev Manages actor(users: service provider, supplier, influencer, customer) storage in SpinProtocol system
 * @author Mustafa Morca - psychoplasma@gmail.com
 */
contract ActorDB is AbstractDB, Proxied {
  
  bytes32 private constant TABLE_KEY = keccak256(abi.encodePacked("ActorTable"));

  event ActorCreated(uint256 indexed actorId, address indexed actorAddress);
  event ActorUpdated(uint256 indexed actorId, uint256 updatedAd);


  constructor(UniversalDB _universalDB) public {
    setUniversalDB(_universalDB);
  }

  function create(
    uint256 actorId,
    address actorAddress,
    string  role
  )
    external
    onlyAuthorizedContract(CONTRACT_NAME_SPIN_PROTOCOL)
  {
    require(actorId > 0);
    require(actorAddress != address(0));
    // Creates a linked list with the given keys, if it does not exist
    // And push the new deal pointer to the list
    require(universalDB.pushNodeToLinkedList(CONTRACT_NAME_ACTOR_DB, TABLE_KEY, actorId), ERROR_ALREADY_EXIST);
    
    universalDB.setAddressStorage(CONTRACT_NAME_ACTOR_DB, keccak256(abi.encodePacked(actorId, "actorAddress")), actorAddress);
    universalDB.setStringStorage(CONTRACT_NAME_ACTOR_DB, keccak256(abi.encodePacked(actorId, "role")), role);
    emit ActorCreated(actorId, actorAddress);
  }

  function updateAddress(
    uint256 actorId,
    address actorAddress
  )
    external
    onlyAuthorizedContract(CONTRACT_NAME_SPIN_PROTOCOL)
    onlyExistentItem(actorId)
  {
    require(actorAddress != address(0));
    universalDB.setAddressStorage(CONTRACT_NAME_ACTOR_DB, keccak256(abi.encodePacked(actorId, "actorAddress")), actorAddress);
    emit ActorUpdated(actorId, block.timestamp);
  }

  function get(uint256 actorId)
    public
    onlyExistentItem(actorId)
    view returns (address actorAddress, string memory role)
  {
    actorAddress = universalDB.getAddressStorage(CONTRACT_NAME_ACTOR_DB, keccak256(abi.encodePacked(actorId, "actorAddress")));
    role = universalDB.getStringStorage(CONTRACT_NAME_ACTOR_DB, keccak256(abi.encodePacked(actorId, "role")));
  }

  function getAddress(uint256 actorId)
    public
    onlyExistentItem(actorId)
    view returns (address)
  {
    return universalDB.getAddressStorage(CONTRACT_NAME_ACTOR_DB, keccak256(abi.encodePacked(actorId, "actorAddress")));
  }

  function getRole(uint256 actorId)
    public
    onlyExistentItem(actorId)
    view returns (string memory)
  {
    return universalDB.getStringStorage(CONTRACT_NAME_ACTOR_DB, keccak256(abi.encodePacked(actorId, "role")));
  }

  function doesItemExist(uint256 actorId) public view returns (bool) {
    return universalDB.doesNodeExist(CONTRACT_NAME_ACTOR_DB, TABLE_KEY, actorId);
  }
}