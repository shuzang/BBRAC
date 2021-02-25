var Web3 = require('web3');
var web3 = new Web3(Web3.givenProvider || "ws://localhost:23001");

var pcAbi = [
	{
		"inputs": [],
		"stateMutability": "nonpayable",
		"type": "constructor"
	},
	{
		"inputs": [
			{
				"internalType": "string",
				"name": "_resource",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "_action",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "_duty",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "_algorithm",
				"type": "string"
			}
		],
		"name": "addPolicy",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "string",
				"name": "_resource",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "_action",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "_sa",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "_oa",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "_ea",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "_result",
				"type": "string"
			}
		],
		"name": "addRule",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "string",
				"name": "_resource",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "_action",
				"type": "string"
			}
		],
		"name": "deletePolicy",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "string",
				"name": "_resource",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "_action",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "_sa",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "_oa",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "_ea",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "_result",
				"type": "string"
			}
		],
		"name": "deleteRule",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "string",
				"name": "_resource",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "_action",
				"type": "string"
			}
		],
		"name": "getPolicy",
		"outputs": [
			{
				"internalType": "string",
				"name": "_duty",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "_algorithm",
				"type": "string"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "string",
				"name": "_resource",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "_action",
				"type": "string"
			},
			{
				"internalType": "uint256",
				"name": "_index",
				"type": "uint256"
			}
		],
		"name": "getRule",
		"outputs": [
			{
				"internalType": "string",
				"name": "",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "",
				"type": "string"
			},
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
				"internalType": "string",
				"name": "_resource",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "_action",
				"type": "string"
			}
		],
		"name": "getRuleNum",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
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

var pcAddr = "0x87Ec4E85245D901DE66C09c96Bd53C8146e0C12D"
var myPC = new web3.eth.Contract(pcAbi, pcAddr);


myPC.methods.getPolicy("switch","on").send({
	from: "0xcA843569e3427144cEad5e4d5999a3D0cCF92B8e",
	gas: 10000000,
	gasPrice: 0
}).then(function(receipt){
	if (receipt.status) {
	   console.log("Get policy success")
	}
	process.exit(0);
})






