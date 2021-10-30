// SPDX-License-Identifier: MIT

import "./models/Schema.sol";
import "./models/EventModels.sol";

import "./BaseContract.sol";
import "./libraries/SafeERC20.sol";
import "./libraries/SafeMath.sol";

import "./libraries/ReentrancyGuard.sol";
import "./interfaces/IInvestorController.sol";
import "./interfaces/ICompanyStore.sol";
import "./interfaces/IProposalStore.sol";
import "./interfaces/IRoundStore.sol";
import "./interfaces/ICompanyVault.sol";
import "./interfaces/ICompanyVaultStore.sol";

import "./interfaces/IEventEmitter.sol";
import "./interfaces/IIdentityContract.sol";
import "./interfaces/IInvestorStore.sol";
import "./interfaces/IERC20.sol";
import "./interfaces/IQuidRaiseShares.sol";

pragma experimental ABIEncoderV2;
pragma solidity 0.7.0;

contract InvestorController is  BaseContract,ReentrancyGuard, IInvestorController{

    using SafeERC20 for IERC20;
    using SafeMath for uint256;


    ICompanyStore private _companyStore;
    IProposalStore private _proposalStore;
    IRoundStore private _roundStore;
    ICompanyVault private _companyVault;
    ICompanyVaultStore private _companyVaultStore;

    IEventEmitter private _eventEmitter;
    IIdentityContract private _identityContract;
    IInvestorStore private _investorStore;
    IQuidRaiseShares private _quidRaiseShares;



 constructor(address dnsContract) BaseContract(dnsContract) {

        _companyStore = ICompanyStore(_dns.getRoute(COMPANY_STORE));
        _proposalStore = IProposalStore(_dns.getRoute(PROPOSAL_STORE));
        _roundStore = IRoundStore(_dns.getRoute(ROUND_STORE));
        _companyVault = ICompanyVault(_dns.getRoute(COMPANY_VAULT));
        _companyVaultStore = ICompanyVaultStore(_dns.getRoute(COMPANY_VAULT_STORE));

        _eventEmitter = IEventEmitter(_dns.getRoute(EVENT_EMITTER));
        _identityContract = IIdentityContract(_dns.getRoute(IDENTITY_CONTRACT));
        _investorStore = IInvestorStore(_dns.getRoute(INVESTOR_STORE));
        _quidRaiseShares = IQuidRaiseShares(_dns.getRoute(NFT));

    }



    function investInRound(uint256 roundId, address paymentTokenAddress, address investor) external override nonReentrant c2cCallValid
    {
        Round memory round =  _roundStore.getRound(roundId);
        ensureWhitelist(round.CompanyId,investor);
        require(isSupportedPaymentOption(roundId,paymentTokenAddress), "Payment token not supported");
        IERC20 token = IERC20(paymentTokenAddress);
        uint256 investmentAmount = token.allowance(investor, address(this));

        require(investmentAmount>0,"Cannot deposit 0 tokens");

        address[] memory paymentOptions = _roundStore.getRoundPaymentOptions(round.Id);

        token.safeTransferFrom(investor,address(this),investmentAmount);

        token.approve(address(_companyVault),investmentAmount);
        _companyVault.depositPaymentTokensToVault(round.CompanyId, paymentTokenAddress);

        uint256 tokenAllocation = getTokenAllocation(round,paymentTokenAddress,investmentAmount);

        if(!_investorStore.isInvestor(investor))
        {
            _investorStore.createInvestor(Investor(investor,0,0));
        }

        RoundInvestment memory roundInvestment  = _investorStore.getRoundInvestment(investor,roundId);
        if(!roundInvestment.Exists)
        {
            uint256[] memory investmentAmounts = new uint256[](paymentOptions.length);
           
            roundInvestment = RoundInvestment(round.Id,0,paymentOptions,investmentAmounts ,true);
            // If it's a new investor, then we update the investor count for this round;
            round.TotalInvestors = round.TotalInvestors.add(1);

        }

         for (uint256 i = 0; i < paymentOptions.length; i++) 
         {
            if(paymentOptions[i]==paymentTokenAddress)
            {
                roundInvestment.InvestmentAmounts[i] = roundInvestment.InvestmentAmounts[i].add(investmentAmount);
                roundInvestment.TokenAlloaction =   roundInvestment.TokenAlloaction.add(tokenAllocation);

                 // Update the Total raised in that round for that particular currency
                 round.TotalRaised[i] = round.TotalRaised[i].add(investmentAmount);
            }                
         }

         round.TotalTokensSold =  round.TotalTokensSold.add(tokenAllocation);
       
        _roundStore.updateRound(round.Id, round);
        _investorStore.updateRoundsInvestment(investor,roundInvestment);
        _investorStore.updateCompaniesInvestedIn(investor, round.CompanyId);
        _quidRaiseShares.mint(round.CompanyId, tokenAllocation, investor);


        _eventEmitter.emitInvestmentDepositEvent(InvestmentDepositRequest(round.CompanyId, round.Id, investor,paymentTokenAddress, investmentAmount));
    }

    function getTokenAllocation(Round memory round,  address paymentTokenAddress, uint256 investmentAmount) internal pure returns (uint256)
    {
       for (uint256 i = 0; i < round.PaymentCurrencies.length; i++)
       {
           if(paymentTokenAddress == round.PaymentCurrencies[i])
           {
               uint256 pricePerShare = round.PricePerShare[i];
               return investmentAmount.div(pricePerShare);
           }
       }
       revert("Token allocation cannot be calculated");
    }


    function ensureWhitelist(uint256 companyId, address investor) internal view
    {
        require(_identityContract.isInvestorAddressWhitelisted(investor),
                    "Address blacklisted");
        require(_identityContract.isCompanyWhitelisted(companyId),
                "Company blacklisted");
    }

    function isSupportedPaymentOption(uint roundId,address tokenAddress) internal view returns (bool)
    {
        address[] memory paymentAddresses = _roundStore.getRoundPaymentOptions(roundId);
        for (uint256 i = 0; i < paymentAddresses.length; i++) {
            
            if(tokenAddress==paymentAddresses[i])
            {
                return true;
            }
        }
        return false;
    }

    function voteForProposal(uint256 proposalId, address investor, bool isApproved) external override nonReentrant c2cCallValid
    {
        Proposal memory proposal =  _proposalStore.getProposal(proposalId);
        uint256 tokenAllocation = _quidRaiseShares.balanceOf(investor,proposal.CompanyId);
        require(tokenAllocation>0, "You are not a shareholder in this company"); 
        ensureWhitelist(proposal.CompanyId,investor);

        
        ProposalVote memory proposalVote  = _investorStore.getProposalVote(investor,proposal.Id);

        if(proposalVote.Exists)
        {
           uint256 stakedShares =  proposalVote.SharesStaked;
           if(proposalVote.IsApproved)
           {
             proposal.TokensStakedForApprovedVotes = proposal.TokensStakedForApprovedVotes.sub(stakedShares);
             proposal.ApprovedVotes = proposal.ApprovedVotes.sub(1);
           }
           else
           {
             proposal.TokensStakedForRejectedVotes = proposal.TokensStakedForRejectedVotes.sub(stakedShares);        
             proposal.RejectedVotes = proposal.RejectedVotes.sub(1);
           }
        }
      
        if(isApproved)
        {
            proposal.TokensStakedForApprovedVotes =  proposal.TokensStakedForApprovedVotes.add(tokenAllocation);
            proposal.ApprovedVotes = proposal.ApprovedVotes.add(1);

        }
        else
        {
            proposal.TokensStakedForRejectedVotes = proposal.TokensStakedForRejectedVotes.add(tokenAllocation);
            proposal.RejectedVotes = proposal.RejectedVotes.add(1);
        }
        proposalVote = ProposalVote(proposal.Id,tokenAllocation,isApproved,true);

        _investorStore.updateProposalsVotedIn(investor,proposalVote);
        _proposalStore.updateProposal(proposal.Id, proposal);
    }

    function viewProposalVote(uint256 proposalId, address investor) external view override returns (ProposalVote memory)
    {
        ProposalVote memory proposalVote  = _investorStore.getProposalVote(investor,proposalId);
        require(proposalVote.Exists, "Investor vote not found");
        return proposalVote;
    }

    function getRoundInvestment(uint256 roundId, address investor) external view override  returns (RoundInvestment memory)
    {
        return _investorStore.getRoundInvestment(investor,roundId);
    }


    function getRound(uint256 roundId) external view override returns (RoundResponse memory)
    {
        Round memory round =  _roundStore.getRound(roundId);
        return RoundResponse(round.Id, round.CompanyId, round.LockUpPeriodForShare, round.PricePerShare, 
                             round.PaymentCurrencies, round.TotalTokensUpForSale, 
                             round.TotalInvestors, round.TotalRaised, round.TotalTokensSold, round.RoundStartTimeStamp, 
                             round.DurationInSeconds,
                             round.DocumentUrl, round.RunTillFullySubscribed, isRoundOpen(round)
                             );  
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
}
