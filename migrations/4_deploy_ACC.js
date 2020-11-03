var AccessControlMethod = artifacts.require("AccessControlMethod")

module.exports = function(deployer, network, accounts) {
    if (network == "ganache") {
        deployer.deploy(AccessControlMethod, accounts[1], {from: accounts[2]})
    }  
}