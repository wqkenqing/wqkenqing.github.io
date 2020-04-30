---
title: spark算子
tags: spark学习
date: 2018-03-04 11:12:5
---


# spark 算子
<!-- more -->
```
sparkRDD封装的函数方法又称算子,通过这些算子可以对RDD进行相关处理,从而获我们想要的结果,因为可能涉及的算子较多.因此单独开篇进行粒度更细,更集中的总结.

总得来讲spark的算子,本就是scala集合的一些高阶用法.

```
## Transformation(转换)
不触发提交作业，完成作业中间处理过程。

### parallelize (并行化)
将一个存在的集合，变成一个RDD ,返回的是一个JavaRDD[T] 
** in scala **
``` scala 
 sc.parallelize(List("shenzhen", "is a beautiful city"))
 ```
 ** in java **
 ```java
 JavaRDD<String> javaStringRDD = sc.parallelize(Arrays.asList("shenzhen", "is a beautiful city"));
```
### makeRDD
只有scala版本的才有makeRDD ,与parallelize类似.

### textFile
调用SparkContext.textFile()方法，从外部存储中读取数据来创建 RDD 
** in scala **
 ``` scala
 var lines = sc.textFile(inpath) 
```
```java
// java
 JavaRDD<String> lines = sc.textFile(inpath);
```

### filter
对RDD数据进行过滤
### map
接收一个函数,并将这个函数作用于RDD中的每个元素.RDD 中对应**元素的值 map是一对一的关系 **

### flatMap
有时候，我们希望对某个元素生成多个元素，实现该功能的操作叫作 flatMap() ,faltMap的函数应用于每一个元素，对于每一个元素返回的是多个元素组成的迭代器

### distinct
去重,我们生成的RDD可能有重复的元素，使用distinct方法可以去掉重复的元素, 不过此方法涉及到混洗，操作开销很大 
### union
两个RDD进行合并 
### intersection
RDD1.intersection(RDD2) 返回两个RDD的交集，** 并且去重 **
intersection 需要混洗数据，比较浪费性能
### subtract
RDD1.subtract(RDD2),返回在RDD1中出现，但是不在RDD2中出现的元素，不去重 
### cartesian
cartesian(RDD2) 返回RDD1和RDD2的笛卡儿积，这个开销非常大
### mapToPair 
将元素该成key-value形式
### flatMapToPair
差异同mapToPair
### combineByKey
该方法主要针对不同分区的同一key进行元素合并函数操作.
需要对pairRDD进行
1. createCombiner  会遍历分区中的所有元素，因此每个元素的键要么还没有遇到过,要么就 
和之前的某个元素的键相同。如果这是一个新的元素， combineByKey() 会使用一个叫作 createCombiner() 的函数来创建 
那个键对应的累加器的初始值
2. mergeValue 如果这是一个在处理当前分区之前已经遇到的键， 它会使用 mergeValue() 方法将该键的累加器对应的当前值与这个新的值进行合并
3. mergeCombiners 于每个分区都是独立处理的， 因此对于同一个键可以有多个累加器。如果有两个或者更 
多的分区都有对应同一个键的累加器， 就需要使用用户提供的 mergeCombiners() 方法将各 
个分区的结果进行合并。
### reduceByKey
接收一个函数，按照相同的key进行reduce操
### foldByKey
该函数用于RDD[K,V]根据K将V做折叠、合并处理，其中的参数zeroValue表示先根据映射函数将zeroValue应用于V,进行初始化V,再将映射函数应用于初始化后的V ,与reduce不同的是 foldByKey开始折叠的第一个元素不是集合中的第一个元素，而是传入的一个元素 
### sortByKey
SortByKey用于对pairRDD按照key进行排序，第一个参数可以设置true或者false，默认是true 
### groupByKey
groupByKey会将RDD[key,value] 按照相同的key进行分组，形成RDD[key,Iterable[value]]的形式， 有点类似于sql中的groupby，例如类似于mysql中的group_concat 
### cogroup
groupByKey是对单个 RDD 的数据进行分组，还可以使用一个叫作 cogroup() 的函数对多个共享同一个键的 RDD 进行分组
RDD1.cogroup(RDD2) 会将RDD1和RDD2按照相同的key进行分组，得到(key,RDD[key,Iterable[value1],Iterable[value2]])的形式 
### subtractByKey
类似于subtrac，删掉 RDD 中键与 other RDD 中的键相同的元素
### join
可以把RDD1,RDD2中的相同的key给连接起来，类似于sql中的join操作
RDD1.join(RDD2) 
### fullOuterJoin
全连接
### leftOuterJoin
### rightOuterJoin


## Action
### first
返回第一个元素 
### take
rdd.take(n)返回第n个元素 
### collect
rdd.collect() 返回 RDD 中的所有元素 
### count
rdd.count() 返回 RDD 中的元素个数 
### countByValue
各元素在 RDD 中出现的次数 返回{(key1,次数),(key2,次数),…(keyn,次数)} 
### reduce
并行整合RDD中所有数据
### fold
和 reduce() 一 样， 但是提供了初始值num,每个元素计算时，先要合这个初始值进行折叠, 注意，这里会按照每个分区进行fold，然后分区之间还会再次进行fold 
### top
rdd.top(n) 
按照降序的或者指定的排序规则，返回前n个元素 
### takeOrdered
rdd.take(n) 
对RDD元素进行升序排序,取出前n个元素并返回，也可以自定义比较器（这里不介绍），类似于top的相反的方法 
### foreach
对 RDD 中的每个元素使用给 
定的函数
### countByKey
以RDD{(1, 2),(2,4),(2,5), (3, 4),(3,5), (3, 6)}为例 rdd.countByKey会返回{(1,1),(2,2),(3,3)} 
### collectAsMap
将pair类型(键值对类型)的RDD转换成map, 还是上面的例子
### saveAsTextFile
saveAsTextFile用于将RDD以文本文件的格式存储到文件系统中。
### saveAsSequenceFile
saveAsSequenceFile用于将RDD以SequenceFile的文件格式保存到HDFS上。
### saveAsObjectFile
saveAsObjectFile用于将RDD中的元素序列化成对象，存储到文件中。
### saveAsHadoopFile

### saveAsNewAPIHadoopFile

### mapPartitions 
### mapPartitionsWithIndex
### HashPartitioner
### RangePartitioner
### 自定义分区