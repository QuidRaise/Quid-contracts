// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

contract Quid {
    string public name = "Quid";

    function getName() public view returns (string) {
        return name;
    }
}
}
