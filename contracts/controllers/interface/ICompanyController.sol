// SPDX-License-Identifier: MIT
import "../../models/Schema.sol";

pragma experimental ABIEncoderV2;
pragma solidity 0.7.0;

interface ICompanyController {
    function createCompany(
        string calldata companyUrl,
        string calldata companyName,
        address companyTokenContractAddress,
        address companyOwner,
        address companyCreatedBy
    ) external;

    function createRound(
        address companyOwner,
        string calldata roundDocumentUrl,
        uint256 startTimestamp,
        uint256 duration,
        uint256 lockupPeriodForShare,
        uint256 tokensSuppliedForRound,
        bool runTillFullySubscribed,
        address[] memory paymentCurrencies,
        uint256[] memory pricePerShare
    ) external;

    function createProposal(
        uint256[] calldata amountRequested,
        address[] calldata paymentCurrencies,
        uint256 votingStartTimestamp,
        address companyOwner
    ) external;

    function getProposalResult(uint256 proposalId) external view returns (ProposalResponse memory);

    function getRound(uint256 roundId) external view returns (RoundResponse memory);

    function releaseProposalBudget(uint256 proposalId, address companyOwnerAddress) external;

    function deleteProposal(uint256 proposalId, address companyOwnerAddress) external;

    function deleteRound(uint256 proposalId, address companyOwnerAddress) external;
}
