const { expect } = require("chai");
const { ethers, deployments } = require("hardhat");

describe("company controller contract", function () {
  beforeEach(async () => {
    // FACTORIES
    const company_controller = await ethers.getContractFactory("CompanyController");
    const dns = await ethers.getContractFactory("DNS");

    // ACCOUNTS
    const [owner, addr1, addr2, addr3] = await ethers.getSigners();

    // CONTRACTS
    var DNS, BASE_CONTRACT, COMPANY_CONTROLLER;

    const COMPANY_URL = "https://quidraise.co",
      COMPANY_NAME = "Quid Raise",
      COMPANY_TOKEN_CONTRACT_ADDRESS = addr3,
      COMPANY_OWNER = addr2,
      COMPANY_CREATED_BY = addr1;

    // DEPLOYMENT
    DNS = await dns.deploy();
    COMPANY_CONTROLLER = await company_controller.deploy(DNS.address);
    console.log(DNS.address)
  });

  it("should create company successfully", async function () {
    await deployments.fixture(["CompanyController"]);
    await expect(
      await COMPANY_CONTROLLER.createCompany(COMPANY_URL, COMPANY_NAME, COMPANY_TOKEN_CONTRACT_ADDRESS, COMPANY_OWNER, COMPANY_CREATED_BY),
    ).to.emit(COMPANY_CONTROLLER, "CompanyCreated");
  });
});
