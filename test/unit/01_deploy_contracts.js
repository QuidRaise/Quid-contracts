const { ethers } = require("hardhat");
const { BigNumber } = require("ethers");

// export function deploy() {
describe("Deployment of contracts", function () {
  before(async () => {
    DNS = await ethers.getContractFactory("DNS");
    CompanyController = await ethers.getContractFactory("CompanyController");
    InvestorController = await ethers.getContractFactory("InvestorController");
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

    config = await Config.deploy();


    module.exports = { dns, companyController };
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
    await config.setNumericConfig("MAX_ROUND_PAYMENT_OPTION", BigNumber.from("100"));
  });

  it("should grant access to contracts ", async () => {
    await identityContract.grantContractInteraction(identityContract.address, eventEmitter.address);
    await identityContract.grantContractInteraction(companyController.address, eventEmitter.address);
    await identityContract.grantContractInteraction(investorController.address, eventEmitter.address);
    await identityContract.grantContractInteraction(companyController.address, config.address);
    await identityContract.grantContractInteraction(companyController.address, identityContract.address);
    await identityContract.grantContractInteraction(companyController.address, companyVault.address);
    await identityContract.grantContractInteraction(investorController.address, companyVault.address);
    await identityContract.grantContractInteraction(companyVault.address, companyVaultStore.address);
    await identityContract.grantContractInteraction(companyController.address, companyVaultStore.address);
    await identityContract.grantContractInteraction(investorController.address, companyVaultStore.address);
    await identityContract.grantContractInteraction(investorController.address, roundStore.address);
    await identityContract.grantContractInteraction(investorController.address, proposalStore.address);
    await identityContract.grantContractInteraction(investorController.address, investorStore.address);
    await identityContract.grantContractInteraction(investorController.address, companyStore.address);
    await identityContract.grantContractInteraction(companyController.address, roundStore.address);
    await identityContract.grantContractInteraction(companyController.address, proposalStore.address);
    await identityContract.grantContractInteraction(companyController.address, investorStore.address);
    await identityContract.grantContractInteraction(companyController.address, companyStore.address);

  });
});

// }
