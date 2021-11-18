// SPDX-License-Identifier: MIT
import "../infrastructure/BaseContract.sol";
import "../DataGrant.sol";
import "./interface/IInvestmentTokenVault.sol";
import "../interfaces/IERC20.sol";
import "../libraries/SafeERC20.sol";
import "../libraries/SafeMath.sol";

import "../models/Schema.sol";

pragma experimental ABIEncoderV2;

pragma solidity 0.7.0;

/**
 * The system actors, Investors and Companies do not interact with this contract directly, but rather via the
 * Company controller or Investor controller
 */
contract InvestmentTokenVault is BaseContract, DataGrant, IInvestmentTokenVault {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    
    uint256 private _releaseTimeStamp;
    uint256 private _roundId;

    /** @dev
     * How many tokens have been claimed
     */

    uint256 private _claimed;
    
    /** @dev
      * How many tokens have not been claimed
     */
    uint256 private _unclaimed;

    address private _tokenAddress;

    
    /** @dev
      *  How many tokens each investor has locked up till the token release date
     */
    mapping(address=>uint256) private _investorTokenAllocation;

    constructor(address dnsContract, address tokenAddress, uint256 releaseTimeStamp, uint256 roundId) BaseContract(dnsContract) {
       _releaseTimeStamp = releaseTimeStamp;
       _roundId = roundId;
       _tokenAddress = tokenAddress;
    }

    function setReleaseTimeStamp(uint256 releaseTimeStamp) external override onlyDataAccessor
    {
        _releaseTimeStamp = releaseTimeStamp;
    }

    /** 
     * Tokens purchased in a round are locked in this contract till the lockup period for that round has elapsed
     * 
     */
    function lockTokens(address investor) external override onlyDataAccessor {
        
        IERC20 token = IERC20(_tokenAddress);
        uint256 allowance = token.allowance(_msgSender(), address(this));
        token.safeTransferFrom(_msgSender(), address(this), allowance);
        _investorTokenAllocation[investor] = _investorTokenAllocation[investor].add(allowance);
        
    }

    /**
     * After the lockup period has elapsed tokens are released to the investors
     */
    function releaseTokens(uint256 amount, address investor) external override onlyDataAccessor {
        require(_investorTokenAllocation[investor]>=amount, "Insufficient Token Allocation");
        require(block.timestamp>=_releaseTimeStamp, "Tokens are still locked");

        IERC20 token = IERC20(_tokenAddress);
        token.safeTransferFrom(address(this), _msgSender(), amount);
        _investorTokenAllocation[investor] = _investorTokenAllocation[investor].sub(amount);
    }

}
