pragma solidity ^0.4.24;

import './Campaign.sol';
import './RevenueLedger.sol';

/**
 * @title SpinProtocol
 */
contract SpinProtocol is Campaign, RevenueLedger {
    function setA() public onlyAccessOwner {
        setUintStorage("Test", keccak256(abi.encodePacked("Test")), 1);
    }

    function getA() public view returns (uint256) {
        return getUintStorage("Test", keccak256(abi.encodePacked("Test")));
    }
}