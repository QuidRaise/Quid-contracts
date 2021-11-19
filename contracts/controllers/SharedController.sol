// SPDX-License-Identifier: MIT
import "../models/Schema.sol";
import "../models/EventModels.sol";

import "../infrastructure/BaseContract.sol";
import "../libraries/SafeERC20.sol";
import "../libraries/ReentrancyGuard.sol";

import "./interface/ICompanyProposalController.sol";
import "../store/interface/ICompanyStore.sol";
import "../store/interface/IProposalStore.sol";
import "../store/interface/IRoundStore.sol";
import "../vault/interface/ICompanyVault.sol";

import "../store/interface/ICompanyVaultStore.sol";

import "../events/interface/IEventEmitter.sol";
import "../infrastructure/interface/IIdentityContract.sol";
import "../interfaces/IERC20.sol";
import "../interfaces/IConfig.sol";

pragma experimental ABIEncoderV2;
pragma solidity 0.7.0;

abstract contract SharedController is BaseContract {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    constructor(address dnsContract) BaseContract(dnsContract) {
       
    }
  

    function ensureCompanyIsWhitelisted(uint256 companyId, address companyOwner) internal view {
        IIdentityContract _identityContract = IIdentityContract(_dns.getRoute(IDENTITY_CONTRACT));

        require(_identityContract.isCompanyAddressWhitelisted(companyOwner), "Address blacklisted");
        require(_identityContract.isCompanyWhitelisted(companyId), "Company blacklisted");
    }


    function isRoundOpen(Round memory round) internal view returns (bool) {
        if (round.RunTillFullySubscribed) {
            if (round.TotalTokensUpForSale == round.TotalTokensSold) {
                return false;
            } else {
                return true;
            }
        } else {
            uint256 expiryTime = round.RoundStartTimeStamp.add(round.DurationInSeconds);

            if (block.timestamp <= expiryTime) {
                return true;
            } else {
                return false;
            }
        }
    }

    function doesCompanyHaveOpenRound(uint256 companyId) internal view returns (bool) {
        IRoundStore _roundStore = IRoundStore(_dns.getRoute(ROUND_STORE));

        Round[] memory rounds = _roundStore.getCompanyRounds(companyId);
        if(rounds.length==0)
            return false;

        Round memory lastRound = rounds[rounds.length - 1];
        return isRoundOpen(lastRound);
    }

    function doesCompanyHaveOpenProposal(uint256 companyId) internal view returns (bool) {
        IProposalStore _proposalStore = IProposalStore(_dns.getRoute(PROPOSAL_STORE));

        Proposal[] memory proposals = _proposalStore.getCompanyProposals(companyId);

        if(proposals.length==0)
            return false;

        Proposal memory lastProposal = proposals[proposals.length - 1];

        if (lastProposal.IsDeleted) {
            return false;
        } else {
            uint256 expiryTime = lastProposal.VoteStartTimeStamp.add(lastProposal.VoteSessionDuration);
            if (block.timestamp <= expiryTime) {
                return true;
            } else {
                return false;
            }
        }
    }

}
