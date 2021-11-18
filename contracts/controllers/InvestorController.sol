// SPDX-License-Identifier: MIT

import "../models/Schema.sol";
import "../models/EventModels.sol";

import "../infrastructure/BaseContract.sol";
import "../libraries/SafeERC20.sol";
import "../libraries/SafeMath.sol";

import "../libraries/ReentrancyGuard.sol";
import "./interface/IInvestorController.sol";
import "../store/interface/ICompanyStore.sol";
import "../store/interface/IProposalStore.sol";
import "../store/interface/IRoundStore.sol";
import "../vault/interface/ICompanyVault.sol";
import "../store/interface/ICompanyVaultStore.sol";

import "../vault/interface/IInvestmentTokenVault.sol";


import "../events/interface/IEventEmitter.sol";
import "../infrastructure/interface/IIdentityContract.sol";
import "../store/interface/IInvestorStore.sol";
import "../interfaces/IERC20.sol";
import "../nfts/interface/IQuidRaiseShares.sol";

pragma experimental ABIEncoderV2;
pragma solidity 0.7.0;

contract InvestorController is  BaseContract,ReentrancyGuard, IInvestorController{

    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    constructor(address dnsContract) BaseContract(dnsContract) {
       
    }



    function investInRound(uint256 roundId, address paymentTokenAddress, address investor) external override nonReentrant c2cCallValid
    {
        IRoundStore _roundStore = IRoundStore(_dns.getRoute(ROUND_STORE));
        IInvestorStore _investorStore = IInvestorStore(_dns.getRoute(INVESTOR_STORE));

        Round memory round =  _roundStore.getRound(roundId);
        ensureWhitelist(round.CompanyId,investor);
        require(isSupportedPaymentOption(roundId,paymentTokenAddress), "Payment token not supported");
        IERC20 token = IERC20(paymentTokenAddress);
        uint256 investmentAmount = token.allowance(investor, address(this));

        require(investmentAmount>0,"Cannot deposit 0 tokens");

        address[] memory paymentOptions = _roundStore.getRoundPaymentOptions(round.Id);

        token.safeTransferFrom(investor,address(this),investmentAmount);

        token.approve(address(_dns.getRoute(COMPANY_VAULT)),investmentAmount);
        (ICompanyVault(_dns.getRoute(COMPANY_VAULT))).depositPaymentTokensToVault(round.CompanyId, paymentTokenAddress);

        uint256 tokenAllocation = getTokenAllocation(round,paymentTokenAddress,investmentAmount);

        if(!_investorStore.isInvestor(investor))
        {
            _investorStore.createInvestor(Investor(investor,0,0));
        }

        RoundInvestment memory roundInvestment;
        if(!_investorStore.investedInRound(investor,roundId))
        {
            uint256[] memory investmentAmounts = new uint256[](paymentOptions.length);

            roundInvestment = RoundInvestment(round.Id,0,paymentOptions,investmentAmounts,true);
            // If it's a new investor, then we update the investor count for this round;
            round.TotalInvestors = round.TotalInvestors.add(1);
        }
        else
        {
            roundInvestment = _investorStore.getRoundInvestment(investor,roundId);
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

        _roundStore.updateRound(round);
        _investorStore.updateRoundsInvestment(investor,roundInvestment);
        lockTokensAllocated(round, investor,tokenAllocation);
        (IQuidRaiseShares(_dns.getRoute(NFT))).mint(round.CompanyId, tokenAllocation, investor);

        (IEventEmitter(_dns.getRoute(EVENT_EMITTER))).emitInvestmentDepositEvent(InvestmentDepositRequest(round.CompanyId, round.Id, investor,paymentTokenAddress, investmentAmount,tokenAllocation));
    }

    function lockTokensAllocated(Round memory round, address investor, uint256 tokenAllocation) internal
    {
        ICompanyStore _companyStore = ICompanyStore(_dns.getRoute(COMPANY_STORE));
        ICompanyVault _companyVault = ICompanyVault(_dns.getRoute(COMPANY_VAULT));

        Company memory company = _companyStore.getCompanyById(round.CompanyId);

        IERC20 companyToken =   IERC20(company.CompanyTokenContractAddress);
        _companyVault.withdrawCompanyTokens(round.CompanyId,tokenAllocation);
        companyToken.approve(round.TokenLockVaultAddres, tokenAllocation);

        IInvestmentTokenVault(round.TokenLockVaultAddres).lockTokens(investor);

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
        IInvestorStore _investorStore = IInvestorStore(_dns.getRoute(INVESTOR_STORE));

        IIdentityContract _identityContract = IIdentityContract(_dns.getRoute(IDENTITY_CONTRACT));
        if(_investorStore.isInvestor(investor))
        {
            require(_identityContract.isInvestorAddressWhitelisted(investor),
                        "Address blacklisted");
        }
        require(_identityContract.isCompanyWhitelisted(companyId),
                "Company blacklisted");
    }

    function isSupportedPaymentOption(uint roundId,address tokenAddress) internal view returns (bool)
    {
        IRoundStore _roundStore = IRoundStore(_dns.getRoute(ROUND_STORE));
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
        IProposalStore _proposalStore = IProposalStore(_dns.getRoute(PROPOSAL_STORE));
        IInvestorStore _investorStore = IInvestorStore(_dns.getRoute(INVESTOR_STORE));
        IQuidRaiseShares _quidRaiseShares = IQuidRaiseShares(_dns.getRoute(NFT));

        Proposal memory proposal =  _proposalStore.getProposal(proposalId);
        uint256 tokenAllocation = _quidRaiseShares.balanceOf(investor,proposal.CompanyId);
        require(tokenAllocation>0, "You are not a shareholder in this company");
        require(canVote(proposal), "Votes can no longer be cast on this proposal");
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
        _proposalStore.updateProposal(proposal);
    }

    function canVote(Proposal memory proposal) internal view returns(bool)
    {
        uint256 expiryTimeStamp = proposal.VoteStartTimeStamp.add(proposal.VoteSessionDuration);

        if(block.timestamp<=expiryTimeStamp)
        {
            return true;
        }
        else
        {
            return false;
        }
    }

    function viewProposalVote(uint256 proposalId, address investor) external view override returns (ProposalVote memory)
    {
        IInvestorStore _investorStore = IInvestorStore(_dns.getRoute(INVESTOR_STORE));
        ProposalVote memory proposalVote  = _investorStore.getProposalVote(investor,proposalId);
        require(proposalVote.Exists, "Investor vote not found");
        return proposalVote;
    }

    function getRoundInvestment(uint256 roundId, address investor) external view override  returns (RoundInvestment memory)
    {
        IInvestorStore _investorStore = IInvestorStore(_dns.getRoute(INVESTOR_STORE));
        return _investorStore.getRoundInvestment(investor,roundId);
    }


    function getRound(uint256 roundId) external view override returns (RoundResponse memory)
    {
        IRoundStore _roundStore = IRoundStore(_dns.getRoute(ROUND_STORE));
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
              uint256 expiryTime = round.RoundStartTimeStamp .add(round.DurationInSeconds);
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
