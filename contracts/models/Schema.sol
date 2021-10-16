// SPDX-License-Identifier: MIT

pragma solidity 0.7.0;

// Storage Models
/** 
   Represents a company's investment round
   When a round is fully subscribed, we emit a Fully Subscribed event

   A round can be set to auto close, which means disable intake of funds after a given time period
   Or they can be set to run until they are fully subscribed

   Either way, companies cannot raise proposals when they have an open round
   It is, what it is

   For rounds that are not set to run till they ae fully subscribed

*/
struct Round {
   uint Id;
   uint CompanyId;
   uint LockUpPeriodForShare;
   string DocumentUrl;
   uint PricePerShare;
   uint TotalTokensUpForSale;
   uint TotalInvestors;
   uint TotalRaised;
   uint TotalTokensSold;

   uint RoundStartTimeStamp;   
   uint DurationInSeconds;
   // When set to true, the round duration is not considered
   // The round is kept open until it has been fully subscribed
   // Fully subscribed being that the TotalTokensUpForSale == TotalRaised
   bool RunTillFullySubscribed;
   bool IsDeleted;
}


/**

  Used in representing the NFT an investor has gotten from participating in a round
  Contains records about the NFT as well as the COmpany token amount backing up this token
  We need to find a way for people to interact with these records on chain
  Lots of integration potentials here with other nft market places

 */
struct RoundNft
{
   uint Id;
   address NftContractAddress;
   uint TokenId;
   uint UnderlyingFundAmount;
   uint RoundId;
}

struct Proposal{
   uint Id;
   uint CompanyId;
   uint AmountRequested;
   uint VoteSessionDuration;
   uint VoteStartTimeStamp;
   uint ApprovedVotes;
   uint RejectedVotes;
   uint TokensStakedForApprovedVotes;
   uint TokensStakedForRejectedVotes;
   bool IsDeleted;
}

struct Investor{
   address WalletAddress;
   uint roundsParticipatedIn;
   uint proposalsVotedIn  ;
}

struct Company{
   uint Id;
   string CompanyName;
   string CompanyUrl;
   address CompanyTokenContractAddress;
   address OwnerAddress;
}




// Service Models

struct ProposalResponse
{
   uint ApprovedVotes;
   uint RejectedVotes;
   uint TokensStakedForApprovedVotes;
   uint TokensStakedForRejectedVotes;
   uint HasVotingPeriodElapsed;
   uint IsProposalApproved;
}

struct RoundResponse
{
   uint Id;
   uint CompanyId;
   uint LockUpPeriodForShare;
   string IPFSLinkForRoadMap;
   uint PricePerShare;
   uint TotalTokensUpForSale;
   uint TotalTokensSold;
   uint TotalInvestors;
   uint TotalRaised;

   uint RoundStartTimeStamp;   
   uint DurationInSeconds;
   bool RunTillFullySubscribed;
   uint NumberOfShareholders;
}


