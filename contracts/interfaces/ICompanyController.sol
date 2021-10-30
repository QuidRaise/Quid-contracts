// SPDX-License-Identifier: MIT
import "../models/Schema.sol";

pragma experimental ABIEncoderV2;
pragma solidity 0.7.0;

interface ICompanyController {
    function createCompany(string calldata companyUrl,
                           string calldata companyName, address companyTokenContractAddress, 
                           address companyOwner,address companyCreatedBy) external;

    function createRound(address companyOwner,string calldata roundDocumentUrl, uint startTimestamp, uint duration,
                         uint lockupPeriodForShare, 
                         uint tokensSuppliedForRound,bool runTillFullySubscribed, address[] memory paymentCurrencies,uint256[] memory pricePerShare) external;



    function createProposal(uint amountRequested, uint votingStartTimestamp, address companyOwner ) external;
    function getProposalResult(uint proposalId) view external returns (ProposalResponse memory);
    function getRound(uint roundId) external view returns (RoundResponse memory) ;
    function releaseProposalBudget(uint proposalId, address companyOwnerAddress) external;

    function deleteProposal(uint proposalId, address companyOwnerAddress) external;
    function deleteRound(uint proposalId, address companyOwnerAddress) external;


}
