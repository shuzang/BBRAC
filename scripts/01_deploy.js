web3.setProvider('http://localhost:7545');


var connect = function() {
    web3.eth.getBlock(0, function(error){
        if(!error)
            console.log("connection succeed");
        else
            console.log("something wrong, connection failed");
    });
}

let accounts = new Array();
var getAccount = async function() {
    await connect();
    web3.eth.getAccounts(function(error, result){
        if(!error){
            accounts[0] = result[0];
            accounts[1] = result[1];
            accounts[2] = result[2];
            //console.log(account0);
            for (var i in accounts) {
                console.log("accounts" + i +":" + accounts[i])
            }
        }
        else{
            console.log("failed to get Accoutns");
        }
    });
}


getAccount().then(function() {
    web3.eth.getBalance(accounts[0]).then(function(balance) {
        console.log('balance:',balance);
        console.log("test passed！");
    })
})




