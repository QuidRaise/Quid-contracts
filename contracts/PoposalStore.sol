// SPDX-License-Identifier: MIT
import "./models/Schema.sol";
import "./interfaces/IproposalStore.sol";


pragma experimental ABIEncoderV2;
pragma solidity 0.7.0;

contract ProposalStore is IProposalStore {

   mapping(uint256=> Index) private _proposalIndex;
   mapping(uint256=> Index[]) private _companyProposals;

   mapping(uint256 => mapping(uint256 => Index)) private _companyProposalIndex;
   Proposal[] private _proposals;
   
    function getProposal(uint id) external override view returns (Proposal memory)
    {
       Index memory index = _proposalIndex[id];
       require(index.Exists, "Record not found");
       return _proposals[index.Index];

    }

    function getCompanyProposals(uint companyId) external override view returns (Proposal[] memory)
    {
       Index[] memory indexes = _companyProposals[companyId];
       Proposal[] memory proposals = new Proposal[](indexes.length);

       for (uint256 i = 0; i < indexes.length; i++) {
           uint256 recordIndex = indexes[i].Index;
           proposals[recordIndex] = _proposals[recordIndex];
           
       }


       return proposals;

    }

    function updateProposal(uint id, Proposal memory proposal) external override
    {

    }

    function createProposal(Proposal memory proposal) external override returns (uint)
    {

    }

}
