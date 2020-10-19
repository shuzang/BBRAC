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
        bytes16 currentWeight;
    }
    
    struct Behaviors {
        BehaviorRecord[] LegalBehaviors;
        BehaviorRecord[] MisBehaviors;
        uint begin; // begin index of legalBehaviors, when misbehaviors compute, this field recalculate
        uint TimeofUnblock; //End time of blocked (0 if unblocked, otherwise, blocked)
    }
    
    struct Environment {
        bytes16[4] omega; 
        bytes16[4] alpha; // penalty factor, index 2,4 is policy action, index 1 is large number of requests in a short time
        bytes16 CrPmax;
        bytes16 gamma; // forgetting factor
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
    function updateEnvironment(string memory _name, uint256 index, bytes16 value) public {
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
        
        bytes16 CrN;
        bytes16 CrP;
        uint Tblocked;
        
        if (_ismisbehavior) {
            behaviorsLookup[_subject].MisBehaviors.push(BehaviorRecord(_behaviorID, _behavior, _time, evAttr.alpha[_behaviorID-1]));
        } else {
            behaviorsLookup[_subject].LegalBehaviors.push(BehaviorRecord(_behaviorID, _behavior, _time, evAttr.omega[_behaviorID-1]));
        }
        
        // calculate negative impact part
        uint misLen = behaviorsLookup[_subject].MisBehaviors.length;
        for (uint i = 0; i < misLen; i++) {
            bytes16 wi = behaviorsLookup[_subject].MisBehaviors[i].currentWeight; 
            CrN = ABDKMathQuad.add(
                CrN,
                ABDKMathQuad.div(wi, ABDKMathQuad.fromUInt(misLen-i))
            );           
        }
        CrN = ABDKMathQuad.neg(ABDKMathQuad.mul(CrN, ABDKMathQuad.fromUInt(misLen)));

        
        // calculate positive impact part
        uint legLen = behaviorsLookup[_subject].LegalBehaviors.length - behaviorsLookup[_subject].begin;
        for (uint i = behaviorsLookup[_subject].begin; i < behaviorsLookup[_subject].LegalBehaviors.length; i++) {
            bytes16 wi = behaviorsLookup[_subject].MisBehaviors[i].currentWeight; 
            bytes16 g = Utils.exp(evAttr.gamma, legLen-i);
            CrP = ABDKMathQuad.add(
                CrP,
                ABDKMathQuad.mul(wi, g)
            );
        }
        CrP = ABDKMathQuad.div(CrP,ABDKMathQuad.fromUInt(legLen));
        if (ABDKMathQuad.cmp(evAttr.CrPmax, CrP) == -1) {
            CrP = evAttr.CrPmax;
        }

        // calculate credit
        int credit = ABDKMathQuad.toInt(ABDKMathQuad.add(CrP,CrN));

        // calculate penalty
        if ((block.timestamp > behaviorsLookup[_subject].TimeofUnblock) && (credit < 0)) {
            behaviorsLookup[_subject].begin = behaviorsLookup[_subject].LegalBehaviors.length-1;
            Tblocked = uint(ABDKMathQuad.toInt(ABDKMathQuad.pow_2(ABDKMathQuad.fromInt(credit))));
            // update unblocked time
            behaviorsLookup[_subject].TimeofUnblock = block.timestamp + Tblocked;
            mc.updateTimeofUnblock(_subject, behaviorsLookup[_subject].TimeofUnblock);
        }
        
        emit isCalled(_subject, _ismisbehavior, _behavior, _time, credit, Tblocked);
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
/*         evAttr.alpha[0] = 2; // Too frequent request
        evAttr.alpha[1] = 3; // policy check failed
        evAttr.alpha[2] = 5; // both above two
        evAttr.alpha[3] = 4; // importance policy check failed
        evAttr.omega[0] = 1;
        evAttr.omega[1] = 1;
        evAttr.omega[2] = 1;
        evAttr.omega[3] = 2;
        evAttr.CrPmax = 30;
        evAttr.gamma = 0; */
    }
}


abstract contract Management {
    function updateTimeofUnblock(address _device, uint256 _TimeofUnblock) virtual public;
    function isContractAddress(address _scAddress) virtual public view returns (bool);
}