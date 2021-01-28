var ABDKMathQuad = artifacts.require("ABDKMathQuad")

module.exports = function(deployer) {
    // deploy ABDKMathQuad.sol
    deployer.deploy(ABDKMathQuad);
}
