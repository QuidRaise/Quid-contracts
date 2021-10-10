// SPDX-License-Identifier: MIT
import "./BaseContract.sol";
import "./DataGrant.sol";
import "./interfaces/ICompanyVaultStore.sol";

pragma solidity 0.7.0;

contract CompanyVaultStore is BaseContract, DataGrant, ICompanyVaultStore {
    /** @dev
     * Outer Key = Company Id
     * Inner Key  = Contract Address Of payment Currency (USDT, DAI, USDC, ... )
     * Inner Map Value = Balance in the payment currency
     */
     mapping(uint=>mapping(address=>uint)) private  _companyVaultBalance;

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

    function updateCompanyVaultBalance(uint companyId, address tokenContractAddress, uint amount) external override c2cCallValid
    {
        _companyVaultBalance[companyId][tokenContractAddress] = amount;

    }
}
