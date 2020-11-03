// SPDX-License-Identifier:MIT
pragma solidity ^0.7.0;

contract Judge {
    uint public base;
    uint public inteval;
    address public owner;
    
    event isCalled(address _from, uint _time, uint _penalty);
    
    struct Misbehavior{
        address subject;   //subject who performed the misbehavior 
        address object;
        bytes32 res;
        bytes32 action;   //action (e.g., "read","write","execute") of the misbehavior
        string misbehavior;
        uint time;   //time of the Misbehavior ocured
        uint penalty;   //penalty (number of minitues blocked)
    }
    
    mapping (address => Misbehavior[]) public MisbehaviorList;
    
    constructor(uint  _base, uint  _inteval) {
        base = _base;
        inteval = _inteval;
        owner = msg.sender;
    }
    
    function misbeaviorJudge(
        address _subject, 
        address  _object, 
        bytes32 _res,
        string memory _misbehavior,
        bytes32  _action, 
        uint  _time) 
        public returns (uint  penalty) 
    {
        //misbeaviorJudge(msb)
        uint length = MisbehaviorList[_subject].length + 1;
        uint n = length/inteval;
        penalty = base**n;
        MisbehaviorList[_subject].push(Misbehavior(_subject, _object, _res, _action, _misbehavior, _time, penalty));
        emit isCalled(msg.sender, _time, penalty);
    }
    
    function getLatestMisbehavior(address _scAddress) public view 
        returns (address _subject, address _object, bytes32 _res, bytes32 _action, string memory _misbehavior, uint _time)
    {
        uint latest = MisbehaviorList[_scAddress].length  - 1;
        //uint latest = 0;
        _subject = MisbehaviorList[_scAddress][latest].subject;
        _object = MisbehaviorList[_scAddress][latest].object;
        _res = MisbehaviorList[_scAddress][latest].res;
        _action = MisbehaviorList[_scAddress][latest].action;
        _misbehavior = MisbehaviorList[_scAddress][latest].misbehavior;
        _time = MisbehaviorList[_scAddress][latest].time;
    }
}