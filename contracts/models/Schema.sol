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
    uint256 Id;
    uint256 CompanyId;
    uint256 LockUpPeriodForShare;
    uint256[] PricePerShare;
    address[] PaymentCurrencies;
    uint256 TotalTokensUpForSale;
    uint256 TotalInvestors;
    uint256[] TotalRaised;
    uint256 TotalTokensSold;
    uint256 RoundStartTimeStamp;
    uint256 DurationInSeconds;
    string DocumentUrl;
    address TokenLockVaultAddres;
    // When set to true, the round duration is not considered
    // The round is kept open until it has been fully subscribed
    // Fully subscribed being that the TotalTokensUpForSale == TotalRaised
    bool RunTillFullySubscribed;
    bool IsDeleted;
}

struct RoundInvestment {
    uint256 RoundId;
    uint256 TokenAlloaction;
    address[] PaymentCurrencies;
    uint256[] InvestmentAmounts;
    bool Exists;
}

struct Index {
    uint256 Index;
    bool Exists;
}

/**

  Used in representing the NFT an investor has gotten from participating in a round
  Contains records about the NFT as well as the COmpany token amount backing up this token
  We need to find a way for people to interact with these records on chain
  Lots of integration potentials here with other nft market places

 */
struct RoundNft {
    uint256 Id;
    uint256 RoundId;
    address NftContractAddress;
    address Investor;
}

struct Proposal {
    uint256 Id;
    uint256 CompanyId;
    uint256[] AmountRequested;
    address[] PaymentCurrencies;
    uint256 VoteSessionDuration;
    uint256 VoteStartTimeStamp;
    uint256 ApprovedVotes;
    uint256 RejectedVotes;
    uint256 TokensStakedForApprovedVotes;
    uint256 TokensStakedForRejectedVotes;
    bool IsDeleted;
    bool HasWithdrawn;
}

struct Investor {
    address WalletAddress;
    uint256 proposalsApproved;
    uint256 proposalsRejected;
}

struct Company {
    uint256 Id;
    string CompanyName;
    string CompanyUrl;
    address CompanyTokenContractAddress;
    address OwnerAddress;
}

struct SupportedPaymentOption {
    bool IsEnabled;
    bool Exists;
    uint256 Index;
}

struct ProposalVote {
    uint256 ProposalId;
    uint256 SharesStaked;
    bool IsApproved;
    bool Exists;
}

// Service Models

struct ProposalResponse {
    uint256 ApprovedVotes;
    uint256 RejectedVotes;
    uint256 TokensStakedForApprovedVotes;
    uint256 TokensStakedForRejectedVotes;
    bool IsProposalApproved;
    bool HasVotingPeriodElapsed;
}

struct RoundResponse {
    uint256 Id;
    uint256 CompanyId;
    uint256 LockUpPeriodForShare;
    uint256[] PricePerShare;
    address[] PaymentCurrencies;
    uint256 TotalTokensUpForSale;
    uint256 TotalInvestors;
    uint256[] TotalRaised;
    uint256 TotalTokensSold;
    uint256 RoundStartTimeStamp;
    uint256 DurationInSeconds;
    string DocumentUrl;
    bool RunTillFullySubscribed;
    bool IsOpen;
}

struct RebalancedProposalPayout {
    address currencyAddress;
    uint256 amountToSend;
}
