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
contract  EventEmitter is BaseContract, DataGrant, Events, IEventEmitter {
    constructor(address dnsContract) BaseContract(dnsContract) {
     
    }

     function emitCompanyDepositEvent(CompanyDepositRequest memory model) external override c2cCallValid 
     {

     }

     function emitCompanyWithdrawalEvent(CompanyWithdrawalRequest memory model) external override c2cCallValid 
     {

     }

     function emitInvestmentDepositEvent(InvestmentDepositRequest memory model) external override c2cCallValid 
     {

     }

     function emitInvestmentWithdrawalEvent(InvestmentWithdrawalRequest memory model) external override c2cCallValid 
     { 

     }


     function emitWhitelistCompanyOwnerEvent(WhitelistCompanyOwnerRequest memory model) external override c2cCallValid 
     { 

     }

     function emitBlacklistCompanyOwnerEvent(BlacklistCompanyOwnerRequest memory model) external override c2cCallValid 
     { 

     }

     function emitWhitelistCompanyEvent(WhitelistCompanyRequest memory model) external override c2cCallValid 
     { 

     }

     function emitBlacklistCompanyEvent(BlacklistCompanyRequest memory model) external override c2cCallValid 
     { 

     }

     function emitWhitelistInvestorEvent(WhitelistInvestorRequest memory model) external override c2cCallValid 
     { 

     }

     function emitBlacklistInvestorEvent(BlacklistInvestorRequest memory model) external override c2cCallValid 
     { 

     }


     function emitC2CAccessGrantEvent(C2CAccessGrantRequest memory model) external override c2cCallValid 
     { 
         emit C2CAccessGrant(model.SourceContract, model.DestinationContract, model.PerformedBy);

     }

     function emitC2CAccessRevokedEvent(C2CAccessRevokedRequest memory model) external override c2cCallValid 
     { 
         emit C2CAccessRevoked(model.SourceContract, model.DestinationContract, model.PerformedBy);

     }


     function emitCompanyCreatedEvent(CompanyCreatedRequest memory model) external override c2cCallValid 
     { 

     }

     function emitProposalCreatedEvent(ProposalCreatedRequest memory model) external override c2cCallValid 
     { 

     }


     function emitRoundCreatedEvent(RoundCreatedRequest memory model) external override c2cCallValid 
     { 

     }

     function emitShareCertificateCreatedEvent(ShareCertificateCreatedRequest memory model) external override c2cCallValid 
     {

     }


}
