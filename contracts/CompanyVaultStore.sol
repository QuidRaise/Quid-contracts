// SPDX-License-Identifier: MIT
import "BaseContract.sol";
pragma solidity 0.7.0;

contract CompanyVaultStore is BaseContract, DataGrant, ICompanyVaultStore {
    function getCompanyTokenBalance(uint companyId) external returns (uint);

    function getCompanyVaultBalance(uint companyId,address tokenContractAddress) external returns (uint);

    function updateCompanyTokenBalance(uint companyId, uint amount) external;

    function updateCompanyVaultBalance(uint companyId, address tokenContractAddress, uint amount) external;
}
