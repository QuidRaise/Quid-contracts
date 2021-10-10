// SPDX-License-Identifier: MIT
import "../models/Schema.sol";

pragma experimental ABIEncoderV2;
pragma solidity 0.7.0;

interface ICompanyController {
    function createCompany(string calldata companyDocUrl, string calldata logoUrl, 
                           string calldata companyName, address companyTokenContractAddress, 
                           address companyOwner) external;

    function createRound(uint startTimestamp, uint durationInSeconds,
                         uint lockupPeriodForShareInSeconds, uint pricePerShare, 
                         uint tokensSuppliedForRound, address paymentCurrencyAddress) external
}
