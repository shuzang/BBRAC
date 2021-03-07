BBRAC, Blockchain-based reputed access control system. It adopts the attribute-based access control model and design for IoT scenarios.

We implement this system in the Quorum blockchain using smart contract. Code and test in Remix, EVM version is byzantium, compiler version is 0.7.0, enable optimization and set 200 times. 

We have tried to deploy and test in truffle and there are some old scripts in `truffle` folder. But you should know truffle is limited because our different contracts have complex deployment and calling relationships. 


## 1. Statistics 

All contracts are in `contracts` folder, deploy them in Remix JavaScript VM environment and get Gas cost(transaction cost not execution cost). The contract size is obtained by counting the bytecode of each contract.

| contract            | transaction cost | contract size           |
| ------------------- | ---------------- | --------------          |
| Management.sol      | 2892826 gas      | 77,960 bytes(78.0 KB)   |
| Reputation.sol      | 2148487 gas      | 102,088 bytes(102.1 KB) |
| AccessControl.sol   | 4221936 gas      | 121,454 bytes(121.5 KB) |
| ABDKMathQuad.sol    | 76861 gas        | 885 bytes               |


## 2. Test preparation

### Step1: Create test network(using quorum-wizard)

```
$ npm install -g quorum-wizard
$ quorum-wizard -v

- choose simple network
- use bash scripts
- use istanbul consensus
- 4 nodes(minimum numbers of nodes)
- Quourm 2.7.0
- Tessera 0.10.5
- use Cakeshop as chain explorer
- network name: 4-nodes-istanbul-bash

```

---

use `./start.sh` to start network, Cakeshop started at http://localhost:8999 after network started

rpc and websocket port define as follows, Remix connect using rpc port, web3 connect using ws port

| Node  | rpcport | wsport|
|-------|---------|-------|
| Node1 |  22000  | 23000 |
| Node2 |  22001  | 23001 |
| Node3 |  22002  | 23002 |
| Node4 |  22003  | 23003 |


you can use `./stop.sh` to stop network and use `./attach.sh number` to attach node, number is node's number


### Step2: deploy contract, add attribute and policy

use cakeshop create new account in Node1, Node2 and Node3, then send 1000 ETH to new account

Node1 account0 deploy MC, Node1 account1 deploy RC, Node2 account1 is device that send request, Node2 account0 is manager of account0, Node3 account1 is device that receive request, Node3 account0 is mananger of account0

Note: Unlock related accounts before performing actions

1. Node1 account0 deploy MC   
    deploy account: 0xed9d02e382b34818e88B88a309c7fe71E65f419d    
    return MC address: 0x1349F3e1B8D71eFfb47B840594Ff27dA7E603d17

2. Node1 account1 deploy RC   
    deploy account: 0xa4040cEE0cF30de69A9FC617fea49F5EC29034cD    
    input: MC address      
    return RC address: 0xAEaa9A4dE3f3F59AdeAcfAb5E7D1Cd0807979f27

3. Node1 account1 setRC in MC    
    call account: 0xa4040cEE0cF30de69A9FC617fea49F5EC29034cD   
    input:
    - RC address: 0xAEaa9A4dE3f3F59AdeAcfAb5E7D1Cd0807979f27
    - RC creator: 0xa4040cEE0cF30de69A9FC617fea49F5EC29034cD

4. Node2 account0 deploy ACC  
    deploy account: 0xcA843569e3427144cEad5e4d5999a3D0cCF92B8e 
    input:
    - MC address: 0x1349F3e1B8D71eFfb47B840594Ff27dA7E603d17
    - RC address: 0xAEaa9A4dE3f3F59AdeAcfAb5E7D1Cd0807979f27
    - manager: 0xcA843569e3427144cEad5e4d5999a3D0cCF92B8e   

    return ACC address: 0x87Ec4E85245D901DE66C09c96Bd53C8146e0C12D

5. Node2 account1 deploy ACC  
    deploy account: 0xB474eDB969802f81E5BB0C977bEE3B0aB91736F8    
    input:
    - MC address: 0x1349F3e1B8D71eFfb47B840594Ff27dA7E603d17
    - RC address: 0xAEaa9A4dE3f3F59AdeAcfAb5E7D1Cd0807979f27
    - manager: 0xcA843569e3427144cEad5e4d5999a3D0cCF92B8e   

    return ACC address: 0x43FF91eECdB11B8f7a2A2A65Bc64d934d8336BED

