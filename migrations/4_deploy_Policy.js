var Policy = artifacts.require("Policy");

module.exports = function(deployer, network, accounts) {

    if (network == "ganache") {
        deployer.deploy(Policy, {from: accounts[0]});
    };     
}

// Reference: Migrate script edit(https://www.sitepoint.com/truffle-migrations-explained/)