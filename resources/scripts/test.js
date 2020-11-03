var Web3 = require('web3');

if(typeof web3 !=='undefined'){ //检查是否已有web3实例
    web3=new Web3(web3.currentProvider);
}else{
    //否则就连接到给出节点
    web3=new Web3();
    web3.setProvider(new Web3.providers.WebsocketProvider("ws://localhost:8545"));
};

web3.eth.getBlock(0, function(error, result){
	if(!error)
		console.log("connection succeed");
	else
		console.log("something wrong, connection failed");
});


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

web3.eth.getBalance('0xa53EE765E7315363293dcaDCA42271bd6Ca5aFC4').then(function(balance){
    console.log('balance:',balance);
    console.log("所有操作执行完毕！");
});


