// SPDX-License-Identifier: MIT

import "./interface/IRoundStore.sol";
import "../infrastructure/BaseContract.sol";
import "../models/Schema.sol";
import "../libraries/SafeMath.sol";


pragma experimental ABIEncoderV2;

pragma solidity 0.7.0;

contract RoundStore is BaseContract, IRoundStore {
    
    using SafeMath for uint256;

    mapping(uint => Index[]) private _companyRounds;
    mapping(uint => Index) private _roundIndex;
    mapping(uint => mapping(uint256 => Index)) private _companyRoundIndex;


    Round[] private _rounds;

    constructor(address dnContract) BaseContract(dnContract) {}
        

    function getRound(uint roundId) external override view returns(Round memory){
        Index memory index = _roundIndex[roundId];
        return _rounds[index.Index];
    }

    function getCompanyRounds(uint companyId) external override  view returns (Round[] memory) {
        Index[] memory indexes = _companyRounds[companyId];
        Round[] memory rounds = new Round[](indexes.length);

        for(uint256 i = 0; i < indexes.length; i++){
            uint256 roundIndex = _companyRounds[companyId][i].Index;
            rounds[i] = _rounds[roundIndex];
        }

        return rounds;
    }

    function updateRound(Round memory round) external override c2cCallValid {
        Index memory index = _roundIndex[round.Id];
        require(index.Exists,"Record not found");
        round.Id = _rounds[index.Index].Id;
        _rounds[index.Index] = round;
    }

    function createRound(Round memory round) external override c2cCallValid returns (uint) {
        Index memory index = _roundIndex[round.Id];
        require(!index.Exists, "Record already exist");

        uint256 recordIndex = _rounds.length;
        round.Id = recordIndex.add(1);

        index = Index(recordIndex, true);

        _rounds.push(round);
        _companyRoundIndex[round.CompanyId][round.Id] = index;
        _companyRounds[round.CompanyId].push(index);
        _roundIndex[round.Id] = index;

        return round.Id;
    }

    function getRoundPaymentOptions(uint id) external override view returns(address[] memory){
        require(id <= _rounds.length, "No record of such round");
        return _rounds[id].PaymentCurrencies;
    }
    
}