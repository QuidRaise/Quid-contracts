// SPDX-License-Identifier: MIT

pragma solidity 0.7.0;

interface ICompanyVaultStore {
    function getCompanyTokenBalance(uint256 companyId) external view returns (uint256);

    function getCompanyVaultBalance(uint256 companyId, address tokenContractAddress) external view returns (uint256);

    function isSupportedCompanyPaymentOption(uint256 companyId, address tokenContractAddress) external view returns (bool);

    function getCompanyVaultBalanceCurrencies(uint256 companyId) external view returns (address[] memory);

    function updateCompanyTokenBalance(uint256 companyId, uint256 amount) external;

    function updateCompanyVaultBalance(
        uint256 companyId,
        address tokenContractAddress,
        uint256 amount
    ) external;

    function enablePaymentOption(address tokenContractAddress) external;

    function deletePaymentOption(address tokenContractAddress) external;

    function getPaymentOptions() external view returns (address[] memory);

    function isSupportedPaymentOption(address tokenContractAddress) external view returns (bool);
}
