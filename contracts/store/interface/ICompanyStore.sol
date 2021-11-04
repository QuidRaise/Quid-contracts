// SPDX-License-Identifier: MIT
import "../../models/Schema.sol";

pragma experimental ABIEncoderV2;
pragma solidity 0.7.0;

interface ICompanyStore {
    function isCompanyOwner(address ownerAddress) external returns (bool);

    function getCompanyById(uint256 id) external returns (Company memory);

    function getCompanyByOwner(address ownerAddress) external returns (Company memory);

    function updateCompany(Company memory company) external;
    function createCompany(Company memory company) external returns (uint256);
}
