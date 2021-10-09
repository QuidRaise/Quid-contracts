// SPDX-License-Identifier: MIT

pragma solidity 0.7.0;
import "./BaseContract.sol";

abstract contract DataGrant is BaseContract {
    mapping(address => bool) private dataAccessor;

    function activateDataAcess(address acessor) external onlyOwner {
        dataAccessor[acessor] = true;
    }

    function deactivateDataAccess(address acessor) external onlyOwner {
        dataAccessor[acessor] = false;
    }

    

    function reAssignWriteAccess(address acessor)
        external
        onlyDataAccessor
    {
        dataAccessor[msg.sender] = false;
        dataAccessor[acessor] = true;
    }

     modifier onlyDataAccessor() {
        bool hasAccess = dataAccessor[msg.sender];
        require(hasAccess, "unauthorized access to contract");
        _;
    }     
}