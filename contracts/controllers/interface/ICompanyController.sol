// SPDX-License-Identifier: MIT
import "../../models/Schema.sol";

pragma experimental ABIEncoderV2;
pragma solidity 0.7.0;

interface ICompanyController {
    function createCompany(
        string calldata companyUrl,
        string calldata companyName,
        address companyTokenContractAddress,
        address companyOwner,
        address companyCreatedBy
    ) external;

}
