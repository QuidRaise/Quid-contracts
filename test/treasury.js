const { expect, use } = require("chai");
const { ethers, deployments } = require("hardhat");
const { BigNumber } = require("ethers");
const { solidity, loadFixture, deployContract } = require("ethereum-waffle");

use(solidity);



describe("Deployment of Treasury Test Contracts", function () {
  before(async () => {
    [addr1, addr2] = await ethers.getSigners();

    const Treasury = await ethers.getContractFactory("Treasury");
    const Contract = await ethers.getContractFactory("ERC20Token");

    token = await Contract.deploy("QuidToken","QT");
    treasury = await Treasury.deploy();
   
  });

  /**
   * Deposits tokens into the treasury
   * Validates that the amount approved is what is found in the treasury balance
   * Attempts withdrawal of the tokens by a non-owner address, which reverts with the appropriate error message
   * Attempts withdrawal of tokens by owner, which is successful
   * Validate that the tokens are no more in the treasury contract
   * Validate that the tokens are now in the owner walet
   * 
   */
  it("should recieve token deposits", async () => {
    let amountDeposited = BigNumber.from("1000000000000000000");    

    let expectedOwnerBalance = await token.balanceOf(addr1.address);

    await token.approve(treasury.address, amountDeposited);
    await treasury.depositToken(token.address);

    expect (await treasury.getTokenBalance(token.address)).to.equal("1000000000000000000")

    await expect(treasury.connect(addr2).withdrawTokens(token.address, amountDeposited)).to.be.revertedWith("Ownable: caller is not the owner");

    await treasury.connect(addr1).withdrawTokens(token.address, amountDeposited);

    expect (await treasury.getTokenBalance(token.address)).to.equal(0)
    expect (await token.balanceOf(addr1.address)).to.equal(expectedOwnerBalance)

  });

  it("should recieve eth deposits", async () => {
    const provider = ethers.getDefaultProvider();

    let amountDeposited = BigNumber.from("150000000000000000");    

    let etherBalance = await provider.getBalance(addr1.address)


    await addr2.sendTransaction({
        to: treasury.address,
        value: BigNumber.from("150000000000000000"), // Sends exactly 1.0 ether
      });

    expect (await treasury.getEtherBalance()).to.equal("150000000000000000");

    
    await expect(treasury.connect(addr2).withdrawEthers(amountDeposited)).to.be.revertedWith("Ownable: caller is not the owner");
    await treasury.connect(addr1).withdrawEthers(amountDeposited);

    expect (await treasury.getEtherBalance()).to.equal(0)

    expect (await provider.getBalance(addr1.address)).to.equal(etherBalance)


  });


});