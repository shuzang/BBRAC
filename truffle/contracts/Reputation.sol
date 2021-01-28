// SPDX-License-Identifier:MIT
pragma solidity >0.6.0 <0.8.0;

import "./ABDKMathQuad.sol";

contract Reputation {

    address public owner;
    address public mcAddress;
    Management public mc;
    
    event isCalled(
        address indexed _from, 
        bool _ismisbehavior, 
        string _behavior, 
        uint _bn, // block number
        int Cr, 
        uint Blocked // Blocks blocked
    );

    struct BehaviorRecord {
        uint8 behaviorID;
        string behavior;
        uint  blockNumber;
        uint currentWeight;
    }
    
    struct Behaviors {
        BehaviorRecord[] LegalBehaviors;
        BehaviorRecord[] MisBehaviors;
        uint begin; // begin index of legalBehaviors, when misbehaviors compute, this field recalculate
        uint endBBN; // end blocking block number
    }
    
    struct Environment {
        uint[4] omega; 
        uint[4] alpha; // penalty factor, index 2,4 is policy action, index 1 is large number of requests in a short time
        bytes16[2] lambda; // weight of CrP and CrN
        uint CrPmax;
        //bytes16 gamma; // forgetting factor
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
    /// @notice real input value is value/base, e.g. 0.1 = 1/10, 0.25 = 25/100
    function updateEnvironment(string memory _name, uint256 index, uint value, uint base) public {
        require(
            msg.sender == owner,
            "updateEnvironment error: Only owner can update environment factors!"
        );
        require(
             base != 0,
             "param error: divisor can't be 0!"
        );
        bytes16 input = ABDKMathQuad.div(
            ABDKMathQuad.fromUInt(value),
            ABDKMathQuad.fromUInt(base)
        );
        if (stringCompare(_name, "omega")) {
            require(
                index >= 0 && index < 4,
                "updateEnvironment error: parameter array overflow"
            );
            evAttr.omega[index] = value;
        }
        if (stringCompare(_name, "alpha")) {
            require(
                index >= 0 && index < 4,
                "updateEnvironment error: parameter array overflow"
            );
            evAttr.alpha[index] = value;
        }
        if (stringCompare(_name, "lambda")) {
            require(
                index >= 0 && index < 4,
                "updateEnvironment error: parameter array overflow"
            );
            evAttr.lambda[index] = input;
        }
        if (stringCompare(_name, "CrPmax")) {
            evAttr.CrPmax = value;
        }
    }

    /// @dev reputationCompute compute the positive impact part and negative impact part of credit value,
    ///      and then, compute blocked time and reward time according the credit value and update the device attribute
    function reputationCompute(
        address _subject, 
        bool _ismisbehavior,
        uint8 _behaviorID,
        string memory _behavior,
        uint  _bn
    ) 
        public 
    {
        require(
            mc.isACCAddress(msg.sender) || msg.sender == mcAddress,
            "reputationCompute error: only acc or mc can call function!"
        );
        
        if (_ismisbehavior) {
            behaviorsLookup[_subject].MisBehaviors.push(BehaviorRecord(_behaviorID, _behavior, _bn, evAttr.alpha[_behaviorID-1]));
        } else {
            behaviorsLookup[_subject].LegalBehaviors.push(BehaviorRecord(_behaviorID, _behavior, _bn, evAttr.omega[_behaviorID-1]));
        }

        // calculate negative impact part
        bytes16 CrN;
        uint misLen = behaviorsLookup[_subject].MisBehaviors.length;
        for (uint i = 0; i < misLen; i++) {
            uint wi = behaviorsLookup[_subject].MisBehaviors[i].currentWeight; 
            CrN = ABDKMathQuad.add(
                CrN,
                ABDKMathQuad.div(
                    ABDKMathQuad.fromUInt(wi), 
                    ABDKMathQuad.fromUInt(misLen-i)
                )
            );           
        }

        // calculate positive impact part
        uint CrP;
        for (uint i = behaviorsLookup[_subject].begin; i < behaviorsLookup[_subject].LegalBehaviors.length; i++) {
            CrP = CrP + behaviorsLookup[_subject].LegalBehaviors[i].currentWeight; 
        }
        if (CrP > evAttr.CrPmax) {
            CrP = evAttr.CrPmax;
        }
        
        // calculate credit
        int credit = ABDKMathQuad.toInt(ABDKMathQuad.sub(
            ABDKMathQuad.mul(evAttr.lambda[0], ABDKMathQuad.fromUInt(CrP)),
            ABDKMathQuad.mul(evAttr.lambda[1], CrN))
        );

        // calculate penalty
        uint Tblocked;
        if ((block.number > behaviorsLookup[_subject].endBBN) && (credit < 0)) {
            if (behaviorsLookup[_subject].LegalBehaviors.length > behaviorsLookup[_subject].begin) {
                behaviorsLookup[_subject].begin = behaviorsLookup[_subject].LegalBehaviors.length-1;
            }
            Tblocked = 2**uint(credit * -1);
            // update unblocked time
            behaviorsLookup[_subject].endBBN = block.number + Tblocked;
            mc.updateEndBBN(_subject, behaviorsLookup[_subject].endBBN);
        }
        
        emit isCalled(_subject, _ismisbehavior, _behavior, _bn, credit, Tblocked);
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
            uint _bn
        ) 
    {
        uint latest;
        if (_behaviorType == 0) {
            require(behaviorsLookup[_requester].LegalBehaviors.length > 0, "There is currently no legal behavior");
            latest = behaviorsLookup[_requester].LegalBehaviors.length - 1;
            _behaviorID = behaviorsLookup[_requester].LegalBehaviors[latest].behaviorID;
            _behavior = behaviorsLookup[_requester].LegalBehaviors[latest].behavior;
            _bn = behaviorsLookup[_requester].LegalBehaviors[latest].blockNumber;
        } else {
            require(behaviorsLookup[_requester].MisBehaviors.length > 0, "There is currently no misbehavior");
            latest = behaviorsLookup[_requester].MisBehaviors.length - 1;
            _behaviorID = behaviorsLookup[_requester].MisBehaviors[latest].behaviorID;
            _behavior = behaviorsLookup[_requester].MisBehaviors[latest].behavior;
            _bn = behaviorsLookup[_requester].MisBehaviors[latest].blockNumber;
        }
    }
    
    /// @dev initEnvironment initial parameters of reputation function
    function initEnvironment() internal {
        evAttr.alpha[0] = 5; // 0.2 
        evAttr.alpha[1] = 10; // 0.3
        evAttr.alpha[2] = 15; // 0.5
        evAttr.alpha[3] = 12; // 0.4
        evAttr.omega[0] = 10; // 0.1
        evAttr.omega[1] = 10; // 0.1
        evAttr.omega[2] = 10; // 0.1
        evAttr.omega[3] = 10; // 0.1
        evAttr.lambda[0] = 0x3ffe0000000000000000000000000000; // 0.5
        evAttr.lambda[1] = 0x3ffe0000000000000000000000000000; // 0.5
        evAttr.CrPmax = 30; // 30
        //evAttr.gamma = 0x3ffd3333333333333333333333333333; // 0.3
    }

    /// @dev stringCompare determine whether the strings are equal, using length + hash comparson to reduce gas consumption
    function stringCompare(string memory a, string memory b) public pure returns (bool) {
        bytes memory _a = bytes(a);
        bytes memory _b = bytes(b);
        if (_a.length != _b.length) {
            return false;
        } else {
            if (_a.length == 1) {
                return _a[0] == _b[0];
            } else {
                return keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b));
            }
        }
    }
}


abstract contract Management {
    function updateEndBBN(address _device, uint256 _endBBN) virtual public;
    function isACCAddress(address _scAddress) virtual public view returns (bool);
}