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
    event CompanyDeposit(uint256 indexed companyId, uint256 indexed roundId, address indexed sender, address tokenContractAddress, uint256 amount);

    event CompanyWithdrawal(
        uint256 indexed companyId,
        uint256 indexed roundId,
        address indexed receiver,
        address tokenContractAddress,
        uint256 amount
    );

    event InvestmentDeposit(uint256 indexed companyId, uint256 indexed roundId, address indexed sender, address tokenContractAddress, uint256 amount);

    event InvestmentWithdrawal(
        uint256 indexed companyId,
        uint256 indexed roundId,
        address indexed receiver,
        address tokenContractAddress,
        uint256 amount
    );

    event WhitelistCompanyOwner(address indexed companyOwner, address indexed performedBy);

event BlacklistCompanyOwner(
        address indexed companyOwner,
        address indexed performedBy
);


event WhitelistCompany(
        uint indexed companyId,
        address indexed performedBy
);

event BlacklistCompany(
        uint indexed companyId,
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


event ShareCertificateCreated(
    uint indexed registryId,
    uint indexed tokenId,
    uint indexed roundId,
    uint underlyingFundAmount,
    address nftTokenContractAddress    
);

event CompanyCreated(string CompanyUrl);

}
