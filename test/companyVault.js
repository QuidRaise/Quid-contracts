const { expect, use } = require("chai");
const { ethers, deployments } = require("hardhat");
const { BigNumber } = require("ethers");
const { solidity, loadFixture, deployContract } = require("ethereum-waffle");

use(solidity);



describe("Deployment of Company Vault Contracts", function () {
  before(async () => {
    [addr1, addr2, addr3] = await ethers.getSigners();
    
    const DNS = await ethers.getContractFactory("DNS");
    const CompanyVault = await ethers.getContractFactory("CompanyVault");
    const Contract = await ethers.getContractFactory("ERC20Token");
    const CompanyStore = await ethers.getContractFactory("CompanyStore");
    const IdentityContract = await ethers.getContractFactory("IdentityContract");
    const CompanyVaultStore = await ethers.getContractFactory("CompanyVaultStore");

    companyToken = await Contract.deploy("QuidToken","QT");
    paymentToken = await Contract.deploy("PaymentToken","QT");
    companyVault = await CompanyVault.deploy();
    dns = await DNS.deploy();
    companyStore = CompanyStore.deploy(dns.address);
    identityContract = await IdentityContract.deploy(dns.address);
    companyVaultStore = await CompanyVaultStore.deploy(dns.address);

    await dns.setRoute("IDENTITY_CONTRACT", identityContract.address);
    await dns.setRoute("COMPANY_STORE", companyStore.address);
    await dns.setRoute("COMPANY_VAULT", companyVault.address);
    await dns.setRoute("COMPANY_VAULT_STORE", companyVaultStore.address);

    await identityContract.grantContractInteraction(companyVault.address, companyVaultStore.address);
    await identityContract.grantContractInteraction(companyVault.address, companyStore.address);


    //Move payment tokens to other addresses used in this test suite
    await paymentToken.transfer(addr2, BigNumber.from("15000000000000000000"));
    await paymentToken.transfer(addr3, BigNumber.from("15000000000000000000"));

  });

  /**   
   * Calling deposit company tokens should throw an error
   */
  it("Deposit Company Tokens Should Revert When Company Not Found", async () => {
    let companyId=1
    let amountDeposited = BigNumber.from("1000000000000000000");    

    await companyToken.approve(companyVault.address, amountDeposited);
    await expect(companyVault.connect(addr1).depositCompanyTokens(companyId)).to.be.revertedWith("No such record");

  });

  it("Deposit Company Tokens Should Increment Company Token Balance In Store", async () => {

    companyStore.createCompany();


    let companyId=1
    let amountDeposited = BigNumber.from("1000000000000000000");    

    let expectedOwnerBalance = await token.balanceOf(addr1.address);

    await companyToken.approve(companyVault.address, amountDeposited);
    await companyVault.connect(addr1).depositCompanyTokens(companyId);


  });

  it("Deposit Company Tokens Should Increment Company Token Balance In Store On Subsequent Calls", async () => {
    let companyId=1
    let amountDeposited = BigNumber.from("1000000000000000000");    

    let expectedOwnerBalance = await token.balanceOf(addr1.address);

    await token.approve(treasury.address, amountDeposited);
    await treasury.depositCompanyTokens(companyId);

    expect (await treasury.getTokenBalance(token.address)).to.equal("1000000000000000000")

    await expect(treasury.connect(addr2).withdrawTokens(token.address, amountDeposited)).to.be.revertedWith("Ownable: caller is not the owner");

    await treasury.connect(addr1).withdrawTokens(token.address, amountDeposited);

    expect (await treasury.getTokenBalance(token.address)).to.equal(0)
    expect (await token.balanceOf(addr1.address)).to.equal(expectedOwnerBalance)

  });



});