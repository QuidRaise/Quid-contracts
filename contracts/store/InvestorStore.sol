// SPDX-License-Identifier: MIT

import "./interface/IInvestorStore.sol";
import "../infrastructure/BaseContract.sol";
import "../models/Schema.sol";

pragma experimental ABIEncoderV2;

pragma solidity 0.7.0;

contract InvestorStore is BaseContract, IInvestorStore {
    mapping(address => Index) private _investorsIndex;
    Investor[] private _investors;

    mapping(address => Index[]) private _investorRoundsIndex;
    mapping(address => mapping(uint256 => Index)) private _investorRoundIndex;
    RoundInvestment[] private _investorRounds;

    mapping(address => Index[]) private _investorProposalsIndex;
    mapping(address => mapping(uint256 => Index)) private _investorProposalIndex;
    ProposalVote[] private _investorProposalVotes;

    //TODO: Need To Create Getter and Setter functions for this field so we can track how much an investor has invested in
    mapping(address => mapping(address => uint256)) private _investorInvestmentsAcrossCurrencies;

    constructor(address dnsContract) BaseContract(dnsContract) {}

    function isInvestor(address investorAddress) external view override returns (bool) {
        return _investorsIndex[investorAddress].Exists;
    }

    function getInvestor(address investorAddress) external view override returns (Investor memory) {
        Index memory index = _investorsIndex[investorAddress];
        require(index.Exists, "Record not found");
        return _investors[index.Index];
    }

    function getAmountInvestorHasSpent(address investorAddress, address paymentCurrencyAddress) external view override returns (uint256) {
        return _investorInvestmentsAcrossCurrencies[investorAddress][paymentCurrencyAddress];
    }

    function updateInvestor(address investorAddress, Investor memory investor) external override c2cCallValid {
        Index memory index = _investorsIndex[investorAddress];
        if (index.Exists) {
            _investors[index.Index] = investor;
        } else {
            uint256 recordIndex = _investors.length;
            _investors.push(investor);
            _investorsIndex[investorAddress] = Index(recordIndex, true);
        }
    }

    function createInvestor(Investor memory investor) external override c2cCallValid {
        Index memory index = _investorsIndex[investor.WalletAddress];
        require(!index.Exists, "Cannot insert duplicate");

        uint256 recordIndex = _investors.length;
        _investors.push(investor);
        _investorsIndex[investor.WalletAddress] = Index(recordIndex, true);
    }

    function updateRoundsInvestment(address investorAddress, RoundInvestment memory roundInvestment) external override c2cCallValid {
        Index memory index = _investorRoundIndex[investorAddress][roundInvestment.RoundId];
        if (index.Exists) {
            _investorRounds[index.Index] = roundInvestment;
        } else {
            uint256 recordIndex = _investorRounds.length;
            Index memory indexRecord = Index(recordIndex, true);
            _investorRounds.push(roundInvestment);
            _investorRoundsIndex[investorAddress].push(indexRecord);
            _investorRoundIndex[investorAddress][roundInvestment.RoundId] = indexRecord;
        }
    }

    function updateProposalsVotedIn(address investorAddress, ProposalVote memory proposalVote) external override c2cCallValid {
        Index memory index = _investorProposalIndex[investorAddress][proposalVote.ProposalId];
        if (index.Exists) {
            _investorProposalVotes[index.Index] = proposalVote;
        } else {
            uint256 recordIndex = _investorProposalVotes.length;
            Index memory indexRecord = Index(recordIndex, true);
            _investorProposalVotes.push(proposalVote);
            _investorProposalsIndex[investorAddress].push(indexRecord);
            _investorProposalIndex[investorAddress][proposalVote.ProposalId] = indexRecord;
        }
    }

    function getRoundsInvestedIn(address investorAddress) external view override returns (RoundInvestment[] memory) {
        Index[] memory indexes = _investorRoundsIndex[investorAddress];
        RoundInvestment[] memory investments = new RoundInvestment[](indexes.length);
        for (uint256 i = 0; i < indexes.length; i++) {
            investments[i] = _investorRounds[indexes[i].Index];
        }
        return investments;
    }

    function getProposalVotes(address investorAddress) external view override returns (ProposalVote[] memory) {
        Index[] memory indexes = _investorProposalsIndex[investorAddress];
        ProposalVote[] memory proposalVotes = new ProposalVote[](indexes.length);
        for (uint256 i = 0; i < indexes.length; i++) {
            proposalVotes[i] = _investorProposalVotes[indexes[i].Index];
        }
        return proposalVotes;
    }

    function votedInProposal(address investorAddress, uint256 proposalId) external view override returns(bool)
    {
        Index memory index = _investorProposalIndex[investorAddress][proposalId];
        return index.Exists;

    }

    function getProposalVote(address investorAddress, uint256 proposalId) external view override returns (ProposalVote memory) {
        Index memory index = _investorProposalIndex[investorAddress][proposalId];
        return _investorProposalVotes[index.Index];
    }

    function investedInRound(address investorAddress, uint256 roundId) external view override returns (bool) {
        Index memory index = _investorRoundIndex[investorAddress][roundId];
        return index.Exists;
    }


    function getRoundInvestment(address investorAddress, uint256 roundId) external view override returns (RoundInvestment memory) {
        Index memory index = _investorRoundIndex[investorAddress][roundId];
        return _investorRounds[index.Index];
    }
}
