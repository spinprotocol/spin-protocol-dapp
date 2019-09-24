pragma solidity ^0.4.24;

import './UpgradeabilityProxy.sol';
import '../auth/UpgradeabilityOwnerStorage.sol';

/**
 * @title OwnedUpgradeabilityProxy
 * @dev This contract combines an upgradeability proxy with basic authorization control functionalities
 */
contract OwnedUpgradeabilityProxy is UpgradeabilityOwnerStorage, UpgradeabilityProxy {
  /**
   * @dev Allows the upgradeability owner to upgrade the current version of the proxy.
   * @param version representing the version name of the new implementation to be set.
   * @param implementation representing the address of the new implementation to be set.
   */
  function upgradeTo(string version, address implementation) public onlyProxyOwner {
    _upgradeTo(version, implementation);
  }
}