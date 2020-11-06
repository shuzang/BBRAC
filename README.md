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