// SPDX-License-Identifier:MIT
pragma solidity >=0.4.22 <=0.7.0;

/* @title: management of OA for each device
   @author: shuzang
*/
contract Object {
    address public owner;
    
    struct device{
        bool isValued;
        string  OA;
    }
    
    mapping(address => device) internal devices; // the list of legitimate devices
    
    constructor() {
        owner = msg.sender; // 'msg.sender' is sender of current call, contract deployer for a constructor
    }
    
    /* @dev addObattr add object attribute to device
    */
    function addObattr (address _device, string memory _oa) public {
        require(msg.sender == _device, "addObattr error: Only device can add attribute to itself!");
        require(
            !devices[_device].isValued,
            "addObattr error: attribute already exist!"
        );

        devices[_device].OA = _oa;
        devices[_device].isValued = true;
    }
    
    
    /* @dev deleteObattr delete object attribute of device
    */
    function deleteObattr(address _device) public {
        require(
            msg.sender == owner,
            "deleteObattr error: Only owner of OC can delete!"
        );        
        require (
            devices[_device].isValued,
            "deleteObattr error: device not exists"
        );

        delete devices[_device];
    }
    
    /*@dev getAttr get object attribute of devices
    */
    function getAttr(address _device) public view returns (string memory _oa) {
        require (
            devices[_device].isValued,
            "getAttr error: device not exists"
        );
        
        return devices[_device].OA;
    }
}    