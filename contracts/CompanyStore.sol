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
    mapping(uint => Index) _companyIndexes;

    constructor(address dnsContract) BaseContract(dnsContract) {

    }

    function isCompanyOwner(address ownerAddress) external override returns(bool) {
        return _ownedCompanies[ownerAddress].Exists;
    }

    function getCompanyById(uint id) external override returns(Company memory) {
        require(_companyIndexes[id].Exists, "No such record");
        return _companies[id];
    }

    function getCompanyByOwner(address ownerAddress) external override returns(Company memory)  {
        require(_ownedCompanies[ownerAddress].Exists, "No record for address");
        uint companyIndex = _ownedCompanies[ownerAddress].Index;
        Company memory company = _companies[companyIndex];

        return company;
    }

    function updateCompany(Company memory company) external override {
        require(_ownedCompanies[company.OwnerAddress].Exists, "No such record");
        _companies[company.Id.sub(1)] = company;
    }

    function createCompany(Company memory company) external override returns(uint) {
        require(!_ownedCompanies[company.OwnerAddress].Exists, "Record of company exists for address");
        Index memory index;
        uint256 recordIndex = _companies.length;

        company.Id = recordIndex.add(1);
        index = Index(recordIndex, true);

        _companies.push(company);
        _ownedCompanies[company.OwnerAddress] = index;
        _companyIndexes[company.Id] = index;

        return company.Id;


    }

}
