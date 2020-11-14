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

create record

---

Simple Network  
Would you like to generate bash scripts, a docker-compose file, or a kubernete
s config to bring up your network? bash 
Select your consensus mode - istanbul is a pbft inspired algorithm with transa
ction finality while raft provides faster blocktimes, transaction finality and o
n-demand block creation：istanbul    
Input the number of nodes (2-7) you would like in your network - a minimum of 
4 is recommended：4  
Which version of Quorum would you like to use? Quorum 2.6.0   
Choose a version of tessera if you would like to use private transactions in y
our network, otherwise choose "none"：none  
Do you want to run Cakeshop (our chain explorer) with your network? Yes  
What would you like to call this network? 4-nodes-istanbul-bash

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

利用 Cakeshop 在 Node1 中新建一个账户，并转给新账户 100 ETH，Node2 和 Node3 做同样的操作。  

Node1 两个账户分别部署 MC 和 RC，Node2 的两个账户分别是发起请求的设备和它的管理者，Node3 的两个账户分别是被请求的设备和它的管理者。

1. Node1 部署 MC    
   部署账户：0xed9d02e382b34818e88B88a309c7fe71E65f419d  
   传入参数：无  
   返回 MC 合约地址：0x1349F3e1B8D71eFfb47B840594Ff27dA7E603d17

2. Node1 部署 RC
   部署账户：0xa74F7187C65d308561110C7D8364351d89ad93F8
   传入参数：MC 合约地址
   返回 RC 合约地址：0x701A33C69909dD8Cd9B5b0f7A5E56893ac3dcF9f

3. Node1 设置 RC
   调用账户：0xa74F7187C65d308561110C7D8364351d89ad93F8
   传入参数：RC 合约地址，RC 部署账户

4. Node2 账户1 部署 ACC
   部署账户：0xcA843569e3427144cEad5e4d5999a3D0cCF92B8e
   传入参数：
   - MC 合约地址：0x1349F3e1B8D71eFfb47B840594Ff27dA7E603d17
   - RC 合约地址：0x701A33C69909dD8Cd9B5b0f7A5E56893ac3dcF9f
   - 管理者账户：0xcA843569e3427144cEad5e4d5999a3D0cCF92B8e

    返回 ACC 合约地址：0x87Ec4E85245D901DE66C09c96Bd53C8146e0C12D

5. Node2 账户1 注册 ACC
   调用账户：0xcA843569e3427144cEad5e4d5999a3D0cCF92B8e
   传入参数：
   - 设备账户：0xcA843569e3427144cEad5e4d5999a3D0cCF92B8e
   - 管理者账户：0xcA843569e3427144cEad5e4d5999a3D0cCF92B8e
   - 合约地址：0x87Ec4E85245D901DE66C09c96Bd53C8146e0C12D
   - 设备ID：gateway202
   - 设备类型：gateway
   - 设备角色：manager

6. Node2 账户2 部署 ACC
   部署账户：0xeeBFCA7A2951CCFf05DD98DC0F3f1fe180baDE2e
   传入参数:
   - MC 合约地址：0x1349F3e1B8D71eFfb47B840594Ff27dA7E603d17
   - RC 合约地址：0x701A33C69909dD8Cd9B5b0f7A5E56893ac3dcF9f
   - 管理者账户：0xcA843569e3427144cEad5e4d5999a3D0cCF92B8e

    返回 ACC 合约地址：0xFA260A50F46589611a6C3C2dFD31f0F3b4730Db6

7. Node2 账户2 注册 ACC
   调用账户：0xcA843569e3427144cEad5e4d5999a3D0cCF92B8e
   传入参数：
   - 设备账户：0xeeBFCA7A2951CCFf05DD98DC0F3f1fe180baDE2e
   - 管理者账户：0xcA843569e3427144cEad5e4d5999a3D0cCF92B8e
   - 合约地址：0xFA260A50F46589611a6C3C2dFD31f0F3b4730Db6
   - 设备ID：pallat23
   - 设备类型：pallat
   - 设备角色：device

8. Node3 账户1 部署 ACC
   部署账户：0x0fBDc686b912d7722dc86510934589E0AAf3b55A
   返回 ACC 合约地址：0x9E966663fCA74605357e328994D29a3D6D614C2F

9. Node3 账户2 部署 ACC
    部署账户：0xced993C378a9F92491ac0921573959c5e5E3ED04
    返回 ACC 合约地址：0x15C6D8a018f1C4f7CcB0cD8cf51E33b265fe62B1

10. Node3 账户1 注册 自身
    调用账户：0x0fBDc686b912d7722dc86510934589E0AAf3b55A
    传入参数：
   - 设备账户：0x0fBDc686b912d7722dc86510934589E0AAf3b55A
   - 管理者账户：0x0fBDc686b912d7722dc86510934589E0AAf3b55A
   - 合约地址：0x9E966663fCA74605357e328994D29a3D6D614C2F
   - 设备ID：gateway203
   - 设备类型：gateway
   - 设备角色：manager

11. Node3 账户2 注册设备
    调用账户：0x0fBDc686b912d7722dc86510934589E0AAf3b55A
    传入参数：
   - 设备账户：0xced993C378a9F92491ac0921573959c5e5E3ED04
   - 管理者账户：0x0fBDc686b912d7722dc86510934589E0AAf3b55A
   - 合约地址：0x15C6D8a018f1C4f7CcB0cD8cf51E33b265fe62B1
   - 设备ID：truck13
   - 设备类型：truck
   - 设备角色：device

12. Node2 账户2 添加策略
    调用账户：0x0fBDc686b912d7722dc86510934589E0AAf3b55A
    传入参数：
    - 资源：GPS
    - 操作：read
    - 属性所有者：subject
    - 属性名：deviceID
    - 操作符：=
    - 属性值：pallat23
    - 重要级别：0

