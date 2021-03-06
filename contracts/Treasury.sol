// SPDX-License-Identifier: MIT
pragma solidity 0.7.0;

import "./libraries/Ownable.sol";
import "./interfaces/IERC20.sol";
import "./libraries/SafeERC20.sol";

contract Treasury is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    event TokenDepositEvent(address indexed depositorAddress, address indexed tokenContractAddress, uint256 amount);

    event EtherDepositEvent(address indexed depositorAddress, uint256 amount);

    receive() external payable {
        require(msg.value != 0, "Cannot deposit nothing into the treasury");
        emit EtherDepositEvent(msg.sender, msg.value);
    }

    function depositToken(address token) public payable {
        require(token != address(0x0), "token contract address cannot be null");

        require(address(token) != address(0), "tken contract address cannot be 0");

        IERC20 tokenContract = IERC20(token);
        uint256 amountToDeposit = tokenContract.allowance(msg.sender, address(this));

        require(amountToDeposit != 0, "Cannot deposit nothing into the treasury");

        tokenContract.safeTransferFrom(msg.sender, address(this), amountToDeposit);
        emit TokenDepositEvent(msg.sender, token, amountToDeposit);
    }

    function getEtherBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getTokenBalance(address token) public view returns (uint256) {
        require(token != address(0x0), "token contract address cannot be null");

        require(address(token) != address(0), "tken contract address cannot be 0");

        IERC20 tokenContract = IERC20(token);
        return tokenContract.balanceOf(address(this));
    }

    function withdrawEthers(uint256 amount) external onlyOwner{
        uint256 etherBalance = address(this).balance;
        require(etherBalance >= amount, "Insufficient ether balance");
        payable(owner()).transfer(amount);
    }

    function withdrawTokens(address tokenAddress, uint256 amount) external onlyOwner{
        IERC20 tokenContract = IERC20(tokenAddress);
        uint256 tokenBalance = tokenContract.balanceOf(address(this));
        require(tokenBalance >= amount, "Insufficient token balance");
        tokenContract.safeTransfer(owner(), amount);
    }
}
