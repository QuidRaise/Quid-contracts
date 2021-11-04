// SPDX-License-Identifier: MIT
import "./interface/IDNS.sol";
import "./interface/IIdentityContract.sol";

import "../libraries/Ownable.sol";
import "../libraries/Address.sol";

pragma solidity 0.7.0;

abstract contract BaseContract is Ownable {
    using Address for address;

    bytes32 constant IDENTITY_CONTRACT = "IDENTITY_CONTRACT";
    bytes32 constant EVENT_EMITTER = "EVENT_EMITTER";
    bytes32 constant COMPANY_VAULT_STORE = "COMPANY_VAULT_STORE";
    bytes32 constant COMPANY_VAULT = "COMPANY_VAULT";
    bytes32 constant COMPANY_STORE = "COMPANY_STORE";
    bytes32 constant INVESTOR_STORE = "INVESTOR_STORE";
    bytes32 constant PROPOSAL_STORE = "PROPOSAL_STORE";
    bytes32 constant ROUND_STORE = "ROUND_STORE";
    bytes32 constant NFT = "NFT";
    bytes32 constant CONFIG = "CONFIG";
    bytes32 constant MAX_ROUND_PAYMENT_OPTION = "MAX_ROUND_PAYMENT_OPTION";
    bytes32 constant PLATFORM_COMMISION = "PLATFORM_COMMISION";
    bytes32 constant PRECISION = "PRECISION";

    IDNS _dns;

    constructor(address dnsContractAddress) {
        _dns = IDNS(dnsContractAddress);
    }

    function update_dnsContractAddress(address dnsContractAddress) external onlyOwner {
        require(dnsContractAddress != address(0x0), "contract address cannot be empty");
        require(dnsContractAddress.isContract(), "invalid contract address");
        _dns = IDNS(dnsContractAddress);
    }

    function get_dnsContractAddress() external view returns (address) {
        return address(_dns);
    }

    modifier c2cCallValid() {
        IIdentityContract identityContract = IIdentityContract(_dns.getRoute(IDENTITY_CONTRACT));
        bool isValid = identityContract.validateC2CTransaction(msg.sender, address(this));
        require(isValid, "unauthorized contract to contract interaction");
        _;
    }
}
