// SPDX-License-Identifier: MIT
import "./interfaces/IDNS.sol";
import "./interfaces/IIdentityContract.sol";

import "./libraries/Ownable.sol";
import "./libraries/Address.sol";


pragma solidity 0.7.0;

abstract contract BaseContract is Ownable 
{

    using Address for address;

    
    bytes32 constant FEE_VAULT_STORAGE_ROUTE_KEY = "IDENTITY_CONTRACT";
    bytes32 constant EVENT_EMITTER_KEY = "EVENT_EMITTER";

    IDNS Dns;

    constructor(address dnsContractAddress){
        Dns = IDNS(dnsContractAddress);
    }

    function updateDnsContractAddress(address  dnsContractAddress) external onlyOwner{
        require(dnsContractAddress!=address(0x0),"contract address cannot be empty");
        require(dnsContractAddress.isContract(),"invalid contract address");
        Dns = IDNS(dnsContractAddress);

    }

    function getDnsContractAddress() external view returns (address){
        return address(Dns);
    }


     modifier c2cCallValid() {
        IIdentityContract identityContract =  IIdentityContract(Dns.getRoute(FEE_VAULT_STORAGE_ROUTE_KEY));
        bool isValid = identityContract.validateC2CTransaction(msg.sender,address(this));
        require(isValid, "unauthorized contract to contract interaction");
        _;
    }     



}