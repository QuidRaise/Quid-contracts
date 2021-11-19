// SPDX-License-Identifier: MIT
import "../models/Schema.sol";
import "../models/EventModels.sol";

import "./SharedController.sol";
import "../libraries/SafeERC20.sol";
import "../libraries/ReentrancyGuard.sol";

import "./interface/ICompanyController.sol";
import "../store/interface/ICompanyStore.sol";
import "../store/interface/IProposalStore.sol";
import "../store/interface/IRoundStore.sol";
import "../vault/interface/ICompanyVault.sol";
import "../vault/InvestmentTokenVault.sol";

import "../store/interface/ICompanyVaultStore.sol";

import "../events/interface/IEventEmitter.sol";
import "../infrastructure/interface/IIdentityContract.sol";
import "../store/interface/IInvestorStore.sol";
import "../interfaces/IERC20.sol";
import "../interfaces/IConfig.sol";

pragma experimental ABIEncoderV2;
pragma solidity 0.7.0;

contract CompanyController is SharedController, ReentrancyGuard, ICompanyController {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    constructor(address dnsContract) SharedController(dnsContract) {
       
    }

    //Currently defaulting oracle to owner address
    // We would need to build a more robust oracle system for QuidRaise
    function createCompany(
        string calldata CompanyUrl,
        string calldata companyName,
        address companyTokenContractAddress,
        address companyOwner,
        address companyCreatedBy
    ) external override nonReentrant c2cCallValid {

        ICompanyStore _companyStore = ICompanyStore(_dns.getRoute(COMPANY_STORE));
        IInvestorStore _investorStore = IInvestorStore(_dns.getRoute(INVESTOR_STORE));
        IIdentityContract _identityContract = IIdentityContract(_dns.getRoute(IDENTITY_CONTRACT));


        bool isInvestor = _investorStore.isInvestor(companyOwner);
        require(!_companyStore.isCompanyOwner(companyOwner), "Company owner already owns a business");

        if (isInvestor) {
            require(_identityContract.isInvestorAddressWhitelisted(companyOwner), "Company owner address blacklisted as investor");
        }
        Company memory company = Company(0, companyName, CompanyUrl, companyTokenContractAddress, companyOwner);
        company.Id = _companyStore.createCompany(company);
        createCompanySecondStep(companyCreatedBy,company);
        
    }

    function createCompanySecondStep(address companyCreatedBy,Company memory company) internal
    {
        IEventEmitter _eventEmitter = IEventEmitter(_dns.getRoute(EVENT_EMITTER));
        IIdentityContract _identityContract = IIdentityContract(_dns.getRoute(IDENTITY_CONTRACT));

        _identityContract.whitelistCompanyAddress(company.OwnerAddress);
        _identityContract.whitelistCompany(company.Id);

        _eventEmitter.emitCompanyCreatedEvent(
            CompanyCreatedRequest(
                company.Id,
                company.OwnerAddress,
                companyCreatedBy,
                company.CompanyName,
                company.CompanyUrl,
                company.CompanyTokenContractAddress
            )
        );
    }

}
