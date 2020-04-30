---

title: flink学习
date: 2019-07-31
tags: flink

---

flink内容记录

<!--more-->

## 搭建

## 创建maven项目

```
mvn archetype:generate \
    -DarchetypeGroupId=org.apache.flink \
    -DarchetypeArtifactId=flink-quickstart-java \
    -DarchetypeVersion=1.6.1 \
    -DgroupId=my-flink-project \
    -DartifactId=my-flink-project \
    -Dversion=0.1 \
    -Dpackage=myflink \
    -DinteractiveMode=false

```

```

mvn clean package -Dmaven.test.skip=true

```

```
flink run -c myflink.demo.SocketTextStreamWordCount my-flink-project-0.1.jar 127.0.0.1 9000
```

## DataStream API
flink程序工作解剖图
![](http://img.wqkenqing.ren/FIyXNI.png)

### 执行环境

flink支持
- 获取已经存在的flink环境
- 创建一个本地环境
- 创建一个远程环境

### DataSource

#### 预置source

Socket-based

- socketTextStream();

File-based

### Transfomations

- map
- flatMap
- filter
- keyBy
- reduce
- fold

合计

- min
- max
- sum

窗口




