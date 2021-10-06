// SPDX-License-Identifier: MIT
import '../models/Schema.sol'

pragma solidity 0.7.0;

interface IProposalStore {
    function getRound(uint roundId) external returns (Round memory);
    function getCompanyRounds(uint companyId) external returns (Round[] memory);

    function updateRound(uint id, Round momory round) external
    function createRound(Round memory round) external returns (string memory);

    function createRoundNft(RoundNft memory roundNft) external;
    function updateRoundNft(uint id, RoundNft memory roundNft);
    function getRoundNft(uint id) external returns (RoundNft memory)
    function getCompanyRoundsNft(uint companyId) external returns (RoundNft[] memory)
    function getRoundsNft(uint roundId) external returns (RoundNft[] memory)


}
