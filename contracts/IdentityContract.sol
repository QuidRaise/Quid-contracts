// SPDX-License-Identifier: MIT
import "./DataGrant.sol";
import "./models/EventModels.sol";

import "./interfaces/IIdentityContract.sol";


pragma solidity 0.7.0;

contract IdentityContract is DataGrant,IIdentityContract {

    IEventEmitter _eventEmitter;

    mapping(address=>bool) private _companyOwnerAddressWhitelist;
    mapping(uint=>bool) private _companyWhitelist;
    mapping(address=>bool) private _investorWhitelist;

    mapping(address=>mapping(address=>bool)) private _c2cWhitleist;

   constructor(address dnsContract) BaseContract(dnsContract) {
        _eventEmitter = IEventEmitter(_dns.getRoute(EVENT_EMITTER));
    }



    function whitelistCompanyAddress(address companyOwnerAddress) external override onlyDataAccessor 
    {
        _companyOwnerAddressWhitelist[companyOwnerAddress] = true;
        _eventEmitter.emitWhitelistCompanyOwnerEvent(WhitelistCompanyOwnerRequest(companyOwnerAddress,_msgSender()));
    }

   
    function whitelistCompany(uint companyId)  external override onlyDataAccessor
    {
        _companyWhitelist[companyId] = true;
        _eventEmitter.emitWhitelistCompanyEvent(WhitelistCompanyRequest(companyId,_msgSender()));

    }

   
    function whitelistInvestor(address investor) external override onlyDataAccessor 
    {
        _investorWhitelist[investor] = true;
        _eventEmitter.emitWhitelistInvestorEvent(WhitelistInvestorRequest(investor,_msgSender()));

    }


    function blacklistCompanyAddress(address companyOwnerAddress) external override onlyDataAccessor 
    {
        _companyOwnerAddressWhitelist[companyOwnerAddress] = false;
        _eventEmitter.emitBlacklistCompanyOwnerEvent(WhitelistInvestorRequest(companyOwnerAddress,_msgSender()));

    }

  
    function blacklistCompany(uint companyId)  external override onlyDataAccessor
    {
        _companyWhitelist[companyId] = false;
        _eventEmitter.emitBlacklistCompanyEvent(BlacklistCompanyRequest(companyId,_msgSender()));

    }


    function blacklistInvestor(address investor) external override onlyDataAccessor 
    {
        _investorWhitelist[investor] = false;
        _eventEmitter.emitBlacklistInvestorEvent(BlacklistInvestorRequest(investor,_msgSender()));

    }

    /**
     * We use this for validating that a caller can call functions on a particular contract
     * This function should be used in the modifiers of our contracts
     * Will implement a Grant contract where this would be used so all contracts can 
     * inherit from it and have the modifer already in place
     * Let's make life easier for Kelvin
     */
    function validateC2CTransaction(address sourceContract,
                                    address destinationContract) external view override returns (bool)
    {
            return _c2cWhitleist[sourceContract][destinationContract];
    }

    function grantContractInteraction(address sourceContract,address destinationContract) external override onlyOwner 
    {
        _c2cWhitleist[sourceContract][destinationContract] = true;
        _eventEmitter.emitC2CAccessGrantEvent(C2CAccessGrantRequest(sourceContract,destinationContract,_msgSender()));

    }
    function revokeContractInteraction(address sourceContract, address destinationContract) external override onlyOwner 
    {
        _c2cWhitleist[sourceContract][destinationContract] = false;
        _eventEmitter.emitC2CAccessRevokedEvent(
            C2CAccessRevokedRequest(sourceContract,destinationContract,_msgSender())
        );

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
