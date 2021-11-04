const { assert, expect } = require("chai");
const dns = artifacts.require("DNS");
const base_contract = artifacts.require("BaseContract");
const company_controller = artifacts.require("CompanyController");
require("chai").should();

contract("company_controller", (accounts) => {

  var DNS, BASE_CONTRACT, COMPANY_CONTROLLER;

  // Deploys contracts and returns a new instance of it before each test
  beforeEach(async () => {
    DNS = await dns.new();
    BASE_CONTRACT = await base_contract.new(DNS.address);
    COMPANY_CONTROLLER = await company_controller.new(DNS.address);
  });

  describe('Contracts deployment status', ()=>{

    it('checks if dns contract is deployed', ()=>{
      await dns.deployed();
    })

  })



});
