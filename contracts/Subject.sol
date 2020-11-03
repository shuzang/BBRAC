// SPDX-License-Identifier:MIT
pragma solidity >=0.4.22 <=0.8.0;

/* @title: manages the accounts of legitimate manufacturers, the accounts of IoT devices and all the subject attribute information of IoT
   @author: shuzang
*/
contract Subject {
    address public owner;
    
    struct attribute{
        bool isValued;
        string value;
    }
    
    struct device{
        bool isValued;
        address manufacturer;
        string  MA;  // Describe the basic initialization information of the device (such as MAC address, serial number, etc.). and MA is set by the legitimate manufacturer and can only be set once
        mapping(address => attribute) SOA;  // Only used for a pair of specific subject-object. If the object i sets a SOA to the subject j, then the SOA only take effect when j accesses i at the same time not affecting other devices.
   
    }
    
    /*
    Mapping is marked internal, and write own getter function
    */
    mapping(address => bool) public manufacturers; // the list of legitimate manufacturers
    mapping(address => device) internal devices;
    
    /**
     * @dev Set contract deployer as owner
     */
    constructor() {
        owner = msg.sender; // 'msg.sender' is sender of current call, contract deployer for a constructor
    }
    
    /* @dev addManufacturer accepts the address of a manufacturer and adds this address to the list of legitimate manufacturers
    */
    function addManufacturer(address _manufacturer) public
    {
        require (
            !manufacturers[_manufacturer],
            "addManufacturer error: Manufacturer already exists"
        );
        
        require(
            msg.sender == owner,
            "addManufacturer error: Only owner of SC can add!"
        );
        manufacturers[_manufacturer] = true;
    }
    
    /* @dev addSubject registering new IoT devices
    */
    function addSubject (address _device, string memory _ma) public {
        require(manufacturers[msg.sender], "addSubject error: Illegal manufacturer!");
        require(
            !devices[_device].isValued,
            "addSubject error: device already exist!"
        );
        
        devices[_device].isValued = true;
        devices[_device].manufacturer = msg.sender;
        devices[_device].MA = _ma;
    }
    
    /* @dev addObattr set SOA for a subject
    */
    function addObattr (address _subject, string memory _soa) public {
        require(
            devices[_subject].isValued,
            "addObattr error: device not exist!"
        );
        require(
            !devices[_subject].SOA[msg.sender].isValued,
            "addObattr error: attribute already exist!"
        );
        
        devices[_subject].SOA[msg.sender].value = _soa;
        devices[_subject].SOA[msg.sender].isValued = true;
    }
    
    /* @dev getMA get the Manufacturer Attribute
    */
    function getMA(address _subject) public view returns (string memory) {
        require(
            devices[_subject].isValued,
            "getMA error: device not exist!"
        );
        return devices[_subject].MA;
    }
    
    /* @dev getSOA get the Attribute Setting by Object
    */
    function getSOA(address _subject, address _object) public view returns (string memory) {
        require(
            devices[_subject].SOA[_object].isValued,
            "getSOA error: attribute not exist!"
        );  
        return devices[_subject].SOA[_object].value;
    }
    
    
    /* @dev deleteManufacturer deletes the manufaceurer from the manufaceurer list
    */
    function deleteManufacturer(address _manufacturer) public {
        require (
            manufacturers[_manufacturer],
            "deleteManufacturer error: Manufacturer not exists"
        );
        
        require(
            msg.sender == owner,
            "deleteManufacturer error: Only owner of SC can delete!"
        );
 
        delete manufacturers[_manufacturer];
    }
    
    /* @dev deleteObattr delete the attribute setting by object
    */
    function deleteObattr(address _subject) public {
        require (
            devices[_subject].SOA[msg.sender].isValued,
            "deleteObattr error: SOA not exist!"
        );
        delete devices[_subject].SOA[msg.sender];
    }
}    