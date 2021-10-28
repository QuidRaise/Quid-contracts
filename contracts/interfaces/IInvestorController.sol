// SPDX-License-Identifier: MIT
import "../models/Schema.sol";

pragma experimental ABIEncoderV2;
pragma solidity 0.7.0;

interface IInvestorController {
    function investInRound(uint256 roundId, address paymentTokenAddress, address investor) external;
    function voteForProposal(uint256 proposalId, address investor) external;

    function viewProposalVote(uint256 proposalId, address investor) external;

    function getRoundInvestedIn(uint256 roundId, address investor) external;

    function getRound(uint256 roundId) external;
}
