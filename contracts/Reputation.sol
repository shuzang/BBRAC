// SPDX-License-Identifier:MIT
pragma solidity >0.6.0 <0.8.0;

import "./ABDKMathQuad.sol";

contract Reputation {

    address public owner;
    Management public mc;
    
    event isCalled(
        address indexed _from,
        string _behavior, 
        uint _bn, // block number when behavior happen
        int Cr, // Credit value
        uint Blocked // Block numbers blocked
    );

    struct BehaviorRecord {
        uint8 behaviorID;
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
        uint omega; 
        uint[3] alpha; // penalty factor, index 0 is frequent request, 1 is policy check failed, 2 is important policy checkfailed
        bytes16[2] lambda; // weight of CrP and CrN
        uint CrPmax;
    }

    // mapping devie address => Behavior recort for reputation compute
    mapping(address => Behaviors) public behaviorsLookup;
    // some environment factors
    Environment public evAttr;
    
    /// @dev Set contract deployer as owner, set management contract address, initial environment variable
    constructor(address _mc) {
        owner = msg.sender;
        mc = Management(_mc);
        initEnvironment();
    }

    /// @dev initEnvironment initial parameters of reputation function
    function initEnvironment() internal {
        evAttr.alpha[0] = 2; // 0.2 
        evAttr.alpha[1] = 2; // 0.3
        evAttr.alpha[2] = 3; // 0.5
        evAttr.omega = 3; // 0.1
        evAttr.lambda[0] = 0x3ffe0000000000000000000000000000; // 0.5
        evAttr.lambda[1] = 0x3ffe0000000000000000000000000000; // 0.5
        evAttr.CrPmax = 30; // 30
        //evAttr.gamma = 0x3ffd3333333333333333333333333333; // 0.3
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
                index == 0,
                "updateEnvironment error: parameter array overflow"
            );
            evAttr.omega = value;
        }
        if (stringCompare(_name, "alpha")) {
            require(
                index >= 0 && index < 3,
                "updateEnvironment error: parameter array overflow"
            );
            evAttr.alpha[index] = value;
        }
        if (stringCompare(_name, "lambda")) {
            require(
                index >= 0 && index < 2,
                "updateEnvironment error: parameter array overflow"
            );
            evAttr.lambda[index] = input;
        }
        if (stringCompare(_name, "CrPmax")) {
            require(
                index == 0,
                "updateEnvironment error: parameter array overflow"
            );
            evAttr.CrPmax = value;
        }
    }

    /// @dev reputationCompute compute credit value, and then give the penalty through attribute in MC
    function reputationCompute(
        address _subject, 
        uint8 _behaviorID,
        uint  _bn
    ) 
        public 
    {
        require(
            mc.isACCAddress(msg.sender),
            "reputationCompute error: only acc can call function!"
        );
        
        if (_behaviorID == 0) {
            behaviorsLookup[_subject].LegalBehaviors.push(BehaviorRecord(_behaviorID, _bn, evAttr.omega));
        } else {
            behaviorsLookup[_subject].MisBehaviors.push(BehaviorRecord(_behaviorID, _bn, evAttr.alpha[_behaviorID-1]));
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
        uint legLen = behaviorsLookup[_subject].LegalBehaviors.length;
        uint CrP = ( legLen - behaviorsLookup[_subject].begin)*evAttr.omega;
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
            if (legLen > behaviorsLookup[_subject].begin) {
                behaviorsLookup[_subject].begin = legLen-1;
            }
            Tblocked = 2**uint(credit * -1);
            // update end blocking block number
            behaviorsLookup[_subject].endBBN = block.number + Tblocked;
            mc.updateEndBBN(_subject, behaviorsLookup[_subject].endBBN);
        }

        if (_behaviorID == 0) {
            emit isCalled(_subject, "Access authrozied", _bn, credit, Tblocked);
        }else if (_behaviorID == 1) {
            emit isCalled(_subject, "Too frequent access", _bn, credit, Tblocked);
        }else if (_behaviorID == 2) {
            emit isCalled(_subject, "Policy check failed", _bn, credit, Tblocked);
        }else{
            emit isCalled(_subject, "Important policy check failed", _bn, credit, Tblocked);
        }
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