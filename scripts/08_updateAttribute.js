var Web3 = require('web3');
var web3 = new Web3(Web3.givenProvider || "ws://localhost:23001");

var mcAbi = [
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
				"name": "_attrName",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "_attrValue",
				"type": "string"
			}
		],
		"name": "addAttribute",
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
				"name": "_attrName",
				"type": "string"
			}
		],
		"name": "deleteAttribute",
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
		"name": "deleteDevice",
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
				"internalType": "address",
				"name": "_manager",
				"type": "address"
			},
			{
				"internalType": "address",
				"name": "_scAddress",
				"type": "address"
			},
			{
				"internalType": "string",
				"name": "_deviceID",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "_deviceType",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "_deviceRole",
				"type": "string"
			}
		],
		"name": "deviceRegister",
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
				"name": "_attrName",
				"type": "string"
			}
		],
		"name": "getCustomedAttribute",
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
		"inputs": [
			{
				"internalType": "address",
				"name": "_device",
				"type": "address"
			},
			{
				"internalType": "string",
				"name": "_attrName",
				"type": "string"
			}
		],
		"name": "getDeviceRelatedAddress",
		"outputs": [
			{
				"internalType": "address",
				"name": "_attrValue",
				"type": "address"
			}
		],
		"stateMutability": "view",
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
				"name": "_attrName",
				"type": "string"
			}
		],
		"name": "getFixedAttribute",
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
				"internalType": "address",
				"name": "_device",
				"type": "address"
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
		"name": "updateAttribute",
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
				"internalType": "address",
				"name": "_newManager",
				"type": "address"
			}
		],
		"name": "updateManager",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	}
];

var mcAddr = "0x1349F3e1B8D71eFfb47B840594Ff27dA7E603d17"
var myMC = new web3.eth.Contract(mcAbi, mcAddr);


//console.log("Send access request...\n")

var timeStamp = new Date().getTime();
var attrValue = formatDate(timeStamp)

//const args = process.argv.slice(2)


myMC.methods.updateAttribute("0xcA843569e3427144cEad5e4d5999a3D0cCF92B8e", "currentTime", attrValue).send({
	from: "0xcA843569e3427144cEad5e4d5999a3D0cCF92B8e",
	gas: 10000000,
	gasPrice: 0
}).then(function(receipt){
	if (receipt.status) {
	   console.log("Update attribute success")
	}
	process.exit(0);
})

function formatDate(value) {
  var date = new Date(value);
  var y = date.getFullYear(),
    m = date.getMonth() + 1,
    d = date.getDate(),
    h = date.getHours(),
    i = date.getMinutes(),
    s = date.getSeconds();
  if (m < 10) { m = '0' + m; }
  if (d < 10) { d = '0' + d; }
  if (h < 10) { h = '0' + h; }
  if (i < 10) { i = '0' + i; }
  if (s < 10) { s = '0' + s; }
  var t = y + '-' + m + '-' + d + ' ' + h + ':' + i + ':' + s;
  return t;
}





