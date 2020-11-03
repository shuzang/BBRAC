// SPDX-License-Identifier:MIT
pragma solidity >=0.4.22 <=0.7.0;
pragma experimental ABIEncoderV2;

contract AccessControl {
    address public owner;
    SubjectA public sc;
    ObjectA public oc;
    PolicyA public pc;

    event ReturnAccessResult(
        address indexed _from,
        address _to,
        string _resource,
        string _action,
        uint256 _time,
        string _result
    );

    string public EA;

    mapping(address => address) public deviceToPC;

    /**
     * @dev Set contract deployer as manager, set management and reputation contract address
     */
    constructor(address _sc, address _oc) {
        owner = msg.sender;
        sc = SubjectA(_sc);
        oc = ObjectA(_oc);
    }
    
    /* @dev stringCompare determine whether the strings are equal, using length + hash comparson to reduce gas consumption
    */
    function stringCompare(string memory a, string memory b) internal pure returns (bool) {
        bytes memory _a = bytes(a);
        bytes memory _b = bytes(b);
        if (_a.length != _b.length) {
            return false;
        }else{
            if (_a.length == 1) {
                return _a[0] == _b[0];
            }else{
                return keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b));
            }
            
        }
    }
    
    function setEA(string memory _ea) public {
        require(
            msg.sender == owner,
            "setEA error: Only acc owner can set ea!"
        );
        EA = _ea;
    }
    
    function setObjectPolicyAddress(address _device, address _pc) public {
        require(
            msg.sender == _device,
            "setObjectPolicyAddress error: Only device itself can binding device address and pc address!"
        );        
        deviceToPC[_device] = _pc;
    }


    /* @dev accessControl is core fucntion
    */
    function accessControl(address _object, string memory _resource, string memory _action)
        public
        returns (string memory)
    {
        string memory _ma;
        string memory _soa;
        string memory _sa;
        string memory _oa;
        address _pc = deviceToPC[_object];
        
        string[4] memory curRule;
        string[2] memory curPolicy;
        
        string[3] memory result;
        string memory finalresult;
        
        _ma = sc.getMA(msg.sender);
        _soa = sc.getSOA(msg.sender,_object);
        _sa = strConcat(_ma,_soa);
        
        _oa = oc.getAttr(_object);
        pc = PolicyA(_pc);
        (curPolicy[0],curPolicy[1]) = pc.getPolicy(_resource,_action);
        uint256 num = pc.getRuleNum(_resource,_action);

        //check _rules
        for (uint i = 0; i < num; i++) {
            (curRule[0],curRule[1],curRule[2],curRule[3]) = pc.getRule(_resource,_action,i);
            if (stringCompare(curRule[0],_sa) && stringCompare(curRule[1],_oa) && stringCompare(curRule[2],EA)) {
                if (stringCompare(curRule[3],"deny")) {
                    result[0] = "deny";
                }else{
                    result[1] = "allow";              
                }
            }else{
                result[2] = "NotApplicable";
            }
        }
        
        if (stringCompare(curPolicy[1],"denyoverrides")) {
            if (stringCompare(result[0], "deny")) {
                finalresult = "deny";
            }else if (stringCompare(result[1], "allow")) {
                finalresult = "allow";
            }else{
                finalresult = "NotApplicable";
            }
        }
        
        if (stringCompare(curPolicy[1], "allowoverrides") && stringCompare(result[1], "allow")) {
            if (stringCompare(result[1], "allow")) {
                finalresult = "allow";
            }else if (stringCompare(result[0], "deny")) {
                finalresult = "deny";
            }else{
                finalresult = "NotApplicable";
            }
        }
        
        if (stringCompare(curPolicy[0],"record")) {
            emit ReturnAccessResult(msg.sender,_object,_resource,_action,block.timestamp,finalresult);
        }
        return finalresult;
    }
    
    /* @dev stringToUint is a utility fucntion used for convert number string to uint
    */
    function stringToUint(string memory s)
        public
        pure
        returns (uint256 result)
    {
        bytes memory b = bytes(s);
        uint256 i;
        result = 0;
        for (i = 0; i < b.length; i++) {
            uint8 c = uint8(b[i]);
            if (c >= 48 && c <= 57) {
                result = result * 10 + (c - 48);
            }
        }
    }
    
    // contact two strings
    function strConcat(string memory _a, string memory _b) public pure returns (string memory){
        bytes memory _ba = bytes(_a);
        bytes memory _bb = bytes(_b);
        string memory ret = new string(_ba.length + _bb.length);
        bytes memory bret = bytes(ret);
        uint k = 0;
        for (uint i = 0; i < _ba.length; i++) {
           bret[k++] = _ba[i]; 
        }
        
        for (uint i = 0; i < _bb.length; i++) {
            bret[k++] = _bb[i];
        }
        return string(ret);
   } 
}

abstract contract SubjectA {
    function getMA(address _subject) public virtual view returns (string memory);
    function getSOA(address _subject, address _object) public virtual view returns (string memory);  
}

abstract contract ObjectA {
    function getAttr(address _device) public virtual view returns (string memory _oa);
}

abstract contract PolicyA {
    function getPolicy(string memory _resource, string memory _action) public virtual view returns (string memory _duty, string memory _algorithm);
    function getRule(string memory _resource, string memory _action, uint _index) public virtual view returns (string memory, string memory, string memory, string memory);
    function getRuleNum(string memory _resource, string memory _action) public virtual view returns (uint256);
}