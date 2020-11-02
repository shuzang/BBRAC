var ABDKMathQuad = artifacts.require("ABDKMathQuad")
var Utils = artifacts.require("Utils")

module.exports = function(deployer) {
    // deploy ABDKMathQuad.sol
    deployer.deploy(ABDKMathQuad);
    // deploy Utils.sol
    deployer.deploy(Utils);
}
