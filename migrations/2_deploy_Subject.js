var Subject = artifacts.require("Subject");

module.exports = function(deployer, network, accounts) {

    if (network == "ganache") {
        deployer.deploy(Subject, {from: accounts[0]});
    };     
}

// Reference: Migrate script edit(https://www.sitepoint.com/truffle-migrations-explained/)