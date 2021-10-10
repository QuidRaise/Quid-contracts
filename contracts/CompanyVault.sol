// SPDX-License-Identifier: MIT
import "./BaseContract.sol";
import "./DataGrant.sol";
import "./interfaces/ICompanyVault.sol";
import "./interfaces/ICompanyVaultStore.sol";
import "./interfaces/ICompanyStore.sol";
import "./interfaces/IERC20.sol";
import "./libraries/SafeERC20.sol";
import "./models/Schema.sol";


pragma experimental ABIEncoderV2;


pragma solidity 0.7.0;

/**
  * The system actors, Investors and Companies do not interact with this contract directly, but rather via the 
  * Company controller or Investor controller 
 */
contract  CompanyVault is BaseContract, DataGrant, ICompanyVault {

    using SafeERC20 for IERC20;

    ICompanyVaultStore _companyVaultStore;
    ICompanyStore _companyStore;

    constructor(address dnsContract) BaseContract(dnsContract) {
        _companyVaultStore = ICompanyVaultStore(_dns.getRoute(COMPANY_VAULT_STORE));
        _companyStore = ICompanyStore(_dns.getRoute(COMPANY_VAULT_STORE));

    }


    /**
      * During the round creation process for companies
      * The round allocation tokens are deposited in the company vault contract by calling this function
     */
    function depositCompanyTokens(uint companyId) external override
    {
        Company memory company  =  _companyStore.getCompanyById(companyId);
        IERC20 token = IERC20(company.CompanyTokenContractAddress);
        uint allowance = token.allowance(_msgSender(), address(this));
        token.safeTransferFrom(_msgSender(), address(this), allowance);
        


    }
    /**
      * During the round sale process
      * When investors invest ina company's round, 
      * the payments they make for the company's token are sent to the vault contract
      * The amount sent here conforms to the following formula
      * Amount Sent To Vault = Investors payment - Quidraise commissions
     */
    function depositPaymentTokensToVault(uint companyId,address tokenContractAddress) external override
    {

    }

    /**
      * When a round has closed, the company can decide to withdraw their tokens by calling this function
      * During round creation, any leftover tokens from a previous round are sent out to the Company owner's address
      * Before the new deposit is processed
     */
    function withdrawCompanyTokens(uint companyId) external override
    {

    }

    /**
      * Companies after submitting a proposal that has been approved can access their capital by calling this function
     */
    function withdrawPaymentTokensFromVault(uint companyId,address tokenContractAddress, uint amount) external override
    {

    }
}
