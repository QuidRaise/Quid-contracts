// SPDX-License-Identifier: MIT
import "../models/Schema.sol";
import "../infrastructure/BaseContract.sol";

import "./interface/ICompanyStore.sol";
import "../libraries/SafeMath.sol";


pragma experimental ABIEncoderV2;
pragma solidity 0.7.0;

contract CompanyStore is BaseContract, ICompanyStore {

   using SafeMath for uint256;

    Company[] private _companies;
    mapping(address => Index) private _ownedCompanies;
    mapping(uint => Index) private _companyIndexes;

    constructor(address dnsContract) BaseContract(dnsContract) {

    }

    function isCompanyOwner(address ownerAddress) external view override returns(bool) {
        return _ownedCompanies[ownerAddress].Exists;
    }

    function getCompanyById(uint id) external view override returns(Company memory) {
        require(_companyIndexes[id].Exists, "No such record");
        return _companies[_companyIndexes[id].Index];
    }

    function getCompanyByOwner(address ownerAddress) external view override  returns(Company memory)  {
        require(_ownedCompanies[ownerAddress].Exists, "No record for address");
        uint companyIndex = _ownedCompanies[ownerAddress].Index;
        Company memory company = _companies[companyIndex];

        return company;
    }

    function updateCompany(Company memory company) external override c2cCallValid {
        Index memory index = _companyIndexes[company.Id];
        require(index.Exists, "Record Not Found");
        _companies[index.Index] = company;
    }

    function createCompany(Company memory company) external override c2cCallValid returns(uint) {
        require(!_ownedCompanies[company.OwnerAddress].Exists, "Record of company exists for address");
        
        uint256 recordIndex = _companies.length;

        company.Id = recordIndex.add(1);
        Index memory index = Index(recordIndex, true);

        _companies.push(company);
        _ownedCompanies[company.OwnerAddress] = index;
        _companyIndexes[company.Id] = index;

        return company.Id;


    }

}
