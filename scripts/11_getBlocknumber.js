var Web3 = require('web3');

if(typeof web3 !=='undefined'){ //检查是否已有web3实例
    web3=new Web3(web3.currentProvider);
}else{
    //否则就连接到给出节点
    web3=new Web3();
    web3.setProvider(new Web3.providers.WebsocketProvider("ws://localhost:23000"));
};

web3.eth.getBlockNumber(function (error, result) {
  if(!error) {
    console.log(result);
    process.exit(0)
  }
})


