// SPDX-License-Identifier: MIT
import "../../models/Schema.sol";

pragma experimental ABIEncoderV2;
pragma solidity 0.7.0;

interface ICompanyRoundController {

    function createRound(
        address companyOwner,
        string calldata roundDocumentUrl,
        uint256 startTimestamp,
        uint256 duration,
        uint256 lockupPeriodForShare,
        uint256 tokensSuppliedForRound,
        bool runTillFullySubscribed,
        address[] memory paymentCurrencies,
        uint256[] memory pricePerShare
    ) external;

    function getRound(uint256 roundId) external view returns (RoundResponse memory);

   
    function deleteRound(uint256 proposalId, address companyOwnerAddress) external;
}
