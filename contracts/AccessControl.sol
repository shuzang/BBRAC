// SPDX-License-Identifier:MIT
pragma solidity >0.6.0 <0.8.0;
pragma experimental ABIEncoderV2;

contract AccessControl {
    address public manager;
    ReputationA public rc;
    ManagementA public mc;

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
        uint256 minInterval; // minimum allowable interval (in seconds) between two successive requests
        uint256 threshold; // threshold on NoFR, above which a misbehavior is suspected
        string algorithm; // determine the result when rules conflict, denyoverries and allowoverrides
    }
   
    struct BehaviorItem {
        uint256 ToLR; //Time of Last Request
        uint256 NoFR; //Number of frequent Requests in a short period of time
    }

    Environment public evAttr = Environment(100, 2, "denyoverries");

    // mapping subjcetAddress => BehaviorCriteria for behavior check
    mapping(address => BehaviorItem) internal behaviors;
    
    // mapping (resource, attributeName) => attributeValue for define and search resource attribute
    mapping(string => mapping(string => AttriValue)) internal resources;
    // mapping (resource, action) =>PolicyCriteria for policy check
    mapping(string => mapping(string => PolicyItem[])) internal policies;

    /// @dev Set contract deployer as manager, set management and reputation contract address
    constructor(address _mc, address _rc, address _manager) {
        manager = _manager;
        mc = ManagementA(_mc);
        rc = ReputationA(_rc);
    }
    
    function updateEnviroment(uint256 _minInterval, uint256 _threshold, string memory _algorithm) public {
        require(
            msg.sender == manager,
            "updateEnviroment error: Only acc manager can update environment value!"
        );
        evAttr.minInterval = _minInterval;
        evAttr.threshold = _threshold;
        evAttr.algorithm = _algorithm;
    }
    
    /// @dev updateSCAddr update management contract or reputation contract address
    function updateSCAddr(string memory scType, address _scAddress) public {
        require(
            msg.sender == manager,
            "updateSCAddr error: Only acc manager can update mc or rc address!"
        );
        require(
            stringCompare(scType, "mc") || stringCompare(scType, "rc"),
            "updateSCAddr error: Updatable contract type can only be rc or mc!"
        );
        if (stringCompare(scType, "mc")) {
            mc = ManagementA(_scAddress);
        } else {
            rc = ReputationA(_scAddress);
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
            if (stringCompare(policies[_resource][_action][i].attrName, _attrName)) {
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
            if (stringCompare(policies[_resource][_action][i].attrName, _attrName)) {
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
    function accessControl(string memory _resource, string memory _action) public returns (string memory) {
        address subject = msg.sender;
        require (
            mc.getTimeofUnblocked(subject) < block.timestamp,
            "access error: Device is still blocked!"
        );
        
        PolicyItem memory current;
        string memory _attrValue; 
        
        bool policycheck;
        bool behaviorcheck;
        uint8 errcode;
        bool[2] memory result; // result[0] record if a rule in policy match, result[1] record if a rule not match
        string memory finalResult;
        
        // unblocked state
        if ((block.timestamp - behaviors[subject].ToLR) <= evAttr.minInterval) {
            behaviors[subject].NoFR++;
            if (behaviors[subject].NoFR >= evAttr.threshold) {
                behaviorcheck = true;
            }
        } else {
            behaviors[subject].NoFR = 0;
        } 

        // check policies
        for (uint256 i = 0; i < policies[_resource][_action].length; i++) {
            current.attrOwner = policies[_resource][_action][i].attrOwner;
            current.attrName = policies[_resource][_action][i].attrName;
            current.operator = policies[_resource][_action][i].operator;
            current.attrValue = policies[_resource][_action][i].attrValue;

            if (stringCompare(current.attrOwner,"subject")) {
                if (stringCompare(current.attrName, "deviceID") || stringCompare(current.attrName, "deviceType") || stringCompare(current.attrName, "deviceRole")) {
                    _attrValue = mc.getFixedAttribute(subject, current.attrName);
                } else {
                    _attrValue = mc.getCustomedAttribute(subject, current.attrName);
                }
            } else {
                _attrValue = resources[_resource][current.attrName].value;
            }

            if (stringCompare(current.operator,">") && (stringToUint(_attrValue) <= stringToUint(current.attrValue))) {
                result[1] = true;
            } else {
                result[0] = true;
            }
            if (stringCompare(current.operator,"<") && (stringToUint(_attrValue) >= stringToUint(current.attrValue))) {
                result[1] = true;
            } else {
                result[0] = true;
            }
            if (stringCompare(current.operator,"=") && (!stringCompare(_attrValue,current.attrValue))) {
                result[1] = true;
            } else {
                result[0] = true;
            }
            
            if (result[1] && policies[_resource][_action][i].importance != 0) {
                errcode = 4;
            }
        }

        // determine policy check result when rules conflict
        if (stringCompare(evAttr.algorithm, "denyoverrides") && result[1]) {
            policycheck = true;
        }
        if (stringCompare(evAttr.algorithm, "allowoverrides") && result[0]) {
            policycheck = false;
        }
        
        if (policycheck && !behaviorcheck && errcode == 0) errcode = 1; // Static check failed!
        if (!policycheck && behaviorcheck) errcode = 2; // Misbehavior detected!
        if (policycheck && behaviorcheck) errcode = 3; // Static check failed and Misbehavior detected
        
        behaviors[subject].ToLR = block.timestamp;
        // determine final result
        if (policycheck || behaviorcheck) {
            finalResult = "deny";
        } else if (result[0] || result[1]) {
            finalResult = "allow";
        } else {
            finalResult = "NotDefine";
        }
        
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
        return finalResult;
    }

    function deleteACC() public {
        require(msg.sender == manager, "Caller is not manager!");
        selfdestruct(msg.sender);
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


abstract contract ReputationA {
    function reputationCompute(
        address _subject, 
        bool _ismisbehavior,
        uint8 _behaviorID,
        string memory _behavior,
        uint256  _time
    ) virtual public;
}


abstract contract ManagementA {
    function getTimeofUnblocked(address _device)  public virtual returns (uint256);

    function getFixedAttribute (
        address _device, 
        string memory _attrName
    ) public view virtual returns (string memory _attrValue);
    
    function getCustomedAttribute(
        address _device, 
        string memory _attrName
    ) public view virtual returns (string memory _attrValue);
}
