const { expect } = require("chai");
const { ethers, deployments } = require("hardhat");
const { BigNumber } = require("ethers");

describe("Deployment of Contracts", function () {
  before(async () => {
    [tester, addr1, addr2, addr3] = await ethers.getSigners();
    DNS = await ethers.getContractFactory("DNS");
    CompanyController = await ethers.getContractFactory("CompanyController");
    InvestorController = await ethers.getContractFactory("InvestorController");
    CompanyProxy = await ethers.getContractFactory("CompanyProxy");
    InvestorProxy = await ethers.getContractFactory("InvestorProxy");
    EventEmitter = await ethers.getContractFactory("EventEmitter");
    IdentityContract = await ethers.getContractFactory("IdentityContract");
    QuidRaiseShares = await ethers.getContractFactory("QuidRaiseShares");
    CompanyStore = await ethers.getContractFactory("CompanyStore");
    InvestorStore = await ethers.getContractFactory("InvestorStore");
    ProposalStore = await ethers.getContractFactory("ProposalStore");
    RoundStore = await ethers.getContractFactory("RoundStore");
    CompanyVaultStore = await ethers.getContractFactory("CompanyVaultStore");
    CompanyVault = await ethers.getContractFactory("CompanyVault");
    Config = await ethers.getContractFactory("Config");
    Treasury = await ethers.getContractFactory("Treasury");

    dns = await DNS.deploy();

    treasury = await Treasury.deploy();
    identityContract = await IdentityContract.deploy(dns.address);
    eventEmitter = await EventEmitter.deploy(dns.address);
    nft = await QuidRaiseShares.deploy("", dns.address);
    companyStore = await CompanyStore.deploy(dns.address);
    investorStore = await InvestorStore.deploy(dns.address);
    proposalStore = await ProposalStore.deploy(dns.address);
    roundStore = await RoundStore.deploy(dns.address);
    companyVaultStore = await CompanyVaultStore.deploy(dns.address);
    companyVault = await CompanyVault.deploy(dns.address);
    companyController = await CompanyController.deploy(dns.address);
    investorController = await InvestorController.deploy(dns.address);
    companyProxy = await CompanyProxy.deploy(dns.address)
    investorProxy = await InvestorProxy.deploy(dns.address)

    config = await Config.deploy();
  });

  it("should set the contracts routes", async () => {
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
    await dns.setRoute("INVESTOR_CONTROLLER", investorController.address);
  });

  it("should set the configurations", async () => {
    await config.setNumericConfig("MAX_ROUND_PAYMENT_OPTION", BigNumber.from("3"));
    await config.setNumericConfig("PLATFORM_COMMISION", BigNumber.from("1"));
    await config.setNumericConfig("PRECISION", BigNumber.from("100"));
  });

  it("should grant access to contracts ", async () => {
    await identityContract.activateDataAccess(companyController.address);
    await identityContract.activateDataAccess(tester.address);
    await identityContract.grantContractInteraction(identityContract.address, eventEmitter.address)
    await identityContract.grantContractInteraction(companyController.address, eventEmitter.address)
    await identityContract.grantContractInteraction(investorController.address, eventEmitter.address)
    await identityContract.grantContractInteraction(companyController.address, config.address)
    await identityContract.grantContractInteraction(companyController.address, identityContract.address)
    await identityContract.grantContractInteraction(investorController.address, identityContract.address)

    await identityContract.grantContractInteraction(companyController.address, companyVault.address)
    await identityContract.grantContractInteraction(investorController.address, companyVault.address)
    await identityContract.grantContractInteraction(companyVault.address, companyVaultStore.address)
    await identityContract.grantContractInteraction(companyController.address, companyVaultStore.address)
    await identityContract.grantContractInteraction(investorController.address, companyVaultStore.address)
    await identityContract.grantContractInteraction(investorController.address, roundStore.address)
    await identityContract.grantContractInteraction(investorController.address, nft.address)

    await identityContract.grantContractInteraction(investorController.address, proposalStore.address)
    await identityContract.grantContractInteraction(investorController.address, investorStore.address)
    await identityContract.grantContractInteraction(investorController.address, companyStore.address)
    await identityContract.grantContractInteraction(companyController.address, roundStore.address)
    await identityContract.grantContractInteraction(companyController.address, proposalStore.address)
    await identityContract.grantContractInteraction(companyController.address, investorStore.address)
    await identityContract.grantContractInteraction(companyController.address, companyStore.address)
    await identityContract.grantContractInteraction(companyProxy.address, companyController.address);
    await identityContract.grantContractInteraction(investorProxy.address, investorController.address);
  });
});

