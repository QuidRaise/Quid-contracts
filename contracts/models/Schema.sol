// SPDX-License-Identifier: MIT

pragma solidity 0.7.0;


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
   string IPFSLinkForRoadMap;
   uint PricePerShare;
   uint TotalTokensUpForSale;
   uint TotalInvestors;
   uint TotalRaised;

   uint RoundStartTimeStamp;   
   uint DurationInSeconds;
   // When set to true, the round duration is not considered
   // The round is kept open until it has been fully subscribed
   // Fully subscribed being that the TotalTokensUpForSale == TotalRaised
   bool RunTillFullySubscribed

}

struct RoundNft
{
   uint Id;
   address Investor;
   address NftContractAddress;
   uint TokenId;
   uint UnderlyingFundAmount;
   uint RoundId;
}

struct 
