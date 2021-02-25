var Web3 = require('web3');
var web3 = new Web3(Web3.givenProvider || "ws://localhost:23001");

var scAbi = [
	{
		"inputs": [],
		"stateMutability": "nonpayable",
		"type": "constructor"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "_manufacturer",
				"type": "address"
			}
		],
		"name": "addManufacturer",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "_subject",
				"type": "address"
			},
			{
				"internalType": "string",
				"name": "_soa",
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
			},
			{
				"internalType": "string",
				"name": "_ma",
				"type": "string"
			}
		],
		"name": "addSubject",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "_manufacturer",
				"type": "address"
			}
		],
		"name": "deleteManufacturer",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "_subject",
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
				"name": "_subject",
				"type": "address"
			}
		],
		"name": "getMA",
		"outputs": [
			{
				"internalType": "string",
				"name": "",
				"type": "string"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "_subject",
				"type": "address"
			},
			{
				"internalType": "address",
				"name": "_object",
				"type": "address"
			}
		],
		"name": "getSOA",
		"outputs": [
			{
				"internalType": "string",
				"name": "",
				"type": "string"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"name": "manufacturers",
		"outputs": [
			{
				"internalType": "bool",
				"name": "",
				"type": "bool"
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
]
var scAddr = "0x1349F3e1B8D71eFfb47B840594Ff27dA7E603d17"
var mySC = new web3.eth.Contract(scAbi, scAddr);


mySC.methods.deleteObattr("0xd7107dd68050e7e35dabae85cbc9d3b83be4c8e2").send({
	from: "0xb474edb969802f81e5bb0c977bee3b0ab91736f8",
	gas: 10000000,
	gasPrice: 0
}).then(function(receipt){
	if (receipt.status) {
	   console.log("Delete attribute success")
	}
	process.exit(0);
})






