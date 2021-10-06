// SPDX-License-Identifier: MIT
import '../models/Schema.sol';

pragma experimental ABIEncoderV2;
pragma solidity 0.7.0;

interface IRoundStore {
    function getRound(uint roundId) external returns (Round memory);
    function getCompanyRounds(uint companyId) external returns (Round[] memory);

    function updateRound(uint id, Round memory round) external;
    function createRound(Round memory round) external returns (uint);

    function createRoundNft(RoundNft memory roundNft) external returns (uint);
    function updateRoundNft(uint id, RoundNft memory roundNft) external;
    function getRoundNft(uint id) external returns (RoundNft memory);
    function getCompanyRoundsNft(uint companyId) external returns (RoundNft[] memory);
    function getRoundsNft(uint roundId) external returns (RoundNft[] memory);


}
