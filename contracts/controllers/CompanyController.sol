// SPDX-License-Identifier: MIT
import "../models/Schema.sol";
import "../models/EventModels.sol";

import "../infrastructure/BaseContract.sol";
import "../libraries/SafeERC20.sol";
import "../libraries/ReentrancyGuard.sol";

import "./interface/ICompanyController.sol";
import "../store/interface/ICompanyStore.sol";
import "../store/interface/IProposalStore.sol";
import "../store/interface/IRoundStore.sol";
import "../vault/interface/ICompanyVault.sol";
import "../store/interface/ICompanyVaultStore.sol";

import "../events/interface/IEventEmitter.sol";
import "../infrastructure/interface/IIdentityContract.sol";
import "../store/interface/IInvestorStore.sol";
import "../interfaces/IERC20.sol";
import "../interfaces/IConfig.sol";
import "hardhat/console.sol";

pragma experimental ABIEncoderV2;
pragma solidity 0.7.0;

contract CompanyController is BaseContract, ReentrancyGuard, ICompanyController {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    constructor(address dnsContract) BaseContract(dnsContract) {}

    //Currently defaulting oracle to owner address
    // We would need to build a more robust oracle system for QuidRaise
    /**
        company owner - wallet address of the person who owns a company
        company created by - wallet address of who initiated the company creation transaction
     */

    /* event CompanyCreated(
        uint256 indexed companyId,
        address indexed companyOwner,
        address indexed performedBy,
        string companyName,
        string companyDocumentUrl,
        address companyTokenContract
    ); */
    function createCompany(
        string calldata CompanyUrl,
        string calldata companyName,
        address companyTokenContractAddress,
        address companyOwner,
        address companyCreatedBy
    ) external override nonReentrant onlyOwner {
        // require(0 != 0, "damn!");

        ICompanyStore _companyStore = ICompanyStore(_dns.getRoute(COMPANY_STORE));
        IInvestorStore _investorStore = IInvestorStore(_dns.getRoute(INVESTOR_STORE));
        IIdentityContract _identityContract = IIdentityContract(_dns.getRoute(IDENTITY_CONTRACT));
        IEventEmitter _eventEmitter = IEventEmitter(_dns.getRoute(EVENT_EMITTER));

        bool isInvestor = _investorStore.isInvestor(companyOwner);
        require(!_companyStore.isCompanyOwner(companyOwner), "Company owner already owns a business");

        if (isInvestor) {
            require(_identityContract.isInvestorAddressWhitelisted(companyOwner),
            "Company owner address blacklisted as investor");
        }
        Company memory company = Company(0, companyName, CompanyUrl, companyTokenContractAddress, companyOwner);
        uint256 companyId = _companyStore.createCompany(company);

        _identityContract.whitelistCompanyAddress(companyOwner);
        _identityContract.whitelistCompany(companyId);



       /*  emit CompanyCreated(
            companyId,
            company.OwnerAddress,
            companyCreatedBy,
            company.CompanyName,
            company.CompanyUrl,
            company.CompanyTokenContractAddress
        ); */
        _eventEmitter.emitCompanyCreatedEvent(
            CompanyCreatedRequest(
                companyId,
                company.OwnerAddress,
                companyCreatedBy,
                company.CompanyName,
                company.CompanyUrl,
                company.CompanyTokenContractAddress
            )
        );
    }

/**
        address companyOwner -
        string calldata roundDocumentUrl - url
        uint256 startTimestamp, current timestamp
        uint256 duration, how many secs till round closes
        uint256 lockupPeriodForShare, - sec - you can't trade your shares during the lockup duration
        uint256 tokensSuppliedForRound, -  how much tokens they are giving out? - 20000
        bool runTillFullySubscribed, - true
        address[] memory paymentCurrencies, - address of stable coins [usdt, dai]
        uint256[] memory pricePerShare -[20, 50]
 */
    function createRound(
        address companyOwner,
        string calldata roundDocumentUrl,
        uint256 startTimestamp,
        uint256 duration,
        uint256 lockupPeriodForShare,
        uint256 tokensSuppliedForRound,
        bool runTillFullySubscribed,
        address[] memory paymentCurrencies,
        uint256[] memory pricePerShare
    ) external override nonReentrant c2cCallValid {
        ICompanyStore _companyStore = ICompanyStore(_dns.getRoute(COMPANY_STORE));
        require(
            (IConfig(_dns.getRoute(CONFIG))).getNumericConfig(MAX_ROUND_PAYMENT_OPTION) >= paymentCurrencies.length,
            "Exceeded number of payment options"
        );

        for (uint256 i = 0; i < pricePerShare.length; i++) {
            require(pricePerShare[i] > 0, "Price per share cannot be zero");
        }

        require(
            startTimestamp > 0 &&
                duration > 0 &&
                tokensSuppliedForRound > 0 &&
                paymentCurrencies.length > 0 &&
                paymentCurrencies.length == pricePerShare.length,
            "Contract input data is invalid"
        );

        require(_companyStore.isCompanyOwner(companyOwner), "Could not find a company owned by this user");
        Company memory company = _companyStore.getCompanyByOwner(companyOwner);

        ensureCompanyIsWhitelisted(company.Id, companyOwner);

        validateRoundCreationInput(company.Id, paymentCurrencies);

        depsitCompanyTokensToVault(company, tokensSuppliedForRound);

        Round memory round = Round(
            0,
            company.Id,
            lockupPeriodForShare,
            pricePerShare,
            paymentCurrencies,
            tokensSuppliedForRound,
            0,
            new uint256[](paymentCurrencies.length),
            0,
            startTimestamp,
            duration,
            roundDocumentUrl,
            runTillFullySubscribed,
            false
        );

        uint256 roundId = (IRoundStore(_dns.getRoute(ROUND_STORE))).createRound(round);

        (IRoundStore(_dns.getRoute(ROUND_STORE))).createRoundPaymentOptions(roundId, paymentCurrencies);

        emitRoundCreatedEvents(roundId, paymentCurrencies, company, round);
    }


/**
        uint256[] calldata amountRequested,
        address[] calldata paymentCurrencies,
        uint256 votingStartTimestamp,
        address companyOwner
 */
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

        require(!_companyStore.isCompanyOwner(companyOwner), "Could not find a company owned by this user");
        Company memory company = _companyStore.getCompanyByOwner(companyOwner);

        ensureCompanyIsWhitelisted(company.Id, companyOwner);

        // check they dont have a prev. open round
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

    // checks the status of a proposal created by company
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

    // checks if proposal status is approved
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

    // returns details about the round
    function getRound(uint256 roundId) external view override returns (RoundResponse memory) {
        IRoundStore _roundStore = IRoundStore(_dns.getRoute(ROUND_STORE));

        Round memory round = _roundStore.getRound(roundId);
        require(!round.IsDeleted, "Round has been deleted");
        RoundResponse memory response = RoundResponse(
            round.Id,
            round.CompanyId,
            round.LockUpPeriodForShare,
            round.PricePerShare,
            round.PaymentCurrencies,
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

    //
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
        proposal.HasWithdrawn = true;
        _proposalStore.updateProposal(proposal);

        for (uint256 i = 0; i < proposal.PaymentCurrencies.length; i++) {
            address currency = proposal.PaymentCurrencies[i];
            uint256 balance = _companyVaultStore.getCompanyVaultBalance(proposal.CompanyId, currency);
            require(balance >= proposal.AmountRequested[i], "Insufficient Vault Balance");
            _companyVault.withdrawPaymentTokensFromVault(proposal.CompanyId, currency, proposal.AmountRequested[i]);
        }
    }

    // platform always has a cut from all proposals
    function calculatePlatformCommision(uint256 amount) internal view returns (uint256) {
        IConfig _config = IConfig(_dns.getRoute(CONFIG));

        uint256 factor = _config.getNumericConfig(PLATFORM_COMMISION);
        uint256 precision = _config.getNumericConfig(PRECISION);

        return amount.mul(factor).div(precision);
    }

    // check company is whitelisted
    function ensureCompanyIsWhitelisted(uint256 companyId, address companyOwner) internal view {
        IIdentityContract _identityContract = IIdentityContract(_dns.getRoute(IDENTITY_CONTRACT));

        require(_identityContract.isCompanyAddressWhitelisted(companyOwner), "Address blacklisted");
        require(_identityContract.isCompanyWhitelisted(companyId), "Company blacklisted");
    }

    //
    function deleteProposal(uint256 proposalId, address companyOwnerAddress) external override c2cCallValid {
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

    function deleteRound(uint256 roundId, address companyOwnerAddress) external override c2cCallValid {
        ICompanyStore _companyStore = ICompanyStore(_dns.getRoute(COMPANY_STORE));
        IRoundStore _roundStore = IRoundStore(_dns.getRoute(ROUND_STORE));

        Round memory round = _roundStore.getRound(roundId);
        Company memory company = _companyStore.getCompanyById(round.CompanyId);
        require(company.OwnerAddress == companyOwnerAddress, "Unauthorized access to round");
        require(!round.IsDeleted, "Round has been deleted");
        require(round.TotalTokensSold == 0, "Round can no longer be deleted");

        for (uint256 i = 0; i < round.TotalRaised.length; i++) {
            require(round.TotalRaised[i] == 0, "Round can no longer be deleted");
        }

        round.IsDeleted = true;

        _roundStore.updateRound(roundId, round);
        //TODO: Emit Round Deleted Event;
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
        // console.log(rounds[0].Id);
        if(rounds.length == 0){
            return false;
        }else{
        Round memory lastRound = rounds[rounds.length - 1];
        return isRoundOpen(lastRound);
        }
    }

    function doesCompanyHaveOpenProposal(uint256 companyId) internal view returns (bool) {
        IProposalStore _proposalStore = IProposalStore(_dns.getRoute(PROPOSAL_STORE));

        Proposal[] memory proposals = _proposalStore.getCompanyProposals(companyId);
        if(proposals.length == 0){
            return false;
        }
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
        IConfig _config = IConfig(_dns.getRoute(CONFIG));
        return _config.getNumericConfig(CONFIG);
    }

    /***
        Checks the payment currencies against a list of supported payment currencies in the company vault contract
    */
    function validateRoundPaymentOptions(address[] memory paymentCurrencies) internal view returns (bool) {
        ICompanyVaultStore _companyVaultStore = ICompanyVaultStore(_dns.getRoute(COMPANY_VAULT_STORE));

        for (uint256 i = 0; i < paymentCurrencies.length; i++) {
            address currency = paymentCurrencies[i];
            bool isSupported = _companyVaultStore.isSupportedPaymentOption(currency);
            if (!isSupported) {
                return false;
            }
        }

        return true;
    }

    function emitRoundCreatedEvents(
        uint256 roundId,
        address[] memory paymentCurrencies,
        Company memory company,
        Round memory round
    ) internal {
        IEventEmitter _eventEmitter = IEventEmitter(_dns.getRoute(EVENT_EMITTER));

        _eventEmitter.emitCompanyDepositEvent(
            CompanyDepositRequest(company.Id, roundId, company.OwnerAddress, company.CompanyTokenContractAddress, round.TotalTokensUpForSale)
        );

        _eventEmitter.emitRoundCreatedEvent(
            RoundCreatedRequest(
                roundId,
                company.Id,
                company.OwnerAddress,
                round.LockUpPeriodForShare,
                round.TotalTokensUpForSale,
                round.RoundStartTimeStamp,
                round.DurationInSeconds,
                round.RunTillFullySubscribed,
                paymentCurrencies,
                round.PricePerShare
            )
        );
    }

    function depsitCompanyTokensToVault(Company memory company, uint256 expectedTokenDeposit) internal {
        ICompanyVault _companyVault = ICompanyVault(_dns.getRoute(COMPANY_VAULT));
        IERC20 token = IERC20(company.CompanyTokenContractAddress);
        uint256 amountToDeposit = token.allowance(company.OwnerAddress, address(this));
        require(expectedTokenDeposit == amountToDeposit, "Approved deposit does not tally with round allocation");
        require(amountToDeposit > 0, "Cannot deposit 0 tokens");

        token.safeTransferFrom(company.OwnerAddress, address(this), amountToDeposit);
        token.approve(address(_companyVault), amountToDeposit);

        console.log(company.Id);
        _companyVault.depositCompanyTokens(company.Id);
    }
}
