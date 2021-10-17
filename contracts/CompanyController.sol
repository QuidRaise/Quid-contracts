// SPDX-License-Identifier: MIT
import "./models/Schema.sol";
import "./models/EventModels.sol";

import "./BaseContract.sol";
import "./DataGrant.sol";
import "./libraries/SafeERC20.sol";

import "./interfaces/ICompanyController.sol";
import "./interfaces/ICompanyStore.sol";
import "./interfaces/IProposalStore.sol";
import "./interfaces/IRoundStore.sol";
import "./interfaces/ICompanyVault.sol";
import "./interfaces/IEventEmitter.sol";
import "./interfaces/IIdentityContract.sol";
import "./interfaces/IInvestorStore.sol";
import "./interfaces/IERC20.sol";

pragma experimental ABIEncoderV2;
pragma solidity 0.7.0;

contract CompanyController is BaseContract, DataGrant, ICompanyController {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    ICompanyStore _companyStore;
    IProposalStore _proposalStore;
    IRoundStore _roundStore;
    ICompanyVault _companyVault;
    IEventEmitter _eventEmitter;
    IIdentityContract _identityContract;
    IInvestorStore _investorStore;

    constructor(address dnsContract) BaseContract(dnsContract) {
        _companyStore = ICompanyStore(_dns.getRoute(COMPANY_STORE));
        _proposalStore = IProposalStore(_dns.getRoute(PROPOSAL_STORE));
        _roundStore = IRoundStore(_dns.getRoute(ROUND_STORE));
        _companyVault = ICompanyVault(_dns.getRoute(COMPANY_VAULT));
        _eventEmitter = IEventEmitter(_dns.getRoute(EVENT_EMITTER));
        _identityContract = IIdentityContract(_dns.getRoute(IDENTITY_CONTRACT));
        _investorStore = IInvestorStore(_dns.getRoute(INVESTOR_STORE));
    }

    //Currently defaulting oracle to owner address
    // We would need to build a more robust oracle system for QuidRaise
    function createCompany(
        string calldata CompanyUrl,
        string calldata companyName,
        address companyTokenContractAddress,
        address companyOwner,
        address companyCreatedBy
    ) external override onlyOwner {
        bool isInvestor = _investorStore.isInvestor(companyOwner);
        require(!_companyStore.isCompanyOwner(companyOwner), "Company owner already owns a business");

        if (isInvestor) {
            require(_identityContract.isInvestorAddressWhitelisted(companyOwner), "Company owner address blacklisted as investor");
        }
        Company memory company = Company(0, companyName, CompanyUrl, companyTokenContractAddress, companyOwner);
        uint256 companyId = _companyStore.createCompany(company);

        _identityContract.whitelistCompanyAddress(companyOwner);
        _identityContract.whitelistCompany(companyId);

        _eventEmitter.emitCompanyCreatedEvent(CompanyCreatedRequest(CompanyUrl));
    }

    function createRound(
        address companyOwner,
        string calldata roundDocumentUrl,
        uint256 startTimestamp,
        uint256 duration,
        uint256 lockupPeriodForShare,
        uint256 pricePerShare,
        uint256 tokensSuppliedForRound,
        bool runTillFullySubscribed,
        address[] memory paymentCurrencies
    ) external override c2cCallValid {
        require(
            startTimestamp > 0 && duration > 0 && pricePerShare > 0 && tokensSuppliedForRound > 0 && paymentCurrencies.length > 0,
            "Contract input data is invalid"
        );

        require(!_companyStore.isCompanyOwner(companyOwner), "Could not find a company owned by this user");
        Company memory company = _companyStore.getCompanyByOwner(companyOwner);

        validateRoundCreationInput(company.Id, paymentCurrencies);

        depsitCompanyTokensToVault(company, tokensSuppliedForRound);

        Round memory round = Round(
            0,
            company.Id,
            lockupPeriodForShare,
            pricePerShare,
            tokensSuppliedForRound,
            0,
            0,
            0,
            startTimestamp,
            duration,
            roundDocumentUrl,
            runTillFullySubscribed,
            false
        );

        uint256 roundId = _roundStore.createRound(round);

        _roundStore.createRoundPaymentOptions(roundId, paymentCurrencies);

        emitRoundCreatedEvents(roundId, paymentCurrencies, company, round);
    }

    function createProposal(
        uint256 amountRequested,
        uint256 votingStartTimestamp,
        address companyOwner
    ) external override c2cCallValid {
        require(!_companyStore.isCompanyOwner(companyOwner), "Could not find a company owned by this user");
        Company memory company = _companyStore.getCompanyByOwner(companyOwner);

        validateProposalCreationAction(company.Id);

        Proposal memory proposal = Proposal(0, company.Id, amountRequested, getVoteDuration(), votingStartTimestamp, 0, 0, 0, 0, false);
        uint256 propoalId = _proposalStore.createProposal(proposal);

        _eventEmitter.emitProposalCreatedEvent(
            ProposalCreatedRequest(
                propoalId,
                company.Id,
                companyOwner,
                company.CompanyTokenContractAddress,
                proposal.AmountRequested,
                proposal.VoteStartTimeStamp,
                proposal.VoteSessionDuration
            )
        );
    }

    function getProposalResult(uint256 proposalId) external view override returns (ProposalResponse memory) {
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

    function getRound(uint256 roundId) external view override returns (RoundResponse memory) {
        Round memory round = _roundStore.getRound(roundId);
        require(!round.IsDeleted, "Round has been deleted");
        RoundResponse memory response = RoundResponse(
            round.Id,
            round.CompanyId,
            round.LockUpPeriodForShare,
            round.PricePerShare,
            round.TotalTokensUpForSale,
            round.TotalInvestors,
            round.TotalRaised,
            round.TotalTokensSold,
            round.RoundStartTimeStamp,
            round.DurationInSeconds,
            round.DocumentUrl,
            round.RunTillFullySubscribed,
            isRoundOpen(round)
        );

        return response;
    }

    function releaseProposalBudget(uint256 proposalId, address companyOwnerAddress) external override c2cCallValid {}

    function deleteProposal(uint256 proposalId, address companyOwnerAddress) external override c2cCallValid {}

    function deleteRound(uint256 proposalId, address companyOwnerAddress) external override c2cCallValid {}

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
        Round[] memory rounds = _roundStore.getCompanyRounds(companyId);
        Round memory lastRound = rounds[rounds.length - 1];
        return isRoundOpen(lastRound);
    }

    function doesCompanyHaveOpenProposal(uint256 companyId) internal view returns (bool) {
        Proposal[] memory proposals = _proposalStore.getCompanyProposals(companyId);
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

    function validateRoundCreationInput(uint256 companyId, address[] memory paymentCurrencies) internal view {
        bool hasOpenRound = doesCompanyHaveOpenRound(companyId);
        require(!hasOpenRound, "Company has an open round");

        bool hasOpenProposal = doesCompanyHaveOpenProposal(companyId);
        require(!hasOpenProposal, "Company has an open proposal");

        bool isPaymentOptionsValid = validateRoundPaymentOptions(paymentCurrencies);
        require(isPaymentOptionsValid, "One or more payment options are not supported");
    }

    function validateProposalCreationAction(uint256 companyId) internal view {
        bool hasOpenRound = doesCompanyHaveOpenRound(companyId);
        require(!hasOpenRound, "Company has an open round");

        bool hasOpenProposal = doesCompanyHaveOpenProposal(companyId);
        require(!hasOpenProposal, "Company has an open proposal");
    }

    function getVoteDuration() internal view returns (uint256) {
        //TODO: This should be read from our config contract
        return 0;
    }

    /***
        Checks the payment currencies against a list of supported payment currencies in the company vault contract
    */
    function validateRoundPaymentOptions(address[] memory paymentCurrencies) internal view returns (bool) {
        //TODO: Check CompanyVault for list of supported payment options
        return true;
    }

    function emitRoundCreatedEvents(
        uint256 roundId,
        address[] memory paymentCurrencies,
        Company memory company,
        Round memory round
    ) internal {
        _eventEmitter.emitCompanyDepositEvent(
            CompanyDepositRequest(company.Id, roundId, company.OwnerAddress, company.CompanyTokenContractAddress, round.TotalTokensUpForSale)
        );

        _eventEmitter.emitRoundCreatedEvent(
            RoundCreatedRequest(
                roundId,
                company.Id,
                company.OwnerAddress,
                round.LockUpPeriodForShare,
                round.PricePerShare,
                round.TotalTokensUpForSale,
                round.RoundStartTimeStamp,
                round.DurationInSeconds,
                round.RunTillFullySubscribed,
                paymentCurrencies
            )
        );
    }

    function depsitCompanyTokensToVault(Company memory company, uint256 expectedTokenDeposit) internal {
        IERC20 token = IERC20(company.CompanyTokenContractAddress);
        uint256 amountToDeposit = token.allowance(company.OwnerAddress, address(this));
        require(expectedTokenDeposit == amountToDeposit, "Approved deposit does not tally with round allocation");
        require(amountToDeposit > 0, "Cannot deposit 0 tokens");

        token.safeTransferFrom(company.OwnerAddress, address(this), amountToDeposit);

        token.approve(address(_companyVault), amountToDeposit);
        _companyVault.depositCompanyTokens(company.Id);
    }
}
