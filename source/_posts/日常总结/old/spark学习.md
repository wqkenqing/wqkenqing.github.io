---
title: spark学习
date: 2018-03-04 11:12:58
tags: 学习spark
---

# spark 学习
<!-- more -->

```
spark 作为主流的实时计算引擎,需要高度掌握
```
<!-- more -->

## spark介绍

Apache Spark是一用于实时处理的开源集群计算框架.持多种语言编程,Spark Streaming有高吞吐量和容错能力强等特点.
数据输入后可以用Spark的高度抽象原语如：map、reduce、join、window等进行运算,而结果也能保存在很多地方，如HDFS，数据库等。另外Spark Streaming也能和MLlib（机器学习）以及Graphx完美融合。

优点
+ 易用
+ 容错
+ spark体系整合

![spark&storm对比](http://img.wqkenqing.ren/2019-03-04-15-45-38.png)



## RDD详解
### RDD是什么
RDD：Spark的核心概念是RDD (resilientdistributed dataset)，指的是一个只读的，可分区的分布式数据集，这个数据集的全部或部分可以缓存在内存中，在多次计算间重用。

另:RDD即弹性分布式数据集，有容错机制并可以被并行操作的元素集合，具有只读、分区、容错、高效、无需物化、可以缓存、RDD依赖等特征。RDD只是数据集的抽象，分区内部并不会存储具体的数据。

RDD的五个特性
1. 有一个分片列表。就是能被切分，和hadoop一样的，能够切分的数据才能并行计算。 
2. 有一个函数计算每一个分片，这里指的是下面会提到的compute函数.
3. 对其他的RDD的依赖列表，依赖还具体分为宽依赖和窄依赖，但并不是所有的RDD都有依赖.
4. 可选：key-value型的RDD是根据哈希来分区的，类似于mapreduce当中的Paritioner接口，控制key分到哪个reduce。
5. 可选：每一个分片的优先计算位置（preferred locations），比如HDFS的block的所在位置应该是优先计算的位置。(存储的是一个表，可以将处理的分区“本地化”).


```scala
//只计算一次  
  protected def getPartitions: Array[Partition]  
  //对一个分片进行计算，得出一个可遍历的结果
  def compute(split: Partition, context: TaskContext): Iterator[T]
  //只计算一次，计算RDD对父RDD的依赖
  protected def getDependencies: Seq[Dependency[_]] = deps
  //可选的，分区的方法，针对第4点，类似于mapreduce当中的Paritioner接口，控制key分到哪个reduce
  @transient val partitioner: Option[Partitioner] = None
  //可选的，指定优先位置，输入参数是split分片，输出结果是一组优先的节点位置
  protected def getPreferredLocations(split: Partition): Seq[String] = Nil

```

### 为什么会产生RDD

### RDD数据集
1. 并行集合

接收一个已经存在的集合,然后进行各种并行计算.并行化集合是通过调用SparkContext的parallelize方法，在一个已经存在的Scala集合上创建（一个Seq对象）。集合的对象将会被拷贝，创建出一个可以被并行操作的分布式数据集。

2. Hadoop数据集

Spark可以将任何Hadoop所支持的存储资源转化成RDD，只要文件系统是HDFS，或者Hadoop支持的任意存储系统即可，如本地文件（需要网络文件系统，所有的节点都必须能访问到）、HDFS、Cassandra、HBase、Amazon S3等，Spark支持文本文件、SequenceFiles和任何Hadoop InputFormat格式。

此两种类型的RDD都可以通过相同的方式进行操作，从而获得子RDD等一系列拓展，形成lineage血统关系图。


### Spark RDD算子
1. Transformation
不触发提交作业，完成作业中间处理过程。



## DStream
### 什么是DStream

Discretized Stream :代表持续性的数据流和经过各种Spark原语操作后的结果数据流,在内部实现上是一系列连续的RDD来表示.每个RDD含有一段时间间隔内的数据,如下图
![DStream](http://img.wqkenqing.ren/2019-03-04-15-50-41.png)

计算则由spark engine来完成
![spark engine流程](http://img.wqkenqing.ren/2019-03-04-15-51-58.png)




## spark java 

因为我是主要掌握的语言是java,从效率上来考虑,这里






## 参考博客

https://blog.csdn.net/wangxiaotongfan/article/details/51395769 RDD详解
https://blog.csdn.net/zuochang_liu/article/details/81459185  spark streaming学习
https://blog.csdn.net/hellozhxy/article/details/81672845 spark java 使用指南
https://blog.csdn.net/t1dmzks/article/details/70198430 sparkRDD算子介绍
https://blog.csdn.net/wxycx11111/article/details/79123482 **sparkRDD入门介绍**
https://github.com/zhaikaishun/spark_tutorial **RDD算子介绍**
