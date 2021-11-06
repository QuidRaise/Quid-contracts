// SPDX-License-Identifier: MIT

pragma solidity 0.7.0;

import "../libraries/Ownable.sol";
import "../libraries/Address.sol";

import "./interface/IDNS.sol";

contract DNS is Ownable, IDNS {
    mapping(string => address payable) private RouteTable;

    using Address for address payable;

    function setRoute(string calldata name, address payable _address) external override onlyOwner {
        require(_address != address(0x0), "contract address cannot be empty");
        require(_address.isContract(), "invalid contract address");
        RouteTable[name] = _address;
    }

    function getRoute(string calldata name) external view override returns (address payable) {
        address payable contractAddress = RouteTable[name];
        require(contractAddress != address(0x0), "route entry not found");
        return contractAddress;
    }
}
