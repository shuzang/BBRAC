利用智能合约实现的基于属性的访问控制系统，使用 truffle 进行测试、部署、交互，其中测试开发基于 Ganache, 实际部署交互基于 Quorum, Solidity 编译器版本为 0.7.0, 启用代码优化，evm 版本为 byzantium。

## 1.数据统计

### 1.1 Deploy Gas

- ABDKMathQuad.sol: 71921 gas
- Management.sol: 2559615 gas
- Reputation.sol: 3572814 gas
- AccessControl.sol: 3909846 gas

### 1.2 Bytecode size

- ABDKMathQuad.sol: 885 bytes
- Management.sol: 77,960 bytes(78.0 KB)
- Reputation.sol: 102,088 bytes(102.1 KB) 
- AccessControl.sol: 121,454 bytes(121.5 KB)

## 2. 其他说明

truffle 可以连接到 quorum，但无法用来部署合约，因为 truffle 假设每种合约只会部署一次，但是在我们的方案中每一个设备都需要部署自己的 AccessControl contract. 解决办法是不使用 truffle 自己的部署机制，使用单独的脚本或者使用 Remix。

Quourm network created by quorum-wizard. 
- choose simple network
- use bash scripts
- use istanbul consensus
- 4 nodes(minimum numbers of nodes)
- Quourm 2.7.0
- no Tessera
- use Cakeshop as chain explorer
- network name: 4-nodes-istanbul-bash

---

use `./start.sh` to start network   
use `./stop.sh` to stop network
use `./attach.sh number` to attach node, number is node's number

Cakeshop started at http://localhost:8999 after network started

rpc and websocket port define as follows

| Node  | rpcport | wsport|
|-------|---------|-------|
| Node1 |  22000  | 23000 |
| Node2 |  22001  | 23001 |
| Node3 |  22002  | 23002 |
| Node4 |  22003  | 23003 |

Remix connect using rpcport, web3 connect using wsport

## 3. deploy record

利用 Cakeshop 在 Node1 中新建一个账户，并转给新账户 1000 ETH，Node2 和 Node3 做同样的操作。  

Node1 两个账户分别部署 MC 和 RC，Node2 的两个账户分别是发起请求的设备和它的管理者，Node3 的两个账户分别是被请求的设备和它的管理者。

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
    - deviceRole: manager

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
    - deviceRole: manager

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
    input:
    - resource: location
    - action: read
    - attribute owner: subject
    - attribute name: deviceID
    - operator: =
    - attribute value: pallat23
    - importance: 0

13. Node2 account1 access test(passed)
14. Node2 account0 access test(passed)
