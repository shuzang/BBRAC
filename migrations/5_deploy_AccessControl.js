var Subject = artifacts.require("Subject");
var Object = artifacts.require("Object");
var AccessControl = artifacts.require("AccessControl");

module.exports = function(deployer, network, accounts) {
    if (network == "ganache") {
        deployer.deploy(AccessControl, Subject.address,Object.address, {from: accounts[1]});
    }  
}