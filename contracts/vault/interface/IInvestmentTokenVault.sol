// SPDX-License-Identifier: MIT

pragma solidity 0.7.0;


interface IInvestmentTokenVault {   

     function setReleaseTimeStamp(uint256 releaseTimeStamp) external ;

    /** 
     * Tokens purchased in a round are locked in this contract till the lockup period for that round has elapsed
     * 
     */
    function lockTokens(address investor) external ;

    /**
     * After the lockup period has elapsed tokens are released to the investors
     */
    function releaseTokens(uint256 amount, address investor) external ;
}
