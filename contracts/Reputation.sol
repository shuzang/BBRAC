// SPDX-License-Identifier:MIT
pragma solidity >0.6.0 <0.8.0;

import "./lib/Utils.sol";
import "./lib/ABDKMathQuad.sol";

contract Reputation {

    address public owner;
    address public mcAddress;
    Management public mc;
    
    event isCalled(
        address indexed _from, 
        bool _ismisbehavior, 
        string _behavior, 
        uint _time, 
        int Cr, 
        uint Tblocked
    );

    struct BehaviorRecord {
        uint8 behaviorID;
        string behavior;
        uint  time;
        uint8 currentWeight;
    }
    
    struct Behaviors {
        BehaviorRecord[] LegalBehaviors;
        BehaviorRecord[] MisBehaviors;
        uint begin; // begin index of legalBehaviors, when misbehaviors compute, this field recalculate
        uint TimeofUnblock; //End time of blocked (0 if unblocked, otherwise, blocked)
    }
    
    struct Environment {
        uint8[4] omega; 
        uint8[4] alpha; // penalty factor, index 2,4 is policy action, index 1 is large number of requests in a short time
        uint8 CrPmax;
        uint8 gamma;
    }

    // mapping devie address => Behavior recort for reputation compute
    mapping(address => Behaviors) public behaviorsLookup;
    // some environment factors
    Environment public evAttr;
    
    /// @dev Set contract deployer as owner, set management contract address, initial environment variable
    constructor(address _mc) {
        owner = msg.sender;
        mc = Management(_mc);
        mcAddress = _mc;
        initEnvironment();
    }
    
    /// @dev updateEnvironment update parameters of reputation function
    function updateEnvironment(string memory _name, uint256 index, uint8 value) public {
        require(
            msg.sender == owner,
            "updateEnvironment error: Only owner can update environment factors!"
        );
        if (Utils.stringCompare(_name, "omega")) {
            evAttr.omega[index] = value;
        }
        if (Utils.stringCompare(_name, "alpha")) {
            evAttr.alpha[index] = value;
        }
        if (Utils.stringCompare(_name, "CrPmax")) {
            evAttr.CrPmax = value;
        }
        if (Utils.stringCompare(_name, "gamma")) {
            evAttr.gamma = value;
        }
    }

    /// @dev reputationCompute compute the positive impact part and negative impact part of credit value,
    ///      and then, compute blocked time and reward time according the credit value and update the device attribute
    function reputationCompute(
        address _subject, 
        bool _ismisbehavior,
        uint8 _behaviorID,
        string memory _behavior,
        uint  _time
    ) 
        public 
    {
        require(
            mc.isContractAddress(msg.sender) || msg.sender == mcAddress,
            "reputationCompute error: only acc or mc can call function!"
        );
        
        uint CrN = 0;
        uint CrP = 0;
        uint Tblocked;
        
        if (_ismisbehavior) {
            behaviorsLookup[_subject].MisBehaviors.push(BehaviorRecord(_behaviorID, _behavior, _time, evAttr.alpha[_behaviorID-1]));
        } else {
            behaviorsLookup[_subject].LegalBehaviors.push(BehaviorRecord(_behaviorID, _behavior, _time, evAttr.omega[_behaviorID-1]));
        }
        
        for (uint i = 0;i < behaviorsLookup[_subject].MisBehaviors.length; i++) {
            uint8 tmp = behaviorsLookup[_subject].MisBehaviors[i].currentWeight; 
            CrN = CrN + tmp;
            if (tmp > 1) {
                behaviorsLookup[_subject].MisBehaviors[i].currentWeight = tmp - 1;
            }
        }
        
        for (uint i = behaviorsLookup[_subject].begin; i < behaviorsLookup[_subject].LegalBehaviors.length; i++) {
            CrP = CrP + behaviorsLookup[_subject].LegalBehaviors[i].currentWeight;
            if (CrP >= evAttr.CrPmax) {
                CrP = evAttr.CrPmax;
            }
        }

        if ((block.timestamp > behaviorsLookup[_subject].TimeofUnblock) && (int(CrP - CrN) < evAttr.gamma)) {
            behaviorsLookup[_subject].begin = behaviorsLookup[_subject].LegalBehaviors.length-1;
            if (CrP < CrN) {
                Tblocked = 2**(CrN - CrP + evAttr.gamma);
            } else {
                Tblocked = 2**(CrP - CrN);
            }
            
            behaviorsLookup[_subject].TimeofUnblock = block.timestamp + Tblocked;
            mc.updateTimeofUnblock(_subject, behaviorsLookup[_subject].TimeofUnblock);
        }
        
        emit isCalled(_subject, _ismisbehavior, _behavior, _time, int(CrP-CrN), Tblocked);
    }
    
    /// @dev getLastBehavior get the latest behavior condition
    function getLastBehavior(
        address _requester, 
        uint8 _behaviorType
    ) 
        public 
        view 
        returns (
            uint _behaviorID, 
            string memory _behavior, 
            uint _time
        ) 
    {
        uint latest;
        if (_behaviorType == 0) {
            require(behaviorsLookup[_requester].LegalBehaviors.length > 0, "There is currently no legal behavior");
            latest = behaviorsLookup[_requester].LegalBehaviors.length - 1;
            _behaviorID = behaviorsLookup[_requester].LegalBehaviors[latest].behaviorID;
            _behavior = behaviorsLookup[_requester].LegalBehaviors[latest].behavior;
            _time = behaviorsLookup[_requester].LegalBehaviors[latest].time;
        } else {
            require(behaviorsLookup[_requester].MisBehaviors.length >= 0, "There is currently no misbehavior");
            latest = behaviorsLookup[_requester].MisBehaviors.length - 1;
            _behaviorID = behaviorsLookup[_requester].MisBehaviors[latest].behaviorID;
            _behavior = behaviorsLookup[_requester].MisBehaviors[latest].behavior;
            _time = behaviorsLookup[_requester].MisBehaviors[latest].time;
        }
    }
    
    /// @dev initEnvironment initial parameters of reputation function
    function initEnvironment() internal {
        evAttr.alpha[0] = 2; // Too frequent request
        evAttr.alpha[1] = 3; // policy check failed
        evAttr.alpha[2] = 5; // both above two
        evAttr.alpha[3] = 4; // importance policy check failed
        evAttr.omega[0] = 1;
        evAttr.omega[1] = 1;
        evAttr.omega[2] = 1;
        evAttr.omega[3] = 2;
        evAttr.CrPmax = 30;
        evAttr.gamma = 0;
    }
}


abstract contract Management {
    function updateTimeofUnblock(address _device, uint256 _TimeofUnblock) virtual public;
    function isContractAddress(address _scAddress) virtual public view returns (bool);
}