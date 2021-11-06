// SPDX-License-Identifier: MIT

import "./interfaces/IConfig.sol";

pragma experimental ABIEncoderV2;
pragma solidity 0.7.0;

contract Config is IConfig {
    mapping(string => string) private _characterConfigManager;
    mapping(string => uint256) private _numericConfigManager;

    function setNumericConfig(string calldata key, uint256 value) external override {
        _numericConfigManager[key] = value;
    }

    function setCharacterConfig(string calldata key, string calldata value) external override {
        _characterConfigManager[key] = value;
    }

    function getNumericConfig(string calldata key) external view override returns (uint256) {
        return _numericConfigManager[key];
    }

    function getCharacterConfig(string calldata key) external view override returns (string memory) {
        return _characterConfigManager[key];
    }
}
