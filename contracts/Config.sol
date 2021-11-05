// SPDX-License-Identifier: MIT

import "./interfaces/IConfig.sol";

pragma experimental ABIEncoderV2;
pragma solidity 0.7.0;

contract Config is IConfig {
    mapping(bytes32 => string) private _characterConfigManager;
    mapping(bytes32 => uint256) private _numericConfigManager;

    function setConfig(bytes32 key, uint256 value) external override {
        _numericConfigManager[key] = value;
    }

    function setConfig(bytes32 key, string calldata value) external override {
        _characterConfigManager[key] = value;
    }

    function getNumericConfig(bytes32 key) external view override returns (uint256) {
        return _numericConfigManager[key];
    }

    function getCharacterConfig(bytes32 key) external view override returns (string memory) {
        return _characterConfigManager[key];
    }
}
