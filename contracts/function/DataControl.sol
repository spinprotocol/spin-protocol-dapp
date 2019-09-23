pragma solidity ^0.4.24;

import '../components/system/EternalStorage.sol';
import "../libs/LinkedListLib.sol";
import "../components/auth/Authority.sol";

contract DataControl is EternalStorage, Authority{
  using LinkedListLib for LinkedListLib.LinkedList;

  modifier onlyExistentItem(string contractName, uint256 primaryIndex) {
    require(doesNodeExist(contractName, primaryIndex), "Item does not exist");
    _;
  }

  function doesNodeExist(string contractName, uint256 nodeId) 
    public
    view
    returns (bool)
  {
    return linkedListStorage[keccak256(abi.encodePacked(contractName, keccak256(abi.encodePacked("Table"))))].nodeExists(nodeId);
  }

  function setIntStorage(
    string  contractName,
    bytes32 key,
    int256 value
  )
    internal
    onlyAccessOwner
  {
    intStorage[keccak256(abi.encodePacked(contractName, key))] = value;
  }

  function getIntStorage(
    string memory contractName,
    bytes32 key
  )
    public view returns (int256)
  {
    return intStorage[keccak256(abi.encodePacked(contractName, key))];
  }

  function setUintStorage(
    string  contractName,
    bytes32 key,
    uint256 value
  )
    internal
    onlyAccessOwner
  {
    uintStorage[keccak256(abi.encodePacked(contractName, key))] = value;
  }

  function getUintStorage(
    string memory contractName,
    bytes32 key
  )
    public view returns (uint256)
  {
    return uintStorage[keccak256(abi.encodePacked(contractName, key))];
  }

  function setStringStorage(
    string  contractName,
    bytes32 key,
    string  value
  )
    internal
    onlyAccessOwner
  {
    stringStorage[keccak256(abi.encodePacked(contractName, key))] = value;
  }

  function getStringStorage(
    string memory contractName,
    bytes32 key
  )
    public view returns (string memory)
  {
    return stringStorage[keccak256(abi.encodePacked(contractName, key))];
  }

  function setAddressStorage(
    string  contractName,
    bytes32 key,
    address value
  )
    internal
    onlyAccessOwner
  {
    addressStorage[keccak256(abi.encodePacked(contractName, key))] = value;
  }

  function getAddressStorage(
    string memory contractName,
    bytes32 key
  )
    public view returns (address)
  {
    return addressStorage[keccak256(abi.encodePacked(contractName, key))];
  }

  function setBytesStorage(
    string  contractName,
    bytes32 key,
    bytes  value
  )
    internal
    onlyAccessOwner
  {
    bytesStorage[keccak256(abi.encodePacked(contractName, key))] = value;
  }

  function getBytesStorage(
    string memory contractName,
    bytes32 key
  )
    public view returns (bytes memory)
  {
    return bytesStorage[keccak256(abi.encodePacked(contractName, key))];
  }

  function setBoolStorage(
    string  contractName,
    bytes32 key,
    bool value
  )
    internal
    onlyAccessOwner
  {
    boolStorage[keccak256(abi.encodePacked(contractName, key))] = value;
  }

  function getBoolStorage(
    string memory contractName,
    bytes32 key
  )
    public view returns (bool)
  {
    return boolStorage[keccak256(abi.encodePacked(contractName, key))];
  }

  function pushNodeToLinkedList(
    string  contractName,
    bytes32 key,
    uint256 nodeId
  )
    internal
    onlyAccessOwner
    returns (bool)
  {
    if (linkedListStorage[keccak256(abi.encodePacked(contractName, key))].nodeExists(nodeId)) {
      return false;
    }

    linkedListStorage[keccak256(abi.encodePacked(contractName, key))].push(nodeId, true);
    return true;
  }

  function removeNodeFromLinkedList(
    string  contractName,
    bytes32 key,
    uint256 nodeId
  )
    internal
    onlyAccessOwner
    returns (bool)
  {
    if (!linkedListStorage[keccak256(abi.encodePacked(contractName, key))].nodeExists(nodeId)) {
      return false;
    }

    linkedListStorage[keccak256(abi.encodePacked(contractName, key))].remove(nodeId);
    return true;
  }

  function getAdjacent(
    string memory contractName,
    bytes32 key,
    uint256 nodeId,
    bool dir
  )
    public view returns (bool, uint256)
  {
    return linkedListStorage[keccak256(abi.encodePacked(contractName, key))].getAdjacent(nodeId, dir);
  }

  function getNodes(
    string memory contractName,
    bytes32 key
  )
    public view returns (uint256[] memory nodes)
  {
    uint256 nextNode;
    uint256 i;
    uint256 len = getLinkedListSize(contractName, key);
    nodes = new uint256[](len);

    do {
      (,nextNode) = getAdjacent(contractName, key, nextNode, true);
      if (nextNode > 0) {nodes[i++] = nextNode;}
    } while (nextNode != 0 && i < len);
  }

  function doesListExist(
    string memory contractName,
    bytes32 key
  )
    public view returns (bool)
  {
    return linkedListStorage[keccak256(abi.encodePacked(contractName, key))].listExists();
  }

  function getLinkedListSize(
    string memory contractName,
    bytes32 key
  )
    public view returns (uint256)
  {
    return linkedListStorage[keccak256(abi.encodePacked(contractName, key))].sizeOf();
  }
}