---
title: sqoop记录
date: 2018-03-04 10:54:48
tags: 日常总结
abstract: sqoop记录
---

##  将Mysql数据导入Hive中
<!-- more -->
命令:
```
sqoop import  
-Dorg.apache.sqoop.splitter.allow_text_splitter=true       
--connect jdbc:mysql://211.159.172.76:3306/solo
--username root 
--password 125323Wkq 
--table  tablename 
--hive-import 
--hive-table tablename 
```

### 整库导入

```
sqoop import-all-tables --connect jdbc:mysql://211.159.172.76:3306/ --username root --password 125323Wkq --hive-database solo  -m 10  
--create-hive-table  
--fields-terminated-by "\t"
--hive-import --hive-database qianyang --hive-overwrite
```
sqoop  import-all-tables -Dorg.apache.sqoop.splitter.allow_text_splitter=true --connect jdbc:mysql://211.159.172.76:3306/solo --username root --password 125323Wkq --hive-database blog  --create-hive-table  --hive-import --hive-overwrite -m 10 
  


### 单表导入

sqoop import  --connect   jdbc:mysql://211.159.172.76:3306/solo --username root     --password 125323Wkq    --table b3_solo_article --target-dir /blog/article   --hive-import  --hive-database blog  
--fields-terminated-by "\t" --hive-table article  --hive-overwrite
--m 10  

sqoop  import  --connect jdbc:mysql://211.159.172.76:3306/solo --username root --password 125323Wkq --table b3_solo_article --target-dir /blog/article --hive-import --hive-database blog  --create-hive-table  --hive-table article --hive-overwrite -m 1 
