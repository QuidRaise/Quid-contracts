const { expect, use } = require("chai");
const { ethers, deployments } = require("hardhat");
const { BigNumber } = require("ethers");
const { solidity, loadFixture, deployContract } = require("ethereum-waffle");

use(solidity);

return;

function getCurrentTimeStamp()
{
  var timeStamp = Math.floor(Date.now() / 1000);
  return timeStamp;
}

describe("Proxy Controller Tests", function () {
  beforeEach(async () => {
    
  [deployer, companyOwner, companyOwner2, investor] = await ethers.getSigners();

  const DNS = await ethers.getContractFactory("DNS");
  const CompanyController = await ethers.getContractFactory("CompanyController");
  const CompanyRoundController = await ethers.getContractFactory("CompanyRoundController");
  const CompanyProposalController = await ethers.getContractFactory("CompanyProposalController");
  const InvestorController = await ethers.getContractFactory("InvestorController");
  const CompanyProxy = await ethers.getContractFactory("CompanyProxy");
  const InvestorProxy = await ethers.getContractFactory("InvestorProxy");
  const EventEmitter = await ethers.getContractFactory("EventEmitter",);
  const IdentityContract = await ethers.getContractFactory("IdentityContract");
  const QuidRaiseShares = await ethers.getContractFactory("QuidRaiseShares");
  const CompanyStore = await ethers.getContractFactory("CompanyStore");
  const InvestorStore = await ethers.getContractFactory("InvestorStore");
  const ProposalStore = await ethers.getContractFactory("ProposalStore");
  const RoundStore = await ethers.getContractFactory("RoundStore");
  const CompanyVaultStore = await ethers.getContractFactory("CompanyVaultStore");
  const CompanyVault = await ethers.getContractFactory("CompanyVault");
  const Config = await ethers.getContractFactory("Config");
  const Treasury = await ethers.getContractFactory("Treasury");

  dns = await DNS.deploy();
  companyRoundController = await CompanyRoundController.deploy(dns.address)
  companyProposalController = await CompanyProposalController.deploy(dns.address)
  companyController = await CompanyController.deploy(dns.address)
  investorController = await InvestorController.deploy(dns.address)
  treasury = await Treasury.deploy();
  identityContract = await IdentityContract.deploy(dns.address);
  eventEmitter = await EventEmitter.deploy(dns.address)
  nft = await QuidRaiseShares.deploy("", dns.address)
  companyStore = await CompanyStore.deploy(dns.address)
  investorStore = await InvestorStore.deploy(dns.address)
  proposalStore = await ProposalStore.deploy(dns.address)
  roundStore = await RoundStore.deploy(dns.address)
  companyVaultStore = await CompanyVaultStore.deploy(dns.address)
  companyVault = await CompanyVault.deploy(dns.address)
 
  companyProxy = await CompanyProxy.deploy(dns.address)
  investorProxy = await InvestorProxy.deploy(dns.address)

  config = await Config.deploy()

  await dns.setRoute("IDENTITY_CONTRACT", identityContract.address);
  await dns.setRoute("EVENT_EMITTER", eventEmitter.address);
  await dns.setRoute("COMPANY_VAULT_STORE", companyVaultStore.address);
  await dns.setRoute("COMPANY_VAULT", companyVault.address);
  await dns.setRoute("COMPANY_STORE", companyStore.address);
  await dns.setRoute("INVESTOR_STORE", investorStore.address);
  await dns.setRoute("PROPOSAL_STORE", proposalStore.address);
  await dns.setRoute("ROUND_STORE", roundStore.address);
  await dns.setRoute("NFT", nft.address);
  await dns.setRoute("CONFIG", config.address);
  await dns.setRoute("COMPANY_CONTROLLER", companyController.address);
  await dns.setRoute("COMPANY_ROUND_CONTROLLER", companyRoundController.address);
  await dns.setRoute("COMPANY_PROPOSAL_CONTROLLER", companyProposalController.address);

  await dns.setRoute("INVESTOR_CONTROLLER", investorController.address);  

  // console.log("Routes Set Successfully");



  await config.setNumericConfig("MAX_ROUND_PAYMENT_OPTION", BigNumber.from("4"));
  await config.setNumericConfig("PLATFORM_COMMISION", BigNumber.from("1"));
  await config.setNumericConfig("PRECISION", BigNumber.from("100"));
  await config.setNumericConfig("VOTE_DURATION", BigNumber.from("600"));

  // console.log("Config Set Successfully");

  await identityContract.activateDataAccess(companyController.address); 
  await identityContract.activateDataAccess(investorController.address); 
  await identityContract.activateDataAccess(deployer.address);

  await identityContract.grantContractInteraction(identityContract.address, eventEmitter.address)
  await identityContract.grantContractInteraction(companyController.address, eventEmitter.address)
  await identityContract.grantContractInteraction(companyController.address, config.address)
  await identityContract.grantContractInteraction(companyController.address, identityContract.address)
  await identityContract.grantContractInteraction(companyController.address, companyVaultStore.address)
  await identityContract.grantContractInteraction(companyController.address, roundStore.address)
  await identityContract.grantContractInteraction(companyController.address, proposalStore.address)
  await identityContract.grantContractInteraction(companyController.address, investorStore.address)
  await identityContract.grantContractInteraction(companyController.address, companyStore.address)
  await identityContract.grantContractInteraction(companyController.address, companyVault.address)

  await identityContract.grantContractInteraction(companyRoundController.address, eventEmitter.address)
  await identityContract.grantContractInteraction(companyRoundController.address, config.address)
  await identityContract.grantContractInteraction(companyRoundController.address, identityContract.address)
  await identityContract.grantContractInteraction(companyRoundController.address, companyVaultStore.address)
  await identityContract.grantContractInteraction(companyRoundController.address, roundStore.address)
  await identityContract.grantContractInteraction(companyRoundController.address, proposalStore.address)
  await identityContract.grantContractInteraction(companyRoundController.address, investorStore.address)
  await identityContract.grantContractInteraction(companyRoundController.address, companyStore.address)
  await identityContract.grantContractInteraction(companyRoundController.address, companyVault.address)


  await identityContract.grantContractInteraction(companyProposalController.address, eventEmitter.address)
  await identityContract.grantContractInteraction(companyProposalController.address, config.address)
  await identityContract.grantContractInteraction(companyProposalController.address, identityContract.address)
  await identityContract.grantContractInteraction(companyProposalController.address, companyVaultStore.address)
  await identityContract.grantContractInteraction(companyProposalController.address, roundStore.address)
  await identityContract.grantContractInteraction(companyProposalController.address, proposalStore.address)
  await identityContract.grantContractInteraction(companyProposalController.address, investorStore.address)
  await identityContract.grantContractInteraction(companyProposalController.address, companyStore.address)
  await identityContract.grantContractInteraction(companyProposalController.address, companyVault.address)



  await identityContract.grantContractInteraction(investorController.address, companyVault.address)
  await identityContract.grantContractInteraction(companyVault.address, companyVaultStore.address)
  await identityContract.grantContractInteraction(investorController.address, companyVaultStore.address)
  await identityContract.grantContractInteraction(investorController.address, roundStore.address)
  await identityContract.grantContractInteraction(investorController.address, nft.address)
  await identityContract.grantContractInteraction(investorController.address, identityContract.address)
  await identityContract.grantContractInteraction(investorController.address, eventEmitter.address)

  await identityContract.grantContractInteraction(investorController.address, proposalStore.address)
  await identityContract.grantContractInteraction(investorController.address, investorStore.address)
  await identityContract.grantContractInteraction(investorController.address, companyStore.address)
 
  await identityContract.grantContractInteraction(companyProxy.address, companyController.address);
  await identityContract.grantContractInteraction(companyProxy.address, companyProposalController.address);
  await identityContract.grantContractInteraction(companyProxy.address, companyRoundController.address);

  await identityContract.grantContractInteraction(investorProxy.address, investorController.address);

  await companyProxy.activateDataAccess(deployer.address);



  // DEPLOY PAYMENT OPTIONS
  const Contract = await ethers.getContractFactory("ERC20Token");
  companyToken = await Contract.deploy("LazerPay", "LP");
  companyToken2 = await Contract.deploy("Wicrypt", "WNT");

  // SEND TOKENS TO COMPANY OWNERS TO USE IN CREATING ROUNDS
  await companyToken.transfer(companyOwner.address, BigNumber.from("31000000000000000000000000"))
  await companyToken2.transfer(companyOwner2.address, BigNumber.from("31000000000000000000000000"))

  const usdtContract = await ethers.getContractFactory("ERC20Token");
  Usdt = await usdtContract.deploy("USDT tether", "USDT");

  const daiContract = await ethers.getContractFactory("ERC20Token");
  Dai = await daiContract.deploy("DAI Token", "DAI");

  const busdContract = await ethers.getContractFactory("ERC20Token");
  Busd = await busdContract.deploy("Binance BUSD", "BUSD");

  const USDContract = await ethers.getContractFactory("ERC20Token");
  Usdc = await USDContract.deploy("USDC", "USDC");



  await Usdt.transfer(investor.address, BigNumber.from("31000000000000000000000000"))
  await Dai.transfer(investor.address, BigNumber.from("31000000000000000000000000"))
  await Busd.transfer(investor.address, BigNumber.from("31000000000000000000000000"))
  await Usdc.transfer(investor.address, BigNumber.from("31000000000000000000000000"))


  await companyVaultStore.enablePaymentOption(Usdt.address);
  await companyVaultStore.enablePaymentOption(Dai.address);
  await companyVaultStore.enablePaymentOption(Busd.address);
  await companyVaultStore.enablePaymentOption(Usdc.address);


  });

  it("should createCompany", async function () {

    const companyUrl =  "https://www.lazerpay.finance/";
    const companyName = "Lazer Pay";
    

    await expect(companyProxy
      .connect(deployer)
      .createCompany(companyUrl, companyName, companyToken.address, companyOwner.address))
      .to.emit(eventEmitter, "CompanyCreated")
         .withArgs
         (
           1,
           companyOwner.address,
           deployer.address,
           companyName,
           companyUrl,
           companyToken.address
         );


  });

  it("should create round", async function () {

    const companyUrl =  "https://www.lazerpay.finance/";
    const companyName = "Lazer Pay";
    const roundDocumentUrl = "https://cdn.invictuscapital.com/reports/2021_QR3.pdf"
    const tokensSuppliedForRound  = BigNumber.from("10000000000000000000000");
    const startTimestamp = getCurrentTimeStamp();
    const duration = BigNumber.from("1296000");
    const lockupPeriod = BigNumber.from("1000");
    const paymentCurrencies = [ Usdt.address, Dai.address, Busd.address, Usdc.address ];
    const pricePerShare = [ BigNumber.from("1000000000000000000"), BigNumber.from("1000000000000000000"), BigNumber.from("1000000000000000000"), BigNumber.from("1000000000000000000") ];
    const runTillFullySubscribed = false;
    
    await expect(companyProxy
      .connect(deployer)
      .createCompany(companyUrl, companyName, companyToken.address, companyOwner.address))
      .to.emit(eventEmitter, "CompanyCreated")
         .withArgs
         (
           1,
           companyOwner.address,
           deployer.address,
           companyName,
           companyUrl,
           companyToken.address
         );

    await companyToken.connect(companyOwner).approve(companyRoundController.address,tokensSuppliedForRound)


    
    await expect(companyProxy
      .connect(companyOwner)
      .createRound(roundDocumentUrl, startTimestamp, duration, lockupPeriod, tokensSuppliedForRound, runTillFullySubscribed, paymentCurrencies, pricePerShare))
      .to.emit(eventEmitter, "RoundCreated")
         .withArgs(
            1,
            1,
            companyOwner.address,
            lockupPeriod,
            tokensSuppliedForRound,
            startTimestamp,
            duration,
            runTillFullySubscribed,
            paymentCurrencies,
            pricePerShare
         ) ;

    
  });

  it("should create round that will run till fully subscribed", async function () {

    const companyUrl =  "https://www.lazerpay.finance/";
    const companyName = "Lazer Pay";
    const roundDocumentUrl = "https://cdn.invictuscapital.com/reports/2021_QR3.pdf"
    const tokensSuppliedForRound  = BigNumber.from("10000000000000000000000");
    const startTimestamp = getCurrentTimeStamp();
    const duration = BigNumber.from("1");
    const lockupPeriod = BigNumber.from("1000");
    const paymentCurrencies = [ Usdt.address, Dai.address, Busd.address, Usdc.address ];
    const pricePerShare = [ BigNumber.from("1000000000000000000"), BigNumber.from("1000000000000000000"), BigNumber.from("1000000000000000000"), BigNumber.from("1000000000000000000") ];
    const runTillFullySubscribed = true;
    
    await expect(companyProxy
      .connect(deployer)
      .createCompany(companyUrl, companyName, companyToken.address, companyOwner.address))
      .to.emit(eventEmitter, "CompanyCreated")
         .withArgs
         (
           1,
           companyOwner.address,
           deployer.address,
           companyName,
           companyUrl,
           companyToken.address
         );

         
  await companyToken.connect(companyOwner).approve(companyRoundController.address,tokensSuppliedForRound)
    
    await expect(companyProxy
      .connect(companyOwner)
      .createRound(roundDocumentUrl, startTimestamp, duration, lockupPeriod, tokensSuppliedForRound, runTillFullySubscribed, paymentCurrencies, pricePerShare))
      .to.emit(eventEmitter, "RoundCreated")
         .withArgs(
            1,
            1,
            companyOwner.address,
            lockupPeriod,
            tokensSuppliedForRound,
            startTimestamp,
            duration,
            runTillFullySubscribed,
            paymentCurrencies,
            pricePerShare
         ) ;
  });

  it("should invest in round", async function () {

    const companyUrl =  "https://www.lazerpay.finance/";
    const companyName = "Lazer Pay";
    const roundDocumentUrl = "https://cdn.invictuscapital.com/reports/2021_QR3.pdf"
    const tokensSuppliedForRound  = BigNumber.from("10000000000000000000000");
    const startTimestamp = getCurrentTimeStamp();
    const duration = BigNumber.from("1296000");
    const lockupPeriod = BigNumber.from("1000");
    const paymentCurrencies = [ Usdt.address, Dai.address, Busd.address, Usdc.address ];
    const pricePerShare = [ BigNumber.from("1000000000000000000"), BigNumber.from("1000000000000000000"), BigNumber.from("1000000000000000000"), BigNumber.from("1000000000000000000") ];
    const runTillFullySubscribed = false;
    const amountInvested = BigNumber.from("5000000000000000000000");
    const expectedTokenQuantityPurchased = BigNumber.from("5000000000000000000000");
    
    await expect(companyProxy
      .connect(deployer)
      .createCompany(companyUrl, companyName, companyToken.address, companyOwner.address))
      .to.emit(eventEmitter, "CompanyCreated")
         .withArgs
         (
           1,
           companyOwner.address,
           deployer.address,
           companyName,
           companyUrl,
           companyToken.address
         );

    await companyToken.connect(companyOwner).approve(companyRoundController.address,tokensSuppliedForRound)


    
    await expect(companyProxy
      .connect(companyOwner)
      .createRound(roundDocumentUrl, startTimestamp, duration, lockupPeriod, tokensSuppliedForRound, runTillFullySubscribed, paymentCurrencies, pricePerShare))
      .to.emit(eventEmitter, "RoundCreated")
         .withArgs(
            1,
            1,
            companyOwner.address,
            lockupPeriod,
            tokensSuppliedForRound,
            startTimestamp,
            duration,
            runTillFullySubscribed,
            paymentCurrencies,
            pricePerShare
         ) ;

    await Usdt.connect(investor).approve(investorController.address,amountInvested)

    await expect(investorProxy.connect(investor).investInRound(1,Usdt.address))
          .to.emit(eventEmitter, "InvestmentDeposit")
          .withArgs(
            1,
            1,
            investor.address,
            Usdt.address,
            amountInvested,
            expectedTokenQuantityPurchased
          );

    let record = await roundStore.getRound(1);
   
    // let investmentVaultContract = await ethers.getContractAt("ERC20Token",record.TokenLockVaultAddres);

    expect(await companyToken.balanceOf(record.TokenLockVaultAddres)).to.equal(expectedTokenQuantityPurchased);
    expect(await nft.balanceOf(investor.address, 1)).to.equal(expectedTokenQuantityPurchased);    
  });

  
  it("should invest in round and prevent others from investing", async function () {

    const companyUrl =  "https://www.lazerpay.finance/";
    const companyName = "Lazer Pay";
    const roundDocumentUrl = "https://cdn.invictuscapital.com/reports/2021_QR3.pdf"
    const tokensSuppliedForRound  = BigNumber.from("10000000000000000000000");
    const startTimestamp = getCurrentTimeStamp();
    const duration = BigNumber.from("1296000");
    const lockupPeriod = BigNumber.from("1000");
    const paymentCurrencies = [ Usdt.address, Dai.address, Busd.address, Usdc.address ];
    const pricePerShare = [ BigNumber.from("1000000000000000000"), BigNumber.from("1000000000000000000"), BigNumber.from("1000000000000000000"), BigNumber.from("1000000000000000000") ];
    const runTillFullySubscribed = false;
    const amountInvested = BigNumber.from("10000000000000000000000");
    const expectedTokenQuantityPurchased = BigNumber.from("10000000000000000000000");
    
    await expect(companyProxy
      .connect(deployer)
      .createCompany(companyUrl, companyName, companyToken.address, companyOwner.address))
      .to.emit(eventEmitter, "CompanyCreated")
         .withArgs
         (
           1,
           companyOwner.address,
           deployer.address,
           companyName,
           companyUrl,
           companyToken.address
         );

    await companyToken.connect(companyOwner).approve(companyRoundController.address,tokensSuppliedForRound)


    
    await expect(companyProxy
      .connect(companyOwner)
      .createRound(roundDocumentUrl, startTimestamp, duration, lockupPeriod, tokensSuppliedForRound, runTillFullySubscribed, paymentCurrencies, pricePerShare))
      .to.emit(eventEmitter, "RoundCreated")
         .withArgs(
            1,
            1,
            companyOwner.address,
            lockupPeriod,
            tokensSuppliedForRound,
            startTimestamp,
            duration,
            runTillFullySubscribed,
            paymentCurrencies,
            pricePerShare
         ) ;

    await Usdt.connect(investor).approve(investorController.address,amountInvested)

    await expect(investorProxy.connect(investor).investInRound(1,Usdt.address))
          .to.emit(eventEmitter, "InvestmentDeposit")
          .withArgs(
            1,
            1,
            investor.address,
            Usdt.address,
            amountInvested,
            expectedTokenQuantityPurchased
          );

    let record = await roundStore.getRound(1);
   
    // let investmentVaultContract = await ethers.getContractAt("ERC20Token",record.TokenLockVaultAddres);

    expect(await companyToken.balanceOf(record.TokenLockVaultAddres)).to.equal(expectedTokenQuantityPurchased);
    expect(await nft.balanceOf(investor.address, 1)).to.equal(expectedTokenQuantityPurchased);    

    await Usdt.connect(investor).approve(investorController.address,amountInvested)

    await expect(investorProxy.connect(investor).investInRound(1,Usdt.address))
          .to.be.revertedWith("Round is fully subscribed");  
    
  });



})

