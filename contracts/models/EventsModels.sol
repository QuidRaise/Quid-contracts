// SPDX-License-Identifier: MIT

pragma solidity 0.7.0;
interface EventModels
{

    
 struct CompanyDeposit{
        uint  CompanyId;
        uint  RoundId;
        address  Sender;
        address TokenContractAddress;
        uint Amount;
 }

 struct CompanyWithdrawal{
        uint CompanyId;
        uint RoundId;
        address Receiver;
        address TokenContractAddress;
        uint Amount;
 }

 struct InvestmentDeposit{
        uint CompanyId;
        uint RoundId;  
        address Sender;
        address TokenContractAddress;
        uint Amount;
 }

struct InvestmentWithdrawal{
        uint  CompanyId;
        uint  RoundId; 
        address  Receiver;
        address TokenContractAddress;
        uint Amount;
}

struct WhitelistCompanyOwner{
        address  CompanyOwner;
        address  PerformedBy;
}

struct BlacklistCompanyOwner{
        address  CompanyOwner;
        address  PerformedBy;
}


struct WhitelistCompany{
        address  CompanyId;
        address  PerformedBy;
}

struct BlacklistCompany{
        address  CompanyId;
        address  PerformedBy;
}

struct WhitelistInvestor{
        address  Investor;
        address  PerformedBy;
}

struct BlacklistInvestor{
        address  Investor;
        address  PerformedBy;
}

struct C2CAccessGrant{
    address  SourceContract;
    address  DestinationContract;
    address  PerformedBy;
}

struct C2CAccessRevoked{
    address  SourceContract;
    address  DestinationContract;
    address  PerformedBy;
}


struct CompanyCreated{
    uint  CompanyId; 
    address  CompanyOwner;
    address  PerformedBy;
    string CompanyName;
    string LogoUrl;
    string CompanyDocumentUrl;
    address CompanyTokenContract;
}

struct ProposalCreated{
    uint  ProposalId;
    uint  CompanyId;
    address  CompanyOwner;
    address CompanyTokenContract;
    uint ProposalAmount;
    uint ProposalStartTimestamp;
    uint ProposalDuration;
}

struct RoundCreated{
    uint  RoundId;
    uint  CompanyId;
    address  CompanyOwner;
    uint LockupPeriodForSHares;
    uint PricePerShare;
    uint TokensSuppliedForRound;
    uint StartTimestamp;
    uint RoundDuration;
    uint RunTillFullySubscribed;
}

struct ShareCertificateCreated{
    uint  RegistryId;
    uint  TokenId;
    uint  RoundId;
    uint UnderlyingFundAmount;
    address nftTokenContractAddress;    
}



}

