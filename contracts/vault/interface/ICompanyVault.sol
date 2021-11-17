// SPDX-License-Identifier: MIT

pragma solidity 0.7.0;

/**
 * The system actors, Investors and Companies do not interact with this contract directly, but rather via the
 * Company controller or Investor controller
 */
interface ICompanyVault {
    /**
     * During the round creation process for companies
     * The round allocation tokens are deposited in the company vault contract by calling this function
     */
    function depositCompanyTokens(uint256 companyId) external;

    /**
     * During the round sale process
     * When investors invest ina company's round,
     * the payments they make for the company's token are sent to the vault contract
     * The amount sent here conforms to the following formula
     * Amount Sent To Vault = Investors payment - Quidraise commissions
     */
    function depositPaymentTokensToVault(uint256 companyId, address tokenContractAddress) external;

    /**
     * When a round has closed, the company can decide to withdraw their tokens by calling this function
     * During round creation, any leftover tokens from a previous round are sent out to the Company owner's address
     * Before the new deposit is processed
     */
    function withdrawCompanyTokens(uint256 companyId, uint256 amount) external;

    /**
     * Companies after submitting a proposal that has been approved can access their capital by calling this function
     */
    function withdrawPaymentTokensFromVault(
        uint256 companyId,
        address tokenContractAddress,
        uint256 amount
    ) external;
}
