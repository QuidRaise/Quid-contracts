// SPDX-License-Identifier: MIT
import "./interface/IDNS.sol";
import "./interface/IIdentityContract.sol";

import "../libraries/Ownable.sol";
import "../libraries/Address.sol";

pragma solidity 0.7.0;

abstract contract BaseContract is Ownable {
    using Address for address;

    string constant IDENTITY_CONTRACT = "IDENTITY_CONTRACT";
    string constant EVENT_EMITTER = "EVENT_EMITTER";
    string constant COMPANY_VAULT_STORE = "COMPANY_VAULT_STORE";
    string constant COMPANY_VAULT = "COMPANY_VAULT";
    string constant COMPANY_STORE = "COMPANY_STORE";
    string constant INVESTOR_STORE = "INVESTOR_STORE";
    string constant PROPOSAL_STORE = "PROPOSAL_STORE";
    string constant ROUND_STORE = "ROUND_STORE";
    string constant NFT = "NFT";
    string constant CONFIG = "CONFIG";
    string constant COMPANY_CONTROLLER = "COMPANY_CONTROLLER";
    string constant INVESTOR_CONTROLLER = "INVESTOR_CONTROLLER";

    string constant MAX_ROUND_PAYMENT_OPTION = "MAX_ROUND_PAYMENT_OPTION";
    string constant PLATFORM_COMMISION = "PLATFORM_COMMISION";
    string constant PRECISION = "PRECISION";  
    string constant INVESTMENT_TOKEN_VAULT = "INVESTMENT_TOKEN_VAULT";


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
