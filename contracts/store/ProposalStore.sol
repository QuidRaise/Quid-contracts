// SPDX-License-Identifier: MIT
import "../models/Schema.sol";
import "../BaseContract.sol";

import "./interface/IProposalStore.sol";
import "../libraries/SafeMath.sol";

pragma experimental ABIEncoderV2;
pragma solidity 0.7.0;

contract ProposalStore is BaseContract, IProposalStore {
    using SafeMath for uint256;

    mapping(uint256 => Index) private _proposalIndex;
    mapping(uint256 => Index[]) private _companyProposals;

    mapping(uint256 => mapping(uint256 => Index)) private _companyProposalIndex;
    Proposal[] private _proposals;

    constructor(address dnsContract) BaseContract(dnsContract) {}

    function getProposal(uint256 id) external view override returns (Proposal memory) {
        Index memory index = _proposalIndex[id];
        require(index.Exists, "Record not found");
        return _proposals[index.Index];
    }

    function getCompanyProposals(uint256 companyId) external view override returns (Proposal[] memory) {
        Index[] memory indexes = _companyProposals[companyId];
        Proposal[] memory proposals = new Proposal[](indexes.length);

        for (uint256 i = 0; i < indexes.length; i++) {
            uint256 recordIndex = indexes[i].Index;
            proposals[recordIndex] = _proposals[recordIndex];
        }
        return proposals;
    }

    function updateProposal(Proposal memory proposal) external override c2cCallValid {
        Index memory index = _companyProposalIndex[proposal.CompanyId][proposal.Id];
        require(!index.Exists, "Record not found");
        Proposal memory currentProposal = _proposals[index.Index];

        proposal.Id = currentProposal.Id;
        proposal.CompanyId = currentProposal.CompanyId;

        _proposals[index.Index] = proposal;
    }

    function createProposal(Proposal memory proposal) external override c2cCallValid returns (uint256) {
        Index memory index = _companyProposalIndex[proposal.CompanyId][proposal.Id];
        require(!index.Exists, "Record already exist");

        uint256 recordIndex = _proposals.length;
        proposal.Id = recordIndex.add(1);

        index = Index(recordIndex, true);

        _proposals.push(proposal);
        _proposalIndex[proposal.Id] = index;
        _companyProposals[proposal.CompanyId].push(index);
        _companyProposalIndex[proposal.CompanyId][proposal.Id] = index;
    }
}
