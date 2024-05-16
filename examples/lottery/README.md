# 彩票抽奖实现

## 使用 [weather-oracle](https://github.com/MystenLabs/apps/weather-oracle) 获取随机数
## 对共享对象的使用与思考
##


```markdown
# todo 
1.event
2.单元测试
3.前端页面
```

## 如何获取Weather Oracle对象 object id?

# 发布合约
```shell
sui client publish --gas-budget 200000000 --json
```
package_id: 0xa9f30ece52e7a91ffc54149987759109d8674cf4c239acfd660a5210397b1636
lottery_id: 0xa54c3daf5b74498a580ca17bbf024af5c09f7dff37660b65cfdbf540ec424c13

```shell
sui client call --package  0xa9f30ece52e7a91ffc54149987759109d8674cf4c239acfd660a5210397b1636\
                --module lottery \
                --function buy_lottory \
                --gas-budget 100000000 \
                --args 0x6629eb758f2f791e2672573ecb1f816b288c9015f20e7d8f7a1d085fac42b003 \
                       1 \
                       0x1146516728e9ae2129522f44ceff901b79a4c37e66f91cdb791aca2c2865976f \
                       0x6 
```

```shell
 Created Objects:                                                                                      │
│  ┌──                                                                                                  │
│  │ ObjectID: 0x1f386c5014a02b80d68a41b121b267106cc85858e5e9c700b6214360b18cdf4f                       │
│  │ Sender: 0xe29fa8db4cb05d9b3b436784f146e1297f65fffdd5f69f7803844a5d81e0850c                         │
│  │ Owner: Account Address ( 0xe29fa8db4cb05d9b3b436784f146e1297f65fffdd5f69f7803844a5d81e0850c )      │
│  │ ObjectType: 0xa9f30ece52e7a91ffc54149987759109d8674cf4c239acfd660a5210397b1636::lottery::AdminCap  │
│  │ Version: 106488267                                                                                 │
│  │ Digest: 7XbvHJLbvqZd7qm9NuKH1XqcTCitoHK14jyf9qFfDJ8x                                               │
│  └──                                                                                                  │
│  ┌──                                                                                                  │
│  │ ObjectID: 0x64b2bbfb85a9772d48c1bcb4e888cdbedc3993cd495aaba439e8a818178fb36c                       │
│  │ Sender: 0xe29fa8db4cb05d9b3b436784f146e1297f65fffdd5f69f7803844a5d81e0850c                         │
│  │ Owner: Account Address ( 0xe29fa8db4cb05d9b3b436784f146e1297f65fffdd5f69f7803844a5d81e0850c )      │
│  │ ObjectType: 0x2::package::Publisher                                                                │
│  │ Version: 106488267                                                                                 │
│  │ Digest: 46LKoZhHN5JpbEALRrnqpt4RgBvnBJ6Gjbk1Ta6TSCCG                                               │
│  └──                                                                                                  │
│  ┌──                                                                                                  │
│  │ ObjectID: 0x7ebd04d9c9b61c1e51411339c6e00d3c9d6de6555bd1741b5647f3bf0e4688f9                       │
│  │ Sender: 0xe29fa8db4cb05d9b3b436784f146e1297f65fffdd5f69f7803844a5d81e0850c                         │
│  │ Owner: Account Address ( 0xe29fa8db4cb05d9b3b436784f146e1297f65fffdd5f69f7803844a5d81e0850c )      │
│  │ ObjectType: 0x2::package::UpgradeCap                                                               │
│  │ Version: 106488267                                                                                 │
│  │ Digest: GdmkaMgjYdn4vfertfWSFKKZ42GpVmCCNUGThEo7gr4u 
```