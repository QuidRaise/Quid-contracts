// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

interface IDNS {
    
    function setRoute(string calldata name,address payable _address) external;

    function getRoute(string calldata name) external view returns(address payable);
}
