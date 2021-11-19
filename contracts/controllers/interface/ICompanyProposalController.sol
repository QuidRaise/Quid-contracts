// SPDX-License-Identifier: MIT
import "../../models/Schema.sol";

pragma experimental ABIEncoderV2;
pragma solidity 0.7.0;

interface ICompanyProposalController {   

    function createProposal(
        uint256[] calldata amountRequested,
        address[] calldata paymentCurrencies,
        uint256 votingStartTimestamp,
        address companyOwner
    ) external;

    function getProposalResult(uint256 proposalId) external view returns (ProposalResponse memory);
  
    function releaseProposalBudget(uint256 proposalId, address companyOwnerAddress) external;

    function deleteProposal(uint256 proposalId, address companyOwnerAddress) external;

}
