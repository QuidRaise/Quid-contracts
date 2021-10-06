// SPDX-License-Identifier: MIT
import '../models/Schema.sol';

pragma experimental ABIEncoderV2;
pragma solidity 0.7.0;

interface IProposalStore {
    function getProposal(uint id) external returns (Proposal memory);
    function getCompanyProposals(uint companyId) external returns (Proposal[] memory);
    function updateProposal(uint id, Proposal memory proposal) external;
    function createProposal(Proposal memory proposal) external returns (uint);
}
