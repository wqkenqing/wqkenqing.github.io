---

title: flume记录
date: 2019-06-13
tags: 

---
此处简介
<!--more-->
# flume记录

## from kafka
<!-- more -->
```
a1.sources = source1

a1.sources.source1.type = org.apache.flume.source.kafka.KafkaSource

a1.sources.source1.channels = c1

a1.sources.source1.batchSize = 5000

a1.sources.source1.batchDurationMillis = 2000
a1.sources.source1.zookeeperConnect = localhost:2181

#a1.sources.source1.kafka.brokerList = localhost:9092
a1.sources.source1.kafka.bootstrap.servers = localhost:9092
a1.sources.source1.topic = flumetest
a1.sources.source1.kafka.consumer.group.id = custom.g.id



a1.channels = c1

a1.channels.c1.type = memory

a1.channels.c1.capacity = 10000

a1.channels.c1.transactionCapacity = 10000

a1.channels.c1.byteCapacityBufferPercentage = 20

a1.channels.c1.byteCapacity = 800000



a1.sinks = k1

a1.sinks.k1.type = file_roll

a1.sinks.k1.channel = c1

a1.sinks.k1.sink.directory = /home/hadoop/testfile/flume
```

这里也有版本匹配的问题.经过多番尝试,这里的组合版本是flume1.6+kafka_2.11-2.2.0.tgz 
其它版本可能会有request header 问题.
另外还遇到了指定topic 和 zookeeper的问题.

执行语句:flume-ng agent -n a1 -c conf -f kafka.properties -Dflume.root.logger=INFO,console

## flume 采集到kafka




```
agent.sources=r1
agent.sinks=k1
agent.channels=c1

agent.sources.r1.type=exec
agent.sources.r1.command=tail /root/tomcat/logs/catalina.out
agent.sources.r1.restart=true
agent.sources.r1.batchSize=1000
agent.sources.r1.batchTimeout=3000
agent.sources.r1.channels=c1

agent.channels.c1.type=memory
agent.channels.c1.capacity=102400
agent.channels.c1.transactionCapacity=1000

agent.channels.c1.byteCapacity=134217728
agent.channels.c1.byteCapacityBufferPercentage=80

agent.sinks.k1.channel=c1
agent.sinks.k1.type=org.apache.flume.sink.kafka.KafkaSink
agent.sinks.k1.kafka.topic=sparkstreaming
agent.sinks.k1.kafka.zookeeperConnect=47.102.199.215:2181
#agent.sinks.k1.kafka.bootstrap.servers=47.102.199.215:9092
agent.sinks.k1.kafka.brokerList =47.102.199.215:9092
agent.sinks.k1.serializer.class=kafka.serializer.StringEncoder
agent.sinks.k1.flumeBatchSize=1000
agent.sinks.k1.useFlumeEventFormat=true


```