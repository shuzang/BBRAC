var Web3 = require('web3');

if(typeof web3 !=='undefined'){ //检查是否已有web3实例
    web3=new Web3(web3.currentProvider);
}else{
    //否则就连接到给出节点
    web3=new Web3();
    web3.setProvider(new Web3.providers.WebsocketProvider("ws://localhost:23000"));
};

var date1 = new Date();

var connect = function() {
    web3.eth.getBlock(0, function(error, result){
        if(!error)
            console.log("connection succeed");
        else
            console.log("something wrong, connection failed");
    });
}

var getAccount = async function() {
    await connect();
    var account0;
    web3.eth.getAccounts(function(error, result){
        if(!error){
            account0=result[0];
            //console.log(account0);
            console.log("accounts:"+result);
        }
        else{
            console.log("failed to get Accoutns");
        }
    });
}


getAccount().then(function() {
    web3.eth.getBalance("0xfd441BCa68Ed8eCd6d5d4F5C173251a25E42316a").then(function(balance) {
        console.log('balance:',balance);
        console.log("test passed！");
    })
})

var date2 = new Date();
console.log(date2.getTime()-date1.getTime());
