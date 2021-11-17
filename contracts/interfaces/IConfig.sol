// SPDX-License-Identifier: MIT
pragma solidity 0.7.0;

interface IConfig {
    function setNumericConfig(string calldata key, uint256 value) external;

    function setCharacterConfig(string calldata key, string calldata value) external;

    function getNumericConfig(string calldata key) external view returns (uint256);

    function getCharacterConfig(string calldata key) external view returns (string memory);
}
