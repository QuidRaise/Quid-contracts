// SPDX-License-Identifier: MIT
import "./models/Schema.sol";
import "./BaseContract.sol";

import "./interfaces/ICompanyStore.sol";
import "./libraries/SafeMath.sol";


pragma experimental ABIEncoderV2;
pragma solidity 0.7.0;

contract CompanyStore is BaseContract, ICompanyStore {

   using SafeMath for uint256;

    Company[] private _companies;
    mapping(address => Index) private _ownedCompanies;
    mapping(address => bool) private _isCompanyOwner;

    constructor(address dnsContract) BaseContract(dnsContract) {

    }

    function isCompanyOwner(address ownerAddress) external override returns(bool) {
        return _isCompanyOwner[ownerAddress];
    }

    function getCompanyById(uint id) external override returns(Company memory) {
        require(id < _companies.length, "No such record");
        return _companies[id];
    }

    function getCompanyByOwner(address ownerAddress) external override returns(Company memory)  {
        require(_isCompanyOwner[ownerAddress], "No record for address");
        uint companyIndex = _ownedCompanies[ownerAddress].Index;
        Company memory company = _companies[companyIndex];

        return company;
    }

    function updateCompany(uint id, Company memory company) external override {
        require(id < _companies.length, "No such record" );
        _companies[id.sub(1)] = company;
    }

    function createCompany(Company memory company) external override returns(uint) {
        require(!_isCompanyOwner[company.OwnerAddress], "Record of company exists for address");
        Index memory index;
        uint256 recordIndex = _companies.length;

        company.Id = recordIndex.add(1);
        index = Index(recordIndex, true);

        _companies.push(company);
        _ownedCompanies[company.OwnerAddress] = index;
        _isCompanyOwner[company.OwnerAddress] = true;

        return index.Index;


    }

}
