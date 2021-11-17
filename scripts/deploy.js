const hre = require("hardhat");
const { ethers } = hre;
const { BigNumber } = require("ethers");

async function main() {
  const DNS = await ethers.getContractFactory("DNS");
  const CompanyController = await ethers.getContractFactory("CompanyController");
  const InvestorController = await ethers.getContractFactory("InvestorController");
  const EventEmitter = await ethers.getContractFactory("EventEmitter");
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
  // const CompanyToken = await ethers.getContractFactory("companyToken");

  const dns = await DNS.deploy();

  const treasury = await Treasury.deploy();
  const identityContract = await IdentityContract.deploy(dns.address);
  const eventEmitter = await EventEmitter.deploy(dns.address);
  const nft = await QuidRaiseShares.deploy("", dns.address);
  const companyStore = await CompanyStore.deploy(dns.address);
  const investorStore = await InvestorStore.deploy(dns.address);
  const proposalStore = await ProposalStore.deploy(dns.address);
  const roundStore = await RoundStore.deploy(dns.address);
  const companyVaultStore = await CompanyVaultStore.deploy(dns.address);
  const companyVault = await CompanyVault.deploy(dns.address);
  const companyController = await CompanyController.deploy(dns.address);
  const investorController = await InvestorController.deploy(dns.address);
  // const companyToken = await CompanyToken.deploy(1000000)

  const config = await Config.deploy();

  console.log(`Identity Contract Address: ${identityContract.address}`);
  console.log(`Event Emitter Contract Address: ${eventEmitter.address}`);
  console.log(`Treasury Contract Address: ${treasury.address}`);
  console.log(`DNS Contract Address: ${dns.address}`);
  console.log(`NFT Contract Address: ${nft.address}`);
  console.log(`Company Store Contract Address: ${companyStore.address}`);
  console.log(`Investor Store Contract Address: ${investorStore.address}`);
  console.log(`Proposal Store Contract Address: ${proposalStore.address}`);
  console.log(`Round Store Contract Address: ${roundStore.address}`);
  console.log(`Company Vault Store Contract Address: ${companyVaultStore.address}`);
  console.log(`Company Vault Contract Address: ${companyVault.address}`);
  console.log(`Company Controller Contract Address: ${companyController.address}`);
  console.log(`Investor Controller Contract Address: ${investorController.address}`);
  console.log(`Config Contract Address: ${config.address}`);
  // console.log(`Company Token Address: ${companyToken.address}`);

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
  console.log("Routes Set Successfully");

  await config.setNumericConfig("MAX_ROUND_PAYMENT_OPTION", BigNumber.from("3"));
  await config.setNumericConfig("PLATFORM_COMMISION", BigNumber.from("1"));
  await config.setNumericConfig("PRECISION", BigNumber.from("100"));
  console.log("Config Set Successfully");

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

  console.log("Identity Access Grant Set Successfully");

  if (hre.network.name === "mainnet" || hre.network.name === "testnet") {
    await hre.run("verify:verify", {
      address: quidRaise.address,
      constructorArguments: [],
    });
  } else {
    console.log("Contracts deployed to", hre.network.name, "network. Please verify them manually.");
  }
}
main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