6. Node2 account0 register    
    call account: 0xcA843569e3427144cEad5e4d5999a3D0cCF92B8e   
    input:
    - device account: 0xcA843569e3427144cEad5e4d5999a3D0cCF92B8e
    - manager account: 0xcA843569e3427144cEad5e4d5999a3D0cCF92B8e
    - ACC address: 0x87Ec4E85245D901DE66C09c96Bd53C8146e0C12D
    - deviceID: gateway202
    - deviceType: gateway
    - deviceRole: non-validator

7. Node2 account1 register    
    call account: 0xcA843569e3427144cEad5e4d5999a3D0cCF92B8e   
    input:
    - device account: 0xB474eDB969802f81E5BB0C977bEE3B0aB91736F8
    - manager account: 0xcA843569e3427144cEad5e4d5999a3D0cCF92B8e
    - ACC address: 0x43FF91eECdB11B8f7a2A2A65Bc64d934d8336BED
    - deviceID: pallat23
    - deviceType: pallat
    - deviceRole: device

8. Node3 account0 deploy ACC     
    deploy account: 0x0fBDc686b912d7722dc86510934589E0AAf3b55A    
    input:
    - MC address: 0x1349F3e1B8D71eFfb47B840594Ff27dA7E603d17
    - RC address: 0xAEaa9A4dE3f3F59AdeAcfAb5E7D1Cd0807979f27
    - manager: 0x0fBDc686b912d7722dc86510934589E0AAf3b55A   

    return ACC address: 0x9E966663fCA74605357e328994D29a3D6D614C2F

9. Node3 account1 deploy ACC  
    deploy account: 0x0c9Fd5f5212D15dcaE054a798c1C0916D286d58a    
    input:
    - MC address: 0x1349F3e1B8D71eFfb47B840594Ff27dA7E603d17
    - RC address: 0xAEaa9A4dE3f3F59AdeAcfAb5E7D1Cd0807979f27
    - manager: 0x0fBDc686b912d7722dc86510934589E0AAf3b55A   

    return ACC address: 0xfb1C803c6f1D5Ab6358a37881f67F66c45F0887c

10. Node3 account0 register   
    call account: 0x0fBDc686b912d7722dc86510934589E0AAf3b55A   
    input:
    - device account: 0x0fBDc686b912d7722dc86510934589E0AAf3b55A
    - manager account: 0x0fBDc686b912d7722dc86510934589E0AAf3b55A
    - ACC address: 0x9E966663fCA74605357e328994D29a3D6D614C2F
    - deviceID: gateway203
    - deviceType: gateway
    - deviceRole: non-validator

11. Node3 account1 register   
    call account: 0x0fBDc686b912d7722dc86510934589E0AAf3b55A   
    input:
    - device account: 0x0c9Fd5f5212D15dcaE054a798c1C0916D286d58a
    - manager account: 0x0fBDc686b912d7722dc86510934589E0AAf3b55A
    - ACC address: 0xfb1C803c6f1D5Ab6358a37881f67F66c45F0887c
    - deviceID: truck34
    - deviceType: truck
    - deviceRole: device

12. Node3 account1 addPolicy  
    call account: 0x0fBDc686b912d7722dc86510934589E0AAf3b55A   
    Call ACC: 0xfb1C803c6f1D5Ab6358a37881f67F66c45F0887c
    input:
    - resource: basicInformation
    - action: read
    - attribute owner: subject
    - attribute name: deviceID
    - operator: =
    - attribute value: pallat23
    - importance: 0

13. Node3 account1 addPolicy
    call account: 0x0fBDc686b912d7722dc86510934589E0AAf3b55A   
    Call ACC: 0xfb1C803c6f1D5Ab6358a37881f67F66c45F0887c
    input:
    - resource: location
    - action: read
    - attribute owner: subject
    - attribute name: deviceType
    - operator: =
    - attribute value: gateway
    - importance: 2

13. Node2 account1 access test(success)
14. Node2 account0 access test(failed)

### Step3: legal and illegal request
web3.js is necessary when we execute scripts, install it in root directory. All scripts are in scripts folder.

```
# 1.2.8 is the only version we tested successfully
$ npm install web3@1.2.8
```

unlock Node2 account1 10 min

```
chmod +x script/06_accessTest.sh
./script/06_accessTest.sh
```

open two new terminal

```
node script/04_monitorACC.js
node script/05_monitorRC.js
```

### Step4: Continuous misbehavior testing

1. The upper limit of reputation value is adjusted to 30
2. Switch Remix to access account (Node1 account1)
3. Initiate continuous malicious access until the number of blocked blocks reaches 32

### Step5: Transaction collect testing

```
chmod +x script/11_transCollectTest.sh
./script/11_transCollectTest.sh
```

### Step6: Blockchain size growth testing

```
chmod +x script/09_chainGrowthTest.sh
./script/09_chainGrowthTest.sh
```