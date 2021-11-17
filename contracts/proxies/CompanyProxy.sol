// SPDX-License-Identifier: MIT
import "../DataGrant.sol";

import "../infrastructure/BaseContract.sol";
import "../libraries/ReentrancyGuard.sol";

import "../controllers/interface/ICompanyController.sol";
import "../controllers/interface/IInvestorController.sol";


pragma experimental ABIEncoderV2;
pragma solidity 0.7.0;

contract CompanyProxy is BaseContract, DataGrant, ReentrancyGuard {
   

    constructor(address dnsContract) BaseContract(dnsContract) {
       
    }

    //Currently defaulting oracle to owner address
    // We would need to build a more robust oracle system for QuidRaise
    function createCompany(
        string calldata CompanyUrl,
        string calldata companyName,
        address companyTokenContractAddress,
        address companyOwner
    ) external nonReentrant onlyDataAccessor {

        ICompanyController controller  = ICompanyController(_dns.getRoute("COMPANY_CONTROLLER"));
        controller.createCompany(CompanyUrl,companyName,companyTokenContractAddress,companyOwner, _msgSender());
        
    }

    function createRound(
        string calldata roundDocumentUrl,
        uint256 startTimestamp,
        uint256 duration,
        uint256 lockupPeriodForShare,
        uint256 tokensSuppliedForRound,
        bool runTillFullySubscribed,
        address[] memory paymentCurrencies,
        uint256[] memory pricePerShare
    ) external nonReentrant {

        ICompanyController controller  = ICompanyController(_dns.getRoute("COMPANY_CONTROLLER"));
        controller.createRound(_msgSender(),roundDocumentUrl, startTimestamp, duration,  lockupPeriodForShare, tokensSuppliedForRound, runTillFullySubscribed, paymentCurrencies, pricePerShare);
        
    }


    function createProposal(
        uint256[] calldata amountRequested,
        address[] calldata paymentCurrencies,
        uint256 votingStartTimestamp
    ) external  nonReentrant {

         ICompanyController controller  = ICompanyController(_dns.getRoute("COMPANY_CONTROLLER"));
        controller.createProposal(amountRequested,paymentCurrencies,votingStartTimestamp,_msgSender());

    }

    function getProposalResult(uint256 proposalId) external view  returns (ProposalResponse memory) {
         ICompanyController controller  = ICompanyController(_dns.getRoute("COMPANY_CONTROLLER"));
         return controller.getProposalResult(proposalId);
       
    }


    function getRound(uint256 roundId) external view returns (RoundResponse memory) {
         ICompanyController controller  = ICompanyController(_dns.getRoute("COMPANY_CONTROLLER"));
         return controller.getRound(roundId);
    }

    function releaseProposalBudget(uint256 proposalId) external nonReentrant {
        ICompanyController controller  = ICompanyController(_dns.getRoute("COMPANY_CONTROLLER"));
        controller.releaseProposalBudget(proposalId,_msgSender());      
    }


    function deleteProposal(uint256 proposalId) external nonReentrant {
        ICompanyController controller  = ICompanyController(_dns.getRoute("COMPANY_CONTROLLER"));
        controller.deleteProposal(proposalId,_msgSender());    
    }

    function deleteRound(uint256 roundId) external nonReentrant {
        ICompanyController controller  = ICompanyController(_dns.getRoute("COMPANY_CONTROLLER"));
        controller.deleteRound(roundId,_msgSender());   
    }

}
