pragma solidity ^0.4.24;

import "./EternalStorage.sol";
import "./LinkedListLib.sol";
import "./Proxied.sol";


/**
 * @title Generic Eternal Storage Unit which can only be accessed through the proxied contracts
 * @dev This contract holds all the necessary state variables to carry out the storage of any contract.
 * This contract is not supposed to re-deployed after it's deployed very first time. It should be persistent on the chain.
 * @author Mustafa Morca - psychoplasma@gmail.com
 */
contract UniversalDB is Proxied, EternalStorage {
  using LinkedListLib for LinkedListLib.LinkedList;

  function setIntStorage(
    string  contractName,
    bytes32 key,
    int256 value
  )
    external
    onlyAuthorizedContract(contractName)
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
    external
    onlyAuthorizedContract(contractName)
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
    external
    onlyAuthorizedContract(contractName)
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
    external
    onlyAuthorizedContract(contractName)
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
    external
    onlyAuthorizedContract(contractName)
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
    external
    onlyAuthorizedContract(contractName)
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
    external
    onlyAuthorizedContract(contractName) returns (bool)
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
    external
    onlyAuthorizedContract(contractName) returns (bool)
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
    public
    view returns (uint256[] memory nodes)
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

  function doesNodeExist(
    string memory contractName,
    bytes32 key,
    uint256 nodeId
  )
    public view returns (bool)
  {
    return linkedListStorage[keccak256(abi.encodePacked(contractName, key))].nodeExists(nodeId);
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