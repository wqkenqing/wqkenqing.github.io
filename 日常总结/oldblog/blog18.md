---

title: flume小结
date: 2019-07-16
tags: 

---
此处简介
<!--more-->

## flume小结
`此次flume环境的搭建是针对实际日志业务，整个过程还算顺利`
针对flume的引入更多的偏向应用层面。所以更多的要熟悉相关配置与参数的设置

### flume的整体构思
采用的是flume框架中的flume-ng。整体架构如下图
![c6589103d8ba4dffaf21c52b37cc7e17-image.png](//img.wqkenqing.ren/file/2017/7/c6589103d8ba4dffaf21c52b37cc7e17-image.png)
log_product环节尚有争议，主要针对flume环节进行小结。
原从效率上考虑，打算在跳板机上搭建直接接入hadoop的单flume节点，因为网络权限等问题，无法直接写入所以放弃。转而改为在hadoop环境中也引入一个flume节点(flume-server)。因client是单节点，所以没有必要引入fail-over机制。因此flume-server也是单节点
。

---

###
写入hdfs时有三个参数要注意
rollSize
rollCount
rollInterval
这三个参数对写入单个hdfs文件时的大小，行，时间。

---
flume-ng agent -n agent1 -c conf -f flume-client.properties -Dflume.root.logger=DEBUG,console

flume-ng agent -n agent1 -c conf -f flume-client.properties -Dflume.root.logger=DEBUG,console &

flume-ng agent -n a1 -c ../conf -f flume-server.properties -Dflume.root.logger=DEBUG,console &