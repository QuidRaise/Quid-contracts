// SPDX-License-Identifier: MIT

pragma solidity 0.7.0;
import "./infrastructure/BaseContract.sol";
import "./DataGrant.sol";

abstract contract Deprecateable is BaseContract, DataGrant {
    bool private isDeprecated;

    constructor() {
        isDeprecated = false;
    }

    function deprecate() external onlyOwner {
        isDeprecated = true;
    }

    function undeprecate() external onlyOwner {
        isDeprecated = false;
    }

    modifier notDeprecated() {
        require(!isDeprecated, "Cannot access deprecated contract");
        _;
    }
}
