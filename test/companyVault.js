const { expect, use } = require("chai");
const { ethers, deployments } = require("hardhat");
const { BigNumber } = require("ethers");
const { solidity, loadFixture, deployContract } = require("ethereum-waffle");

use(solidity);



describe("Deployment of Company Vault Contracts", function () {
  beforeEach(async () => {
    [addr1, addr2, addr3] = await ethers.getSigners();
    
    const DNS = await ethers.getContractFactory("DNS");
    const CompanyVault = await ethers.getContractFactory("CompanyVault");
    const Contract = await ethers.getContractFactory("ERC20Token");
    const CompanyStore = await ethers.getContractFactory("CompanyStore");
    const IdentityContract = await ethers.getContractFactory("IdentityContract");
    const CompanyVaultStore = await ethers.getContractFactory("CompanyVaultStore");
    const EventEmitter = await ethers.getContractFactory("EventEmitter");

    companyToken = await Contract.deploy("QuidToken","QT");
    paymentToken = await Contract.deploy("PaymentToken","QT");
    dns = await DNS.deploy();
    companyVault = await CompanyVault.deploy(dns.address);
    companyStore = await CompanyStore.deploy(dns.address);
    identityContract = await IdentityContract.deploy(dns.address);
    companyVaultStore = await CompanyVaultStore.deploy(dns.address);
    eventEmitter = await EventEmitter.deploy(dns.address);

    //Set Address Registry
    await dns.setRoute("IDENTITY_CONTRACT", identityContract.address);
    await dns.setRoute("COMPANY_STORE", companyStore.address);
    await dns.setRoute("COMPANY_VAULT", companyVault.address);
    await dns.setRoute("COMPANY_VAULT_STORE", companyVaultStore.address);
    await dns.setRoute("COMPANY_VAULT_STORE", companyVaultStore.address);
    await dns.setRoute("EVENT_EMITTER", eventEmitter.address);

    //Set Auth Permissions For C2C Calls
    await identityContract.activateDataAccess(addr1.address);
    await identityContract.grantContractInteraction(identityContract.address, eventEmitter.address);
    await identityContract.grantContractInteraction(companyVault.address, companyVaultStore.address);
    await identityContract.grantContractInteraction(companyVault.address, companyStore.address);
    await identityContract.grantContractInteraction(addr1.address, companyVault.address);
    await identityContract.grantContractInteraction(addr1.address, companyVaultStore.address);
    await identityContract.grantContractInteraction(addr1.address, companyStore.address);


    //Move payment tokens to other addresses used in this test suite
    await paymentToken.transfer(addr2.address, BigNumber.from("15000000000000000000"));
    await paymentToken.transfer(addr3.address, BigNumber.from("15000000000000000000"));

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

 
    //Create Test Company
    let company = {
      Id:0,
      CompanyName:'QuidRaise',
      CompanyUrl:'https://QuidRaise.io',
      CompanyTokenContractAddress: companyToken.address,
      OwnerAddress : addr1.address
    };
    await companyStore.createCompany(company);


    

    let companyId=1
    let amountDeposited = BigNumber.from("1000000000000000000");    

    await companyToken.approve(companyVault.address, amountDeposited);
    await companyVault.connect(addr1).depositCompanyTokens(companyId);

    expect(await companyToken.balanceOf(companyVault.address)).to.equal("1000000000000000000");
  });

   it("Deposit Company Tokens Should Increment Company Token Balance In Store On Subsequent Calls", async () => {

    //Create Test Company
    let company = {
      Id:0,
      CompanyName:'QuidRaise',
      CompanyUrl:'https://QuidRaise.io',
      CompanyTokenContractAddress: companyToken.address,
      OwnerAddress : addr1.address
    };
    await companyStore.createCompany(company);


    

    let companyId=1
    let amountDeposited = BigNumber.from("1000000000000000000");    

    await companyToken.approve(companyVault.address, amountDeposited);
    await companyVault.connect(addr1).depositCompanyTokens(companyId);

    await companyToken.approve(companyVault.address, amountDeposited);
    await companyVault.connect(addr1).depositCompanyTokens(companyId);

    expect(await companyToken.balanceOf(companyVault.address)).to.equal("2000000000000000000");
  });

  it("Deposit Payment Tokens To Vault", async () => {

    //Create Test Company
    let company = {
      Id:0,
      CompanyName:'QuidRaise',
      CompanyUrl:'https://QuidRaise.io',
      CompanyTokenContractAddress: companyToken.address,
      OwnerAddress : addr1.address
    };
    await companyStore.createCompany(company);

    await companyVaultStore.enablePaymentOption(paymentToken.address);

    //So second address can call the depositPaymentTokensToVault function
    await identityContract.grantContractInteraction(addr2.address, companyVault.address);
   

    let companyId=1
    let amountDeposited = BigNumber.from("1000000000000000000");    

    await paymentToken.connect(addr2).approve(companyVault.address, amountDeposited);
    await companyVault.connect(addr2).depositPaymentTokensToVault(companyId, paymentToken.address);
    expect(await paymentToken.balanceOf(companyVault.address)).to.equal("1000000000000000000");

    await paymentToken.connect(addr2).approve(companyVault.address, amountDeposited);
    await companyVault.connect(addr2).depositPaymentTokensToVault(companyId,paymentToken.address);

    expect(await paymentToken.balanceOf(companyVault.address)).to.equal("2000000000000000000");
  });

  it("Deposit Payment Tokens To Vault Should Fail When Approved Amount Is Zero", async () => {

    //Create Test Company
    let company = {
      Id:0,
      CompanyName:'QuidRaise',
      CompanyUrl:'https://QuidRaise.io',
      CompanyTokenContractAddress: companyToken.address,
      OwnerAddress : addr1.address
    };
    await companyStore.createCompany(company);

    await companyVaultStore.enablePaymentOption(paymentToken.address);

    //So second address can call the depositPaymentTokensToVault function
    await identityContract.grantContractInteraction(addr2.address, companyVault.address);
   

    let companyId=1

    await expect(companyVault.connect(addr2).depositPaymentTokensToVault(companyId, paymentToken.address)).to.be.revertedWith("Cannot deposit 0 to vault");
  });


  
  it("withdraw Payment Tokens From Vault Should Withdraw Tokens to calling address", async () => {

    //Create Test Company
    let company = {
      Id:0,
      CompanyName:'QuidRaise',
      CompanyUrl:'https://QuidRaise.io',
      CompanyTokenContractAddress: companyToken.address,
      OwnerAddress : addr1.address
    };
    await companyStore.createCompany(company);

    await companyVaultStore.enablePaymentOption(paymentToken.address);

    //So second address can call the depositPaymentTokensToVault function
    await identityContract.grantContractInteraction(addr2.address, companyVault.address);
   

    let companyId=1
    let amountLiteral = "1000000000000000000";
    let amountDeposited = BigNumber.from(amountLiteral);    

    await paymentToken.connect(addr2).approve(companyVault.address, amountDeposited);
    await companyVault.connect(addr2).depositPaymentTokensToVault(companyId, paymentToken.address);
    expect(await paymentToken.balanceOf(companyVault.address)).to.equal(amountLiteral);

    await expect(companyVault.connect(addr1).withdrawPaymentTokensFromVault(companyId, paymentToken.address,amountDeposited)).to.emit(paymentToken,"Transfer").withArgs(companyVault.address, addr1.address,amountLiteral );
    expect(await paymentToken.balanceOf(companyVault.address)).to.be.equal(0);   
  });

  
  it("withdraw Payment Tokens Greater Than Company Vault Balance Should Revert", async () => {

    //Create Test Company
    let company = {
      Id:0,
      CompanyName:'QuidRaise',
      CompanyUrl:'https://QuidRaise.io',
      CompanyTokenContractAddress: companyToken.address,
      OwnerAddress : addr1.address
    };

    let secondCompany = {
      Id:0,
      CompanyName:'QuidRaise',
      CompanyUrl:'https://QuidRaise.io',
      CompanyTokenContractAddress: companyToken.address,
      OwnerAddress : addr2.address
    };
    await companyStore.createCompany(company);
    await companyStore.createCompany(secondCompany);

    await companyVaultStore.enablePaymentOption(paymentToken.address);

    //So second address can call the depositPaymentTokensToVault function
    await identityContract.grantContractInteraction(addr2.address, companyVault.address);
   

    let companyId=1
    let secondCompanyId=2;
    let amountLiteral = "1000000000000000000";
    let amountDeposited = BigNumber.from(amountLiteral);    

    await paymentToken.connect(addr2).approve(companyVault.address, amountDeposited);
    await companyVault.connect(addr2).depositPaymentTokensToVault(companyId, paymentToken.address);
    expect(await paymentToken.balanceOf(companyVault.address)).to.equal(amountLiteral);


    await paymentToken.connect(addr2).approve(companyVault.address, amountDeposited);
    await companyVault.connect(addr2).depositPaymentTokensToVault(secondCompanyId, paymentToken.address);

    let totalDeposit = amountDeposited.add(amountDeposited);


    await expect(companyVault.connect(addr1).withdrawPaymentTokensFromVault(companyId, paymentToken.address,totalDeposit)).to.be.revertedWith("[CompanyVault] amount exceeded balance");
    expect(await paymentToken.balanceOf(companyVault.address)).to.be.equal(totalDeposit.toString());   
  });


  
  it("withdraw Company Tokens From Vault Should Withdraw Tokens to calling address", async () => {

    
    //Create Test Company
    let company = {
      Id:0,
      CompanyName:'QuidRaise',
      CompanyUrl:'https://QuidRaise.io',
      CompanyTokenContractAddress: companyToken.address,
      OwnerAddress : addr1.address
    };
    await companyStore.createCompany(company);

    //So second address can call the depositPaymentTokensToVault function
    await identityContract.grantContractInteraction(addr2.address, companyVault.address);
  
    let companyId=1
    let amountLiteral = "1000000000000000000";
    let amountDeposited = BigNumber.from(amountLiteral);    

    await companyToken.approve(companyVault.address, amountDeposited);
    await companyVault.connect(addr1).depositCompanyTokens(companyId);

    expect(await companyToken.balanceOf(companyVault.address)).to.equal(amountLiteral);

    await expect(companyVault.connect(addr1).withdrawCompanyTokens(companyId,amountDeposited)).to.emit(companyToken,"Transfer").withArgs(companyVault.address, addr1.address,amountLiteral );
    expect(await paymentToken.balanceOf(companyVault.address)).to.be.equal(0);   
  });


  
  it("withdraw Company Tokens From Vault Should Withdraw Tokens to calling address", async () => {

    
    //Create Test Company
    let company = {
      Id:0,
      CompanyName:'QuidRaise',
      CompanyUrl:'https://QuidRaise.io',
      CompanyTokenContractAddress: companyToken.address,
      OwnerAddress : addr1.address
    };
    await companyStore.createCompany(company);

    //So second address can call the depositPaymentTokensToVault function
    await identityContract.grantContractInteraction(addr2.address, companyVault.address);
  
    let companyId=1
    let amountLiteral = "1000000000000000000";
    let amountDeposited = BigNumber.from(amountLiteral);    

    await companyToken.approve(companyVault.address, amountDeposited);
    await companyVault.connect(addr1).depositCompanyTokens(companyId);

    expect(await companyToken.balanceOf(companyVault.address)).to.equal(amountLiteral);

    let exceededBalanceAmount = amountDeposited.mul(2);

    await expect(companyVault.connect(addr1).withdrawCompanyTokens(companyId,exceededBalanceAmount)).to.be.revertedWith("[CompanyVault] amount exceeded balance");
    expect(await paymentToken.balanceOf(companyVault.address)).to.be.equal(0);   
  });




});