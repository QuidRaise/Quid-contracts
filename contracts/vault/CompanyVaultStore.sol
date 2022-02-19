// SPDX-License-Identifier: MIT
import "../infrastructure/BaseContract.sol";
import "../DataGrant.sol";
import "../models/Schema.sol";
import "../store/interface/ICompanyVaultStore.sol";

pragma solidity 0.7.0;

contract CompanyVaultStore is BaseContract, ICompanyVaultStore {
    /** @dev
     * Outer Key = Company Id
     * Inner Key  = Contract Address Of payment Currency (USDT, DAI, USDC, ... )
     * Inner Map Value = Balance in the payment currency
     */
    mapping(uint256 => mapping(address => uint256)) private _companyVaultBalance;
    mapping(uint256 => mapping(address => bool)) private _companyVaultSupportedCurrencies;

    // Store a list of currencies a company has used in receiveing payments
    mapping(uint256 => address[]) private _companySupportedPaymentOptions;

    // Stores a mapping of all supported payment currencies and if they're enabled or not
    mapping(address => SupportedPaymentOption) private _supportedPaymentOptions;

    address[] private _paymentOptions;

    /** @dev
     * Stores a mapping of companies to their tokens deposited with our platform
     */
    mapping(uint256 => uint256) private _companyTokenBalance;

    constructor(address dnsContract) BaseContract(dnsContract) {}

    function getCompanyTokenBalance(uint256 companyId) external view override returns (uint256) {
        return _companyTokenBalance[companyId];
    }

    function getCompanyVaultBalance(uint256 companyId, address tokenContractAddress) external view override returns (uint256) {
        return _companyVaultBalance[companyId][tokenContractAddress];
    }

    function updateCompanyTokenBalance(uint256 companyId, uint256 amount) external override c2cCallValid {
        _companyTokenBalance[companyId] = amount;
    }

    function isSupportedCompanyPaymentOption(uint256 companyId, address tokenContractAddress) external view override c2cCallValid returns (bool) {
        return _companyVaultSupportedCurrencies[companyId][tokenContractAddress];
    }

    function getCompanyVaultBalanceCurrencies(uint256 companyId) external view override c2cCallValid returns (address[] memory) {
        return _companySupportedPaymentOptions[companyId];
    }

    function updateCompanyVaultBalance(
        uint256 companyId,
        address tokenContractAddress,
        uint256 amount
    ) external override c2cCallValid {
        if (!_companyVaultSupportedCurrencies[companyId][tokenContractAddress]) {
            _companyVaultSupportedCurrencies[companyId][tokenContractAddress] = true;
            _companySupportedPaymentOptions[companyId].push(tokenContractAddress);
        }

        _companyVaultBalance[companyId][tokenContractAddress] = amount;
    }

    function enablePaymentOption(address tokenContractAddress) external override onlyOwner {
        if (!_supportedPaymentOptions[tokenContractAddress].Exists) {
            _paymentOptions.push(tokenContractAddress);
        }

        _supportedPaymentOptions[tokenContractAddress] = SupportedPaymentOption(true, true, _paymentOptions.length - 1);
    }

    function deletePaymentOption(address tokenContractAddress) external override onlyOwner {
        require(_supportedPaymentOptions[tokenContractAddress].Exists, "Payment option not found");
        require(_supportedPaymentOptions[tokenContractAddress].IsEnabled, "Payment option not enabled");

        uint256 recordIndex = _supportedPaymentOptions[tokenContractAddress].Index;

        _paymentOptions[recordIndex] = _paymentOptions[_paymentOptions.length - 1];

        _paymentOptions.pop();
        delete _supportedPaymentOptions[tokenContractAddress];
    }

    function getPaymentOptions() external view override returns (address[] memory) {
        return _paymentOptions;
    }

    function isSupportedPaymentOption(address tokenContractAddress) external view override returns (bool) {
        return _supportedPaymentOptions[tokenContractAddress].Exists && _supportedPaymentOptions[tokenContractAddress].IsEnabled;
    }
}
