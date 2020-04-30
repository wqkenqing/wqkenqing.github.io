---

title: spark操作.md
date: 2019-05-17
tags: 

---
spark编程积累

<!--more-->

# spark编程

## Input
### hdfs
操作hdfs比较常规,直接通过
context.textfile(path) //即可实现
### hbase
hbase 则要通过newAPIHadoopRDD来实现
```java

JavaPairRDD<ImmutableBytesWritable, Result> javaRDD = jsc.newAPIHadoopRDD(HbaseOperate.getConf(), TableInputFormat.class, ImmutableBytesWritable.class, Result.class);

```
这里要特别说明的是,这里的conf承担了更多的责任,如指定表名,指定scan传输字符串等.
```java

    Configuration hconf = HbaseOperate.getConf();
        Scan scan = new Scan();
        hconf.set(TableInputFormat.INPUT_TABLE, "company");
        hconf.set(TableInputFormat.SCAN, convertScanToString(scan));

```
参考以上这段代码

另
```java
   static String convertScanToString(Scan scan) throws IOException {
        ClientProtos.Scan proto = ProtobufUtil.toScan(scan);
        return Base64.encodeBytes(proto.toByteArray());
    }
```
以上是为实现scan指令传输字符的封装.

两者底层都是通过persist实现

