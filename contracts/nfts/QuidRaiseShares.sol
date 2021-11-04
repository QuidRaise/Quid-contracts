// SPDX-License-Identifier: MIT

pragma solidity 0.7.0;

import "../libraries/ERC1155/ERC1155.sol";
import "../libraries/ReentrancyGuard.sol";
import "../libraries/Ownable.sol";
import "../libraries/SafeMath.sol";
import "../libraries/SafeERC20.sol";
import "../interfaces/IERC20.sol";
import "../interfaces/ITreasury.sol";
import "../infrastructure/interface/IIdentityContract.sol";

import "../infrastructure/BaseContract.sol";

contract QuidRaiseShares is BaseContract, ERC1155, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IIdentityContract private _identityContract;

    function mint(
        uint256 tokenId,
        uint256 numberOfTokens,
        address recipient
    ) external nonReentrant c2cCallValid {
        _mint(recipient, tokenId, numberOfTokens, "");
    }

    function burn(
        address from,
        uint256 id,
        uint256 amount
    ) external {
        super._burn(from, id, amount);
    }

    function burnBatch(
        address from,
        uint256[] memory ids,
        uint256[] memory amounts
    ) internal virtual {
        super._burnBatch(from, ids, amounts);
    }

    function setUri(string memory baseUri) external onlyOwner {
        _setURI(baseUri);
    }

    constructor(string memory baseUri, address dnsContract) BaseContract(dnsContract) ERC1155(baseUri) {
         //TODO: Move this initialization into an internal function
        //This internal function would be called before any external function execution on this contract
        _identityContract = IIdentityContract(_dns.getRoute(IDENTITY_CONTRACT));
    }
}
