// SPDX-License-Identifier: MIT
import "./DataGrant.sol";
import "./interfaces/IIdentityContract.sol";


pragma solidity 0.7.0;

contract IdentityContract is DataGrant,IIdentityContract {


    mapping(address=>bool) private _companyOwnerAddressWhitelist;
    mapping(uint=>bool) private _companyWhitelist;
    mapping(address=>bool) private _investorWhitelist;

    mapping(address=>mapping(address=>bool)) private _c2cWhitleist;

   constructor(address dnsContract) BaseContract(dnsContract) {

    }



    function whitelistCompanyAddress(address companyOwnerAddress) external override onlyDataAccessor 
    {
        _companyOwnerAddressWhitelist[companyOwnerAddress] = true;
    }

   
    function whitelistCompany(uint companyId)  external override onlyDataAccessor
    {
        _companyWhitelist[companyId] = true;
    }

   
    function whitelistInvestor(address investor) external override onlyDataAccessor 
    {
        _investorWhitelist[investor] = true;
    }


    function blacklistCompanyAddress(address companyOwnerAddress) external override onlyDataAccessor 
    {
        _companyOwnerAddressWhitelist[companyOwnerAddress] = false;
    }

  
    function blacklistCompany(uint companyId)  external override onlyDataAccessor
    {
        _companyWhitelist[companyId] = false;
    }


    function blacklistInvestor(address investor) external override onlyDataAccessor 
    {
        _investorWhitelist[investor] = false;
    }

    /**
     * We use this for validating that a caller can call functions on a particular contract
     * This function should be used in the modifiers of our contracts
     * Will implement a Grant contract where this would be used so all contracts can 
     * inherit from it and have the modifer already in place
     * Let's make life easier for Kelvin
     */
    function validateC2CTransaction(address sourceContract,address destinationContract) external view override returns (bool)
    {
            return _c2cWhitleist[sourceContract][destinationContract];
    }

    function grantContractInteraction(address sourceContract,address destinationContract) external override onlyOwner 
    {
        _c2cWhitleist[sourceContract][destinationContract] = true;
    }
    function revokeContractInteraction(address sourceContract, address destinationContract) external override onlyOwner 
    {
        _c2cWhitleist[sourceContract][destinationContract] = false;
    }

    function isCompanyAddressWhitelisted(address companyOwnerAddress) external view override returns(bool)
    {
            return _companyOwnerAddressWhitelist[companyOwnerAddress];
    }

    function isCompanyWhitelisted(uint companyId) external view override returns (bool)
    {
        return _companyWhitelist[companyId];
    }


    function isInvestorAddressWhitelisted(address companyOwnerAddress) external view override returns(bool)
    {
        return _investorWhitelist[companyOwnerAddress];
    }

}
