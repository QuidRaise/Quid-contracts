const hre = require("hardhat");
const { ethers } = hre;
const { BigNumber } = require('ethers');


async function main() {

  [deployer, companyOwner, companyOwner2, investor] = await ethers.getSigners();

  const InvestorController = await ethers.getContractFactory("InvestorController"); 
  const QuidRaiseShares = await ethers.getContractFactory("QuidRaiseShares");


  const dns = await ethers.getContractAt("DNS","0x25EbF1F0F1f656FB43Ab3b922e715Ea2EBf73273");
  const identityContract = await ethers.getContractAt("IdentityContract", "0x07A7F11A40633E7e851C819526F2450d6CFB113C");
  const eventEmitter = await ethers.getContractAt("EventEmitter", "0x7703DD225043316FE191e5ed4d98561c773252A9");
  const companyStore = await ethers.getContractAt("CompanyStore", "0xFA886005dB1d8c9bf9cDb02c95a17320C7de8792");
  const investorStore = await ethers.getContractAt("InvestorStore", "0x8788B74b80780F3Fbd08008861481378ff7f2C10");
  const proposalStore = await ethers.getContractAt("ProposalStore", "0x6D7e8c7689678BD320DC62d08F46304bEbA38f76");
  const roundStore = await ethers.getContractAt("RoundStore","0xa2CE4c230fa1CF7f567f85aF06C28b5D75091CF7");
  const companyVaultStore = await ethers.getContractAt("CompanyVaultStore", "0x28433F2Cdb4A52BB3c7f34Ba856e87D899715eb7");
  const companyVault = await ethers.getContractAt("CompanyVault", "0x7c729CCdc265a73359f54FF79DEd62D715D641d7");
  const investorProxy = await ethers.getContractAt("InvestorProxy","0x2Ad39f790d186d802BA600357D7f56B19334F182");

  const nft = await QuidRaiseShares.deploy("", dns.address)
  const investorController = await InvestorController.deploy(dns.address)


  console.log(`nft Contract Address: ${nft.address}`);

  console.log(`Investor Controller Contract Address: ${investorController.address}`);


  await dns.setRoute("NFT", nft.address);  
  await dns.setRoute("INVESTOR_CONTROLLER", investorController.address);  
  console.log("Routes Set Successfully");

  await identityContract.activateDataAccess(investorController.address); 

  await identityContract.grantContractInteraction(investorController.address, companyVault.address)
  await identityContract.grantContractInteraction(investorController.address, companyVaultStore.address)
  await identityContract.grantContractInteraction(investorController.address, roundStore.address)
  await identityContract.grantContractInteraction(investorController.address, nft.address)
  await identityContract.grantContractInteraction(investorController.address, identityContract.address)
  await identityContract.grantContractInteraction(investorController.address, eventEmitter.address)
  await identityContract.grantContractInteraction(investorController.address, proposalStore.address)
  await identityContract.grantContractInteraction(investorController.address, investorStore.address)
  await identityContract.grantContractInteraction(investorController.address, companyStore.address)
 
  await identityContract.grantContractInteraction(investorProxy.address, investorController.address);
  console.log("Identity Access Grant Set Successfully");



  console.log("Contracts deployed to", hre.network.name, "network. Please verify them manually.");
  
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });


