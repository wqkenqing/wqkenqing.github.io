---
title:  hive2总结
date: 2021-12-24 23:07:45
tags: bigdata
---
# Hive相关点小结
<!-- more -->

## 启动指令
1. hive ==  hive --service cli
不需要启动server，使用本地的metastore，可以直接做一些简单的数据操作和测试。
2. 启动hiveserver2
hive --service hiveserver2
3. beeline工具测试使用jdbc方式连接
beeline -u jdbc:hive2://localhost:10000

1.managed table
管理表。
删除表时，数据也删除了

2.external table
外部表。
删除表时，数据不删

## 建表:
CREATE TABLE IF NOT EXISTS t2(id int,name string,age int)
COMMENT 'xx'                                     //注释
ROW FORMAT DELIMITED                             //行分隔符
FIELDS TERMINATED BY ','                         //字段分隔符，这里使用的是逗号可以根据自己的需要自行进行修改
STORED AS TEXTFILE ;
### 外部表:
 CREATE  TABLE IF NOT EXISTS t2(id int,name string,age int)
 COMMENT 'xx' 
 ROW FORMAT DELIMITED 
 FIELDS TERMINATED BY ',' 
 STORED AS TEXTFILE ; 
### 分区表，桶表
#### 分区表
Hive中有分区表的概念。我们可以看到分区表具有重要的性能，而且分区表还可以将数据以一种符合逻辑的方式进行组织，比如分层存储。Hive的分区表，是把数据放在满足条件的分区目录下
CREATE TABLE t3(id int,name string,age int) 

PARTITIONED BY (Year INT, Month INT)   //按照年月进行分区

 ROW FORMAT DELIMITED                      //行分隔符

FIELDS TERMINATED BY ',' ;                    //字段分隔符，这里使用的是逗号可以根据自己的需要自行进行修改
load data local inpath '/home/zpx/customers.txt' into table t3 partition
#### 分桶表
这样做，在查找数据的时候就可以跨越多个桶，直接查找复合条件的数据了。速度快，时间成本低。Hive中的桶表默认使用的机制也是hash。
CREATE TABLE t4(id int,name string,age int) 

                   CLUSTERED BY (id) INTO 3 BUCKETS      //创建3个通桶表，按照字段id进行分桶

                   ROW FORMAT DELIMITED                     //行分隔符

                   FIELDS TERMINATED BY ',' ; 

load data local inpath '/home/centos/customers.txt' into table t4 ;

## 导入数据
load data local inpath '/home/zpx/customers.txt' into table t2 ; //local上传文件
load data inpath '/user/zpx/customers.txt' [overwrite] into table t2 //分布式文件系统上移动文件

## 建视图
Hive也可以建立视图，是一张虚表，方便我们进行操作.

create view v1 as select a.id aid,a.name ,b.id bid , b.order from customers a left outer join default.tt b on a.id = b.cid ;

## Hive的严格模式
Hive提供了一个严格模式，可以防止用户执行那些产生意想不到的不好的影响的查询。
使用了严格模式之后主要对以下3种不良操作进行控制：

1.分区表必须指定分区进行查询。
2.order by时必须使用limit子句。
3.不允许笛卡尔积。
![2019-03-18-17-13-36](http://img.wqkenqing.ren/2019-03-18-17-13-36.png)

## Hive的动态分区
像分区表里面存储了数据。我们在进行存储数据的时候，都是明确的指定了分区。在这个过程中Hive也提供了一种比较任性化的操作，就是动态分区，不需要我们指定分区目录，Hive能够把数据进行动态的分发,**我们需要将当前的严格模式设置成非严格模式，否则不允许使用动态分区**
set hive.exec.dynamic.partition.mode=nonstrict//设置非严格模式
## Hive的排序

Hive也提供了一些排序的语法，包括order by,sort by。

order by=MapReduce的全排序
sort by=MapReduce的部分排序
distribute by=MapReduce的分区

selece .......from ...... order by 字段；//按照这个字段全排序

selece .......from ...... sort by 字段； //按照这个字段局部有序

selece 字段.....from ...... distribute by 字段；//按照这个字段分区
特别注意的是：

1. 在上面的最后一个distribute by使用过程中，按照排序的字段要出现在最左侧也就是select中有这个字段，因为我们要告诉MapReduce你要按照哪一个字段分区，当然获取的数据中要出现这个字段了。类似于我们使用group by的用法，字段也必须出现在最左侧，因为数据要包含这个字段，才能按照这个字段分组，至于Hive什么时候会自行的开启MapReduce，那就是在使用聚合的情况下开启，使用select ...from ....以及使用分区表的selece ....from......where .....不会开启
2. distribute by与sort by可以组合使用，但是distribute by要放在前边，因为MapReduce要先分区，后排序，再归并

select 字段a,........from .......distribute by字段a，sort by字段
如果distribute by与sort by使用的字段一样，则可以使用cluster by 字段替代：
select 字段a,........from .......cluster by 字段

## 函数

1. show functions; 展示相关函数
2. desc function split;
3. desc function  extended split;  //查看函数的扩展信息

### 用户自定义函数（UDF）
具体步骤如下：

（1）.自定义类（继承UDF，或是GenericUDF。GenericUDF是更为复杂的抽象概念，但是其支持更好的null值处理同时还可以处理一些标准的UDF无法支持的编程操作）。
（2）.导出jar包，通过命令添加到hive的类路径。
$hive>add jar xxx.jar
（3）.注册函数
$hive>CREATE TEMPORARY FUNCTION 函数名 AS '具体类路径：包.类';
（4）.使用
 $hive>select 函数名(参数);
自定义实现类如下(继承UDF)：

