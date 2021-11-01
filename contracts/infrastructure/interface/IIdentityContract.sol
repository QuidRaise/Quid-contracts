// SPDX-License-Identifier: MIT
import "../models/Schema.sol";

pragma experimental ABIEncoderV2;
pragma solidity 0.7.0;

interface IIdentityContract {
    function whitelistCompanyAddress(address companyOwnerAddress) external;

    function whitelistCompany(uint256 companyId) external;

    function whitelistInvestor(address investor) external;

    function blacklistCompanyAddress(address companyOwnerAddress) external;

    function blacklistCompany(uint256 companyId) external;

    function blacklistInvestor(address investor) external;

    /**
     * We use this for validating that a caller can call functions on a particular contract
     * This function should be used in the modifiers of our contracts
     * Will implement a Grant contract where this would be used so all contracts can
     * inherit from it and have the modifer already in place
     * Let's make life easier for Kelvin
     */
    function validateC2CTransaction(address sourceContract, address destinationContract) external view returns (bool);

    function grantContractInteraction(address sourceContract, address destinationContract) external;

    function revokeContractInteraction(address sourceContract, address destinationContract) external;

    function isCompanyAddressWhitelisted(address companyOwnerAddress) external view returns (bool);

    function isCompanyWhitelisted(uint256 companyId) external view returns (bool);

    function isInvestorAddressWhitelisted(address companyOwnerAddress) external view returns (bool);
}
