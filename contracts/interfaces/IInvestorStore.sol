// SPDX-License-Identifier: MIT
import '../models/Schema.sol';

pragma experimental ABIEncoderV2;
pragma solidity 0.7.0;

interface IInvestorStore {
    function isInvestor(address investorAddress ) external returns (bool);
    function getInvestor(address investorAddress) external returns (Investor memory);
    function getAmountInvestorHasSpent(address investorAddress, address paymentCurrencyAddress) external returns (uint);
    function updateInvestor(address investorAddress, Investor memory investor) external;


    function updateAmountSpentByInvestor(address investorAddress, address paymentCurrencyAddress, uint totalAmountSpent) external returns (uint);
    function updateRoundsInvestedIn(address investorAddress, uint roundId) external;
    function updateCompaniesInvestedIn(address investorAddress, uint companyId) external;

    function getRoundsInvestedIn(address investorAddress) external returns (uint[] memory);
    function getCompaniesInvestedIn(address investorAddress) external returns (uint[] memory);
    
}
