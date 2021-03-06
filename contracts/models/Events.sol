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

    event ProposalVote
    (
        uint256 indexed proposalId,
        address indexed investor,
        bool isApproved
    );

    event CompanyDeposit(uint256 indexed companyId, uint256 indexed roundId, address indexed sender, address tokenContractAddress, uint256 amount);

    event CompanyWithdrawal(
        uint256 indexed companyId,
        uint256 indexed roundId,
        address indexed receiver,
        address tokenContractAddress,
        uint256 amount
    );

    event InvestmentDeposit(uint256 indexed companyId, uint256 indexed roundId, address indexed sender, address tokenContractAddress, uint256 amount, uint256 tokenQuantity);

    event InvestmentWithdrawal(
        uint256 indexed companyId,
        uint256 indexed roundId,
        address indexed receiver,
        address tokenContractAddress,
        uint256 amount
    );

    event WhitelistCompanyOwner(address indexed companyOwner, address indexed performedBy);

    event BlacklistCompanyOwner(address indexed companyOwner, address indexed performedBy);

    event WhitelistCompany(uint256 indexed companyId, address indexed performedBy);

    event BlacklistCompany(uint256 indexed companyId, address indexed performedBy);

    event WhitelistInvestor(address indexed investor, address indexed performedBy);

    event BlacklistInvestor(address indexed investor, address indexed performedBy);

    event C2CAccessGrant(address indexed sourceContract, address indexed destinationContract, address indexed performedBy);

    event C2CAccessRevoked(address indexed sourceContract, address indexed destinationContract, address indexed performedBy);

    event CompanyCreated(
        uint256 indexed companyId,
        address indexed companyOwner,
        address indexed performedBy,
        string companyName,
        string companyDocumentUrl,
        address companyTokenContract
    );

    event RoundCreated(
        uint256 indexed roundId,
        uint256 indexed companyId,
        address indexed companyOwner,
        uint256 lockupPeriodForSHares,
        uint256 tokensSuppliedForRound,
        uint256 startTimestamp,
        uint256 roundDuration,
        bool runTillFullySubscribed,
        address[] paymentCurrencies,
        uint256[] pricePerShare
    );

    event ProposalCreated(
        uint256 indexed proposalId,
        uint256 indexed companyId,
        address indexed companyOwner,
        address companyTokenContract,
        uint256[] proposalAmount,
        address[] paymentCurrencies,
        uint256 proposalStartTimestamp,
        uint256 proposalDuration
    );

  

    event ShareCertificateCreated(
        uint256 indexed tokenId,
        uint256 indexed roundId,
        address indexed investor,
        uint256 underlyingFundAmount,
        address nftTokenContractAddress
    );
}
