// SPDX-License-Identifier: MIT
import "../../models/Schema.sol";

pragma experimental ABIEncoderV2;
pragma solidity 0.7.0;

interface IInvestorController {
    function investInRound(
        uint256 roundId,
        address paymentTokenAddress,
        address investor
    ) external;

    function voteForProposal(
        uint256 proposalId,
        address investor,
        bool isApproved
    ) external;

    function viewProposalVote(uint256 proposalId, address investor) external view returns (ProposalVote memory);

    function getRoundInvestment(uint256 roundId, address investor) external view returns (RoundInvestment memory);

    function getRound(uint256 roundId) external view returns (RoundResponse memory);
}
