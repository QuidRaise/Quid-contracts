// SPDX-License-Identifier: MIT
pragma solidity 0.7.0;

interface IConfig{

    function setConfig(bytes32 key, uint256 value) external;

    function setConfig(bytes32 key, string calldata value) external;

    function getNumericConfig(bytes32 key) external view returns (uint256);
    function getCharacterConfig(bytes32 key) external view returns (string memory);


}
