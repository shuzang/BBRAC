使用 truffle 进行测试、部署、交互，其中测试开发基于 Ganache, 实际部署交互基于 Quorum, Solidity 编译器版本为 0.7.0, 启用代码优化，evm 版本为 byzantium。

该分支为下面论文的复现：

> Zhang Y, Kasahara S, Shen Y, e.g. Smart Contract-Based Access Control for the Internet of Things[J]. IEEE Internet of Things Journal, 2019, 6(2): 1594–1605. DOI:[10.1109/JIOT.2018.2847705](https://doi.org/10.1109/JIOT.2018.2847705).



以下是一些数据统计。

## Deploy Gas

- RC.sol: 281361 gas
- JC.sol: 607700 gas
- ACC.sol: 1049691 gas

## Bytecode size

- RC.sol: 7,735 bytes(7.7 KB)
- JC.sol: 17,174 bytes(17.2 KB) 
- ACC.sol: 31,231 bytes(31.2 KB)