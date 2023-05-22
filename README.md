# Prestare
复制主链状态，开启自己的私链节点
```shell
npx hardhat node --hostname 0.0.0.0 --port 8545
nohup npx hardhat node --hostname 0.0.0.0 --port 8545 >> log.txt 2>&1
```

当开启自己的私链节点后，可以部署合约
```
npx hardhat run .\scripts\deploy.ts --network localhost
```

通过script运行各种脚本
```
npx hardhat run .\test\testDeploy.ts --network localhost
```

想要运行test下已经写好的单元测试
```
npx hardhat test ./test/borrow.ts
```


