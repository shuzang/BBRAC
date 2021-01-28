var Management = artifacts.require("Management")
var Reputation = artifacts.require("Reputation")
var AccessControl = artifacts.require("AccessControl")

module.exports = async function(deployer, network, accounts) {
    if (network == "ganache") {
        // deployer.deploy(AccessControl, Management.address, Reputation.address, accounts[2], {from: accounts[2]}).then(function() {
        //     return Management.deployed();
        // });
        deployer.deploy(
            AccessControl, 
            Management.address, 
            Reputation.address, 
            accounts[1], // manager
            {from: accounts[1]} // deploy by itself
        ) 
        
        // let manager = await Management.deployed();
        // //console.log(manager)
        // await manager.deviceRegister(
        //     accounts[1], // device account
        //     accounts[1], // mananger account
        //     AccessControl.address,
        //     "server1",
        //     "server",
        //     "manager",
        //     {from:accounts[1]} // register by manager
        // )
            
        // let mID = await manager.getFixedAttribute(
        //     accounts[1],
        //     "deviceID"
        // );
        // console.log(mID)
    } 
    
    // if (network == "quorum_node2") {
    //     deployer.deploy(
    //         AccessControl, 
    //         Management.address, 
    //         Reputation.address, 
    //         accounts[1], // manager
    //         {from: accounts[1]} // deploy by itself
    //     ).then(function() {
    //         return Management.deployed();
    //     }.then(function(instance) {
    //         return instance.deviceRegister(
    //             accounts[1], // device account
    //             accounts[1], // mananger account
    //             AccessControl.address,
    //             "server1",
    //             "server",
    //             "manager",
    //             {from:accounts[1]} // register by manager
    //         )
    //     }));
    // }    
}