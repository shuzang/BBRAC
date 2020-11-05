// Note: Even we successfully deployed the contract with $ truffle migrate --reset, we still need to reset every time when start testrpc. 
const Management = artifacts.require("Management");
const Reputation = artifacts.require("Reputation");

contract("Management", async accounts => {

    it("should get correct Reputation contract address", async () => {
        let instance = await Management.deployed();
        // all public variable have own Getter function, rcc's Getter is rcc()
        // we get Reputation contract address via this funtion
        let result = await instance.rcc();

        assert.equal(
            result.scAddress,
            Reputation.address
        );
    })
})