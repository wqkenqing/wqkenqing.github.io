---
title: kafka
date: 2020-05-11
tags: kafka
---
kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic sparkstreaming
kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic flumetest
<!-- more -->

kafka-console-producer.sh --broker-list localhost:9092 --topic flumetest :创建生产者

kafka-console-consumer.sh --bootstrap-server namenode:9092  --topic  flume-ng

# Kafka相关小结

##  kafka 相关指令
kafka-server-start.sh config/server.properties & 启动
kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic topic_name  :创建topic
kafka-console-producer.sh --broker-list localhost:9092 --topic topic_name :创建生产者

kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic topic_name :创建消费者

kafka-console-producer.sh --broker-list namenode:9092 --topic sparkstreaming

删除group

kafka-consumer-groups --bootstrap-server 192.168.10.100:9092,192.168.10.101:9092,192.168.10.102:9092  —group traffic_history —delete


## kafka java api
kafka 虽然搭建较为简单,但想要对针它编程体验还是有些问题.初步使用下来明显感觉对版本的强约束性.以我线上版本

![2019-03-12-11-02-43](http://img.wqkenqing.ren/2019-03-12-11-02-43.png)为例,我java项目对应的版本则是
``` java

<dependency>
            <groupId>org.apache.kafka</groupId>
            <artifactId>kafka_2.10</artifactId>
            <version>0.8.1</version>
        </dependency>
        <dependency>
            <groupId>org.apache.kafka</groupId>
            <artifactId>kafka-clients</artifactId>
            <version>0.8.2.1</version>
        </dependency>
```

以上版本搭配经由我亲测通过
