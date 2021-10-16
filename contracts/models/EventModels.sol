// SPDX-License-Identifier: MIT

pragma solidity 0.7.0;

    
 struct CompanyDepositRequest{
        uint  CompanyId;
        uint  RoundId;
        address  Sender;
        address TokenContractAddress;
        uint Amount;
 }

 struct CompanyWithdrawalRequest{
        uint CompanyId;
        uint RoundId;
        address Receiver;
        address TokenContractAddress;
        uint Amount;
 }

 struct InvestmentDepositRequest{
        uint CompanyId;
        uint RoundId;  
        address Sender;
        address TokenContractAddress;
        uint Amount;
 }

struct InvestmentWithdrawalRequest{
        uint  CompanyId;
        uint  RoundId; 
        address  Receiver;
        address TokenContractAddress;
        uint Amount;
}

struct WhitelistCompanyOwnerRequest{
        address  CompanyOwner;
        address  PerformedBy;
}

struct BlacklistCompanyOwnerRequest{
        address  CompanyOwner;
        address  PerformedBy;
}


struct WhitelistCompanyRequest{
        address  CompanyId;
        address  PerformedBy;
}

struct BlacklistCompanyRequest{
        address  CompanyId;
        address  PerformedBy;
}

struct WhitelistInvestorRequest{
        address  Investor;
        address  PerformedBy;
}

struct BlacklistInvestorRequest{
        address  Investor;
        address  PerformedBy;
}

struct C2CAccessGrantRequest{
    address  SourceContract;
    address  DestinationContract;
    address  PerformedBy;
}

struct C2CAccessRevokedRequest{
    address  SourceContract;
    address  DestinationContract;
    address  PerformedBy;
}


struct CompanyCreatedRequest{
    uint  CompanyId; 
    address  CompanyOwner;
    address  PerformedBy;
    string CompanyName;    
    string CompanyDocumentUrl;
    address CompanyTokenContract;
}

struct ProposalCreatedRequest{
    uint  ProposalId;
    uint  CompanyId;
    address  CompanyOwner;
    address CompanyTokenContract;
    uint ProposalAmount;
    uint ProposalStartTimestamp;
    uint ProposalDuration;
}

struct RoundCreatedRequest{
    uint  RoundId;
    uint  CompanyId;
    address  CompanyOwner;
    uint LockupPeriodForShares;
    uint PricePerShare;
    uint TokensSuppliedForRound;
    uint StartTimestamp;
    uint RoundDuration;
    uint RunTillFullySubscribed;
    address[] paymentCurrencies;
}

struct ShareCertificateCreatedRequest{
    uint  RegistryId;
    uint  TokenId;
    uint  RoundId;
    uint UnderlyingFundAmount;
    address nftTokenContractAddress;    
}


