pragma solidity ^0.4.24;

import "../../libs/LinkedListLib.sol";
import "../../libs/AccessRoles.sol";

/**
 * @title EternalStorage
 * @dev This contract holds all the necessary state variables to carry out the storage of any contract.
 */
contract EternalStorage {
  mapping(bytes32 => uint256) internal uintStorage;
  mapping(bytes32 => string) internal stringStorage;
  mapping(bytes32 => address) internal addressStorage;
  mapping(bytes32 => bytes) internal bytesStorage;
  mapping(bytes32 => bool) internal boolStorage;
  mapping(bytes32 => int256) internal intStorage;

  mapping(bytes32 => LinkedListLib.LinkedList) internal linkedListStorage;
}