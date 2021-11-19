// SPDX-License-Identifier: MIT
import "../models/Schema.sol";
import "../models/EventModels.sol";

import "./SharedController.sol";
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

contract CompanyProposalController is SharedController, ReentrancyGuard, ICompanyProposalController {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    constructor(address dnsContract) SharedController(dnsContract) {
       
    }

   
   

    function createProposal(
        uint256[] calldata amountRequested,
        address[] calldata paymentCurrencies,
        uint256 votingStartTimestamp,
        address companyOwner
    ) external override nonReentrant c2cCallValid {

        ICompanyStore _companyStore = ICompanyStore(_dns.getRoute(COMPANY_STORE));
        IConfig _config = IConfig(_dns.getRoute(CONFIG));
        IProposalStore _proposalStore = IProposalStore(_dns.getRoute(PROPOSAL_STORE));
        IEventEmitter _eventEmitter = IEventEmitter(_dns.getRoute(EVENT_EMITTER));


        require(_config.getNumericConfig(MAX_ROUND_PAYMENT_OPTION) >= paymentCurrencies.length, "Exceeded number of payment options");

        require(_companyStore.isCompanyOwner(companyOwner), "Could not find a company owned by this user");
        Company memory company = _companyStore.getCompanyByOwner(companyOwner);

        ensureCompanyIsWhitelisted(company.Id, companyOwner);

        validateProposalCreationAction(company.Id);

        Proposal memory proposal = Proposal(
            0,
            company.Id,
            amountRequested,
            paymentCurrencies,
            getVoteDuration(),
            votingStartTimestamp,
            0,
            0,
            0,
            0,
            false,
            false
        );
        uint256 propoalId = _proposalStore.createProposal(proposal);

        _eventEmitter.emitProposalCreatedEvent(
            ProposalCreatedRequest(
                propoalId,
                company.Id,
                companyOwner,
                company.CompanyTokenContractAddress,
                proposal.AmountRequested,
                proposal.PaymentCurrencies,
                proposal.VoteStartTimeStamp,
                proposal.VoteSessionDuration
            )
        );
    }

    function getProposalResult(uint256 proposalId) external view override returns (ProposalResponse memory) {
        IProposalStore _proposalStore = IProposalStore(_dns.getRoute(PROPOSAL_STORE));

        Proposal memory proposal = _proposalStore.getProposal(proposalId);

        bool hasVotingPeriodElapsed = false;
        uint256 expiryDate = proposal.VoteStartTimeStamp.add(proposal.VoteSessionDuration);
        if (block.timestamp > expiryDate) {
            hasVotingPeriodElapsed = true;
        }

        ProposalResponse memory response = ProposalResponse(
            proposal.ApprovedVotes,
            proposal.RejectedVotes,
            proposal.TokensStakedForApprovedVotes,
            proposal.TokensStakedForRejectedVotes,
            isProposalApproved(proposal, hasVotingPeriodElapsed),
            hasVotingPeriodElapsed
        );

        return response;
    }

    
    function releaseProposalBudget(uint256 proposalId, address companyOwner) external override nonReentrant c2cCallValid {
        
        ICompanyStore _companyStore = ICompanyStore(_dns.getRoute(COMPANY_STORE));
        IProposalStore _proposalStore = IProposalStore(_dns.getRoute(PROPOSAL_STORE));
        ICompanyVault _companyVault = ICompanyVault(_dns.getRoute(COMPANY_VAULT));
        ICompanyVaultStore _companyVaultStore = ICompanyVaultStore(_dns.getRoute(COMPANY_VAULT_STORE));
        
        require(!_companyStore.isCompanyOwner(companyOwner), "Could not find a company owned by this user");

        Proposal memory proposal = _proposalStore.getProposal(proposalId);
        Company memory company = _companyStore.getCompanyById(proposal.CompanyId);

        ensureCompanyIsWhitelisted(company.Id, companyOwner);

        require(company.Id == proposal.CompanyId, "Unauthorized access to proposal budget");

        require(company.OwnerAddress == companyOwner, "Unauthorized access to proposal budegt");
        require(!proposal.IsDeleted, "Proposal has been deleted");
        require(!proposal.HasWithdrawn, "Proposal has been withdrawn from");
        require(block.timestamp >= proposal.VoteStartTimeStamp.add(proposal.VoteSessionDuration), "Proposal has not ended");

        proposal.HasWithdrawn = true;
        _proposalStore.updateProposal(proposal);

        for (uint256 i = 0; i < proposal.PaymentCurrencies.length; i++) {
            address currency = proposal.PaymentCurrencies[i];
            uint256 balance = _companyVaultStore.getCompanyVaultBalance(proposal.CompanyId, currency);
            require(balance >= proposal.AmountRequested[i], "Insufficient Vault Balance");
            _companyVault.withdrawPaymentTokensFromVault(proposal.CompanyId, currency, proposal.AmountRequested[i]);
        }
    }

    
    function deleteProposal(uint256 proposalId, address companyOwnerAddress) external override c2cCallValid nonReentrant {
        ICompanyStore _companyStore = ICompanyStore(_dns.getRoute(COMPANY_STORE));
        IProposalStore _proposalStore = IProposalStore(_dns.getRoute(PROPOSAL_STORE));


        Proposal memory proposal = _proposalStore.getProposal(proposalId);
        Company memory company = _companyStore.getCompanyById(proposal.CompanyId);
        require(company.OwnerAddress == companyOwnerAddress, "Unauthorized access to proposal");
        require(!proposal.IsDeleted, "Proposal has been deleted");
        require(proposal.ApprovedVotes == 0 && proposal.RejectedVotes == 0, "Proposal can no longer be deleted");
        proposal.IsDeleted = true;
        _proposalStore.updateProposal(proposal);
        //TODO: Emit Proposal Deleted Event;
    }


    function isProposalApproved(Proposal memory proposal, bool hasVotingPeriodElapsed) internal pure returns (bool) {
        if (!hasVotingPeriodElapsed) {
            return false;
        } else {
            uint256 weightedApprovals = proposal.ApprovedVotes.mul(proposal.TokensStakedForApprovedVotes);
            uint256 weightedRejections = proposal.RejectedVotes.mul(proposal.TokensStakedForRejectedVotes);

            if (weightedApprovals > weightedRejections) {
                return true;
            } else {
                return false;
            }
        }
    }

    function validateProposalCreationAction(uint256 companyId) internal view {
        bool hasOpenRound = doesCompanyHaveOpenRound(companyId);
        require(!hasOpenRound, "Company has an open round");

        bool hasOpenProposal = doesCompanyHaveOpenProposal(companyId);
        require(!hasOpenProposal, "Company has an open proposal");
    }

    function getVoteDuration() internal view returns (uint256) {
        IConfig _config = IConfig(_dns.getRoute(CONFIG));
        return _config.getNumericConfig(VOTE_DURATION);
    }

}
