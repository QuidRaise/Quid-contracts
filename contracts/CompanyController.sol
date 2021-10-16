// SPDX-License-Identifier: MIT
import "./models/Schema.sol";
import "./models/EventModels.sol";

import "./BaseContract.sol";
import "./DataGrant.sol";
import "./interfaces/ICompanyController.sol";

pragma experimental ABIEncoderV2;
pragma solidity 0.7.0;

interface CompanyController is  BaseContract, DataGrant, ICompanyController{

    ICompanyStore _companyStore;
    IProposalStore _proposalStore;
    IRoundStore _roundStore;
    ICompanyVault _companyVault;
    IEventEmitter _eventEmitter;
    IIdentityContract _identityContract;
    IInvestorStore _investorStore;

     constructor(address dnsContract) BaseContract(dnsContract) {
        _companyStore = ICompanyStore(_dns.getRoute(COMPANY_STORE));
        _proposalStore = IProposalStore(_dns.getRoute(PROPOSAL_STORE));
        _roundStore = IRoundStore(_dns.getRoute(ROUND_STORE));
        _companyVault = ICompanyVault(_dns.getRoute(COMPANY_VAULT));
        _eventEmitter = IEventEmitter(_dns.getRoute(EVENT_EMITTER));
        _identityContract = IIdentityContract(_dns.getRoute(IDENTITY_CONTRACT));
        _investorStore = IInvestorStore(_dns.getRoute(INVESTOR_STORE));
    }


    //Currently defaulting oracle to owner address
    // We would need to build a more robust oracle system for QuidRaise
    function createCompany(string calldata CompanyUrl,
                           string calldata companyName, address companyTokenContractAddress, 
                           address companyOwner, address companyCreatedBy) external  onlyOwner
    {
         bool isInvestor = _investorStore.isInvestor(companyOwner);
         require(!_companyStore.isCompanyOwner(companyOwner),"Company owner already owns a business");

         if(isInvestor)
         {
            require(_identityContract.isInvestorAddressWhitelisted(companyOwner), 
                    "Company owner address blacklisted as investor");
         }
         Company memory company = Company(0,companyName,companyDocUrl,companyTokenContractAddress,companyOwner);
         uint companyId = _companyStore.createCompany(company);

         _identityContract.whitelistCompanyAddress(companyOwner);
         _identityContract.whitelistCompany(companyId);

         Company memory company = Company(0,companyName,companyDocUrl,companyTokenContractAddress,companyOwner);
         _eventEmitter.emitCompanyCreatedEvent(CompanyCreatedRequest(companyId, company.CompanyOwner, companyCreatedBy, 
                                                                     company.CompanyName, company.CompanyDocumentUrl,
                                                                     company.CompanyTokenContract));

        _eventEmitter.emitWhitelistCompanyEvent(WhitelistCompanyRequest(companyId,companyCreatedBy));

    }

    function createRound(address companyOwner,string roundDocumentUrl,uint startTimestamp, uint duration,
                         uint lockupPeriodForShare, uint pricePerShare, 
                         uint tokensSuppliedForRound, bool runTillFullySubscribed, 
                         address[] memory paymentCurrencies) external  override c2cCallValid
    {
         require(startTimestamp>0 && duration>0 && pricePerShare>0 &&  
                 tokensSuppliedForRound>0 && paymentCurrencies.length>0, 
                 "Contract input data is invalid");

         require(!_companyStore.isCompanyOwner(companyOwner),"Could not find a company owned by this user");
         Company memory company = _companyStore.getCompanyByOwner(companyOwner);

         bool hasOpenRound = doesCompanyHaveOpenRound(company.Id);
         require(!hasOpenRound,"Company has an open round");

         bool hasOpenProposal = doesCompanyHaveOpenProposal(company.Id);
         require(!hasOpenProposal,"Company has an open proposal");

         bool isPaymentOptionsValid = validateRoundPaymentOptions(paymentCurrencies);
         require(isPaymentOptionsValid,"One or more payment options are not supported");

         depsitCompanyTokensToVault(company);

         Round round = Round(0,company.Id,lockupPeriodForShare,roundDocumentUrl,pricePerShare,
                             tokensSuppliedForRound,0,0,startTimestamp,duration,
                             runTillFullySubscribed,false);

         uint roundId = _roundStore.createRound(round);

         _roundStore.createRoundPaymentOptions(roundId,paymentCurrencies);

         _eventEmitter
         .emitCompanyDepositEvent(
                CompanyDepositRequest(company.Id, roundId, companyOwner,
                                        company.CompanyTokenContractAddress,tokensSuppliedForRound)
            );


         _eventEmitter
         .emitRoundCreatedEvent(
             RoundCreatedRequest(roundId,company.Id, companyOwner,
                                round.LockUpPeriodForShare, round.PricePerShare, round.TotalTokensUpForSale,
                                round.RoundStartTimeStamp, round.DurationInSeconds, 
                                round.RunTillFullySubscribed, paymentCurrencies )
            );
         
    }

