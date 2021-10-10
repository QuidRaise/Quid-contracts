// SPDX-License-Identifier: MIT

pragma solidity 0.7.0;


/**
  * IdentityContract Events
  *  WhitelistCompanyOwner, BlacklistCompanyOwner, WhitelistCompany, BlacklistCompany
  *  WhitelistInvestor, BlacklistInvestor, C2CAccessGrant, C2CAccessRevoked
  *
  * CompanyVault Events
  * CompanyDeposit, CompanyWithdrawal, InvestmentDeposit, InvestmentWithdrawal
  * 
  * CompanyController Events
  * CompanyCreated, ProposalCreated, RoundCreated, ShareCertificateCreated
  *
 */
abstract contract Events {


 event CompanyDeposit(
        uint indexed companyId,
        uint indexed roundId,  
        address indexed sender,
        address tokenContractAddress,

        uint amount
);

 event CompanyWithdrawal(
        uint indexed companyId,
        uint indexed roundId,  
        address indexed receiver,
        address tokenContractAddress,
        uint amount
);

 event InvestmentDeposit(
        uint indexed companyId,
        uint indexed roundId,  
        address indexed sender,
        address tokenContractAddress,
        uint amount
);

event InvestmentWithdrawal(
        uint indexed companyId,
        uint indexed roundId,  
        address indexed receiver,
        address tokenContractAddress,
        uint amount
);

event WhitelistCompanyOwner(
        address indexed companyOwner,
        address indexed performedBy
);

event BlacklistCompanyOwner(
        address indexed companyOwner,
        address indexed performedBy
);


event WhitelistCompany(
        address indexed companyId,
        address indexed performedBy
);

event BlacklistCompany(
        address indexed companyId,
        address indexed performedBy
);

event WhitelistInvestor(
        address indexed investor,
        address indexed performedBy
);

event BlacklistInvestor(
        address indexed investor,
        address indexed performedBy
);

event C2CAccessGrant(
    address indexed sourceContract,
    address indexed destinationContract,
    address indexed performedBy
);

event C2CAccessRevoked(
    address indexed sourceContract,
    address indexed destinationContract,
    address indexed performedBy
);


event CompanyCreated(
    uint indexed companyId, 
    address indexed companyOwner,
    address indexed performedBy,
    string companyName,
    string logoUrl,
    string companyDocumentUrl,
    address companyTokenContract
);

event ProposalCreated(
    uint indexed proposalId,
    uint indexed companyId,
    address indexed companyOwner,
    address companyTokenContract,
    uint proposalAmount,
    uint proposalStartTimestamp,
    uint proposalDuration
);

event RoundCreated(
    uint indexed roundId,
    uint indexed companyId,
    address indexed companyOwner,
    uint lockupPeriodForSHares,
    uint pricePerShare,
    uint tokensSuppliedForRound,
    uint startTimestamp,
    uint roundDuration,
    uint runTillFullySubscribed
);

event ShareCertificateCreated(
    uint indexed registryId,
    uint indexed tokenId,
    uint indexed roundId,
    uint underlyingFundAmount,
    address nftTokenContractAddress    
);








}

