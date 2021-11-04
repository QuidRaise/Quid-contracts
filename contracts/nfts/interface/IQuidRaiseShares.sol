// SPDX-License-Identifier: MIT
import "../../models/Schema.sol";

pragma experimental ABIEncoderV2;
pragma solidity 0.7.0;

interface IQuidRaiseShares {
    function mint(
        uint256 tokenId,
        uint256 numberOfTokens,
        address recipient
    ) external;

    function balanceOf(address account, uint256 id) external view returns (uint256);

    function burn(
        address from,
        uint256 id,
        uint256 amount
    ) external;

    function burnBatch(
        address from,
        uint256[] memory ids,
        uint256[] memory amounts
    ) external;
}
