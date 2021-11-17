import "./interface/IRoundStore.sol";
import "../infrastructure/BaseContract.sol";
import "../models/Schema.sol";
import "../libraries/SafeMath.sol";

pragma experimental ABIEncoderV2;

pragma solidity 0.7.0;

contract RoundStore is BaseContract, IRoundStore {
    using SafeMath for uint256;

    mapping(uint256 => Index[]) private _companyRounds;
    mapping(uint256 => mapping(uint256 => Index)) private _companyroundsIndex;

    Round[] private _rounds;

    constructor(address dnContract) BaseContract(dnContract) {}

    function getRound(uint256 roundId) external view override returns (Round memory) {
        return _rounds[roundId.sub(1)];
    }

    function getCompanyRounds(uint256 companyId) external view override returns (Round[] memory) {
        Index[] memory indexes = _companyRounds[companyId];
        Round[] memory rounds = new Round[](indexes.length);

        for (uint256 i = 0; i < indexes.length; i++) {
            uint256 roundIndex = _companyRounds[companyId][i].Index;
            rounds[i] = _rounds[roundIndex];
        }

        return rounds;
    }

    function updateRound(uint256 id, Round memory round) external override {
        require(id < _rounds.length, "No such rounds");
        _rounds[id] = round;
    }

    function createRound(Round memory round) external override returns (uint256) {
        Index memory index = _companyroundsIndex[round.CompanyId][round.Id];
        require(!index.Exists, "Record already exist");

        uint256 recordIndex = _rounds.length;
        round.Id = recordIndex.add(1);

        index = Index(recordIndex, true);

        _rounds.push(round);
        _companyroundsIndex[round.CompanyId][round.Id] = index;
        _companyRounds[round.CompanyId].push(index);

        return round.Id;
    }

    function createRoundPaymentOptions(uint256 roundId, address[] memory paymentCurrencies) external override {
        Round memory round = _rounds[roundId.sub(1)];
        Index memory index = _companyroundsIndex[round.CompanyId][round.Id];
        require(index.Exists, "Record doesn't exists");

        round.PaymentCurrencies = paymentCurrencies;

        _rounds[roundId] = round;
    }

    function getRoundPaymentOptions(uint256 id) external view override returns (address[] memory) {
        require(id <= _rounds.length, "No record of such round");
        return _rounds[id].PaymentCurrencies;
    }
}
