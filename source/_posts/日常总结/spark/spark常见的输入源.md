---
title: spark常见的输入源
date: 2020-05-11
tags: 


---

spark 输入源整理

<!--more-->

# spark常见的输入源



## text

```java
public static void main(String[] args) {
        SparkConf conf = new SparkConf().setAppName("text_count");

        JavaSparkContext sc = new JavaSparkContext(conf);

        JavaRDD<String> tRDD = sc.textFile("/Users/kuiq.wang/Desktop/upload/yd_conver.txt", 3);

        long res = tRDD.count();

        log.info("text_count's result is [{}]", res);
    }
```



## collect

```
    public static void main(String[] args) {
        SparkConf conf = new SparkConf().setAppName("collectRDD");
        JavaSparkContext jsc = new JavaSparkContext(conf);

        JavaRDD collectRDD = jsc.parallelize(Arrays.asList(new String[]{"one", "two", "three"}));
         long res = collectRDD.count();

        log.info("collect rdd res is [{}]", res);
    }
```



## elasticsearch

准备



```maven
        <!--spark-es-->
        <dependency>
              <groupId>org.elasticsearch</groupId>
              <artifactId>elasticsearch-spark-20_2.11</artifactId>
              <version>6.7.2</version>
        </dependency>
```



```java
    public static void readES(String url, String index) {
        SparkConf conf = new SparkConf().setAppName("es_count").set("es.nodes", "data1:9200");
        JavaSparkContext jsc = new JavaSparkContext(conf);
        JavaPairRDD<String, Map<String, Object>> esRDD = JavaEsSpark.esRDD(jsc, "funnylog_test");
        long es = esRDD.count();
        System.out.println("res is :" + es);

    }
```



## hbase

```

```





## kafka

