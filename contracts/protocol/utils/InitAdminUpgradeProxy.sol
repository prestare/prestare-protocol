// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;


import "./BaseAdminUpgradeProxy.sol";
import "../../dependencies/proxy/InitUpgradeProxy.sol";

/**
 * @title InitializableAdminUpgradeabilityProxy
 * @dev Extends BaseAdminUpgradeabilityProxy with an initializer function
 */
contract InitializableImmutableAdminUpgradeabilityProxy is
    BaseImmutableAdminUpgradeabilityProxy,
    InitializableUpgradeabilityProxy
    {
    constructor(address admin) public BaseImmutableAdminUpgradeabilityProxy(admin) {}

    /**
    * @dev Only fall back when the sender is not the admin.
    */
    function _willFallback() internal override(BaseImmutableAdminUpgradeabilityProxy, Proxy) {
        BaseImmutableAdminUpgradeabilityProxy._willFallback();
    }
}