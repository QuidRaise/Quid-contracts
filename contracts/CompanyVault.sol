// SPDX-License-Identifier: MIT
import "./BaseContract.sol";
import "./DataGrant.sol";
import "./interfaces/ICompanyVault.sol";
import "./interfaces/ICompanyVaultStore.sol";
import "./interfaces/ICompanyStore.sol";
import "./interfaces/IERC20.sol";
import "./libraries/SafeERC20.sol";
import "./libraries/SafeMath.sol";

import "./models/Schema.sol";


pragma experimental ABIEncoderV2;


pragma solidity 0.7.0;

/**
  * The system actors, Investors and Companies do not interact with this contract directly, but rather via the 
  * Company controller or Investor controller 
 */
contract  CompanyVault is BaseContract, DataGrant, ICompanyVault {

    using SafeERC20 for IERC20;
    using SafeMath for uint;

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
    function depositCompanyTokens(uint companyId) external override c2cCallValid
    {
        Company memory company  =  _companyStore.getCompanyById(companyId);
        IERC20 token = IERC20(company.CompanyTokenContractAddress);
        uint allowance = token.allowance(_msgSender(), address(this));
        token.safeTransferFrom(_msgSender(), address(this), allowance);

        uint balance =_companyVaultStore.getCompanyTokenBalance(companyId);
        uint updatedBalance = balance.add(allowance);
        _companyVaultStore.updateCompanyTokenBalance(companyId, updatedBalance);
    }


    /**
      * During the round sale process
      * When investors invest ina company's round, 
      * the payments they make for the company's token are sent to the vault contract
      * The amount sent here conforms to the following formula
      * Amount Sent To Vault = Investors payment - Quidraise commissions
     */
    function depositPaymentTokensToVault(uint companyId,address tokenContractAddress) external override c2cCallValid
    {
        IERC20 token = IERC20(tokenContractAddress);
        uint allowance = token.allowance(_msgSender(), address(this));
        token.safeTransferFrom(_msgSender(), address(this), allowance);

        uint balance =_companyVaultStore.getCompanyVaultBalance(companyId, tokenContractAddress);
        uint updatedBalance = balance.add(allowance);
        _companyVaultStore.updateCompanyVaultBalance(companyId, tokenContractAddress, updatedBalance);
    }

    /**
      * When a round has closed, the company can decide to withdraw their tokens by calling this function
      * During round creation, any leftover tokens from a previous round are sent out to the Company owner's address
      * Before the new deposit is processed
     */
    function withdrawCompanyTokens(uint companyId,uint amount) external override c2cCallValid
    {
        Company memory company  =  _companyStore.getCompanyById(companyId);
        uint balance =_companyVaultStore.getCompanyTokenBalance(companyId);

        require(balance>=amount,"[CompanyVault] amount exceeded balance");

        uint newBalance = balance.sub(amount);
        _companyVaultStore.updateCompanyTokenBalance(companyId, newBalance);

        IERC20 token = IERC20(company.CompanyTokenContractAddress);
        token.safeTransfer(_msgSender(), amount);
    }

    /**
      * Companies after submitting a proposal that has been approved can access their capital by calling this function
     */
    function withdrawPaymentTokensFromVault(uint companyId,address tokenContractAddress, uint amount) external override c2cCallValid
    {
        uint balance =_companyVaultStore.getCompanyVaultBalance(companyId, tokenContractAddress);
        require(balance>=amount,"[CompanyVault] amount exceeded balance");
        uint newBalance = balance.sub(amount);
        _companyVaultStore.updateCompanyVaultBalance(companyId, tokenContractAddress, newBalance);

        IERC20 token = IERC20(tokenContractAddress);
        token.safeTransfer(_msgSender(), amount);
    }
}
