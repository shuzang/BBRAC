var Management = artifacts.require("Management")
var Reputation = artifacts.require("Reputation")
var AccessControl = artifacts.require("AccessControl")

module.exports = function(deployer, network, accounts) {
    //var mcAddress = ""
    //var rcAddress = ""
    if (network == "ganache") {
        deployer.deploy(AccessControl, Management.address, Reputation.address, accounts[2], {from: accounts[2]})
    }
    
}