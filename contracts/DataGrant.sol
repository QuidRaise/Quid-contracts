// SPDX-License-Identifier: MIT

pragma solidity 0.7.0;
import "./infrastructure/BaseContract.sol";

abstract contract DataGrant is BaseContract {
    mapping(address => bool) private dataAccessor;

    function activateDataAccess(address acessor) external onlyOwner {
        dataAccessor[acessor] = true;
    }

    function deactivateDataAccess(address acessor) external onlyOwner {
        dataAccessor[acessor] = false;
    }

    function reAssignWriteAccess(address acessor) external onlyDataAccessor {
        dataAccessor[msg.sender] = false;
        dataAccessor[acessor] = true;
    }

    modifier onlyDataAccessor() {
        bool hasAccess = dataAccessor[msg.sender];
        require(hasAccess, "unauthorized data access to contract");
        _;
    }
}
