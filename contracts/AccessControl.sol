// SPDX-License-Identifier:MIT
pragma solidity >0.6.0 <0.8.0;
pragma experimental ABIEncoderV2;

import "./lib/Utils.sol";

contract AccessControl {
    address public manager;
    Reputation public rc;
    Management public mc;

    event ReturnAccessResult (
        address indexed from,
        bool result,
        string msg,
        uint256 time
    );

    struct AttriValue {
        bool isValued;
        string value;
    }

    struct PolicyItem {
        //for one (resource, action) pair;
        string attrOwner; // attribute of this policyItem belong to, subject or resources
        string attrName; // attribute name
        string operator; // Conditions operator that policyItem used
        string attrValue; // Conditions that policyItem should meet
        uint importance; // Importance of this policy item, it will be submit to rc for calculating reputation hhen it is not 0
    }
    
    struct Environment {
        uint256 minInterval; //minimum allowable interval (in seconds) between two successive requests
        uint256 threshold; //threshold on NoFR, above which a misbehavior is suspected
    }

    Environment public evAttr = Environment(100, 2);
    
    struct BehaviorItem {
        uint256 ToLR; //Time of Last Request
        uint256 NoFR; //Number of frequent Requests in a short period of time
    }

    // mapping subjcetAddress => BehaviorCriteria for behavior check
    mapping(address => BehaviorItem) internal behaviors;
    
    // mapping (resource, attributeName) => attributeValue for define and search resource attribute
    mapping(string => mapping(string => AttriValue)) internal resources;
    // mapping (resource, action) =>PolicyCriteria for policy check
    mapping(string => mapping(string => PolicyItem[])) internal policies;

    /// @dev Set contract deployer as manager, set management and reputation contract address
    constructor(address _mc, address _rc, address _manager) {
        manager = _manager;
        mc = Management(_mc);
        rc = Reputation(_rc);
    }
    
    function updateEnviroment(uint256 _minInterval, uint256 _threshold) public {
        require(
            msg.sender == manager,
            "updateEnviroment error: Only acc manager can update environment value!"
        );
        evAttr.minInterval = _minInterval;
        evAttr.threshold = _threshold;
    }
    
    /// @dev updateSCAddr update management contract or reputation contract address
    function updateSCAddr(string memory scType, address _scAddress) public {
        require(
            msg.sender == manager,
            "updateSCAddr error: Only acc manager can update mc or rc address!"
        );
        require(
            Utils.stringCompare(scType, "mc") || Utils.stringCompare(scType, "rc"),
            "updateSCAddr error: Updatable contract type can only be rc or mc!"
        );
        if (Utils.stringCompare(scType, "mc")) {
            mc = Management(_scAddress);
        } else {
            rc = Reputation(_scAddress);
        }
    }
    
    /// @dev updateManager update device manager, after that only new manager can operate this access control contract
    function updateManager(address _manager) public {
        require(
            msg.sender == manager,
            "updateManager error: Only management contract can update manager address!"
        );
        manager = _manager;
        rc.reputationCompute(msg.sender, false, 2, "Device manager update", block.timestamp);
    }
    

    /// @dev addResourceAttr add resource attribute
    function addResourceAttr(
        string memory _resource,
        string memory _attrName,
        string memory _attrValue
    ) 
        public 
    {
        require(msg.sender == manager, "addResourceAttr error: Caller is not manager!");
        require(
            !resources[_resource][_attrName].isValued,
            "addResourceAttr error: Resource attribute had been setted, pleased call resourceAttrUpdate!"
        );
        resources[_resource][_attrName].value = _attrValue;
        resources[_resource][_attrName].isValued = true;
        rc.reputationCompute(msg.sender, false, 1, "Resource attribute add", block.timestamp);
    }

    /// @dev updateResourceAttr update resource attribute
    function updateResourceAttr(
        string memory _resource,
        string memory _attrName,
        string memory _attrValue
    ) 
        public 
    {
        require(msg.sender == manager, "updateResourceAttr error: Caller is not manager!");
        require(
            resources[_resource][_attrName].isValued,
            "updateResourceAttr error: Resource attribute not exist, pleased first call addResourceAttr!"
        );
        resources[_resource][_attrName].value = _attrValue;
        rc.reputationCompute(msg.sender, false, 2, "Resource attribute update", block.timestamp);
    }

    /// @dev getResourceAttr get resource attribute
    function getResourceAttr(
        string memory _resource, 
        string memory _attrName
    )
        public
        view
        returns (
            string memory _attrValue
        ) 
    {
        require(
            resources[_resource][_attrName].isValued,
            "getResourceAttr error: Resource attribute not exist!"
        );
        _attrValue = resources[_resource][_attrName].value;
    }

    /// @dev deleteResourceAttr delete the resource attribute
    function deleteResourceAttr(
        string memory _resource,
        string memory _attrName
    ) 
        public 
    {
        require(msg.sender == manager, "deleteResourceAttr error: Caller is not manager!");
        require(
            resources[_resource][_attrName].isValued,
            "deleteResourceAttr error: Resource attribute not exist, don't need delete!"
        );
        delete resources[_resource][_attrName];
        rc.reputationCompute(msg.sender, false, 3, "Resource attribute delete", block.timestamp);
    }

    /// @dev addPolicy add a policy
    ///   @notice We can't judge whether the added policy is unique, so there are security risks here
    function addPolicy(
        string memory _resource,
        string memory _action,
        string memory _attrOwner,
        string memory _attrName,
        string memory _operator,
        string memory _attrValue,
        uint _importance
    ) 
        public 
    {
        require(msg.sender == manager, "addPolicy error: Caller is not manager!");
        policies[_resource][_action].push(
            PolicyItem(_attrOwner, _attrName, _operator, _attrValue, _importance)
        );
        rc.reputationCompute(msg.sender, false, 1, "Policy add", block.timestamp);
    }

    /// @dev getPolicy get the policy associate with specified resource and action
    function getPolicy(
        string memory _resource,
        string memory _action
    ) 
        public 
        view 
        returns (
            PolicyItem[] memory
        ) 
    {
        require(
            policies[_resource][_action].length != 0, 
            "getPolicy error: There is no policy for this resource and action at this time!"
        );
        PolicyItem[] memory result = new PolicyItem[](policies[_resource][_action].length);
        for (uint256 i = 0; i < policies[_resource][_action].length; i++) {
            result[i] = PolicyItem(
                policies[_resource][_action][i].attrOwner,
                policies[_resource][_action][i].attrName,
                policies[_resource][_action][i].operator,
                policies[_resource][_action][i].attrValue,
                policies[_resource][_action][i].importance
            );
        }
        return result;
    }
    
    /// @dev getPolicyItem get the policy item associate with specified attribute name
    function getPolicyItem(
        string memory _resource,
        string memory _action,
        string memory _attrName
    ) 
        public 
        view 
        returns (
            PolicyItem[] memory
        ) 
    {
        require(
            policies[_resource][_action].length != 0, 
            "getPolicyItem error: There is no policy for this resource and action at this time!"
        );
        PolicyItem[] memory result = new PolicyItem[](policies[_resource][_action].length);
        uint num = 0;
        for (uint256 i = 0; i < policies[_resource][_action].length; i++) {
            if (Utils.stringCompare(policies[_resource][_action][i].attrName, _attrName)) {
                result[num] = PolicyItem(
                    policies[_resource][_action][i].attrOwner,
                    _attrName,
                    policies[_resource][_action][i].operator,
                    policies[_resource][_action][i].attrValue,
                    policies[_resource][_action][i].importance
                );
                num++;
            }
        }
        return result;
    }
    
    /// @dev deletePolicy delete the policy associate with resource and specified action
    function deletePolicy(string memory _resource, string memory _action) public {
        require(msg.sender == manager, "deletePolicy error: Caller is not manager!");
        require(
            policies[_resource][_action].length != 0, 
            "deletePolicy error: There is no policy for this resource and action at this time!"
        );
        delete policies[_resource][_action];
        rc.reputationCompute(msg.sender, false, 3, "Policy delete", block.timestamp);
    }
    
    /// @dev deletePolicyItem delete the policy item associate with specified attribute name
    function deletePolicyItem(string memory _resource, string memory _action, string memory _attrName) public {
        require(msg.sender == manager, "deletePolicyItem error: Caller is not manager!");
        require(
            policies[_resource][_action].length != 0, 
            "deletePolicyItem error: There is no policy for this resource and action at this time!"
        );
        for (uint256 i = 0; i < policies[_resource][_action].length; i++) {
            if (Utils.stringCompare(policies[_resource][_action][i].attrName, _attrName)) {
                delete policies[_resource][_action][i];
            }
        }
        rc.reputationCompute(msg.sender, false, 3, "Policy item delete", block.timestamp);
    }

    /// @dev stringToUint is a utility fucntion used for convert number string to uint
    function stringToUint(string memory s) public pure returns (uint256 result) {
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

    /// @dev accessControl is core fucntion
    function accessControl(string memory _resource, string memory _action) public returns (bool) {
        address subject = msg.sender;
        require (
            mc.getTimeofUnblock(subject) >= block.timestamp,
            "access error: Device is still blocked!"
        );
        
        
        string memory _curOwner;
        string memory _curAttrName;
        string memory _curOperator;
        string memory _curAttrValue;
        string memory _attrValue;
        
        bool policycheck = true;
        bool behaviorcheck = true;
        uint8 errcode;
        bool result;
        
        // unblocked state
        if ((block.timestamp - behaviors[subject].ToLR) <= evAttr.minInterval) {
            behaviors[subject].NoFR++;
            if (behaviors[subject].NoFR >= evAttr.threshold) {
                behaviorcheck = false;
            }
        } else {
            behaviors[subject].NoFR = 0;
        } 

        // check policies
        for (uint256 i = 0; i < policies[_resource][_action].length; i++) {
            _curOwner = policies[_resource][_action][i].attrOwner;
            _curAttrName = policies[_resource][_action][i].attrName;
            _curOperator = policies[_resource][_action][i].operator;
            _curAttrValue = policies[_resource][_action][i].attrValue;

            if (Utils.stringCompare(_curOwner,"subject")) {
                if (Utils.stringCompare(_curAttrName, "deviceID") || Utils.stringCompare(_curAttrName, "deviceType") || Utils.stringCompare(_curAttrName, "deviceRole")) {
                    _attrValue = mc.getFixedAttribute(subject, _curAttrName);
                } else {
                    _attrValue = mc.getCustomedAttribute(subject, _curAttrName);
                }
            } else {
                _attrValue = resources[_resource][_curAttrName].value;
            }

            if (Utils.stringCompare(_curOperator,">") && (stringToUint(_attrValue) <= stringToUint(_curAttrValue))) {
                policycheck = true;
            }
            if (Utils.stringCompare(_curOperator,"<") && (stringToUint(_attrValue) >= stringToUint(_curAttrValue))) {
                policycheck = true;
            }
            if (Utils.stringCompare(_curOperator,"=") && (!Utils.stringCompare(_attrValue,_curAttrValue))) {
                policycheck = true;
            }
            
            if (policycheck && policies[_resource][_action][i].importance != 0) {
                errcode = 4;
                break;
            }
        }
        
        if (policycheck && !behaviorcheck && errcode == 0) errcode = 1; // Static check failed!
        if (!policycheck && behaviorcheck) errcode = 2; // Misbehavior detected!
        if (policycheck && behaviorcheck) errcode = 3; // Static check failed and Misbehavior detected
        
        behaviors[subject].ToLR = block.timestamp;
        result = policycheck && behaviorcheck;
        
        if (errcode == 0) {
            rc.reputationCompute(subject, false, 4, "Access authorized", block.timestamp);
            emit ReturnAccessResult(subject, true, "Access authorized", block.timestamp);
        }
        
        if (errcode == 1) {
            rc.reputationCompute(subject, true, 1, "Too frequent access", block.timestamp);
            emit ReturnAccessResult(subject, false, "Too frequent access", block.timestamp);
        }
        
        if (errcode == 2) {
            rc.reputationCompute(subject, true, 2, "Policy check failed", block.timestamp);
            emit ReturnAccessResult(subject, false, "Policy check failed", block.timestamp);
        }
        
        if (errcode == 3) {
            rc.reputationCompute(subject, true, 3, "Policy check failed and Too frequent access", block.timestamp);
            emit ReturnAccessResult(subject, false, "Policy check failed and Too frequent access", block.timestamp);
        }
        if (errcode == 4) {
            rc.reputationCompute(subject, true, 4, "Importance check failed", block.timestamp);
            emit ReturnAccessResult(subject, false, "Importance check failed", block.timestamp);
        }
        return result;
    }

    function deleteACC() public {
        require(msg.sender == manager, "Caller is not manager!");
        selfdestruct(msg.sender);
    }
}


abstract contract Reputation {
    function reputationCompute(
        address _subject, 
        bool _ismisbehavior,
        uint8 _behaviorID,
        string memory _behavior,
        uint256  _time
    ) virtual public;
}


abstract contract Management {
    function getTimeofUnblock(address _device)  public virtual returns (uint256);

    function getFixedAttribute (
        address _device, 
        string memory _attrName
    ) public view virtual returns (string memory _attrValue);
    
    function getCustomedAttribute(
        address _device, 
        string memory _attrName
    ) public view virtual returns (string memory _attrValue);
}
