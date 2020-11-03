var Web3 = require('web3');
var web3 = new Web3(Web3.givenProvider || "ws://192.168.191.4:8545");

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

var accAbi = [
	{
		"constant": true,
		"inputs": [],
		"name": "subject",
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
		"name": "object",
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
				"name": "_jc",
				"type": "address"
			}
		],
		"name": "setJC",
		"outputs": [],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [
			{
				"name": "_resource",
				"type": "string"
			},
			{
				"name": "_action",
				"type": "string"
			}
		],
		"name": "getPolicy",
		"outputs": [
			{
				"name": "_permission",
				"type": "string"
			},
			{
				"name": "_minInterval",
				"type": "uint256"
			},
			{
				"name": "_threshold",
				"type": "uint256"
			},
			{
				"name": "_ToLR",
				"type": "uint256"
			},
			{
				"name": "_NoFR",
				"type": "uint256"
			},
			{
				"name": "_res",
				"type": "bool"
			},
			{
				"name": "_errcode",
				"type": "uint8"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [],
		"name": "jc",
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
				"name": "_resource",
				"type": "string"
			},
			{
				"name": "_action",
				"type": "string"
			}
		],
		"name": "policyDelete",
		"outputs": [],
		"payable": false,
		"stateMutability": "nonpayable",
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
				"name": "_resource",
				"type": "string"
			},
			{
				"name": "_action",
				"type": "string"
			},
			{
				"name": "_newThreshold",
				"type": "uint256"
			}
		],
		"name": "thresholdUpdate",
		"outputs": [],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [
			{
				"name": "_resource",
				"type": "string"
			}
		],
		"name": "getTimeofUnblock",
		"outputs": [
			{
				"name": "_penalty",
				"type": "uint256"
			},
			{
				"name": "_timeOfUnblock",
				"type": "uint256"
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
				"name": "_resource",
				"type": "string"
			},
			{
				"name": "_action",
				"type": "string"
			},
			{
				"name": "_permission",
				"type": "string"
			},
			{
				"name": "_minInterval",
				"type": "uint256"
			},
			{
				"name": "_threshold",
				"type": "uint256"
			}
		],
		"name": "policyAdd",
		"outputs": [],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [
			{
				"name": "_resource",
				"type": "string"
			},
			{
				"name": "_action",
				"type": "string"
			},
			{
				"name": "_newMinInterval",
				"type": "uint256"
			}
		],
		"name": "minIntervalUpdate",
		"outputs": [],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [
			{
				"name": "_resource",
				"type": "string"
			},
			{
				"name": "_action",
				"type": "string"
			},
			{
				"name": "_time",
				"type": "uint256"
			}
		],
		"name": "accessControl",
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
				"name": "_resource",
				"type": "string"
			},
			{
				"name": "_action",
				"type": "string"
			},
			{
				"name": "_newPermission",
				"type": "string"
			}
		],
		"name": "policyUpdate",
		"outputs": [],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [],
		"name": "deleteACC",
		"outputs": [],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"name": "_subject",
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
				"name": "_errmsg",
				"type": "string"
			},
			{
				"indexed": false,
				"name": "_result",
				"type": "bool"
			},
			{
				"indexed": false,
				"name": "_time",
				"type": "uint256"
			},
			{
				"indexed": false,
				"name": "_penalty",
				"type": "uint256"
			}
		],
		"name": "ReturnAccessResult",
		"type": "event"
	}
];

var rcAddr = "0xa49fe05a90c49c44b7d533c64b8cc33e5e6d582e";

var methodName = "Access Control";
var register = new web3.eth.Contract(rcAbi, rcAddr);
register.methods.getContractAddr(methodName).call({
	from: "0x44d13e0c0d91a2ebe570c58cdadef2b99bf55bc1",
	gas: 10000000
},function(error,result){
	if(!error) {
		listen(result);
	}
});


function listen(accAddr) {
	var myACC = new web3.eth.Contract(accAbi, accAddr);

	myACC.events.ReturnAccessResult({
		fromBlock: 0
	}, function(error, result){
		    if(!error) {
				console.log("Contract: "+result.address);
				console.log("Block Number: "+result.blockNumber);
				console.log("Tx Hash: "+result.transactionHash);
				console.log("Block Hash: "+result.blockHash);
				console.log("Time: "+result.returnValues._time);
				console.log("Message: "+result.returnValues._errmsg);
				console.log("Result: "+result.returnValues._result);
				if (result.returnValues._penalty > 0) {
					console.log("Requests are blocked for " + result.returnValues._penalty +"seconds!")
				}
				console.log('\n');
	    	}
	})
}

