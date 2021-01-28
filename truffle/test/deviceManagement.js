// Note: Even we successfully deployed the contract with $ truffle migrate --reset, we still need to reset every time when start testrpc. 
const Management = artifacts.require("Management");

contract("Management", async accounts => {
    let account_one = accounts[0]
    let account_two = accounts[1]

    it("should register a device", async () => {
        let instance = await Management.deployed();
        //console.log(accounts);

        await instance.deviceRegister(
            account_one,
            account_two,
            "0x19455cac7bd27705661d467e20ee82b1cc48737b",
            "gateway33",
            "gateway",
            "manager",
            {from:account_two}
        );
    });

    it("should get correct register information", async () => {
        let instance = await Management.deployed();

        let ID = await instance.getFixedAttribute(
            account_one,
            "deviceID"
        );

        let Type = await instance.getFixedAttribute(
            account_one,
            "deviceType"
        );

        let Role = await instance.getFixedAttribute(
            account_one,
            "deviceRole"
        );

        assert.equal(
            ID,
            "gateway33"
        );

        assert.equal(
            Type,
            "gateway"
        );

        assert.equal(
            Role,
            "manager"
        );

        let manager = await instance.getDeviceRelatedAddress(
            account_one,
            "manager"
        );

        let scAddress = await instance.getDeviceRelatedAddress(
            account_one,
            "scAddress"
        );

        assert.equal(
            manager,
            account_two
        )

        assert.equal(
            scAddress.toLowerCase(),
            "0x19455cac7bd27705661d467e20ee82b1cc48737b"
        )

    });


    // it("should remove device from gegistered list", async () => {
    //     let instance = await Management.deployed();
    //     await instance.deleteDevice(account_one, {from:account_two});
    // })
})