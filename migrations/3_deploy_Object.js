var Object = artifacts.require("Object");

module.exports = function(deployer, network, accounts) {

    if (network == "ganache") {
        deployer.deploy(Object, {from: accounts[0]});
    };     
}

// Reference: Migrate script edit(https://www.sitepoint.com/truffle-migrations-explained/)