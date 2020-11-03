var ABDKMathQuad = artifacts.require("ABDKMathQuad");
var Management = artifacts.require("Management");
var Reputation = artifacts.require("Reputation");

module.exports = function(deployer, network, accounts) {
    // link lib to Management and Reputation
    deployer.link(ABDKMathQuad, Reputation);

    if (network == "ganache") {
        //var a,b;
        // deploy management and Reputation
        deployer.deploy(Management, {from: accounts[0]}).then(function() {  
            return deployer.deploy(Reputation, Management.address, {from: accounts[1]});                  
        });

        deployer.then(function() {
            return Management.deployed();
        }).then(function(instance) {
            a = instance;
            a.setRC(Reputation.address, accounts[1]);
        }) 
    };
    

       
    // Reference: Migrate script edit(https://www.sitepoint.com/truffle-migrations-explained/)
}