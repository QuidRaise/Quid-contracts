// SPDX-License-Identifier: MIT

pragma solidity 0.7.0;

interface ICompanyVaultStore {
    function getCompanyTokenBalance(uint companyId) external view returns (uint);

    function getCompanyVaultBalance(uint companyId,address tokenContractAddress) external view returns (uint);
    
    function isSupportedCompanyPaymentOption(uint companyId, address tokenContractAddress) external  view  returns (bool);

    function getCompanyVaultBalanceCurrencies(uint companyId) external  view returns (address[] memory);

    function updateCompanyTokenBalance(uint companyId, uint amount) external;

    function updateCompanyVaultBalance(uint companyId, address tokenContractAddress, uint amount) external;

    function enablePaymentOption(address tokenContractAddress) external;

    function deletePaymentOption(address tokenContractAddress) external;

    function getPaymentOptions() external view returns (address[] memory);
    function isSupportedPaymentOption(address tokenContractAddress) external view returns (bool);
}
