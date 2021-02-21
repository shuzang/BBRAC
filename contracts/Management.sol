// SPDX-License-Identifier:MIT
pragma solidity >0.6.0 <0.8.0;

/// @title Manage smart contracts and device attributes
/// @author shuzang
contract Management {
    address public owner; // The ower of management contract 
    
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
        mapping (string => AttrValue) customed;   // other attribute self customed, can have no element
    }
    
    mapping(address => Device)  internal lookupTable;
    
    
    /// @dev Set contract deployer as owner
    constructor() {
        owner = msg.sender; // 'msg.sender' is sender of current call, contract deployer for a constructor
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
        lookupTable[_device].isValued = true;
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
    }
    
    /// @dev updateManager update the manager of device
    function updateManager (address _device, address _newManager) public {
        require(lookupTable[_device].isValued, "updateManager error: Device not registered!");
        require (
            msg.sender == owner || msg.sender == lookupTable[_device].manager,
            "updateManager error: Only mc owner or device manager can update device manager!"
        );
        lookupTable[_device].manager = _newManager;
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
            stringCompare(_attrName, "deviceID") || stringCompare(_attrName,"deviceType") || stringCompare(_attrName,"deviceRole"),
            "getFixedAttribute error: The attribute passed in is not a device fixed attribute!"
        );
        if (stringCompare(_attrName, "deviceID")) {
            return lookupTable[_device].deviceID;
        }
        if (stringCompare(_attrName,"deviceType")) {
            return lookupTable[_device].deviceType;
        } 
        if (stringCompare(_attrName,"deviceRole")) {
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
        if (stringCompare(_attrName, "manager")) {
            return lookupTable[_device].manager;
        }
        if (stringCompare(_attrName, "scAddress")) {
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
    
    /// @dev deleteDevice remove device from registered list
    function deleteDevice(address _device) public {
        require(lookupTable[_device].isValued, "deleteDevice error: Device not registered!");
        require (
            msg.sender == lookupTable[_device].manager,
            "deleteDevice error: Only manager can remove device!"
        );
        delete lookupTable[_device];
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