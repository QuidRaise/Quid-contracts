// SPDX-License-Identifier: MIT

import "../infrastructure/BaseContract.sol";
import "../libraries/ReentrancyGuard.sol";

import "../controllers/interface/ICompanyController.sol";
import "../controllers/interface/IInvestorController.sol";


pragma experimental ABIEncoderV2;
pragma solidity 0.7.0;

contract InvestorProxy is BaseContract, ReentrancyGuard {
   

    constructor(address dnsContract) BaseContract(dnsContract) {
       
    }



    function investInRound(uint256 roundId, address paymentTokenAddress) external nonReentrant 
    {
        IInvestorController controller  = IInvestorController(_dns.getRoute("INVESTOR_CONTROLLER"));
        (bool success, bytes memory data) = address(controller).delegatecall(
            abi.encodeWithSignature("investInRound(uint256,address,address)",roundId,paymentTokenAddress,_msgSender())
        );
    }

    function voteForProposal(uint256 proposalId, bool isApproved) external nonReentrant 
    {
        IInvestorController controller  = IInvestorController(_dns.getRoute("INVESTOR_CONTROLLER"));
        (bool success, bytes memory data) = address(controller).delegatecall(
            abi.encodeWithSignature("voteForProposal(uint256,address,bool)",proposalId,_msgSender(),isApproved)
        );
    }

    function viewProposalVote(uint256 proposalId) external view returns (ProposalVote memory)
    {
        IInvestorController controller  = IInvestorController(_dns.getRoute("INVESTOR_CONTROLLER"));
        controller.viewProposalVote(proposalId,_msgSender());

    }

    function getRoundInvestment(uint256 roundId) external view  returns (RoundInvestment memory)
    {
        IInvestorController controller  = IInvestorController(_dns.getRoute("INVESTOR_CONTROLLER"));
        controller.getRoundInvestment(roundId,_msgSender());

    }


    function getRound(uint256 roundId) external view returns (RoundResponse memory)
    {
        IInvestorController controller  = IInvestorController(_dns.getRoute("INVESTOR_CONTROLLER"));
        controller.getRound(roundId);
    }

}
