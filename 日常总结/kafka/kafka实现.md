---
title: kafka学习
date: 
tags: kafka
abstract: kafka high level
---

[ x ]  Consumer Group里只会被某一个Consumer消费 ,Kafka还允许不同Consumer Group同时消费同一条消息，这一特性可以为消息的多元化处理提供支持。
<!--more-->
## kafka 发送模式
通过producer.type设置,可以设置producer的发送模式,具体参数据有
producer.type=false即同步(默认就是同步),设置为true为异步,即以batch形式像broker发送信息.(这里的batch可以设置)
还有一种oneway.即通过对ack的设置即可实现,ack=0时,即为oneway,只管发,不管是否接收成功.-1则是全部副本接收成功才算成功.

## kakfa消费模式
1. at last one
2. at most one
3. exactly one


