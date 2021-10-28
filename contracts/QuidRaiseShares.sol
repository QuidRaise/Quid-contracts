// SPDX-License-Identifier: MIT

pragma solidity 0.7.0;

import "./libraries/ERC1155/ERC1155.sol";
import "./libraries/ReentrancyGuard.sol";
import "./libraries/Ownable.sol";
import "./libraries/SafeMath.sol";
import "./libraries/SafeERC20.sol";
import "./interfaces/IERC20.sol";
import "./interfaces/ITreasury.sol";
import "./interfaces/IIdentityContract.sol";

import "./BaseContract.sol";





contract QuidRaiseShares is BaseContract, ERC1155,  ReentrancyGuard, Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IIdentityContract private _identityContract;


    function mint(uint256 tokenId, uint256 numberOfTokens, address recipient) external nonReentrant c2cCallValid
    {
        _mint(recipient, tokenId,numberOfTokens);

    }

    function setUri(string memory baseuri) external onlyOwner{
        _setURI(baseUri);
    }

    function getUri() external view returns (string memory){
        return _baseURI();
    }

    function _baseURI() internal view override returns (string memory) {
        return _baseUri;
    }
    

     constructor(string calldata baseUri, address dnsContract) BaseContract(dnsContract) ERC1155(baseUri) {
        _identityContract = IIdentityContract(_dns.getRoute(IDENTITY_CONTRACT));
     }


}




