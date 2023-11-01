---

title: hadoop高可用模式搭建
date: 2019-05-16
tags: 

---

发现对hadoop的相关版本的组件,进程还有些模糊,借着针对hadoopHA模式搭建的过程,对hadoop
进行一次细统的回顾.

<!--more-->

# hadoop HA搭建与总结

## 什么是HA

HA即高可用

## HA相关配置

### core-site.xml

基本一致

### hdfs-site.xml

这里有明显差别
hadoop2.X与hadoop1.X的高可能中的明显差异就是从这里开始的.
2.x 引入了nameservice. 该nameservice可支持最大两个namenode.
1.x img 和edits统一放置在namenode上.
2.x 则通过journalnodes来共享edits日志.
```xml
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<!--
            Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License. See accompanying LICENSE file.
-->

<!-- Put site-specific property overrides in this file. -->
<configuration>
 <!-- 为namenode集群定义一个services name -->
  <property>
    <name>dfs.nameservices</name>
    <value>ns1</value>
  </property>
  
    <!-- nameservice 包含哪些namenode，为各个namenode起名 -->
    <property>
      <name>dfs.ha.namenodes.ns1</name>
      <value>namenode,datanode1</value>
    </property>
  
   <!-- 名为master188的namenode的rpc地址和端口号，rpc用来和datanode通讯 -->
    <property>
      <name>dfs.namenode.rpc-address.ns1.namenode</name>
      <value>namenode:9000</value>
    </property>
  
    <!-- 名为master189的namenode的rpc地址和端口号，rpc用来和datanode通讯 -->
    <property>
      <name>dfs.namenode.rpc-address.ns1.datanode1</name>
      <value>datanode1:9000</value>
    </property>

  <!--名为master188的namenode的http地址和端口号，用来和web客户端通讯 -->
  <property>
    <name>dfs.namenode.http-address.ns1.namenode</name>
    <value>namenode:50070</value>
  </property>

  <!-- 名为master189的namenode的http地址和端口号，用来和web客户端通讯 -->
  <property>
    <name>dfs.namenode.http-address.ns1.datanode1</name>
    <value>datanode1:50070</value>
  </property>

 <!-- namenode间用于共享编辑日志的journal节点列表 -->
  <property>
    <name>dfs.namenode.shared.edits.dir</name>
    <value>qjournal://namenode:8485;datanode1:8485;datanode2:8485/ns1</value>
  </property>
  
    <!-- 指定该集群出现故障时，是否自动切换到另一台namenode -->
    <property>
      <name>dfs.ha.automatic-failover.enabled.ns1</name>
      <value>true</value>
    </property>
    
    
      <!-- journalnode 上用于存放edits日志的目录 -->
      <property>
        <name>dfs.journalnode.edits.dir</name>
        <value>/home/hadoop/hadoop_store/dfs/data/dfs/journalnode</value>
      </property>
  
  <!-- 客户端连接可用状态的NameNode所用的代理类 -->
    <property>
      <name>dfs.client.failover.proxy.provider.ns1</name>
      <value>org.apache.hadoop.hdfs.server.namenode.ha.ConfiguredFailoverProxyProvider</value>
    </property>
  
    <!-- 一旦需要NameNode切换，使用ssh方式进行操作 -->
    <property>
      <name>dfs.ha.fencing.methods</name>
      <value>sshfence</value>
    </property>
  
    <!-- 如果使用ssh进行故障切换，使用ssh通信时用的密钥存储的位置 -->
    <property>
      <name>dfs.ha.fencing.ssh.private-key-files</name>
      <value>/home/hadoop/.ssh/id_rsa</value>
    </property>
  
    <!-- connect-timeout超时时间 -->
    <property>
      <name>dfs.ha.fencing.ssh.connect-timeout</name>
      <value>30000</value>
    </property>
       <property>
                <name>dfs.name.dir</name>
                <value>/home/hadoop/hadoop_store/dfs/name</value>
        </property>
        <property>
                <name>dfs.data.dir</name>
                <value>/home/hadoop/hadoop_store/dfs/data</value>
        </property>
        <property>
                <name>dfs.permissions</name>
                <value>false</value>
        </property>
<property>

<name>dfs.replication</name>

<value>3</value>

</property>
</configuration>

```

### mapreduce-site.xml
变动不大
### yarn-site.xml

