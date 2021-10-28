// SPDX-License-Identifier: MIT

import "./models/Schema.sol";
import "./models/EventModels.sol";

import "./BaseContract.sol";
import "./libraries/SafeERC20.sol";
import "./libraries/ReentrancyGuard.sol";
import "./interfaces/IInvestorController.sol";
import "./interfaces/ICompanyStore.sol";
import "./interfaces/IProposalStore.sol";
import "./interfaces/IRoundStore.sol";
import "./interfaces/ICompanyVault.sol";
import "./interfaces/ICompanyVaultStore.sol";

import "./interfaces/IEventEmitter.sol";
import "./interfaces/IIdentityContract.sol";
import "./interfaces/IInvestorStore.sol";
import "./interfaces/IERC20.sol";

pragma experimental ABIEncoderV2;
pragma solidity 0.7.0;

contract InvestorController is  BaseContract, IInvestorController{

    using SafeERC20 for IERC20;
    using SafeMath for uint256;


    ICompanyStore private _companyStore;
    IProposalStore private _proposalStore;
    IRoundStore private _roundStore;
    ICompanyVault private _companyVault;
    ICompanyVaultStore private _companyVaultStore;

    IEventEmitter private _eventEmitter;
    IIdentityContract private _identityContract;
    IInvestorStore private _investorStore;



 constructor(address dnsContract) BaseContract(dnsContract) {

        _companyStore = ICompanyStore(_dns.getRoute(COMPANY_STORE));
        _proposalStore = IProposalStore(_dns.getRoute(PROPOSAL_STORE));
        _roundStore = IRoundStore(_dns.getRoute(ROUND_STORE));
        _companyVault = ICompanyVault(_dns.getRoute(COMPANY_VAULT));
        _companyVaultStore = ICompanyVaultStore(_dns.getRoute(COMPANY_VAULT_STORE));

        _eventEmitter = IEventEmitter(_dns.getRoute(EVENT_EMITTER));
        _identityContract = IIdentityContract(_dns.getRoute(IDENTITY_CONTRACT));
        _investorStore = IInvestorStore(_dns.getRoute(INVESTOR_STORE));
    }



    function investInRound(uint256 roundId, address paymentTokenAddress, address investor) external override nonReentrant c2cCallValid
    {
        Round memory round =  _roundStore.getRound(roundId);
        ensureWhitelist(round.CompanyId,investor);
        require(isSupportedPaymentOption(roundId,paymentTokenAddress), "Payment token not supported");
        IERC20 token = IERC20(paymentTokenAddress);
        uint256 investmentAmount = token.allowance(investor, address(this));
        require(investmentAmount>0,"Cannot deposit 0 tokens");

        token.safeTransferFrom(investor,address(this),investmentAmount);

        token.approve(address(_companyVault),investmentAmount);
        _companyVault.depositPaymentTokensToVault(round.CompanyId, paymentTokenAddress);

        if(!_investorStore.isInvestor(investor))
        {
            _investorStore.createInvestor(Investor(investor,0,0));
        }

        _investorStore.updateAmountSpentByInvestor(investor,paymentTokenAddress,investmentAmount);
        _investorStore.updateRoundsInvestedIn(investor, round.Id);
        _investorStore.updateCompaniesInvestedIn(investor, round.CompanyId);

        mintShareCertificate(round.CompanyId,round.Id, paymentTokenAddress,investmentAmount);

        _eventEmitter.emitInvestmentDepositEvent(InvestmentDepositRequest(round.CompanyId, round.Id, investor,paymentTokenAddress, investmentAmount));
    }

    function mintShareCertificate(uint256 companyId, uint256 roundId, address paymentTokenAddress, uint256 investmentAmount) internal
    {

    }

    function ensureWhitelist(uint256 companyId, address investor) internal view
    {
        require(_identityContract.isInvestorAddressWhitelisted(investor),
                    "Address blacklisted");
        require(_identityContract.isCompanyWhitelisted(companyId),
                "Company blacklisted");
    }

    function isSupportedPaymentOption(uint roundId,address tokenAddress) internal view returns (bool)
    {
        address[] memory paymentAddresses = _roundStore.getRoundPaymentOptions(roundId);
        for (uint256 i = 0; i < paymentAddresses.length; i++) {
            
            if(tokenAddress==paymentAddresses[i])
            {
                return true;
            }
        }
        return false;
    }

    function voteForProposal(uint256 proposalId, address investor) external override nonReentrant c2cCallValid
    {
        Proposal memory proposal =  _proposalStore.getProposal(proposalId);
        //TODO: Verify that investor can vote for this proposal and that he has shares in this company
        require()
        ensureWhitelist(proposal.CompanyId,investor);

    }

    function viewProposalVote(uint256 proposalId, address investor) external view override 
    {
        
    }

    function getRoundInvestedIn(uint256 roundId, address investor) external view override 
    {
        
    }
    function getRound(uint256 roundId) external view override 
    {
        
    }
}
