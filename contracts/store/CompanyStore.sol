// SPDX-License-Identifier: MIT
import "../models/Schema.sol";
import "../infrastructure/BaseContract.sol";

import "./interface/ICompanyStore.sol";
import "../libraries/SafeMath.sol";
import "hardhat/console.sol";

pragma experimental ABIEncoderV2;
pragma solidity 0.7.0;

contract CompanyStore is BaseContract, ICompanyStore {
    using SafeMath for uint256;

    Company[] private _companies;
    mapping(address => Index) private _ownedCompanies;
    mapping(uint256 => Index) _companyIndexes;

    constructor(address dnsContract) BaseContract(dnsContract) {}

    function isCompanyOwner(address ownerAddress) external view override returns (bool) {
        return _ownedCompanies[ownerAddress].Exists;
    }

    function getCompanyById(uint256 id) external view override returns  (Company memory) {
        // console.log("this is the company id");
        // console.log("this is the company id", _companies[id].Id);
        require(_companyIndexes[id].Exists, "No such record");
        return _companies[ _companyIndexes[id].Index   ];
    }

    function getCompanyByOwner(address ownerAddress) external view override returns (Company memory) {
        require(_ownedCompanies[ownerAddress].Exists, "No record for address");
        uint256 companyIndex = _ownedCompanies[ownerAddress].Index;
        Company memory company = _companies[companyIndex];

        return company;
    }

    function updateCompany(Company memory company) external override {
        require(_ownedCompanies[company.OwnerAddress].Exists, "No such record");
        _companies[company.Id.sub(1)] = company;
    }

    function createCompany(Company memory company) external override returns (uint256) {
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
