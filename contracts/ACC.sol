// SPDX-License-Identifier:MIT
pragma solidity ^0.7.0;

contract AccessControlMethod{
    address public owner;
    address public subject;
    address public object;
    JudgeA public jc;
    
    event ReturnAccessResult(
        address indexed _from,
        string _errmsg,
        bool _result,
        uint _time,
        uint _penalty
    );
    
    struct Misbehavior{
        bytes32 res;   //resource on which the misbehavior is conducted
        bytes32 action;   //action (e.g., "read", "write", "execute") of the misbehavior
        string misbehavior;   //misbehavior
        uint time;   //time of the misbehavior occured
        uint penalty;   //penalty opposed to the subject (number of minutes blocked)
    }
    
    struct BehaviorItem{   //for one resource
        Misbehavior []mbs;   //misbehavior list of the subject on a particular resource
        uint TimeofUnblock;   //time when the resource is unblocked (0 if unblocked, otherwise, blocked)
    }
    
    struct PolicyItem{ //for one (resource, action) pair;
        bool isValued; //for duplicate check
        bytes32 permission; //permission: "allow" or "deny"
        uint minInterval; //minimum allowable interval (in seconds) between two successive requests
        uint ToLR; //Time of Last Request
        uint NoFR; //Number of frequent Requests in a short period of time
        uint threshold; //threshold on NoFR, above which a misbehavior is suspected
        bool result; //last access result
        uint8 err; //last err code
    }
    
    mapping (bytes32 => mapping(bytes32 => PolicyItem)) policies; //mapping (resource, action) =>PolicyCriteria for policy check
    mapping (bytes32 => BehaviorItem) behaviors; //mapping resource => BehaviorCriteria for behavior check
    
    
    constructor (address _subject) {
        owner = msg.sender;
        object = msg.sender;
        subject = _subject;
    }
    
    function setJC(address _jc) public {
        require(
            owner == msg.sender,
            "Only owner can set the JC instance!"
        );
        jc = JudgeA(_jc);
    }
    
    function policyAdd(bytes32 _resource, bytes32 _action, bytes32 _permission, uint _minInterval, uint _threshold) public {
        require(
            msg.sender == owner,
            "Only owner can add policy!"
        );
        require(
            !policies[_resource][_action].isValued,
            "policy already exist!"
        );

        policies[_resource][_action].permission = _permission;
        policies[_resource][_action].minInterval = _minInterval;
        policies[_resource][_action].threshold = _threshold;
        policies[_resource][_action].ToLR = 0;
        policies[_resource][_action].NoFR = 0;
        policies[_resource][_action].isValued = true;
        policies[_resource][_action].result = false;
        behaviors[_resource].TimeofUnblock = 0;
    }
    
    function getPolicy(bytes32 _resource, bytes32 _action) public view 
        returns (bytes32 _permission, uint _minInterval, uint _threshold, uint _ToLR, uint _NoFR, bool _res, uint8 _errcode) 
    {
        require(
            policies[_resource][_action].isValued,
            "policy not exist!"
        );
        _permission = policies[_resource][_action].permission;
        _minInterval = policies[_resource][_action].minInterval;
        _threshold = policies[_resource][_action].threshold;
        _NoFR = policies[_resource][_action].NoFR;
        _ToLR = policies[_resource][_action].ToLR;
        _res = policies[_resource][_action].result;
        _errcode = policies[_resource][_action].err;
    }
     
    function policyUpdate(bytes32 _resource, bytes32 _action, bytes32 _newPermission) public {
        require(
            policies[_resource][_action].isValued,
            "policy not exist!"
        );
        policies[_resource][_action].permission = _newPermission;
    }
     
    function minIntervalUpdate(bytes32 _resource, bytes32 _action, uint _newMinInterval) public {
        require(
            policies[_resource][_action].isValued,
            "policy not exist!"
        ); 
        policies[_resource][_action].minInterval = _newMinInterval;
    }
     
     function thresholdUpdate(bytes32 _resource, bytes32 _action, uint _newThreshold) public {
        require(
            policies[_resource][_action].isValued,
            "policy not exist!"
        ); 
        policies[_resource][_action].threshold = _newThreshold;
     }
     
    function policyDelete(bytes32 _resource, bytes32 _action) public {
        require(
            msg.sender == owner,
            "Only owner can delete policy!"
        );
        require(
            policies[_resource][_action].isValued,
            "policy not exist!"
        );
        delete policies[_resource][_action];
    }
     
    //Use event
    function accessControl(bytes32 _resource, bytes32 _action, uint _time) public {
        bool policycheck = false;
        bool behaviorcheck = true;
        uint8 errcode = 0;
        uint penalty = 0;
         
        if(msg.sender == subject) {
            if(behaviors[_resource].TimeofUnblock >= _time) {//still blocked state
                errcode = 1; //"Requests are blocked!"
            }
            else {//unblocked state
                if(behaviors[_resource].TimeofUnblock > 0) {
                    behaviors[_resource].TimeofUnblock = 0;
                    policies[_resource][_action].NoFR = 0;
                    policies[_resource][_action].ToLR = 0;
                }
                //policy check
                if(keccak256("allow") == keccak256(abi.encodePacked(policies[_resource][_action].permission))) {
                    policycheck = true;
                }
                else {
                    policycheck = false;
                }
                //behavior check
                if ((_time - policies[_resource][_action].ToLR) <= policies[_resource][_action].minInterval) {
                    policies[_resource][_action].NoFR++;
                    if(policies[_resource][_action].NoFR >= policies[_resource][_action].threshold){
                        penalty = jc.misbehaviorJudge(subject, object, _resource, _action, "Too frequent access!", _time);
                        behaviorcheck = false;
                        behaviors[_resource].TimeofUnblock = _time + penalty * 60;
                        behaviors[_resource].mbs.push(Misbehavior(_resource,_action, "Too frequent access!", _time, penalty));
                    }
                }
                else {
                    policies[_resource][_action].NoFR = 0;
                }
                if(!policycheck && behaviorcheck) errcode = 2; //Static check failed!
                if(policycheck && !behaviorcheck) errcode = 3; //Misbehavior detected!
                if(!policycheck && !behaviorcheck) errcode = 4; //Static check failed and Misbehavior detected
            }
            policies[_resource][_action].ToLR = _time;
        }
        else {
            errcode = 5; //Wrong object or subject detected;
        }
        policies[_resource][_action].result = policycheck && behaviorcheck;
        policies[_resource][_action].err = errcode;
        if(0 == errcode) emit ReturnAccessResult(msg.sender, "Access authorized!", true, _time, penalty);
        if(1 == errcode) emit ReturnAccessResult(msg.sender, "Requests are blocked!", false, _time, penalty);
        if(2 == errcode) emit ReturnAccessResult(msg.sender, "Static Check failed!", false, _time, penalty);
        if(3 == errcode) emit ReturnAccessResult(msg.sender, "Misbehavior detected!", false, _time, penalty);
        if(4 == errcode) emit ReturnAccessResult(msg.sender, "Static check failed! & Misbehavior detected!", false, _time, penalty);
        if(5 == errcode) emit ReturnAccessResult(msg.sender, "Wrong object or subject specified!", false, _time, penalty);
     }
     
    function getTimeofUnblock(bytes32 _resource) public view returns (uint _penalty, uint _timeOfUnblock) {
        uint l = behaviors[_resource].mbs.length; 
        _timeOfUnblock = behaviors[_resource].TimeofUnblock;
        _penalty = behaviors[_resource].mbs[l-1].penalty;
    }
     
    function deleteACC() public {
        require(
            msg.sender == owner,
            "Only owner can delete ACC!"
        );
        selfdestruct(msg.sender);
    }
}


abstract contract JudgeA {
    function misbehaviorJudge(address _subject, address _object, bytes32 _res, bytes32 _action, string memory _misbehavior, uint _time) public virtual returns (uint);
}