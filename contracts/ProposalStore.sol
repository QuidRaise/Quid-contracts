// SPDX-License-Identifier: MIT

import "./interfaces/IProposalStore.sol";
import "./BaseContract.sol";
import "./models/Schema.sol";


pragma experimental ABIEncoderV2;

pragma solidity 0.7.0;

contract ProposalStore is BaseContract, IProposalStore {
    
    Proposal[] _proposals;

    mapping (uint  => Proposal[]) _companyProposals;

    constructor(address dnsContract) BaseContract(dnsContract) {

    }

    function getProposal(uint id) external view override returns (Proposal memory) {
        return _proposals[id];
    }

    function getCompanyProposals(uint companyId) external view override returns (Proposal[] memory) {
        return _companyProposals[companyId];
    }

    function updateProposal(uint id, Proposal memory proposal) external override {
        _proposals[id] = proposal;
    }

    function createProposal(Proposal memory proposal) external override returns(uint) {
        uint id = _proposals.length + 1;
        proposal.Id = id;
        _proposals.push(proposal);
        _companyProposals[proposal.CompanyId].push(proposal);
        return id;
    }
}
