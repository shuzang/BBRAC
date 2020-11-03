// SPDX-License-Identifier:MIT
pragma solidity >=0.4.22 <=0.7.0;
pragma experimental ABIEncoderV2;

/* @title: management of OA for each device
   @author: shuzang
*/
contract Policy {
    address public owner;

    struct rule {
        string sa;
        string oa;
        string ea;
        string result; // Two types: allow, deny
    }

    struct policy {
        bool isValued;
        string duty;
        rule[] rules;
        string algorithm;  // determine the result when rules conflict: denyoverrides, allowoverrides
    }
    
    
    //mapping (resource, action) =>Policy for policy check
    mapping(string => mapping(string => policy)) internal policies;
    
    constructor() {
        owner = msg.sender; // 'msg.sender' is sender of current call, contract deployer for a constructor
    }
    
    /* @dev addPolicy add a policy
    */
    function addPolicy(
        string memory _resource,
        string memory _action,
        string memory _duty,
        string memory _algorithm
    ) public {
        require(msg.sender == owner, "addPolicy error: Caller is not contract owner!");
        require(!policies[_resource][_action].isValued, "addPolicy error: policy already exist!");
        policies[_resource][_action].duty = _duty;
        policies[_resource][_action].algorithm = _algorithm;
        policies[_resource][_action].isValued = true;
    }
    
    /* @dev addRule add a rule
    */
    function addRule(
        string memory _resource,
        string memory _action,
        string memory _sa,
        string memory _oa,
        string memory _ea,
        string memory _result
    ) public {
        require(msg.sender == owner, "addRule error: Caller is not contract owner!");
        policies[_resource][_action].rules.push(
            rule(_sa,_oa,_ea,_result)
        );
    }
    
    /* @dev deletePolicy delete the policy associate with resource and specified action
    */
    function deletePolicy(string memory _resource, string memory _action) public {
        require(msg.sender == owner, "deletePolicy error: Caller is not contract owner!");
        require(policies[_resource][_action].isValued, "deletePOlicy error: policy not exist!");
        delete policies[_resource][_action];
    }
    
    function deleteRule(
        string memory _resource,
        string memory _action,
        string memory _sa,
        string memory _oa,
        string memory _ea,
        string memory _result
    ) public {
        require(msg.sender == owner, "deleteRule error: Caller is not owner!");
        require(policies[_resource][_action].rules.length != 0, "deleteRule error: rule list is null!");
        for (uint256 i = 0; i < policies[_resource][_action].rules.length; i++) {
            string memory tmpSA = policies[_resource][_action].rules[i].sa;
            string memory tmpOA = policies[_resource][_action].rules[i].oa;
            string memory tmpEA = policies[_resource][_action].rules[i].ea;
            string memory tmpResult = policies[_resource][_action].rules[i].result;
            if (stringCompare(tmpSA, _sa) && stringCompare(tmpOA, _oa) && stringCompare(tmpEA, _ea) && stringCompare(tmpResult, _result)) {
                delete policies[_resource][_action].rules[i];
            }
        }
        
    }
    
    /* @dev getPolicy get the policy associate with specified resource and action
    */
    function getPolicy(string memory _resource, string memory _action) public view returns (string memory _duty, string memory _algorithm)
    {
        require(policies[_resource][_action].isValued, "getPolicy error: There is no policy for this resource and action at this time!");
        return (policies[_resource][_action].duty,policies[_resource][_action].algorithm);
    }
    
    /* @dev getPolicy get the policy associate with specified resource and action
    */
    function getRule(string memory _resource, string memory _action, uint _index) public view returns (string memory, string memory, string memory, string memory)
    {
        require(policies[_resource][_action].rules.length != 0, "getRule error: rules list is null!");
        require(_index <= policies[_resource][_action].rules.length, "getRule error: _index outrage!");
        return (
            policies[_resource][_action].rules[_index].sa,
            policies[_resource][_action].rules[_index].oa,
            policies[_resource][_action].rules[_index].ea,
            policies[_resource][_action].rules[_index].result
        );
    }
    
    function getRuleNum(string memory _resource, string memory _action) public view returns (uint256) {
        require(policies[_resource][_action].rules.length != 0, "getRule error: rules list is null!");
        return policies[_resource][_action].rules.length;
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
}    