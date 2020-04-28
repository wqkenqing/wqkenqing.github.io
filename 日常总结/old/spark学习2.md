---
title: spark学习2
date: 2018-03-04 11:12:58
tags: 学习spark2
---
# spark学习2
## spark 运行的四种模式
<!-- more -->

### 本地模式
如
```
./bin/spark-submit --class org.apache.spark.examples.SparkPi --master local[1] ./lib/spark-examples-1.3.1-hadoop2.4.0.jar 100
```

### standlone模式

#### client 
./bin/spark-submit --class org.apache.spark.examples.SparkPi --master spark://spark001:7077 --executor-memory 1G --total-executor-cores 1 ./lib/spark-examples-1.3.1-hadoop2.4.0.jar 100
#### cluster
./bin/spark-submit --class org.apache.spark.examples.SparkPi --master spark://spark001:7077 --deploy-mode cluster --supervise --executor-memory 1G --total-executor-cores 1 ./lib/spark-examples-1.3.1-hadoop2.7.0.jar 100

### Yarn模式
#### client模式
```
client模式：
结果xshell可见：
./bin/spark-submit --class org.apache.spark.examples.SparkPi --master yarn-client --executor-memory 1G --num-executors 1 ./lib/spark-examples-1.3.1-hadoop2.7.0.jar 100
```
#### cluster模式
./bin/spark-submit --class org.apache.spark.examples.SparkPi --master yarn-cluster --executor-memory 1G --num-executors 1 ./lib/spark-examples-1.3.1-hadoop2.4.0.jar 100

## spark sql


