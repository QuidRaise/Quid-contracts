const { expect, use } = require("chai");
const { ethers, deployments } = require("hardhat");
const { BigNumber } = require("ethers");
const { solidity, loadFixture, deployContract } = require("ethereum-waffle");

use(solidity);



describe("Deployment of Company Vault Store Contracts", function () {
  beforeEach(async () => {
    [addr1, addr2, addr3] = await ethers.getSigners();
    
    const DNS = await ethers.getContractFactory("DNS");
    const Contract = await ethers.getContractFactory("ERC20Token");
    const IdentityContract = await ethers.getContractFactory("IdentityContract");
    const CompanyVaultStore = await ethers.getContractFactory("CompanyVaultStore");
    const EventEmitter = await ethers.getContractFactory("EventEmitter");

    companyToken = await Contract.deploy("QuidToken","QT");
    paymentToken = await Contract.deploy("PaymentToken","QT");
    dns = await DNS.deploy();
    identityContract = await IdentityContract.deploy(dns.address);
    companyVaultStore = await CompanyVaultStore.deploy(dns.address);
    eventEmitter = await EventEmitter.deploy(dns.address);

    //Set Address Registry
    await dns.setRoute("IDENTITY_CONTRACT", identityContract.address);
    await dns.setRoute("COMPANY_VAULT_STORE", companyVaultStore.address);
    await dns.setRoute("EVENT_EMITTER", eventEmitter.address);

    //Set Auth Permissions For C2C Calls
    await identityContract.activateDataAccess(addr1.address);
    await identityContract.connect(addr1).grantContractInteraction(identityContract.address, eventEmitter.address);
    await identityContract.connect(addr1).grantContractInteraction(addr1.address, companyVaultStore.address);

  });

  /**   
   * Calling deposit company tokens should throw an error
   */
  it("Update Company Balance SHould Update Company Balance", async () => {
    let companyId=1
    let amount = BigNumber.from("1000000000000000000");    

    await companyVaultStore.connect(addr1).updateCompanyTokenBalance(companyId, amount);

    expect(await companyVaultStore.getCompanyTokenBalance(companyId)).to.be.equal(amount.toString());

  });

  it("Update Company Vault Balance Should Update Company Vault Balance", async () => {
    let companyId=1
    let amount = BigNumber.from("1000000000000000000");    

    await companyVaultStore.connect(addr1).updateCompanyVaultBalance(companyId,  paymentToken.address, amount);

    expect(await companyVaultStore.getCompanyVaultBalance(companyId, paymentToken.address)).to.be.equal(amount.toString());
    

  });

  it("Update Company Vault Balance Should Add Suported Payment Option", async () => {
    let companyId=1
    let amount = BigNumber.from("1000000000000000000");    

    await companyVaultStore.connect(addr1).updateCompanyVaultBalance(companyId,  paymentToken.address, amount);

    expect(await companyVaultStore.isSupportedCompanyPaymentOption(companyId, paymentToken.address)).to.be.equal(true);  
  });

  
  it("Update Company Vault Balance Should Add Suported Payment Option With Only One Entry", async () => {
    let companyId=1
    let amount = BigNumber.from("1000000000000000000");    

    await companyVaultStore.connect(addr1).updateCompanyVaultBalance(companyId,  paymentToken.address, amount);
    await companyVaultStore.connect(addr1).updateCompanyVaultBalance(companyId,  paymentToken.address, amount.mul(2));


    expect(await companyVaultStore.getCompanyVaultBalance(companyId, paymentToken.address)).to.be.equal(amount.mul(2).toString());
    expect(await companyVaultStore.isSupportedCompanyPaymentOption(companyId, paymentToken.address)).to.be.equal(true);
    let supportedPaymentOptions = await companyVaultStore.getCompanyVaultBalanceCurrencies(companyId);
    expect(supportedPaymentOptions.length).to.be.equal(1);
  });

  it("Enable Payment Option Should Enable Payment Option", async () => {

    await companyVaultStore.connect(addr1).enablePaymentOption(paymentToken.address);

    expect(await companyVaultStore.isSupportedPaymentOption(paymentToken.address)).to.be.equal(true);  

    let supportedPaymentOptions = await companyVaultStore.getPaymentOptions();
    expect(supportedPaymentOptions.length).to.be.equal(1);  
    expect(supportedPaymentOptions[0]).to.be.equal(paymentToken.address);  
  });

  it("Enable Payment Option Multiple Times Only Creates One Supported Payment Option Entry", async () => {

    await companyVaultStore.connect(addr1).enablePaymentOption(paymentToken.address);
    await companyVaultStore.connect(addr1).enablePaymentOption(paymentToken.address);

    expect(await companyVaultStore.isSupportedPaymentOption(paymentToken.address)).to.be.equal(true);  
    let supportedPaymentOptions = await companyVaultStore.getPaymentOptions();
    expect(supportedPaymentOptions.length).to.be.equal(1);  
    expect(supportedPaymentOptions[0]).to.be.equal(paymentToken.address);  
  });

  it("Delete Payment Option Should Delete Payment Option Entry", async () => {

    await companyVaultStore.connect(addr1).enablePaymentOption(paymentToken.address);

    expect(await companyVaultStore.isSupportedPaymentOption(paymentToken.address)).to.be.equal(true);  
    let supportedPaymentOptions = await companyVaultStore.getPaymentOptions();
    expect(supportedPaymentOptions.length).to.be.equal(1);  
    expect(supportedPaymentOptions[0]).to.be.equal(paymentToken.address);  

    await companyVaultStore.connect(addr1).deletePaymentOption(paymentToken.address);

    expect(await companyVaultStore.isSupportedPaymentOption(paymentToken.address)).to.be.equal(false);  
    supportedPaymentOptions = await companyVaultStore.getPaymentOptions();
    expect(supportedPaymentOptions.length).to.be.equal(0);  
  });

  it("Delete Payment Option Should Revert For Already Deleted Payment Option", async () => {

    await companyVaultStore.connect(addr1).enablePaymentOption(paymentToken.address);

    expect(await companyVaultStore.isSupportedPaymentOption(paymentToken.address)).to.be.equal(true);  
    let supportedPaymentOptions = await companyVaultStore.getPaymentOptions();
    expect(supportedPaymentOptions.length).to.be.equal(1);  
    expect(supportedPaymentOptions[0]).to.be.equal(paymentToken.address);  

    await companyVaultStore.connect(addr1).deletePaymentOption(paymentToken.address);
    expect(await companyVaultStore.isSupportedPaymentOption(paymentToken.address)).to.be.equal(false);  
    supportedPaymentOptions = await companyVaultStore.getPaymentOptions();
    expect(supportedPaymentOptions.length).to.be.equal(0);  

    await expect(companyVaultStore.connect(addr1).deletePaymentOption(paymentToken.address)).to.be.revertedWith("Payment option not found");
  });





});