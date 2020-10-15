// SPDX-License-Identifier:MIT
pragma solidity >0.6.0 <0.8.0;

import "./lib/Utils.sol";

/// @title Manage smart contracts and device attributes
/// @author shuzang
contract Management {
    address public owner; // The ower of management contract 
    Reputation public rc;
    
    struct RCContract {
        bool isValued;       // for duplicate check
        address creator;     // the peer(account) who created and deployed reputation contract
        address scAddress;   // the address of the smart contract
    }
    
    struct AttrValue {
        bool isValued; // fro duplicate check
        string value; // attribute value
    }
    
    struct Device {
        bool isValued;                      // for duplicate check
        address manager;                    // the address of gateway which device belong to, for the gateway, is itself
        address scAddress;                  // the address of access control contract associate with device
        string  deviceID;                   // the UUID of device
        string  deviceType;                 // device type, e.g. Loudness Sensor
        string  deviceRole;                 // device role, e.g. validator, manager or device 
        uint256 timeofUnblocked;              // time when the resource is unblocked (0 if unblocked, otherwise, blocked)
        mapping (string => AttrValue) customed;   // other attribute self customed, can have no element
    }
    
    
    /// Mapping is marked internal, and write own getter function
    RCContract public rcc;
    mapping(address => Device)  internal lookupTable;
    mapping(address => bool) internal isACCAddress; // judge if a address is a access control contract address, used by Reputation contract
    
    
    /// @dev Set contract deployer as owner
    constructor() {
        owner = msg.sender; // 'msg.sender' is sender of current call, contract deployer for a constructor
    }
    
    /// @dev set reputation contract
    function setRC(address  _rc, address _creator) public {
        //duplicate unchecked
        require(
            !rcc.isValued,
            "setRC error: Reputation contract already exist!"
        );
        
        require(
            msg.sender == owner || msg.sender == _creator,
            "setRC error: Only mc owner or rc creator can register!"
        );
        
        // register
        rcc.creator = _creator;
        rcc.scAddress = _rc;
        rcc.isValued = true;
        
        // setting for contract calls
        rc = Reputation(_rc);
    }
    
    /// @dev update the information (i.e., scAddress) of a registered reputation contract
    function updateRC(address _rc) public {
        require(rcc.isValued, "Reputation contract not exist!");
        require(
            msg.sender == owner || msg.sender == rcc.creator,
            "updateRC error: Only mc owner or rc creator can update rc!"
        );

        rcc.scAddress = _rc;
        rc = Reputation(_rc);
    }
    
    /// @dev deviceRegister register device attributes
    function deviceRegister(
        address _device,
        address _manager,
        address _scAddress,
        string memory _deviceID,
        string memory _deviceType,
        string memory _deviceRole
    )
        public 
    {
        require (
            !lookupTable[_device].isValued,
            "deviceRegister error: device already registered"
        );
        
        require(
            msg.sender == _manager,
            "deviceRegister error: Only manager of device can register!"
        );
        
        lookupTable[_device].manager = _manager;
        lookupTable[_device].scAddress = _scAddress;
        lookupTable[_device].deviceID = _deviceID;
        lookupTable[_device].deviceType = _deviceType;
        lookupTable[_device].deviceRole = _deviceRole;
        lookupTable[_device].timeofUnblocked = 0;
        lookupTable[_device].isValued = true;
        //rc.reputationCompute(msg.sender, false, 1, "Device register", now ); //设备注册事件提交会触发阻塞时间更新的的回调，回调时设备未注册陷入死循环 
        isACCAddress[_scAddress] = true;
    }
    
    /// @dev addAttribute add additional attribute to the device
    function addAttribute (
        address _device,
        string memory _attrName,
        string memory _attrValue
    )
        public 
    {
        require(lookupTable[_device].isValued, "addAttribute error: Device not registered!");
        require (
            msg.sender == lookupTable[_device].manager,
            "add Attribute error: Only manager can add attribute!"
        );
        require(
            !lookupTable[_device].customed[_attrName].isValued,
            "add Attribute error: Attribute already exist!"
        );
        
        lookupTable[_device].customed[_attrName].value = _attrValue;
        lookupTable[_device].customed[_attrName].isValued = true;
        rc.reputationCompute(msg.sender, false, 1, "Attribute add", block.timestamp);
    }
    
    /// @dev updateManager update the manager of device
    function updateManager (address _device, address _newManager) public {
        require(lookupTable[_device].isValued, "updateManager error: Device not registered!");
        require (
            msg.sender == owner || msg.sender == lookupTable[_device].manager,
            "updateManager error: Only mc owner or device manager can update device manager!"
        );
        lookupTable[_device].manager = _newManager;
        rc.reputationCompute(msg.sender, false, 2, "Device manager update", block.timestamp);
    }
    
    /// @dev updateAttribute update attribute of device
    function updateAttribute (
        address _device,
        string memory _attrName,
        string memory _attrValue
    )
        public 
    {
        require(lookupTable[_device].isValued, "updateAttribute error: Device not registered!");
        require (
            msg.sender == lookupTable[_device].manager,
            "updateAttribute error: Only manager can update Attribute!"
        );
        require(
            lookupTable[_device].customed[_attrName].isValued,
            "updateAttribute error: Attribute not exist!"
        );
        lookupTable[_device].customed[_attrName].value = _attrValue;
        rc.reputationCompute(msg.sender, false, 2, "Device customed attribute update", block.timestamp);
    }
    
    /// @dev updateTimeofUnblocked update the time of unblocked, 
    /// @notice this fucntion only can be call by reputation contract
    function updateTimeofUnblocked(address _device, uint256 _timeofUnblocked) public {
        require(
            lookupTable[_device].isValued, 
            "updateTimeofUnblocked error: Device not registered!"
        );
        require(
            msg.sender == rcc.scAddress, 
            "updateTimeofUnblocked error: Only reputation contract can update time of unblock!"
        );
        lookupTable[_device].timeofUnblocked = _timeofUnblocked;
    }
    
    /// @dev get the fixed device attribute(type is string)
    function getFixedAttribute (
        address _device, 
        string memory _attrName
    ) 
        public 
        view 
        returns (
            string memory _attrValue
        ) 
    {
        require(lookupTable[_device].isValued, "getFixedAttribute error: Device not registered!");
        require(
            Utils.stringCompare(_attrName, "deviceID") || Utils.stringCompare(_attrName,"deviceType") || Utils.stringCompare(_attrName,"deviceRole"),
            "getFixedAttribute error: The attribute passed in is not a device fixed attribute!"
        );
        if (Utils.stringCompare(_attrName, "deviceID")) {
            return lookupTable[_device].deviceID;
        }
        if (Utils.stringCompare(_attrName,"deviceType")) {
            return lookupTable[_device].deviceType;
        } 
        if (Utils.stringCompare(_attrName,"deviceRole")) {
            return lookupTable[_device].deviceRole;
        }
    }
    
    /// @dev get the fixed device attribute(type is address)
    function getDeviceRelatedAddress(
        address _device, 
        string memory _attrName
    ) 
        public 
        view 
        returns (
            address _attrValue
        ) 
    {
        require(lookupTable[_device].isValued, "getDeviceRelatedAddress error: Device not registered!");
        if (Utils.stringCompare(_attrName, "manager")) {
            return lookupTable[_device].manager;
        }
        if (Utils.stringCompare(_attrName, "scAddress")) {
            return lookupTable[_device].scAddress;
        }
    }
    
    /// dev get the customed attribute
    function getCustomedAttribute(
        address _device, 
        string memory _attrName
    ) 
        public 
        view 
        returns (
            string memory _attrValue
        ) 
    {
        require(lookupTable[_device].isValued, "getCustomedAttribute error: Device not registered!");
        require(
            lookupTable[_device].customed[_attrName].isValued,
            "getCustomedAttribute error: Attribute not exist!"
        );
        return lookupTable[_device].customed[_attrName].value;
    }
    
    function getTimeofUnblocked(address _device) public view returns (uint256) {
        require(lookupTable[_device].isValued, "getTimeofUnblocked error: Device not registered!");
        return lookupTable[_device].timeofUnblocked;
    }
    
    function isContractAddress(address _scAddress) public view returns (bool) {
        return isACCAddress[_scAddress];
    }
    
    /// @dev deleteDevice remove device from registered list
    function deleteDevice(address _device) public {
        require(lookupTable[_device].isValued, "deleteDevice error: Device not registered!");
        require (
            msg.sender == lookupTable[_device].manager,
            "deleteDevice error: Only manager can remove device!"
        );
        delete lookupTable[_device];
        delete isACCAddress[lookupTable[_device].scAddress];
        rc.reputationCompute(msg.sender, false, 3, "Device delete", block.timestamp);
    }
    
    /// @dev deleteAttribute delete customed attribute
    function deleteAttribute(address _device, string memory _attrName) public {
        require(lookupTable[_device].isValued, "deleteAttribute error: device not exist!");
        require (
            msg.sender == lookupTable[_device].manager,
            "deleteAttribute error: Only owner can delete attribute!"
        );
        require (
            lookupTable[_device].customed[_attrName].isValued,
            "deleteAttribute error: Attribute not exist!"
        );
        delete lookupTable[_device].customed[_attrName];
        rc.reputationCompute(msg.sender, false, 3, "Attribute delete", block.timestamp);
    }
}    


abstract contract Reputation {
    function reputationCompute(
        address _subject, 
        bool _ismisbehavior,
        uint8 _behaviorID,
        string memory _behavior,
        uint256  _time
    ) public virtual ;
}