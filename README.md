# Test_Fisco

> fisco-bcos搭建 four-node网络 并使用test_fisco 下的脚本文件进行技术风险检测



## 初始化Fisco-bcos 网络（v2.9.1）

```shell
cd fisco
# 若不存在nodes文件 需执行 bash build_chain.sh -d -l 127.0.0.1:4 -p 30300,20200,8545
# -d表示以docker方式启动
# -l指定ip列表及节点数，多个ip用逗号隔开
# -p表示指定端口号
# All completed说明成功

# 127.0.0.1处替换为对应${ip}
cd nodes/127.0.0.1

# 启动区块链节点容器
./start_all.sh
# or 去每一个node目录下执行start
# ./start.sh

# 关闭网络
# ./stop_all.sh

# 查看网络是否生成完毕 4node
docker ps -a

cp -r ./sdk/* ../../test_fisco/tools/console/conf/
cd ../../test_fisco/tools/console
# 将conf目录下的config-example.toml文件重命名为config.toml文件。
# 配置config.toml文件，其中添加注释的内容根据区块链节点配置做相应修改。
# 提示：如果搭链时设置的channel_listen_ip(若节点版本小于v2.3.0，查看配置项listen_ip)为127.0.0.1或者0.0.0.0，channel_port为20200， 则config.toml配置不用修改。
```

查询、更新

```shell
./start.sh 进入控制台 # 输入q退出

# 运行getDeployLog，查询群组内由当前控制台部署合约的日志信息。日志信息包括部署合约的时间，群组ID，合约名称和合约地址。
getDeployLog

# 注册
# 部署合约。(默认提供HelloWorld合约和TableTest.sol进行示例使用) 参数：
# 部署HelloWorld合约，默认路径
[group:1]> deploy HelloWorld
contract address:0xc0ce097a5757e2b6e189aa70c7d55770ace47767

# 部署HelloWorld合约，相对路径
[group:1]> deploy contracts/solidity/HelloWorld.sol
contract address:0xd653139b9abffc3fe07573e7bacdfd35210b5576

# 部署HelloWorld合约，绝对路径
[group:1]> deploy ~/fisco/console/contracts/solidity/HelloWorld.sol
contract address:0x85517d3070309a89357c829e4b9e2d23ee01d881



# save & query

# 调用HelloWorld的get接口获取name字符串
[group:1]> call HelloWorld 0x175b16a1299c7af3e2e49b97e68a44734257a35e get
---------------------------------------------------------------------------------------------
Return code: 0
description: transaction executed successfully
Return message: Success
---------------------------------------------------------------------------------------------
Return values:
[
    "Hello,World!"
]
---------------------------------------------------------------------------------------------

# 调用HelloWorld的set接口设置name字符串
[group:1]> call HelloWorld 0x175b16a1299c7af3e2e49b97e68a44734257a35e set "Hello, FISCO BCOS"
transaction hash: 0x54b7bc73e3b57f684a6b49d2fad41bd8decac55ce021d24a1f298269e56f1ce1
---------------------------------------------------------------------------------------------
transaction status: 0x0
description: transaction executed successfully
---------------------------------------------------------------------------------------------
Output
Receipt message: Success
Return message: Success
---------------------------------------------------------------------------------------------
Event logs
Event: {}

# 调用HelloWorld的get接口获取name字符串，检查设置是否生效
[group:1]> call HelloWorld 0x175b16a1299c7af3e2e49b97e68a44734257a35e get
---------------------------------------------------------------------------------------------
Return code: 0
description: transaction executed successfully
Return message: Success
---------------------------------------------------------------------------------------------
Return values:
[
    "Hello,FISCO BCOS"
]
---------------------------------------------------------------------------------------------


# 调用TableTest的insert接口插入记录，字段为name, item_id, item_name
[group:1]> call TableTest 0x5f248ad7e917cddc5a4d408cf18169d19c0990e5 insert "fruit" 1 "apple"
transaction hash: 0x64bfab495dc1f50c58d219b331df5a47577aa8afc16be926260238a9b0ec0fbb
---------------------------------------------------------------------------------------------
transaction status: 0x0
description: transaction executed successfully
---------------------------------------------------------------------------------------------
Output
Receipt message: Success
Return message: Success
---------------------------------------------------------------------------------------------
Event logs
Event: {"InsertResult":[1]}

# 调用TableTest的select接口查询记录
[group:1]> [group:1]> call TableTest 0x5f248ad7e917cddc5a4d408cf18169d19c0990e5 select "fruit"
---------------------------------------------------------------------------------------------
Return code: 0
description: transaction executed successfully
Return message: Success
---------------------------------------------------------------------------------------------
Return values:
[
    [
        "fruit"
    ],
    [
        1
    ],
    [
        "apple"
    ]
]
---------------------------------------------------------------------------------------------

```



## 测试

测试中转结果存放在result文件夹中，测试最终结果打印在命令行

```shell
cd ../..

# 基础query & invoke
# 关于query
./test_query_or_invoke.sh query 1 TableTest 0x841ca048dcaff1569346b60ad30e9f08ee0f32e0 select fruit
./test_query_or_invoke.sh query 2 TableTest 0x841ca048dcaff1569346b60ad30e9f08ee0f32e0 select fruit
# or ./example_query.sh 1 && ./example_query.sh 2

# 关于invoke
./test_query_or_invoke.sh invoke TableTest 0x841ca048dcaff1569346b60ad30e9f08ee0f32e0 insert fruit 1 apple
# or ./example_invoke.sh

# 测试是否使用微服务架构
./test_docker_architecture.sh

# 测试所有加密算法 若bug可替换其中的路径为密钥存放的绝对路径
./detect_encryption_method.sh

# 测试可维护性 使用混沌工程工具chaosblade制造故障
./test_blade.sh

# 打印链码所有函数（弃用）
# ./print_chaincode_function.sh

# 打印区块数据 是否加密
./test_data_crypt.sh

# 测试交易幂等性、持久性
./test_data_duration.sh

# 测试node高可用性
./test_node_high_available.sh invoke 0 TableTest 0x841ca048dcaff1569346b60ad30e9f08ee0f32e0 insert fruit 1 apple
# or in query mod
# ./test_node_high_available.sh query 0 TableTest 0x841ca048dcaff1569346b60ad30e9f08ee0f32e0 select fruit

# 测试node数据一致性
./test_node_data_consistency.sh

# 验证共识节点(Raft)
./test_node_raft.sh
```

