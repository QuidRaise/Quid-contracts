const hre = require("hardhat");
const { ethers } = hre;
const { BigNumber } = require('ethers');


async function main() {

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

   let dns;
   let companyRoundController;

  if (hre.network.name === "testnet") {

       dns = await ethers.getContractAt("DNS","0x25EbF1F0F1f656FB43Ab3b922e715Ea2EBf73273");
       companyRoundController = await ethers.getContractAt("CompanyRoundController","0x497fd1Dc3f0A7530f85319981d3d215eBd3737eb");

  }
  else
  {
       dns = await DNS.deploy();
       companyRoundController = await CompanyRoundController.deploy(dns.address)
  }

  const companyProposalController = await CompanyProposalController.deploy(dns.address)
  const companyController = await CompanyController.deploy(dns.address)
  const investorController = await InvestorController.deploy(dns.address)
  const treasury = await Treasury.deploy();
  const identityContract = await IdentityContract.deploy(dns.address);
  const eventEmitter = await EventEmitter.deploy(dns.address)
  const nft = await QuidRaiseShares.deploy("", dns.address)
  const companyStore = await CompanyStore.deploy(dns.address)
  const investorStore = await InvestorStore.deploy(dns.address)
  const proposalStore = await ProposalStore.deploy(dns.address)
  const roundStore = await RoundStore.deploy(dns.address)
  const companyVaultStore = await CompanyVaultStore.deploy(dns.address)
  const companyVault = await CompanyVault.deploy(dns.address)
 
  const companyProxy = await CompanyProxy.deploy(dns.address)
  const investorProxy = await InvestorProxy.deploy(dns.address)

  const config = await Config.deploy()



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
  console.log(`Company Round Controller Contract Address: ${companyRoundController.address}`);
  console.log(`Company Proposal Controller Contract Address: ${companyProposalController.address}`);
  console.log(`Investor Controller Contract Address: ${investorController.address}`);
  console.log(`Company Proxy Contract Address: ${companyProxy.address}`);
  console.log(`Investor Proxy Contract Address: ${investorProxy.address}`);
  console.log(`Config Contract Address: ${config.address}`);


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

  console.log("Routes Set Successfully");



  await config.setNumericConfig("MAX_ROUND_PAYMENT_OPTION", BigNumber.from("4"));
  await config.setNumericConfig("PLATFORM_COMMISION", BigNumber.from("1"));
  await config.setNumericConfig("PRECISION", BigNumber.from("100"));
  await config.setNumericConfig("VOTE_DURATION", BigNumber.from("600"));

  console.log("Config Set Successfully");

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
  console.log("Identity Access Grant Set Successfully");

  await companyProxy.activateDataAccess(deployer.address);


  console.log("Auth Access Granted");


  /**
   * The following lines of code is a hack to get the contracts initialized. This should not run on mainnet release
   * 
   */
  if (hre.network.name === "localhost" || hre.network.name === "testnet") {

    // DEPLOY PAYMENT OPTIONS
    const Contract = await ethers.getContractFactory("ERC20Token");
    companyToken = await Contract.deploy("LazerPay", "LP");
    companyToken2 = await Contract.deploy("Wicrypt", "WNT");

    // SEND TOKENS TO COMPANY OWNERS TO USE IN CREATING ROUNDS
    await companyToken.transfer(companyOwner.address, BigNumber.from("31000000000000000000000000"))
    await companyToken2.transfer(companyOwner2.address, BigNumber.from("31000000000000000000000000"))

    const companyATokenAllocation = BigNumber.from("10000000000000000000000");
    const companyBTokenAllocation = BigNumber.from("10000000000000000000000");

    const roundDurationInSeconds = BigNumber.from("1000000");


    const usdtContract = await ethers.getContractFactory("ERC20Token");
    Usdt = await usdtContract.deploy("USDT tether", "USDT");

    const daiContract = await ethers.getContractFactory("ERC20Token");
    Dai = await daiContract.deploy("DAI Token", "DAI");

    const busdContract = await ethers.getContractFactory("ERC20Token");
    Busd = await busdContract.deploy("Binance BUSD", "BUSD");

    const USDContract = await ethers.getContractFactory("ERC20Token");
    Usdc = await USDContract.deploy("USDC", "USDC");

    console.log(`Usdt Contract Address: ${Usdt.address}`);
    console.log(`Dai Contract Address: ${Dai.address}`);
    console.log(`Busd Contract Address: ${Busd.address}`);
    console.log(`Usdc Contract Address: ${Usdc.address}`);
    console.log(`companyToken Contract Address: ${companyToken.address}`);
    console.log(`companyToken2 Contract Address: ${companyToken2.address}`);


    await Usdt.transfer(investor.address, BigNumber.from("31000000000000000000000000"))
    await Dai.transfer(investor.address, BigNumber.from("31000000000000000000000000"))
    await Busd.transfer(investor.address, BigNumber.from("31000000000000000000000000"))
    await Usdc.transfer(investor.address, BigNumber.from("31000000000000000000000000"))


    await companyVaultStore.enablePaymentOption(Usdt.address);
    await companyVaultStore.enablePaymentOption(Dai.address);
    await companyVaultStore.enablePaymentOption(Busd.address);
    await companyVaultStore.enablePaymentOption(Usdc.address);



    await companyToken.connect(companyOwner).approve(companyRoundController.address,companyATokenAllocation)
    await companyToken2.connect(companyOwner2).approve(companyRoundController.address,companyBTokenAllocation)

    let companyCreationResult = await companyProxy
      .connect(deployer)
      .createCompany("https://www.lazerpay.finance/", "Lazer Pay", companyToken.address, companyOwner.address);
      console.log({companyCreationResult})

    let company2CreationResult = await companyProxy
      .connect(deployer)
      .createCompany("http://wicrypt.com/", "Wicrypt", companyToken2.address, companyOwner2.address);
      console.log({company2CreationResult});

    
    let roundCreationResult = await companyProxy
      .connect(companyOwner)
      .createRound("https://cdn.invictuscapital.com/reports/2021_QR3.pdf", getCurrentTimeStamp(), BigNumber.from("1296000"), BigNumber.from("1000"), companyATokenAllocation, false, [ Usdt.address, Dai.address, Busd.address, Usdc.address ], [ BigNumber.from("1000000000000000000"), BigNumber.from("1000000000000000000"), BigNumber.from("1000000000000000000"), BigNumber.from("1000000000000000000") ]);
      console.log({roundCreationResult})

      let round2CreationResult = await companyProxy
      .connect(companyOwner2)
      .createRound("https://token.wicrypt.com/WicryptLitepaper.pdf", getCurrentTimeStamp(), roundDurationInSeconds, BigNumber.from("1296000"), companyBTokenAllocation, true, [ Usdt.address, Dai.address, Busd.address,Usdc.address ], [ BigNumber.from("1000000000000000000"), BigNumber.from("1000000000000000000"), BigNumber.from("1000000000000000000"), BigNumber.from("1000000000000000000") ]);
      console.log({round2CreationResult})

      await Usdt.connect(investor).approve(investorController.address,BigNumber.from("100000000000000000000"))

      let investment1Result = await investorProxy.connect(investor).investInRound(1,Usdt.address);
      console.log({investment1Result});

      // await Busd.connect(investor).approve(investorController.address,roundInvestmentAmount);
      // let investment2Result = await investorProxy.connect(investor).investInRound(1,Busd.address);
      // console.log({investment2Result});

      // await wait(60*1000);

      // let proposalResult1 = await companyProxy.connect(companyOwner).createProposal([BigNumber.from("100000000000000000000"),BigNumber.from("100000000000000000000")],[Usdt.address,Busd.address],getCurrentTimeStamp()+5000);
      // console.log({proposalResult1});
      
      
      // let proxyVoteResult = await investorProxy.connect(investor).voteForProposal(1, true);
      // console.log({proxyVoteResult});


      // let proposalResult2 = await companyProxy.connect(companyOwner2).createProposal([BigNumber.from("100000000000000000000"),BigNumber.from("100000000000000000000")],[Usdt.address,Busd.address],getCurrentTimeStamp()+5000);
      // console.log({proposalResult2});



  }


  if (hre.network.name === "mainnet" || hre.network.name === "testnet") {
    await hre.run("verify:verify", {
      address: quidRaise.address,
      constructorArguments: [],
    });
  } else {
    console.log("Contracts deployed to", hre.network.name, "network. Please verify them manually.");
  }
}




function getCurrentTimeStamp()
{
  var timeStamp = Math.floor(Date.now() / 1000);
  return timeStamp;


}

function wait(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}



main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });


