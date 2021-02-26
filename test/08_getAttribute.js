var Web3 = require('web3');
var web3 = new Web3(Web3.givenProvider || "ws://localhost:23001");

var ocAbi = [
	{
		"inputs": [],
		"stateMutability": "nonpayable",
		"type": "constructor"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "_device",
				"type": "address"
			},
			{
				"internalType": "string",
				"name": "_oa",
				"type": "string"
			}
		],
		"name": "addObattr",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "_device",
				"type": "address"
			}
		],
		"name": "deleteObattr",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "_device",
				"type": "address"
			}
		],
		"name": "getAttr",
		"outputs": [
			{
				"internalType": "string",
				"name": "_oa",
				"type": "string"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "owner",
		"outputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"stateMutability": "view",
		"type": "function"
	}
];
var ocAddr = "0x9d13C6D3aFE1721BEef56B55D303B09E021E27ab"
var myOC = new web3.eth.Contract(ocAbi, ocAddr);


myOC.methods.getAttr("0xb474edb969802f81e5bb0c977bee3b0ab91736f8").send({
	from: "0xb474edb969802f81e5bb0c977bee3b0ab91736f8",
	gas: 10000000,
	gasPrice: 0
}).then(function(receipt){
	if (receipt.status) {
	   console.log("Get attribute success")
	}
	process.exit(0);
})






