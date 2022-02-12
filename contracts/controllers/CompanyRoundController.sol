// SPDX-License-Identifier: MIT
import "../models/Schema.sol";
import "../models/EventModels.sol";

import "./SharedController.sol";
import "../libraries/SafeERC20.sol";
import "../libraries/ReentrancyGuard.sol";
import "../libraries/Address.sol";

import "./interface/ICompanyRoundController.sol";
import "../store/interface/ICompanyStore.sol";
import "../store/interface/IProposalStore.sol";
import "../store/interface/IRoundStore.sol";
import "../vault/interface/ICompanyVault.sol";
import "../vault/InvestmentTokenVault.sol";

import "../store/interface/ICompanyVaultStore.sol";

import "../events/interface/IEventEmitter.sol";
import "../infrastructure/interface/IIdentityContract.sol";
import "../interfaces/IERC20.sol";
import "../interfaces/IConfig.sol";

pragma experimental ABIEncoderV2;
pragma solidity 0.7.0;

contract CompanyRoundController is SharedController, ReentrancyGuard, ICompanyRoundController {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    using Address for address;

    constructor(address dnsContract) SharedController(dnsContract) {
       
    }

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

        require((IConfig(_dns.getRoute(CONFIG))).getNumericConfig(MAX_ROUND_PAYMENT_OPTION) >= paymentCurrencies.length, "Exceeded number of payment options");

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
            address(0x0),
            runTillFullySubscribed,
            false
        );

        roundCreationSecondStep(round,company);
    }

    function roundCreationSecondStep(Round memory round, Company memory company) internal
    {
        round.Id = (IRoundStore(_dns.getRoute(ROUND_STORE))).createRound(round);

        ICompanyVault  _companyVault = ICompanyVault(_dns.getRoute(COMPANY_VAULT));
        round = _companyVault.createInvestmentTokenVaultForRound(company.CompanyTokenContractAddress, round);

        (IRoundStore(_dns.getRoute(ROUND_STORE))).updateRound(round);   


        emitRoundCreatedEvents(round.Id, round.PaymentCurrencies, company, round);
    }

   
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

    function deleteRound(uint256 roundId, address companyOwnerAddress) external override c2cCallValid nonReentrant {
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

        _roundStore.updateRound(round);
        //TODO: Emit Round Deleted Event;
    }

    
    function validateRoundCreationInput(uint256 companyId, address[] memory paymentCurrencies) internal view {
        bool hasOpenRound = doesCompanyHaveOpenRound(companyId);
        require(!hasOpenRound, "Company has an open round");

        bool hasOpenProposal = doesCompanyHaveOpenProposal(companyId);
        require(!hasOpenProposal, "Company has an open proposal");

        bool isPaymentOptionsValid = validateRoundPaymentOptions(paymentCurrencies);
        require(isPaymentOptionsValid, "One or more payment options are not supported");
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
        ICompanyVault  _companyVault = ICompanyVault(_dns.getRoute(COMPANY_VAULT));
        IERC20 token = IERC20(company.CompanyTokenContractAddress);
        uint256 amountToDeposit = token.allowance(company.OwnerAddress, address(this));
        require(expectedTokenDeposit >= amountToDeposit, "Approved deposit does not tally with round allocation");
        require(amountToDeposit > 0, "Cannot deposit 0 tokens");

        token.safeTransferFrom(company.OwnerAddress, address(this), amountToDeposit);

        token.approve(address(_companyVault), amountToDeposit);
        _companyVault.depositCompanyTokens(company.Id);
    }
}