```xml

<?xml version="1.0"?>
<!--
            Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License. See accompanying LICENSE file.
-->
<configuration>
    
    

       <!-- 启用HA高可用性 -->
        <property>
          <name>yarn.resourcemanager.ha.enabled</name>
          <value>true</value>
        </property>
      
        <!-- 指定resourcemanager的名字 -->
        <property>
          <name>yarn.resourcemanager.cluster-id</name>
          <value>yrc</value>
        </property>
      
        <!-- 使用了2个resourcemanager,分别指定Resourcemanager的地址 -->
        <property>
          <name>yarn.resourcemanager.ha.rm-ids</name>
          <value>rm1,rm2</value>
        </property>
        
        <!-- 指定rm1的地址 -->
        <property>
          <name>yarn.resourcemanager.hostname.rm1</name>
          <value>namenode</value>
        </property>
        
        <!-- 指定rm2的地址  -->
        <property>
          <name>yarn.resourcemanager.hostname.rm2</name>
          <value>datanode1</value>
        </property>
        
        <!-- 指定当前机器master188作为rm1 -->
        <property>
          <name>yarn.resourcemanager.ha.id</name>
          <value>rm1</value>
        </property>
        
        <!-- 指定zookeeper集群机器 -->
        <property>
          <name>yarn.resourcemanager.zk-address</name>
          <value>namenode:2181,datanode1:2181,datanode2:2181</value>
        </property>
        
        <!-- NodeManager上运行的附属服务，默认是mapreduce_shuffle -->
        <property>
          <name>yarn.nodemanager.aux-services</name>
          <value>mapreduce_shuffle</value>
        </property>
      
        <property>
                <name>yarn.resourcemanager.hostname</name>
                <value>kuiqwang</value>
        </property>
        <property>
                <name>yarn.nodemanager.aux-services</name>
                <value>mapreduce_shuffle</value>
        </property>
  <property>
    <name>yarn.log.server.url</name>
    <value>http://namenode:19888/tmp/logs/hadoop/logs/</value>
  </property>

                <property>
                <name>yarn.nodemanager.local-dirs</name>
                <value>/home/hadoop/hadoop_store/logs/yarn</value>
        </property>
           <property>
                <name>yarn.nodemanager.log-dirs</name>
                <value>/home/hadoop/hadoop_store/logs/userlogs</value>
        </property>
<!--内存,核数大小配置 -->

        <property>
      <name>yarn.nodemanager.resource.memory-mb</name>
      <value>4096</value>
  </property>

  <property>
      <name>yarn.scheduler.minimum-allocation-mb</name>
      <value>1024</value>
  </property>
  <property>
      <name>yarn.scheduler.maximum-allocation-mb</name>
      <value>3072</value>
  </property>
  <property>
      <name>yarn.app.mapreduce.am.resource.mb</name>
      <value>3072</value>
  </property>
  <property>
      <name>yarn.app.mapreduce.am.command-opts</name>
      <value>-Xmx3276m</value>
  </property>
    <property>
      <name>yarn.nodemanager.resource.cpu-vcores</name>
      <value>2</value>
  </property>
  <property>
      <name>yarn.scheduler.maximum-allocation-vcores</name>
      <value>3</value>
  </property>
</configuration>


```

### HA过程中主要用到的操作命令

当配置文件完成后,先启动journalnode,以助namenode 和standby node 共享edits文件
hadoop-daemon.sh
![](http://img.wqkenqing.ren/urHEX6.png)

然后再进行namdnode格式化,hadoop namenode -format
进行namenode格式化
当namenode格式化完成后可以先启动该节点的namenode
hadoop-daemon.sh start namenode
然后再在另一namdnode节点执行
hdfs namenode -bootstrapStandby
到这可以将之前的journalnode停用,然后start-dfs.sh

因为要用到zookeeper协助同步配置文件与操作日志,所以这里可以先对zookeeper进行hdfs内容的格式化
hdfs zkfc –formatZK
然后启动FailOver进程
hadoop-daemon.sh start zkfc
![](http://img.wqkenqing.ren/lvuo9N.png)
至此则是这些进程
然后启用yarn.
即
start-yarn.sh
到这里HA过程中用到的一些常用指令大致总结完成

---
至此 hadoop HA的常规总结完成.后续再补充一些细节,如standy 节点切的,与切换机制.HA背后的运作机制,与效果


