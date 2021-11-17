// SPDX-License-Identifier: MIT
import "../../models/Schema.sol";

pragma experimental ABIEncoderV2;
pragma solidity 0.7.0;

interface IRoundStore {
    function getRound(uint256 roundId) external view returns (Round memory);

    function getCompanyRounds(uint256 companyId) external view returns (Round[] memory);

    function updateRound(Round memory round) external;

    function createRound(Round memory round) external returns (uint256);

    function createRoundPaymentOptions(uint256 roundId, address[] memory paymentCurrencies) external;

    function getRoundPaymentOptions(uint256 id) external view returns (address[] memory);
}
   
