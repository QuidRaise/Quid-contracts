// SPDX-License-Identifier: MIT

pragma solidity 0.7.0;

interface ICompanyVaultStore {
    function getCompanyTokenBalance(uint companyId) external view returns (uint);

    function getCompanyVaultBalance(uint companyId,address tokenContractAddress) external view returns (uint);

    function updateCompanyTokenBalance(uint companyId, uint amount) external;

    function updateCompanyVaultBalance(uint companyId, address tokenContractAddress, uint amount) external;
}
