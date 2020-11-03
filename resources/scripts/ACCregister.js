var Web3 = require('web3');
if(typeof web3 !=='undefined'){ //检查是否已有web3实例
    web3=new Web3(web3.currentProvider);
}else{
    //否则就连接到给出节点
    web3=new Web3();
    web3.setProvider(new Web3.providers.WebsocketProvider("ws://localhost:8545"));
}

var rcAbi = [
	{
		"constant": true,
		"inputs": [
			{
				"name": "",
				"type": "bytes32"
			}
		],
		"name": "lookupTable",
		"outputs": [
			{
				"name": "scName",
				"type": "string"
			},
			{
				"name": "subject",
				"type": "address"
			},
			{
				"name": "object",
				"type": "address"
			},
			{
				"name": "creator",
				"type": "address"
			},
			{
				"name": "scAddress",
				"type": "address"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [
			{
				"name": "_methodName",
				"type": "string"
			},
			{
				"name": "_scname",
				"type": "string"
			},
			{
				"name": "_subject",
				"type": "address"
			},
			{
				"name": "_object",
				"type": "address"
			},
			{
				"name": "_creator",
				"type": "address"
			},
			{
				"name": "_scAddress",
				"type": "address"
			}
		],
		"name": "methodRegister",
		"outputs": [],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [
			{
				"name": "_methodName",
				"type": "string"
			},
			{
				"name": "_scName",
				"type": "string"
			}
		],
		"name": "methodScNameUpdate",
		"outputs": [],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [
			{
				"name": "_methodName",
				"type": "string"
			}
		],
		"name": "getContractAddr",
		"outputs": [
			{
				"name": "_scAddress",
				"type": "address"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [
			{
				"name": "_methodName",
				"type": "string"
			},
			{
				"name": "_scAddress",
				"type": "address"
			}
		],
		"name": "methodAcAddressUpdate",
		"outputs": [],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [
			{
				"name": "_oldName",
				"type": "string"
			},
			{
				"name": "_newName",
				"type": "string"
			}
		],
		"name": "methodNameUpdate",
		"outputs": [],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [
			{
				"name": "_str",
				"type": "string"
			}
		],
		"name": "stringToBytes32",
		"outputs": [
			{
				"name": "result",
				"type": "bytes32"
			}
		],
		"payable": false,
		"stateMutability": "pure",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [
			{
				"name": "_name",
				"type": "string"
			}
		],
		"name": "methodDelete",
		"outputs": [],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	}
];

web3.eth.getBlock(0, function(error, result){
	if(!error)
		console.log("connection succeed");
	else
		console.log("something wrong, connection failed");
});


var rcAddress = "0xa49fe05a90c49c44b7d533c64b8cc33e5e6d582e";
var accAddress= "0x99c8dcc26e3e8d65c257abccdf7b3a6bb88cf3db";
var register = new web3.eth.Contract(rcAbi);
register.options.address=rcAddress;

 register.methods.methodRegister("Access Control", "ACC", "0x9abf7020cc405fce60fdfb84168fb9457bde52e2", "0x44d13e0c0d91a2ebe570c58cdadef2b99bf55bc1", "0x44d13e0c0d91a2ebe570c58cdadef2b99bf55bc1",  accAddress).send({
	from: "0xe113bd7868b9a8761a7ae86603a9e9861a56815f",
	gas: 10000000
}, function (error, result){
	if(!error){
		console.log('register ACC transactionHash: ' + result);
		console.log('register succeed!');
	}
	else
		console.log(error);
 })

 register.methods.getContractAddr("Access Control").call({
	from: "0xe113bd7868b9a8761a7ae86603a9e9861a56815f",
	gas: 10000000
}, function (error, result){
	if(!error){
        console.log('acc address:' + result);
	}
	else
		console.log(error);
 })
