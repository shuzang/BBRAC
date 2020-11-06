var ABDKMathQuad = artifacts.require("ABDKMathQuad");
var Management = artifacts.require("Management");
var Reputation = artifacts.require("Reputation");

module.exports = function(deployer, network, accounts) {
    // link lib to Management and Reputation
    deployer.link(ABDKMathQuad, Reputation);

    if (network == "ganache") {
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
    } 
    // else if (network == "quorum_node1") {
    //     // deploy MC and RC, accounts[0] for MC, accounts[1] for RC
    //     deployer.deploy(Management, {from: accounts[0]}).then(function() {
    //         return deployer.deploy(Reputation, Management.address, {from: accounts[1]});
    //     });

    //     deployer.then(function() {
    //         return Management.deployed();
    //     }).then(function(instance) {
    //         b = instance;
    //         b.setRC(Reputation.address, accounts[1]);
    //     })
    // };
    

       
    // Reference: Migrate script edit(https://www.sitepoint.com/truffle-migrations-explained/)
}