let createCompany, companyToken, Usdt, Dai, Busd, Usdc;

describe("Company Controller Contract", function () {
  before(async () => {
    await identityContract.grantContractInteraction(tester.address, companyController.address);
    await identityContract.activateDataAcess(companyController.address);
    await identityContract.grantContractInteraction(tester.address, investorStore.address);
    await identityContract.activateDataAcess(investorStore.address);
    await identityContract.grantContractInteraction(tester.address, companyController.address);
    await companyProxy.activateDataAccess(tester.address);

    // DEPLOY PAYMENT OPTIONS
    const Contract = await ethers.getContractFactory("companyToken");
    companyToken = await Contract.deploy();

    const usdtContract = await ethers.getContractFactory("USDT");
    Usdt = await usdtContract.deploy();

    const daiContract = await ethers.getContractFactory("DAI");
    Dai = await daiContract.deploy();

    const busdContract = await ethers.getContractFactory("BUSD");
    Busd = await busdContract.deploy();

    const USDContract = await ethers.getContractFactory("USDC");
    Usdc = await USDContract.deploy();

    // ENABLE PAYMENT OPTIONS
    await companyVaultStore.enablePaymentOption(Usdt.address);
    await companyVaultStore.enablePaymentOption(Dai.address);
    await companyVaultStore.enablePaymentOption(Busd.address);
    await companyVaultStore.enablePaymentOption(Usdc.address);

    // CREATE NEW COMPANY
    COMPANY_URL = "https://quidraise.co";
    COMPANY_NAME = "Quid Raise";
    COMPANY_OWNER = tester.address;
    COMPANY_CREATED_BY = tester.address;
    COMPANY_TOKEN_CONTRACT_ADDRESS = companyToken.address;

    createCompany = await companyController
      .connect(tester)
      .createCompany(COMPANY_URL, COMPANY_NAME, COMPANY_TOKEN_CONTRACT_ADDRESS, COMPANY_OWNER, COMPANY_CREATED_BY);

    // CREATE NEW ROUND
    companyOwner = COMPANY_OWNER;
    roundDocumentUrl = "https://whitepaper.quidraise.co";
    startTimestamp = Date.now();
    duration = 172800; // two days
    lockupPeriodForShare = 604800; // one week
    tokensSuppliedForRound = 20000;
    runTillFullySubscribed = true;
    paymentCurrencies = [Usdt.address, Dai.address];
    pricePerShare = [100, 100];
  });

  describe("createCompany function", () => {
    it("should emit event if company was created successfully", async function () {
      expect(createCompany).to.emit(eventEmitter, "CompanyCreated");
    });

    it("should fail if company owner already owns a business", async () => {
      await expect(
        companyController.connect(tester).createCompany(COMPANY_URL, COMPANY_NAME, COMPANY_TOKEN_CONTRACT_ADDRESS, COMPANY_OWNER, COMPANY_CREATED_BY),
      ).to.be.revertedWith("Company owner already owns a business");
    });

    it("should fail if company owner is already an investor", async () => {
      let isInvestor = await investorStore.connect(tester).isInvestor(COMPANY_OWNER);
      expect(isInvestor).to.equal(false);
    });

    it("should ensure company owner is whitelisted", async () => {
      let companyOwnerIsWhitelisted = await identityContract.isCompanyAddressWhitelisted(COMPANY_OWNER);
      expect(companyOwnerIsWhitelisted).to.equal(true);
    });

    it("should ensure company is whitelisted", async () => {
      let companyIsWhitelisted = await identityContract.isCompanyWhitelisted(1);
      expect(companyIsWhitelisted).to.equal(true);
    });
  });

  describe("createRound function", () => {
    before(async () => {});

    it("should fail if payment options exceed the max round payment option", async () => {
      let paymentCurrencies = [Usdt.address, Dai.address, Busd.address, Usdc.address];
      let pricePerShare = [100, 100, 100, 100];
      await expect(
        companyController
          .connect(tester)
          .createRound(
            companyOwner,
            roundDocumentUrl,
            startTimestamp,
            duration,
            lockupPeriodForShare,
            tokensSuppliedForRound,
            runTillFullySubscribed,
            paymentCurrencies,
            pricePerShare,
          ),
      ).to.be.revertedWith("Exceeded number of payment options");
    });

    it("should fail if price per share is zero", async () => {
      let pricePerShare = [0, 0, 0, 0];
      await expect(
        companyController
          .connect(tester)
          .createRound(
            companyOwner,
            roundDocumentUrl,
            startTimestamp,
            duration,
            lockupPeriodForShare,
            tokensSuppliedForRound,
            runTillFullySubscribed,
            paymentCurrencies,
            pricePerShare,
          ),
      ).to.be.revertedWith("Price per share cannot be zero");
    });

    it("should fail if input data is invaild", async () => {
      let startTimestamp = 0,
        duration = 0,
        tokensSuppliedForRound = 0,
        paymentCurrencies = [],
        pricePerShare = [];

      await expect(
        companyController
          .connect(tester)
          .createRound(
            companyOwner,
            roundDocumentUrl,
            startTimestamp,
            duration,
            lockupPeriodForShare,
            tokensSuppliedForRound,
            runTillFullySubscribed,
            paymentCurrencies,
            pricePerShare,
          ),
      ).to.be.revertedWith("Contract input data is invalid");
    });
    it("should fail if round creator is not a company owner", async () => {
      let companyOwner = addr1.address;
      await expect(
        companyController
          .connect(tester)
          .createRound(
            companyOwner,
            roundDocumentUrl,
            startTimestamp,
            duration,
            lockupPeriodForShare,
            tokensSuppliedForRound,
            runTillFullySubscribed,
            paymentCurrencies,
            pricePerShare,
          ),
      ).to.be.revertedWith("Could not find a company owned by this user");
    });
    it("should get company details by company owner address", async () => {
      let companyByOwner = await companyStore.callStatic.getCompanyByOwner(companyOwner);
      expect(companyByOwner.CompanyName).to.equal("Quid Raise");
    });

    it("should ensure company is whitelisted", async () => {
      let companyIsWhitelisted = await identityContract.isCompanyWhitelisted(1);
      expect(companyIsWhitelisted).to.equal(true);
    });

    it("should ensure company owner is whitelisted", async () => {
      let companyOwnerIsWhitelisted = await identityContract.isCompanyAddressWhitelisted(COMPANY_OWNER);
      expect(companyOwnerIsWhitelisted).to.equal(true);
    });

    it("should fail if company has an open round", async () => {
      // let companyid = await companyStore.getCompanyById(1);
      // console.log(companyid);
      await companyToken.approve(companyController.address, BigNumber.from("20000"));
      let createRound = await companyController
        .connect(tester)
        .createRound(
          companyOwner,
          roundDocumentUrl,
          startTimestamp,
          duration,
          lockupPeriodForShare,
          tokensSuppliedForRound,
          runTillFullySubscribed,
          paymentCurrencies,
          pricePerShare,
        );
      console.log(createRound);
    });
  });
});
