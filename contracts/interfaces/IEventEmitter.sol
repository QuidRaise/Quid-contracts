// SPDX-License-Identifier: MIT
import "../models/EventModels.sol";

pragma experimental ABIEncoderV2;
pragma solidity 0.7.0;

interface IEventEmitter {


     function emitCompanyDepositEvent(CompanyDepositRequest memory model) external;
     function emitCompanyWithdrawalEvent(CompanyWithdrawalRequest memory model) external;

     function emitInvestmentDepositEvent(InvestmentDepositRequest memory model) external;
     function emitInvestmentWithdrawalEvent(InvestmentWithdrawalRequest memory model) external;


     function emitWhitelistCompanyOwnerEvent(WhitelistCompanyOwnerRequest memory model) external;
     function emitBlacklistCompanyOwnerEvent(BlacklistCompanyOwnerRequest memory model) external;

     function emitWhitelistCompanyEvent(WhitelistCompanyRequest memory model) external;
     function emitBlacklistCompanyEvent(BlacklistCompanyRequest memory model) external;

     function emitWhitelistInvestorEvent(WhitelistInvestorRequest memory model) external;
     function emitBlacklistInvestorEvent(BlacklistInvestorRequest memory model) external;

     function emitC2CAccessGrantEvent(C2CAccessGrantRequest memory model) external;
     function emitC2CAccessRevokedEvent(C2CAccessRevokedRequest memory model) external;

     function emitCompanyCreatedEvent(CompanyCreatedRequest memory model) external;
     function emitProposalCreatedEvent(ProposalCreatedRequest memory model) external;


     function emitRoundCreatedEvent(RoundCreatedRequest memory model) external;
     function emitShareCertificateCreatedEvent(ShareCertificateCreatedRequest memory model) external;




 
}
