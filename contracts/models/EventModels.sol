// SPDX-License-Identifier: MIT

pragma solidity 0.7.0;
pragma experimental ABIEncoderV2;

struct ProposalVoteRequest
{
    uint256 ProposalId;
    address Investor;
    bool IsApproved;
}

struct CompanyDepositRequest {
    uint256 CompanyId;
    uint256 RoundId;
    address Sender;
    address TokenContractAddress;
    uint256 Amount;
}

struct CompanyWithdrawalRequest {
    uint256 CompanyId;
    uint256 RoundId;
    address Receiver;
    address TokenContractAddress;
    uint256 Amount;
}

struct InvestmentDepositRequest {
    uint256 CompanyId;
    uint256 RoundId;
    address Sender;
    address TokenContractAddress;
    uint256 Amount;
    uint256 TokenQuantity;
}

struct InvestmentWithdrawalRequest {
    uint256 CompanyId;
    uint256 RoundId;
    address Receiver;
    address TokenContractAddress;
    uint256 Amount;
}

struct WhitelistCompanyOwnerRequest {
    address CompanyOwner;
    address PerformedBy;
}

struct BlacklistCompanyOwnerRequest {
    address CompanyOwner;
    address PerformedBy;
}

struct WhitelistCompanyRequest {
    uint256 CompanyId;
    address PerformedBy;
}

struct BlacklistCompanyRequest {
    uint256 CompanyId;
    address PerformedBy;
}

struct WhitelistInvestorRequest {
    address Investor;
    address PerformedBy;
}

struct BlacklistInvestorRequest {
    address Investor;
    address PerformedBy;
}

struct C2CAccessGrantRequest {
    address SourceContract;
    address DestinationContract;
    address PerformedBy;
}

struct C2CAccessRevokedRequest {
    address SourceContract;
    address DestinationContract;
    address PerformedBy;
}

struct CompanyCreatedRequest {
    uint256 CompanyId;
    address CompanyOwner;
    address PerformedBy;
    string CompanyName;
    string CompanyDocumentUrl;
    address CompanyTokenContract;
}

struct ProposalCreatedRequest {
    uint256 ProposalId;
    uint256 CompanyId;
    address CompanyOwner;
    address CompanyTokenContract;
    uint256[] ProposalAmount;
    address[] PaymentCurrencies;
    uint256 ProposalStartTimestamp;
    uint256 ProposalDuration;
}

struct RoundCreatedRequest {
    uint256 RoundId;
    uint256 CompanyId;
    address CompanyOwner;
    uint256 LockupPeriodForShares;
    uint256 TokensSuppliedForRound;
    uint256 StartTimestamp;
    uint256 RoundDuration;
    bool RunTillFullySubscribed;
    address[] PaymentCurrencies;
    uint256[] PricePerShare;
}

struct ShareCertificateCreatedRequest {
    uint256 TokenId;
    uint256 RoundId;
    address Investor;
    uint256 UnderlyingFundAmount;
    address nftTokenContractAddress;
}
