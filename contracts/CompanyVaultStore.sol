// SPDX-License-Identifier: MIT
import "./BaseContract.sol";
import "./DataGrant.sol";
import "./models/Schema.sol";
import "./interfaces/ICompanyVaultStore.sol";

pragma solidity 0.7.0;

contract CompanyVaultStore is BaseContract, ICompanyVaultStore {
    /** @dev
     * Outer Key = Company Id
     * Inner Key  = Contract Address Of payment Currency (USDT, DAI, USDC, ... )
     * Inner Map Value = Balance in the payment currency
     */
     mapping(uint=>mapping(address=>uint)) private  _companyVaultBalance;
     mapping(uint=>mapping(address=>bool)) private  _companyVaultSupportedCurrencies;

     // Store a list of currencies a company has used in receiveing payments
     mapping(uint=> address[]) private _companySupportedPaymentOptions;

     // Stores a mapping of all supported payment currencies and if they're enabled or not
     mapping(address => SupportedPaymentOption) private _supportedPaymentOptions;

     address[] private _paymentOptions;



    /** @dev
     * Stores a mapping of companies to their tokens deposited with our platform 
    */
    mapping(uint=>uint) private _companyTokenBalance;

    constructor(address dnsContract) BaseContract(dnsContract) {

    }

    function getCompanyTokenBalance(uint companyId) external view override returns (uint)
    {
        return _companyTokenBalance[companyId];
    }

    function getCompanyVaultBalance(uint companyId,address tokenContractAddress) external view override returns (uint)
    {   
        return _companyVaultBalance[companyId][tokenContractAddress];

    }

    function updateCompanyTokenBalance(uint companyId, uint amount) external override c2cCallValid
    {
        _companyTokenBalance[companyId] = amount;
    }

    function isSupportedCompanyPaymentOption(uint companyId, address tokenContractAddress) external  view override c2cCallValid returns (bool) 
    {
        return _companyVaultSupportedCurrencies[companyId][tokenContractAddress];
    }

     function getCompanyVaultBalanceCurrencies(uint companyId) external  view override c2cCallValid returns (address[] memory) 
    {
        return _companySupportedPaymentOptions[companyId];
    }

    function updateCompanyVaultBalance(uint companyId, address tokenContractAddress, uint amount) external override c2cCallValid
    {
        if(!_companyVaultSupportedCurrencies[companyId][tokenContractAddress])
        {
            _companyVaultSupportedCurrencies[companyId][tokenContractAddress] = true;
            _companySupportedPaymentOptions[companyId].push(tokenContractAddress);
        }

        _companyVaultBalance[companyId][tokenContractAddress] = amount;

    }

    function enablePaymentOption(address tokenContractAddress) external override onlyOwner
    {
        if(!_supportedPaymentOptions[tokenContractAddress].Exists)
        {
            _paymentOptions.push(tokenContractAddress);
        }

        _supportedPaymentOptions[tokenContractAddress] = SupportedPaymentOption(true,true, _paymentOptions.length-1);
    }

     function deletePaymentOption(address tokenContractAddress) external override onlyOwner
    {
        require(_supportedPaymentOptions[tokenContractAddress].Exists,"Payment option not found");
        require(_supportedPaymentOptions[tokenContractAddress].IsEnabled,"Payment option not enabled");

        uint recordIndex = _supportedPaymentOptions[tokenContractAddress].Index;

        _paymentOptions[recordIndex] =  _paymentOptions[_paymentOptions.length-1];

        delete _paymentOptions[_paymentOptions.length-1];
        delete _supportedPaymentOptions[tokenContractAddress];
    }

    function getPaymentOptions() external view override returns (address[] memory)
    {
        return _paymentOptions;
    }

    function isSupportedPaymentOption(address tokenContractAddress) external override view returns (bool)
    {
        return _supportedPaymentOptions[tokenContractAddress].Exists &&
               _supportedPaymentOptions[tokenContractAddress].IsEnabled;
    }
}
