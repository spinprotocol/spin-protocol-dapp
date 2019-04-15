pragma solidity 0.5.7;

import "./UniversalDB.sol";
import "../components/system/Proxied.sol";


/**
 * @title ActorDB
 * @dev Manages actor(users: service provider, supplier, influencer, customer) storage in SpinProtocol system
 * @author Mustafa Morca - psychoplasma@gmail.com
 */
contract ActorDB is Proxied {
  UniversalDB public universalDB;

  bytes32 private constant TABLE_KEY = keccak256(abi.encodePacked("ActorTable"));

  string private constant ERROR_ALREADY_EXIST = "Actor already exists";
  string private constant ERROR_DOES_NOT_EXIST = "Actor does not exist";

  event ActorCreated(uint256 indexed actorId, address indexed actorAddress);
  event ActorUpdated(uint256 indexed actorId, uint256 updatedAd);


  constructor(UniversalDB _universalDB) public {
    setUniversalDB(_universalDB);
  }

  function setUniversalDB(UniversalDB _universalDB)
    public
    onlyAdmin
  {
    universalDB = _universalDB;
  }

  function create(
    uint256 actorId,
    address actorAddress,
    string calldata role
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
  {
    require(universalDB.doesNodeExist(CONTRACT_NAME_ACTOR_DB, TABLE_KEY, actorId), ERROR_DOES_NOT_EXIST);
    require(actorAddress != address(0));
    universalDB.setAddressStorage(CONTRACT_NAME_ACTOR_DB, keccak256(abi.encodePacked(actorId, "actorAddress")), actorAddress);
    emit ActorUpdated(actorId, block.timestamp);
  }

  function updateSFame(
    uint256 actorId,
    uint256 sfame
  )
    external
    onlyAuthorizedContract(CONTRACT_NAME_SPIN_PROTOCOL)
  {
    require(universalDB.doesNodeExist(CONTRACT_NAME_ACTOR_DB, TABLE_KEY, actorId), ERROR_DOES_NOT_EXIST);
    universalDB.setUintStorage(CONTRACT_NAME_ACTOR_DB, keccak256(abi.encodePacked(actorId, "sfame")), sfame);
    emit ActorUpdated(actorId, block.timestamp);
  }

  function get(uint256 actorId)
    public view returns (address actorAddress, string memory role)
  {
    require(universalDB.doesNodeExist(CONTRACT_NAME_ACTOR_DB, TABLE_KEY, actorId), ERROR_DOES_NOT_EXIST);
    actorAddress = universalDB.getAddressStorage(CONTRACT_NAME_ACTOR_DB, keccak256(abi.encodePacked(actorId, "actorAddress")));
    role = universalDB.getStringStorage(CONTRACT_NAME_ACTOR_DB, keccak256(abi.encodePacked(actorId, "role")));
  }

  function getAddress(uint256 actorId)
    public view returns (address)
  {
    require(universalDB.doesNodeExist(CONTRACT_NAME_ACTOR_DB, TABLE_KEY, actorId), ERROR_DOES_NOT_EXIST);
    return universalDB.getAddressStorage(CONTRACT_NAME_ACTOR_DB, keccak256(abi.encodePacked(actorId, "actorAddress")));
  }

  function getRole(uint256 actorId)
    public view returns (string memory)
  {
    require(universalDB.doesNodeExist(CONTRACT_NAME_ACTOR_DB, TABLE_KEY, actorId), ERROR_DOES_NOT_EXIST);
    return universalDB.getStringStorage(CONTRACT_NAME_ACTOR_DB, keccak256(abi.encodePacked(actorId, "role")));
  }

  function getSFame(uint256 actorId)
    public view returns (uint256)
  {
    require(universalDB.doesNodeExist(CONTRACT_NAME_ACTOR_DB, TABLE_KEY, actorId), ERROR_DOES_NOT_EXIST);
    return universalDB.getUintStorage(CONTRACT_NAME_ACTOR_DB, keccak256(abi.encodePacked(actorId, "sfame")));
  }
}