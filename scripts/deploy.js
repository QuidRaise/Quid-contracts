const hre = require("hardhat");
const { ethers } = hre;
const { BigNumber } = require('ethers');


async function main() {

  const DNS = await ethers.getContractFactory("DNS");
  const CompanyController = await ethers.getContractFactory("CompanyController");
  const InvestorController = await ethers.getContractFactory("InvestorController");
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


  const dns = await DNS.deploy();

  const treasury = await Treasury.deploy();
  const identityContract = await IdentityContract.deploy(dns.address);
  const eventEmitter = await EventEmitter.deploy(dns.address)
  const nft = await QuidRaiseShares.deploy("",dns.address)
  const companyStore = await CompanyStore.deploy(dns.address)
  const investorStore = await InvestorStore.deploy(dns.address)
  const proposalStore = await ProposalStore.deploy(dns.address)
  const roundStore = await RoundStore.deploy(dns.address)
  const companyVaultStore = await CompanyVaultStore.deploy(dns.address)
  const companyVault = await CompanyVault.deploy(dns.address)
  const config = await Config.deploy()


  dns.setRoute("IDENTITY_CONTRACT", identityContract.address);
  dns.setRoute("EVENT_EMITTER", eventEmitter.address);
  dns.setRoute("COMPANY_VAULT_STORE", companyVaultStore.address);
  dns.setRoute("COMPANY_VAULT", companyVault.address);
  dns.setRoute("COMPANY_STORE", companyStore.address);
  dns.setRoute("INVESTOR_STORE", investorStore.address);
  dns.setRoute("PROPOSAL_STORE", proposalStore.address);
  dns.setRoute("ROUND_STORE", roundStore.address);
  dns.setRoute("NFT", nft.address);
  dns.setRoute("CONFIG", config.address);




  config.setConfig("MAX_ROUND_PAYMENT_OPTION", BigNumber.from("3"));
  config.setConfig("PLATFORM_COMMISION", BigNumber.from("1"));
  config.setConfig("MAX_ROUND_PAYMENT_OPTION", BigNumber.from("100"));





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
  console.log(`Config Contract Address: ${config.address}`);















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
