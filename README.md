使用 truffle 进行测试、部署、交互，其中测试开发基于 Ganache, 实际部署交互基于 Quorum, Solidity 编译器版本为 0.7.0, 启用代码优化，evm 版本为 byzantium。

该分支为下面论文的复现：

> Wang P, Yue Y, Sun W, e.g. An Attribute-Based Distributed Access Control for Blockchain-enabled IoT[C/OL]//2019 International Conference on Wireless and Mobile Computing, Networking and Communications (WiMob). Barcelona, Spain: IEEE, 2019: 1–6[2020–04–02]. https://ieeexplore.ieee.org/document/8923232/. DOI:[10.1109/WiMOB.2019.8923232](https://doi.org/10.1109/WiMOB.2019.8923232).


以下是一些数据统计。

## Deploy Gas

- Subject.sol: 808091 gas
- Object.sol: 451818 gas
- Policy.sol: 1625667 gas
- AccessControl.sol: 1311810 gas

## Bytecode size

- Subject.sol: 23,760 bytes(23.8 KB)
- Object.sol: 12,431 bytes(12.4 KB) 
- Policy.sol: 49,978 bytes(50.0 KB)
- AccessControl.sol: 40,086 bytes(40.1KB)