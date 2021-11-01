// SPDX-License-Identifier: MIT
import "../models/Schema.sol";

pragma experimental ABIEncoderV2;
pragma solidity 0.7.0;

interface IProposalStore {
    function getProposal(uint256 id) external view returns (Proposal memory);

    function getCompanyProposals(uint256 companyId) external view returns (Proposal[] memory);

    function updateProposal(Proposal memory proposal) external;

    function createProposal(Proposal memory proposal) external returns (uint256);
}
