pragma solidity ^0.5.9;

/*
    Committer is a contract that can validate an user commit.
    To avoid front running, only unique msg + salt are allowed.
    Owner is responsable from changing the between states.
*/

contract Committer {
    // States that this contract can have
    enum States {Commit, Reveal, Stopped}


    // Hold commitment information as two keccak hashs
    struct Commitment {
        bytes32 hashMsg;
        bytes32 hashSalt;
    }

    address public owner;

    States public state;
    mapping(address => Commitment) public commitments;
    mapping(bytes32 => bool) public filter;


    constructor() public {
        owner = msg.sender;
    }

    // Save commiment from sender. Can only submit one commitment.
    // A message and salt must be unique. (Front-runners)
    function commit(
        bytes32 _hashMsg,
        bytes32 _hashSalt
    )
    public
    onlyInState(States.Commit)
    {

        require(commitments[msg.sender].hashMsg == 0x0, 'can only make one commitment');
        bytes32 _test = keccak256(abi.encodePacked(_hashMsg, _hashSalt));
        require(filter[_test] == false, 'Cant commit this message');

        filter[_test] = true;
        commitments[msg.sender] = Commitment(_hashMsg, _hashSalt);
    }


    function reveal(
        bytes memory _msg,
        bytes memory _salt
    )
    public
    view
    onlyCommiters
    onlyInState(States.Reveal)
    returns(bool)
    {
        if(keccak256(_salt) == commitments[msg.sender].hashSalt &&
           keccak256(_msg) == commitments[msg.sender].hashMsg
          )
        {
            return true;
        }

        return false;
    }

    // Set contract to next stage.
    // Only Owner can make this call.
    function nextState() public onlyOwner {
        States oldState = state;
        state = States(uint(state) + 1);

        require(uint(state) > uint(oldState) && uint(state) < 3, 'cant change state');
    }


    modifier onlyOwner {
        require(msg.sender == owner, 'not owner');
        _;
    }


    modifier onlyInState(States _state) {

        require(_state == state, 'not in the correct state');
        _;
    }


    modifier onlyCommiters {

        require(commitments[msg.sender].hashMsg != 0x0, 'not a commiter');
        _;
    }
}
