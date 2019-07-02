pragma solidity ^0.4.24;

import "./Registry.sol";
import "../system/Proxied.sol";
import "./RevenueShare.sol";


/**
 * @title SpinProtocol
 * @dev Implements business logic of SPIN Protocol
 */
contract SpinProtocol is Registry, RevenueShare {

    constructor (Proxy _proxy, CampaignDB _campaignDB, RevenueLedgerDB _revenueLedgerDB, PurchaseDB _purchaseDB) public Proxied(_proxy) {
        setDataStore(_campaignDB, _revenueLedgerDB, _purchaseDB);
    }

}