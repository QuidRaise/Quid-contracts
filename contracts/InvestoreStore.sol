import "./interfaces/IInvestorStore.sol";
import "./BaseContract.sol";
import "./models/Schema.sol";


pragma experimental ABIEncoderV2;

pragma solidity 0.7.0;

contract ProposalStore is BaseContract, IInvestorStore {
    

    mapping (address  => Index)  _investorsIndex;
    Investor[] _investors;

    mapping(address=> Index[]) __investorRoundsIndex;
    RoundInvestment[] _investorRounds;

    mapping(address=> Index[]) _investorProposalsIndex;
    ProposalVote[] _proposalVotes;


    constructor(address dnsContract) BaseContract(dnsContract) {

    }


    function isInvestor(address investorAddress ) external view returns (bool)
    {

    }
    function getInvestor(address investorAddress) external view returns (Investor memory)
    {

    }
    function getAmountInvestorHasSpent(address investorAddress, address paymentCurrencyAddress) external view returns (uint)
    {

    }


    function updateInvestor(address investorAddress, Investor memory investor) external
    {

    }
    function createInvestor(Investor memory investor) external
    {

    }
    function updateRoundsInvestment(address investorAddress, RoundInvestment memory roundInvestment) external
    {

    }
    function updateCompaniesInvestedIn(address investorAddress, uint companyId) external
    {

    }
    function updateProposalsVotedIn(address investorAddress, ProposalVote memory proposalVote) external
    {

    }

    function getRoundsInvestedIn(address investorAddress) external view returns (uint[] memory)
    {

    }
    function getCompaniesInvestedIn(address investorAddress) external view returns (uint[] memory)
    {

    }
    function getProposalVote(address investorAddress, uint256 proposalId) external view returns (ProposalVote memory)
    {

    }
    function getRoundInvestment(address investorAddress, uint256 roundId) external view returns (RoundInvestment memory)
    {
        
    }
    







}
