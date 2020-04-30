---

title: kafka小结
date: 2019-07-16
tags: 

---
此处简介
<!--more-->

## kafka小结

消息系统术语
kafka特性
+ 分布式的
+ 可分区的
+ 可复制的

在普通的消息系统的功上，还有自己独特的设计


Kafka将消息以topic为单位进行归纳。
将向Kafka topic发布消息的程序成为producers.
将预订topics并消费消息的程序成为consumer.
Kafka以集群的方式运行，可以由一个或多个服务组成，每个服务叫做一个broker.
producers通过网络将消息发送到Kafka集群，集群向消费者提供消息，

![827fdc820cae4619859042761c3b40a9-image.png](//img.wqkenqing.ren/file/2017/7/827fdc820cae4619859042761c3b40a9-image.png)



客户端和服务端通过TCP协议通信。Kafka提供了Java客户端，并且对多种语言都提供了支持。


---

Topics 和Logs

先来看一下Kafka提供的一个抽象概念:topic.
一个topic是对一组消息的归纳。对每个topic，Kafka 对它的日志进行了分区
![bf0d2ddee1d14cb29fd54483a622d67c-image.png](//img.wqkenqing.ren/file/2017/7/bf0d2ddee1d14cb29fd54483a622d67c-image.png)


一个topic是对一组消息的归纳。
对每个topic，Kafka 对它的日志进行了分区，


每个分区都由一系列有序的、不可变的消息组成，这些消息被连续的追加到分区中。分区中的每个消息都有一个连续的序列号叫做offset,用来在分区中唯一的标识这个消息。



---
### kafka常用指令收集

**查看topic的详细信息**
kafka-topics.sh -zookeeper 127.0.0.1:2181 -describe -topic topic name

**为topic增加副本**
kafka-reassign-partitions.sh -zookeeper 127.0.0.1:2181 -reassignment-json-file json/partitions-to-move.json -execute
**创建topic**
kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic name
**为topic增加partition**
kafka-topics.sh –zookeeper 127.0.0.1:2181 –alter –partitions 20 –topic name
**kafka生产者客户端命令**
kafka-console-producer.sh --broker-list localhost:9092 --topic name
**kafka消费者客户端命令**
kafka-console-consumer.sh -zookeeper localhost:2181 --from-beginning --topic name
**kafka服务启动**
kafka-server-start.sh -daemon ../config/server.properties
**删除topic**
kafka-run-class.sh kafka.admin.DeleteTopicCommand --topic testKJ1 --zookeeper 127.0.0.1:2181
kafka-topics.sh --zookeeper localhost:2181 --delete --topic testKJ1
**查看consumer组内消费的offset**
kafka-run-class.sh kafka.tools.ConsumerOffsetChecker --zookeeper localhost:2181 --group test --topic name