var Web3 = require('web3');
var web3 = new Web3(Web3.givenProvider || "ws://localhost:23000");

var accAbi = [
	{
		"constant": true,
		"inputs": [
			{
				"name": "s",
				"type": "string"
			}
		],
		"name": "stringToUint",
		"outputs": [
			{
				"name": "result",
				"type": "uint256"
			}
		],
		"payable": false,
		"stateMutability": "pure",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [],
		"name": "EA",
		"outputs": [
			{
				"name": "",
				"type": "string"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [
			{
				"name": "",
				"type": "address"
			}
		],
		"name": "deviceToPC",
		"outputs": [
			{
				"name": "",
				"type": "address"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [],
		"name": "oc",
		"outputs": [
			{
				"name": "",
				"type": "address"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [],
		"name": "owner",
		"outputs": [
			{
				"name": "",
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
				"name": "_object",
				"type": "address"
			},
			{
				"name": "_resource",
				"type": "string"
			},
			{
				"name": "_action",
				"type": "string"
			}
		],
		"name": "accessControl",
		"outputs": [
			{
				"name": "",
				"type": "string"
			}
		],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [
			{
				"name": "_device",
				"type": "address"
			},
			{
				"name": "_pc",
				"type": "address"
			}
		],
		"name": "setObjectPolicyAddress",
		"outputs": [],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [],
		"name": "sc",
		"outputs": [
			{
				"name": "",
				"type": "address"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [],
		"name": "pc",
		"outputs": [
			{
				"name": "",
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
				"name": "_ea",
				"type": "string"
			}
		],
		"name": "setEA",
		"outputs": [],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [
			{
				"name": "_a",
				"type": "string"
			},
			{
				"name": "_b",
				"type": "string"
			}
		],
		"name": "strConcat",
		"outputs": [
			{
				"name": "",
				"type": "string"
			}
		],
		"payable": false,
		"stateMutability": "pure",
		"type": "function"
	},
	{
		"inputs": [
			{
				"name": "_sc",
				"type": "address"
			},
			{
				"name": "_oc",
				"type": "address"
			}
		],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "constructor"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"name": "_from",
				"type": "address"
			},
			{
				"indexed": false,
				"name": "_to",
				"type": "address"
			},
			{
				"indexed": false,
				"name": "_resource",
				"type": "string"
			},
			{
				"indexed": false,
				"name": "_action",
				"type": "string"
			},
			{
				"indexed": false,
				"name": "_time",
				"type": "uint256"
			},
			{
				"indexed": false,
				"name": "_result",
				"type": "string"
			}
		],
		"name": "ReturnAccessResult",
		"type": "event"
	}
]

var accAddr = "0xFe0602D820f42800E3EF3f89e1C39Cd15f78D283"
var myACC = new web3.eth.Contract(accAbi, accAddr);


myACC.methods.accessControl("0xb474edb969802f81e5bb0c977bee3b0ab91736f8","switch", "on").send({
	from: "0xd7107dd68050e7e35dabae85cbc9d3b83be4c8e2",
	gas: 10000000,
	gasPrice: 0
}).then(function(receipt){
	if (receipt.status) {
	   console.log("Request success")	   
	}
	process.exit(0);	
})



