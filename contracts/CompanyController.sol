// SPDX-License-Identifier: MIT
import "./models/Schema.sol";
import "./models/EventModels.sol";

import "./BaseContract.sol";
import "./libraries/SafeERC20.sol";
import "./libraries/ReentrancyGuard.sol";


import "./interfaces/ICompanyController.sol";
import "./interfaces/ICompanyStore.sol";
import "./interfaces/IProposalStore.sol";
import "./interfaces/IRoundStore.sol";
import "./interfaces/ICompanyVault.sol";
import "./interfaces/ICompanyVaultStore.sol";

import "./interfaces/IEventEmitter.sol";
import "./interfaces/IIdentityContract.sol";
import "./interfaces/IInvestorStore.sol";
import "./interfaces/IERC20.sol";
import "./interfaces/IConfig.sol";



pragma experimental ABIEncoderV2;
pragma solidity 0.7.0;

contract CompanyController is  BaseContract, ReentrancyGuard,  ICompanyController{

    using SafeERC20 for IERC20;
    using SafeMath for uint;


    ICompanyStore private _companyStore;
    IProposalStore private _proposalStore;
    IRoundStore private _roundStore;
    ICompanyVault private _companyVault;
    ICompanyVaultStore private _companyVaultStore;

    IEventEmitter private _eventEmitter;
    IIdentityContract private _identityContract;
    IInvestorStore private _investorStore;
    IConfig private _config;

     constructor(address dnsContract) BaseContract(dnsContract) {

        _companyStore = ICompanyStore(_dns.getRoute(COMPANY_STORE));
        _proposalStore = IProposalStore(_dns.getRoute(PROPOSAL_STORE));
        _roundStore = IRoundStore(_dns.getRoute(ROUND_STORE));
        _companyVault = ICompanyVault(_dns.getRoute(COMPANY_VAULT));
        _companyVaultStore = ICompanyVaultStore(_dns.getRoute(COMPANY_VAULT_STORE));

        _eventEmitter = IEventEmitter(_dns.getRoute(EVENT_EMITTER));
        _identityContract = IIdentityContract(_dns.getRoute(IDENTITY_CONTRACT));
        _investorStore = IInvestorStore(_dns.getRoute(INVESTOR_STORE));
        _config = IConfig(_dns.getRoute(CONFIG));
    }


    //Currently defaulting oracle to owner address
    // We would need to build a more robust oracle system for QuidRaise
    function createCompany(string calldata CompanyUrl,
                           string calldata companyName, address companyTokenContractAddress, 
                           address companyOwner, address companyCreatedBy) external override  nonReentrant onlyOwner
    {
         bool isInvestor = _investorStore.isInvestor(companyOwner);
         require(!_companyStore.isCompanyOwner(companyOwner),"Company owner already owns a business");

         if(isInvestor)
         {
            require(_identityContract.isInvestorAddressWhitelisted(companyOwner), 
                    "Company owner address blacklisted as investor");
         }
         Company memory company = Company(0,companyName,CompanyUrl,companyTokenContractAddress,companyOwner);
         uint256 companyId = _companyStore.createCompany(company);

         _identityContract.whitelistCompanyAddress(companyOwner);
         _identityContract.whitelistCompany(companyId);

         _eventEmitter.emitCompanyCreatedEvent(CompanyCreatedRequest(companyId, company.OwnerAddress, companyCreatedBy, 
                                                                     company.CompanyName, company.CompanyUrl,
                                                                     company.CompanyTokenContractAddress));

    }

    function createRound(address companyOwner,string calldata roundDocumentUrl,uint256 startTimestamp, uint256 duration,
                         uint256 lockupPeriodForShare, 
                         uint256 tokensSuppliedForRound, bool runTillFullySubscribed, 
                         address[] memory paymentCurrencies, uint256[] memory pricePerShare) external  override nonReentrant c2cCallValid
    {

        require(_config.getNumericConfig(MAX_ROUND_PAYMENT_OPTION) >= paymentCurrencies.length, "Exceeded number of payment options");

       
         for (uint256 i = 0; i < pricePerShare.length; i++) 
         {
             require(pricePerShare[i]> 0, "Price per share cannot be zero");
         }

         require(startTimestamp>0 && duration>0 &&   
                 tokensSuppliedForRound>0 && paymentCurrencies.length>0 &&
                 paymentCurrencies.length == pricePerShare.length, 
                 "Contract input data is invalid");

         require(!_companyStore.isCompanyOwner(companyOwner),"Could not find a company owned by this user");
         Company memory company = _companyStore.getCompanyByOwner(companyOwner);

        ensureCompanyIsWhitelisted(company.Id, companyOwner);
       

         validateRoundCreationInput(company.Id,paymentCurrencies);

         depsitCompanyTokensToVault(company,tokensSuppliedForRound);

         Round memory round = Round(0,company.Id,lockupPeriodForShare,pricePerShare,paymentCurrencies,
                             tokensSuppliedForRound,0, new uint256[](paymentCurrencies.length),0,startTimestamp,duration,roundDocumentUrl,
                             runTillFullySubscribed,false);

         uint256 roundId = _roundStore.createRound(round);

         _roundStore.createRoundPaymentOptions(roundId,paymentCurrencies);

        emitRoundCreatedEvents(roundId, paymentCurrencies, company, round);
         
    }


    function createProposal(uint256[] calldata amountRequested,address[] calldata paymentCurrencies, uint256 votingStartTimestamp, 
                            address companyOwner ) external override nonReentrant c2cCallValid
    {

        require( _config.getNumericConfig(MAX_ROUND_PAYMENT_OPTION) >= paymentCurrencies.length, "Exceeded number of payment options");

         require(!_companyStore.isCompanyOwner(companyOwner),"Could not find a company owned by this user");
         Company memory company = _companyStore.getCompanyByOwner(companyOwner);

        ensureCompanyIsWhitelisted(company.Id, companyOwner);


        validateProposalCreationAction(company.Id);

        Proposal memory proposal = Proposal(0,company.Id,amountRequested,paymentCurrencies,
                                            getVoteDuration(),votingStartTimestamp,
                                            0,0,0,0,false,false);
        uint256 propoalId = _proposalStore.createProposal(proposal);

        _eventEmitter
        .emitProposalCreatedEvent(
            ProposalCreatedRequest(propoalId,company.Id,companyOwner,company.CompanyTokenContractAddress,
                                   proposal.AmountRequested,proposal.PaymentCurrencies, proposal.VoteStartTimeStamp,
                                   proposal.VoteSessionDuration)
        );



    }


    function getProposalResult(uint256 proposalId) external view override returns (ProposalResponse memory) 
    {

       Proposal memory proposal =  _proposalStore.getProposal(proposalId);

       bool hasVotingPeriodElapsed = false;
       uint256 expiryDate = proposal.VoteStartTimeStamp.add(proposal.VoteSessionDuration);
       if(block.timestamp>expiryDate)
       {
            hasVotingPeriodElapsed = true;
       }
      
       ProposalResponse memory response = ProposalResponse(proposal.ApprovedVotes, proposal.RejectedVotes,
                                                           proposal.TokensStakedForApprovedVotes,  proposal.TokensStakedForRejectedVotes ,
                                                            isProposalApproved(proposal, hasVotingPeriodElapsed), hasVotingPeriodElapsed );


       return response;
    }

    function isProposalApproved(Proposal memory proposal, bool hasVotingPeriodElapsed) internal pure returns (bool)
    {
        if(!hasVotingPeriodElapsed)
        {
            return false;
        }
        else
        {
            uint256 weightedApprovals = proposal.ApprovedVotes.mul(proposal.TokensStakedForApprovedVotes);
            uint256 weightedRejections = proposal.RejectedVotes.mul(proposal.TokensStakedForRejectedVotes);

            if(weightedApprovals>weightedRejections)
            {
                return true;
            }
            else
            {

                return false;
            }
        }
    }

    function getRound(uint256 roundId) external view override returns (RoundResponse memory) 
    {
        Round memory round =  _roundStore.getRound(roundId);
        require(!round.IsDeleted,"Round has been deleted");
        RoundResponse memory response = RoundResponse(round.Id, round.CompanyId, round.LockUpPeriodForShare, 
                                                      round.PricePerShare,round.PaymentCurrencies, round.TotalTokensUpForSale, round.TotalInvestors, round.TotalRaised,
                                                      round.TotalTokensSold, round.RoundStartTimeStamp, round.DurationInSeconds,
                                                      round.DocumentUrl, round.RunTillFullySubscribed, isRoundOpen(round));


        return response;
    }


    function releaseProposalBudget(uint256 proposalId, address companyOwner) external  override nonReentrant c2cCallValid 
    {
        require(!_companyStore.isCompanyOwner(companyOwner),"Could not find a company owned by this user");

         Proposal memory proposal =  _proposalStore.getProposal(proposalId);
         Company memory company = _companyStore.getCompanyById(proposal.CompanyId);

        ensureCompanyIsWhitelisted(company.Id, companyOwner);


         require(company.Id==proposal.CompanyId, "Unauthorized access to proposal budget");


         require(company.OwnerAddress==companyOwner, "Unauthorized access to proposal budegt");
         require(!proposal.IsDeleted,"Proposal has been deleted");
         require(!proposal.HasWithdrawn,"Proposal has been withdrawn from");
        proposal.HasWithdrawn = true;
        _proposalStore.updateProposal(proposal.Id, proposal);

        for (uint256 i = 0; i < proposal.PaymentCurrencies.length; i++) {
            address currency = proposal.PaymentCurrencies[i];
            uint256 balance = _companyVaultStore.getCompanyVaultBalance(proposal.CompanyId, currency);
            require(balance>=proposal.AmountRequested[i],"Insufficient Vault Balance");
            _companyVault.withdrawPaymentTokensFromVault(proposal.CompanyId, currency, proposal.AmountRequested[i]);             

        }

         
    }


     function calculatePlatformCommision(uint256 amount) internal view returns (uint256)
    {
        uint256 factor = _config.getNumericConfig(PLATFORM_COMMISION);
        uint256 precision = _config.getNumericConfig(PRECISION);

        return amount.mul(factor).div(precision);
    }

    
    function ensureCompanyIsWhitelisted(uint256 companyId, address companyOwner) internal view
    {
          require(_identityContract.isCompanyAddressWhitelisted(companyOwner),
                    "Address blacklisted");
        require(_identityContract.isCompanyWhitelisted(companyId),
                    "Company blacklisted");
    }


    function deleteProposal(uint256 proposalId, address companyOwnerAddress) external  override c2cCallValid 
    {
       Proposal memory proposal =  _proposalStore.getProposal(proposalId);
       Company memory company = _companyStore.getCompanyById(proposal.CompanyId);
       require(company.OwnerAddress==companyOwnerAddress, "Unauthorized access to proposal");
       require(!proposal.IsDeleted,"Proposal has been deleted");
       require(proposal.ApprovedVotes==0 && proposal.RejectedVotes==0,"Proposal can no longer be deleted");
       proposal.IsDeleted = true;
       _proposalStore.updateProposal(proposalId,proposal);
       //TODO: Emit Proposal Deleted Event;

    }

    function deleteRound(uint256 roundId, address companyOwnerAddress) external  override c2cCallValid 
    {
        Round memory round =  _roundStore.getRound(roundId);
        Company memory company = _companyStore.getCompanyById(round.CompanyId);
        require(company.OwnerAddress==companyOwnerAddress, "Unauthorized access to round");
        require(!round.IsDeleted,"Round has been deleted");
        require(round.TotalTokensSold==0,"Round can no longer be deleted");

        for (uint256 i = 0; i < round.TotalRaised.length; i++) 
        {
            require(round.TotalRaised[i]==0 ,"Round can no longer be deleted");
        }

        round.IsDeleted = true;

       _roundStore.updateRound(roundId, round);
       //TODO: Emit Round Deleted Event;
    }




    function isRoundOpen(Round memory round) internal view returns (bool)
    {
        if(round.RunTillFullySubscribed)
        {
            if(round.TotalTokensUpForSale==round.TotalTokensSold) 
            {
                return false;
            }
            else
            {
                return true;
            }
        }
        else 
        {
              uint256 expiryTime = round.RoundStartTimeStamp.add(round.DurationInSeconds);
             if(block.timestamp<=expiryTime)
             {
                 return true;
             }
             else{
                 return false;
             }
        }
    }


    
    function doesCompanyHaveOpenRound(uint256 companyId) internal view returns (bool)
    {
         Round[] memory rounds =  _roundStore.getCompanyRounds(companyId);
         Round memory lastRound = rounds[rounds.length-1];
         return isRoundOpen(lastRound);
    }

    function doesCompanyHaveOpenProposal(uint256 companyId) internal view returns (bool)
    {
        Proposal[] memory proposals = _proposalStore.getCompanyProposals(companyId);
        Proposal memory lastProposal = proposals[proposals.length-1];

        if(lastProposal.IsDeleted)
        {
            return false;
        }
        else
        {
            uint256 expiryTime = lastProposal.VoteStartTimeStamp.add(lastProposal.VoteSessionDuration);
             if(block.timestamp<=expiryTime)
             {
                 return true;
             }
             else{
                 return false;
             }
        }
    }

     function validateRoundCreationInput(uint256 companyId,  address[] memory paymentCurrencies) internal view
    {
         bool hasOpenRound = doesCompanyHaveOpenRound(companyId);
         require(!hasOpenRound,"Company has an open round");

         bool hasOpenProposal = doesCompanyHaveOpenProposal(companyId);
         require(!hasOpenProposal,"Company has an open proposal");

         bool isPaymentOptionsValid = validateRoundPaymentOptions(paymentCurrencies);
         require(isPaymentOptionsValid,"One or more payment options are not supported");

    }

     function validateProposalCreationAction(uint256 companyId) internal view
    {
         bool hasOpenRound = doesCompanyHaveOpenRound(companyId);
         require(!hasOpenRound,"Company has an open round");

         bool hasOpenProposal = doesCompanyHaveOpenProposal(companyId);
         require(!hasOpenProposal,"Company has an open proposal");     
    }


    function getVoteDuration() internal view returns (uint256)
    {
        return _config.getNumericConfig(CONFIG);
    }
    

    /***
        Checks the payment currencies against a list of supported payment currencies in the company vault contract
    */
    function validateRoundPaymentOptions(address[] memory paymentCurrencies) internal view returns(bool)
    {        

        for (uint256 i = 0; i < paymentCurrencies.length; i++) {
            address currency = paymentCurrencies[i];
            bool isSupported = _companyVaultStore.isSupportedPaymentOption(currency);
            if(!isSupported)
            {
                return false;
            }            
        }

        return true;
    }




    
    function emitRoundCreatedEvents(uint256 roundId, address[] memory paymentCurrencies, Company memory company, Round memory round) internal 
    {
            
         _eventEmitter
         .emitCompanyDepositEvent(
                CompanyDepositRequest(company.Id, roundId, company.OwnerAddress,
                                        company.CompanyTokenContractAddress,round.TotalTokensUpForSale)
            );


         _eventEmitter
         .emitRoundCreatedEvent(
             RoundCreatedRequest(roundId,company.Id, company.OwnerAddress,
                                round.LockUpPeriodForShare,  round.TotalTokensUpForSale,
                                round.RoundStartTimeStamp, round.DurationInSeconds, 
                                round.RunTillFullySubscribed, paymentCurrencies,round.PricePerShare )
            );

    }

   
    function depsitCompanyTokensToVault(Company memory company, uint256 expectedTokenDeposit) internal
    {
        IERC20 token = IERC20(company.CompanyTokenContractAddress);
        uint256 amountToDeposit = token.allowance(company.OwnerAddress, address(this));
        require(expectedTokenDeposit==amountToDeposit,"Approved deposit does not tally with round allocation");
        require(amountToDeposit>0,"Cannot deposit 0 tokens");

        token.safeTransferFrom(company.OwnerAddress,address(this),amountToDeposit);

        token.approve(address(_companyVault),amountToDeposit);
        _companyVault.depositCompanyTokens(company.Id);
    }


}
