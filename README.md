# Prestare
复制主链状态，开启自己的私链节点
```shell
npx hardhat node --hostname 0.0.0.0 --port 8545
```

当开启自己的私链节点后，可以部署合约
```
npx hardhat run .\scripts\deploy.ts --network localhost
```


