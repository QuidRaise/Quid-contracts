// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

interface IDNS {
    function setRoute(bytes32 name, address payable _address) external;

    function getRoute(bytes32 name) external view returns (address payable);
}
