var Judge = artifacts.require("Judge");

module.exports = function(deployer, network, accounts) {

    if (network == "ganache") {
        // deploy Register.sol
        deployer.deploy(Judge, 2, 3, {from: accounts[0]});
    };     
}

// Reference: Migrate script edit(https://www.sitepoint.com/truffle-migrations-explained/)