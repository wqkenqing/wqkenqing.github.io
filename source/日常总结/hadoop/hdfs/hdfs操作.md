---

title: hdfs操作细节
date: 2019-05-16
tags: 

---

针对hdfs一些较细节的api封装

<!--more-->

# hdfs操作

## 常规操作
1. 创建文件 
2. 写数据 
3. 删除文件 
4. 上传文件 
5. 下载文件 
6. 断点续写

``` error
错误：

    java.io.IOException: Failed to replace a bad datanode on the existing pipeline due to no more good datanodes being available to try
```

原因：
    无法写入；我的环境中有3个datanode，备份数量设置的是3。在写操作时，它会在pipeline中写3个机器。默认replace-datanode-on-failure.policy是DEFAULT,如果系统中的datanode大于等于3，它会找另外一个datanode来拷贝。目前机器只有3台，因此只要一台datanode出问题，就一直无法写入成功。
    
```xml
<property>

        <name>dfs.client.block.write.replace-datanode-on-failure.enable</name>         <value>true</value>

    </property>

   

    <property>
    <name>dfs.client.block.write.replace-datanode-on-failure.policy</name>

        <value>NEVER</value>

    </property>
```

对于dfs.client.block.write.replace-datanode-on-failure.enable，客户端在写失败的时候，是否使用更换策略，默认是true没有问题
对于，dfs.client.block.write.replace-datanode-on-failure.policy，default在3个或以上备份的时候，是会尝试更换结点尝试写入datanode。而在两个备份的时候，不更换datanode，直接开始写。对于3个datanode的集群，只要一个节点没响应写入就会出问题，所以可以关掉。