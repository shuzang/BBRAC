var Web3 = require('web3');
var web3 = new Web3(Web3.givenProvider || "ws://localhost:23001");

var accAbi = [
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "_mc",
				"type": "address"
			},
			{
				"internalType": "address",
				"name": "_rc",
				"type": "address"
			},
			{
				"internalType": "address",
				"name": "_manager",
				"type": "address"
			}
		],
		"stateMutability": "nonpayable",
		"type": "constructor"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "address",
				"name": "from",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "string",
				"name": "result",
				"type": "string"
			},
			{
				"indexed": false,
				"internalType": "uint8",
				"name": "behaviorID",
				"type": "uint8"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "bn",
				"type": "uint256"
			}
		],
		"name": "ReturnAccessResult",
		"type": "event"
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
		"name": "accessControl",
		"outputs": [
			{
				"internalType": "string",
				"name": "",
				"type": "string"
			}
		],
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
				"name": "_attrOwner",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "_attrName",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "_operator",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "_attrValue",
				"type": "string"
			},
			{
				"internalType": "uint256",
				"name": "_importance",
				"type": "uint256"
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
				"name": "_attrName",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "_attrValue",
				"type": "string"
			}
		],
		"name": "addResourceAttr",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "deleteACC",
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
				"name": "_attrName",
				"type": "string"
			}
		],
		"name": "deletePolicyItem",
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
				"name": "_attrName",
				"type": "string"
			}
		],
		"name": "deleteResourceAttr",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "evAttr",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "minInterval",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "threshold",
				"type": "uint256"
			},
			{
				"internalType": "string",
				"name": "algorithm",
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
		"name": "getPolicy",
		"outputs": [
			{
				"components": [
					{
						"internalType": "string",
						"name": "attrOwner",
						"type": "string"
					},
					{
						"internalType": "string",
						"name": "attrName",
						"type": "string"
					},
					{
						"internalType": "string",
						"name": "operator",
						"type": "string"
					},
					{
						"internalType": "string",
						"name": "attrValue",
						"type": "string"
					},
					{
						"internalType": "uint256",
						"name": "importance",
						"type": "uint256"
					}
				],
				"internalType": "struct AccessControl.PolicyItem[]",
				"name": "",
				"type": "tuple[]"
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
				"internalType": "string",
				"name": "_attrName",
				"type": "string"
			}
		],
		"name": "getPolicyItem",
		"outputs": [
			{
				"components": [
					{
						"internalType": "string",
						"name": "attrOwner",
						"type": "string"
					},
					{
						"internalType": "string",
						"name": "attrName",
						"type": "string"
					},
					{
						"internalType": "string",
						"name": "operator",
						"type": "string"
					},
					{
						"internalType": "string",
						"name": "attrValue",
						"type": "string"
					},
					{
						"internalType": "uint256",
						"name": "importance",
						"type": "uint256"
					}
				],
				"internalType": "struct AccessControl.PolicyItem[]",
				"name": "",
				"type": "tuple[]"
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
				"name": "_attrName",
				"type": "string"
			}
		],
		"name": "getResourceAttr",
		"outputs": [
			{
				"internalType": "string",
				"name": "_attrValue",
				"type": "string"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "manager",
		"outputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "mc",
		"outputs": [
			{
				"internalType": "contract Management",
				"name": "",
				"type": "address"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "rc",
		"outputs": [
			{
				"internalType": "contract Reputation",
				"name": "",
				"type": "address"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "string",
				"name": "a",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "b",
				"type": "string"
			}
		],
		"name": "stringCompare",
		"outputs": [
			{
				"internalType": "bool",
				"name": "",
				"type": "bool"
			}
		],
		"stateMutability": "pure",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "string",
				"name": "s",
				"type": "string"
			}
		],
		"name": "stringToUint",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "result",
				"type": "uint256"
			}
		],
		"stateMutability": "pure",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "_minInterval",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "_threshold",
				"type": "uint256"
			},
			{
				"internalType": "string",
				"name": "_algorithm",
				"type": "string"
			}
		],
		"name": "updateEnviroment",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "_manager",
				"type": "address"
			}
		],
		"name": "updateManager",
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
				"name": "_attrName",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "_attrValue",
				"type": "string"
			}
		],
		"name": "updateResourceAttr",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "string",
				"name": "scType",
				"type": "string"
			},
			{
				"internalType": "address",
				"name": "_scAddress",
				"type": "address"
			}
		],
		"name": "updateSCAddr",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	}
];
var accAddr = "0xfb1C803c6f1D5Ab6358a37881f67F66c45F0887c";
var myACC = new web3.eth.Contract(accAbi, accAddr);

myACC.events.ReturnAccessResult({
	fromBlock: 0
}, function(error, result){
		if(!error) {
			console.log("Contract address: "+result.address);
			console.log("Tx Hash: "+result.transactionHash);
			console.log("Request from: "+result.returnValues.from);
			console.log("Access result: "+result.returnValues.result);
			console.log("Behavior ID: "+result.returnValues.behaviorID);
			console.log("Block number(submit to RC): "+result.returnValues.bn);
			console.log('\n');
		}
})


