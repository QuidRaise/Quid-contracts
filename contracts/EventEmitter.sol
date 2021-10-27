// SPDX-License-Identifier: MIT
import "./BaseContract.sol";
import "./DataGrant.sol";
import "./interfaces/IEventEmitter.sol";

import "./models/Events.sol";
import "./models/EventModels.sol";

pragma experimental ABIEncoderV2;

pragma solidity 0.7.0;

/**
 * The system actors, Investors and Companies do not interact with this contract directly, but rather via the
 * Company controller or Investor controller
 */
contract EventEmitter is BaseContract, DataGrant, Events, IEventEmitter {
    constructor(address dnsContract) BaseContract(dnsContract) {}

    function emitCompanyDepositEvent(CompanyDepositRequest memory model) external override c2cCallValid {
        emit CompanyDeposit(model.CompanyId, model.RoundId, model.Sender, model.TokenContractAddress, model.Amount);
    }

    function emitCompanyWithdrawalEvent(CompanyWithdrawalRequest memory model) external override c2cCallValid {
        emit CompanyWithdrawal(model.CompanyId, model.RoundId, model.Receiver, model.TokenContractAddress, model.Amount);
    }

    function emitInvestmentDepositEvent(InvestmentDepositRequest memory model) external override c2cCallValid {
        emit InvestmentDeposit(model.CompanyId, model.RoundId, model.Sender, model.TokenContractAddress, model.Amount);
    }

    function emitInvestmentWithdrawalEvent(InvestmentWithdrawalRequest memory model) external override c2cCallValid {
        emit InvestmentWithdrawal(model.CompanyId, model.RoundId, model.Receiver, model.TokenContractAddress, model.Amount);
    }

    function emitWhitelistCompanyOwnerEvent(WhitelistCompanyOwnerRequest memory model) external override c2cCallValid {
        emit WhitelistCompanyOwner(model.CompanyOwner, model.PerformedBy);
    }

    function emitBlacklistCompanyOwnerEvent(BlacklistCompanyOwnerRequest memory model) external override c2cCallValid {
        emit BlacklistCompanyOwner(model.CompanyOwner, model.PerformedBy);
    }

    function emitWhitelistCompanyEvent(WhitelistCompanyRequest memory model) external override c2cCallValid {
        emit WhitelistCompany(model.CompanyId, model.PerformedBy);
    }

    function emitBlacklistCompanyEvent(BlacklistCompanyRequest memory model) external override c2cCallValid {
        emit BlacklistCompany(model.CompanyId, model.PerformedBy);
    }

    function emitWhitelistInvestorEvent(WhitelistInvestorRequest memory model) external override c2cCallValid {
        emit WhitelistInvestor(model.Investor, model.PerformedBy);
    }

    function emitBlacklistInvestorEvent(BlacklistInvestorRequest memory model) external override c2cCallValid {
        emit BlacklistInvestor(model.Investor, model.PerformedBy);
    }

    function emitC2CAccessGrantEvent(C2CAccessGrantRequest memory model) external override c2cCallValid {
        emit C2CAccessGrant(model.SourceContract, model.DestinationContract, model.PerformedBy);
    }

    function emitC2CAccessRevokedEvent(C2CAccessRevokedRequest memory model) external override c2cCallValid {
        emit C2CAccessRevoked(model.SourceContract, model.DestinationContract, model.PerformedBy);
    }

    function emitCompanyCreatedEvent(CompanyCreatedRequest memory model) external override c2cCallValid {
        emit CompanyCreated(model.CompanyId, model.CompanyOwner, model.PerformedBy, model.CompanyName, model.CompanyDocumentUrl, model.CompanyTokenContract);
    }

    function emitProposalCreatedEvent(ProposalCreatedRequest memory model) external override c2cCallValid {
        emit ProposalCreated(
            model.ProposalId,
            model.CompanyId,
            model.CompanyOwner,
            model.CompanyTokenContract,
            model.ProposalAmount,
            model.ProposalStartTimestamp,
            model.ProposalDuration
        );
    }

    function emitRoundCreatedEvent(RoundCreatedRequest memory model) external override c2cCallValid {
        emit RoundCreated(
            model.RoundId,
            model.CompanyId,
            model.CompanyOwner,
            model.LockupPeriodForShares,
            model.PricePerShare,
            model.TokensSuppliedForRound,
            model.StartTimestamp,
            model.RoundDuration,
            model.RunTillFullySubscribed,
            model.paymentCurrencies
        );
    }

    function emitShareCertificateCreatedEvent(ShareCertificateCreatedRequest memory model) external override c2cCallValid {
        emit ShareCertificateCreated(model.RegistryId, model.TokenId, model.RoundId, model.UnderlyingFundAmount, model.nftTokenContractAddress);
    }
}
