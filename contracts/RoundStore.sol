import "./interfaces/IRoundStore.sol";
import "./BaseContract.sol";
import "./models/Schema.sol";
import "./libraries/SafeMath.sol";


pragma experimental ABIEncoderV2;

pragma solidity 0.7.0;

contract RoundStore is BaseContract, IRoundStore {
    
    using SafeMath for uint256;

    mapping(uint => Index[]) private _companyRounds;
    mapping(uint => mapping(uint256 => Index)) private _companyroundsIndex;

    Round[] private _rounds;

    constructor(address dnContract) BaseContract(dnContract) {

    }

    function getRound(uint roundId) external override view returns(Round memory){
        return _rounds[roundId.sub(1)];
    }

    function getCompanyRounds(uint companyId) external override view returns (Round[] memory) {
        Index[] memory indexes = _companyRounds[companyId];
        Round[] memory rounds = new Round[](indexes.length);

        for(uint256 i = 0; i < indexes.length; i++){
            uint256 roundIndex = indexes[i].Index;
            rounds[roundIndex] = _rounds[roundIndex];
        }

        return rounds;
    }

    function updateRound(uint id, Round memory round) external override {
        require(id < _rounds.length , "No such rounds");
        _rounds[id] = round;
    }

    function createRound(Round memory round) external override returns (uint) {
        Index memory index = _companyroundsIndex[round.CompanyId][round.Id];
        require(!index.Exists, "Record already exist");

        uint256 recordIndex = _rounds.length;
        round.Id = recordIndex.add(1);

        index = Index(recordIndex, true);

        _rounds.push(round);
        _companyroundsIndex[round.CompanyId][round.Id] = index;
        _companyRounds[round.CompanyId].push(index);

        return index.Index;
    }

    function createRoundPaymentOptions(uint roundId, address[] memory paymentCurrencies) external override {
        Round memory round = _rounds[roundId];
        Index memory index = _companyroundsIndex[round.CompanyId][round.Id];
        require(index.Exists, "Record doesn't exists");

        round.PaymentCurrencies = paymentCurrencies;

        _rounds[roundId] = round;
        
    }

    function getRoundPaymentOptions(uint id) external override view returns(address[] memory){
        require(id <= _rounds.length, "No record of such round");
        return _rounds[id].PaymentCurrencies;
    }
    
}