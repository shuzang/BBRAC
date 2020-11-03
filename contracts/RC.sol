// SPDX-License-Identifier:MIT
pragma solidity ^0.7.0;

contract Register {
    struct Method{
        bytes32 scType;       //contract type
        address subject;     //the subject of the corresponding subject-object pair of the ACC;for the JC, this filed is left blank;
        address object;      //the object of the corresponding subject-object pair of the ACC;for the JC, this filed is left blank;
        address manager;     //the peer(account) who created and deployed this contract
        address scAddress;   //the address of the contract
    }
    
    mapping(bytes32=>Method) public lookupTable;
    
    /*
    register an access control contract(ACC)
    */
    function methodRegister(
        bytes32 _methodName, 
        bytes32 _sctype, 
        address _subject, 
        address _object, 
        address _manager, 
        address  _scAddress) 
        public 
    {
        //no duplicate unchecked
        bytes32 newKey = _methodName;
        lookupTable[newKey].scType = _sctype;
        lookupTable[newKey].subject = _subject;
        lookupTable[newKey].object = _object;
        lookupTable[newKey].manager = _manager;
        lookupTable[newKey].scAddress = _scAddress;
    }
    
    /*
    update the ACC information (i.e., scAddress) of an exisiting method specified by the methodName
    */
    
    function methodAcAddressUpdate(bytes32 _methodName, address _scAddress) public{
        lookupTable[_methodName].scAddress = _scAddress;
    }
    
    /*
    update the name (_oldname) of an exisiting method with a new name (_newname)
    */
    function methodNameUpdate(bytes32 _oldName, bytes32 _newName) public {
        lookupTable[_newName].scType = lookupTable[_oldName].scType;
        lookupTable[_newName].subject = lookupTable[_oldName].subject;
        lookupTable[_newName].object = lookupTable[_oldName].object;
        lookupTable[_newName].manager = lookupTable[_oldName].manager;
        lookupTable[_newName].scAddress = lookupTable[_oldName].scAddress;
        delete lookupTable[_oldName];
    }
    
    function methodDelete(bytes32 _methodName) public{
        delete lookupTable[_methodName];
    }
    
    function getContractAddr(bytes32 _methodName) public view returns (address _scAddress){
        _scAddress = lookupTable[_methodName].scAddress;
    }
}