    function depsitCompanyTokensToVault(Company memory company, uint expectedTokenDeposit) internal
    {
        IERC20 token = IERC20(company.CompanyTokenContractAddress);
        uint amountToDeposit = token.allowance(company.OwnerAddress, address(this));
        require(expectedTokenDeposit==amountToDeposit,"Approved deposit does not tally with round allocation");
        require(amountToDeposit>0,"Cannot deposit 0 tokens");

        token.safeTransferFrom(company.OwnerAddress,address(this),amountToDeposit);

        token.approve(address(_companyVault),amountToDeposit);
        _companyVault.depositCompanyTokens(company.Id);
    }



    function createProposal(uint amountRequested, uint votingStartTimestamp, 
                            address companyOwnerAddress ) external override c2cCallValid
    {

    }


    function getProposalResutl(uint proposalId) external view override returns (ProposalResponse memory) 
    {

    }

    function getRound(uint roundId) external view override returns (RoundResponse memory) 
    {

    }


    function releaseProposalBudget(uint proposalId, address companyOwnerAddress) external  override c2cCallValid 
    {


    }

    function deleteProposal(uint proposalId, address companyOwnerAddress) external  override c2cCallValid 
    {

    }

    function deleteRound(uint proposalId, address companyOwnerAddress) external  override c2cCallValid 
    {

    }



    
    function doesCompanyHaveOpenRound(uint companyId) internal returns (bool)
    {
         Round[] memory rounds =  _roundStore.getCompanyRounds(company.Id);
         Round memory lastRound = rounds[rounds.length-1];
         if(lastRound.RunTillFullySubscribed)
         {
            if(lastRound.TotalTokensUpForSale!=lastRound.TotalTokensSold)
            {
                return true;
            }
            // We need to be careful with round token sales to 
            //ensure we never oversell tokens sha. If not everything have spoil
            else 
            {
                return false;
            }
         }
         else
         {
             uint expiryTime = lastRound.RoundStartTimeStamp.add(lastRound.DurationInSeconds);
             if(block.timestamp<=expiryTime)
             {
                 return true;
             }
             else{
                 return false;
             }
         }
    }

    function doesCompanyHaveOpenProposal(uint companyId) internal returns (bool)
    {
        Proposal[] memory proposals = _proposalStore.getCompanyProposals(companyId);
        Proposal memory lastProposal = proposals[proposals.length-1];

        if(lastProposal.IsDeleted)
        {
            return false;
        }
        else
        {
            uint expiryTime = lastProposal.VoteStartTimeStamp.add(lastProposal.VoteSessionDuration);
             if(block.timestamp<=expiryTime)
             {
                 return true;
             }
             else{
                 return false;
             }
        }
    }

    /***
        Checks the payment currencies against a list of supported payment currencies in the company vault contract
    */
    function validateRoundPaymentOptions(address[] paymentCurrencies) internal returns(bool)
    {
        //TODO: Check CompanyVault for list of supported payment options
        return true;
    }



}
